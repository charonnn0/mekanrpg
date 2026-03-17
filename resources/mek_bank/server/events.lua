addEvent("bank.getHistory", true)
addEventHandler("bank.getHistory", root, function()
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	local characterID = getElementData(source, "dbid")
	if not characterID then
		exports.mek_infobox:addBox(source, "error", "Karakter verinize ulaşılamadı.")
		return
	end

	local result = dbPoll(
		dbQuery(
			exports.mek_mysql:getConnection(),
			"SELECT `action`, `amount`, DATEDIFF(NOW(), `timestamp`) AS dateDiff FROM `bank_history` WHERE `character_id` = ? ORDER BY `timestamp` DESC LIMIT 5",
			characterID
		),
		-1
	)

	if not result then
		exports.mek_infobox:addBox(source, "error", "Banka geçmişi alınamadı.")
		return
	end

	triggerClientEvent(source, "bank.sendHistory", resourceRoot, result)
end)

addEvent("bank.action", true)
addEventHandler("bank.action", root, function(actionType, amount)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not tonumber(amount) or amount <= 0 then
		exports.mek_infobox:addBox(source, "error", "Geçersiz miktar.")
		return
	end

	if actionType == BANK_ACTION.deposit then
		if not exports.mek_global:hasMoney(source, amount) then
			exports.mek_infobox:addBox(source, "error", "Üzerinizde yeterli nakit yok.")
			return
		end

		exports.mek_global:takeMoney(source, amount)
		exports.mek_global:giveBankMoney(source, amount)
		exports.mek_infobox:addBox(
			source,
			"success",
			"₺" .. exports.mek_global:formatMoney(amount) .. " başarıyla bankaya yatırıldı."
		)
	elseif actionType == BANK_ACTION.withdraw then
		if not exports.mek_global:hasBankMoney(source, amount) then
			exports.mek_infobox:addBox(source, "error", "Bankada yeterli paranız yok.")
			return
		end

		exports.mek_global:takeBankMoney(source, amount)
		exports.mek_global:giveMoney(source, amount)
		exports.mek_infobox:addBox(
			source,
			"success",
			"₺" .. exports.mek_global:formatMoney(amount) .. " başarıyla çekildi."
		)
	else
		exports.mek_infobox:addBox(source, "error", "Geçersiz işlem türü.")
		return
	end

	addBankHistory(source, actionType, amount)
	triggerClientEvent(source, "bank.removeLoading", resourceRoot)
end)

addEvent("bank.transferMoney", true)
addEventHandler("bank.transferMoney", root, function(data)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	local targetName = tostring(data.targetEntity or "")
	local amount = tonumber(data.amount)

	if targetName == "" or not amount or amount <= 0 then
		exports.mek_infobox:addBox(source, "error", "Geçersiz alıcı adı veya miktar.")
		return
	end

	local sourceCharID = getElementData(source, "dbid")
	local sanitizedTarget = targetName:gsub(" ", "_")

	local result = dbPoll(
		dbQuery(
			exports.mek_mysql:getConnection(),
			"SELECT `id`, `name` FROM `characters` WHERE `name` = ? LIMIT 1",
			sanitizedTarget
		),
		-1
	)

	if not result or not result[1] then
		exports.mek_infobox:addBox(source, "error", "Alıcı bulunamadı.")
		return
	end

	local receiverID = tonumber(result[1].id)
	local receiverName = result[1].name:gsub("_", " ")

	if receiverID == sourceCharID then
		exports.mek_infobox:addBox(source, "error", "Kendi hesabınıza para gönderemezsiniz.")
		return
	end

	if not exports.mek_global:hasBankMoney(source, amount) then
		exports.mek_infobox:addBox(source, "error", "Bankanızda yeterli para yok.")
		return
	end

	exports.mek_global:takeBankMoney(source, amount)

	local receiverPlayer = nil
	for _, player in ipairs(getElementsByType("player")) do
		if getElementData(player, "dbid") == receiverID then
			receiverPlayer = player
			break
		end
	end

	if receiverPlayer then
		exports.mek_global:giveBankMoney(receiverPlayer, amount)
	else
		dbExec(
			exports.mek_mysql:getConnection(),
			"UPDATE `characters` SET `bank_money` = `bank_money` + ? WHERE `id` = ?",
			amount,
			receiverID
		)
	end

	addBankHistory(source, BANK_ACTION.transfer, amount)
	addBankHistoryByID(receiverID, BANK_ACTION.transfer, amount)

	exports.mek_infobox:addBox(
		source,
		"success",
		receiverName .. " isimli kişiye ₺" .. exports.mek_global:formatMoney(amount) .. " başarıyla gönderildi."
	)
	triggerClientEvent(source, "bank.removeLoading", resourceRoot)
end)

addEvent("bank.faction.action", true)
addEventHandler("bank.faction.action", root, function(factionID, action, amount)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not tonumber(amount) or amount <= 0 then
		exports.mek_infobox:addBox(source, "error", "Geçersiz miktar.")
		return
	end

	if not factionID or not tonumber(factionID) then
		exports.mek_infobox:addBox(source, "error", "Birlik ID'si geçersiz.")
		return
	end

	local faction = exports.mek_faction:getFactionFromID(factionID)
	if not faction or not isElement(faction) then
		exports.mek_infobox:addBox(source, "error", "Birlik bulunamadı.")
		return
	end

	if action == BANK_ACTION.deposit then
		if not exports.mek_global:hasMoney(source, amount) then
			exports.mek_infobox:addBox(source, "error", "Üzerinizde yeterli nakit yok.")
			return
		end

		exports.mek_global:takeMoney(source, amount)
		exports.mek_global:giveMoney(faction, amount)
		exports.mek_infobox:addBox(
			source,
			"success",
			"₺" .. exports.mek_global:formatMoney(amount) .. " birlik kasasına yatırıldı."
		)
	elseif action == BANK_ACTION.withdraw then
		if not exports.mek_global:hasMoney(faction, amount) then
			exports.mek_infobox:addBox(source, "error", "Birlik kasasında yeterli para yok.")
			return
		end

		exports.mek_global:takeMoney(faction, amount)
		exports.mek_global:giveMoney(source, amount)
		exports.mek_infobox:addBox(
			source,
			"success",
			"₺" .. exports.mek_global:formatMoney(amount) .. " birlik kasasından çekildi."
		)
	else
		exports.mek_infobox:addBox(source, "error", "Geçersiz işlem türü.")
	end
end)
