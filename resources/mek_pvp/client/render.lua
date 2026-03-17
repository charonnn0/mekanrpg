PointsDrawing = {}

local screenSize = Vector2(guiGetScreenSize())

local FONT_SIZE_MAIN = 30
local FONT_SIZE_MULTIPLIER = 24

local fontMain
local fontMultiplier

local textHeightMain
local state = "hide"

local themeColor = { 212, 0, 40 }

local pointsCount = 0
local currentMultiplier = 0
local targetAlpha = 0
local alpha = 0
local hidingTextScale = 1
local hidingTextAlpha = 255
local showingProgress = 0
local SHOWING_SPEED = 8
local HIDING_SPEED = 8

local isShaking = false
local shakingAmount = 0
local SHAKE_POWER = 5

local isCollision = false

local multiplierAlpha = 0

local targetPointsAngle = 0
local currentPointsAngle = 0

local bonusText = ""
local bonusAnimation = 1
local bonusOffset = 60
local bonusAnimationSpeed = 1.5

function PointsDrawing.show()
	if state == "hide" or state == "hiding" then
		state = "showing"
		targetAlpha = 255
		alpha = 0
		isCollision = false
		showingProgress = 0
		currentMultiplier = 0
		pointsCount = 0
		targetPointsAngle = 0
		currentPointsAngle = 0

		themeColor = { 162, 155, 254 }
		return true
	end
end

function PointsDrawing.collision()
	if isCollision then
		return
	end
	shakingAmount = 2
	targetPointsAngle = 0
	isCollision = true
end

function PointsDrawing.hide()
	if state == "show" then
		state = "hiding"
		targetAlpha = 0
		alpha = 255
		hidingTextScale = 1
		hidingTextAlpha = 255
		targetPointsAngle = 0
		bonusText = ""
	end
end

local function dxDrawTextShadow(text, x1, y1, x2, y2, color, scale, fontMain, alignX, alignY, textRotation, alpha)
	if not alpha then
		alpha = 255
	end

	dxDrawText(
		text,
		x1 - 1,
		y1,
		x2 - 1,
		y2,
		tocolor(0, 0, 0, alpha),
		scale,
		fontMain,
		alignX,
		alignY,
		false,
		false,
		false,
		false,
		false,
		textRotation
	)
	dxDrawText(
		text,
		x1 + 1,
		y1,
		x2 + 1,
		y2,
		tocolor(0, 0, 0, alpha),
		scale,
		fontMain,
		alignX,
		alignY,
		false,
		false,
		false,
		false,
		false,
		textRotation
	)
	dxDrawText(
		text,
		x1,
		y1 - 1,
		x2,
		y2 - 1,
		tocolor(0, 0, 0, alpha),
		scale,
		fontMain,
		alignX,
		alignY,
		false,
		false,
		false,
		false,
		false,
		textRotation
	)
	dxDrawText(
		text,
		x1,
		y1 + 1,
		x2,
		y2 + 1,
		tocolor(0, 0, 0, alpha),
		scale,
		fontMain,
		alignX,
		alignY,
		false,
		false,
		false,
		false,
		false,
		textRotation
	)
	dxDrawText(
		text,
		x1,
		y1,
		x2,
		y2,
		color,
		scale,
		fontMain,
		alignX,
		alignY,
		false,
		false,
		false,
		false,
		false,
		textRotation
	)
end

function PointsDrawing.draw()
	local textWidth = dxGetTextWidth(pointsCount, 1, fontMain)
	local textX = screenSize.x / 2 - textWidth / 2
	local textY = 80

	if state == "showing" or state == "hiding" then
		dxDrawTextShadow(
			pointsCount,
			textX,
			textY,
			textX + textWidth,
			textY + textHeightMain,
			tocolor(255, 255, 255, alpha),
			1,
			fontMain,
			"center",
			"center",
			0,
			alpha
		)
	elseif state == "show" then
		local textRotation = currentPointsAngle
		if isCollision then
			textRotation = (math.random() - 0.5) * 10 * shakingAmount + currentPointsAngle
			local ox = (math.random() - 0.5) * SHAKE_POWER * shakingAmount
			local oy = (math.random() - 0.5) * SHAKE_POWER * shakingAmount

			dxDrawText(
				pointsCount,
				textX + ox,
				textY + oy,
				textX + textWidth + ox,
				textY + textHeightMain + oy,
				tocolor(255, 0, 0, 170),
				1,
				fontMain,
				"center",
				"center",
				false,
				false,
				false,
				false,
				false,
				textRotation
			)

			local ox = (math.random() - 0.5) * SHAKE_POWER * shakingAmount
			local oy = (math.random() - 0.5) * SHAKE_POWER * shakingAmount

			dxDrawText(
				pointsCount,
				textX + ox,
				textY + oy,
				textX + textWidth + ox,
				textY + textHeightMain + oy,
				tocolor(50, 150, 255, 170),
				1,
				fontMain,
				"center",
				"center",
				false,
				false,
				false,
				false,
				false,
				textRotation
			)
		end

		local ox = (math.random() - 0.5) * SHAKE_POWER * shakingAmount
		local oy = (math.random() - 0.5) * SHAKE_POWER * shakingAmount

		dxDrawTextShadow(
			pointsCount,
			textX + ox,
			textY + oy,
			textX + textWidth + ox,
			textY + textHeightMain + oy,
			tocolor(255, 255, 255),
			1,
			fontMain,
			"center",
			"center",
			textRotation
		)

		if currentMultiplier > 0 and not isCollision then
			local mulText = "X" .. tostring(currentMultiplier)
			local mulTextWidth = dxGetTextWidth(mulText, 1, fontMultiplier)
			local mulX = textX + textWidth + ox + 5
			local mulY = textY + oy

			if multiplierAlpha > 0 then
				dxDrawText(
					mulText,
					mulX,
					mulY,
					mulX + mulTextWidth,
					mulY + textHeightMain / 2,
					tocolor(themeColor[1], themeColor[2], themeColor[3], 255 * multiplierAlpha),
					1 + 1 * multiplierAlpha,
					fontMultiplier,
					"center",
					"center",
					false,
					false,
					false,
					false,
					false,
					textRotation
				)
			end

			dxDrawTextShadow(
				mulText,
				mulX,
				mulY,
				mulX + mulTextWidth,
				mulY + textHeightMain / 2,
				tocolor(themeColor[1], themeColor[2], themeColor[3]),
				1,
				fontMultiplier,
				"center",
				"center",
				textRotation
			)
		end

		if bonusAnimation < 1 then
			local bonusAlpha = (1 - bonusAnimation) * 255
			local dy = -bonusOffset * bonusAnimation

			dxDrawText(
				bonusText,
				textX,
				textY + dy,
				textX + textWidth,
				textY + textHeightMain + dy,
				tocolor(225, 225, 225, bonusAlpha),
				1,
				fontMultiplier,
				"center",
				"top",
				false,
				false,
				false,
				false,
				false,
				0
			)
		end
	end

	if state == "hiding" and not isCollision then
		dxDrawText(
			pointsCount,
			textX,
			textY,
			textX + textWidth,
			textY + textHeightMain,
			tocolor(255, 255, 255, hidingTextAlpha),
			hidingTextScale,
			fontMain,
			"center",
			"center",
			false,
			false,
			false,
			false,
			false,
			currentPointsAngle
		)
	end
end

function PointsDrawing.update(deltaTime)
	deltaTime = deltaTime / 1000

	if state == "showing" then
		alpha = alpha + (targetAlpha - alpha) * SHOWING_SPEED * deltaTime
		showingProgress = showingProgress + deltaTime * 2

		if showingProgress > 1 then
			showingProgress = 1
		end

		if alpha > 250 then
			alpha = 255
			state = "show"
		end
	elseif state == "hiding" then
		alpha = alpha + (targetAlpha - alpha) * HIDING_SPEED * deltaTime
		hidingTextScale = hidingTextScale + deltaTime * 1
		hidingTextAlpha = hidingTextAlpha - deltaTime * 700

		if hidingTextAlpha < 0 then
			hidingTextAlpha = 0
		end

		if alpha < 5 then
			alpha = 0
			state = "hide"
		end

		if isCollision then
			pointsCount = pointsCount - 1
			if pointsCount < 0 then
				pointsCount = 0
			end
		end
	elseif state == "show" then
		multiplierAlpha = multiplierAlpha - deltaTime * 5
		if multiplierAlpha < 0 then
			multiplierAlpha = 0
		end

		if isCollision then
			pointsCount = pointsCount - math.ceil(pointsCount / 5)
			if pointsCount < 0 then
				pointsCount = 0
			end
		end
	end

	shakingAmount = shakingAmount - deltaTime * 2
	if shakingAmount < 0 then
		shakingAmount = 0
	end

	currentPointsAngle = currentPointsAngle + (targetPointsAngle - currentPointsAngle) * deltaTime * 3

	bonusAnimation = bonusAnimation + deltaTime * bonusAnimationSpeed
	if bonusAnimation > 1 then
		bonusAnimation = 1
	end
end

function PointsDrawing.updateMultiplier(multiplier)
	if multiplier then
		currentMultiplier = multiplier
		multiplierAlpha = 1
	end
end

function PointsDrawing.setShaking(shaking)
	if shaking then
		shakingAmount = 1
	end
	isShaking = shaking
end

function PointsDrawing.updatePointsCount(count, angle)
	pointsCount = tostring(count)
	if angle then
		targetPointsAngle = angle * 0.15
	end
end

function PointsDrawing.drawBonus(amount)
	bonusAnimation = 0
	bonusText = tostring(amount)
end

addEventHandler("onClientResourceStart", resourceRoot, function()
	fontMain = dxCreateFont(":mek_ui/public/fonts/UbuntuRegular.ttf", FONT_SIZE_MAIN) or "default"
	fontMultiplier = dxCreateFont(":mek_ui/public/fonts/UbuntuRegular.ttf", FONT_SIZE_MULTIPLIER) or "default"
	textHeightMain = dxGetFontHeight(1, fontMain)
end)
