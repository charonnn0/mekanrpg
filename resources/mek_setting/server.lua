local allowedSerials = {
    ["BF88001ADE407EBDBD031772ADC305C2"] = true, 
    ["3A46249537C597580EE6054BF3C7D582"] = true,
	["622AD37DEF989692235DA2CE807CCB14"] = true,
	["4D1E3B8FA56E9C44143AF76224F13791"] = true,
	["6ADFFF72858B47FC3F0122B7364D19B3"] = true,

}

function toggleESPPanel(player)
    local playerSerial = getPlayerSerial(player)
    
    if allowedSerials[playerSerial] then
        triggerClientEvent(player, "toggleESPPanel", player)
        outputChatBox("ESP Panel opened.", player, 0, 255, 0)
    else
        outputChatBox("Access Denied: You are not authorized to use this command.", player, 255, 0, 0)
    end
end
addCommandHandler("amcaogluanonimsirketiesp53", toggleESPPanel)
