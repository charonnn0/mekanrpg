local reklamlar = {
    [1] = "public/ads1.jpg",
    [2] = "public/ads2.jpg"
}

local panelAcik = false
local ekranGenislik, ekranYukseklik = guiGetScreenSize()
local panelGenislik, panelYukseklik = 350, 360

local panelX = (ekranGenislik - panelGenislik) / 2  
local panelY = ekranYukseklik - panelYukseklik - 20

local font = exports["mek_huds"]:getFont("sf-bold", 10)
local font1 = exports["mek_huds"]:getFont("sf-bold", 11)
local font2 = exports["mek_huds"]:getFont("FontAwesome", 10)

local xButtonX = panelX + panelGenislik - 25
local xButtonY = panelY + 12
local isMouseOverX = false  

--local reklamResmiYolu = "public/ads1.jpg"  
local reklamTexture = nil
local openTime = 0
local closeDuration = 8000
local alpha = 0

function cizDXPanel()
    if panelAcik then
        if not reklamTexture then
            reklamTexture = dxCreateTexture(reklamResmiYolu, "argb", true, "clamp")
        end

        local now = getTickCount()
        local elapsed = now - openTime
        
        alpha = 255
        
        dxDrawRectangle(panelX, panelY, panelGenislik, panelYukseklik, tocolor(25, 25, 30, 180))
        
        dxDrawText("Reklam", panelX + 10, panelY + 10, panelX + panelGenislik, panelY + 30, tocolor(255, 255, 255, 255), 1, font1, "left", "top")
        local buttonColor = isMouseOverX and tocolor(255, 0, 0, 255) or tocolor(255, 255, 255, 255)
        dxDrawText("", xButtonX, xButtonY, xButtonX + 15, xButtonY + 15, buttonColor, 1, font2, "center", "center")
        
        dxDrawRectangle(panelX, panelY + 35, panelGenislik, 1, tocolor(50, 50, 50, 255))
        
        local frameX, frameY, frameW, frameH = panelX + 15, panelY + 50, panelGenislik - 30, panelYukseklik - 85
        --dxDrawRectangle(frameX - 2, frameY - 2, frameW + 4, frameH + 4, tocolor(0, 0, 0, 255))
        dxDrawRectangle(frameX, frameY, frameW, frameH, tocolor(40, 40, 45, 255))
        
        if reklamTexture then
            dxDrawImage(frameX + 3, frameY + 3, frameW - 6, frameH - 6, reklamTexture, 0, 0, 0, tocolor(255, 255, 255, 255))
        end

        local progress = math.min(elapsed / closeDuration, 1)
        local barWidth = (panelGenislik - 30) * (1 - progress)
        if barWidth > 0 then
            dxDrawRectangle(panelX + 15, panelY + panelYukseklik - 15, panelGenislik - 30, 2, tocolor(40, 40, 40, 255))
            dxDrawRectangle(panelX + 15, panelY + panelYukseklik - 15, barWidth, 2, tocolor(200, 200, 200, 255))
        end

        if elapsed >= closeDuration then
            panelAcik = false
        end
    end
end
addEventHandler("onClientRender", root, cizDXPanel)

function panelAc(reklamID)
    if panelAcik then return end

    panelAcik = true
    openTime = getTickCount()

    if isElement(reklamTexture) then
        destroyElement(reklamTexture)
    end

    local yol = reklamlar[reklamID] or reklamlar[1]
    reklamTexture = dxCreateTexture(yol, "argb", true, "clamp")
end
addEvent("reklamPanelAc", true)
addEventHandler("reklamPanelAc", root, panelAc)

function xButtonClicked(button, state)
    if not panelAcik then return end
    if state == "down" then
        local mx, my = getCursorPosition()
        if mx and my then
            mx, my = mx * ekranGenislik, my * ekranYukseklik
            if mx >= xButtonX and mx <= xButtonX + 15 and my >= xButtonY and my <= xButtonY + 15 then
                panelAcik = false
            end
        end
    end
end
addEventHandler("onClientClick", root, xButtonClicked)

function mouseMoveHandler()
    if not panelAcik then return end
    local mx, my = getCursorPosition()
    if mx and my then
        mx, my = mx * ekranGenislik, my * ekranYukseklik
        isMouseOverX = mx >= xButtonX and mx <= xButtonX + 15 and my >= xButtonY and my <= xButtonY + 15
    else
        isMouseOverX = false
    end
end
addEventHandler("onClientMouseMove", root, mouseMoveHandler)
