function checkPlayer(thePlayer, commandName, targetPlayer)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end
	
	if exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
		if targetPlayer then
			local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
			if targetPlayer then
				if getElementData(targetPlayer, "logged") then
					local ip = getPlayerIP(targetPlayer)
					local adminReports = tonumber(getElementData(targetPlayer, "admin_reports"))
					local balance = nil
					local note = ""

					dbQuery(
						function(queryHandle)
							local res, rows, err = dbPoll(queryHandle, 0)
							local result = res[1]
							if result then
								text = result["admin_note"] or "?"
								balance = result["balance"] or "?"
							end

							dbQuery(
								function(queryHandle)
									local res, rows, err = dbPoll(queryHandle, 0)
									history = {}
									for index, row in ipairs(res) do
										if row then
											table.insert(history, { tonumber(row.action), tonumber(row.numbr) })
										end
									end

									hoursAcc = "?"

									dbQuery(
										function(queryHandle)
											local res, rows, err = dbPoll(queryHandle, 0)

											hoursAcc = tonumber(res[1].hours)
											local money = getElementData(targetPlayer, "money") or -1
											local adminLevel = exports.mek_global:getPlayerAdminTitle(targetPlayer)
											local hoursPlayed = getElementData(targetPlayer, "hours_played")
											local username = getElementData(targetPlayer, "account_username")

											triggerClientEvent(
												thePlayer,
												"onCheck",
												targetPlayer,
												ip,
												adminReports,
												balance,
												note,
												history,
												money,
												adminLevel,
												hoursPlayed,
												username,
												hoursAcc
											)
										end,
										exports.mek_mysql:getConnection(),
										"SELECT SUM(hours_played) AS hours FROM `characters` WHERE account_id = ?",
										tostring(getElementData(targetPlayer, "account_id"))
									)
								end,
								exports.mek_mysql:getConnection(),
								"SELECT action, COUNT(*) as numbr FROM admin_history WHERE user = ? GROUP BY action",
								tostring(getElementData(targetPlayer, "account_id"))
							)
						end,
						exports.mek_mysql:getConnection(),
						"SELECT admin_note, balance FROM accounts WHERE id = ?",
						tostring(getElementData(targetPlayer, "account_id"))
					)
				else
					outputChatBox(
						"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
						thePlayer,
						255,
						0,
						0,
						true
					)
				end
			end
		else
			outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addEvent("checkPlayer", true)
addEventHandler("checkPlayer", root, checkPlayer)

function savePlayerNote(targetPlayer, text)
	if exports.mek_integration:isPlayerTrialAdmin(client) then
		local account = getElementData(targetPlayer, "account_id")
		if account then
			local result = dbExec(
				exports.mek_mysql:getConnection(),
				"UPDATE accounts SET admin_note = ? WHERE id = ?",
				text,
				account
			)
			if result then
				outputChatBox(
					"[!]#FFFFFF Başarıyla "
						.. getPlayerName(targetPlayer):gsub("_", " ")
						.. " ("
						.. getElementData(targetPlayer, "account_username")
						.. ") isimli oyuncunun yetkili notu yenilendi.",
					client,
					0,
					255,
					0,
					true
				)
			end
		else
			outputChatBox("[!]#FFFFFF Bir sorun oluştu.", client, 255, 0, 0, true)
		end
	end
end
addEvent("savePlayerNote", true)
addEventHandler("savePlayerNote", root, savePlayerNote)

function showAdminHistory(targetPlayer)
	if source and isElement(source) and getElementType(source) == "player" then
		client = source
	end

	if not exports.mek_integration:isPlayerTrialAdmin(client) then
		if client ~= targetPlayer then
			return false
		end
	end

	if getElementData(targetPlayer, "logged") then
		local targetID = getElementData(targetPlayer, "account_id")
		if targetID then
			dbQuery(
				function(queryHandle, client)
					local res, rows, err = dbPoll(queryHandle, 0)
					local info = {}
					for index, row in ipairs(res) do
						local i = #info + 1
						if not info[i] then
							info[i] = {}
						end
						info[i][1] = row["date"]
						info[i][2] = row["action"]
						info[i][3] = row["reason"]
						info[i][4] = row["duration"]
						info[i][5] = row["username"] == nil and "SİSTEM" or row["username"]
						info[i][6] = row["user_char"] == nil and "?" or row["user_char"]
						info[i][7] = row["recordid"]
						info[i][8] = row["hadmin"]
					end

					triggerClientEvent(
						client,
						"cshowAdminHistory",
						targetPlayer,
						info,
						tostring(getElementData(targetPlayer, "account_username"))
					)
				end,
				{ client },
				exports.mek_mysql:getConnection(),
				"SELECT date, action, h.admin AS hadmin, reason, duration, a.username as username, c.name AS user_char, h.id as recordid FROM admin_history h LEFT JOIN accounts a ON a.id = h.admin LEFT JOIN characters c ON h.user_char = c.id WHERE user = ? ORDER BY h.id DESC",
				targetID
			)
		else
			outputChatBox("[!]#FFFFFF Bir sorun oluştu.", client, 255, 0, 0, true)
		end
	else
		outputChatBox(
			"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
			client,
			255,
			0,
			0,
			true
		)
	end
end
addEvent("showAdminHistory", true)
addEventHandler("showAdminHistory", root, showAdminHistory)

function removeAdminHistoryLine(id)
	if not id then
		return
	end

	dbQuery(function(queryHandle, client)
		local res, rows, err = dbPoll(queryHandle, 0)
		if rows > 0 then
			dbExec(exports.mek_mysql:getConnection(), "DELETE FROM admin_history WHERE id = ?", tostring(id))
			if client then
				outputChatBox("[!]#FFFFFF Başarıyla [" .. id .. "] ID'li kayıt silindi.", client, 0, 255, 0, true)
			end
		end
	end, { client }, exports.mek_mysql:getConnection(), "SELECT * FROM admin_history WHERE id = ?", tostring(id))
end
addEvent("admin.removeHistory", true)
addEventHandler("admin.removeHistory", root, removeAdminHistoryLine)

addCommandHandler("history", function(thePlayer, commandName, ...)
	if not exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
		if ... then
			outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
			return false
		end
	end

	local targetPlayer = thePlayer
	if ... then
		targetPlayer = exports.mek_global:findPlayerByPartialNick(thePlayer, table.concat({ ... }, "_"))
	end

	if targetPlayer then
		if not getElementData(targetPlayer, "logged") then
			outputChatBox(
				"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
				thePlayer,
				255,
				0,
				0,
				true
			)
		else
			triggerEvent("showAdminHistory", thePlayer, targetPlayer)
		end
	else
		local targetPlayerName = table.concat({ ... }, "_")

		local query = dbPrepareString(
			exports.mek_mysql:getConnection(),
			"SELECT account_id FROM characters WHERE name = ?",
			targetPlayerName
		)
		local result = dbPoll(dbQuery(exports.mek_mysql:getConnection(), query), -1)
		if result then
			if #result == 1 then
				local row = result[1]
				local id = row["account_id"] or "0"
				triggerEvent("showOfflineAdminHistory", thePlayer, id, targetPlayerName)
				return
			else
				local query2 = dbPrepareString(
					exports.mek_mysql:getConnection(),
					"SELECT id FROM accounts WHERE username = ?",
					targetPlayerName
				)
				local result2 = dbPoll(dbQuery(exports.mek_mysql:getConnection(), query2), -1)
				if result2 then
					if #result2 == 1 then
						local row2 = result2[1]
						local id = tonumber(row2["id"]) or "0"
						triggerEvent("showOfflineAdminHistory", thePlayer, id, targetPlayerName)
						return
					end
				end
			end
		end

		outputChatBox("[!]#FFFFFF Oyuncu bulunamadı veya birden fazla oyuncu bulunamadı.", thePlayer, 255, 0, 0, true)
	end
end)

addEvent("admin.showInventory", true)
addEventHandler("admin.showInventory", root, function(targetPlayer)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	executeCommandHandler("showinv", client, getElementData(targetPlayer, "id"))
end)

function addAdminHistory(user, admin, reason, action, duration)
	local user_char = 0

	if not action or not tonumber(action) then
		action = getHistoryAction(action)
	end

	if not action then
		action = 6
	end

	if not duration or not tonumber(duration) then
		duration = 0
	end

	if isElement(user) then
		user_char = getElementData(user, "dbid") or 0
		user = getElementData(user, "account_id") or 0
	end

	if isElement(admin) then
		admin = getElementData(admin, "account_id")
	end

	if not tonumber(user) or not tonumber(admin) or not reason then
		return false
	end

	return dbExec(
		exports.mek_mysql:getConnection(),
		"INSERT INTO admin_history SET admin = ?, user = ?, user_char = ?, action = ?, duration = ?, reason = ?",
		admin,
		user,
		user_char,
		action,
		duration,
		reason
	)
end
