CallSoundStreamer = {}
CallSoundStreamer.MAX_DIST = 6
CallSoundStreamer.sounds = {}

CallSoundStreamer.play = function(path, replay)
	setElementData(localPlayer, "phone.callSound", {
		path = path,
		replay = replay,
	})
end

CallSoundStreamer.destroyAllSounds = function()
	setElementData(localPlayer, "phone.callSound", nil)
end

addEventHandler("onClientElementDataChange", root, function(dataName, _, newValue)
	if not isElement(source) or dataName ~= "phone.callSound" then
		return
	end

	local distance = getDistanceBetweenPoints3D(localPlayer.position, source.position)

	if newValue then
		if distance < CallSoundStreamer.MAX_DIST then
			if isElement(CallSoundStreamer.sounds[source]) then
				destroyElement(CallSoundStreamer.sounds[source])
			end

			CallSoundStreamer.sounds[source] = playSound3D(newValue.path, source.position, newValue.replay)
			attachElements(CallSoundStreamer.sounds[source], source, 0, 0, 0)
			setSoundVolume(CallSoundStreamer.sounds[source], 0.2)
			setSoundMaxDistance(CallSoundStreamer.sounds[source], CallSoundStreamer.MAX_DIST)
		end
	else
		if isElement(CallSoundStreamer.sounds[source]) then
			destroyElement(CallSoundStreamer.sounds[source])
		end
	end
end)
