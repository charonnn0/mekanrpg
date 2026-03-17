local clientID = "1455934852481290450"

addEventHandler("onClientResourceStart", resourceRoot, function()
	if setDiscordApplicationID(clientID) then
		setRichPresenceOptions()
	end
end)

addEventHandler("onClientPlayerChangeNick", localPlayer, function()
	setRichPresenceOptions()
end)

addEventHandler("onClientPlayerJoin", root, function()
	setRichPresenceOptions()
end)

addEventHandler("onClientPlayerQuit", root, function()
	setRichPresenceOptions()
end)

addEventHandler("onClientElementDataChange", localPlayer, function(theKey, oldValue, newValue)
	if theKey == "logged" then
		setRichPresenceOptions()
	end
end)

function setRichPresenceOptions()
	if isDiscordRichPresenceConnected() then
		setTimer(function()
			local logged = getElementData(localPlayer, "logged") or false

			setDiscordRichPresenceAsset("logo", "Mekan Game")
			setDiscordRichPresenceSmallAsset("mtasa", "Multi Theft Auto")
			setDiscordRichPresenceDetails(logged and getPlayerName(localPlayer):gsub("_", " ") or "Giriş Ekranında")
			setDiscordRichPresenceState("Oyunda: " .. #getElementsByType("player") .. "/1000")

			setDiscordRichPresenceButton(1, "Sunucuya Katıl", "mtasa://" .. getServerIp(true))
			setDiscordRichPresenceButton(2, "Discord'a Katıl", "https://discord.gg/mekanrp")
		end, 500, 1)
	end
end
