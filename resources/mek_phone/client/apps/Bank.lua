Bank = {}
Bank.padding = 16
Bank.state = {
    loading = false,
    tab = 1,
    amount = "",
    transferTo = "",
    history = {},
}

local function drawHeader(onClick)
    Phone.components.Header(function(headerPosition, headerSize)
        dxDrawText(
            "Banka",
            headerPosition.x + Bank.padding,
            headerPosition.y + 10,
            0,
            0,
            rgba(theme.GREEN[400]),
            1,
            fonts.BebasNeueBold.h1
        )
    end, onClick)
end

local function drawTabs(position, size, startY)
    local tabs = {
        { name = "Havale" },
        { name = "Geçmiş" },
    }

	local tabWidth = (size.x - Bank.padding * 2) / #tabs
    for i, t in ipairs(tabs) do
		local tx = position.x + Bank.padding + (i - 1) * tabWidth
		local ty = startY
		local hover = inArea(tx, ty, tabWidth - 8, 34)
        drawRoundedRectangle({
            position = { x = tx, y = ty },
			size = { x = tabWidth - 8, y = 34 },
            color = i == Bank.state.tab and theme.GREEN[500] or theme.GRAY[700],
			alpha = i == Bank.state.tab and 1 or 0.8,
			radius = 10,
        })
        dxDrawText(
            t.name,
            tx,
            ty,
			tx + tabWidth - 8,
			ty + 34,
            rgba(theme.GRAY[50]),
            1,
			fonts.BebasNeueBold.caption,
            "center",
            "center"
        )
        if hover and isKeyPressed("mouse1") then
            Bank.state.tab = i
        end
    end
end

local function drawTransfer(position, size, contentStartY)
	local startY = contentStartY

    local toInput = drawInput({
        position = {
            x = position.x + Bank.padding,
			y = startY,
        },
        size = {
            x = size.x - Bank.padding * 2,
            y = 35,
        },
        name = "bank.transfer.to",
        label = "Kime (Karakter Adı)",
        placeholder = "Ad_Soyad",
        value = Bank.state.transferTo,
        variant = "outlined",
        color = "gray",
        disabled = Bank.state.loading,
    })
    Bank.state.transferTo = toInput.value or ""

    local amountInput = drawInput({
        position = {
            x = position.x + Bank.padding,
			y = startY + Bank.padding * 3,
        },
        size = {
            x = size.x - Bank.padding * 2,
            y = 35,
        },
        name = "bank.transfer.amount",
        label = "Tutar",
        placeholder = "0",
        value = Bank.state.amount,
        variant = "outlined",
        color = "gray",
        disabled = Bank.state.loading,
    })
    Bank.state.amount = amountInput.value or ""

    local sendBtn = drawButton({
        position = {
            x = position.x + Bank.padding,
			y = startY + Bank.padding * 6,
        },
        size = {
            x = size.x - Bank.padding * 2,
            y = 35,
        },
        variant = "soft",
        color = "green",
        text = "Gönder",
        disabled = Bank.state.loading,
    })
    if sendBtn.pressed then
        local amount = tonumber(Bank.state.amount)
        local toName = Bank.state.transferTo
        if not toName or toName == "" then
            Phone.showNotification("error", "Alıcı adı gerekli.")
            return
        end
        if not amount or amount <= 0 then
            Phone.showNotification("error", "Geçerli bir tutar girin.")
            return
        end
        Bank.state.loading = true
        triggerServerEvent("bank.transferMoney", localPlayer, { targetEntity = toName, amount = amount })
    end
end

local function drawHistory(position, size, contentStartY)
	local startY = contentStartY + Bank.padding

    local items = {}
    for i, row in ipairs(Bank.state.history or {}) do
        local actionText = row.action == BANK_ACTION.deposit and "Para Yatırma" or (row.action == BANK_ACTION.withdraw and "Para Çekme" or "Transfer")
        local dateText = tonumber(row.dateDiff) == 0 and "Bugün" or (tostring(row.dateDiff) .. " gün önce")
        local text = actionText .. " (₺" .. exports.mek_global:formatMoney(row.amount) .. ") - " .. dateText
        table.insert(items, { icon = "", text = text, key = i })
    end

    drawList({
        position = {
            x = position.x + Bank.padding,
			y = startY,
        },
        size = {
            x = size.x - Bank.padding * 2,
			y = size.y - startY - Bank.padding * 2,
        },
        padding = 14,
        rowHeight = 30,
        name = "bank_history_phone",
        header = "Son İşlemler",
        items = items,
        variant = "soft",
        color = "gray",
    })
end

Phone.addApp(Phone.enums.Apps.Bank, function(position, size)
	drawHeader()

	local tabsY = position.y + Phone.headerPadding + Bank.padding
	local contentStartY = tabsY + 34 + Bank.padding * 1.5

    if not Bank.state.initialized then
        Bank.state.initialized = true
        triggerServerEvent("bank.getHistory", localPlayer)
    end

	drawTabs(position, size, tabsY)

    if Bank.state.tab == 1 then
        drawTransfer(position, size, contentStartY)
    elseif Bank.state.tab == 2 then
        drawHistory(position, size, contentStartY)
    end
end, "public/apps/bank.png", "Banka")

addEvent("bank.sendHistory", true)
addEventHandler("bank.sendHistory", root, function(history)
    Bank.state.history = history or {}
end)

addEvent("bank.removeLoading", true)
addEventHandler("bank.removeLoading", root, function()
    Bank.state.loading = false
    Bank.state.amount = ""
end)


