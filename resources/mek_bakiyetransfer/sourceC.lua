local screenSize = Vector2(guiGetScreenSize())
local sizeX, sizeY = 750, 535
local screenX, screenY = (screenSize.x - sizeX) / 2, (screenSize.y - sizeY) / 2

-- GUI Elements
local transferWindow = nil
local transferTab = nil
local historyTab = nil
local targetInput = nil
local amountInput = nil
local reasonInput = nil
local sendButton = nil
local closeButton = nil
local historyGrid = nil

-- Variables
local currentTab = "transfer"
local transferHistory = {}

function createTransferGUI()
    if transferWindow then
        destroyElement(transferWindow)
        transferWindow = nil
        showCursor(false)
        return
    end

    transferWindow = guiCreateWindow(screenX, screenY, sizeX, sizeY, "Oyun İçi Bakiye Transfer İstekleri", false)
    guiWindowSetSizable(transferWindow, false)
    guiSetProperty(transferWindow, "AlwaysOnTop", "True")

    local tabPanel = guiCreateTabPanel(20, 40, sizeX - 40, sizeY - 100, false, transferWindow)

    -- Transfer Tab
    transferTab = guiCreateTab("Transfer İsteği", tabPanel)

    local warning1 = guiCreateLabel(20, 20, sizeX - 40, 20, "Aşağıya transfer etmek istediğiniz oyuncunun karakter adını tam şekilde yazınız.", false, transferTab)
    guiLabelSetHorizontalAlign(warning1, "center", false)

    local warning2 = guiCreateLabel(20, 45, sizeX - 40, 20, "Unutmayın, transfer ettiğiniz bakiyenin karşılığını başka bir şekilde alırsanız her iki hesap da kalıcı olarak yasaklanır.", false, transferTab)
    guiLabelSetHorizontalAlign(warning2, "center", false)

    local warning3 = guiCreateLabel(20, 70, sizeX - 40, 20, "TRANSFERLER ÜST YÖNETİM KURULU TARAFINDAN ONAYLANACAKTIR, LÜTFEN BEKLEYİN.", false, transferTab)
    guiLabelSetHorizontalAlign(warning3, "center", false)

    -- Inputlar
    local startX = (sizeX - 430) / 2
    local labelWidth = 180
    local inputWidth = 250

    guiCreateLabel(startX, 120, labelWidth, 20, "Kime? (Karakter Adı):", false, transferTab)
    targetInput = guiCreateEdit(startX + labelWidth + 10, 120, inputWidth, 25, "", false, transferTab)

    guiCreateLabel(startX, 160, labelWidth, 20, "Ne Kadar? (Bakiye Miktarı):", false, transferTab)
    amountInput = guiCreateEdit(startX + labelWidth + 10, 160, inputWidth, 25, "", false, transferTab)

    guiCreateLabel(startX, 200, labelWidth, 20, "Gönderme Nedeni:", false, transferTab)
    reasonInput = guiCreateMemo(startX + labelWidth + 10, 200, inputWidth, 80, "", false, transferTab)

    -- Butonlar
    local buttonWidth = 250
    local buttonStartX = (sizeX - buttonWidth) / 2

    sendButton = guiCreateButton(buttonStartX, 300, buttonWidth, 35, "Transfer İsteği Gönder", false, transferTab)
    closeButton = guiCreateButton(buttonStartX, 345, buttonWidth, 35, "Arayüzü Kapat", false, transferTab)

    -- Geçmiş Tab
    historyTab = guiCreateTab("Onaylanan/Reddedilen İsteklerim", tabPanel)

    guiCreateLabel(20, 20, sizeX - 80, 20, "Aşağıda geçmiş bakiye transfer isteklerini görebilirsiniz:", false, historyTab)

    historyGrid = guiCreateGridList(20, 50, sizeX - 80, 300, false, historyTab)
    guiGridListAddColumn(historyGrid, "Kime", 0.25)
    guiGridListAddColumn(historyGrid, "Ne Kadar?", 0.25)
    guiGridListAddColumn(historyGrid, "Tarih", 0.25)
    guiGridListAddColumn(historyGrid, "Durum", 0.25)

    -- Event handlers
    addEventHandler("onClientGUIClick", sendButton, function()
        local target = guiGetText(targetInput)
        local amount = tonumber(guiGetText(amountInput))
        local reason = guiGetText(reasonInput)

        if target == "" or not amount or amount <= 0 or reason == "" then
            outputChatBox("[!] #FFFFFFLütfen tüm alanları doğru şekilde doldurun.", 255, 0, 0, true)
            return
        end

        triggerServerEvent("onBakiyeTransferRequest", localPlayer, target, amount, reason)
        destroyElement(transferWindow)
        transferWindow = nil
        showCursor(false)
    end, false)

    addEventHandler("onClientGUIClick", closeButton, function()
        destroyElement(transferWindow)
        transferWindow = nil
        showCursor(false)
    end, false)

    addEventHandler("onClientGUITabSwitched", tabPanel, function(selectedTab)
        if selectedTab == historyTab then
            triggerServerEvent("onRequestTransferHistory", localPlayer)
        end
    end)

    showCursor(true)
    guiSetInputMode("no_binds_when_editing")
end

function updateTransferHistory(history)
    transferHistory = history
    guiGridListClear(historyGrid)

    local function humanizeStatus(status)
        if status == "approved" then return "Onaylandı" end
        if status == "rejected" then return "Reddedildi" end
        return "Beklemede"
    end

    for _, transfer in ipairs(history) do
        local row = guiGridListAddRow(historyGrid)
        guiGridListSetItemText(historyGrid, row, 1, tostring(transfer.target or "-"), false, false)
        guiGridListSetItemText(historyGrid, row, 2, tostring(transfer.amount or 0), false, true)
        guiGridListSetItemText(historyGrid, row, 3, tostring(transfer.date or "-"), false, false)
        guiGridListSetItemText(historyGrid, row, 4, humanizeStatus(transfer.status), false, false)
    end
end

addEvent("onTransferHistoryReceived", true)
addEventHandler("onTransferHistoryReceived", root, updateTransferHistory)

addCommandHandler("bakiyetransfer", function()
    if getElementData(localPlayer, "logged") then
        createTransferGUI()
    else
        outputChatBox("[!] #FFFFFFÖnce giriş yapmalısınız.", 255, 0, 0, true)
    end
end)
