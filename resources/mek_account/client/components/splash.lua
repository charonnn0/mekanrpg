local splashTextureBg = nil
local splashTexture5 = nil

local musicStartTick = nil
local musicAlpha = 0
local musicFadeTime = 1500

local musicIconSize = {
	x = 32,
	y = 32,
}

local musicIconPosition = {
	x = 16,
	y = screenSize.y - 48,
}

addEventHandler("onClientResourceStart", resourceRoot, function()
	splashTextureBg = dxCreateTexture("public/images/splashs/bg.png")
	splashTexture5 = dxCreateTexture("public/images/splashs/5.png")
end)

function renderSplash()
	if splashTextureBg then
		dxDrawImage(0, 0, screenSize.x, screenSize.y, splashTextureBg, 0, 0, 0, tocolor(255, 255, 255, 240))
	end

	if Music and not getElementData(localPlayer, "logged") and not isEventHandlerAdded("onClientRender", root, renderCountdown) and passedIntro then
		if not musicStartTick then
			musicStartTick = getTickCount()
		end

		local elapsed = getTickCount() - musicStartTick
		local progress = math.min(elapsed / musicFadeTime, 1)
		musicAlpha = interpolateBetween(0, 0, 0, 255, 0, 0, progress, "InOutQuad")

		local musicToggleButton = drawButton({
			position = musicIconPosition,
			size = musicIconSize,

			textProperties = {
				align = "center",
				font = fonts.icon,
				scale = 0.5,
			},

			variant = "plain",
			color = "blue",
			alpha = musicAlpha / 255,
			disabled = countdownMusic,

			text = Music.isEnabled and "" or "",
		})

		if musicToggleButton.pressed then
			Music.toggle()
		end

		if not countdownMusic then
			drawTooltip({
				position = musicIconPosition,
				size = musicIconSize,
				
				radius = 4,
				text = Music.isEnabled and "Müziği kapatmak için tıklayın" or "Müziği açmak için tıklayın",
				description = "",
				
				alpha = musicAlpha / 255,
				
				align = "left",
				alignY = "top",
			})
		end

		dxDrawText(
			Music.name
				.. (
					Music.isEnabled
						and Music.element
						and (" (" .. convertMusicTime(math.floor(Music.element.playbackPosition)) .. "/" .. convertMusicTime(
							math.floor(Music.element.length)
						) .. ")")
					or ""
				),
			musicIconPosition.x + musicIconSize.x + 5,
			musicIconPosition.y + 8,
			0,
			0,
			rgba(theme.GRAY[200], musicAlpha / 255),
			1,
			fonts.UbuntuRegular.caption,
			"left",
			"top"
		)
	end
end

function renderSplashHome()
	if splashTexture5 then
		dxDrawImage(0, 0, screenSize.x, screenSize.y, splashTexture5, 0, 0, 0, tocolor(255, 255, 255, 180))
	end
end
