addCommandHandler("numaram", function(thePlayer)
	local phoneNumber
	for _, item in ipairs(exports.mek_item:getItems(thePlayer)) do
		if item[1] == 2 then
			phoneNumber = item[2]
			break
		end
	end

	if phoneNumber then
		outputChatBox("[!]#FFFFFF Telefon Numaranız: " .. phoneNumber, thePlayer, 0, 0, 255, true)
	else
		outputChatBox("[!]#FFFFFF Üzerinizde telefon yok.", thePlayer, 255, 0, 0, true)
	end
end, false, false)
