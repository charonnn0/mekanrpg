local threads = {}
local threadTimer = nil
local loadSpeed = 50
local loadSpeedMultipler = 100
local loadTimeout = 60000

local queryToLoad = "SELECT interiors.interior_id, (CASE WHEN last_login IS NOT NULL THEN TO_SECONDS(last_login) ELSE NULL END) AS owner_last_login, interiors.id AS id, interiors.x AS x, interiors.y AS y, "
	.. " interiors.z AS z, interiorwithin, dimensionwithin, angle, interiorx, interiory, interiorz, interiors.interior, angleexit, type, disabled, locked, owner, cost, supplies, address, faction, interiors.name, "
	.. " keypad_lock, keypad_lock_pw, keypad_lock_auto, safepositionX, safepositionY, safepositionZ, safepositionRZ, furniture, tokenUsed, TO_SECONDS(last_used) AS lastused_sec, interiors.settings "
	.. " FROM `interiors` "
	.. " LEFT JOIN `interior_business` ON `interiors`.`id` = `interior_business`.`intID` "
	.. " LEFT JOIN characters ON interiors.owner=characters.id "

local function load(res)
	for _, thePlayer in ipairs(getElementsByType("player")) do
		setElementData(thePlayer, "interiormarker", false)
	end
	setInteriorSoundsEnabled(false)
	threads = {}

	local qh = dbQuery(exports.mek_mysql:getConnection(), queryToLoad .. " WHERE deleted = 0")
	local result, num_affected_rows, last_insert_id = dbPoll(qh, loadTimeout)
	if result and num_affected_rows > 0 then
		for _, row in ipairs(result) do
			local co = coroutine.create(loadOne)
			table.insert(threads, { co, row, nil, true })
		end
		threadTimer = setTimer(resumeThreads, loadSpeed, 0)
		outputDebugString(
			"[INTERIOR] Started loading "
				.. num_affected_rows
				.. " interiors. Finish in "
				.. exports.mek_global:formatMoney((loadSpeed * num_affected_rows) / 1000 / loadSpeedMultipler)
				.. " second(s)"
		)
	end
end
addEventHandler("onResourceStart", resourceRoot, load)

function resumeThreads()
	for i, co in ipairs(threads) do
		coroutine.resume(unpack(co))
		table.remove(threads, i)

		if i == loadSpeedMultipler then
			break
		end
	end

	if #threads <= 0 then
		killTimer(threadTimer)
		setTimer(triggerLatentClientEvent, 50000, 1, root, "interior.initializeSoFar", resourceRoot, true)
	end
end

function loadOne(data, updatePlayers, massLoad)
	if type(data) == "table" then
		local element = exports.mek_pool:getElementByID("interior", data.id)
		if element then
			if isElement(element) then
				destroyElement(element)
			end
			element = nil
		end

		element = createElement("interior", "int" .. data.id)
		setElementData(element, "dbid", data.id)
		exports.mek_pool:allocateElement(element, data.id, true)

		if data.interior_id then
			setElementData(element, "interior_id", data.interior_id)
		end

		-- Parse settings first to get entrance fee
		local settings
		if data.settings then
			settings = fromJSON(data.settings)
		else
			settings = {}
		end
		local entranceFee = (settings and tonumber(settings.entranceFee)) or 0
		
		setElementData(element, "entrance", {
			x = data.x,
			y = data.y,
			z = data.z,
			int = data.interiorwithin,
			dim = data.dimensionwithin,
			rot = data.angle,
			fee = entranceFee,
		})
		setElementPosition(element, data.x, data.y, data.z)
		setElementInterior(element, data.interiorwithin)
		setElementDimension(element, data.dimensionwithin)

		setElementData(element, "exit", {
			x = data.interiorx,
			y = data.interiory,
			z = data.interiorz,
			int = data.interior,
			dim = data.id,
			rot = data.angleexit,
			fee = 0,
		})
		setElementData(element, "status", {
			type = data.type,
			disabled = data.disabled == 1,
			locked = data.locked == 1,
			owner = data.owner,
			cost = data.cost,
			supplies = data.supplies,
			faction = data.faction,
			furniture = data.furniture == 1,
			tokenUsed = data.tokenUsed == 1,
		})
		setElementData(element, "name", data.name)
		setElementData(element, "address", data.address)

		if data.lastused_sec then
			setElementData(element, "last_used", tonumber(data.lastused_sec))
		end

		if data.owner_last_login then
			setElementData(element, "owner_last_login", tonumber(data.owner_last_login))
		end

		if data.keypad_lock and data.type ~= 2 and data.owner and data.owner > 0 then
			setElementData(element, "keypad_lock", data.keypad_lock)
			if data.keypad_lock_pw then
				setElementData(element, "keypad_lock_pw", data.keypad_lock_pw)
			end
			if data.keypad_lock_auto then
				setElementData(element, "keypad_lock_auto", data.keypad_lock_auto == 1)
			end
		end

		if data.safepositionX then
			exports.mek_interior:addSafe(
				data.id,
				nil,
				{ data.safepositionX, data.safepositionY, data.safepositionZ },
				data.interior,
				data.safepositionRZ,
				false,
				true
			)
		end

		if updatePlayers then
			if isElement(updatePlayers[2]) then
				if isElement(updatePlayers[1]) then
					triggerLatentClientEvent(updatePlayers[1], "drawAllMyInteriorBlips", updatePlayers[2])
				end
				triggerLatentClientEvent(updatePlayers[2], "drawAllMyInteriorBlips", updatePlayers[2])
			end
		end

		if not massLoad then
			triggerLatentClientEvent(root, "interior.schedulePickupLoading", resourceRoot, element)
		end

		-- Settings already parsed above, just set element data
		setElementData(element, "settings", settings or {})

		return true
	elseif tonumber(data) then
		dbQuery(
			function(qh, updatePlayers)
				local result, num_affected_rows, last_insert_id = dbPoll(qh, 0)
				if result then
					loadOne(result[1], updatePlayers)
				end
			end,
			{ updatePlayers },
			exports.mek_mysql:getConnection(),
			queryToLoad .. " WHERE interiors.id = ? " .. (loadDeletedOne and "" or " AND deleted = 0"),
			data
		)
	end
end

function unload(int)
	int = isElement(int) and int or exports.mek_pool:getElementByID("interior", int)
	if int then
		exports.mek_interior:clearSafe(getElementData(int, "dbid") or 0)
		destroyElement(int)
	end
end

addEventHandler("onResourceStop", resourceRoot, function()
	triggerEvent("interior.clearAllSafes", resourceRoot)
end)
