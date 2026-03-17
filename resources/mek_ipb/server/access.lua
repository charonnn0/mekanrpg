addEvent("ipb.accessControl", true)

function hasIPBAccess(player)
    return exports.mek_integration:isPlayerGeneralAdmin(player)
end

function onIPBCommand(player)
    if not hasIPBAccess(player) then return end
    if isListening(player) then return end
    triggerClientEvent(player, "ipb.accessControl", player, true)
end
addCommandHandler("perfbrowse", onIPBCommand)
addCommandHandler("ipb", onIPBCommand)

addEventHandler("onPlayerLogout", root, function()
    if isListening(source) then
        removeListener(source)
        triggerClientEvent(source, "ipb.accessControl", source, false)
    end
end)
