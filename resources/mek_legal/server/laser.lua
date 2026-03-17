addCommandHandler("lazer", function(thePlayer)
	local laser = getElementData(thePlayer, "laser")
	if not laser then
		setElementData(thePlayer, "laser", true)
		outputChatBox("[!]#FFFFFF Silah lazeriniz başarıyla açıldı.", thePlayer, 0, 255, 0, true)
	else
		setElementData(thePlayer, "laser", false)
		outputChatBox("[!]#FFFFFF Silah lazeriniz başarıyla kapandı.", thePlayer, 255, 0, 0, true)
	end
end, false, false)
