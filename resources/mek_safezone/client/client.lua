local fireControls = {
	"fire",
	"vehicle_fire",
	"vehicle_secondary_fire",
}

local legalFactions = { [1] = true, [3] = true }

local lastState = {
    safe = false,
    legal = false
}

function isLegalFaction(player)
    local faction = getElementData(player, "faction")
    if type(faction) == "table" then
        if faction[1] or faction[3] then
            return true
        end
        for k, v in pairs(faction) do
            if tonumber(k) == 1 or tonumber(k) == 3 then
                return true
            end
        end
    elseif type(faction) == "number" or type(faction) == "string" then
        return legalFactions[tonumber(faction)]
    end
    return false
end

addEventHandler("onClientResourceStart", resourceRoot, function()
	setTimer(checkSafezoneState, 500, 0)
    for _, control in pairs(fireControls) do
        toggleControl(control, true)
    end
end)

addEventHandler("onClientPlayerWeaponFire", localPlayer, function()
    if getElementData(localPlayer, "safezone") then
        if not isLegalFaction(localPlayer) then
            cancelEvent()
            return
        end

        local target = getPedTarget(localPlayer)
        if target and isElement(target) and getElementType(target) == "player" then
            if not getElementData(target, "safezone") then
                cancelEvent()
            end
        end
    end
end)

addEventHandler("onClientPlayerWeaponSwitch", localPlayer, function()
    if getElementData(localPlayer, "safezone") then
        if not isLegalFaction(localPlayer) then
            setPedWeaponSlot(localPlayer, 0)
        end
    end
end)

addEventHandler("onClientPlayerDamage", localPlayer, function(attacker)
    local victimInSafe = getElementData(source, "safezone")
    
    if attacker and isElement(attacker) and getElementType(attacker) == "player" then
        local attackerInSafe = getElementData(attacker, "safezone")
        
        if attackerInSafe and not victimInSafe then
            cancelEvent()
            return
        end

        if victimInSafe then
            if isLegalFaction(attacker) then
                return
            end
            cancelEvent()
            return
        end
    elseif victimInSafe then
        cancelEvent()
    end
end)

function checkSafezoneState()
    local isSafe = getElementData(localPlayer, "safezone") or false
    local isLegal = isLegalFaction(localPlayer)

    local stateChanged = (isSafe ~= lastState.safe) or (isLegal ~= lastState.legal)
    
    if stateChanged then
        lastState.safe = isSafe
        lastState.legal = isLegal

        if isSafe then
            if isLegal then
                for _, control in pairs(fireControls) do
                    toggleControl(control, true)
                end
            else
                for _, control in pairs(fireControls) do
                    toggleControl(control, false)
                end
            end
        else
            for _, control in pairs(fireControls) do
                toggleControl(control, true)
            end
        end
    end

    if isSafe and not isLegal then
        if getPedWeaponSlot(localPlayer) ~= 0 then
            setPedWeaponSlot(localPlayer, 0)
        end
    end
end
