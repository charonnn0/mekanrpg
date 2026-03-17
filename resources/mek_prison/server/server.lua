mysql = exports.mek_mysql

prisonData = {}

function string:split(sep)
	local sep, fields = sep or ":", {}
	local pattern = string.format("([^%s]+)", sep)
	self:gsub(pattern, function(c)
		fields[#fields + 1] = c
	end)
	return fields
end

function refreshPrisonData()
	dbQuery(function(queryHandle)
		local result, rows = dbPoll(queryHandle, 0)
		if result and rows > 0 then
			prisonData = {}
			for _, row in ipairs(result) do
				table.insert(prisonData, {
					row.id,
					row.character_id,
					row.name,
					row.jail_time,
					row.conviction_date,
					row.updated_by,
					row.charges,
					row.cell,
					row.fine,
				})
			end
		else
			prisonData = {}
		end
	end, mysql:getConnection(), "SELECT * FROM jailed ORDER BY id ASC")
end

addEventHandler("onResourceStart", resourceRoot, function()
	refreshPrisonData()
	setTimer(refreshPrisonData, 10000, 0)
	timeReleaseCheck()
	setTimer(timeReleaseCheck, 300000, 0)
	setTimer(securePrisonCheck, 5000, 0)
end)

function arrestCommand(thePlayer)
	if
		exports.mek_faction:isPlayerInFaction(thePlayer, { 1, 3 })
		or exports.mek_integration:isPlayerManager(thePlayer)
	then
		triggerClientEvent(thePlayer, "PrisonGUI", thePlayer, prisonData)
	end
end
addCommandHandler("arrest", arrestCommand, false, false)

addEvent("removePrisoner", true)
addEventHandler("removePrisoner", resourceRoot, function(row, removeID, fromGUI)
	if not client then return end
	if not (exports.mek_faction:isPlayerInFaction(client, { 1, 3 }) or exports.mek_integration:isPlayerManager(client)) then
		exports.mek_sac:banForEventAbuse(client, "removePrisoner")
		return
	end

	local result = dbExec(mysql:getConnection(), "DELETE FROM jailed WHERE id = ?", removeID)
	local charID = tonumber(prisonData[row][2])

	if result then
		if not fromGUI then
			dbExec(mysql:getConnection(), "UPDATE characters SET pd_jailed = 0 WHERE id = ?", charID)
		else
			exports.mek_infobox:addBox(
				client,
				"success",
				prisonData[row][3]:gsub("_", " ") .. " isimli mahkum hapisten çıkarıldı."
			)
			sendPrisonMessage(
				"** [Hapis] "
					.. getPlayerName(client):gsub("_", " ")
					.. " isimli personel "
					.. prisonData[row][3]
					.. " isimli mahkumu hapisten çıkardı."
			)

			for _, value in ipairs(getElementsByType("player")) do
				if getElementData(value, "dbid") == charID then
					outputChatBox(
						"[!]#FFFFFF "
							.. getPlayerName(client):gsub("_", " ")
							.. " isimli kişi tarafından hapisden çıkarıldınız.",
						value,
						0,
						255,
						0,
						true
					)

					if not getElementData(value, "admin_jailed") then
						local cell = getElementData(value, "pd_jail_cell")
						local location = releaseLocations[cells[cell].location]
						setElementPosition(value, location[1], location[2], location[3])
						setElementInterior(value, location[4])
						setElementDimension(value, location[5])
					end

					removeElementData(value, "pd_jailed")
					removeElementData(value, "pd_jail_time")
					removeElementData(value, "pd_jail_id")
					removeElementData(value, "pd_jail_cell")
					removeElementData(value, "pd_jail_charges")
				end
			end
		end

		table.remove(prisonData, row)

		if fromGUI then
			triggerClientEvent(client, "PrisonGUI:Refresh", client, prisonData)
		end
	end
end)

addEvent("addPrisoner", true)
addEventHandler("addPrisoner", resourceRoot, function(name, cell, days, hours, charges, fine, online)
	if not client then return end
	if not (exports.mek_faction:isPlayerInFaction(client, { 1, 3 }) or exports.mek_integration:isPlayerManager(client)) then
		exports.mek_sac:banForEventAbuse(client, "addPrisoner")
		return
	end
	
	local realTime = getRealTime()
	if days == "" then
		local days = 0
	end

	if online then
		if not isInArrestColshape(name) then
			exports.mek_infobox:addBox(
				client,
				"error",
				"Hedef oyuncunun işlem alanı içerisinde olması gerekmektedir."
			)
			return
		end
	else
		if not isInArrestColshape(client) then
			exports.mek_infobox:addBox(
				client,
				"error",
				"Bir mahkum eklemek için işlem alanı içerisinde olmanız gerekmektedir."
			)
			return
		end
	end

	if duplicateCheck(returnWhat(name, online)) then
		exports.mek_infobox:addBox(
			client,
			"error",
			"Bu oyuncu zaten cezasını çekiyor, bunun yerine mahkumu güncelle ifadesini kullanın."
		)
		return
	end

	local days = tonumber(days) * 24
	local jailTime = (realTime.timestamp + (tonumber(hours) + days) * 60 * 60)
	local query = dbExec(
		mysql:getConnection(),
		[[
            INSERT INTO jailed 
                (character_id, name, jail_time, updated_by, charges, cell, fine)
            VALUES 
                (
                    (SELECT id FROM characters WHERE name = ? LIMIT 1), 
                    ?, ?, ?, ?, ?, ?
                )
        ]],
		returnWhat(name, online),
		returnWhat(name, online),
		jailTime,
		updatedWho(client, online),
		charges,
		cell,
		fine
	)

	local thePlayer = client
	if query then
		dbExec(mysql:getConnection(), "UPDATE characters SET pd_jailed = 1 WHERE name = ?", returnWhat(name, online))
		dbQuery(function(queryHandle)
			local res, rows, err = dbPoll(queryHandle, 0)
			if rows > 0 then
				for index, row in ipairs(res) do
					table.insert(prisonData, #prisonData + 1, {
						row.id,
						row.character_id,
						row.name,
						row.jail_time,
						row.conviction_date,
						row.updated_by,
						row.charges,
						row.cell,
						row.fine,
					})

					-- Use the captured thePlayer variable
					if isElement(thePlayer) then
						local playerNameParts = getPlayerName(thePlayer):split("_")
						local firstLetter = string.sub(playerNameParts[1], 1, 1)
						local shortPlayerName = firstLetter .. playerNameParts[2]

						triggerClientEvent(thePlayer, "PrisonGUI:Refresh", thePlayer, prisonData)

						if online then
							exports.mek_infobox:addBox(
								thePlayer,
								"success",
								getPlayerName(name):gsub("_", " ") .. " isimli kişi hapse atıldı."
							)
							outputChatBox(
								"[!]#FFFFFF " .. getPlayerName(thePlayer):gsub("_", " ") .. " isimli kişi sizi hapse attı.",
								name,
								0,
								255,
								0,
								true
							)
							sendPrisonMessage(
								"** [Hapis] "
									.. getPlayerName(thePlayer):gsub("_", " ")
									.. " isimli personel "
									.. getPlayerName(name):gsub("_", " ")
									.. " isimli mahkumu "
									.. row.cell
									.. " numaralı hücreye yerleştirdi."
							)
						end
					end

					if online then
						if tonumber(fine) > 0 then
							local amount = tonumber(fine)
							local tax = exports.mek_global:getTaxAmount()

							exports.mek_global:takeBankMoney(name, amount)
							exports.mek_global:giveMoney(
								getTeamFromName("İstanbul Büyükşehir Belediyesi"),
								amount * tax
							)

							outputChatBox(
								"[!]#FFFFFF ₺"
									.. exports.mek_global:formatMoney(amount)
									.. " tutarında para cezası uygulandı.",
								name,
								0,
								255,
								0,
								true
							)
						end

						activateJail(row.character_id, name)
					end
				end
			end
		end, mysql:getConnection(), "SELECT * FROM jailed WHERE id = LAST_INSERT_ID()")
	else
		exports.mek_infobox:addBox(thePlayer, "error", "Bu isimde karakter bulunamadı.")
	end
end)

addEvent("changePrisoner", true)
addEventHandler("changePrisoner", resourceRoot, function(name, cell, days, hours, charges, row1, online)
	if not client then return end
	if not (exports.mek_faction:isPlayerInFaction(client, { 1, 3 }) or exports.mek_integration:isPlayerManager(client)) then
		exports.mek_sac:banForEventAbuse(client, "changePrisoner")
		return
	end
	
	local realTime = getRealTime()
	if days == "" then
		days = 0
	elseif days == PRISONER_STATUS.LifeTime and hours == PRISONER_STATUS.Release then
		days = 9999
		hours = 9999
	elseif days == PRISONER_STATUS.Awaiting and hours == PRISONER_STATUS.Release then
		days = 0
		hours = 0
	end

	local days = tonumber(days) * 24
	local jailTime = (realTime.timestamp + (tonumber(hours) + days) * 60 * 60)
	local query = dbExec(
		mysql:getConnection(),
		[[
            UPDATE jailed 
            SET 
                jail_time = ?, 
                updated_by = ?, 
                charges = ?, 
                cell = ? 
            WHERE 
                name = ?
        ]],
		jailTime,
		updatedWho(client, online),
		charges,
		cell,
		returnWhat(name, online)
	)

	local thePlayer = client
	if query then
		dbQuery(function(queryHandle)
			local res, rows, err = dbPoll(queryHandle, 0)
			if rows > 0 then
				for index, row in ipairs(res) do
					table.remove(prisonData, row1)
					table.insert(prisonData, #prisonData + 1, {
						row.id,
						row.character_id,
						row.name,
						row.jail_time,
						row.conviction_date,
						row.updated_by,
						row.charges,
						row.cell,
						row.fine,
					})

					if isElement(thePlayer) then
						triggerClientEvent(thePlayer, "PrisonGUI:Refresh", thePlayer, prisonData)

						exports.mek_infobox:addBox(
							thePlayer,
							"success",
							prisonData[row][3]:gsub("_", " ") .. " isimli mahkumun tutukluluk bilgileri güncellendi."
						)
					end

					if online then
						outputChatBox("[!]#FFFFFF Tutukluluk bilgileriniz güncellendi.", name, 0, 255, 0, true)
						activateJail(row.character_id, name)
					end
				end
			end
		end, mysql:getConnection(), "SELECT * FROM jailed WHERE name = ?", returnWhat(name, online))
	else
		exports.mek_infobox:addBox(thePlayer, "error", "Bu isimde karakter bulunamadı.")
	end
end)

function returnWhat(name, online)
	if online then
		return getPlayerName(name)
	else
		return name:gsub(" ", "_")
	end
end

function activateJail(id, target)
	if not id then
		return
	end

	for _, value in ipairs(prisonData) do
		if value[2] == id then
			setElementData(target, "pd_jailed", true)
			setElementData(target, "pd_jail_time", value[4])
			setElementData(target, "pd_jail_id", value[1])
			setElementData(target, "pd_jail_cell", value[8])
			setElementData(target, "pd_jail_charges", value[7])

			local cell = cells[value[8]]
			setElementPosition(target, cell[1], cell[2], cell[3])
			setElementDimension(target, cell[5])
			setElementInterior(target, cell[4])
			
			if getElementData(target, "restrained") then
				exports.mek_realism:forceUncuff(target)
			end
		end
	end
end

function duplicateCheck(name)
	if not name then
		return
	end

	for _, value in ipairs(prisonData) do
		if value[3] == name then
			return true
		end
		return false
	end
end

function checkForRelease()
	local thePlayer = client or source
	if not thePlayer or getElementType(thePlayer) ~= "player" then return end
	
	-- Security check: only allow the player themselves to trigger their own release check, 
	-- or allow if triggered by the server (client is nil).
	if client and client ~= thePlayer then
		exports.mek_sac:banForEventAbuse(client, "prison.checkJail (target mismatch)")
		return
	end

	local found = false
	for key, value in ipairs(prisonData) do
		if tonumber(value[2]) == tonumber(getElementData(thePlayer, "dbid")) then
			found = true
			local days, hours, remainingTime = cleanMath(value[4])

			if remainingTime <= 0 then
				triggerEvent("removePrisoner", resourceRoot, key, value[1])
				outputChatBox("[!]#FFFFFF Hapis süreniz doldu.", thePlayer, 0, 255, 0, true)
				return true
			else
				outputChatBox(
					"[!]#FFFFFF Şu anda hapishanesindesiniz. /jailtime komutuyla cezanızın süresini gözden geçirebilirsiniz.",
					thePlayer,
					255,
					0,
					0,
					true
				)

				setElementData(thePlayer, "pd_jailed", true)
				setElementData(thePlayer, "pd_jail_time", value[4])
				setElementData(thePlayer, "pd_jail_id", value[1])
				setElementData(thePlayer, "pd_jail_cell", value[8])
				setElementData(thePlayer, "pd_jail_charges", value[7])

				local skinID = getElementModel(thePlayer)
				local modelID = getElementData(thePlayer, "model")
				local team = getPlayerTeam(thePlayer)
				local cell = cells[value[8]]

				if isPedDead(thePlayer) then
					spawnPlayer(thePlayer, cell[1], cell[2], cell[3], 0, 0, 0, 0, team)
					setCameraTarget(thePlayer)
				else
					setElementPosition(thePlayer, cell[1], cell[2], cell[3])
				end

				if modelID and tonumber(modelID) > 0 then
					setElementData(thePlayer, "model", 0)
					setElementData(thePlayer, "model", modelID)
				else
					setElementModel(thePlayer, skinID)
				end

				setElementInterior(thePlayer, cell[4])
				setElementDimension(thePlayer, cell[5])

				return true
			end
		end
	end

	-- Only proceed to teleport/release if they are NOT in prisonData but have the jailed flag
	if not found and getElementData(thePlayer, "pd_jailed") then
		dbExec(
			mysql:getConnection(),
			"UPDATE characters SET pd_jailed = 0 WHERE id = ?",
			getElementData(thePlayer, "dbid")
		)

		if not getElementData(thePlayer, "admin_jailed") then
			local cellID = getElementData(thePlayer, "pd_jail_cell")
			local cell = cells[cellID]
			if cell then
				local location = releaseLocations[cell.location]
				if location then
					setElementPosition(thePlayer, location[1], location[2], location[3])
					setElementInterior(thePlayer, location[4])
					setElementDimension(thePlayer, location[5])
				end
			end
		end

		removeElementData(thePlayer, "pd_jailed")
		removeElementData(thePlayer, "pd_jail_time")
		removeElementData(thePlayer, "pd_jail_id")
		removeElementData(thePlayer, "pd_jail_cell")
		removeElementData(thePlayer, "pd_jail_charges")

		return true
	end

	return false
end

addCommandHandler("jailtime", function(thePlayer)
	local days, hours, remainingTime = cleanMath(getElementData(thePlayer, "pd_jail_time"))
	if not remainingTime then
		outputChatBox("[!]#FFFFFF Hapis cezası çekmiyorsunuz.", thePlayer, 255, 0, 0, true)
	elseif remainingTime <= 0 then
		for key, value in ipairs(prisonData) do
			if tonumber(value[2]) == tonumber(getElementData(thePlayer, "dbid")) then
				triggerEvent("removePrisoner", resourceRoot, key, value[1])
				outputChatBox("[!]#FFFFFF Hapis süreniz doldu.", thePlayer, 0, 255, 0, true)
			end
		end
	else
		if tonumber(hours) < 1 and tonumber(days) <= 0 then
			local minutes = ("%.1f"):format(remainingTime / 60)
			outputChatBox(
				"[!]#FFFFFF Şu anda cezanızın bitmesine "
					.. minutes
					.. " dakika kaldı. Mahkûm numaranız: "
					.. getElementData(thePlayer, "pd_jail_id")
					.. ", hücre numaranız: "
					.. getElementData(thePlayer, "pd_jail_cell"),
				thePlayer,
				255,
				255,
				0,
				true
			)
		else
			outputChatBox(
				"[!]#FFFFFF Şu anda cezanızın bitmesine "
					.. days
					.. " gün ve "
					.. hours
					.. " saat kaldı. Mahkûm numaranız: "
					.. getElementData(thePlayer, "pd_jail_id")
					.. ", hücre numaranız: "
					.. getElementData(thePlayer, "pd_jail_cell"),
				thePlayer,
				255,
				255,
				0,
				true
			)
		end
	end
end)

function timeReleaseCheck()
	for i, player in ipairs(getElementsByType("player")) do
		if getElementData(player, "logged") then
			for _, res in ipairs(prisonData) do
				if tonumber(res[2]) == tonumber(getElementData(player, "dbid")) then
					local days, hours, remainingTime = cleanMath(res[4])
					if remainingTime <= 0 then
						outputChatBox("[!]#FFFFFF Hapis süreniz doldu.", player, 0, 255, 0, true)
						triggerEvent("removePrisoner", resourceRoot, _, res[1])

						if not getElementData(player, "admin_jailed") then
							local cellID = getElementData(player, "pd_jail_cell")
							local cell = cells[cellID]
							if cell then
								local location = releaseLocations[cell.location]
								if location then
									setElementPosition(player, location[1], location[2], location[3])
									setElementInterior(player, location[4])
									setElementDimension(player, location[5])
								end
							end
						end

						removeElementData(player, "pd_jailed")
						removeElementData(player, "pd_jail_time")
						removeElementData(player, "pd_jail_id")
						removeElementData(player, "pd_jail_cell")
						removeElementData(player, "pd_jail_charges")
					else
						setElementData(player, "pd_jailed", true)
						setElementData(player, "pd_jail_time", res[4])
						setElementData(player, "pd_jail_id", res[1])
						setElementData(player, "pd_jail_cell", res[8])
						setElementData(player, "pd_jail_charges", res[7])
					end
				end
			end
		end
	end
end

function sendPrisonMessage(string)
	local string = string:gsub("_", " ")
	for _, player in ipairs(getElementsByType("player")) do
		if exports.mek_faction:isPlayerInFaction(player, { 1, 3 }) then
			outputChatBox(string, player, 65, 65, 255)
		end
	end
end

function updatedWho(online)
	if not client then
		return "System"
	end
	
	if online then
		return getElementData(client, "account_username") or "Unknown"
	else
		return getPlayerName(client):gsub("_", " ")
	end
end

addEvent("prison.checkJail", true)
addEventHandler("prison.checkJail", root, checkForRelease)

function securePrisonCheck()
	for _, player in ipairs(getElementsByType("player")) do
		if getElementData(player, "pd_jailed") then
			local dbid = getElementData(player, "dbid")
			local isActuallyJailed = false
			if dbid then
				for _, data in ipairs(prisonData) do
					if tonumber(data[2]) == tonumber(dbid) then
						isActuallyJailed = true
						break
					end
				end
			end
			
			if not isActuallyJailed then
				removeElementData(player, "pd_jailed")
				removeElementData(player, "pd_jail_time")
				removeElementData(player, "pd_jail_id")
				removeElementData(player, "pd_jail_cell")
				removeElementData(player, "pd_jail_charges")
				
				if dbid then
					dbExec(mysql:getConnection(), "UPDATE characters SET pd_jailed = 0 WHERE id = ?", dbid)
				end
			end
		end
	end
end
