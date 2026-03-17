local overlayWidth, overlayHeight = 400, 67
local isVisible = false
local overlayContent = {}
local closeTimer = nil
local cooldownSeconds = 15

local positionOffsetX, positionOffsetY = 0, 0
local baseYSpacing = 16

local fadeAlpha = 0
local fadeState = nil
local fadeSpeed = 0.05

local maxAlpha = 1

function drawOverlay(contentData, customWidth, offsetX, offsetY, cooldown)
	if closeTimer and isTimer(closeTimer) then
		killTimer(closeTimer)
	end

	if not contentData or type(contentData) ~= "table" then
		return false
	end

	overlayContent = contentData
	if customWidth then
		overlayWidth = customWidth
	end
	positionOffsetX = offsetX or 0
	positionOffsetY = offsetY or 0
	cooldownSeconds = cooldown or 10

	isVisible = true
	fadeState = "in"

	if cooldownSeconds > 0 then
		closeTimer = setTimer(function()
			fadeState = "out"
		end, cooldownSeconds * 1000, 1)
	end
end
addEvent("hud.drawOverlay", true)
addEventHandler("hud.drawOverlay", localPlayer, drawOverlay)

setTimer(function()
	if not isVisible or not getElementData(localPlayer, "logged") then
		return
	end

	if exports.mek_item:isInventoryVisible() then
		return
	end

	if fadeState == "in" then
		fadeAlpha = math.min(maxAlpha, fadeAlpha + fadeSpeed)
		if fadeAlpha >= maxAlpha then
			fadeState = nil
		end
	elseif fadeState == "out" then
		fadeAlpha = math.max(0, fadeAlpha - fadeSpeed)
		if fadeAlpha <= 0 then
			isVisible = false
			fadeState = nil
		end
	end

	if fadeAlpha <= 0 then
		return
	end

	local itemCount = #overlayContent
	local totalHeight = baseYSpacing * itemCount + 30
	local centerY = (screenSize.y - totalHeight) / 2
	local marginRight = 15
	local posX = screenSize.x - overlayWidth - marginRight + positionOffsetX
	local posY = centerY + positionOffsetY

	drawRoundedRectangle({
		position = {
			x = posX,
			y = posY,
		},
		size = {
			x = overlayWidth,
			y = totalHeight,
		},

		color = theme.GRAY[900],
		alpha = math.min(fadeAlpha, 0.9),
		radius = 8,

		borderWidth = 1,
		borderColor = theme.GRAY[800],
	})

	for i = 1, itemCount do
		local item = overlayContent[i]
		if item then
			local text = item[1] or ""
			local isBold = item[2] or false
			local font = isBold and fonts.BebasNeueBold.h2 or fonts.UbuntuRegular.body
			local color = isBold and theme.GRAY[100] or theme.GRAY[200]

			dxDrawText(
				text,
				posX + 17,
				posY + (baseYSpacing * i) + (isBold and 1 or 4),
				posX + overlayWidth - 5,
				15,
				rgba(color, fadeAlpha),
				1,
				font,
				"left",
				"top",
				false,
				false,
				false,
				true
			)
		end
	end
end, 0, 0)
