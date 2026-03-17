local screenX, screenY = guiGetScreenSize()

local width, height = 350, 185
local x, y = screenX / 2 - width / 2, screenY / 2 - height / 2

local fonts = useFonts()
local theme = useTheme()

local lastClick = getTickCount()

local currentType = "vehicle"
local availableTypes = {
	vehicle = { icon = "", price = 10000, title = "Araç Anahtarı" },
	interior = { icon = "", price = 20000, title = "Mülk Anahtarı" },
}

local ped = createPed(2, 1489.0400390625, 1305.3486328125, 1093.2963867188, 270)
setElementInterior(ped, 3)
setElementDimension(ped, 5)
setElementFrozen(ped, true)
setElementData(ped, "name", "Anahtarcı")
setElementData(ped, "interaction", {
	callbackEvent = "key.show",
	args = {},
	description = ped:getData("name"):gsub("_", " "),
})

local function renderUI()
	local nowTick = getTickCount()

	dxDrawRectangle(x, y, width, height, rgba(theme.GRAY[900]), false, false, true)

	dxDrawText(
		"",
		x + width - 40,
		y + 20,
		nil,
		nil,
		inArea(x + width - 40, y + 20, dxGetTextWidth("", 0.8, fonts.icon), dxGetFontHeight(0.8, fonts.icon))
				and rgba(theme.RED[500])
			or rgba(theme.GRAY[100]),
		0.8,
		fonts.icon
	)

	if
		inArea(x + width - 40, y + 20, dxGetTextWidth("", 0.8, fonts.icon), dxGetFontHeight(0.8, fonts.icon))
		and getKeyState("mouse1")
		and lastClick + 300 <= getTickCount()
	then
		lastClick = getTickCount()
		hideUI()
	end

	local w, h = width - 30, height - 30
	local startX = 0
	local x, y = x + 15, y + 20

	dxDrawText(
		"Çıkarılacak anahtar tipi: ",
		x,
		y,
		0,
		0,
		rgba(theme.GRAY[100]),
		1,
		fonts.UbuntuRegular.body,
		"left",
		"top"
	)

	y = y + 30

	for type, data in pairs(availableTypes) do
		local buttonWidth, buttonHeight = 32, 32
		local xPos, yPos = x + startX, y

		if currentType == type then
			local textWidth = dxGetTextWidth(data.title, 1, fonts.UbuntuRegular.body) + 15
			buttonWidth = buttonWidth + textWidth
		end

		local hover = inArea(xPos, yPos, buttonWidth, buttonHeight)
		local buttonColor = (hover or currentType == type) and theme.BLUE[500] or theme.GRAY[800]

		dxDrawRectangle(xPos, yPos, buttonWidth, buttonHeight, rgba(buttonColor))
		dxDrawText(
			data.icon,
			xPos + 8,
			yPos,
			buttonWidth + xPos,
			buttonHeight + yPos,
			rgba(theme.GRAY[100]),
			0.5,
			fonts.icon,
			"left",
			"center"
		)

		if currentType == type then
			dxDrawText(
				data.title,
				xPos + 33,
				yPos + 1,
				0,
				buttonHeight + yPos,
				rgba(theme.GRAY[100]),
				1,
				fonts.UbuntuRegular.body,
				"left",
				"center"
			)
		end

		if hover and getKeyState("mouse1") and lastClick + 300 <= getTickCount() then
			lastClick = getTickCount()
			currentType = type
		end

		startX = startX + (buttonWidth + 5)
	end

	y = y + 40
	local inputWidth = (width - 30) / 2

	local input = drawInput({
		position = {
			x = x,
			y = y,
		},
		size = {
			x = inputWidth - 20,
			y = 30,
		},

		name = "key_id",

		placeholder = "ID",
		value = "",

		variant = "solid",
		color = "gray",

		disabled = false,
	})

	y = y + 40
	local buttonWidth, buttonHeight = inputWidth * 2, 35

	local submitButton = drawButton({
		position = {
			x = x,
			y = y,
		},
		size = {
			x = buttonWidth,
			y = buttonHeight,
		},

		textProperties = {
			align = "center",
			color = "#FFFFFF",
			font = fonts.body.regular,
			scale = 0.9,
		},

		variant = "soft",
		color = "green",
		disabled = false,

		text = "Çıkar (₺" .. exports.mek_global:formatMoney(availableTypes[currentType].price) .. ")",
	})

	if submitButton.pressed then
		local id = tonumber(input.value)
		local price = tonumber(availableTypes[currentType].price)

		if not exports.mek_global:hasMoney(localPlayer, price) then
			exports.mek_infobox:addBox("error", "Yeterli paranız yok.")
			return
		elseif not id or id == "" or id <= 0 then
			exports.mek_infobox:addBox("error", "Lütfen geçerli ID giriniz.")
			return
		end

		hideUI()
		triggerServerEvent("key.get", localPlayer, currentType, id, price)
	end
end

function showUI()
	if not isEventHandlerAdded("onClientRender", root, renderUI) then
		addEventHandler("onClientRender", root, renderUI)
	end
end

function hideUI()
	if isEventHandlerAdded("onClientRender", root, renderUI) then
		removeEventHandler("onClientRender", root, renderUI)
	end
end

addEvent("key.show", true)
addEventHandler("key.show", localPlayer, function()
	showUI()
end)
