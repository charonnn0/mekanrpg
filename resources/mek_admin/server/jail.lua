local jailSecurity = {}

function jailPlayer(thePlayer, commandName, targetPlayer, minutes, ...)
	if exports.mek_integration:isPlayerAdmin1(thePlayer) then
		if not jailSecurity[thePlayer] then
			jailSecurity[thePlayer] = 0
		end

		if jailSecurity[thePlayer] < 3 then
			local minutes = tonumber(minutes) and math.floor(tonumber(minutes))
			if targetPlayer and minutes and minutes >= 0 and ... then
				local targetPlayer, targetPlayerName =
					exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
				local reason = table.concat({ ... }, " ")

				if targetPlayer then
					if not exports.mek_integration:canAdminPunish(thePlayer, targetPlayer) then
						outputChatBox("[!]#FFFFFF Kendinizden üst yetkili birisini hapse atamazsınız.", thePlayer, 255, 0, 0, true)
						return
					end
					
					local jailTimer = getElementData(targetPlayer, "admin_jail_timer")
					local accountID = getElementData(targetPlayer, "account_id")

					local currentJailTime = getElementData(targetPlayer, "admin_jail_time")
					local currentReason = getElementData(targetPlayer, "admin_jail_reason")

					if currentJailTime and (type(currentJailTime) == "number" or currentJailTime == "Sınırsız") then
						if currentJailTime ~= "Sınırsız" and minutes ~= 0 then
							minutes = minutes + currentJailTime
						elseif currentJailTime == "Sınırsız" or minutes == 0 then
							minutes = 0
						end

						if currentReason and currentReason ~= "" then
							reason = currentReason .. " + " .. reason
						end
					end

					if isTimer(jailTimer) then
						killTimer(jailTimer)
					end

					if isPedInVehicle(targetPlayer) then
						removePedFromVehicle(targetPlayer)
					end
					detachElements(targetPlayer)

					setElementPosition(targetPlayer, 263.821807, 77.848365, 1001.0390625)
					setPedRotation(targetPlayer, 270)
					setElementInterior(targetPlayer, 6)
					setElementDimension(targetPlayer, 60000 + getElementData(targetPlayer, "id"))
					setCameraInterior(targetPlayer, 6)

					if minutes == 0 then
						dbExec(
							exports.mek_mysql:getConnection(),
							"UPDATE accounts SET admin_jailed = 1, admin_jail_time = -1, admin_jail_by = ?, admin_jail_reason = ? WHERE id = ?",
							exports.mek_global:getPlayerFullAdminTitle(thePlayer),
							reason,
							accountID
						)
						setElementData(targetPlayer, "admin_jail_time", "Sınırsız")
						setElementData(targetPlayer, "admin_jail_timer", true)

						outputChatBox(
							"(( "
								.. targetPlayerName
								.. " cezalandırıldı. Süre: Sınırsız - Sebep: "
								.. reason
								.. " ))",
							root,
							255,
							0,
							0
						)
						exports.mek_logs:addLog(
							"jail",
							exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili "
								.. targetPlayerName
								.. " isimli oyuncuyu Sınırsız olarak hapse attı.;Sebep: "
								.. reason
						)
					else
						dbExec(
							exports.mek_mysql:getConnection(),
							"UPDATE accounts SET admin_jailed = 1, admin_jail_time = ?, admin_jail_by = ?, admin_jail_reason = ? WHERE id = ?",
							minutes,
							exports.mek_global:getPlayerFullAdminTitle(thePlayer),
							reason,
							accountID
						)

						local theTimer = setTimer(timerUnjailPlayer, 60000, 1, targetPlayer)
						setElementData(targetPlayer, "admin_jail_timer", theTimer)
						setElementData(targetPlayer, "admin_jail_served", 0)
						setElementData(targetPlayer, "admin_jail_time", minutes)

						outputChatBox(
							"(( "
								.. targetPlayerName
								.. " cezalandırıldı. Süre: "
								.. minutes
								.. " dakika - Sebep: "
								.. reason
								.. " ))",
							root,
							255,
							0,
							0
						)
						exports.mek_logs:addLog(
							"jail",
							exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili "
								.. targetPlayerName
								.. " isimli oyuncuyu "
								.. minutes
								.. " dakika hapse attı.;Sebep: "
								.. reason
						)
					end

					setElementData(targetPlayer, "admin_jailed", true)
					setElementData(targetPlayer, "admin_jail_reason", reason)
					setElementData(targetPlayer, "admin_jail_by", exports.mek_global:getPlayerFullAdminTitle(thePlayer))

					addAdminHistory(
						targetPlayer,
						thePlayer,
						reason,
						0,
						(tonumber(minutes) and (minutes == 0 and 0 or minutes) or 0)
					)

					jailSecurity[thePlayer] = jailSecurity[thePlayer] + 1
					if jailSecurity[thePlayer] <= 1 then
						setTimer(function()
							jailSecurity[thePlayer] = 0
						end, 1000 * 60 * 5, 1)
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
				"[!]#FFFFFF Beş dakika içinde en fazla 3 oyuncuyu hapse atabilirsiniz.",
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
addCommandHandler("jail", jailPlayer, false, false)

function offlineJailPlayer(thePlayer, commandName, targetPlayer, minutes, ...)
	if exports.mek_integration:isPlayerAdmin1(thePlayer) then
		if not jailSecurity[thePlayer] then
			jailSecurity[thePlayer] = 0
		end

		if jailSecurity[thePlayer] < 5 then
			local minutes = tonumber(minutes) and math.floor(tonumber(minutes))
			if targetPlayer and minutes and minutes >= 0 and ... then
				local reason = table.concat({ ... }, " ")

				for _, player in ipairs(getElementsByType("player")) do
					if getElementData(player, "logged") then
						if targetPlayer:lower() == getElementData(player, "account_username"):lower() then
							jailPlayer(thePlayer, "jail", getPlayerName(player):gsub(" ", "_"), minutes, reason)
							return
						end
					end
				end

				local currentReason = nil
				local currentTime = nil

				local checkJailQuery = dbPrepareString(
					exports.mek_mysql:getConnection(),
					"SELECT admin_jail_time, admin_jail_reason FROM accounts WHERE id = ?",
					accountID
				)
				local checkJailResult = dbPoll(dbQuery(exports.mek_mysql:getConnection(), checkJailQuery), -1)
				if checkJailResult and #checkJailResult > 0 then
					currentTime = tonumber(checkJailResult[1].admin_jail_time)
					currentReason = checkJailResult[1].admin_jail_reason

					if currentTime and currentTime > 0 and minutes ~= 0 then
						minutes = minutes + currentTime
					elseif currentTime == -1 or minutes == 0 then
						minutes = 0
					end

					if currentReason and currentReason ~= "" then
						reason = currentReason .. " + " .. reason
					end
				end

				local targetPlayerQuery = dbPrepareString(
					exports.mek_mysql:getConnection(),
					"SELECT id, username FROM accounts WHERE username = ? LIMIT 1",
					targetPlayer
				)
				local targetPlayerResultHandle = dbQuery(exports.mek_mysql:getConnection(), targetPlayerQuery)
				local targetPlayerResult = dbPoll(targetPlayerResultHandle, -1)
				local accountID, accountUsername = nil, nil

				if targetPlayerResult and #targetPlayerResult > 0 then
					accountID = targetPlayerResult[1].id
					accountUsername = targetPlayerResult[1].username
				else
					outputChatBox("[!]#FFFFFF Böyle bir oyuncu bulunamadı.", thePlayer, 255, 0, 0, true)
					return
				end
				dbFree(targetPlayerResultHandle)

				if minutes == 0 then
					dbExec(
						exports.mek_mysql:getConnection(),
						"UPDATE accounts SET admin_jailed = 1, admin_jail_time = -1, admin_jail_by = ?, admin_jail_reason = ? WHERE id = ?",
						exports.mek_global:getPlayerFullAdminTitle(thePlayer),
						reason,
						accountID
					)
					outputChatBox(
						"(( "
							.. accountUsername
							.. " cezalandırıldı. Süre: Sınırsız - Sebep: "
							.. reason
							.. " ))",
						root,
						255,
						0,
						0
					)
					exports.mek_logs:addLog(
						"jail",
						exports.mek_global:getPlayerFullAdminTitle(thePlayer)
							.. " isimli yetkili "
							.. accountUsername
							.. " isimli oyuncuyu Sınırsız olarak hapse attı.;Sebep: "
							.. reason
					)
				else
					dbExec(
						exports.mek_mysql:getConnection(),
						"UPDATE accounts SET admin_jailed = 1, admin_jail_time = ?, admin_jail_by = ?, admin_jail_reason = ? WHERE id = ?",
						minutes,
						exports.mek_global:getPlayerFullAdminTitle(thePlayer),
						reason,
						accountID
					)
					outputChatBox(
						"(( "
							.. accountUsername
							.. " cezalandırıldı. Süre: "
							.. minutes
							.. " dakika - Sebep: "
							.. reason
							.. " ))",
						root,
						255,
						0,
						0
					)
					exports.mek_logs:addLog(
						"jail",
						exports.mek_global:getPlayerFullAdminTitle(thePlayer)
							.. " isimli yetkili "
							.. accountUsername
							.. " isimli oyuncuyu "
							.. minutes
							.. " dakika hapse attı.;Sebep: "
							.. reason
					)
				end

				addAdminHistory(
					accountID,
					thePlayer,
					reason,
					0,
					(tonumber(minutes) and (minutes == 0 and 0 or minutes) or 0)
				)

				jailSecurity[thePlayer] = jailSecurity[thePlayer] + 1
				if jailSecurity[thePlayer] <= 1 then
					setTimer(function()
						jailSecurity[thePlayer] = 0
					end, 1000 * 60 * 5, 1)
				end
			else
				outputChatBox(
					"Kullanım: /" .. commandName .. " [Kullanıcı Adı] [Dakika / 0 = Sınırsız] [Sebep]",
					thePlayer,
					255,
					194,
					14
				)
			end
		else
			outputChatBox(
				"[!]#FFFFFF Beş dakika içinde en fazla 3 oyuncuyu hapse atabilirsiniz.",
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
addCommandHandler("ojail", offlineJailPlayer, false, false)

function unjailPlayer(thePlayer, commandName, target)
	if exports.mek_integration:isPlayerServerFounder(thePlayer) then
		if not target then
			outputChatBox(
				"Kullanım: /" .. commandName .. " [Karakter Adı / ID]",
				thePlayer,
				255,
				194,
				14
			)
			return
		end

		local targetPlayer, targetPlayerName =
			exports.mek_global:findPlayerByPartialNick(thePlayer, target)

		if not targetPlayer then
			return
		end

		local jailedTimer = getElementData(targetPlayer, "admin_jail_timer")
		local accountID = getElementData(targetPlayer, "account_id")
		local jailReason = getElementData(targetPlayer, "admin_jail_reason") or "Belirtilmedi"

		if not jailedTimer then
			outputChatBox(
				"[!]#FFFFFF " .. targetPlayerName .. " isimli oyuncu hapiste değil.",
				thePlayer,
				255,
				0,
				0,
				true
			)
			return
		end

		if isTimer(jailedTimer) then
			killTimer(jailedTimer)
		end

		dbExec(
			exports.mek_mysql:getConnection(),
			"UPDATE accounts SET admin_jailed = 0, admin_jail_time = 0, admin_jail_by = NULL, admin_jail_reason = NULL WHERE id = ?",
			accountID
		)

		setElementData(targetPlayer, "admin_jail_timer", false)
		setElementData(targetPlayer, "admin_jailed", false)
		setElementData(targetPlayer, "admin_jail_reason", false)
		setElementData(targetPlayer, "admin_jail_time", false)
		setElementData(targetPlayer, "admin_jail_by", false)

		setElementPosition(targetPlayer, 1519.8505859375, -1699.615234375, 13.546875)
		setPedRotation(targetPlayer, 270)
		setElementDimension(targetPlayer, 0)
		setCameraInterior(targetPlayer, 0)
		setElementInterior(targetPlayer, 0)

		outputChatBox(
			"[!]#FFFFFF " .. targetPlayerName .. " isimli oyuncu hapisten çıkarıldı.",
			thePlayer,
			0,
			255,
			0,
			true
		)

		outputChatBox(
			"[!]#FFFFFF "
				.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
				.. " isimli yetkili sizi hapisten çıkardı.",
			targetPlayer,
			0,
			255,
			0,
			true
		)

		exports.mek_global:sendMessageToAdmins(
			"[HAPİS] "
				.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
				.. " isimli yetkili "
				.. targetPlayerName
				.. " isimli oyuncuyu hapisten çıkardı."
		)

		exports.mek_logs:addLog(
			"unjail",
			exports.mek_global:getPlayerFullAdminTitle(thePlayer)
				.. " isimli yetkili "
				.. targetPlayerName
				.. " isimli oyuncuyu hapisten çıkardı.;Önceki Sebep: "
				.. jailReason
		)
	else
		outputChatBox(
			"[!]#FFFFFF Yeterli yetkiniz yok.",
			thePlayer,
			255,
			0,
			0,
			true
		)
	end
end
addCommandHandler("unjail", unjailPlayer, false, false)

function jailedPlayers(thePlayer, commandName)
	if exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
		local players = getElementsByType("player")
		local count = 0
		for _, player in ipairs(players) do
			if getElementData(player, "admin_jailed") then
				if tonumber(getElementData(player, "admin_jail_time")) then
					outputChatBox(
						"[HAPİS] "
							.. getPlayerName(player):gsub("_", " ")
							.. " isimli oyuncu "
							.. tostring(getElementData(player, "admin_jail_by"))
							.. " tarafından "
							.. tostring(getElementData(player, "admin_jail_served"))
							.. " dakikadir içerde, "
							.. tostring(getElementData(player, "admin_jail_time"))
							.. " dakikasi kaldı.",
						thePlayer,
						255,
						0,
						0
					)
					outputChatBox(
						"[HAPİS] Sebep: " .. tostring(getElementData(player, "admin_jail_reason")),
						thePlayer,
						255,
						0,
						0
					)
				else
					outputChatBox(
						"[HAPİS] "
							.. getPlayerName(player):gsub("_", " ")
							.. " isimli oyuncu "
							.. tostring(getElementData(player, "admin_jail_by"))
							.. " tarafından Sınırsız hapse atıldı.",
						thePlayer,
						255,
						0,
						0
					)
					outputChatBox(
						"[HAPİS] Sebep: " .. tostring(getElementData(player, "admin_jail_reason")),
						thePlayer,
						255,
						0,
						0
					)
				end
				count = count + 1
			end
		end

		if count == 0 then
			outputChatBox("[!]#FFFFFF Hiç kimse hapiste değil.", thePlayer, 255, 0, 0, true)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
--addCommandHandler("jailed", jailedPlayers, false, false)

function timerUnjailPlayer(thePlayer)
	if isElement(thePlayer) then
		local timeServed = getElementData(thePlayer, "admin_jail_served")
		local timeLeft = getElementData(thePlayer, "admin_jail_time")
		local accountID = getElementData(thePlayer, "account_id")

		if timeServed then
			setElementData(thePlayer, "admin_jail_served", timeServed + 1)
			timeLeft = timeLeft - 1
			setElementData(thePlayer, "admin_jail_time", timeLeft)

			if timeLeft <= 0 then
				dbExec(
					exports.mek_mysql:getConnection(),
					"UPDATE accounts SET admin_jailed = 0, admin_jail_time = 0, admin_jail_by = NULL, admin_jail_reason = NULL WHERE id = ?",
					accountID
				)

				setElementData(thePlayer, "admin_jail_timer", false)
				setElementData(thePlayer, "admin_jailed", false)
				setElementData(thePlayer, "admin_jail_reason", false)
				setElementData(thePlayer, "admin_jail_time", false)
				setElementData(thePlayer, "admin_jail_by", false)
				setElementPosition(thePlayer, 1519.8505859375, -1699.615234375, 13.546875)
				setPedRotation(thePlayer, 270)
				setElementDimension(thePlayer, 0)
				setElementInterior(thePlayer, 0)
				setCameraInterior(thePlayer, 0)

				outputChatBox("[!]#FFFFFF Hapis süreniz bitti.", thePlayer, 0, 255, 0, true)
				exports.mek_global:sendMessageToAdmins(
					"[HAPİS] " .. getPlayerName(thePlayer):gsub("_", " ") .. " isimli oyuncunun hapis süresi bitti."
				)
				exports.mek_logs:addLog(
					"jail",
					getPlayerName(thePlayer):gsub("_", " ") .. " isimli oyuncunun hapis süresi bitti."
				)
			else
				dbExec(
					exports.mek_mysql:getConnection(),
					"UPDATE accounts SET admin_jail_time = ? WHERE id = ?",
					timeLeft,
					accountID
				)

				local theTimer = setTimer(timerUnjailPlayer, 60000, 1, thePlayer)
				setElementData(thePlayer, "admin_jail_timer", theTimer)
			end
		end
	end
end
addEvent("admin.timerUnjailPlayer", false)
addEventHandler("admin.timerUnjailPlayer", root, timerUnjailPlayer)

addEventHandler("onPlayerQuit", root, function()
	jailSecurity[source] = nil
end)


------ jail-affı commands _charonn0
function jailAmnestyCommand(thePlayer, commandName)
    local username = getElementData(thePlayer, "account_username")
    if username ~= "charon" and username ~= "Thyntra" then
        outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
        return
    end

    triggerClientEvent(thePlayer, "jailaffi.showConfirmation", thePlayer)
end
--addCommandHandler("jailaffi", jailAmnestyCommand, false, false)

addEvent("jailaffi.confirm", true)
addEventHandler("jailaffi.confirm", root, function()
    if not client then return end
    local playerName = getPlayerName(client)

    -- Tüm jail’leri aç
    for _, player in ipairs(getElementsByType("player")) do
        local jailed = getElementData(player, "admin_jail_timer")
        local accountID = getElementData(player, "account_id")

        if jailed then
            if isTimer(jailed) then
                killTimer(jailed)
            end

            dbExec(
                exports.mek_mysql:getConnection(),
                "UPDATE accounts SET admin_jailed = 0, admin_jail_time = 0, admin_jail_by = NULL, admin_jail_reason = NULL WHERE id = ?",
                accountID
            )

            setElementData(player, "admin_jail_timer", false)
            setElementData(player, "admin_jailed", false)
            setElementData(player, "admin_jail_reason", false)
            setElementData(player, "admin_jail_time", false)
            setElementData(player, "admin_jail_by", false)

            setElementPosition(player, 1519.8505859375, -1699.615234375, 13.546875)
            setPedRotation(player, 270)
            setElementDimension(player, 0)
            setCameraInterior(player, 0)
            setElementInterior(player, 0)

            outputChatBox(
                "[!]#FFFFFF Tüm jail affı ile hapisten çıkarıldınız!",
                player,
                0, 255, 0,
                true
            )

            exports.mek_logs:addLog(
                "jail",
                ("%s tarafından affedildi (Jail affı)."):format(playerName)
            )
        end
    end

    exports.mek_global:sendMessageToAdmins(("[JAIL AFFI] %s tüm jail’leri açtı."):format(playerName))
    outputChatBox("[!]#FFFFFF Başarıyla tüm jail’ler açıldı!", client, 0, 255, 0)
end)
