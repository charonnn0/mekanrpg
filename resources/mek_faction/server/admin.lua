dutyAllow = {}
dutyAllowChanges = {}

unemployedPay = 150

function adminSetPlayerFaction(thePlayer, commandName, partialNick, factionID)
	if exports.mek_integration:isPlayerServerOwner(thePlayer) then
		factionID = tonumber(factionID)
		if not partialNick or not factionID then
			outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID] [Birlik ID]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerNick = exports.mek_global:findPlayerByPartialNick(thePlayer, partialNick)
			if targetPlayer then
				local defaultRank = getDefaultRank(factionID)
				local theTeam = exports.mek_pool:getElementByID("team", factionID)

				if not theTeam then
					outputChatBox("[!]#FFFFFF Geçersiz Birlik ID.", thePlayer, 255, 0, 0, true)
					return
				elseif isPlayerInFaction(targetPlayer, factionID) then
					outputChatBox("[!]#FFFFFF Bu oyuncu zaten bu birlikte.", thePlayer, 255, 0, 0, true)
					return
				end

				local factionInfo = getElementData(targetPlayer, "faction") or {}
				if size(factionInfo) >= 5 then
					outputChatBox(
						"[!]#FFFFFF Bu oyuncu zaten maksimum sayıda birlikte yer alıyor.",
						thePlayer,
						255,
						0,
						0,
						true
					)
					return
				end

				if
					dbExec(
						exports.mek_mysql:getConnection(),
						"INSERT INTO characters_faction SET faction_leader = 0, faction_id = ?, faction_rank = ?, faction_phone = NULL, character_id = ?",
						factionID,
						defaultRank,
						getElementData(targetPlayer, "dbid")
					)
				then
					local max = 0
					for id, _ in pairs(factionInfo) do
						if not max then
							max = _.count
						end
						if _.count >= max then
							max = _.count
						end
					end

					factionInfo[factionID] = {
						rank = defaultRank,
						leader = false,
						phone = nil,
						perks = {},
						count = max + 1,
					}
					setElementData(targetPlayer, "faction", factionInfo)

					triggerEvent("duty.offDuty", targetPlayer)
					outputChatBox(
						"[!]#FFFFFF "
							.. targetPlayerNick
							.. " isimli oyuncu "
							.. getTeamName(theTeam)
							.. " ("
							.. factionID
							.. ") isimli birliğine eklendi.",
						thePlayer,
						0,
						255,
						0,
						true
					)
					outputChatBox(
						"[!]#FFFFFF "
							.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
							.. " isimli yetkili sizi "
							.. getTeamName(theTeam)
							.. " ("
							.. factionID
							.. ") isimli birliğe ekledi.",
						targetPlayer,
						0,
						0,
						255,
						true
					)
				end
			end
		end
	end
end
addCommandHandler("setfaction", adminSetPlayerFaction, false, false)

function adminRemovePlayerFaction(thePlayer, commandName, partialNick, factionID)
	if exports.mek_integration:isPlayerServerManager(thePlayer) then
		factionID = tonumber(factionID)
		if not partialNick or not factionID then
			outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID] [Birlik ID]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerNick = exports.mek_global:findPlayerByPartialNick(thePlayer, partialNick)
			if targetPlayer then
				local theTeam = exports.mek_pool:getElementByID("team", factionID)
				if not theTeam and factionID ~= -1 then
					outputChatBox("[!]#FFFFFF Geçersiz Birlik ID.", thePlayer, 255, 0, 0, true)
					return
				end

				if
					dbExec(
						exports.mek_mysql:getConnection(),
						"DELETE FROM characters_faction WHERE faction_id = ? AND character_id = ?",
						factionID,
						getElementData(targetPlayer, "dbid")
					)
				then
					local factionInfo = getElementData(targetPlayer, "faction")
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
					setElementData(targetPlayer, "faction", factionInfo)

					if getElementData(targetPlayer, "duty") and getElementData(targetPlayer, "duty") > 0 then
						takeAllWeapons(targetPlayer)
						setElementData(targetPlayer, "duty", 0)
					end

					outputChatBox(
						"[!]#FFFFFF "
							.. targetPlayerNick
							.. " isimli oyuncu "
							.. getTeamName(theTeam)
							.. " ("
							.. factionID
							.. ") isimli birlikten atıldı.",
						thePlayer,
						0,
						255,
						0,
						true
					)
					outputChatBox(
						"[!]#FFFFFF "
							.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
							.. " isimli yetkili sizi "
							.. getTeamName(theTeam)
							.. " ("
							.. factionID
							.. ") isimli birlikten attı.",
						targetPlayer,
						0,
						0,
						255,
						true
					)
				end
			end
		end
	end
end
addCommandHandler("removefaction", adminRemovePlayerFaction, false, false)

function adminSetFactionLeader(thePlayer, commandName, partialNick, factionID)
	if exports.mek_integration:isPlayerServerOwner(thePlayer) then
		factionID = tonumber(factionID)
		if not partialNick or not factionID then
			outputChatBox(
				"Kullanım: /" .. commandName .. " [Player Partial Name] [Faction ID]",
				thePlayer,
				255,
				194,
				14
			)
		elseif factionID > 0 then
			local targetPlayer, targetPlayerNick = exports.mek_global:findPlayerByPartialNick(thePlayer, partialNick)

			if targetPlayer then
				local theRank = getLeaderRank(factionID)
				local theTeam = exports.mek_pool:getElementByID("team", factionID)

				if not theTeam then
					outputChatBox("[!]#FFFFFF Geçersiz Birlik ID.", thePlayer, 255, 0, 0, true)
					return
				elseif isPlayerInFaction(targetPlayer, factionID) then
					outputChatBox("[!]#FFFFFF Bu oyuncu zaten bu birlikte.", thePlayer, 255, 0, 0, true)
					return
				end

				local factionInfo = getElementData(targetPlayer, "faction") or {}
				if size(factionInfo) >= 5 then
					outputChatBox(
						"[!]#FFFFFF Bu oyuncu zaten maksimum sayıda birlikte yer alıyor.",
						thePlayer,
						255,
						0,
						0,
						true
					)
					return
				end

				if
					dbExec(
						exports.mek_mysql:getConnection(),
						"INSERT INTO characters_faction SET faction_leader = 1, faction_id = ?, faction_rank = ?, faction_phone = NULL, character_id=?",
						factionID,
						theRank,
						getElementData(targetPlayer, "dbid")
					)
				then
					local max = 0
					for id, _ in pairs(factionInfo) do
						if not max then
							max = _.count
						end
						if _.count >= max then
							max = _.count
						end
					end
					factionInfo[factionID] = { rank = theRank, leader = true, phone = nil, perks = {}, count = max + 1 }
					setElementData(targetPlayer, "faction", factionInfo)

					triggerEvent("duty.offDuty", targetPlayer)
					outputChatBox(
						"[!]#FFFFFF "
							.. targetPlayerNick
							.. " isimli oyuncu "
							.. getTeamName(theTeam)
							.. " ("
							.. factionID
							.. ") isimli birliğe lider olarak eklendi.",
						thePlayer,
						0,
						255,
						0,
						true
					)
					outputChatBox(
						"[!]#FFFFFF "
							.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
							.. " isimli yetkili sizi "
							.. getTeamName(theTeam)
							.. " ("
							.. factionID
							.. ") isimli birliğe lider olarak ekledi.",
						targetPlayer,
						0,
						0,
						255,
						true
					)
					sendMessageToAllFactionMembers(
						factionID,
						targetPlayerNick
							.. ", '"
							.. getTeamName(theTeam)
							.. "' birliğinizin artık lideri oldu. Bu yetki "
							.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
							.. " tarafından verildi."
					)
				else
					outputChatBox("[!]#FFFFFF Geçersiz Birlik ID.", thePlayer, 255, 0, 0, true)
				end
			end
		end
	end
end
addCommandHandler("setfactionleader", adminSetFactionLeader, false, false)




function adminSetFactionRank(thePlayer, commandName, partialNick, factionID, ...)
	if exports.mek_integration:isPlayerServerManager(thePlayer) then
		factionID = tonumber(factionID)
		if not partialNick or not factionID or not (...) then
			outputChatBox(
				"Kullanım: /" .. commandName .. " [Karakter Adı / ID] [Birlik ID] [Birlik Rütbesi]",
				thePlayer,
				255,
				194,
				14
			)
		else
			local targetPlayer, targetPlayerNick = exports.mek_global:findPlayerByPartialNick(thePlayer, partialNick)
			local rankName = table.concat({ ... }, " ")
			local rankID = getRankIDbyName(factionID, rankName)
			
			-- Rank ID nil kontrolü
			if not rankID then
				outputChatBox("[!]#FFFFFF Rütbe bulunamadı: " .. tostring(rankName), thePlayer, 255, 0, 0, true)
				return
			end
			
			if targetPlayer then
				local theTeam = exports.mek_pool:getElementByID("team", factionID)
				if not isPlayerInFaction(targetPlayer, factionID) then
					outputChatBox("[!]#FFFFFF Bu oyuncu bu birlikte değil.", thePlayer, 255, 0, 0, true)
					return
				end

				if
					dbExec(
						exports.mek_mysql:getConnection(),
						"UPDATE characters_faction SET faction_rank = ? WHERE character_id = ? AND faction_id = ?",
						rankID,
						getElementData(targetPlayer, "dbid"),
						factionID
					)
				then
					local factionInfo = getElementData(targetPlayer, "faction")
					
					-- factionInfo nil kontrolü
					if factionInfo and factionInfo[factionID] then
						factionInfo[factionID].rank = rankID
						setElementData(targetPlayer, "faction", factionInfo)
						
						-- Oyuncu F3 menüsü açıksa kapat
						if getElementData(targetPlayer, "faction_menu") then
							triggerClientEvent(targetPlayer, "hideFactionMenu", root)
						end
					end

					outputChatBox(
						"[!]#FFFFFF "
							.. targetPlayerNick
							.. " isimli oyuncuya "
							.. factionID
							.. " ID'li birlikte "
							.. rankName
							.. " rütbesi verildi.",
						thePlayer,
						0,
						255,
						0,
						true
					)
					outputChatBox(
						"[!]#FFFFFF "
							.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
							.. " isimli yetkili size "
							.. factionID
							.. " ID'li birlikte "
							.. rankName
							.. " rütbesi verdi.",
						targetPlayer,
						0,
						0,
						255,
						true
					)
				end
			end
		end
	end
end
addCommandHandler("setfactionrank", adminSetFactionRank, false, false)

function respawnFactionVehicles(thePlayer, commandName, factionID)
	if exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
		local factionID = tonumber(factionID)
		if factionID and (factionID > 0) then
			local theTeam = exports.mek_pool:getElementByID("team", factionID)
			if theTeam then
				for key, value in ipairs(exports.mek_pool:getPoolElementsByType("vehicle")) do
					local faction = tonumber(getElementData(value, "faction"))
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
						removeElementData(value, "i:left")
						removeElementData(value, "i:right")
					end
				end

				for i, player in ipairs(getPlayersInFaction(factionID)) do
					outputChatBox(
						">> Tüm birlik araçları "
							.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
							.. " tarafından yenilendi.",
						player,
						255,
						194,
						14
					)
				end
			else
				outputChatBox("Invalid faction ID.", thePlayer, 255, 0, 0, false)
			end
		else
			outputChatBox("Kullanım: /" .. commandName .. " [Faction ID]", thePlayer, 255, 194, 14, false)
		end
	end
end
addCommandHandler("respawnfaction", respawnFactionVehicles, false, false)

function adminDutyStart()
	local result =
		dbQuery(exports.mek_mysql:getConnection(), "SELECT id, name FROM factions WHERE type >= 2 ORDER BY id ASC")
	local resultPoll = dbPoll(result, -1)

	local maxResult = dbQuery(exports.mek_mysql:getConnection(), "SELECT id FROM duty_allowed ORDER BY id DESC LIMIT 1")
	local maxPoll = dbPoll(maxResult, -1)

	if resultPoll and maxPoll then
		local maxRow = maxPoll[1]
		local maxIndex = maxRow and tonumber(maxRow.id) or 0

		dutyAllow = {}

		for _, row in ipairs(resultPoll) do
			local factionID = tonumber(row.id)
			dutyAllow[factionID] = {
				factionID,
				row.name,
				{},
			}

			local dutyResult =
				dbQuery(exports.mek_mysql:getConnection(), "SELECT * FROM duty_allowed WHERE faction = ?", factionID)
			local dutyPoll = dbPoll(dutyResult, -1)

			if dutyPoll then
				for _, dutyRow in ipairs(dutyPoll) do
					table.insert(dutyAllow[factionID][3], {
						dutyRow.id,
						tonumber(dutyRow.itemID),
						dutyRow.itemValue,
					})
				end
			end
		end

		setElementData(resourceRoot, "maxIndex", maxIndex)
		setElementData(resourceRoot, "dutyAllowTable", dutyAllow)
	end
end
addEventHandler("onResourceStart", resourceRoot, adminDutyStart)

function getAllowList(factionID)
	local factionID = tonumber(factionID)
	if factionID and dutyAllow[factionID] then
		return dutyAllow[factionID][3]
	end

	return {}
end

function adminDuty(thePlayer)
	if exports.mek_integration:isPlayerManager(thePlayer) then
		if not getElementData(resourceRoot, "dutyadmin") and type(dutyAllow) == "table" then
			triggerClientEvent(thePlayer, "adminDutyAllow", resourceRoot, dutyAllow, dutyAllowChanges)
			setElementData(resourceRoot, "dutyadmin", true)
		elseif type(dutyAllow) ~= "table" then
			outputChatBox(
				"[!]#FFFFFF Bu kaynağın önbelleğe alınmasıyla ilgili bir sorun oluştu.",
				thePlayer,
				255,
				0,
				0,
				true
			)
		else
			outputChatBox(
				"[!]#FFFFFF Hay aksi! Birisi görev izinlerini düzenliyor. Üzgünüm!",
				thePlayer,
				255,
				0,
				0,
				true
			)
		end
	end
end
addCommandHandler("dutyadmin", adminDuty, false, false)

function saveChanges()
	local tick = getTickCount()
	for key, value in pairs(dutyAllowChanges) do
		if value[2] == 0 then
			dbExec(exports.mek_mysql:getConnection(), "DELETE FROM duty_allowed WHERE id = ?", tonumber(value[3]))
		elseif value[2] == 1 then
			dbExec(
				exports.mek_mysql:getConnection(),
				"INSERT INTO duty_allowed (id, faction, itemID, itemValue) VALUES (?, ?, ?, ?)",
				tonumber(value[3]),
				tonumber(value[1]),
				tonumber(value[4]),
				value[5]
			)
		end
	end
end
addEventHandler("onResourceStop", resourceRoot, saveChanges)

function updateTable(newTable, changesTable)
	dutyAllow = newTable
	dutyAllowChanges = changesTable
	removeElementData(resourceRoot, "dutyadmin")
	setElementData(resourceRoot, "dutyAllowTable", dutyAllow)
end
addEvent("dutyAdmin:Save", true)
addEventHandler("dutyAdmin:Save", resourceRoot, updateTable)
