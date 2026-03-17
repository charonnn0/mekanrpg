local threads = {}
local threadTimer = nil
local total

function getMapObjects(mapID)
	local qh = dbQuery(exports.mek_mysql:getConnection(), "SELECT * FROM maps_objects WHERE map_id = ?", mapID)
	local res, nums, id = dbPoll(qh, 100000)
	if res then
		return res
	else
		dbFree(qh)
		outputDebugString("[MAPS] getMapObjects / Failed on ID #" .. tostring(mapID))
	end
end

function loadMap(mapID, massLoad)
	if isMapLoaded(mapID) then
		unloadMap(mapID, massLoad)
	end

	loadedMaps[mapID] = getMapObjects(mapID)

	if not massLoad then
		updateMapsLoadingQueue()
	end

	return loadedMaps[mapID]
end

function isMapLoaded(mapID)
	return loadedMaps[mapID]
end

function unloadMap(mapID, massLoad)
	loadedMaps[mapID] = nil
	if not massLoad then
		updateMapsLoadingQueue()
	end
	return true
end

function unloadAllMaps()
	loadedMaps = {}
	updateMapsLoadingQueue()
	return true
end

function requestServerMaps(mapID)
	if mapID then
		if isMapLoaded(mapID) then
			triggerLatentClientEvent(source, "maps.loadMap", source, loadedMaps[mapID], mapID)
		end
	else
		for mapID, map in pairs(loadedMaps) do
			triggerLatentClientEvent(source, "maps.loadMap", source, map, mapID)
		end
	end
end
addEvent("maps.requestServerMaps", true)
addEventHandler("maps.requestServerMaps", root, requestServerMaps)

function loadAllMaps()
	local qh = dbQuery(
		exports.mek_mysql:getConnection(),
		"SELECT o.* FROM maps m LEFT JOIN maps_objects o ON m.id = o.map_id WHERE m.approved = 1 AND m.enabled = 1"
	)
	local res, nums, id = dbPoll(qh, 100000)

	if res and nums > 0 then
		total = nums
		loadedMaps = {}
		for _, obj in ipairs(res) do
			loadedMaps[obj.map_id] = loadedMaps[obj.map_id] or {}
			table.insert(loadedMaps[obj.map_id], obj)
		end
		outputDebugString(
			"[MAPS] "
				.. total
				.. " adet harita objesi yüklenmeye başlandı. Tamamlanma süresi yaklaşık "
				.. exports.mek_global:formatMoney(
					((settings.loadSpeed + (#getElementsByType("player") * 100)) * total)
						/ 1000
						/ settings.loadSpeedMultipler
				)
				.. " saniye"
		)
		updateMapsLoadingQueue(true)
	else
		dbFree(qh)
	end
end

addEventHandler("onResourceStart", resourceRoot, function()
	if settings.startupEnabled then
		setTimer(loadAllMaps, settings.startupDelay, 1)
	end
end)

function resumeThreads()
	for i, co in ipairs(threads) do
		coroutine.resume(unpack(co))
		table.remove(threads, i)

		if i == settings.loadSpeedMultipler then
			break
		end
	end

	if #threads <= 0 then
		killTimer(threadTimer)
		threadTimer = nil
		outputDebugString("[MAPS] " .. total .. " harita yüklemesi tamamlandı.")
		updateMapsLoadingQueue()
	end
end

function updateMapsLoadingQueue(forced)
	local q = {}
	for mapID, mapData in pairs(loadedMaps) do
		if mapData then
			q[mapID] = true
		end
	end
	if forced or getElementData(resourceRoot, settings.elementDataName) ~= q then
		return setElementData(resourceRoot, settings.elementDataName, q, true)
	end
end
