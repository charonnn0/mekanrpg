local writing = false

function checkForWriting()
	if isChatBoxInputVisible() and not writing then
		writing = true
	elseif not isChatBoxInputVisible() and writing then
		writing = false
	end
	setElementData(localPlayer, "writing", writing)
end
setTimer(checkForWriting, 250, 0)

bindKey("b", "down", "chatbox", "LocalOOC")
bindKey("u", "down", "chatbox", "HızlıYanıt")
bindKey("y", "down", "chatbox", "Birlik")

addEvent("playRadioSound", true)
addEventHandler("playRadioSound", root, function()
	playSoundFrontEnd(47)
	setTimer(playSoundFrontEnd, 700, 1, 48)
	setTimer(playSoundFrontEnd, 800, 1, 48)
end)

addEvent("playCustomChatSound", true)
addEventHandler("playCustomChatSound", root, function(sound, forceStop)
	if forceStop and customChatSound and isElement(customChatSound) then
		stopSound(customChatSound)
	end

	customChatSound = playSound("public/sounds/" .. sound, false)
end)

addEvent("pm.client", true)
addEventHandler("pm.client", root, function()
	local pmSound = playSound(isMTAWindowFocused() and "public/sounds/pm.mp3" or "public/sounds/pm_afk.mp3", false)
	setSoundVolume(pmSound, isMTAWindowFocused() and 0.7 or 0.9)
end)
