local flasherPermissions = {
	[0] = { flasherType = 1, requiredItemID = 61, allowedFactionIDs = { 1, 3 } },
	[1] = { flasherType = 3, requiredItemID = 140, allowedFactionIDs = { 2 } },
}

addEventHandler("onVehicleRespawn", root, function()
	setElementData(source, "police_flashers", nil)
end)

local function getFactionTypeAndID(vehicle)
	local factionID = getElementData(vehicle, "faction")
	if factionID then
		local factionElement = exports.mek_pool:getElementByID("team", factionID)
		if isElement(factionElement) then
			local factionType = tonumber(getElementData(factionElement, "type"))
			if factionType then
				return factionType, factionID
			end
		end
	end
	return nil, nil
end

local function isFlasherAllowed(vehicle, settings, factionID)
	if not settings then
		return false
	end

	if settings.requiredItemID and exports.mek_item:hasItem(vehicle, settings.requiredItemID) then
		return settings.flasherType
	end

	if settings.allowedFactionIDs and factionID then
		for _, allowedID in ipairs(settings.allowedFactionIDs) do
			if allowedID == factionID then
				return settings.flasherType
			end
		end
	end

	return false
end

function toggleFlasherState()
	if not client then
		return
	end

	local vehicle = getPedOccupiedVehicle(client)
	if not vehicle then
		return
	end

	local currentState = getElementData(vehicle, "police_flashers") or 0

	if currentState ~= 0 then
		setElementData(vehicle, "police_flashers", nil)
	else
		local factionType, factionID = getFactionTypeAndID(vehicle)

		if factionType and flasherPermissions[factionType] then
			local settings = flasherPermissions[factionType]
			local flasherType = isFlasherAllowed(vehicle, settings, factionID)
			if flasherType then
				setElementData(vehicle, "police_flashers", flasherType)
				return
			end
		end

		for _, settings in pairs(flasherPermissions) do
			if settings.requiredItemID and exports.mek_item:hasItem(vehicle, settings.requiredItemID) then
				setElementData(vehicle, "police_flashers", settings.flasherType)
				return
			end
		end

		outputChatBox("[!]#FFFFFF Bu araçta çakar takılı değil.", client, 255, 0, 0, true)
	end
end
addEvent("legal.toggleFlashers", true)
addEventHandler("legal.toggleFlashers", root, toggleFlasherState)
