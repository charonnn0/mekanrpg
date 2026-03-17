local governmentFactions = {
    [1] = true,
    [2] = true
}

local function getCurrentFactionDuty(element)
    local playerFaction = getElementData(element, "faction") or {}
    local duty = getElementData(element, "duty") or 0
    local foundPackage = false
    if duty > 0 then
        for k, v in pairs(playerFaction) do
            if type(v) == "table" and v.perks then
                for key, perk in ipairs(v.perks) do
                    if tonumber(perk) == tonumber(duty) then
                        foundPackage = k
                        break
                    end
                end
            end
        end
    end
    return foundPackage
end

addEvent('repair.buy', true)
addEventHandler('repair.buy', resourceRoot, function(player, vehicle)
    if not isElement(player) or getElementType(player) ~= "player" then
        return false
    end
    
    if not isElement(vehicle) or getElementType(vehicle) ~= "vehicle" then
        return false
    end
    
    local occupiedVehicle = getPedOccupiedVehicle(player)
    if not occupiedVehicle or occupiedVehicle ~= vehicle then
        return false
    end
    
    local seat = getPedOccupiedVehicleSeat(player)
    if seat ~= 0 then
        return false
    end
    
    local vehicleHealth = getElementHealth(vehicle)
    local totalPrice = math.floor((1000 - vehicleHealth) * 2)
    
    if totalPrice <= 0 then
        outputChatBox(">> #FFFFFFAracınızda hasar yok.", player, 255, 165, 0, true)
        return false
    end
    
    local playerVIP = tonumber(getElementData(player, "vip")) or 0
    local vehicleFaction = tonumber(getElementData(vehicle, "faction")) or 0
    local vehicleJob = tonumber(getElementData(vehicle, "job")) or 0
    local isTamirci = tonumber(getElementData(player, "tamirci")) or 0
    
    local isCarGov = governmentFactions[vehicleFaction] == true
    local isCarJob = (vehicleJob == 2)
    
    local currentDuty = getCurrentFactionDuty(player)
    local isCarLaw = false
    if currentDuty and vehicleFaction > 0 and tonumber(currentDuty) == vehicleFaction then
        isCarLaw = true
    end
    
    local hasRepairFree = (isCarGov or isCarLaw or playerVIP >= 4 or isCarJob)
    
    if playerVIP == 3 then
        totalPrice = math.floor(totalPrice / 2)
    end
    
    if isTamirci == 2 then
        totalPrice = 50
    end
    
    fixVehicle(vehicle)
    setElementData(vehicle, "enginebroke", 0, false)
    
    if hasRepairFree then
        outputChatBox(">> #FFFFFFAracınızı başarıyla tamir ettiniz.", player, 0, 255, 0, true)
        outputChatBox(">> #FFFFFFAracınızın masrafları devlet tarafından karşılanmıştır.", player, 0, 0, 255, true)
    else
        local playerMoney = exports.mek_global:getMoney(player) or 0
        if playerMoney < totalPrice then
            outputChatBox(">> #FFFFFFYeterli paranız yok.", player, 255, 0, 0, true)
            return false
        end
        
        exports.mek_global:takeMoney(player, totalPrice)
        outputChatBox(">> #FFFFFFAracınızı başarıyla tamir ettiniz.", player, 0, 255, 0, true)
        outputChatBox(">> #FFFFFFTamir fiyatı: "..formatMoney(totalPrice).."TL", player, 0, 0, 255, true)
    end
end)

function formatMoney(amount)
        local left, num, right = string.match(tostring(amount), '^([^%d]*%d)(%d*)(.-)$')
        return left .. (num:reverse():gsub('(%d%d%d)', '%1,'):reverse()) .. right
end
    