function setWalkingStyle(thePlayer, commandName, walkingStyle)
	if not walkingStyle or not tonumber(walkingStyle) then
		outputChatBox("Kullanım: /" .. commandName .. " [Yürüyüş Stili ID]", thePlayer, 255, 194, 14)
		outputChatBox(
			"[!]#FFFFFF /walklist yazarak yürüyüş stillerinin ID'lerini görüntüleyebilirsiniz.",
			thePlayer,
			0,
			0,
			255,
			true
		)
	else
		walkingStyle = tonumber(walkingStyle)
		if walkingStyle ~= 125 then
			if setPedWalkingStyle(thePlayer, walkingStyle) then
				setElementData(thePlayer, "walking_style", walkingStyle)
				dbExec(
					exports.mek_mysql:getConnection(),
					"UPDATE characters SET walking_style = ? WHERE id = ?",
					walkingStyle,
					getElementData(thePlayer, "dbid")
				)
				outputChatBox(
					"[!]#FFFFFF Başarıyla yürüyüş tarzınız [" .. walkingStyle .. "] olarak değiştirildi.",
					thePlayer,
					0,
					255,
					0,
					true
				)
			else
				outputChatBox("[!]#FFFFFF Bir sorun oluştu.", thePlayer, 255, 0, 0, true)
			end
		else
			outputChatBox("[!]#FFFFFF Bu animasyon sunucuda yasaklanmıştır.", thePlayer, 255, 0, 0, true)
		end
	end
end
addCommandHandler("setwalkingstyle", setWalkingStyle, false)
addCommandHandler("setwalk", setWalkingStyle, false)

function walkStyleList(thePlayer, commandName)
	outputChatBox("[!]#FFFFFF Yürüyüş stillerinin ID'leri:", thePlayer, 0, 0, 255, true)
	outputChatBox(">>#FFFFFF 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 118,", thePlayer, 0, 0, 255, true)
	outputChatBox(">>#FFFFFF 119, 120, 121, 122, 123, 124, 126, 128,", thePlayer, 0, 0, 255, true)
	outputChatBox(">>#FFFFFF 129, 130, 131, 132, 133, 134, 135, 136, 137, 138.", thePlayer, 0, 0, 255, true)
end
addCommandHandler("walklist", walkStyleList, false, false)
