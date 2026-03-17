addEventHandler("onResourceStart", resourceRoot, function()
	lastTime = getRealTime().timestamp
	serverCurrentTimeSec = getRealTime().timestamp
end)

addEvent("getServerCurrentTimeSec", true)
addEventHandler("getServerCurrentTimeSec", root, function()
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	triggerClientEvent(source, "setServerCurrentTimeSec", source, now())
end)
