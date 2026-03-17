addEvent("pointingHand.sync", true)
addEventHandler("pointingHand.sync", root, function(pointingData)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not source or getElementType(source) ~= "player" then
		return
	end

	setElementData(source, "pointing_hand", pointingData, false)
	triggerClientEvent(root, "pointingHand.onSync", root, source, pointingData)
end)
