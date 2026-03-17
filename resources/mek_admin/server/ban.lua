local bannedPlayers = {}

local banSecurity = {}
local kickSecurity = {}

addEventHandler("onResourceStart", resourceRoot, function()
	dbQuery(function(queryHandle)
		local result, rows = dbPoll(queryHandle, 0)
		if rows > 0 and result then
			for _, row in ipairs(result) do
				loadBan(row.serial)
			end
		end
	end, exports.mek_mysql:getConnection(), "SELECT serial FROM bans")
end)

function loadBan(serial)
	if not serial then
		return false
	end

	dbQuery(function(queryHandle)
		local result, rows = dbPoll(queryHandle, 0)
		if rows > 0 and result then
			for _, row in ipairs(result) do
				local endTick = tonumber(row.end_tick)
				if endTick and endTick ~= -1 then
					bannedPlayers[serial] = endTick
				end
			end
		end
	end, exports.mek_mysql:getConnection(), "SELECT end_tick FROM bans WHERE serial = ?", serial)
end

function saveBan(serial)
	local endTick = bannedPlayers[serial]
	if not serial or not endTick then
		return false
	end

	return dbExec(exports.mek_mysql:getConnection(), "UPDATE bans SET end_tick = ? WHERE serial = ?", endTick, serial)
end

function removeBan(serial)
	if not bannedPlayers[serial] then
		return false
	end

	local query = dbExec(exports.mek_mysql:getConnection(), "DELETE FROM bans WHERE serial = ?", serial)
	if query then
		local targetPlayer = exports.mek_global:getPlayerFromSerial(serial)
		if targetPlayer then
			redirectPlayer(targetPlayer, "", 0)
		end
		bannedPlayers[serial] = nil
		return true
	end
	return false
end

function checkExpireTime()
	for serial, endTick in pairs(bannedPlayers) do
		if endTick <= 0 then
			removeBan(serial)
		else
			local newEndTick = math.max(endTick - 60 * 1000, 0)
			bannedPlayers[serial] = newEndTick
			saveBan(serial)

			if newEndTick == 0 then
				removeBan(serial)
			end
		end
	end
end
setTimer(checkExpireTime, 60 * 1000, 0)

function playerManualBan(thePlayer, commandName, targetPlayer, minutes, ...)
	if exports.mek_integration:isPlayerGeneralAdmin(thePlayer) then
		if not banSecurity[thePlayer] then
			banSecurity[thePlayer] = 0
		end

		if banSecurity[thePlayer] < 3 then
			local minutes = tonumber(minutes) and math.floor(tonumber(minutes))
			if targetPlayer and minutes and minutes >= 0 and (...) then
				local reason = table.concat({ ... }, " ")
				local targetPlayer, targetPlayerName =
					exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)

				if targetPlayer then
					local playerAdminLevel = getElementData(thePlayer, "admin_level") or 0
					local targetPlayerAdminLevel = getElementData(targetPlayer, "admin_level") or 0

					if exports.mek_integration:canAdminPunish(thePlayer, targetPlayer) then
						local serial = getPlayerSerial(targetPlayer)
						local ip = getPlayerIP(targetPlayer)

						dbQuery(
							function(queryHandle, thePlayer, targetPlayer, reason, serial)
								local result, rows = dbPoll(queryHandle, 0)
								if (rows > 0) and result[1] then
									outputChatBox(
										"[!]#FFFFFF Zaten ["
											.. result[1].serial
											.. "] serial'lı kullanıcı sunucudan yasaklı durumda.",
										thePlayer,
										255,
										0,
										0,
										true
									)
								else
									local time = getRealTime()
									local year = time.year + 1900
									local month = time.month + 1
									local day = time.monthday
									local hour = time.hour
									local minute = time.minute
									local second = time.second

									local currentDatetime = string.format(
										"%04d-%02d-%02d %02d:%02d:%02d",
										year,
										month,
										day,
										hour,
										minute,
										second
									)
									local endTick = (minutes == 0) and -1 or minutes * 60 * 1000

									dbExec(
										exports.mek_mysql:getConnection(),
										"INSERT INTO bans (serial, ip, admin, reason, date, end_tick) VALUES (?, ?, ?, ?, ?, ?)",
										serial,
										ip,
										exports.mek_global:getPlayerFullAdminTitle(thePlayer),
										reason,
										currentDatetime,
										endTick
									)
									loadBan(serial)

									if minutes == 0 then
										outputChatBox(
											"[BAN] "
												.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
												.. " isimli yetkili "
												.. targetPlayerName
												.. " ("
												.. (getElementData(targetPlayer, "account_username") or "?")
												.. ") isimli oyuncuyu sunucudan yasakladı.",
											root,
											255,
											0,
											0
										)
										outputChatBox("[BAN] Sebep: " .. reason .. " (Sınırsız)", root, 255, 0, 0)
										exports.mek_logs:addLog(
											"ban",
											exports.mek_global:getPlayerFullAdminTitle(thePlayer)
												.. " isimli yetkili "
												.. targetPlayerName
												.. " ("
												.. (getElementData(targetPlayer, "account_username") or "?")
												.. ") isimli oyuncuyu sunucudan yasakladı.;Sebep: "
												.. reason
												.. " (Sınırsız)"
										)
									else
										outputChatBox(
											"[BAN] "
												.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
												.. " isimli yetkili "
												.. targetPlayerName
												.. " ("
												.. (getElementData(targetPlayer, "account_username") or "?")
												.. ") isimli oyuncuyu sunucudan yasakladı.",
											root,
											255,
											0,
											0
										)
										outputChatBox(
											"[BAN] Sebep: " .. reason .. " (" .. minutes .. " dakika)",
											root,
											255,
											0,
											0
										)
										exports.mek_logs:addLog(
											"ban",
											exports.mek_global:getPlayerFullAdminTitle(thePlayer)
												.. " isimli yetkili "
												.. targetPlayerName
												.. " ("
												.. (getElementData(targetPlayer, "account_username") or "?")
												.. ") isimli oyuncuyu sunucudan yasakladı.;Sebep: "
												.. reason
												.. " ("
												.. minutes
												.. " dakika)"
										)
									end

									triggerEvent("savePlayer", targetPlayer, targetPlayer)
									addAdminHistory(
										targetPlayer,
										thePlayer,
										reason,
										2,
										(tonumber(minutes) and (minutes == 0 and 0 or minutes) or 0)
									)

									if getPedOccupiedVehicle(targetPlayer) then
										removePedFromVehicle(targetPlayer)
									end

									setElementPosition(targetPlayer, 0, 0, 0)
									setElementFrozen(targetPlayer, true)
									setElementInterior(targetPlayer, 0)
									setElementDimension(targetPlayer, 9999)

									setElementData(targetPlayer, "legal_name_change", true)
									setPlayerName(targetPlayer, "exception." .. getElementData(targetPlayer, "id"))
									setElementData(targetPlayer, "legal_name_change", false)

									exports.mek_account:resetPlayer(targetPlayer)
									triggerClientEvent(targetPlayer, "account.banPage", targetPlayer, {
										exports.mek_global:getPlayerFullAdminTitle(thePlayer),
										reason,
										currentDatetime,
										endTick,
									})
									triggerClientEvent(targetPlayer, "account.playBanSound", targetPlayer)

									banSecurity[thePlayer] = banSecurity[thePlayer] + 1
									if banSecurity[thePlayer] <= 1 then
										setTimer(function()
											banSecurity[thePlayer] = 0
										end, 1000 * 60 * 5, 1)
									end
								end
							end,
							{ thePlayer, targetPlayer, reason, serial },
							exports.mek_mysql:getConnection(),
							"SELECT serial FROM bans WHERE serial = ?",
							serial
						)
					else
						outputChatBox(
							"[!]#FFFFFF Sizden daha yüksek seviyedeki birini sunucudan yasaklayamazsınız.",
							thePlayer,
							255,
							0,
							0,
							true
						)
						outputChatBox(
							"[!]#FFFFFF "
								.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili sizi sunucudan yasaklamaya çalışdı.",
							targetPlayer,
							255,
							0,
							0,
							true
						)
					end
				end
			else
				outputChatBox(
					"Kullanım: /" .. commandName .. " [Karakter Adı / ID] [Dakika / 0 = Sınırsız] [Sebep]",
					thePlayer,
					255,
					194,
					14
				)
			end
		else
			outputChatBox(
				"[!]#FFFFFF Beş dakika içinde en fazla 3 oyuncuyu sunucudan yasaklayabilirsiniz.",
				thePlayer,
				255,
				0,
				0,
				true
			)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("ban", playerManualBan, false, false)

function offlinePlayerManualBan(thePlayer, commandName, serial, minutes, ...)
	if exports.mek_integration:isPlayerGeneralAdmin(thePlayer) then
		if not banSecurity[thePlayer] then
			banSecurity[thePlayer] = 0
		end

		if banSecurity[thePlayer] < 3 then
			local minutes = tonumber(minutes) and math.floor(tonumber(minutes))
			if serial and minutes and #serial == 32 and minutes >= 0 and (...) then
				local reason = table.concat({ ... }, " ")
				dbQuery(
					function(queryHandle, thePlayer, serial, minutes, reason)
						local result, rows = dbPoll(queryHandle, 0)
						if (rows > 0) and result[1] then
							outputChatBox(
								"[!]#FFFFFF Zaten ["
									.. result[1].serial
									.. "] serial'lı kullanıcı sunucudan yasaklı durumda.",
								thePlayer,
								255,
								0,
								0,
								true
							)
						else
							local time = getRealTime()
							local year = time.year + 1900
							local month = time.month + 1
							local day = time.monthday
							local hour = time.hour
							local minute = time.minute
							local second = time.second

							local currentDatetime =
								string.format("%04d-%02d-%02d %02d:%02d:%02d", year, month, day, hour, minute, second)
							local endTick = (minutes == 0) and -1 or minutes * 60 * 1000

							local maskedSerial = string.sub(serial, 1, 6) .. string.rep("*", 26)

							loadBan(serial)
							dbExec(
								exports.mek_mysql:getConnection(),
								"INSERT INTO bans (serial, ip, admin, reason, date, end_tick) VALUES (?, ?, ?, ?, ?, ?)",
								serial,
								nil,
								exports.mek_global:getPlayerFullAdminTitle(thePlayer),
								reason,
								currentDatetime,
								endTick
							)

							if minutes == 0 then
								outputChatBox(
									"[OBAN] "
										.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
										.. " isimli yetkili ["
										.. maskedSerial
										.. "] serial'ını sunucudan yasakladı.",
									root,
									255,
									0,
									0
								)
								outputChatBox("[OBAN] Sebep: " .. reason .. " (Sınırsız)", root, 255, 0, 0)
								exports.mek_logs:addLog(
									"ban",
									exports.mek_global:getPlayerFullAdminTitle(thePlayer)
										.. " isimli yetkili ["
										.. serial
										.. "] serial'ını sunucudan yasakladı.;Sebep: "
										.. reason
										.. " (Sınırsız)"
								)
							else
								outputChatBox(
									"[OBAN] "
										.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
										.. " isimli yetkili ["
										.. maskedSerial
										.. "] serial'ını sunucudan yasakladı.",
									root,
									255,
									0,
									0
								)
								outputChatBox(
									"[OBAN] Sebep: " .. reason .. " (" .. minutes .. " dakika)",
									root,
									255,
									0,
									0
								)
								exports.mek_logs:addLog(
									"ban",
									exports.mek_global:getPlayerFullAdminTitle(thePlayer)
										.. " isimli yetkili ["
										.. serial
										.. "] serial'ını sunucudan yasakladı.;Sebep: "
										.. reason
										.. " ("
										.. minutes
										.. " dakika)"
								)
							end

							for _, player in ipairs(getElementsByType("player")) do
								if getPlayerSerial(player) == serial then
									triggerEvent("savePlayer", player, player)
									addAdminHistory(
										player,
										thePlayer,
										reason,
										2,
										(tonumber(minutes) and (minutes == 0 and 0 or minutes) or 0)
									)

									if getPedOccupiedVehicle(player) then
										removePedFromVehicle(player)
									end

									setElementPosition(player, 0, 0, 0)
									setElementFrozen(player, true)
									setElementInterior(player, 0)
									setElementDimension(player, 9999)

									setElementData(player, "legal_name_change", true)
									setPlayerName(player, "banned." .. getElementData(player, "id"))
									setElementData(player, "legal_name_change", false)

									exports.mek_account:resetPlayer(player)
									triggerClientEvent(player, "account.banPage", player, {
										exports.mek_global:getPlayerFullAdminTitle(thePlayer),
										reason,
										currentDatetime,
										endTick,
									})
									triggerClientEvent(player, "account.playBanSound", player)
								end
							end

							banSecurity[thePlayer] = banSecurity[thePlayer] + 1
							if banSecurity[thePlayer] <= 1 then
								setTimer(function()
									banSecurity[thePlayer] = 0
								end, 1000 * 60 * 5, 1)
							end
						end
					end,
					{ thePlayer, serial, minutes, reason },
					exports.mek_mysql:getConnection(),
					"SELECT serial FROM bans WHERE serial = ?",
					serial
				)
			else
				outputChatBox(
					"Kullanım: /" .. commandName .. " [Serial] [Dakika / 0 = Sınırsız] [Sebep]",
					thePlayer,
					255,
					194,
					14
				)
			end
		else
			outputChatBox(
				"[!]#FFFFFF Beş dakika içinde en fazla 3 oyuncuyu sunucudan yasaklayabilirsiniz.",
				thePlayer,
				255,
				0,
				0,
				true
			)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("oban", offlinePlayerManualBan, false, false)

function playerBan(thePlayer, commandName, targetPlayer, minutes, ...)
	if exports.mek_integration:isPlayerGeneralAdmin(thePlayer) then
		if not banSecurity[thePlayer] then
			banSecurity[thePlayer] = 0
		end

		if banSecurity[thePlayer] < 3 then
			local minutes = tonumber(minutes) and math.floor(tonumber(minutes))
			if targetPlayer and minutes and minutes >= 0 and (...) then
				local reason = table.concat({ ... }, " ")
				local targetPlayer, targetPlayerName =
					exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)

				local playerAdminLevel = getElementData(thePlayer, "admin_level") or 0
				local targetPlayerAdminLevel = getElementData(targetPlayer, "admin_level") or 0

				if exports.mek_integration:canAdminPunish(thePlayer, targetPlayer) then
					if minutes == 0 then
						outputChatBox(
							"[PBAN] "
								.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili "
								.. targetPlayerName
								.. " ("
								.. (getElementData(targetPlayer, "account_username") or "?")
								.. ") isimli oyuncuyu sunucudan yasakladı.",
							root,
							255,
							0,
							0
						)
						outputChatBox("[PBAN] Sebep: " .. reason .. " (Sınırsız)", root, 255, 0, 0)
						exports.mek_logs:addLog(
							"ban",
							exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili "
								.. targetPlayerName
								.. " ("
								.. (getElementData(targetPlayer, "account_username") or "?")
								.. ") isimli oyuncuyu sunucudan yasakladı.;Sebep: "
								.. reason
								.. " (Sınırsız)"
						)
					else
						outputChatBox(
							"[PBAN] "
								.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili "
								.. targetPlayerName
								.. " ("
								.. (getElementData(targetPlayer, "account_username") or "?")
								.. ") isimli oyuncuyu sunucudan yasakladı.",
							root,
							255,
							0,
							0
						)
						outputChatBox("[PBAN] Sebep: " .. reason .. " (" .. minutes .. " dakika)", root, 255, 0, 0)
						exports.mek_logs:addLog(
							"ban",
							exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili "
								.. targetPlayerName
								.. " ("
								.. (getElementData(targetPlayer, "account_username") or "?")
								.. ") isimli oyuncuyu sunucudan yasakladı.;Sebep: "
								.. reason
								.. " ("
								.. minutes
								.. " dakika)"
						)
					end

					triggerEvent("savePlayer", targetPlayer, targetPlayer)
					addAdminHistory(
						targetPlayer,
						thePlayer,
						reason,
						2,
						(tonumber(minutes) and (minutes == 0 and 0 or minutes) or 0)
					)
					banPlayer(
						targetPlayer,
						true,
						false,
						true,
						(getElementData(thePlayer, "account_username") or "?"),
						reason,
						minutes * 60
					)

					banSecurity[thePlayer] = banSecurity[thePlayer] + 1
					if banSecurity[thePlayer] <= 1 then
						setTimer(function()
							banSecurity[thePlayer] = 0
						end, 10000, 1)
					end
				else
					outputChatBox(
						"[!]#FFFFFF Sizden daha yüksek seviyedeki birini sunucudan yasaklayamazsınız.",
						thePlayer,
						255,
						0,
						0,
						true
					)
					outputChatBox(
						"[!]#FFFFFF "
							.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
							.. " isimli yetkili sizi sunucudan yasaklamaya çalışdı.",
							targetPlayer,
							255,
							0,
							0,
							true
						)
				end
			else
				outputChatBox(
					"Kullanım: /" .. commandName .. " [Karakter Adı / ID] [Dakika / 0 = Sınırsız] [Sebep]",
					thePlayer,
					255,
					194,
					14
				)
			end
		else
			outputChatBox(
				"[!]#FFFFFF Beş dakika içinde en fazla 3 oyuncuyu sunucudan yasaklayabilirsiniz.",
				thePlayer,
				255,
				0,
				0,
				true
			)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("pban", playerBan, false, false)

function offlinePlayerBan(thePlayer, commandName, serial, minutes, ...)
	if exports.mek_integration:isPlayerGeneralAdmin(thePlayer) then
		if not banSecurity[thePlayer] then
			banSecurity[thePlayer] = 0
		end

		if banSecurity[thePlayer] < 3 then
			local minutes = tonumber(minutes) and math.floor(tonumber(minutes))
			if serial and minutes and minutes >= 0 and (...) then
				local reason = table.concat({ ... }, " ")
				local maskedSerial = string.sub(serial, 1, 6) .. string.rep("*", 26)

				if minutes == 0 then
					outputChatBox(
						"[OPBAN] "
							.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
							.. " isimli yetkili ["
							.. maskedSerial
							.. "] serial'ını sunucudan yasakladı.",
						root,
						255,
						0,
						0
					)
					outputChatBox("[OPBAN] Sebep: " .. reason .. " (Sınırsız)", root, 255, 0, 0)
					exports.mek_logs:addLog(
						"ban",
						exports.mek_global:getPlayerFullAdminTitle(thePlayer)
							.. " isimli yetkili ["
							.. serial
							.. "] serial'ını sunucudan yasakladı.;Sebep: "
							.. reason
							.. " (Sınırsız)"
					)
				else
					outputChatBox(
						"[OPBAN] "
							.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
							.. " isimli yetkili ["
							.. maskedSerial
							.. "] serial'ını sunucudan yasakladı.",
						root,
						255,
						0,
						0
					)
					outputChatBox("[OPBAN] Sebep: " .. reason .. " (" .. minutes .. " dakika)", root, 255, 0, 0)
					exports.mek_logs:addLog(
						"ban",
						exports.mek_global:getPlayerFullAdminTitle(thePlayer)
							.. " isimli yetkili ["
							.. serial
							.. "] serial'ını sunucudan yasakladı.;Sebep: "
							.. reason
							.. " ("
							.. minutes
							.. " dakika)"
					)
				end

				for _, player in ipairs(getElementsByType("player")) do
					if getPlayerSerial(player) == serial then
						triggerEvent("savePlayer", player, player)
						addAdminHistory(
							targetPlayer,
							player,
							reason,
							2,
							(tonumber(minutes) and (minutes == 0 and 0 or minutes) or 0)
						)
					end
				end

				addBan(nil, nil, serial, (getElementData(thePlayer, "account_username") or "?"), reason, minutes * 60)

				banSecurity[thePlayer] = banSecurity[thePlayer] + 1
				if banSecurity[thePlayer] <= 1 then
					setTimer(function()
						banSecurity[thePlayer] = 0
					end, 10000, 1)
				end
			else
				outputChatBox(
					"Kullanım: /" .. commandName .. " [Serial] [Dakika / 0 = Sınırsız] [Sebep]",
					thePlayer,
					255,
					194,
					14
				)
			end
		else
			outputChatBox(
				"[!]#FFFFFF Beş dakika içinde en fazla 3 oyuncuyu sunucudan yasaklayabilirsiniz.",
				thePlayer,
				255,
				0,
				0,
				true
			)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("opban", offlinePlayerBan, false, false)

function playerKick(thePlayer, commandName, targetPlayer, reason)
	if exports.mek_integration:isPlayerSeniorAdmin(thePlayer) then
		if not kickSecurity[thePlayer] then
			kickSecurity[thePlayer] = 0
		end

		if kickSecurity[thePlayer] < 3 then
			if targetPlayer and reason then
				local targetPlayer, targetPlayerName =
					exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
				if targetPlayer then
					local playerAdminLevel = getElementData(thePlayer, "admin_level") or 0
					local targetPlayerAdminLevel = getElementData(targetPlayer, "admin_level") or 0

					if exports.mek_integration:canAdminPunish(thePlayer, targetPlayer) then
						outputChatBox(
							"[KICK] "
								.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili "
								.. targetPlayerName
								.. " ("
								.. (getElementData(targetPlayer, "account_username") or "?")
								.. ") isimli oyuncuyu sunucudan attı.",
							root,
							255,
							0,
							0
						)
						outputChatBox("[KICK] Sebep: " .. reason, root, 255, 0, 0)
						exports.mek_logs:addLog(
							"kick",
							exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili "
								.. targetPlayerName
								.. " ("
								.. (getElementData(targetPlayer, "account_username") or "?")
								.. ") isimli oyuncuyu sunucudan attı.;Sebep: "
								.. reason
						)

						triggerEvent("savePlayer", targetPlayer, targetPlayer)
						addAdminHistory(targetPlayer, thePlayer, reason, 1, 0)
						kickPlayer(targetPlayer, thePlayer, reason)

						kickSecurity[thePlayer] = kickSecurity[thePlayer] + 1
						if kickSecurity[thePlayer] <= 1 then
							setTimer(function()
								kickSecurity[thePlayer] = 0
							end, 1000 * 60 * 5, 1)
						end
					else
						outputChatBox(
							"[!]#FFFFFF Kendinizden üst yetkili birisini sunucudan atamazsınız.",
							thePlayer,
							255,
							0,
							0,
							true
						)
						outputChatBox(
							"[!]#FFFFFF "
								.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili sizi sunucudan atmaya çalıştı.",
							targetPlayer,
							255,
							0,
							0,
							true
						)
					end
				end
			else
				outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID] [Sebep]", thePlayer, 255, 194, 14)
			end
		else
			outputChatBox(
				"[!]#FFFFFF Beş dakika içerisinde yalnızca en fazla 3 oyuncuyu sunucudan atabilirsiniz.",
				thePlayer,
				255,
				0,
				0,
				true
			)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("kick", playerKick, false, false)

addEventHandler("onPlayerQuit", root, function()
	banSecurity[source] = nil
	kickSecurity[source] = nil
end)
