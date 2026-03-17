local loaded = {
	removals = {},
	objects = {},
	blips = {},
}

function loadOneObject(obj, loaded, isTest)
	if obj.radius then
		if removeWorldModel(obj.model, obj.radius, obj.posX, obj.posY, obj.posZ, obj.interior) then
			if obj.lodModel and tonumber(obj.lodModel) and obj.lodModel ~= obj.model then
				if removeWorldModel(obj.lodModel, obj.radius, obj.posX, obj.posY, obj.posZ, obj.interior) then
					table.insert(loaded.removals, {
						obj.lodModel,
						obj.radius,
						obj.posX,
						obj.posY,
						obj.posZ,
						obj.interior,
					})
				end
			end

			table.insert(loaded.removals, {
				obj.model,
				obj.radius,
				obj.posX,
				obj.posY,
				obj.posZ,
				obj.interior,
			})

			if isTest then
				local blip = createBlip(obj.posX, obj.posY, obj.posZ, 0, 1)
				if blip then
					table.insert(loaded.blips, blip)
				end
			end
		end
	else
		local createdObject = createObject(obj.model, obj.posX, obj.posY, obj.posZ, obj.rotX, obj.rotY, obj.rotZ)
		if createdObject then
			setElementInterior(createdObject, obj.interior)
			setElementDimension(createdObject, obj.dimension)
			setObjectBreakable(createdObject, obj.breakable == 1)
			setElementCollisionsEnabled(createdObject, obj.collisions ~= 0)

			if obj.scale and tonumber(obj.scale) then
				setObjectScale(createdObject, obj.scale)
			end

			setElementDoubleSided(createdObject, obj.doublesided == 1)

			if obj.alpha and tonumber(obj.alpha) then
				setElementAlpha(createdObject, obj.alpha)
			end

			table.insert(loaded.objects, createdObject)

			if isTest then
				local blip = createBlip(obj.posX, obj.posY, obj.posZ, 0, 1)
				if blip then
					if obj.interior and obj.interior ~= 0 then
						setElementInterior(blip)
					end

					if obj.dimension and obj.dimension ~= 0 then
						setElementDimension(blip)
					end

					table.insert(loaded.blips, blip)
				end
			end
		end
	end
end

function loadMap(contents, mapID, isTest)
	loaded = {
		removals = {},
		objects = {},
		blips = {},
	}

	if isMapLoaded(mapID) then
		unloadMap(mapID)
	end

	if contents then
		for _, obj in pairs(contents) do
			loadOneObject(obj, loaded, isTest)
		end
	end

	loadedMaps[mapID] = loaded

	return loaded
end
addEvent("maps.loadMap", true)
addEventHandler("maps.loadMap", root, loadMap)

function unloadMap(mapID)
	local result = {
		objects = 0,
		removals = 0,
		blips = 0,
	}
	local loadedMap = isMapLoaded(mapID)

	if loadedMap then
		for index, obj in pairs(loadedMap.objects) do
			if destroyElement(obj) then
				result.objects = result.objects + 1
			end
		end

		for index, obj in pairs(loadedMap.removals) do
			if restoreWorldModel(unpack(obj)) then
				result.removals = result.removals + 1
			end
		end

		for index, blip in pairs(loadedMap.blips) do
			if destroyElement(blip) then
				result.blips = result.blips + 1
			end
		end
		loadedMaps[mapID] = nil
	end
	return result
end
addEvent("maps.unloadMap", true)
addEventHandler("maps.unloadMap", root, unloadMap)

function isMapLoaded(mapID, isTemp)
	if loadedMaps[mapID] then
		if isTemp then
			return #loadedMaps[mapID].blips > 0 and loadedMaps[mapID] or false
		else
			return loadedMaps[mapID]
		end
	else
		return false
	end
end

function unloadAllMaps(isTest)
	local result = {}
	for mapID, map in pairs(loadedMaps) do
		local res = {
			objects = 0,
			removals = 0,
			blips = 0,
		}

		if isTest then
			if #map.blips > 0 then
				res = unloadMap(mapID)
			end
		else
			res = unloadMap(mapID)
		end

		if res.objects > 0 or res.removals > 0 or res.blips > 0 then
			table.insert(result, res)
		end
	end
	return result
end

function requestServerMaps()
	triggerServerEvent("maps.requestServerMaps", localPlayer)
end
addEvent("maps.requestServerMaps", true)
addEventHandler("maps.requestServerMaps", root, requestServerMaps)

addCommandHandler("loadmaps", function()
	requestServerMaps()
end, false, false)

addEventHandler("onClientElementDataChange", resourceRoot, function(dataName, oldValue)
	if dataName == settings.elementDataName then
		local queue = getElementData(resourceRoot, settings.elementDataName)
		if queue and queue ~= oldValue then
			syncMaps()
		end
	end
end)

function syncMaps()
	local syncedMaps = getElementData(resourceRoot, settings.elementDataName)
	if syncedMaps then
		for mapID, _ in pairs(loadedMaps) do
			if not syncedMaps[mapID] and isMapLoaded(mapID) then
				unloadMap(mapID)
			end
		end
		for mapID, _ in pairs(syncedMaps) do
			if not isMapLoaded(mapID) then
				triggerLatentServerEvent("maps.requestServerMaps", localPlayer, mapID)
			end
		end
	end
end
addEventHandler("onClientResourceStart", resourceRoot, syncMaps)

addEventHandler("onClientResourceStop", resourceRoot, function()
	unloadAllMaps(false)
end)
