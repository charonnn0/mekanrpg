function developerMode(commandName)
	if exports.mek_integration:isPlayerServerOwner(localPlayer) then
		local developmentMode = not getDevelopmentMode()
		setDevelopmentMode(developmentMode)
		showCol(developmentMode)
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", 255, 0, 0, true)
	end
end
addCommandHandler("devmode", developerMode, false, false)

addEvent("playNudgeSound", true)
addEventHandler("playNudgeSound", root, function()
	playSound("public/sounds/nudge.wav", false)
end)

addEvent("doEarthquake", true)
addEventHandler("doEarthquake", localPlayer, function()
	local x, y, z = getElementPosition(localPlayer)
	createExplosion(x, y, z, -1, false, 3.0, false)
end)

addEvent("copyPosToClipboard", true)
addEventHandler("copyPosToClipboard", localPlayer, function(text)
	setClipboard(text)
end)

-- Prevent taking damage while on admin duty (god mode)
addEventHandler("onClientPlayerDamage", localPlayer, function()
	if getElementData(localPlayer, "duty_admin") then
		cancelEvent()
	end
end)

