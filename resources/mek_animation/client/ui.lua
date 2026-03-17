local screenSize = Vector2(guiGetScreenSize())
local sizeX, sizeY = 600, 300
local screenX, screenY = (screenSize.x - sizeX) / 2, (screenSize.y - sizeY) / 2
local clickTick = 0

local selectedAnimation = 0
local selectedName = ""
local affectStance = false

local maxScroll = 10
local currentScroll = 0

local theme = useTheme()
local fonts = useFonts()

local rounded = {}

function roundedDraw(id, x, y, w, h, radius, color, post)
	if not rounded[id] then
		rounded[id] = {}
	end

	if not rounded[id][w] then
		rounded[id][w] = {}
	end

	if not rounded[id][w][h] then
		local path = string.format(
			[[<svg width="%s" height="%s" viewBox="0 0 %s %s" fill="none" xmlns="http://www.w3.org/2000/svg"><rect opacity="1" width="%s" height="%s" rx="%s" fill="#FFFFFF"/></svg>]],
			w,
			h,
			w,
			h,
			w,
			h,
			radius
		)

		rounded[id][w][h] = svgCreate(w, h, path)
	end

	if rounded[id][w][h] then
		dxDrawImage(x, y, w, h, rounded[id][w][h], 0, 0, 0, color, (post or false))
	end
end

local function drawFlatButton(id, text, x, y, w, h, color, hoverColor, disabled)
	local isHover = inArea(x, y, w, h)
	local bg = (disabled and tocolor(60, 60, 60, 180))
		or (isHover and hoverColor)
		or color

	roundedDraw("btn_" .. id, x, y, w, h, 5, bg)
	dxDrawText(
		text,
		x,
		y,
		x + w,
		y + h,
		tocolor(245, 245, 245),
		1,
		fonts.UbuntuBold.h6,
		"center",
		"center"
	)

	if
		not disabled
		and isHover
		and isKeyPressed("mouse1")
		and clickTick + 300 <= getTickCount()
	then
		clickTick = getTickCount()
		return true
	end

	return false
end

local function drawCheckbox(x, y, size, state, label)
	local hover = inArea(x, y, size, size)
	local boxColor = hover and tocolor(60, 60, 60, 220) or tocolor(45, 45, 45, 220)
	roundedDraw("checkbox_" .. size, x, y, size, size, 3, boxColor)

	if state then
		dxDrawRectangle(x + 4, y + 4, size - 8, size - 8, tocolor(0, 180, 120))
	end

	dxDrawText(
		label,
		x + size + 8,
		y,
		x + size + 200,
		y + size,
		rgba(theme.GRAY[100]),
		1,
		fonts.UbuntuRegular.h6,
		"left",
		"center"
	)

	if
		hover
		and isKeyPressed("mouse1")
		and clickTick + 300 <= getTickCount()
	then
		clickTick = getTickCount()
		return not state
	end

	return state
end

function animationPanel()
	if getElementData(localPlayer, "logged") then
		if not isTimer(renderTimer) then
			local animations = getCustomEngineAnimations()
			if customAnimation and animations[customAnimation] then
				selectedAnimation = customAnimation
				selectedName = animations[customAnimation].name
			else
				selectedAnimation = 0
				selectedName = ""
			end

			showCursor(true)
			renderTimer = setTimer(function()
				local padding = 10
				local headerHeight = 30
				local listWidth = 260
				local listHeight = sizeY - headerHeight - (padding * 2) + 8
				local rowHeight = 36
				local rowSpacing = 42
				local scrollbarWidth = 8
				local contentWidth = sizeX - listWidth - (padding * 3)
				local contentX = screenX + listWidth + (padding * 2)
				local contentY = screenY + headerHeight + padding

				roundedDraw("panel_8", screenX, screenY, sizeX, sizeY, 8, tocolor(10, 10, 10, 230))

				dxDrawText(
					"Animasyonlar",
					screenX + padding,
					screenY + padding,
					screenX + padding + listWidth,
					screenY + padding + headerHeight,
					rgba(theme.GRAY[100]),
					1,
					fonts.UbuntuBold.h4,
					"left",
					"center"
				)

				local closeHover = inArea(screenX + sizeX - 32, screenY + padding, 16, headerHeight)
				dxDrawText(
					"",
					screenX + sizeX - 32,
					screenY + padding,
					screenX + sizeX - padding,
					screenY + padding + headerHeight,
					closeHover and rgba(theme.RED[500]) or rgba(theme.GRAY[100]),
					0.8,
					fonts.icon,
					"center",
					"center"
				)

				if closeHover and isKeyPressed("mouse1") and clickTick + 300 <= getTickCount() then
					clickTick = getTickCount()
					killTimer(renderTimer)
					showCursor(false)
					return
				end

				roundedDraw(
					"list_bg_6",
					screenX + padding,
					screenY + headerHeight + padding,
					listWidth,
					listHeight,
					6,
					tocolor(15, 15, 15, 240)
				)

				local totalItems = table.size(getCustomEngineAnimations())
				maxScroll = math.max(0, math.floor(listHeight / rowSpacing))

				local rowY = 0
				local rowIndex = 0
				local index = 0
				local textPadding = 12
				local itemPadding = 10

				for key, value in pairs(getCustomEngineAnimations()) do
					index = index + 1
					if index > currentScroll and rowIndex < maxScroll then
						local itemX = screenX + padding + itemPadding
						local itemY = screenY + headerHeight + padding + 6 + rowY
						local itemWidth = listWidth - (itemPadding * 2) - scrollbarWidth - 6
						local isSelected = (customAnimation == key) or (selectedAnimation == key)
						local hover = inArea(itemX, itemY, itemWidth, rowHeight)
						local itemColor = hover and tocolor(28, 28, 28, 230) or tocolor(22, 22, 22, 230)

						roundedDraw(
							"item_" .. rowHeight,
							itemX,
							itemY,
							itemWidth,
							rowHeight,
							4,
							itemColor
						)

						dxDrawText(
							value.name,
							itemX + textPadding,
							itemY,
							itemX + itemWidth - textPadding,
							itemY + rowHeight,
							isSelected and tocolor(0, 160, 255) or rgba(theme.GRAY[200]),
							1,
							fonts.UbuntuRegular.body,
							"left",
							"center",
							false,
							false,
							false,
							true
						)

						if hover and isKeyPressed("mouse1") and clickTick + 300 <= getTickCount() then
							clickTick = getTickCount()
							selectedAnimation = key
							selectedName = value.name
						end

						rowIndex = rowIndex + 1
						rowY = rowY + rowSpacing
					end
				end

				drawScrollbar(
					screenX + padding + listWidth - scrollbarWidth - 4,
					screenY + headerHeight + padding + 6,
					scrollbarWidth,
					listHeight - 12,
					totalItems,
					maxScroll
				)

				roundedDraw("content_bg_6", contentX, contentY, contentWidth, listHeight, 6, tocolor(18, 18, 18, 230))

				if selectedAnimation ~= 0 then
					dxDrawText(
						selectedName,
						contentX + 12,
						contentY + 6,
						contentX + contentWidth - 12,
						contentY + 40,
						rgba(theme.GRAY[100]),
						1,
						fonts.UbuntuBold.h4,
						"left",
						"top"
					)
					dxDrawText(
						"Kalan süre: Sınırsız",
						contentX + 12,
						contentY + 34,
						contentX + contentWidth - 12,
						contentY + 70,
						rgba(theme.GRAY[400]),
						1,
						fonts.UbuntuRegular.h6,
						"left",
						"top"
					)
				else
					dxDrawText(
						"Animasyon Seçin",
						contentX + 12,
						contentY + 6,
						contentX + contentWidth - 12,
						contentY + 40,
						rgba(theme.GRAY[200]),
						1,
						fonts.UbuntuBold.h4,
						"left",
						"top"
					)
				end

				affectStance = drawCheckbox(contentX + 12, contentY + 76, 18, affectStance, "Duruşu Etkile")

				local hasSelection = selectedAnimation ~= 0
				local isActive = hasSelection and customAnimation == selectedAnimation
				local btnText = isActive and "Bırak" or "Kullan"
				local btnColor = isActive and tocolor(194, 108, 64) or tocolor(17, 145, 110)
				local btnHover = isActive and tocolor(206, 124, 82) or tocolor(24, 164, 127)

				local btnPressed = drawFlatButton(
					"action",
					btnText,
					contentX + contentWidth - 180,
					contentY + listHeight - 44,
					170,
					36,
					btnColor,
					btnHover,
					not hasSelection
				)

				if btnPressed then
					if hasSelection then
						if customAnimation == selectedAnimation then
							resetPlayerCustomAnimation(localPlayer, selectedAnimation)
							customAnimation = nil
							triggerServerEvent("onClientCustomAnimationUpdate", localPlayer, "")
							exports.mek_infobox:addBox(
								"success",
								selectedName .. " isimli animasyon fiziği devre dışı bırakıldı."
							)
						else
							resetPlayerCustomAnimation(localPlayer, selectedAnimation)
							setPlayerCustomAnimation(localPlayer, selectedAnimation)
							customAnimation = selectedAnimation
							triggerServerEvent(
								"onClientCustomAnimationUpdate",
								localPlayer,
								selectedAnimation
							)
							exports.mek_infobox:addBox(
								"success",
								selectedName .. " isimli animasyon fiziği aktif edildi."
							)
						end
					else
						exports.mek_infobox:addBox("error", "Animasyon seçin.")
					end
				end

				adjustScroll(maxScroll)
			end, 0, 0)
		else
			killTimer(renderTimer)
			showCursor(false)
		end
	end
end
addCommandHandler("animpanel", animationPanel, false, false)

function drawScrollbar(x, y, width, height, totalItems, visibleRows)
	local maxVisible = math.max(1, visibleRows)
	local safeTotal = math.max(1, totalItems)
	local maxScrollValue = math.max(0, safeTotal - maxVisible)
	local thumbHeight = maxScrollValue == 0 and height or math.max(20, height * (maxVisible / safeTotal))
	local thumbY = (maxScrollValue == 0) and y or (y + (currentScroll / maxScrollValue) * (height - thumbHeight))

	dxDrawRectangle(x, y, width, height, rgba(theme.GRAY[800], 200))
	dxDrawRectangle(x, thumbY, width, thumbHeight, rgba(theme.GRAY[600], 220))
end

bindKey("mouse_wheel_down", "down", function()
	if isTimer(renderTimer) then
		currentScroll = currentScroll + 1
		adjustScroll(maxScroll)
	end
end)

bindKey("mouse_wheel_up", "down", function()
	if isTimer(renderTimer) then
		currentScroll = currentScroll - 1
		adjustScroll(maxScroll)
	end
end)

function adjustScroll(maxVisible)
	local maxScroll = table.size(getCustomEngineAnimations()) - maxVisible
	if currentScroll < 0 then
		currentScroll = 0
	elseif currentScroll > maxScroll then
		currentScroll = maxScroll
	end
end

function table.size(tab)
	local length = 0
	for _ in pairs(tab) do
		length = length + 1
	end
	return length
end
