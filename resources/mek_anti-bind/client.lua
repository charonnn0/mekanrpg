local blockedCommands = {
    ban = true,
    oban = true,
    cban = true,
    ocban = true,
    kick = true,
    jail = true,
    sjail = true,
    osjail = true,
    reconnect = true,
    freconnect = true,
    lay = true,
    crack = true,
    fixcar = true,
    lay = true,
    yereyat = true,
    quit = true,
    pm = true,
    ooc = true,
    b = true,
    fixveh = true,
    makeveh = true,
    addii = true,
    makecivveh = true,
    aheal = true,
    sethp = true,
    tedaviet = true,
    vehicle_next_weapon = true,
    vehicle_previous_weapon = true,
    aracgetir = true,
}

local blockedKeys = {
    delete = true,
    insert = true,
    home   = true,
    ["end"] = true,
}

local playerBinds = {}

function updateKeyList()
    playerBinds = {}
    for command in pairs(blockedCommands) do
        local keys = getBoundKeys(command)
        if keys then
            for keyName in pairs(keys) do
                playerBinds[keyName] = command
            end
        end
    end
    setTimer(updateKeyList, 1000, 1)
end
addEventHandler("onClientResourceStart", resourceRoot, updateKeyList)

addEventHandler("onClientKey", root, function(button, press)
    if not isChatBoxInputActive() and not isMTAWindowActive() and not isConsoleActive() then
        if blockedKeys[button] then
            if press then
                outputChatBox("#FF0000[!]#FFFFFF ["..button.."] tuşunu kullanamazsınız.", 255, 0, 0, true)
                playSoundFrontEnd(4)
                cancelEvent()
            end
            return
        end

        if playerBinds[button] and press then
            outputChatBox("#FF0000[!]#FFFFFF ["..button.."] tuşuna eklenmiş yasaklı bind ["..playerBinds[button].."]. Lütfen kaldırınız!", 255, 0, 0, true)
            playSoundFrontEnd(4)
            cancelEvent()
            return
        end
    end
end)
