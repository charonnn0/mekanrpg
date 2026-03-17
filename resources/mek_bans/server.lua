function bansCommand(thePlayer, commandName)
	if exports.mek_integration:isPlayerGeneralAdmin(thePlayer) then
		local normalBans, manualBans, accountBans = {}, {}, {}

		for _, ban in ipairs(getBans()) do
			table.insert(normalBans, {
				getBanNick(ban),
				getBanAdmin(ban),
				getBanReason(ban),
				getBanIP(ban),
				getBanSerial(ban),
			})
		end

		local dbResult = dbPoll(dbQuery(exports.mek_mysql:getConnection(), "SELECT * FROM bans"), -1)
		if dbResult then
			for _, data in ipairs(dbResult) do
				table.insert(manualBans, {
					data.id,
					data.serial,
					data.ip,
					data.admin,
					data.reason,
					data.date,
				})
			end
		end

		dbResult =
			dbPoll(dbQuery(exports.mek_mysql:getConnection(), "SELECT id, username FROM accounts WHERE banned = 1"), -1)
		if dbResult then
			for _, data in ipairs(dbResult) do
				table.insert(accountBans, { data.id, data.username })
			end
		end

		triggerClientEvent(thePlayer, "Ax.39d0s", thePlayer, normalBans, manualBans, accountBans)
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("bans", bansCommand, false, false)

addEvent("Bx.2kd91", true)
addEventHandler("Bx.2kd91", root, function(type, data)
	if client and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not exports.mek_integration:isPlayerGeneralAdmin(client) then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	local adminName = exports.mek_global:getPlayerFullAdminTitle(client)
	if type == 1 then
		removeBanFromSerial(data)
		exports.mek_global:sendMessageToAdmins(
			("[UNBAN] %s isimli yetkili [%s] serialin banını açtı."):format(adminName, data)
		)
		exports.mek_logs:addLog("unban", ("%s isimli yetkili [%s] serialin banını açtı."):format(adminName, data))
		outputChatBox("[!]#FFFFFF Başarıyla [" .. data .. "] serial banı açıldı.", client, 0, 255, 0, true)
	elseif type == 2 then
		dbExec(exports.mek_mysql:getConnection(), "DELETE FROM bans WHERE id = ?", data)
		exports.mek_global:sendMessageToAdmins(
			("[UNBAN] %s isimli yetkili [%s] ID'li banı açtı."):format(adminName, data)
		)
		exports.mek_logs:addLog("unban", ("%s isimli yetkili [%s] ID'li banı açtı."):format(adminName, data))
		outputChatBox("[!]#FFFFFF Başarıyla [" .. data .. "] ID'li ban açıldı.", client, 0, 255, 0, true)
	elseif type == 3 then
		dbExec(exports.mek_mysql:getConnection(), "UPDATE accounts SET banned = 0 WHERE id = ?", data[1])
		exports.mek_global:sendMessageToAdmins(
			("[UNBAN] %s isimli yetkili [%s] hesabın banını açtı."):format(adminName, data[2])
		)
		exports.mek_logs:addLog("unban", ("%s isimli yetkili [%s] hesabın banını açtı."):format(adminName, data[2]))
		outputChatBox(
			"[!]#FFFFFF Başarıyla [" .. data[2] .. "] isimli hesabın banı açıldı.",
			client,
			0,
			255,
			0,
			true
		)
	end
end)

function removeBanFromSerial(serial)
	for _, ban in ipairs(getBans()) do
		if serial == getBanSerial(ban) then
			removeBan(ban)
		end
	end
end