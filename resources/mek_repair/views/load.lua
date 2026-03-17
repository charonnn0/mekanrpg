local governmentFactions = {
    [1] = true,
    [2] = true
}

local screenX, screenY = guiGetScreenSize()

local isMechanicerRendering = false
local renderData = {}

local lastClick = getTickCount()

local coords = {
    { 2065.353515625, -1831.9853515625, 12.546875 },
    { 1911.376953125, -1776.3046875, 12.3828125 },
    { 487.5341796875, -1740.9228515625, 10.13595867157 },
    { 1017.6591796875, -917.9052734375, 41.1796875 },
    { 2007.6826171875, -2469.513671875, 12.546875 }, -- LS Airport
}

local hitElement
local garageColshape

local function hitMarker(hitEntity, matchingDimension)
    if hitEntity ~= localPlayer then
        return false
    end
    local vehicle = localPlayer:getOccupiedVehicle()
    if vehicle then
        local seat = localPlayer:getOccupiedVehicleSeat()
        if seat == 0 then
            if source == garageColshape then
                if not (tonumber(localPlayer:getData("tamirci") or 0) == 2) then
                    return false
                end
            end
            hitElement = source
            showMechanicUI(vehicle)
        end
    end
end

local function leaveMarker(hitEntity, matchingDimension)
    if hitEntity ~= localPlayer then
        return false
    end
    local vehicle = localPlayer:getOccupiedVehicle()
    if vehicle then
        local seat = localPlayer:getOccupiedVehicleSeat()
        if seat == 0 then
            hideMechanicUI()
        end
    end
    hitElement = nil
end

local function fixCarEntity()
    local playerVIP = tonumber(localPlayer:getData("vip")) or 0
    local vehicleFaction = tonumber(localPlayer.vehicle:getData("faction")) or 0
    local isCarGov = governmentFactions[vehicleFaction]
    local hasRepairFree = (isCarGov or playerVIP >= 4)

    local totalPrice = math.floor((1000 - renderData.vehicle.health) * 2, 0)

    if playerVIP == 3 then
        totalPrice = math.floor(totalPrice / 2)
    end

    local isMechanicCol = isElementWithinColShape(localPlayer, garageColshape) or false
    if isMechanicCol and (tonumber(localPlayer:getData("tamirci") or 0) == 2) then
        totalPrice = 50
    end

    if isTimer(renderData.timer) then
        return
    end

    if hasMoney(localPlayer, totalPrice) or hasRepairFree then
        renderData.disableControls = true
        renderData.afterText = " markalı aracınız tamir ediliyor."

        local count = math.random(4, 7)
        localPlayer.vehicle:setFrozen(true)
        renderData.timer = setTimer(function()
            if not localPlayer.vehicle then
                hideMechanicUI()
                return false
            end
            count = count - 1
            renderData.afterText = " markalı aracınız tamir ediliyor, " .. count .. " saniye sonra kullanabileceksiniz."
            localPlayer.vehicle:setFrozen(true)
            if count <= 0 then
                if localPlayer.vehicle then
                    triggerServerEvent("repair.buy", resourceRoot, localPlayer, localPlayer.vehicle)
                end
                localPlayer.vehicle:setFrozen(false)
                hideMechanicUI()
            end
        end, 1000, count)
    else
        exports.mek_infobox:addBox("warning", "Yeterli paranız yok.")
    end
    return true
end

local function renderMechanicUI()
    local fontRegular = exports.mek_huds:getFont("Roboto", 10)
    local fontBold = exports.mek_huds:getFont("RobotoB", 11)
    local fontBoldBig = exports.mek_huds:getFont("RobotoB", 14)
    local vehicleWidth = dxGetTextWidth(renderData.vehicleName, 1, fontBold) + 20
    local width, height = dxGetTextWidth(renderData.vehicleName .. renderData.afterText:gsub("#%x%x%x%x%x%x", ""), 1, fontRegular) + 75, 40
    local x, y = screenX / 2 - width / 2, screenY - (height + 70)

    if not localPlayer.vehicle then
        return
    end

    local seat = localPlayer:getOccupiedVehicleSeat()
    if seat ~= 0 then
        return
    end

    if hitElement.type == "marker" then
        if not isElementWithinMarker(localPlayer, hitElement) then
            return hideMechanicUI()
        end
    elseif hitElement.type == "colshape" then
        if not isElementWithinColShape(localPlayer, hitElement) then
            return hideMechanicUI()
        end
    end

    local playerVIP = tonumber(localPlayer:getData("vip")) or 0
    local vehicleFaction = tonumber(localPlayer.vehicle:getData("faction")) or 0
    local isCarGov = governmentFactions[vehicleFaction]
    local hasRepairFree = (isCarGov or playerVIP >= 4)

    nowTick = getTickCount()

    dxDrawRoundedRectangle(x, y, width, height, tocolor(15, 15, 15, 225), 10, false, false, true)
    dxDrawText(renderData.vehicleName, x + 20, y, width + x, height + y, tocolor(235, 235, 235), 1, fontBold, "left", "center")
    dxDrawText(renderData.afterText, x + vehicleWidth, y, width + x, height + y, tocolor(235, 235, 235), 1, fontRegular, "left", "center", false, false, false, true)

    if renderData.disableControls then
        if not localPlayer.vehicle.frozen then
            localPlayer.vehicle:setFrozen(true)
        end
    end
    if renderData.showDetails and (renderData.hasMoney or hasRepairFree) and not renderData.disableControls then
        local w, h = 400, 150
        local x, y = screenX / 2 - w / 2, screenY / 2 - h / 2

        dxDrawRoundedRectangle(x, y, w, h, tocolor(15, 15, 15, 220), 10, false, false, true)

        dxDrawText("Aracı Tamir Ettir", x, y + 15, w + x, 0, tocolor(245, 245, 245), 1, fontBoldBig, "center", "top")
        dxDrawText(renderData.title, x, y + 50, w + x, 0, tocolor(245, 245, 245), 1, fontRegular, "center", "top")

        local w, h = w - 40, 35
        local x, y = x + 20, y + 100
        local hover = inArea(x, y, w, h)

        local color = (hover or getKeyState("enter")) and animate("select", { from = { 25, 25, 25 }, to = { r, g, b }, state = "fadeIn" }, 150) or
                animate("select", { from = { r, g, b }, to = { 25, 25, 25 }, state = "fadeOut" }, 150)

        dxDrawRoundedRectangle(x, y, w, h, tocolor(color[1], color[2], color[3], 200), 10)
        dxDrawText("Tamir Et (ENTER)", x, y, w + x, h + y, tocolor(235, 235, 235, 210), 1, fontRegular, "center", "center")

        if hover then
            if getKeyState("mouse1") and lastClick + 200 <= getTickCount() then
                lastClick = getTickCount()
                fixCarEntity()
            end
        end
    end
end

function showMechanicUI(vehicleEntity)
    if not isMechanicerRendering then
        local totalPrice = math.floor((1000 - vehicleEntity.health) * 2, 0)
        local currentDuty = getCurrentFactionDuty(localPlayer)
        local isCarLaw = false

        local playerVIP = tonumber(localPlayer:getData("vip")) or 0
        local vehicleFaction = tonumber(vehicleEntity:getData("faction")) or 0
        local vehicleJob = tonumber(vehicleEntity:getData("job")) or 0
        local isCarGov = governmentFactions[vehicleFaction]
        local hasRepairFree = (isCarGov or playerVIP >= 4 or vehicleJob == 2)

        if currentDuty and (tonumber(vehicleEntity:getData("faction")) == tonumber(currentDuty)) or hasRepairFree then
            isCarLaw = true
        end

        if playerVIP == 3 then
            totalPrice = math.floor(totalPrice / 2)
        end

        local isMechanicCol = isElementWithinColShape(localPlayer, garageColshape) or false
        if isMechanicCol and (tonumber(localPlayer:getData("tamirci") or 0) == 2) then
            totalPrice = 50
        end

        isMechanicerRendering = true
        r, g, b = 255, 0, 0
        hexColor = "#FF0000"
        moneyCurrency = "TL"

        renderData.showDetails = false
        renderData.vehicle = vehicleEntity

        renderData.disableControls = false

        renderData.vehicleName = getVehName(vehicleEntity)
        renderData.afterText = totalPrice > 0 and (" markalı aracınızı tamir ettirmek için %s'E'%s tuşuna basın."):format(hexColor, "#ffffff") or " markalı aracınızın hasarı yok."

        renderData.price = math.floor(totalPrice)
        renderData.title = renderData.price <= 0 and "Aracınızda hasar yok." or (isCarLaw and "Aracınızın masrafları devlet tarafından karşılanacak." or "Aracınızda toplam " .. renderData.price .. moneyCurrency .. " masraf var.\nTamir ettirmek ister misiniz?")
        renderData.hasMoney = hasMoney(localPlayer, renderData.price)

        if isCarLaw == true then
            renderData.afterText = (" markalı aracınızı tamir ettirmek için %s'E'%s tuşuna basın."):format(hexColor, "#ffffff")
        elseif not renderData.hasMoney and totalPrice > 0 then
            renderData.afterText = " markalı aracı tamir ettirmek için yeterli paranız yok."
        end

        addEventHandler("onClientRender", root, renderMechanicUI)
        addEventHandler("onClientKey", root, keyHandlers)
    end
end

function keyHandlers(button, press)
    if press then
        if button == "e" and renderData.price > 0 then
            cancelEvent()
            renderData.showDetails = true
        elseif renderData.showDetails and button == "enter" and renderData.price > 0 then
            cancelEvent()
            fixCarEntity()
        elseif renderData.showDetails and button == "backspace" then
            renderData.showDetails = false
        end
    end
end

function hideMechanicUI()
    if isMechanicerRendering then
        isMechanicerRendering = false
        if isTimer(renderData.timer) then
            killTimer(renderData.timer)
        end
        renderData = {}
        removeEventHandler("onClientRender", root, renderMechanicUI)
        removeEventHandler("onClientKey", root, keyHandlers)
        removeEventHandler("accounts.switchCharacter", localPlayer, hideMechanicUI)
    end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    local txd = engineLoadTXD("models/Wrench1.txd")
    engineImportTXD(txd, 2709)
    local dff = engineLoadDFF("models/Wrench1.dff")
    engineReplaceModel(dff, 2709)

    for index, value in ipairs(coords) do
        local x, y, z = value[1], value[2], value[3]

        local marker = createMarker(x, y, z - 2, "cylinder", 4, 255, 153, 0, 110)
        marker:setAlpha(0)
        addEventHandler("onClientMarkerHit", marker, hitMarker)
        addEventHandler("onClientMarkerLeave", marker, leaveMarker)

        local pickup = createPickup(x, y, z + 1, 3, 2709)
        pickup:setData("text", "Bu alanda aracınızı tamir edebilirsiniz.")
    end

    garageColshape = createColSphere(537.537109375, 87.4453125, 1043.4675292969, 5)
    addEventHandler("onClientColShapeHit", garageColshape, hitMarker)
    addEventHandler("onClientColShapeLeave", garageColshape, leaveMarker)
end)

addEventHandler("onClientVehicleEnter", root,
        function(entity, seat)
            if not (entity == localPlayer and seat == 0) then
                return
            end

            local isMechanicCol = isElementWithinColShape(entity, garageColshape) or false
            if not isMechanicCol then
                return false
            end
            if not (tonumber(entity:getData("tamirci") or 0) == 2) then
                return false
            end

            hitElement = garageColshape

            showMechanicUI(entity.vehicle)
        end
)

function getCurrentFactionDuty(element)
    local playerFaction = getElementData(element, "faction") or {}
    local duty = getElementData(element, "duty") or 0
    local foundPackage = false
    if duty > 0 then
        for k, v in pairs(playerFaction) do
            for key, element in ipairs(v.perks) do
                if tonumber(element) == tonumber(duty) then
                    foundPackage = k
                    break
                end
            end
        end
    end
    return foundPackage
end


function dxDrawRoundedRectangle(x, y, w, h, color, radius, postGUI, subPixelPositioning, withBlur)
    radius = radius or 5
    color = color or tocolor(0, 0, 0, 200)

    dxDrawRectangle(x, y, w, h, color)
end

local gvn = getVehicleName
function getVehName(theVehicle)
    if not theVehicle or (getElementType(theVehicle) ~= "vehicle") then
        return "?"
    end
    local name = gvn(theVehicle)
    local year = getElementData(theVehicle, "year")
    local brand = getElementData(theVehicle, "brand")
    local model = getElementData(theVehicle, "model")
    if year and brand and model then
        name = tostring(year) .. " " .. tostring(brand) .. " " .. tostring(model)
    end
    return name
end


local screenX, screenY = guiGetScreenSize()

function inArea(x, y, w, h)
    if isCursorShowing() then
        local aX, aY = getCursorPosition()
        aX, aY = aX * screenX, aY * screenY
        if aX > x and aX < x + w and aY > y and aY < y + h then
            return true
        else
            return false
        end
    else
        return false
    end
end

animateData = {}

function animate(key, data, duration, animateType)
    if not sourceResource then
        sourceResource = "this"
    end
    local nowTick = getTickCount()
    local duration = duration or 500
    local animateType = animateType or "Linear"

    if not animateData[sourceResource] then
        animateData[sourceResource] = {}
    end

    if not animateData[sourceResource][key] then
        animateData[sourceResource][key] = {
            tick = getTickCount(),
            from = data.from,
            to = data.to,
            lastAction = data.state
        }
    elseif animateData[sourceResource][key].lastAction then
        if data.state ~= animateData[sourceResource][key].lastAction then
            animateData[sourceResource][key].tick = getTickCount()
            animateData[sourceResource][key].from = data.from
            animateData[sourceResource][key].to = data.to
            animateData[sourceResource][key].lastAction = data.state
        end
    end

    animateData[sourceResource][key].lastAction = data.state
    local startTick = animateData[sourceResource][key].tick

    local elapsedTime = nowTick - startTick
    local duration = (startTick + duration) - startTick
    local progress = elapsedTime / duration

    local a, b, c = interpolateBetween(
            animateData[sourceResource][key]["from"][1], animateData[sourceResource][key]["from"][2], animateData[sourceResource][key]["from"][3],
            animateData[sourceResource][key]["to"][1], animateData[sourceResource][key]["to"][2], animateData[sourceResource][key]["to"][3],
            progress, animateType
    )

    return { a, b, c }
end

function resetAnimateData()
    if not sourceResource then
        sourceResource = "this"
    end
    animateData[sourceResource] = {}
end

function resetAnimateKey(key)
    if not key then
        return
    end
    if not sourceResource then
        sourceResource = "this"
    end
    if not animateData[sourceResource] then
        animateData[sourceResource] = {}
    end
    animateData[sourceResource][key] = nil
end

local colorsState = {}

function rgbaUnpack(hex, _alpha)
    if not tostring(hex) then
        return hex
    end

    local alpha = _alpha or 1

    local r = tonumber(hex:sub(2, 3), 16)
    local g = tonumber(hex:sub(4, 5), 16)
    local b = tonumber(hex:sub(6, 7), 16)
    local a = tonumber(hex:sub(8, 9), 16) or (alpha * 255)

    return r, g, b, a
end

function rgba(hex, _alpha)
    if not tostring(hex) then
        return hex
    end

    local alpha = _alpha or 1
    local colorKey = tostring(hex) .. tostring(alpha)
    if colorsState[colorKey] then
        return colorsState[colorKey]
    end

    local r, g, b, a = rgbaUnpack(hex, alpha)

    colorsState[colorKey] = tocolor(r, g, b, a)
    return colorsState[colorKey]
end

function hasMoney(thePlayer, amount)
    amount = tonumber(amount) or 0
    if thePlayer and isElement(thePlayer) and amount > 0 then
        amount = math.floor(amount)

        return getMoney(thePlayer) >= amount
    end
    return false
end

function getMoney(thePlayer)
    return getElementData(thePlayer, "money") or 0
end
