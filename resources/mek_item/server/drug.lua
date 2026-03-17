function mixDrugs(drug1, drug2, drug1name, drug2name)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	local drugName
	local drugID

	if drug1 == 31 and drug2 == 31 then
		drugID = 34
	elseif (drug1 == 30 and drug2 == 31) or (drug1 == 31 and drug2 == 30) then
		drugID = 35
	elseif (drug1 == 32 and drug2 == 31) or (drug1 == 31 and drug2 == 32) then
		drugID = 36
	elseif (drug1 == 33 and drug2 == 31) or (drug1 == 31 and drug2 == 33) then
		drugID = 37
	elseif drug1 == 30 and drug2 == 30 then
		drugID = 38
	elseif (drug1 == 30 and drug2 == 32) or (drug1 == 32 and drug2 == 30) then
		drugID = 39
	elseif (drug1 == 30 and drug2 == 33) or (drug1 == 33 and drug2 == 30) then
		drugID = 40
	elseif drug1 == 32 and drug2 == 32 then
		drugID = 41
	elseif (drug1 == 32 and drug2 == 33) or (drug1 == 33 and drug2 == 32) then
		drugID = 42
	elseif drug1 == 33 and drug2 == 33 then
		drugID = 43
	end

	drugName = getItemName(drugID)
	if drugName == nil or drugID == nil then
		return
	end

	exports.mek_item:takeItem(source, drug1)
	exports.mek_item:takeItem(source, drug2)

	local given = exports.mek_item:giveItem(source, drugID, 1)
	if given then
		outputChatBox("[!]#FFFFFF '" .. drug1name .. "' ve '" .. drug2name .. "' maddelerini karıştırarak '" .. drugName .. "' maddesini oluşturdun.", source, 0, 255, 0, true)
		exports.mek_global:sendLocalMeAction(source, "birkaç kimyasalı karıştırır.")
	else
		outputChatBox("[!]#FFFFFF Bu kimyasalları karıştırmak için yeterli alanın yok.", source, 255, 0, 0, true)
		exports.mek_item:giveItem(source, drug1, 1)
		exports.mek_item:giveItem(source, drug2, 1)
	end
end
addEvent("mixDrugs", true)
addEventHandler("mixDrugs", root, mixDrugs)
