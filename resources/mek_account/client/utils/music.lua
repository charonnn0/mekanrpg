Music = {}
Music.element = nil
Music.name = ""
Music.isEnabled = true

function Music.stop(forceStop)
	if Music.element and not countdownMusic then
		if forceStop then
			setSoundVolume(Music.element, 0)
			destroyElement(Music.element)
			Music.element = nil
		else
			local fadeDuration = 1500
			local steps = 100
			local stepDuration = fadeDuration / steps
			local initialVolume = getSoundVolume(Music.element)

			local currentStep = 0
			setTimer(function()
				currentStep = currentStep + 1
				local newVolume = initialVolume * (1 - currentStep / steps)

				if newVolume <= 0 then
					setSoundVolume(Music.element, 0)
					destroyElement(Music.element)
					Music.element = nil
					killTimer(sourceTimer)
				else
					setSoundVolume(Music.element, newVolume)
				end
			end, stepDuration, steps)
		end
	end
end

function Music.toggle()
	if not countdownMusic then
		Music.isEnabled = not Music.isEnabled

		exports.mek_json:save("authSettings", {
			isEnabled = Music.isEnabled,
		})

		if Music.isEnabled then
			Music.play()
		else
			Music.stop(true)
		end
	end
end

function Music.play()
	if Music.element or countdownMusic then
		return
	end

	local musicPreference, hasJSON = exports.mek_json:get("authSettings")
	Music.isEnabled = musicPreference.isEnabled
	if not hasJSON then
		Music.isEnabled = true
	end

	local path = "public/sounds/music.mp3"

	Music.name = "Sıfırdan Zirveye"

	if not Music.isEnabled then
		return
	end

	if fileExists(path) then
		Music.element = playSound(path, true)
		setSoundVolume(Music.element, 0.3)
	end
end
