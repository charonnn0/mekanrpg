mysql = exports.mek_mysql

locations = {}
custom = {}

function loadOneFaction(row)
	local id = tonumber(row.id)

	local theTeam = exports.mek_pool:getElementByID("team", id)
	if theTeam then
		destroyElement(theTeam)
	end

	local name = row.name
	local money = tonumber(row.money)
	local factionType = tonumber(row.type)

	theTeam = createTeam(tostring(name))
	if theTeam then
		exports.mek_pool:allocateElement(theTeam, id)
		setElementData(theTeam, "type", factionType)
		setElementData(theTeam, "money", money)
		setElementData(theTeam, "id", id)

		local motd = row.motd
		local rank_order = row.rank_order
		setElementData(theTeam, "rank_order", rank_order)
		setElementData(theTeam, "motd", motd)
		setElementData(theTeam, "note", row.note == nil and "" or row.note)
		setElementData(theTeam, "fnote", row.fnote == nil and "" or row.fnote)
		setElementData(theTeam, "phone", row.phone ~= nil and row.phone or nil)
		setElementData(theTeam, "max_interiors", tonumber(row.max_interiors))
		setElementData(theTeam, "max_vehicles", tonumber(row.max_vehicles))
		setElementData(theTeam, "before_tax_value", tonumber(row.before_tax_value))
		setElementData(theTeam, "before_wage_charge", tonumber(row.before_wage_charge))

		dbQuery(allocateFactionRank, mysql:getConnection(), "SELECT * FROM `faction_ranks` WHERE `faction_id` = ?", id)
	end
	return theTeam
end

function loadAllFactions(res)
	setElementData(resourceRoot, "duty_gui", {})
	setElementData(resourceRoot, "maxlindex", 0)
	setElementData(resourceRoot, "maxcindex", 0)

	local qh = dbQuery(function(qh)
		local result = dbPoll(qh, 0)
		if not result then
			dbFree(qh)
			return
		end
		for _, row in pairs(result) do
			loadOneFaction(row)
		end
	end, mysql:getConnection(), "SELECT * FROM factions ORDER BY id ASC")

	local customQ = dbQuery(function(customQ)
		local result, rows = dbPoll(customQ, 0)
		if not result or rows < 1 then
			dbFree(customQ)
			return
		end

		for _, row in pairs(result) do
			local skins = fromJSON(tostring(row.skins)) or {}
			local locations = fromJSON(tostring(row.locations)) or {}
			local items = fromJSON(tostring(row.items)) or {}
			custom[row.faction_id] = custom[row.faction_id] or {}
			custom[row.faction_id][tonumber(row.id)] = { row.id, row.name, skins, locations, items }
			maxIndex = tonumber(row.id)
		end

		setElementData(resourceRoot, "maxcindex", maxIndex)
		setElementData(getResourceRootElement(getResourceFromName("mek_duty")), "factionDuty", custom)
	end, mysql:getConnection(), "SELECT * FROM duty_custom ORDER BY id ASC", id)

	local locationQ = dbQuery(function(locationQ)
		local result, rows = dbPoll(locationQ, 0)
		if not result or rows < 1 then
			dbFree(locationQ)
			return
		end

		for _, row in pairs(result) do
			locations[row.faction_id] = locations[row.faction_id] or {}
			locations[row.faction_id][tonumber(row.id)] = {
				row.id,
				row.name,
				row.x,
				row.y,
				row.z,
				row.radius,
				row.dimension,
				row.interior,
				row.vehicle_id,
				row.model,
			}
			if not tonumber(row.model) then
				exports.mek_duty:createDutyColShape(
					row.x,
					row.y,
					row.z,
					row.radius,
					row.interior,
					row.dimension,
					row.faction_id,
					row.id
				)
			end
			maxIndex = tonumber(row.id)
		end

		setElementData(resourceRoot, "maxlindex", maxIndex)
		setElementData(getResourceRootElement(getResourceFromName("mek_duty")), "factionLocations", locations)
	end, mysql:getConnection(), "SELECT * FROM duty_locations ORDER BY id ASC", id)

	local citizenTeam = createTeam("Vatandaş", 255, 255, 255)
	exports.mek_pool:allocateElement(citizenTeam, -1)

	for i, player in ipairs(getElementsByType("player")) do
		dbQuery(
			function(qh)
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

					setElementData(player, "faction", playerFactions)
				else
					setElementData(player, "faction", {})
					dbFree(qh)
				end
			end,
			mysql:getConnection(),
			"SELECT * FROM characters_faction WHERE character_id = ? ORDER BY id ASC",
			getElementData(player, "dbid")
		)

		setPlayerTeam(player, citizenTeam)
		setElementData(player, "faction_menu", false)

		if not (isKeyBound(player, "F3", "down", showFactionMenu)) then
			bindKey(player, "F3", "down", showFactionMenu)
		end
	end
end
addEventHandler("onResourceStart", resourceRoot, loadAllFactions)

function bindKeysOnJoin()
	bindKey(source, "F3", "down", showFactionMenu)
end
addEventHandler("onPlayerJoin", root, bindKeysOnJoin)

function showFactionMenu(source)
	showFactionMenuEx(source)
end
addCommandHandler("faction", showFactionMenu)

function showFactionMenuEx(source, factionID, fromShowF)
	if getElementData(source, "logged") then
		if not getElementData(source, "faction_menu") then
			if not factionID then
				local organizedTable = {}

				for i, k in pairs(getElementData(source, "faction")) do
					organizedTable[k.count] = i
				end
				factionID = organizedTable[1]
			end
			if factionID then
				local theTeam = exports.mek_pool:getElementByID("team", factionID)
				local query = dbQuery(
					mysql:getConnection(),
					"SELECT characters.name, characters_faction.faction_rank, characters_faction.faction_perks, characters_faction.faction_leader, characters_faction.faction_phone, DATEDIFF(NOW(), characters.last_login) AS last_login FROM characters_faction INNER JOIN characters ON characters.id=characters_faction.character_id WHERE characters_faction.faction_ID=? ORDER BY faction_rank DESC, name ASC",
					factionID
				)
				local result, rows = dbPoll(query, 10000)
				if result then
					local memberUsernames = {}
					local memberRanks = {}
					local memberLeaders = {}
					local memberOnline = {}
					local memberLastLogin = {}
					local memberPerks = {}
					local rankOrder = getElementData(theTeam, "rank_order") or ""
					local factionRanks = getElementData(theTeam, "ranks")
					local factionWages = getElementData(theTeam, "wages")
					local motd = getElementData(theTeam, "motd")
					local note = getElementData(theTeam, "note")
					local fnote = getElementData(theTeam, "fnote")
					local vehicleIDs = {}
					local vehicleModels = {}
					local vehiclePlates = {}
					local vehicleLocations = {}
					local properties = {}
					local memberOnDuty = {}
					local phone = getElementData(theTeam, "phone")
					local memberPhones = phone and {} or nil

					if motd == "" then
						motd = nil
					end

					if motd == "" then
						motd = nil
					end

					if rankOrder == "" then
						rankOrder = table.concat(getFactionRanks(tonumber(factionID), false), ",")
						setElementData(theTeam, "rank_order", rankOrder)
					end

					local factionRanksTbl = {}
					local factionRankID = {}
					local rankOrder = split(rankOrder, ",")
					
					-- factionRanks nil kontrolü ekle
					if not factionRanks then
						factionRanks = {}
					end
					
					for i, rankID in ipairs(rankOrder) do
						local rankID = tonumber(rankID)
						if factionRanks[rankID] then
							factionRanksTbl[rankID] = factionRanks[rankID]
							factionRankID[factionRanks[rankID]] = rankID
						end
					end

					-- START: Fix for invisible members (ensure all ranks are in rankOrder)
					local allRanks = getFactionRanks(tonumber(factionID), false)
					if allRanks then
						local rankSet = {}
						for _, rID in ipairs(rankOrder) do
							if tonumber(rID) then
								rankSet[tonumber(rID)] = true
							end
						end

						for _, rID in ipairs(allRanks) do
							local nID = tonumber(rID)
							if nID and not rankSet[nID] then
								table.insert(rankOrder, tostring(nID))
								
								-- Also make sure it's in the rank tables
								if factionRanks[nID] then
									factionRanksTbl[nID] = factionRanks[nID]
									factionRankID[factionRanks[nID]] = nID
								end
							end
						end
					end
					-- END: Fix

					local i = 1
					for _, row in ipairs(result) do
						local playerName = row.name
						memberUsernames[i] = playerName
						memberRanks[i] = row.faction_rank
						memberPerks[i] = type(row.faction_perks) == "string" and fromJSON(row.faction_perks) or {}
						if phone and row.faction_phone ~= nil and tonumber(row.faction_phone) then
							memberPhones[i] = ("%02d"):format(tonumber(row.faction_phone))
						end

						if tonumber(row.faction_leader) == 1 then
							memberLeaders[i] = true
						else
							memberLeaders[i] = false
						end

						local login = ""

						memberLastLogin[i] = tonumber(row.last_login)
						if getPlayerFromName(playerName) then
							local testingPlayer = getPlayerFromName(playerName)
							if getElementData(testingPlayer, "logged") then
								memberOnline[i] = true

								local dutydata = getCurrentFactionDuty(testingPlayer)
								memberOnDuty[i] = (dutydata == factionID)
							end
						else
							memberOnline[i] = false
							memberOnDuty[i] = false
						end
						i = i + 1
					end

					if hasMemberPermissionTo(source, factionID, "respawn_vehs") then
						local vehicleQuery = dbQuery(
							mysql:getConnection(),
							"SELECT id, model, plate FROM vehicles WHERE faction=? AND deleted=0",
							factionID
						)
						local vehResult, rows = dbPoll(vehicleQuery, 10000)
						if vehResult then
							local j = 1
							for _, row in ipairs(vehResult) do
								local veh = exports.mek_pool:getElementByID("vehicle", row.id)
								vehicleIDs[j] = row.id
								vehiclePlates[j] = row.plate
								vehicleModels[j] = exports.mek_global:getVehicleName(veh)
								vehicleLocations[j] = exports.mek_global:getElementZoneName(veh)
								j = j + 1
							end
						else
							dbFree(vehicleQuery)
						end

						local interiorQuery = dbQuery(
							mysql:getConnection(),
							"SELECT id, name FROM interiors WHERE faction=? AND deleted='0' AND disabled=0",
							factionID
						)
						local interiorResult, rows = dbPoll(interiorQuery, 10000)
						if interiorResult then
							local j = 1
							for _, row in ipairs(interiorResult) do
								local int = exports.mek_pool:getElementByID("interior", row.id)
								properties[j] = { row.id, row.name }
								properties[j][3] = exports.mek_global:getElementZoneName(int)
								j = j + 1
							end
						else
							dbFree(interiorQuery)
						end
					end

					setElementData(source, "faction_menu", true)

					triggerClientEvent(
						source,
						"showFactionMenu",
						source,
						motd,
						memberUsernames,
						memberRanks,
						memberPerks or {},
						memberLeaders,
						memberOnline,
						memberLastLogin,
						factionRanksTbl,
						factionWages,
						theTeam,
						note,
						fnote,
						vehicleIDs,
						vehicleModels,
						vehiclePlates,
						vehicleLocations,
						memberOnDuty,
						phone,
						memberPhones,
						fromShowF,
						factionID,
						properties,
						factionRankID,
						rankOrder
					)
				else
					dbFree(query)
				end
			else
				outputChatBox("[!]#FFFFFF Hiç bir birlikde değilsiniz.", source, 255, 0, 0, true)
			end
		else
			triggerClientEvent(source, "hideFactionMenu", source)
		end
	end
end

function loadFaction(factionID)
	local theTeam = exports.mek_pool:getElementByID("team", factionID)
	if theTeam then
		local theTeam = exports.mek_pool:getElementByID("team", factionID)
		local query = dbQuery(
			mysql:getConnection(),
			"SELECT characters.name, characters_faction.faction_rank, characters_faction.faction_perks, characters_faction.faction_leader, characters_faction.faction_phone, DATEDIFF(NOW(), characters.last_login) AS last_login FROM characters_faction INNER JOIN characters ON characters.id=characters_faction.character_id WHERE characters_faction.faction_ID=? ORDER BY faction_rank DESC, name ASC",
			factionID
		)
		local result, rows = dbPoll(query, 10000)
		if result then
			local memberUsernames = {}
			local memberRanks = {}
			local memberLeaders = {}
			local memberOnline = {}
			local memberLastLogin = {}
			local memberPerks = {}
			local rankOrder = getElementData(theTeam, "rank_order") or ""
			local factionRanks = getElementData(theTeam, "ranks")
			local factionWages = getElementData(theTeam, "wages")
			local motd = getElementData(theTeam, "motd")
			local note = getElementData(theTeam, "note")
			local fnote = getElementData(theTeam, "fnote")
			local vehicleIDs = {}
			local vehicleModels = {}
			local vehiclePlates = {}
			local vehicleLocations = {}
			local properties = {}
			local memberOnDuty = {}
			local phone = getElementData(theTeam, "phone")
			local memberPhones = phone and {} or nil

			if motd == "" then
				motd = nil
			end

			if rankOrder == "" then
				rankOrder = table.concat(getFactionRanks(tonumber(factionID), false), ",")
				setElementData(theTeam, "rank_order", rankOrder)
			end

			local factionRanksTbl = {}
			local factionRankID = {}
			local rankOrder = split(rankOrder, ",")
			
			-- factionRanks nil kontrolü ekle
			if not factionRanks then
				factionRanks = {}
			end
			
			for i, rankID in ipairs(rankOrder) do
				local rankID = tonumber(rankID)
				if factionRanks[rankID] then
					factionRanksTbl[rankID] = factionRanks[rankID]
					factionRankID[factionRanks[rankID]] = rankID
				end
			end

			local i = 1
			for _, row in ipairs(result) do
				local playerName = row.name
				memberUsernames[i] = playerName
				memberRanks[i] = row.faction_rank
				memberPerks[i] = type(row.faction_perks) == "string" and fromJSON(row.faction_perks) or {}
				if phone and row.faction_phone ~= nil and tonumber(row.faction_phone) then
					memberPhones[i] = ("%02d"):format(tonumber(row.faction_phone))
				end

				if tonumber(row.faction_leader) == 1 then
					memberLeaders[i] = true
				else
					memberLeaders[i] = false
				end

				local login = ""

				memberLastLogin[i] = tonumber(row.last_login)
				if getPlayerFromName(playerName) then
					local testingPlayer = getPlayerFromName(playerName)
					if getElementData(testingPlayer, "logged") then
						memberOnline[i] = true

						local dutydata = getCurrentFactionDuty(testingPlayer)
						if dutydata == factionID then
							if tonumber(dutydata) > 0 then
								memberOnDuty[i] = true
							else
								memberOnDuty[i] = false
							end
						else
							memberOnDuty[i] = false
						end
					end
				else
					memberOnline[i] = false
					memberOnDuty[i] = false
				end
				i = i + 1
			end

			if hasMemberPermissionTo(client, factionID, "respawn_vehs") then
				local vehicleQuery = dbQuery(
					mysql:getConnection(),
					"SELECT id, model, plate FROM vehicles WHERE faction=? AND deleted=0",
					factionID
				)
				local vehResult, rows = dbPoll(vehicleQuery, 10000)
				if vehResult then
					local j = 1
					for _, row in ipairs(vehResult) do
						local veh = exports.mek_pool:getElementByID("vehicle", row.id)
						vehicleIDs[j] = row.id
						vehiclePlates[j] = row.plate
						vehicleModels[j] = exports.mek_global:getVehicleName(veh)
						vehicleLocations[j] = exports.mek_global:getElementZoneName(veh)
						j = j + 1
					end
				else
					dbFree(vehicleQuery)
				end

				local interiorQuery = dbQuery(
					mysql:getConnection(),
					"SELECT id, name FROM interiors WHERE faction=? AND deleted='0' AND disabled=0",
					factionID
				)
				local interiorResult, rows = dbPoll(interiorQuery, 10000)
				if interiorResult then
					local j = 1
					for _, row in ipairs(interiorResult) do
						local int = exports.mek_pool:getElementByID("interior", row.id)
						properties[j] = { row.id, row.name }
						properties[j][3] = exports.mek_global:getElementZoneName(int)
						j = j + 1
					end
				else
					dbFree(interiorQuery)
				end
			end

			triggerClientEvent(
				client,
				"faction.fillFactionMenu",
				resourceRoot,
				motd,
				memberUsernames,
				memberRanks,
				memberPerks or {},
				memberLeaders,
				memberOnline,
				memberLastLogin,
				factionRanksTbl,
				factionWages,
				theTeam,
				note,
				fnote,
				vehicleIDs,
				vehicleModels,
				vehiclePlates,
				vehicleLocations,
				memberOnDuty,
				phone,
				memberPhones,
				fromShowF,
				factionID,
				properties,
				factionRankID,
				rankOrder
			)
		else
			dbFree(query)
		end
	else
		outputChatBox("[!]#FFFFFF Birliği bulmada hata oluştu.", client, 255, 0, 0, true)
	end
end
addEvent("faction.loadFaction", true)
addEventHandler("faction.loadFaction", resourceRoot, loadFaction)

function callbackRespawnVehicles(factionID)
	local theTeam = getFactionFromID(factionID)
	local factionCooldown = getElementData(theTeam, "cooldown")
	if not hasMemberPermissionTo(client, factionID, "respawn_vehs") then
		outputChatBox("[!]#FFFFFF Yeterli izniniz yok.", client, 255, 0, 0, true)
		return
	end

	if not factionCooldown then
		for key, value in ipairs(exports.mek_pool:getPoolElementsByType("vehicle")) do
			local faction = getElementData(value, "faction")
			if
				faction == factionID
				and not getVehicleOccupant(value, 0)
				and not getVehicleOccupant(value, 1)
				and not getVehicleOccupant(value, 2)
				and not getVehicleOccupant(value, 3)
				and not getVehicleTowingVehicle(value)
			then
				respawnVehicle(value)
				setElementInterior(value, getElementData(value, "interior"))
				setElementDimension(value, getElementData(value, "dimension"))
				setVehicleLocked(value, true)
				setElementData(value, "engine_broke", false)
				setElementData(value, "handbrake", true)
				removeElementData(value, "i:left")
				removeElementData(value, "i:right")
				setTimer(setElementFrozen, 2000, 1, value, true)

				if exports.mek_vehicle:getArmoredCars()[getElementModel(value)] then
					setVehicleDamageProof(value, true)
				else
					setVehicleDamageProof(value, false)
				end
			end
		end

		local teamPlayers = getPlayersInFaction(factionID)
		for _, player in ipairs(teamPlayers) do
			outputChatBox(
				">> Tüm birlik araçları " .. getPlayerName(source):gsub("_", " ") .. " tarafından yenilendi.",
				player,
				255,
				194,
				14
			)
		end

		setTimer(resetFactionCooldown, 60000, 1, theTeam)
		setElementData(theTeam, "cooldown", true)
	else
		outputChatBox(
			"[!]#FFFFFF Şu anda birlik araçlarınızı yenileyemessiniz, lütfen bir süre bekleyin.",
			source,
			255,
			0,
			0,
			true
		)
	end
end
addEvent("cguiRespawnVehicles", true)
addEventHandler("cguiRespawnVehicles", root, callbackRespawnVehicles)

function resetFactionCooldown(theTeam)
	removeElementData(theTeam, "cooldown")
end

function callbackRespawnOneVehicle(vehicleID, factionID)
	local theTeam = getFactionFromID(factionID)
	local theVehicle = exports.mek_pool:getElementByID("vehicle", tonumber(vehicleID))
	if not hasMemberPermissionTo(client, factionID, "respawn_vehs") then
		outputChatBox("[!]#FFFFFF Yeterli izniniz yok.", source, 255, 0, 0, true)
		return
	end

	if theVehicle then
		local theVehicleID = getElementData(theVehicle, "faction")
		if
			factionID == theVehicleID
			and not getVehicleOccupant(theVehicle, 0)
			and not getVehicleOccupant(theVehicle, 1)
			and not getVehicleOccupant(theVehicle, 2)
			and not getVehicleOccupant(theVehicle, 3)
			and not getVehicleTowingVehicle(theVehicle)
		then
			if isElementAttached(theVehicle) then
				detachElements(theVehicle)
			end

			respawnVehicle(theVehicle)
			setElementInterior(theVehicle, getElementData(theVehicle, "interior"))
			setElementDimension(theVehicle, getElementData(theVehicle, "dimension"))
			setVehicleLocked(theVehicle, true)
			setElementData(theVehicle, "engine_broke", false)
			setElementData(theVehicle, "handbrake", true)
			removeElementData(theVehicle, "i:left")
			removeElementData(theVehicle, "i:right")
			setTimer(setElementFrozen, 2000, 1, theVehicle, true)

			if exports.mek_vehicle:getArmoredCars()[getElementModel(theVehicle)] then
				setVehicleDamageProof(theVehicle, true)
			else
				setVehicleDamageProof(theVehicle, false)
			end

			local teamPlayers = getPlayersInFaction(factionID)
			for _, player in ipairs(teamPlayers) do
				outputChatBox(
					">> "
						.. vehicleID
						.. " ID'li araç "
						.. getPlayerName(source):gsub("_", " ")
						.. " tarafından yenilendi.",
					player,
					255,
					194,
					14
				)
			end
		else
			outputChatBox("[!]#FFFFFF Şu anda bu araç dolu.", source, 255, 0, 0, true)
		end
	else
		outputChatBox("[!]#FFFFFF Lütfen yenilemek istediğiniz aracı seçin.", source, 255, 0, 0, true)
	end
end
addEvent("cguiRespawnOneVehicle", true)
addEventHandler("cguiRespawnOneVehicle", root, callbackRespawnOneVehicle)

function callbackUpdateMOTD(motd, factionID)
	local theTeam = getFactionFromID(factionID)
	if not hasMemberPermissionTo(client, factionID, "edit_motd") then
		outputChatBox("[!]#FFFFFF Yeterli izniniz yok.", client, 255, 0, 0, true)
		return
	end

	if factionID ~= -1 then
		if dbExec(mysql:getConnection(), "UPDATE factions SET motd = ? WHERE id = ?", motd, factionID) then
			outputChatBox(
				"[!]#FFFFFF Birliğinizin MOTD'sini '" .. motd .. "' olarak değiştirdiniz.",
				client,
				0,
				255,
				0,
				true
			)
			setElementData(theTeam, "motd", motd)
		end
	end
end
addEvent("cguiUpdateMOTD", true)
addEventHandler("cguiUpdateMOTD", root, callbackUpdateMOTD)

function callbackUpdateNote(note, factionID)
	local theTeam = getFactionFromID(factionID)
	if not hasMemberPermissionTo(client, factionID, "modify_factionl_note") or not note then
		outputChatBox("[!]#FFFFFF Yeterli izniniz yok.", client, 255, 0, 0, true)
		return
	end

	if factionID ~= -1 then
		if dbExec(mysql:getConnection(), "UPDATE factions SET note = ? WHERE id = ?", note, factionID) then
			outputChatBox("[!]#FFFFFF Birliğinizin notunu başarıyla değiştirdiniz.", client, 0, 255, 0, true)
			setElementData(theTeam, "note", note)
		end
	end
end
addEvent("faction.note", true)
addEventHandler("faction.note", root, callbackUpdateNote)

function callbackUpdateFNote(fnote, factionID)
	local theTeam = getFactionFromID(factionID)
	if not hasMemberPermissionTo(client, factionID, "modify_faction_note") or not fnote then
		outputChatBox("[!]#FFFFFF Yeterli izniniz yok.", client, 255, 0, 0, true)
		return
	end

	if factionID ~= -1 then
		if dbExec(mysql:getConnection(), "UPDATE factions SET fnote=? WHERE id=?", fnote, factionID) then
			outputChatBox("[!]#FFFFFF Birliğinizin lider notunu başarıyla değiştirdiniz.", client, 0, 255, 0, true)
			setElementData(theTeam, "fnote", fnote)
		end
	end
end
addEvent("faction.fnote", true)
addEventHandler("faction.fnote", root, callbackUpdateFNote)

function callbackRemovePlayer(removedPlayerName, factionID)
	local theTeam = getFactionFromID(factionID)
	if not hasMemberPermissionTo(client, factionID, "del_member") then
		outputChatBox("[!]#FFFFFF Yeterli izniniz yok.", client, 255, 0, 0, true)
		return
	end

	local _, factionDetails, removedPlayer = getPlayerFactions(removedPlayerName)
	
	-- Oyuncu online ve birlikte değilse hata ver
	if removedPlayer then
		if not factionDetails or not factionDetails[factionID] then
			outputChatBox("[!]#FFFFFF Bu oyuncu bu birlikte değil.", client, 255, 0, 0, true)
			return
		end
	end

	if
		dbExec(
			mysql:getConnection(),
			"DELETE FROM characters_faction WHERE character_id = (SELECT id FROM characters WHERE name = ?) AND faction_id = ?",
			removedPlayerName,
			factionID
		)
	then
		local theTeamName = "Hiçbiri"
		if theTeam then
			theTeamName = getTeamName(theTeam)
		end

		local username = getPlayerName(client)

		if removedPlayer then
			if getElementData(removedPlayer, "faction_menu") then
				triggerClientEvent(removedPlayer, "hideFactionMenu", root)
			end

			outputChatBox(
				"[!]#FFFFFF "
					.. username:gsub("_", " ")
					.. " isimli oyuncu seni '"
					.. tostring(theTeamName)
					.. "' birliğinden çıkardı.",
				removedPlayer,
				255,
				0,
				0,
				true
			)

			local organizedTable = {}
			for i, k in pairs(factionDetails) do
				organizedTable[k.count] = i
			end

			local found = false
			for k, v in ipairs(organizedTable) do
				if v == factionID then
					found = true
				end
				if found then
					factionDetails[v].count = factionDetails[v].count - 1
				end
			end

			factionDetails[factionID] = nil
			setElementData(removedPlayer, "faction", factionDetails)
			triggerEvent("duty.offDuty", removedPlayer)
		end

		sendMessageToAllFactionMembers(
			factionID,
			removedPlayerName:gsub("_", " ")
				.. " isimli oyuncu '"
				.. tostring(theTeamName)
				.. "' birliğinden çıkarıldı. Çıkaran: "
				.. username:gsub("_", " ")
				.. "."
		)
	else
		outputChatBox(
			"[!]#FFFFFF "
				.. removedPlayerName:gsub("_", " ")
				.. " isimli oyuncu birlikten çıkarılamadı, lütfen bir yetkili ile iletişime geçin.",
			source,
			255,
			0,
			0,
			true
		)
	end
end
addEvent("cguiKickPlayer", true)
addEventHandler("cguiKickPlayer", root, callbackRemovePlayer)

function callbackPerkEdit(perkIDTable, playerName, factionID)
	if not hasMemberPermissionTo(client, factionID, "set_member_duty") then
		outputChatBox("[!]#FFFFFF Yeterli izniniz yok.", client, 255, 0, 0, true)
		return
	end

	local _, factionInfo, targetPlayer = getPlayerFactions(playerName)
	if targetPlayer and not factionInfo[factionID] then
		outputChatBox("[!]#FFFFFF Bir sorun oluştu.", client, 255, 0, 0, true)
		return
	end

	local jsonPerkIDTable = toJSON(perkIDTable)
	if
		dbExec(
			mysql:getConnection(),
			"UPDATE `characters_faction` SET `faction_perks` = ? WHERE character_id = (SELECT id FROM characters WHERE name = ?) AND faction_id = ?",
			jsonPerkIDTable,
			playerName,
			factionID
		)
	then
		outputChatBox(
			"[!]#FFFFFF " .. playerName:gsub("_", " ") .. " isimli oyuncunun görev ayrıcalıkları güncellendi.",
			client,
			0,
			255,
			0,
			true
		)
		if targetPlayer then
			factionInfo[factionID].perks = perkIDTable
			setElementData(targetPlayer, "faction", factionInfo)
			outputChatBox(
				"[!]#FFFFFF Görev ayrıcalıklarınız "
					.. getPlayerName(client):gsub("_", " ")
					.. " isimli oyuncu tarafından güncellendi.",
				targetPlayer,
				0,
				255,
				0,
				true
			)
		end
	end
end
addEvent("faction.perks:edit", true)
addEventHandler("faction.perks:edit", root, callbackPerkEdit)

function callbackQuitFaction(factionID)
	local theTeam = getFactionFromID(factionID)
	local username = getPlayerName(client)
	local theTeamName = getTeamName(theTeam)

	if
		dbExec(
			mysql:getConnection(),
			"DELETE FROM characters_faction WHERE character_id = ? AND faction_id = ?",
			getElementData(client, "dbid"),
			factionID
		)
	then
		outputChatBox("[!]#FFFFFF '" .. theTeamName .. "' birliğinden ayrıldınız.", client, 255, 0, 0, true)

		local factionInfo = getElementData(client, "faction")
		local organizedTable = {}

		for i, k in pairs(factionInfo) do
			organizedTable[k.count] = i
		end

		local found = false
		for k, v in ipairs(organizedTable) do
			if v == factionID then
				found = true
			end
			if found then
				factionInfo[v].count = factionInfo[v].count - 1
			end
		end

		factionInfo[factionID] = nil
		setElementData(client, "faction", factionInfo)
		triggerEvent("duty.offDuty", client)

		sendMessageToAllFactionMembers(
			factionID,
			username:gsub("_", " ") .. " isimli oyuncu '" .. theTeamName .. "' birliğinizden ayrıldı."
		)
	else
		outputChatBox(
			"[!]#FFFFFF Birlikten ayrılma işlemi başarısız oldu, lütfen bir yetkili ile iletişime geçin.",
			client,
			255,
			0,
			0,
			true
		)
	end
end
addEvent("cguiQuitFaction", true)
addEventHandler("cguiQuitFaction", root, callbackQuitFaction)

function callbackInvitePlayer(invitedPlayer, factionID)
	local theTeam = getFactionFromID(factionID)
	if not getElementData(invitedPlayer, "logged") then
		outputChatBox("[!]#FFFFFF Yeterli izniniz yok.", client, 255, 0, 0, true)
		return
	end

	local invitedPlayerNick = getPlayerName(invitedPlayer)
	local factionInfo = getElementData(invitedPlayer, "faction")
	local defaultRank = getDefaultRank(factionID)
	local count = 0

	for _ in pairs(factionInfo) do
		count = count + 1
	end

	if count >= 3 then
		outputChatBox(
			"[!]#FFFFFF Bu oyuncu maksimum sayıda birliğe katıldı, başka birliğe katılamaz.",
			client,
			255,
			0,
			0,
			true
		)

		return
	elseif isPlayerInFaction(invitedPlayer, factionID) then
		outputChatBox("[!]#FFFFFF Bu oyuncu zaten bu birliğin üyesi.", client, 255, 0, 0, true)
		return
	end

	if
		dbExec(
			mysql:getConnection(),
			"INSERT INTO characters_faction SET faction_leader = 0, faction_id = ?, faction_rank = ?, character_id = ?",
			factionID,
			defaultRank,
			getElementData(invitedPlayer, "dbid")
		)
	then
		local theTeamName = getTeamName(theTeam)

		local max = 0
		for id, _ in pairs(factionInfo) do
			if not max then
				max = _.count
			end
			if _.count >= max then
				max = _.count
			end
		end

		factionInfo[factionID] = { rank = defaultRank, leader = false, phone = nil, perks = { {} }, count = max + 1 }
		setElementData(invitedPlayer, "faction", factionInfo)

		outputChatBox(
			"[!]#FFFFFF "
				.. invitedPlayerNick:gsub("_", " ")
				.. " isimli oyuncuyu '"
				.. tostring(theTeamName)
				.. "' birliğinize aldınız.",
			client,
			0,
			255,
			0,
			true
		)
		sendMessageToAllFactionMembers(
			factionID,
			invitedPlayerNick:gsub("_", " ")
				.. " isimli oyuncu '"
				.. tostring(theTeamName)
				.. "' birliğinize yeni üye olarak katıldı."
		)
		outputChatBox(
			"[!]#FFFFFF '" .. tostring(theTeamName) .. "' birliğine üye olarak eklendiniz.",
			invitedPlayer,
			0,
			255,
			0,
			true
		)
	else
		outputChatBox("[!]#FFFFFF Bu oyuncu zaten bu birliğe üye.", client, 255, 0, 0, true)
	end
end
addEvent("cguiInvitePlayer", true)
addEventHandler("cguiInvitePlayer", root, callbackInvitePlayer)

function hideFactionMenu()
	setElementData(client, "faction_menu", false)
end
addEvent("faction.hide", true)
addEventHandler("faction.hide", root, hideFactionMenu)

addEvent("faction.setPhone", true)
addEventHandler("faction.setPhone", root, function(playerName, number, factionID)
	local theTeam = getFactionFromID(factionID)

	local _, factionInfo, thePlayer = getPlayerFactions(playerName)
	if thePlayer and not factionInfo[factionID] then
		outputChatBox("[!]#FFFFFF Bir sorun oluştu.", client, 255, 0, 0, true)
		return
	end

	local username = getPlayerName(client)
	local number = tonumber(number) or "NULL"

	local success = false
	if tonumber(number) then
		success = dbExec(
			mysql:getConnection(),
			"UPDATE characters_faction SET faction_phone=? WHERE character_id=(SELECT id FROM characters WHERE name=?) AND faction_id=?",
			number,
			playerName,
			factionID
		)
	else
		success = dbExec(
			mysql:getConnection(),
			"UPDATE characters_faction SET faction_phone=NULL WHERE character_id=(SELECT id FROM characters WHERE name=?) AND faction_id=?",
			playerName,
			factionID
		)
	end

	if success then
		local thePlayer = getPlayerFromName(playerName)
		if thePlayer then
			factionInfo[factionID].phone = tonumber(number) or nil
			setElementData(thePlayer, "faction", factionInfo)
		end
	end
end)

addEvent("fetchDutyInfo", true)
addEventHandler("fetchDutyInfo", resourceRoot, function(factionID)
	if not factionID then
		return
	end

	local elementInfo = getElementData(resourceRoot, "duty_gui")
	elementInfo[client] = factionID
	setElementData(resourceRoot, "duty_gui", elementInfo)

	triggerClientEvent(
		client,
		"importDutyData",
		resourceRoot,
		custom[tonumber(factionID)],
		locations[tonumber(factionID)],
		factionID
	)
end)

addEvent("duty.grab", true)
addEventHandler("duty.grab", resourceRoot, function(factionID)
	if not factionID then
		return
	end

	local t = getAllowList(factionID)

	triggerClientEvent(client, "gotAllow", resourceRoot, t)
end)

addEvent("duty.getPackages", true)
addEventHandler("duty.getPackages", resourceRoot, function(factionID)
	factionID = tonumber(factionID)
	triggerClientEvent(client, "duty.gotPackages", resourceRoot, custom[factionID])
end)

function refreshClient(message, factionID, dontSendToClient)
	for k, v in pairs(getElementData(resourceRoot, "duty_gui")) do
		if dontSendToClient then
			if v == factionID and k ~= dontSendToClient then
				triggerClientEvent(
					k,
					"importDutyData",
					resourceRoot,
					custom[tonumber(factionID)],
					locations[tonumber(factionID)],
					factionID,
					message
				)
			end
		else
			if v == factionID then
				triggerClientEvent(
					k,
					"importDutyData",
					resourceRoot,
					custom[tonumber(factionID)],
					locations[tonumber(factionID)],
					factionID,
					message
				)
			end
		end
	end

	local resource = getResourceRootElement(getResourceFromName("mek_duty"))
	if resource then
		setElementData(resource, "factionDuty", custom)
		setElementData(resource, "factionLocations", locations)
	end
end

function disconnectThem()
	local t = getElementData(resourceRoot, "duty_gui")
	t[source] = nil
	setElementData(resourceRoot, "duty_gui", t)
end

addEventHandler("onPlayerQuit", root, disconnectThem)

function addDuty(dutyItems, finalLocations, dutyNewSkins, name, factionID, dutyID)
	local dutyItems = dutyItems or {}
	local finalLocations = finalLocations or {}
	local dutyNewSkins = dutyNewSkins or {}

	if not custom[tonumber(factionID)] then
		custom[tonumber(factionID)] = {}
	end

	if dutyID == 0 then
		local index = getElementData(resourceRoot, "maxcindex") + 1
		dbExec(
			exports.mek_mysql:getConnection(),
			"INSERT INTO duty_custom (id, faction_id, name, skins, locations, items) VALUES (?, ?, ?, ?, ?, ?)",
			index,
			factionID,
			name,
			toJSON(dutyNewSkins),
			toJSON(finalLocations),
			toJSON(dutyItems)
		)
		setElementData(resourceRoot, "maxcindex", index)

		custom[tonumber(factionID)][index] = { index, name, dutyNewSkins, finalLocations, dutyItems }

		refreshClient(
			"> " .. getPlayerName(client):gsub("_", " ") .. " isimli oyuncu '" .. name .. "' görevini ekledi.",
			factionID,
			false
		)
	else
		dbExec(
			exports.mek_mysql:getConnection(),
			"UPDATE duty_custom SET name = ?, skins = ?, locations = ?, items = ? WHERE id = ?",
			name,
			toJSON(dutyNewSkins),
			toJSON(finalLocations),
			toJSON(dutyItems),
			dutyID
		)

		table.remove(custom[tonumber(factionID)], dutyID)
		custom[tonumber(factionID)][dutyID] = { dutyID, name, dutyNewSkins, finalLocations, dutyItems }

		refreshClient(
			"> "
				.. getPlayerName(client):gsub("_", " ")
				.. " isimli oyuncu görev ID #"
				.. dutyID
				.. " üzerinde değişiklik yaptı.",
			factionID,
			false
		)
	end
end

addEvent("duty.addDuty", true)
addEventHandler("duty.addDuty", resourceRoot, addDuty)

function addLocation(x, y, z, r, i, d, name, factionID, index)
	local interiorElement = exports.mek_pool:getElementByID("interior", d) or d == 0
	if interiorElement then
		local interiorF = 0
		if isElement(interiorElement) then
			interiorStatus = getElementData(interiorElement, "status")
			interiorF = interiorStatus.faction
		end

		if tonumber(interiorF) == tonumber(factionID) or d == 0 then
			if not locations[tonumber(factionID)] then
				locations[tonumber(factionID)] = {}
			end

			if not index then
				local newIndex = getElementData(resourceRoot, "maxlindex") + 1
				dbExec(
					exports.mek_mysql:getConnection(),
					"INSERT INTO duty_locations (id, faction_id, name, x, y, z, radius, dimension, interior) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
					newIndex,
					factionID,
					name,
					x,
					y,
					z,
					r,
					d,
					i
				)
				setElementData(resourceRoot, "maxlindex", newIndex)
				exports.mek_duty:createDutyColShape(x, y, z, r, i, d, factionID, newIndex)
				locations[tonumber(factionID)][newIndex] = { newIndex, name, x, y, z, r, d, i, nil, nil }
				refreshClient(
					"> " .. getPlayerName(client):gsub("_", " ") .. " isimli oyuncu '" .. name .. "' konumunu ekledi.",
					factionID,
					false
				)
			else
				dbExec(
					exports.mek_mysql:getConnection(),
					"UPDATE duty_locations SET name = ?, x = ?, y = ?, z = ?, radius = ?, dimension = ?, interior = ? WHERE id = ?",
					name,
					x,
					y,
					z,
					r,
					d,
					i,
					index
				)
				table.remove(locations[factionID], index)
				exports.mek_duty:destroyDutyColShape(factionID, index)
				exports.mek_duty:createDutyColShape(x, y, z, r, i, d, factionID, index)
				locations[tonumber(factionID)][index] = { index, name, x, y, z, r, d, i, nil, nil }
				refreshClient(
					"> "
						.. getPlayerName(client):gsub("_", " ")
						.. " isimli oyuncu konum ID #"
						.. index
						.. " üzerinde değişiklik yaptı.",
					factionID,
					false
				)
			end
		else
			outputChatBox("[!]#FFFFFF Eklemek istediğiniz mülk, birliğe ait olmalıdır.", client, 255, 0, 0, true)
		end
	else
		outputChatBox("[!]#FFFFFF Böyle bir mülk bulunamadı.", client, 255, 0, 0, true)
	end
end
addEvent("duty.addLocation", true)
addEventHandler("duty.addLocation", resourceRoot, addLocation)

function addVehicle(vehicleID, factionID)
	local element = exports.mek_pool:getElementByID("vehicle", vehicleID)
	if element then
		if getElementData(element, "faction") == factionID then
			local newIndex = getElementData(resourceRoot, "maxlindex") + 1
			dbExec(
				exports.mek_mysql:getConnection(),
				"INSERT INTO duty_locations (id, faction_id, name, vehicle_id, model) VALUES (?, ?, ?, ?, ?)",
				newIndex,
				factionID,
				"ARAÇ",
				vehicleID,
				getElementModel(element)
			)
			setElementData(resourceRoot, "maxlindex", newIndex)
			if not locations[tonumber(factionID)] then
				locations[tonumber(factionID)] = {}
			end
			locations[tonumber(factionID)][newIndex] = {
				newIndex,
				"ARAÇ",
				nil,
				nil,
				nil,
				nil,
				nil,
				nil,
				tonumber(vehicleID),
				getElementModel(element),
			}
			refreshClient(
				"> " .. getPlayerName(client):gsub("_", " ") .. " isimli oyuncu araç #" .. vehicleID .. " ekledi.",
				factionID,
				false
			)
		else
			outputChatBox(
				"[!]#FFFFFF Sadece birlik araçlarını görev noktası olarak ekleyebilirsiniz.",
				client,
				255,
				0,
				0,
				true
			)
		end
	else
		outputChatBox("[!]#FFFFFF Böyle bir araç bulunamadı.", client, 255, 0, 0, true)
	end
end
addEvent("duty.addVehicle", true)
addEventHandler("duty.addVehicle", resourceRoot, addVehicle)

function removeLocation(removeID, factionID)
	locations[tonumber(factionID)][tonumber(removeID)] = nil
	exports.mek_duty:destroyDutyColShape(factionID, removeID)
	dbExec(exports.mek_mysql:getConnection(), "DELETE FROM duty_locations WHERE id = ?", removeID)
	refreshClient(
		"> " .. getPlayerName(client):gsub("_", " ") .. " isimli oyuncu konum #" .. removeID .. " kaldırdı.",
		factionID,
		client
	)
end
addEvent("duty.removeLocation", true)
addEventHandler("duty.removeLocation", resourceRoot, removeLocation)

function removeDuty(removeID, factionID)
	custom[tonumber(factionID)][tonumber(removeID)] = nil
	dbExec(exports.mek_mysql:getConnection(), "DELETE FROM duty_custom WHERE id = ?", removeID)
	refreshClient(
		"> " .. getPlayerName(client):gsub("_", " ") .. " isimli oyuncu görev #" .. removeID .. " kaldırdı.",
		factionID,
		client
	)
end

addEvent("duty.removeDuty", true)
addEventHandler("duty.removeDuty", resourceRoot, removeDuty)

addCommandHandler("gotoduty", function(player, command, id)
	if not exports.mek_integration:isPlayerTrialAdmin(player) then
		return
	end

	if not id then
		outputChatBox("Kullanım: /" .. command .. " [Görev Noktası ID]", player, 255, 194, 14)
		return
	end

	local query = dbQuery(
		exports.mek_mysql:getConnection(),
		"SELECT name, x, y, z, dimension, interior FROM duty_locations WHERE id = ? LIMIT 1",
		tonumber(id)
	)
	local result = dbPoll(query, -1)

	if result and #result == 1 then
		local location = result[1]
		setElementDimension(player, tonumber(location.dimension))
		setElementInterior(player, tonumber(location.interior))
		setElementPosition(player, tonumber(location.x), tonumber(location.y), tonumber(location.z))
		outputChatBox(
			"[!]#FFFFFF '" .. location.name .. "' görev noktasına ışınlandınız.",
			player,
			100,
			255,
			100,
			true
		)
	else
		outputChatBox(
			"[!]#FFFFFF ID #" .. tostring(id) .. " ile eşleşen görev noktası bulunamadı.",
			player,
			255,
			100,
			100,
			true
		)
	end
end, false, false)

function allocateFactionRank(query)
	local factionRanks = {}
	local factionWages = {}

	if query then
		local theTeam = nil
		local pollResult = dbPoll(query, -1)
		if not pollResult then
			dbFree(query)
			return
		else
			for i, row in pairs(pollResult) do
				theTeam = getFactionFromID(tonumber(row["faction_id"]))
				local rankID = tonumber(row.id)
				factionRanks[rankID] = row.name
				factionWages[rankID] = row.wage
			end

			setElementData(theTeam, "ranks", factionRanks)
			setElementData(theTeam, "wages", factionWages)
		end
	end

	dbFree(query)
end

addEvent("faction.showChangeRankGUI", true)
addEventHandler("faction.showChangeRankGUI", root, function(playerName, factionID)
	local factionID = tonumber(factionID)

	local ranks = {}
	local def_table

	local theTeam = getFactionFromID(factionID)
	local rankOrder = getElementData(theTeam, "rank_order") or ""
	rankOrder = split(rankOrder, ",")

	for i, rankID in ipairs(rankOrder) do
		local rankID = tonumber(rankID)
		local rankName = getRankName(rankID)
		table.insert(ranks, { rankID, rankName })
	end
	triggerClientEvent(client, "faction.showChangeRankGUI", resourceRoot, ranks, playerName, rankName)
end)

addEvent("faction.saveNewRank", true)
addEventHandler("faction.saveNewRank", root, function(playerName, oldRankName, newRankName, factionID)
	local fID = tonumber(factionID)
	if not fID then
		outputChatBox("[!]#FFFFFF Geçersiz birlik ID.", client, 255, 0, 0, true)
		return
	end
	
	-- Yetki kontrolü
	if not hasMemberPermissionTo(client, fID, "change_member_rank") then
		outputChatBox("[!]#FFFFFF Yeterli izniniz yok.", client, 255, 0, 0, true)
		return
	end
	
	local oldRankID = getFactionRankIDByName(fID, oldRankName)
	local newRankID = getFactionRankIDByName(fID, newRankName)
	
	-- Nil kontrolü - rank bulunamazsa hata ver
	if not newRankID then
		outputChatBox("[!]#FFFFFF Yeni rütbe bulunamadı: " .. tostring(newRankName), client, 255, 0, 0, true)
		return
	end
	
	local charID = exports.mek_cache:getCharacterIDFromName(playerName)
	if not charID then
		outputChatBox("[!]#FFFFFF Karakter bulunamadı.", client, 255, 0, 0, true)
		return
	end

	if oldRankID and oldRankID == newRankID then
		outputChatBox(
			"[!]#FFFFFF Bir oyuncunun birlik rütbesini aynı rütbeye değiştiremezsiniz.",
			client,
			255,
			125,
			0,
			true
		)
		return
	end

	local success = dbExec(
		exports.mek_mysql:getConnection(),
		"UPDATE `characters_faction` SET `faction_rank` = ? WHERE `character_id` = ? AND `faction_id` = ?",
		newRankID,
		charID,
		fID
	)
	
	if not success then
		outputChatBox("[!]#FFFFFF Rütbe değişikliği başarısız oldu.", client, 255, 0, 0, true)
		return
	end

	local highOrLow = ""
	if oldRankID and getSeniorRank(fID, newRankID, oldRankID) == newRankID then
		highOrLow = "terfi etti"
	else
		highOrLow = "rütbesi düşürüldü"
	end

	local thePlayer = exports.mek_global:getPlayerFromCharacterID(charID)
	if thePlayer then
		local factionInfo = getElementData(thePlayer, "faction")
		if factionInfo and factionInfo[fID] then
			factionInfo[fID].rank = newRankID
			setElementData(thePlayer, "faction", factionInfo)
			
			-- Oyuncu F3 menüsü açıksa kapat ve yeniden açmasını sağla
			if getElementData(thePlayer, "faction_menu") then
				triggerClientEvent(thePlayer, "hideFactionMenu", root)
			end
		end
	end

	local newRankDisplayName = getRankName(newRankID) or newRankName
	local oldRankDisplayName = oldRankID and getRankName(oldRankID) or "Bilinmeyen"
	sendMessageToAllFactionMembers(
		fID,
		playerName:gsub("_", " ")
			.. " isimli oyuncu '"
			.. oldRankDisplayName
			.. "' rütbesinden '"
			.. newRankDisplayName
			.. "' rütbesine "
			.. highOrLow
			.. "."
	)
end)

function aracimiBirligeVer(thePlayer, commandName, vehicleID, factionID)
	if not vehicleID or not factionID or not tonumber(vehicleID) or not tonumber(factionID) then
		outputChatBox("Kullanım: /" .. commandName .. " [Araç ID] [Birlik ID]", thePlayer, 255, 194, 14)
		return
	end

	vehicleID = tonumber(vehicleID)
	factionID = tonumber(factionID)

	local theVehicle = exports.mek_pool:getElementByID("vehicle", tonumber(vehicleID))
	if not isElement(theVehicle) then
		outputChatBox("[!]#FFFFFF Araç bulunamadı.", thePlayer, 255, 0, 0, true)
		return
	end

	local playerDBID = getElementData(thePlayer, "dbid")
	local vehicleOwner = getElementData(theVehicle, "owner")
	local vehicleFaction = getElementData(theVehicle, "faction") or -1

	if vehicleFaction ~= -1 then
		outputChatBox("[!]#FFFFFF Bu araç zaten birliğe aittir.", thePlayer, 255, 0, 0, true)
		return
	end

	if vehicleOwner ~= playerDBID and not exports.mek_integration:isPlayerManager(thePlayer) then
		outputChatBox("[!]#FFFFFF Bu araç size ait değil.", thePlayer, 255, 0, 0, true)
		return
	end

	if not isPlayerInFaction(thePlayer, factionID) then
		outputChatBox("[!]#FFFFFF Bu birlikte değilsiniz.", thePlayer, 255, 0, 0, true)
		return
	end

	if
		setElementData(theVehicle, "faction", factionID)
		and dbExec(
			exports.mek_mysql:getConnection(),
			"UPDATE vehicles SET faction = ? WHERE id = ?",
			factionID,
			vehicleID
		)
	then
		outputChatBox("[!]#FFFFFF Araç başarıyla birliğe verildi.", thePlayer, 0, 255, 0, true)
	else
		outputChatBox("[!]#FFFFFF Bir sorun oluştu.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("abv", aracimiBirligeVer, false, false)

function aracimiBirliktenGeriVer(thePlayer, commandName, vehicleID)
	if not vehicleID or not tonumber(vehicleID) then
		outputChatBox("Kullanım: /" .. commandName .. " [Araç ID]", thePlayer, 255, 194, 14)
		return
	end

	vehicleID = tonumber(vehicleID)

	local theVehicle = exports.mek_pool:getElementByID("vehicle", tonumber(vehicleID))
	if not isElement(theVehicle) then
		outputChatBox("[!]#FFFFFF Araç bulunamadı.", thePlayer, 255, 0, 0, true)
		return
	end

	local playerDBID = getElementData(thePlayer, "dbid")
	local vehicleOwner = getElementData(theVehicle, "owner")
	local vehicleFaction = getElementData(theVehicle, "faction") or -1
	local inFaction, _, isLeader = isPlayerInFaction(thePlayer, vehicleFaction)
	local isManager = exports.mek_integration:isPlayerManager(thePlayer)

	if not inFaction then
		outputChatBox("[!]#FFFFFF Bir birlikte değilsiniz.", thePlayer, 255, 0, 0, true)
		return
	end

	if vehicleOwner ~= playerDBID and not isManager then
		outputChatBox("[!]#FFFFFF Bu araç sizin veya birliğinizin değil.", thePlayer, 255, 0, 0, true)
		return
	end

	if not isLeader and not isManager and vehicleOwner ~= playerDBID then
		outputChatBox("[!]#FFFFFF Aracı teslim etmek için birlik lideri olmalısınız.", thePlayer, 255, 0, 0, true)
		return
	end

	if
		setElementData(theVehicle, "faction", -1)
		and dbExec(exports.mek_mysql:getConnection(), "UPDATE vehicles SET faction = -1 WHERE id = ?", vehicleID)
	then
		outputChatBox("[!]#FFFFFF Araç başarıyla sahibine teslim edildi.", thePlayer, 0, 255, 0, true)
	else
		outputChatBox("[!]#FFFFFF Bir sorun oluştu.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("abg", aracimiBirliktenGeriVer, false, false)
