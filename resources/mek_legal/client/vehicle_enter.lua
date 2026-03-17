addEventHandler("onClientVehicleStartEnter", root, function(thePlayer, seat, jacked)
	if thePlayer ~= localPlayer or seat ~= 0 then
		return
	end

	local vehicleFaction = tonumber(getElementData(source, "faction")) or -1

	if not exports.mek_faction:isPlayerInFaction(localPlayer, vehicleFaction) then
		local factionName = LEGAL_FACTION_NAMES[vehicleFaction]
		if factionName then
			cancelEvent()
			outputChatBox(
				"[!]#FFFFFF Bu aracı yalnızca " .. factionName .. " üyeleri kullanabilir.",
				255,
				0,
				0,
				true
			)
		end
	end
end)
