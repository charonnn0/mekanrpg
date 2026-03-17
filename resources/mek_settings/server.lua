local playerSettings = {}

addEvent("settings.sync", true)
addEventHandler("settings.sync", resourceRoot, function(clientSettings, initialSync)
	playerSettings[client] = clientSettings

	if initialSync then
		for _, player in ipairs(getElementsByType("player")) do
			if player ~= client then
				triggerClientEvent(player, "settings.sync", resourceRoot, client, clientSettings)
			end
		end
	end
end)

addEvent("settings.wantSync", true)
addEventHandler("settings.wantSync", resourceRoot, function(player)
	if playerSettings[player] then
		triggerClientEvent(client, "settings.sync", resourceRoot, player, playerSettings[player])
	end
end)

addEvent("settings.patch", true)
addEventHandler("settings.patch", resourceRoot, function(key, value)
	if not playerSettings[client] then
		playerSettings[client] = {}
	end
	playerSettings[client][key] = value

	for _, player in ipairs(getElementsByType("player")) do
		if player ~= client then
			triggerClientEvent(player, "settings.patch", resourceRoot, client, key, value)
		end
	end
end)

addEventHandler("onPlayerQuit", root, function()
	playerSettings[source] = nil
end)

addEventHandler("onResourceStart", resourceRoot, function()
	for _, player in ipairs(getElementsByType("player")) do
		playerSettings[player] = {}
	end
end)

function getPlayerSetting(player, key)
	if playerSettings[player] and playerSettings[player][key] ~= nil then
		return playerSettings[player][key]
	end
	return nil
end

function setPlayerSetting(player, key, value)
	if not playerSettings[player] then
		playerSettings[player] = {}
	end
	playerSettings[player][key] = value
	triggerClientEvent(player, "settings.patch", resourceRoot, key, value, false)
end

function getPlayerSettings(player)
	return playerSettings[player] or {}
end

function setPlayerSettings(player, settings)
	playerSettings[player] = settings
	triggerClientEvent(player, "settings.sync", resourceRoot, player, settings)
end

function getAllPlayersSettings()
	return playerSettings
end
