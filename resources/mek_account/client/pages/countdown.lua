local font = dxCreateFont(":mek_ui/public/fonts/Digital.ttf", 100) or "default"

local countdownTime = 0
local startTick = nil
local isCounting = false

countdownMusicStarted = false
countdownMusic = nil

local countdownAlpha = 0
local countdownFadeTime = 1500
local countdownFadeStartTick = nil
local countdownFadeOutStartTick = nil
local countdownFadeOutTime = 1500
local countdownEndWaitTime = 3000
local isFadingOut = false

function startCountdown(seconds)
	countdownTime = seconds
	startTick = getTickCount()
	countdownFadeStartTick = getTickCount()
	countdownAlpha = 0
	countdownMusicStarted = false

	if not isCounting then
		isCounting = true
		addEventHandler("onClientRender", root, renderCountdown)
		addEventHandler("onClientRender", root, renderSplash)
	end
end

function renderCountdown()
	local now = getTickCount()
	local elapsed = (now - startTick) / 1000
	local remaining = countdownTime - elapsed

	if remaining < 0 then
		remaining = 0
	end

	if not isFadingOut then
		local fadeElapsed = now - countdownFadeStartTick
		local progress = math.min(fadeElapsed / countdownFadeTime, 1)
		countdownAlpha = interpolateBetween(0, 0, 0, 255, 0, 0, progress, "InOutQuad")
	end

	if (remaining <= 40.5 and remaining < 41) and not countdownMusicStarted then
		countdownMusicStarted = true
		countdownMusic = playSound("public/sounds/countdown_music.mp3")
		if countdownMusic then
			setSoundVolume(countdownMusic, 0.7)
			
			addEventHandler("onClientSoundStopped", countdownMusic, function()
				countdownMusic = nil
				countdownMusicStarted = false
				
				if not localPlayer:getData("logged") then
					Music.play()
				end
			end)
		end
	end

	if remaining == 0 and not isFadingOut then
		countdownEndWaitTime = 3000
		countdownFadeOutStartTick = now + countdownEndWaitTime
		isFadingOut = true
	end

	if isFadingOut then
		if now >= countdownFadeOutStartTick then
			local fadeOutElapsed = now - countdownFadeOutStartTick
			local progress = math.min(fadeOutElapsed / countdownFadeOutTime, 1)
			countdownAlpha = interpolateBetween(255, 0, 0, 0, 0, 0, progress, "InOutQuad")

			if progress >= 1 then
				isCounting = false
				removeEventHandler("onClientRender", root, renderCountdown)
				
				triggerEvent("account.authPage", localPlayer)

				countdownAlpha = 0
				isFadingOut = false
			end
		end
	end

	local hours = math.floor(remaining / 3600)
	local minutes = math.floor((remaining % 3600) / 60)
	local seconds = math.floor(remaining % 60)
	local timeString = string.format("%02d:%02d:%02d", hours, minutes, seconds)

	if countdownAlpha > 0 then
		dxDrawText(
			timeString,
			screenSize.x / 2,
			screenSize.y / 2,
			screenSize.x / 2,
			screenSize.y / 2,
			tocolor(150, 210, 255, countdownAlpha),
			1,
			font,
			"center",
			"center",
			false,
			false,
			true
		)
	end
end

addEvent("account.countdownPage", true)
addEventHandler("account.countdownPage", root, function(remaining)
	if remaining > 0 then
		startCountdown(remaining)
	end
end)
