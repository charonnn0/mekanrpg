screenSize = Vector2(guiGetScreenSize())

fonts = useFonts()
theme = useTheme()

local screenW, screenH = guiGetScreenSize()
local aksanWindow = nil
local aksanCombo = nil

local aksanlar = {
    ["laz"] = "Laz Aksanı",
    ["trakya"] = "Trakya Aksanı",
    ["karadeniz"] = "Karadeniz Aksanı",
    ["dogu"] = "Doğu Aksanı",
    ["guneydogu"] = "Güneydoğu Aksanı",
    ["ege"] = "Ege Aksanı",
    ["kurt"] = "Kürt Aksanı",
    ["none"] = "Aksanı Kapat"
}

-- GUI oluşturma fonksiyonu (ComboBox versiyonu)
function createAksanGUI()
    if isElement(aksanWindow) then
        destroyElement(aksanWindow)
        aksanWindow = nil
        showCursor(false)
        return
    end
    
    aksanWindow = guiCreateWindow((screenW - 350) / 2, (screenH - 280) / 2, 350, 280, "Aksan Seçimi", false)
    guiWindowSetSizable(aksanWindow, false)
    guiSetAlpha(aksanWindow, 0.95)
    
    local label = guiCreateLabel(20, 30, 310, 20, "Bir aksan seçin:", false, aksanWindow)
    guiLabelSetHorizontalAlign(label, "center")
    
    aksanCombo = guiCreateComboBox(20, 55, 310, 130, "Aksan Seçiniz", false, aksanWindow)
    
    for id, isim in pairs(aksanlar) do
        guiComboBoxAddItem(aksanCombo, isim)
    end
    
    local devamButton = guiCreateButton(20, 190, 310, 40, "Aksan Seçmek İçin Devam Edin", false, aksanWindow)
    local aksanButton = guiCreateButton(20, 235, 310, 40, "Seç ve Uygula", false, aksanWindow)
    
    addEventHandler("onClientGUIClick", devamButton, function()
        guiSetEnabled(aksanButton, true)
        guiSetEnabled(devamButton, false)
    end, false)
    
    addEventHandler("onClientGUIClick", aksanButton, function()
        local selected = guiComboBoxGetSelected(aksanCombo)
        if selected ~= -1 then
            local aksanText = guiComboBoxGetItemText(aksanCombo, selected)
            local aksanTuru = nil
            
            for id, isim in pairs(aksanlar) do
                if isim == aksanText then
                    aksanTuru = id
                    break
                end
            end
            
            if aksanTuru then
                triggerServerEvent("aksan->degistir", localPlayer, aksanTuru)
                destroyElement(aksanWindow)
                aksanWindow = nil
                showCursor(false)
                
                if aksanTuru == "none" then
                    outputChatBox("Aksanınız kapatıldı!", 0, 255, 0)
                else
                    outputChatBox("Aksanınız ".. aksanText .." olarak ayarlandı!", 0, 255, 0)
                end
            end
        else
            outputChatBox("Lütfen bir aksan seçin!", 255, 0, 0)
        end
    end, false)
    
    guiSetEnabled(aksanButton, false)
    showCursor(true)
end

-- Gridlist ile alternatif GUI
function createAksanGridlistGUI()
    if isElement(aksanWindow) then
        destroyElement(aksanWindow)
        aksanWindow = nil
        showCursor(false)
        return
    end
    
    aksanWindow = guiCreateWindow((screenW - 350) / 2, (screenH - 330) / 2, 350, 330, "Aksan Seçimi", false)
    guiWindowSetSizable(aksanWindow, false)
    guiSetAlpha(aksanWindow, 0.95)
    
    local label = guiCreateLabel(20, 30, 310, 20, "Bir aksan seçin:", false, aksanWindow)
    guiLabelSetHorizontalAlign(label, "center")
    
    local aksanGridlist = guiCreateGridList(20, 55, 310, 180, false, aksanWindow)
    guiGridListAddColumn(aksanGridlist, "Mevcut Aksanlar", 0.9)
    
    for id, isim in pairs(aksanlar) do
        local row = guiGridListAddRow(aksanGridlist)
        guiGridListSetItemText(aksanGridlist, row, 1, isim, false, false)
        guiGridListSetItemData(aksanGridlist, row, 1, id)
    end
    
    local devamButton = guiCreateButton(20, 245, 310, 40, "Aksan Seçmek İçin Devam Edin", false, aksanWindow)
    local aksanButton = guiCreateButton(20, 290, 310, 40, "Seç ve Uygula", false, aksanWindow)
    
    addEventHandler("onClientGUIClick", devamButton, function()
        guiSetEnabled(aksanButton, true)
        guiSetEnabled(devamButton, false)
    end, false)
    
    addEventHandler("onClientGUIClick", aksanButton, function()
        local selectedRow = guiGridListGetSelectedItem(aksanGridlist)
        if selectedRow ~= -1 then
            local aksanTuru = guiGridListGetItemData(aksanGridlist, selectedRow, 1)
            local aksanText = guiGridListGetItemText(aksanGridlist, selectedRow, 1)
            
            if aksanTuru then
                triggerServerEvent("aksan->degistir", localPlayer, aksanTuru)
                destroyElement(aksanWindow)
                aksanWindow = nil
                showCursor(false)
                
                if aksanTuru == "none" then
                    outputChatBox("Aksanınız kapatıldı!", 0, 255, 0)
                else
                    outputChatBox("Aksanınız ".. aksanText .." olarak ayarlandı!", 0, 255, 0)
                end
            end
        else
            outputChatBox("[!]#FFFFFF Lütfen bir aksan seçin.", 255, 0, 0, true)
        end
    end, false)
    
    guiSetEnabled(aksanButton, false)
    showCursor(true)
end

-- Aksan menüsünü açma komutları
addCommandHandler("aksansec", function()
    createAksanGridlistGUI()
end)

addCommandHandler("aksan", function()
    createAksanGridlistGUI()
end)