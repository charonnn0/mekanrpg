function sendWeather(player)
	local realTime = getRealTime()
	local hour, minute, second = realTime.hour, realTime.minute, realTime.second
	if player then
		triggerClientEvent(player, "weather.gotTimeChange", player, hour, minute, second)
	else
		triggerClientEvent(root, "weather.gotTimeChange", root, hour, minute, second)
	end
end
addEvent("weather.requestWeather", true)
addEventHandler("weather.requestWeather", root, sendWeather)

addEventHandler("onResourceStart", resourceRoot, function()
	sendWeather()
	setTimer(sendWeather, 10000, 0)
end)
