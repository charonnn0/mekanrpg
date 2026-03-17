local fadeAlpha = 0
local fadeStartTick = 0
local fadeDuration = 1000
local fadeTarget = 0
local fadeCallback = nil
local isFading = false
local holdAfterFadeIn = false

function fadeIn(duration, callback)
	fadeDuration = duration or 1000
	fadeStartTick = getTickCount()
	fadeTarget = 255
	fadeCallback = callback
	holdAfterFadeIn = true

	if not isFading then
		isFading = true
		addEventHandler("onClientRender", root, renderFade)
	end
end

function fadeOut(duration, callback)
	if callback then
		callback()
	end

	fadeDuration = duration or 1000
	fadeStartTick = getTickCount()
	fadeTarget = 0
	fadeCallback = nil
	holdAfterFadeIn = false

	if not isFading then
		isFading = true
		addEventHandler("onClientRender", root, renderFade)
	end
end

function renderFade()
	local nowTick = getTickCount()
	local elapsed = nowTick - fadeStartTick
	local progress = math.min(elapsed / fadeDuration, 1)

	if fadeTarget == 255 then
		fadeAlpha = interpolateBetween(fadeAlpha, 0, 0, 255, 0, 0, progress, "InOutQuad")
	else
		fadeAlpha = interpolateBetween(fadeAlpha, 0, 0, 0, 0, 0, progress, "InOutQuad")
	end

	dxDrawRectangle(0, 0, screenSize.x, screenSize.y, tocolor(0, 0, 0, fadeAlpha), true)

	if progress >= 1 then
		if fadeTarget == 255 then
			fadeAlpha = 255
			if fadeCallback then
				fadeCallback()
				fadeCallback = nil
			end
		else
			fadeAlpha = 0
			isFading = false
			removeEventHandler("onClientRender", root, renderFade)
		end
	end
end
