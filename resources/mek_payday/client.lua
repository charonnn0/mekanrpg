local sound

addEvent("payday.playSound", true)
addEventHandler("payday.playSound", root, function()
	if sound and isElement(sound) then
		stopSound(sound)
	end

	sound = playSound("public/sounds/" .. math.random(9) .. ".mp3")
	setSoundVolume(sound, 0.5)
end)

addEvent("payday.stopSound", true)
addEventHandler("payday.stopSound", root, function()
	if sound and isElement(sound) then
		stopSound(sound)
		sound = nil
	end
end)
