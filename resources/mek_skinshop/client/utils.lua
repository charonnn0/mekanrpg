local screenX, screenY = guiGetScreenSize()
local animateData = {}

local function respc(num)
	return num
end

function animate(key, data, duration, animateType)
	local duration = duration or 500
	local animateType = animateType or "Linear"

	if not animateData[key] then
		animateData[key] = {
			tick = getTickCount(),
			from = data.from,
			to = data.to,
			lastAction = data.state,
		}
	elseif animateData[key].lastAction then
		if data.state ~= animateData[key].lastAction then
			animateData[key].tick = getTickCount()
			animateData[key].from = data.from
			animateData[key].to = data.to
			animateData[key].lastAction = data.state
		end
	end

	animateData[key].lastAction = data.state
	local startTick = animateData[key].tick

	local elapsedTime = nowTick - startTick
	local duration = (startTick + duration) - startTick
	local progress = elapsedTime / duration

	local a, b, c = interpolateBetween(
		animateData[key]["from"][1],
		animateData[key]["from"][2],
		animateData[key]["from"][3],
		animateData[key]["to"][1],
		animateData[key]["to"][2],
		animateData[key]["to"][3],
		progress,
		animateType
	)

	return { a, b, c }
end

screenX, screenY = guiGetScreenSize()

local colorizePed = { 123 / 255, 47 / 255, 218 / 255, 1 }
local specularPower = 1.3
local effectMaxDistance = 10
local isPostAura = true

local scx, scy = guiGetScreenSize()
local effectOn = nil
local myRT = nil
local myShader = nil
local isMRTEnabled = false
local outlineEffect = {}
local PWTimerUpdate = 110

buttons = {}
activeButton = false

function cursorInBox(x, y, w, h)
	if x and y and w and h then
		if isCursorShowing() then
			if not isMTAWindowActive() then
				local cursorX, cursorY = getCursorPosition()

				cursorX, cursorY = cursorX * screenX, cursorY * screenY

				if cursorX >= x and cursorX <= x + w and cursorY >= y and cursorY <= y + h then
					return true
				end
			end
		end
	end

	return false
end

function dxDrawMetroBox(
	x,
	y,
	w,
	h,
	color,
	imagePath,
	imageW,
	imageH,
	imageColor,
	imageAlign,
	titleText,
	titleTextColor,
	titleTextFont,
	titleTextAlign,
	downText,
	downTextColor,
	downTextFont,
	downTextAlign,
	bg
)
	local fadeAmount = tabPanelAlphas[activePage]

	dxDrawRectangle(x, y, w, h, color)

	if bg then
		dxDrawRectangle(x, y, bg, h, tocolor(34, 70, 124, 255 * fadeAmount))
	end

	if imagePath then
		imageW = imageW or respc(100)
		imageH = imageH or respc(100)
		imageColor = imageColor or tocolor(255, 255, 255, 255 * fadeAmount)
		imageAlign = imageAlign or "center"

		if imageAlign == "center" then
			local imgX, imgY = x + (w - imageW) * 0.5, y + (h - imageH) * 0.5
			dxDrawImage(imgX, imgY, imageW, imageH, imagePath, 0, 0, 0, imageColor)
		elseif imageAlign == "left" then
			local imgX, imgY = x + respc(10), y + (h - imageH) * 0.5
			dxDrawImage(imgX, imgY, imageW, imageH, imagePath, 0, 0, 0, imageColor)
		elseif imageAlign == "right" then
			local imgX, imgY = x + w - imageW - respc(10), y + (h - imageH) * 0.5
			dxDrawImage(imgX, imgY, imageW, imageH, imagePath, 0, 0, 0, imageColor)
		end
	end

	if titleText then
		titleTextColor = titleTextColor or tocolor(255, 255, 255, 255 * fadeAmount)
		titleTextAlign = titleTextAlign or "left"
		titleTextFont = titleTextFont or fonts.Roboto11

		dxDrawText(
			titleText,
			x + respc(10),
			y + respc(10),
			x + w,
			y + w,
			titleTextColor,
			1,
			titleTextFont,
			titleTextAlign
		)
	end

	if downText then
		downTextColor = downTextColor or tocolor(255, 255, 255, 255 * fadeAmount)
		downTextAlign = downTextAlign or "right"
		downTextFont = downTextFont or fonts.Roboto11
		local fontHeight = dxGetFontHeight(1, downTextFont)

		dxDrawText(
			downText,
			x - respc(10),
			y + h - fontHeight - respc(10),
			(x + w) - respc(10),
			y + w,
			downTextColor,
			1,
			downTextFont,
			downTextAlign
		)
	end
end

function dxDrawMetroTileWithEffect(
	key,
	label,
	x,
	y,
	w,
	h,
	activeColor,
	imagePath,
	imageW,
	imageH,
	imageColor,
	imageAlign,
	titleText,
	titleTextColor,
	titleTextFont,
	titleTextAlign,
	downText,
	downTextColor,
	downTextFont,
	downTextAlign,
	centerText,
	centerTextColor,
	centerTextFont,
	centerTextAlign
)
	local buttonColor

	if activeButton == key then
		buttonColor = { processColorSwitchEffect(key, { activeColor[1], activeColor[2], activeColor[3], 175 }) }
	else
		buttonColor = { processColorSwitchEffect(key, { activeColor[1], activeColor[2], activeColor[3], 125 }) }
	end

	local alphaDifference = 175 - buttonColor[4]
	local fadeAmount = tabPanelAlphas[activePage]

	dxDrawRectangle(
		x,
		y,
		w,
		h,
		tocolor(buttonColor[1], buttonColor[2], buttonColor[3], (175 - alphaDifference) * fadeAmount)
	)
	dxDrawInnerBorder(
		2,
		x,
		y,
		w,
		h,
		tocolor(buttonColor[1], buttonColor[2], buttonColor[3], (125 + alphaDifference) * fadeAmount)
	)

	if imagePath then
		imageW = imageW or respc(100)
		imageH = imageH or respc(100)
		if imageColor then
			imageColor = tocolor(imageColor[1], imageColor[2], imageColor[3], imageColor[4] * fadeAmount)
				or tocolor(255, 255, 255, 255 * fadeAmount)
		else
			imageColor = tocolor(255, 255, 255, 255 * fadeAmount)
		end
		imageAlign = imageAlign or "center"

		if imageAlign == "center" then
			local imgX, imgY = x + (w - imageW) * 0.5, y + (h - imageH) * 0.5
			dxDrawImage(imgX, imgY, imageW, imageH, imagePath, 0, 0, 0, imageColor)
		elseif imageAlign == "left" then
			local imgX, imgY = x + respc(10), y + (h - imageH) * 0.5
			dxDrawImage(imgX, imgY, imageW, imageH, imagePath, 0, 0, 0, imageColor)
		elseif imageAlign == "right" then
			local imgX, imgY = x + w - imageW - respc(10), y + (h - imageH) * 0.5
			dxDrawImage(imgX, imgY, imageW, imageH, imagePath, 0, 0, 0, imageColor)
		end
	end

	if titleText then
		titleTextColor = titleTextColor or tocolor(255, 255, 255, 255 * fadeAmount)
		titleTextAlign = titleTextAlign or "left"
		titleTextFont = titleTextFont or fonts.Roboto11

		dxDrawText(
			titleText,
			x + respc(10),
			y + respc(10),
			x + w,
			y + w,
			titleTextColor,
			1,
			titleTextFont,
			titleTextAlign
		)
	end

	if downText then
		downTextColor = downTextColor or tocolor(255, 255, 255, 255 * fadeAmount)
		downTextAlign = downTextAlign or "right"
		downTextFont = downTextFont or fonts.Roboto11
		local fontHeight = dxGetFontHeight(1, downTextFont)

		dxDrawText(
			downText,
			x - respc(10),
			y + h - fontHeight - respc(10),
			(x + w) - respc(10),
			y + w,
			downTextColor,
			1,
			downTextFont,
			downTextAlign
		)
	end

	if centerText then
		centerTextColor = centerTextColor or tocolor(255, 255, 255, 255 * fadeAmount)
		centerTextAlign = centerTextAlign or "left"
		centerTextFont = centerTextFont or fonts.Roboto11
		local fontHeight = dxGetFontHeight(1, centerTextFont)

		local textX = x + respc(10)
		if imagePath then
			if imageAlign == "left" then
				textX = textX + imageW + respc(5)
			end
		end
		dxDrawText(centerText, textX, y, x + w, y + h, centerTextColor, 1, centerTextFont, centerTextAlign, "center")
	end

	buttons[key] = { x, y, w, h }
end

function dxDrawMetroTileWithoutBorder(
	key,
	label,
	x,
	y,
	w,
	h,
	activeColor,
	imagePath,
	imageW,
	imageH,
	imageColor,
	imageAlign,
	titleText,
	titleTextColor,
	titleTextFont,
	titleTextAlign,
	downText,
	downTextColor,
	downTextFont,
	downTextAlign,
	centerText,
	centerTextColor,
	centerTextFont,
	centerTextAlign
)
	local buttonColor

	if activeButton == key then
		buttonColor = { processColorSwitchEffect(key, { activeColor[1], activeColor[2], activeColor[3], 175 }) }
	else
		buttonColor = { processColorSwitchEffect(key, { activeColor[1], activeColor[2], activeColor[3], 125 }) }
	end

	local alphaDifference = 175 - buttonColor[4]
	local fadeAmount = tabPanelAlphas[activePage]

	dxDrawRectangle(
		x,
		y,
		w,
		h,
		tocolor(buttonColor[1], buttonColor[2], buttonColor[3], (175 - alphaDifference) * fadeAmount)
	)

	if imagePath then
		imageW = imageW or respc(100)
		imageH = imageH or respc(100)
		if imageColor then
			imageColor = tocolor(imageColor[1], imageColor[2], imageColor[3], imageColor[4] * fadeAmount)
				or tocolor(255, 255, 255, 255 * fadeAmount)
		else
			imageColor = tocolor(255, 255, 255, 255 * fadeAmount)
		end
		imageAlign = imageAlign or "center"

		if imageAlign == "center" then
			local imgX, imgY = x + (w - imageW) * 0.5, y + (h - imageH) * 0.5
			dxDrawImage(imgX, imgY, imageW, imageH, imagePath, 0, 0, 0, imageColor)
		elseif imageAlign == "left" then
			local imgX, imgY = x + respc(10), y + (h - imageH) * 0.5
			dxDrawImage(imgX, imgY, imageW, imageH, imagePath, 0, 0, 0, imageColor)
		elseif imageAlign == "right" then
			local imgX, imgY = x + w - imageW - respc(10), y + (h - imageH) * 0.5
			dxDrawImage(imgX, imgY, imageW, imageH, imagePath, 0, 0, 0, imageColor)
		end
	end

	if titleText then
		titleTextColor = titleTextColor or tocolor(255, 255, 255, 255 * fadeAmount)
		titleTextAlign = titleTextAlign or "left"
		titleTextFont = titleTextFont or fonts.Roboto11

		dxDrawText(
			titleText,
			x + respc(10),
			y + respc(10),
			x + w,
			y + w,
			titleTextColor,
			1,
			titleTextFont,
			titleTextAlign
		)
	end

	if downText then
		downTextColor = downTextColor or tocolor(255, 255, 255, 255 * fadeAmount)
		downTextAlign = downTextAlign or "right"
		downTextFont = downTextFont or fonts.Roboto11
		local fontHeight = dxGetFontHeight(1, downTextFont)

		dxDrawText(
			downText,
			x - respc(10),
			y + h - fontHeight - respc(10),
			(x + w) - respc(10),
			y + w,
			downTextColor,
			1,
			downTextFont,
			downTextAlign
		)
	end

	if centerText then
		centerTextColor = centerTextColor or tocolor(255, 255, 255, 255 * fadeAmount)
		centerTextAlign = centerTextAlign or "left"
		centerTextFont = centerTextFont or fonts.Roboto11
		local fontHeight = dxGetFontHeight(1, centerTextFont)

		local textX = x + respc(10)
		if imagePath then
			if imageAlign == "left" then
				textX = textX + imageW + respc(5)
			end
		end
		dxDrawText(centerText, textX, y, x + w, y + h, centerTextColor, 1, centerTextFont, centerTextAlign, "center")
	end

	buttons[key] = { x, y, w, h }
end

local activeDirectX = false
local lastActiveDirectX = false

function dxDrawInteractionButton(
	key,
	label,
	x,
	y,
	w,
	h,
	buttonColor,
	activeColor,
	textColor,
	font,
	textAlign1,
	textAlign2,
	imagePath,
	imageW,
	imageH,
	imageColor
)
	lastActiveDirectX = activeDirectX
	activeDirectX = activeButton

	local imageColorEx = imageColor

	local alphaDifference = 175 - buttonColor[4]
	local fadeAmount = 1

	dxDrawRectangle(x, y, w, h, tocolor(buttonColor[1], buttonColor[2], buttonColor[3], buttonColor[4] * fadeAmount))

	textAlign1 = textAlign1 or "left"
	textAlign2 = textAlign2 or "center"

	dxDrawText(
		label,
		x + respc(5),
		y,
		x + w,
		y + h,
		tocolor(textColor[1], textColor[2], textColor[3], 255 * fadeAmount),
		1,
		font,
		"center",
		textAlign2
	)

	buttons[key] = { x, y, w, h }

	if activeDirectX ~= lastActiveDirectX and activeDirectX then
		playSound("audio/hover.ogg")
	end
end

function dxDrawMetroTilePanel(
	key,
	label,
	x,
	y,
	w,
	h,
	activeColor,
	imagePath,
	imageW,
	imageH,
	imageColor,
	imageAlign,
	titleText,
	titleTextColor,
	titleTextFont,
	titleTextAlign,
	downText,
	downTextColor,
	downTextFont,
	downTextAlign,
	centerText,
	centerTextColor,
	centerTextFont,
	centerTextAlign
)
	local buttonColor
	buttonColor = { processColorSwitchEffect(key, { activeColor[1], activeColor[2], activeColor[3], activeColor[4] }) }

	local alphaDifference = 175 - buttonColor[4]
	local fadeAmount = tabPanelAlphas[activePage]

	dxDrawRectangle(
		x,
		y,
		w,
		h,
		tocolor(buttonColor[1], buttonColor[2], buttonColor[3], (175 - alphaDifference) * fadeAmount)
	)

	if imagePath then
		imageW = imageW or respc(100)
		imageH = imageH or respc(100)
		if imageColor then
			imageColor = tocolor(imageColor[1], imageColor[2], imageColor[3], imageColor[4] * fadeAmount)
				or tocolor(255, 255, 255, 255 * fadeAmount)
		else
			imageColor = tocolor(255, 255, 255, 255 * fadeAmount)
		end
		imageAlign = imageAlign or "center"

		if imageAlign == "center" then
			local imgX, imgY = x + (w - imageW) * 0.5, y + (h - imageH) * 0.5
			dxDrawImage(imgX, imgY, imageW, imageH, imagePath, 0, 0, 0, imageColor)
		elseif imageAlign == "left" then
			local imgX, imgY = x + respc(10), y + (h - imageH) * 0.5
			dxDrawImage(imgX, imgY, imageW, imageH, imagePath, 0, 0, 0, imageColor)
		elseif imageAlign == "right" then
			local imgX, imgY = x + w - imageW - respc(10), y + (h - imageH) * 0.5
			dxDrawImage(imgX, imgY, imageW, imageH, imagePath, 0, 0, 0, imageColor)
		end
	end
end

function dxDrawInnerBorder(thickness, x, y, w, h, color)
	thickness = thickness or 2

	dxDrawLine(x, y, x + w, y, color, thickness)
	dxDrawLine(x, y + h, x + w, y + h, color, thickness)
	dxDrawLine(x, y, x, y + h, color, thickness)
	dxDrawLine(x + w, y, x + w, y + h, color, thickness)
end

local colorSwitch = {}

colorSwitch.storedColors = {}
colorSwitch.lastColors = {}
colorSwitch.startInterpolation = {}
colorSwitch.lastColorConcat = {}

function processColorSwitchEffect(key, color, duration, type)
	if not colorSwitch.storedColors[key] then
		if not color[4] then
			color[4] = 255
		end

		colorSwitch.storedColors[key] = color
		colorSwitch.lastColors[key] = color

		colorSwitch.lastColorConcat[key] = table.concat(color)
	end

	duration = duration or 500
	type = type or "Linear"

	if colorSwitch.lastColorConcat[key] ~= table.concat(color) then
		colorSwitch.lastColorConcat[key] = table.concat(color)
		colorSwitch.lastColors[key] = color
		colorSwitch.startInterpolation[key] = getTickCount()
	end

	if colorSwitch.startInterpolation[key] then
		local progress = (getTickCount() - colorSwitch.startInterpolation[key]) / duration

		local r, g, b = interpolateBetween(
			colorSwitch.storedColors[key][1],
			colorSwitch.storedColors[key][2],
			colorSwitch.storedColors[key][3],
			color[1],
			color[2],
			color[3],
			progress,
			type
		)

		local a = interpolateBetween(colorSwitch.storedColors[key][4], 0, 0, color[4], 0, 0, progress, type)

		colorSwitch.storedColors[key][1] = r
		colorSwitch.storedColors[key][2] = g
		colorSwitch.storedColors[key][3] = b
		colorSwitch.storedColors[key][4] = a

		if progress >= 1 then
			colorSwitch.startInterpolation[key] = false
		end
	end

	return colorSwitch.storedColors[key][1],
		colorSwitch.storedColors[key][2],
		colorSwitch.storedColors[key][3],
		colorSwitch.storedColors[key][4]
end

function activeButtonChecker()
	local cx, cy = getCursorPosition()

	if tonumber(cx) and tonumber(cy) then
		cx, cy = cx * screenX, cy * screenY
		cursorX, cursorY = cx, cy

		activeButton = false

		for k, v in pairs(buttons) do
			if cx >= v[1] and cy >= v[2] and cx <= v[1] + v[3] and cy <= v[2] + v[4] then
				activeButton = k
				break
			end
		end
	else
		activeButton = false
		cursorX, cursorY = -10, -10
	end
end

function table.empty(self)
	for _, _ in pairs(self) do
		return false
	end
	return true
end

function reMap(value, low1, high1, low2, high2)
	return (value - low1) * (high2 - low2) / (high1 - low1) + low2
end

scrollData = {}
scrollData.draggingGrips = {}
scrollData.gripPoses = {}
local lastScrollByArrowBtn = 0

function drawScrollbar(key, x, y, w, h, visibleItems, currentItems)
	local fadeAmount = 1

	local trackY = y + w
	local trackHeight = h - (w * 2)

	local gripHeight = (trackHeight / currentItems) * visibleItems
	local gripColor

	if gripHeight > h then
		gripHeight = h - 12
	end

	if not scrollData[key .. "Offset"] then
		scrollData[key .. "Offset"] = 0
	end

	if scrollData.draggingGrips[key] then
		gripColor = { 174, 174, 174, 255 }

		scrollData.gripPoses[key] = cursorY - scrollData.draggingGrips[key]

		if scrollData.gripPoses[key] < trackY then
			scrollData.gripPoses[key] = trackY
		elseif scrollData.gripPoses[key] > trackY + trackHeight - gripHeight then
			scrollData.gripPoses[key] = trackY + trackHeight - gripHeight
		end

		scrollData[key .. "Offset"] = math.floor(
			reMap(scrollData.gripPoses[key], trackY, trackY + trackHeight - gripHeight, 0, 1)
				* (currentItems - visibleItems)
		)
	elseif activeButton == "scrollbarGrip:" .. key then
		if getKeyState("mouse1") then
			gripColor = { 174, 174, 174, 255 }
		else
			gripColor = { 134, 134, 134, 255 }
		end
	else
		gripColor = { 93, 93, 93, 255 }
	end

	local gripY = trackY
		+ (trackHeight / currentItems) * math.min(scrollData[key .. "Offset"], currentItems - visibleItems)

	if gripY < trackY then
		gripY = trackY
	elseif gripY > trackY + trackHeight - gripHeight then
		gripY = trackY + trackHeight - gripHeight
	end

	scrollData.gripPoses[key] = gripY

	dxDrawRectangle(x, trackY, w, trackHeight, tocolor(53, 53, 53, 255 * fadeAmount))
	dxDrawRectangle(
		x,
		gripY,
		w,
		gripHeight,
		tocolor(gripColor[1], gripColor[2], gripColor[3], gripColor[4] * fadeAmount)
	)
	buttons["scrollbarGrip:" .. key] = { x, gripY, w, gripHeight }

	local colorOfUp = tocolor(50, 50, 48, 255 * fadeAmount)
	local colorOfArrow = tocolor(210, 210, 210, 255 * fadeAmount)

	if activeButton == "scrollUp:" .. key then
		if getKeyState("mouse1") then
			colorOfUp = tocolor(173, 173, 173, 255 * fadeAmount)
			colorOfArrow = tocolor(83, 83, 83, 255 * fadeAmount)

			if lastScrollByArrowBtn == 0 then
				scrollData[key .. "Offset"] = scrollData[key .. "Offset"] - 1
				lastScrollByArrowBtn = getTickCount()
			end

			if getTickCount() - lastScrollByArrowBtn >= 125 then
				scrollData[key .. "Offset"] = scrollData[key .. "Offset"] - 1
				lastScrollByArrowBtn = getTickCount()
			end

			if scrollData[key .. "Offset"] < 0 then
				scrollData[key .. "Offset"] = 0
			end
		else
			lastScrollByArrowBtn = 0
			colorOfUp = tocolor(73, 73, 72)
		end
	end

	dxDrawRectangle(x, trackY - w, w, w, colorOfUp)
	buttons["scrollUp:" .. key] = { x, trackY - w, w, w }

	local colorOfDown = tocolor(50, 50, 48, 255 * fadeAmount)
	local colorOfArrow = tocolor(210, 210, 210, 255 * fadeAmount)

	if activeButton == "scrollDown:" .. key then
		if getKeyState("mouse1") then
			colorOfDown = tocolor(173, 173, 173, 255 * fadeAmount)
			colorOfArrow = tocolor(83, 83, 83, 255 * fadeAmount)

			if lastScrollByArrowBtn == 0 then
				scrollData[key .. "Offset"] = scrollData[key .. "Offset"] + 1
				lastScrollByArrowBtn = getTickCount()
			end

			if getTickCount() - lastScrollByArrowBtn >= 125 then
				scrollData[key .. "Offset"] = scrollData[key .. "Offset"] + 1
				lastScrollByArrowBtn = getTickCount()
			end

			if scrollData[key .. "Offset"] > currentItems - visibleItems then
				scrollData[key .. "Offset"] = currentItems - visibleItems
			end
		else
			lastScrollByArrowBtn = 0
			colorOfDown = tocolor(73, 73, 72)
		end
	end

	dxDrawRectangle(x, trackY + trackHeight, w, w, colorOfDown)
	buttons["scrollDown:" .. key] = { x, trackY + trackHeight, w, w }
end

local buttonSlider = {}
buttonSlider.offsets = {}
buttonSlider.interpolationStart = {}
buttonSlider.states = {}

function drawButtonSlider(key, state, x, y, h, offColor, onColor)
	local fadeAmount = tabPanelAlphas[activePage]

	if not buttonSlider.offsets[key] then
		buttonSlider.offsets[key] = 0
		buttonSlider.states[key] = state
	end

	local buttonColor
	if state then
		buttonColor = { processColorSwitchEffect(key, { onColor[1], onColor[2], onColor[3], 0 }) }
	else
		buttonColor = { processColorSwitchEffect(key, { offColor[1], offColor[2], offColor[3], 255 }) }
	end

	if buttonSlider.states[key] ~= state then
		buttonSlider.states[key] = state
		buttonSlider.interpolationStart[key] = { getTickCount(), state }
	end

	if buttonSlider.interpolationStart[key] then
		local progress = (getTickCount() - buttonSlider.interpolationStart[key][1]) / 500

		if buttonSlider.interpolationStart[key][2] then
			buttonSlider.offsets[key] =
				interpolateBetween(buttonSlider.offsets[key], 0, 0, 32, 0, 0, progress, "Linear")
		else
			buttonSlider.offsets[key] = interpolateBetween(buttonSlider.offsets[key], 0, 0, 0, 0, 0, progress, "Linear")
		end

		if progress >= 1 then
			buttonSlider.interpolationStart[key] = false
		end
	end

	local alphaDifference = 255 - buttonColor[4]

	buttons[key] = { x, y, 64, 32 }

	y = y + (h - 32) / 2
end

addEventHandler("onClientClick", root, function(button, state)
	if button == "left" and state == "down" then
		if activeButton then
			local selected = split(activeButton, ":")

			if selected[1] == "scrollbarGrip" then
				local key = selected[2]

				scrollData.draggingGrips[key] = cursorY - scrollData.gripPoses[key]
			end
		end
	elseif button == "left" and state == "up" then
		scrollData.draggingGrips = {}
	end
end)
