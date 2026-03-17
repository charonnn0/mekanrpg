addEventHandler("onVehicleStartEnter", root, function(thePlayer, seat, jacked)
	local vehicleOwner = getElementData(source, "owner") or 0
	local vehicleFaction = getElementData(source, "faction") or -1
	local playerDBID = getElementData(thePlayer, "dbid") or 0

	if jacked and seat == 0 and vehicleOwner ~= playerDBID and not exports.mek_faction:isPlayerInFaction(thePlayer, vehicleFaction) then
		cancelEvent(true)
		outputChatBox(
			"[!]#FFFFFF Binmeye çalıştığınız arabanın sürücü koltuğunda birisi var.",
			thePlayer,
			255,
			0,
			0,
			true
		)
	end

	if getElementData(thePlayer, "dead") then
		cancelEvent(true)
		outputChatBox("[!]#FFFFFF Baygın iken araca binemezsiniz.", thePlayer, 255, 0, 0, true)
	end

	if getElementData(thePlayer, "cked") then
		cancelEvent(true)
		outputChatBox("[!]#FFFFFF Ölü iken araca binemezsiniz.", thePlayer, 255, 0, 0, true)
	end
end)

addEventHandler("onVehicleStartExit", root, function(thePlayer)
	if getElementData(thePlayer, "cked") then
		cancelEvent(true)
		outputChatBox("[!]#FFFFFF Ölü iken araçtan inemezsiniz.", thePlayer, 255, 0, 0, true)
	end
end)
