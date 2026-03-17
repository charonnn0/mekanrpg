local fonts = useFonts()

local r, g, b = unpack(getServerColor(3))

local isShowing

local lastClick = getTickCount()

local bailInfo = [[ %s Saatlik IC hapsiniz bulunmaktadır. 
	₺%s Kefalet ücreti ödeyerek çıkabilirsiniz. 

	Lütfen aşağıdan nasıl ödemek istediğinizi seçiniz.
]]

local function renderBailUI()
	local width, height = 380, 190
	local x, y = screenSize.x / 2 - width / 2, screenSize.y / 2 - height / 2

	local days, hours, remainingTime = cleanMath(localPlayer:getData("pd_jail_time"))
	if not days then
		return toggleBailUI(false)
	end

	nowTick = getTickCount()

	dxDrawRectangle(x, y, width, height, tocolor(15, 15, 15, 230), false, false, true)
	dxDrawText(
		"Kefalet Ödeme Arayüzü",
		x,
		y + 15,
		width + x,
		0,
		tocolor(245, 245, 245),
		1,
		fonts.UbuntuBold.h5,
		"center",
		"top"
	)

	local closeSize = 25
	local closeX, closeY = x + width - (closeSize + 15), y + 15
	local hover = inArea(closeX, closeY, closeSize, closeSize)

	local color = hover
			and animate(
				"close",
				{ from = { 15, 15, 15 }, to = { 232, 65, 24 }, state = "fadeIn" },
				150,
				"Linear",
				nowTick
			)
		or animate("close", { from = { 232, 65, 24 }, to = { 15, 15, 15 }, state = "fadeOut" }, 150, "Linear", nowTick)

	dxDrawRectangle(closeX, closeY, closeSize, closeSize, tocolor(color[1], color[2], color[3], 190))
	dxDrawText(
		"",
		closeX,
		closeY,
		closeSize + closeX,
		closeSize + closeY,
		tocolor(245, 245, 245),
		0.5,
		fonts.icon,
		"center",
		"center"
	)

	if hover and getKeyState("mouse1") and lastClick + 200 <= getTickCount() then
		lastClick = getTickCount()
		toggleBailUI(false)
	end

	local width, height = width - 40, height - 40
	local x, y = x + 20, y + 20

	if days ~= PRISONER_STATUS.LifeTime then
		hours = hours + (days * 24)
	end

	local bailPrice = (days == PRISONER_STATUS.LifeTime) and 3000000 or (7000 * hours)

	dxDrawText(
		bailInfo:format(hours, exports.mek_global:formatMoney(bailPrice)),
		x,
		y + 30,
		width + x,
		0,
		tocolor(255, 255, 255),
		1,
		fonts.UbuntuRegular.body,
		"center",
		"top"
	)

	local y = y + 115
	local w, h = width / 2 - 5, 35
	local hover = inArea(x, y, w, h)

	local color = hover
			and animate(
				"paywithcash",
				{ from = { 15, 15, 15 }, to = { r, g, b }, state = "fadeIn" },
				150,
				"Linear",
				nowTick
			)
		or animate(
			"paywithcash",
			{ from = { r, g, b }, to = { 15, 15, 15 }, state = "fadeOut" },
			150,
			"Linear",
			nowTick
		)

	dxDrawRectangle(x, y, w, h, tocolor(color[1], color[2], color[3], 200))
	dxDrawText(
		"Üzerimden Öde",
		x,
		y,
		w + x,
		h + y,
		tocolor(235, 235, 235, 210),
		1,
		fonts.UbuntuRegular.h6,
		"center",
		"center"
	)

	if hover and getKeyState("mouse1") and lastClick + 200 <= getTickCount() then
		lastClick = getTickCount()
		triggerServerEvent("prison.payBail", localPlayer, "cash")
	end

	local x = x + w + 10
	local w, h = width / 2 - 5, 35
	local hover = inArea(x, y, w, h)

	local color = hover
			and animate(
				"paywithbank",
				{ from = { 15, 15, 15 }, to = { r, g, b }, state = "fadeIn" },
				150,
				"Linear",
				nowTick
			)
		or animate(
			"paywithbank",
			{ from = { r, g, b }, to = { 15, 15, 15 }, state = "fadeOut" },
			150,
			"Linear",
			nowTick
		)

	dxDrawRectangle(x, y, w, h, tocolor(color[1], color[2], color[3], 200))
	dxDrawText(
		"Bankadan Öde",
		x,
		y,
		w + x,
		h + y,
		tocolor(235, 235, 235, 210),
		1,
		fonts.UbuntuRegular.h6,
		"center",
		"center"
	)

	if hover and getKeyState("mouse1") and lastClick + 200 <= getTickCount() then
		lastClick = getTickCount()
		triggerServerEvent("prison.payBail", localPlayer, "bank")
	end
end

function toggleBailUI(state)
	isShowing = state
	if isShowing then
		addEventHandler("onClientRender", root, renderBailUI)
	else
		removeEventHandler("onClientRender", root, renderBailUI)
	end
end

addCommandHandler("kefalet", function()
	local days, hours, remainingTime = cleanMath(localPlayer:getData("pd_jail_time"))
	if not remainingTime then
		outputChatBox("[!]#FFFFFF Hapiste değilsiniz.", 255, 0, 0, true)
		return
	end

	toggleBailUI(not isShowing)
end, false, false)
