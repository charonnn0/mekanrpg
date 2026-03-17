local LIST_SIZES = {
	x = 300,
	y = 240,
}

local function cleanupCharacterPage()
    if isEventHandlerAdded("onClientRender", root, renderCharacters) then
        removeEventHandler("onClientRender", root, renderCharacters)
    end
    
    local store = useStore("characters")
    local ped = store.get("ped")
    if isElement(ped) then
        ped:destroy()
    end
    
    if isElement(characterLight) then
        characterLight:destroy()
    end
    
    store.set("ped", nil)
    store.set("currentCharacter", 1)
end

local function switchToCharactersPage()
    if isEventHandlerAdded("onClientRender", root, renderSplashHome) then
        removeEventHandler("onClientRender", root, renderSplashHome)
    end
    
    if isEventHandlerAdded("onClientRender", root, renderHome) then
        removeEventHandler("onClientRender", root, renderHome)
    end
    
    showCursor(false)
    
    local characters = getElementData(localPlayer, "characters") or {}
    
    cleanupCharacterPage()

    setTimer(function()
        if #characters > 0 then
            setTimer(function() triggerServerEvent("karakterdegistir", localPlayer, localPlayer) triggerEvent("account.charactersPage", localPlayer, characters, true) setElementData(localPlayer, "logged", false, false) end, 300, 1)
        else
			outputChatBox("[!]#FFFFFF Lütfen bu hata karşınıza çıktıysa discord adresimizden bize ulaşıp bildiriniz bir hata sonucu oluşmuştur.", 255, 0 ,0, true)
        end
    end, 100, 1)
end

function renderHome()
    dxDrawImage(
        screenSize.x / 2 - 128 / 2,
        screenSize.y / 2 - 128 / 2 - 160,
        128,
        128,
        ":mek_ui/public/images/logo.png"
    )

    local list = drawList({
        position = {
            x = screenSize.x / 2 - LIST_SIZES.x / 2,
            y = screenSize.y / 2 - LIST_SIZES.y / 2 + 40,
        },
        size = LIST_SIZES,

        header = "Ana Sayfa",
        items = {
            {
                text = "Mağaza",
                icon = utf8.char(0xF07A),
                key = "MARKET",
            },
            {
                text = "Hesabım",
                icon = utf8.char(0xF007),
                key = "MY_ACCOUNT",
            },
            {
                text = "Ayarlar",
                icon = utf8.char(0xF013),
                key = "SETTINGS",
            },
            {
                text = "Karakter Değiştir",
                icon = utf8.char(0xF0C0),
                key = "CHANGE_CHARACTER",
            },
            {
                text = "Kapat",
                icon = utf8.char(0xF2F5),
                key = "CLOSE",
            },
        },

        name = "account_home",
        padding = 20,
        color = "gray",
        variant = "soft",
        rowHeight = 30,
        disabled = settingsVisible,
    })
    
    if list and list.pressed then
        if list.pressed == "MARKET" then
            executeCommandHandler("market")
        elseif list.pressed == "MY_ACCOUNT" then
            addEventHandler("onClientRender", root, renderMyAccount)
        elseif list.pressed == "SETTINGS" then
            exports.mek_settings:showSettings()
        elseif list.pressed == "CHANGE_CHARACTER" then
            switchToCharactersPage()
            return
        elseif list.pressed == "CLOSE" then
            showCursor(false)
            removeEventHandler("onClientRender", root, renderHome)
            removeEventHandler("onClientRender", root, renderSplashHome)
            return
        end

        showCursor(false)
        removeEventHandler("onClientRender", root, renderSplashHome)
        removeEventHandler("onClientRender", root, renderHome)
    end
end

bindKey("F10", "down", function()
    if not localPlayer:getData("logged") then
        return
    end

    if isEventHandlerAdded("onClientRender", root, renderSplashHome) then
        removeEventHandler("onClientRender", root, renderSplashHome)
        removeEventHandler("onClientRender", root, renderHome)
        showCursor(false)
        
        cleanupCharacterPage()
    else
        addEventHandler("onClientRender", root, renderSplashHome)
        addEventHandler("onClientRender", root, renderHome)
        showCursor(true)
    end
end)

addEvent("account.returnToHome", true)
addEventHandler("account.returnToHome", root, function()
    cleanupCharacterPage()
    
    addEventHandler("onClientRender", root, renderSplashHome)
    addEventHandler("onClientRender", root, renderHome)
    showCursor(true)
end)