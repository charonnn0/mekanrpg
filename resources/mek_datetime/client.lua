addEventHandler("onClientResourceStart", resourceRoot, function()
	serverCurrentTimeSec = 0
	lastTime = getRealTime().timestamp
	triggerServerEvent("getServerCurrentTimeSec", localPlayer)
end)

addEvent("setServerCurrentTimeSec", true)
addEventHandler("setServerCurrentTimeSec", root, function(_serverCurrentTimeSec)
	serverCurrentTimeSec = _serverCurrentTimeSec
end)
