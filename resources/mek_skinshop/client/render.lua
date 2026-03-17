local screenX, screenY = guiGetScreenSize()

local width, height = 950, 595
local x, y = screenX / 2 - width / 2, screenY / 2 - height / 2

local headerFont = dxCreateFont(":mek_ui/public/fonts/UbuntuBold.ttf", 20) or "default"
local font = dxCreateFont(":mek_ui/public/fonts/UbuntuRegular.ttf", 11) or "default"
local fontSmall = dxCreateFont(":mek_ui/public/fonts/UbuntuRegular.ttf", 9) or "default"
local fontIcon = dxCreateFont(":mek_ui/public/fonts/FontAwesome.ttf", 10) or "default"
local fontIconBig = dxCreateFont(":mek_ui/public/fonts/FontAwesome.ttf", 150) or "default"

local isShopRendering = false

local lastClick = getTickCount()

local isPreviewRendered

local tabs = { "GTA Karakterleri", "Özel Karakterler" }

local subTabs = { "Beyaz", "Siyah", "Asyalı" }

local selectedTab = 1
local selectedSubTab = 1

local selectedModel = 1

local cachedModels = {}

local adjust, offset = 17, 1
local scrollbarW, scrollbarH = 12, adjust * 25

local lastHoveredItem = 0

local ped = createPed(217, 161.3740234375, -81.1923828125, 1001.8046875)
setElementRotation(ped, 0, 0, 180)
setElementInterior(ped, 18)
setElementDimension(ped, 3)
setElementFrozen(ped, true)
setElementData(ped, "name", "Arif Sarı")
setElementData(ped, "interaction", {
	callbackEvent = "skinshop.show",
	args = {},
	description = ped:getData("name"):gsub("_", " "),
})

local function cacheCurrentModelsList()
	local gender = tonumber(localPlayer:getData("gender") or 0)
	if selectedTab == 1 then
		local availableSkins = exports.mek_global:getAvailableSkins()
		local row = availableSkins[gender]
		cachedModels = row
	else
		local streamableModels = exports.mek_model:getPedModels()
		local white, black, asian = {}, {}, {}

		for index, value in ipairs(streamableModels) do
			if (value.sale or 1) == 1 and (tonumber(value.gender) == gender or tonumber(value.gender) == 2) then
				if tonumber(value.race) == 1 then
					table.insert(white, { model = index, modelID = value.model })
				elseif tonumber(value.race) == 2 then
					table.insert(black, { model = index, modelID = value.model })
				elseif tonumber(value.race) == 3 then
					table.insert(asian, { model = index, modelID = value.model })
				end
			end
		end

		cachedModels = { white, black, asian }
	end
end

local function renderShop()
	nowTick = getTickCount()

	dxDrawRectangle(x, y, width, height, tocolor(15, 15, 15, 235), false, false, true)
	dxDrawText("Kıyafet Mağazası", x + 25, y + 20, 0, 0, tocolor(245, 245, 245), 1, headerFont, "left", "top")

	local closeSize = 32
	local closeX, closeY = x + width - (closeSize + 20), y + 20
	local hover = inArea(closeX, closeY, closeSize, closeSize)

	local color = hover and animate("close", { from = { 15, 15, 15 }, to = { 232, 65, 24 }, state = "fadeIn" }, 150)
		or animate("close", { from = { 232, 65, 24 }, to = { 15, 15, 15 }, state = "fadeOut" }, 150)

	dxDrawRectangle(closeX, closeY, closeSize, closeSize, tocolor(color[1], color[2], color[3], 190))
	dxDrawText(
		"",
		closeX,
		closeY,
		closeSize + closeX,
		closeSize + closeY,
		tocolor(245, 245, 245),
		1,
		fontIcon,
		"center",
		"center"
	)

	if hover then
		if getKeyState("mouse1") and lastClick + 200 <= getTickCount() then
			lastClick = getTickCount()
			hideShop()
		end
	end

	local width, height = width - 50, height - 135
	local x, y = x + 25, y + 100

	local startsX = 0
	for key, value in ipairs(tabs) do
		local textWidth = dxGetTextWidth(value, 1, fontSmall)
		local tabWidth, tabHeight = textWidth + 20, 25
		local tabX, tabY = x + startsX, y - 30

		local hover = inArea(tabX, tabY, tabWidth, tabHeight)

		local color = (hover or selectedTab == key)
				and animate("tab" .. key, { from = { 15, 15, 15 }, to = { r, g, b }, state = "fadeIn" }, 150)
			or animate("tab" .. key, { from = { r, g, b }, to = { 15, 15, 15 }, state = "fadeOut" }, 150)

		dxDrawRectangle(tabX, tabY, tabWidth, tabHeight, tocolor(color[1], color[2], color[3]))
		dxDrawText(
			value,
			tabX,
			tabY,
			tabWidth + tabX,
			tabHeight + tabY,
			tocolor(245, 245, 245),
			1,
			fontSmall,
			"center",
			"center"
		)

		if hover then
			if getKeyState("mouse1") and lastClick + 200 <= getTickCount() then
				lastClick = getTickCount()
				selectedTab = key
				selectedModel = 1
				offset = 0
				lastHoveredItem = 0
				cacheCurrentModelsList()
			end
		end

		startsX = startsX + (tabWidth + 5)
	end

	local startsX = 0
	for key, value in ipairs(subTabs) do
		local textWidth = dxGetTextWidth(value, 1, fontSmall)
		local tabWidth, tabHeight = textWidth + 30, 25
		local tabX, tabY = x + startsX, y

		local hover = inArea(tabX, tabY, tabWidth, tabHeight)

		local color = (hover or selectedSubTab == key)
				and animate("sub_tab" .. key, { from = { 15, 15, 15 }, to = { r, g, b }, state = "fadeIn" }, 150)
			or animate("sub_tab" .. key, { from = { r, g, b }, to = { 15, 15, 15 }, state = "fadeOut" }, 150)

		dxDrawRectangle(tabX, tabY, tabWidth, tabHeight, tocolor(color[1], color[2], color[3]))
		dxDrawText(
			value,
			tabX,
			tabY,
			tabWidth + tabX,
			tabHeight + tabY,
			tocolor(245, 245, 245),
			1,
			fontSmall,
			"center",
			"center"
		)

		if hover then
			if getKeyState("mouse1") and lastClick + 200 <= getTickCount() then
				lastClick = getTickCount()
				selectedSubTab = key
				selectedModel = 1
				offset = 0
				lastHoveredItem = 0
				cacheCurrentModelsList()
			end
		end

		startsX = startsX + (tabWidth + 5)
	end

	local rows = cachedModels[selectedSubTab]

	local rowW, rowH = width / 2 - 30, 25

	drawScrollbar("interaction", x + rowW - scrollbarW, y + 40, scrollbarW, scrollbarH, adjust, #rows)
	calculatedRowW = rowW - scrollbarW

	for i = 1, adjust do
		local data = rows[i + offset]
		if data then
			local rowX, rowY = x, y + 40 + (rowH * (i - 1))
			local hover = inArea(rowX, rowY, calculatedRowW, rowH)

			if i % 2 == 0 then
				_r, _g, _b = 23, 23, 23
			else
				_r, _g, _b = 33, 33, 33
			end
			local text = selectedTab == 1 and "ID: " .. data or "ID: " .. data.model
			local color = (hover or lastHoveredItem == (i + offset))
					and animate("row_" .. i, { from = { _r, _g, _b }, to = { r, g, b }, state = "fadeIn" }, 50)
				or animate("row_" .. i, { from = { r, g, b }, to = { _r, _g, _b }, state = "fadeOut" }, 150)

			dxDrawInteractionButton(
				"interaction:" .. i,
				text,
				rowX,
				rowY,
				calculatedRowW,
				rowH,
				{ color[1], color[2], color[3], 160 },
				{ 110, 110, 110, 200 },
				{ 255, 255, 255 },
				font,
				"left",
				"center",
				"",
				32,
				32,
				{ 100, 100, 100 }
			)

			if hover then
				if selectedTab == 1 then
					setElementModel(thePed, data)
				else
					local model = exports.mek_model:getEntityModel(data.model)
					setElementModel(thePed, model)
				end
				lastHoveredItem = i + offset
			end
		end
	end

	local width = width / 2
	local x = x + width

	dxDrawRectangle(x, y, width, height, tocolor(25, 25, 25, 235))
	dxDrawText(genderIcon, x, y, width + x, height + y, tocolor(55, 55, 55), 1, fontIconBig, "center", "center")

	local w, h = width - 150, 35
	local x, y = x + 75, y + height - 35
	local hover = inArea(x, y, w, h)
	local price = 100
	local color = hover and animate("buy", { from = { 15, 15, 15 }, to = { r, g, b }, state = "fadeIn" }, 150)
		or animate("buy", { from = { r, g, b }, to = { 15, 15, 15 }, state = "fadeOut" }, 150)

	dxDrawRectangle(x, y, w, h, tocolor(color[1], color[2], color[3], 200))
	dxDrawText(
		"Satın Al (₺" .. price .. ")",
		x,
		y,
		w + x,
		h + y,
		tocolor(235, 235, 235, 210),
		1,
		font,
		"center",
		"center"
	)

	if hover then
		if getKeyState("mouse1") and lastClick + 200 <= getTickCount() then
			lastClick = getTickCount()

			if not exports.mek_global:hasMoney(localPlayer, price) then
				exports.mek_infobox:addBox("error", "Kıyafeti alabilmek için yeterli paranız yok.")
				return
			end

			hideShop()
			triggerServerEvent("skinshop.buy", localPlayer, rows[lastHoveredItem])
		end
	end
end

function hideShop()
	if isShopRendering then
		isShopRendering = false
		exports["mek_object-preview"]:destroyObjectPreview(pedPreview)
		destroyElement(thePed)
		isPreviewRendered = false
		showCursor(false)
		removeEventHandler("onClientRender", root, renderShop)
	end
end

function showShop()
	if not isShopRendering then
		selectedTab = 1
		selectedModel = 1
		cacheCurrentModelsList()

		local width, height = width - 50, height - 135
		local x, y = x + 25, y + 100

		local width = width / 2
		local x, y = x + width, y - 35

		thePed = createPed(1, 0, 0, 0)
		setElementInterior(thePed, localPlayer.interior)
		setElementDimension(thePed, localPlayer.dimension)
		setElementFrozen(thePed, true)
		pedPreview =
			exports["mek_object-preview"]:createObjectPreview(thePed, 0, 0, 180, x, y, width, height, false, true)

		playerGender = tonumber(localPlayer:getData("gender"))
		setPedWalkingStyle(thePed, playerGender == 1 and 131 or 118)

		r, g, b = unpack(getServerColor(3))

		isPreviewRendered = false
		isShopRendering = true
		offset = 0
		showCursor(true)

		genderIcon = playerGender == 0 and "" or ""
		addEventHandler("onClientRender", root, renderShop)
	end
end

addEvent("skinshop.show", true)
addEventHandler("skinshop.show", localPlayer, function()
	showShop()
end)

addEventHandler("onClientKey", root, function(key, press)
	if isShopRendering then
		if press then
			if key == "mouse_wheel_down" and offset < (#cachedModels[selectedSubTab] - adjust) then
				offset = offset + 1
			elseif key == "mouse_wheel_up" and offset > 0 then
				offset = offset - 1
			end
			scrollData["interactionOffset"] = offset
		end
	end
end)
