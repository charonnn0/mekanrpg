local reklamTimer = nil

function reklamBaslat()
    local reklamID = math.random(1, 2)
    triggerClientEvent(root, "reklamPanelAc", root, reklamID)
end

reklamTimer = setTimer(reklamBaslat, 5400000, 0)

addCommandHandler("reklamgonder", function(thePlayer)
    if exports.mek_integration:isPlayerServerOwner(thePlayer) then
        reklamBaslat()
    end
end)