addEvent("factions.fetchFactionList", true)
addEventHandler("factions.fetchFactionList", resourceRoot, function()
	dbQuery(
		function(qh, client)
			local res, nums, id = dbPoll(qh, 0)
			local factions = {}
			if res and nums > 0 then
				for _, row in ipairs(res) do
					table.insert(factions, {
						id = row.id,
						name = row.name,
						type = row.type,
						members = (#getPlayersInFaction(row.id) or "?") .. " / " .. row.members,
						max_interiors = row.max_interiors,
						max_vehicles = row.max_vehicles,
						ints = row.ints,
						vehs = row.vehs,
						before_tax = row.before_tax_value,
						free_wage = row.before_wage_charge,
					})
					table.sort(factions, function(a, b)
						return a.id < b.id
					end)
				end
			end
			triggerClientEvent(client, "showFactionList", resourceRoot, factions)
		end,
		{ client },
		exports.mek_mysql:getConnection(),
		"SELECT	id, name, type, (SELECT COUNT(*) FROM characters_faction c WHERE c.faction_id = f.id) AS members, (SELECT COUNT(*) FROM interiors i WHERE i.faction = f.id AND i.deleted=0) AS ints, (SELECT COUNT(*) FROM vehicles v WHERE v.faction = f.id AND v.deleted=0) AS vehs, max_interiors, max_vehicles, before_tax_value, before_wage_charge FROM factions f ORDER BY id ASC"
	)
end)

addEvent("factions.editFaction", true)
addEventHandler("factions.editFaction", resourceRoot, function(data, old_id)
	local qh = dbQuery(
		exports.mek_mysql:getConnection(),
		"SELECT id, name FROM factions WHERE id!=? AND name=? LIMIT 1",
		old_id or 0,
		data.name
	)
	local res, nums, id = dbPoll(qh, 10000)
	if res then
		if nums > 0 and res[1].name == data.name then
			return not triggerClientEvent(
				client,
				"factions.editFaction.callback",
				resourceRoot,
				"Birlik adı zaten alınmış."
			)
		end

		if old_id then
			local qh2 = dbQuery(
				exports.mek_mysql:getConnection(),
				"UPDATE factions SET name=?, type=?, max_interiors=?, max_vehicles=?, before_tax_value=?, before_wage_charge=? WHERE id=?",
				data.name,
				data.type,
				data.max_interiors,
				data.max_vehicles,
				data.before_tax_value,
				data.free_wage_amount,
				old_id
			)
			local res, nums, id = dbPoll(qh2, 10000)
			if nums and nums > 0 then
				local team = exports.mek_pool:getElementByID("team", old_id)
				if team then
					setElementData(team, "type", data.type)
					setElementData(team, "max_interiors", data.max_interiors)
					setElementData(team, "max_vehicles", data.max_vehicles)
					setElementData(team, "before_tax_value", data.before_tax_value)
					setElementData(team, "before_wage_charge", data.free_wage_amount)
					setTeamName(team, data.name)
					exports.mek_cache:removeFactionNameFromCache(old_id)
				end

				exports.mek_global:sendMessageToAdmins(
					"[ADM] "
						.. exports.mek_global:getPlayerFullAdminTitle(client)
						.. " isimli yetkili '"
						.. data.name
						.. "' birliğini düzenledi."
				)

				sendMessageToAllFactionMembers(
					old_id,
					"'"
						.. data.name
						.. "' birliğiniz düzenlendi. Düzenleyen: "
						.. exports.mek_global:getPlayerFullAdminTitle(client)
				)

				return triggerClientEvent(client, "factions.editFaction.callback", resourceRoot, "ok")
			else
				return not triggerClientEvent(
					client,
					"factions.editFaction.callback",
					resourceRoot,
					"Birlik değişikliği başarısız oldu."
				)
			end
		else
			local qh2 = dbQuery(
				exports.mek_mysql:getConnection(),
				"INSERT INTO factions SET money='0', motd='Birliğe hoş geldiniz.', note = '', name=?, type=?, max_interiors=?, max_vehicles=?, before_tax_value=?, before_wage_charge=?",
				data.name,
				data.type,
				data.max_interiors,
				data.max_vehicles,
				data.before_tax_value,
				data.free_wage_amount
			)
			local res, nums, id = dbPoll(qh2, 10000)
			if id and tonumber(id) then
				data.id = id
				data.money = 0
				data.motd = ""
				data.note = ""
				data.fnote = ""
				local theTeam = loadOneFaction(data)
				local rank_order = ""
				local factionRanks = {}
				local factionWages = {}
				RanksByFaction[data.id] = {}

				local perms = {}
				for i, v in ipairs(memberPermissions) do
					table.insert(perms, i)
				end
				local permissions = table.concat(perms, ",")
				for i = 1, 2 do
					if i == 1 then
						local qh3 = dbQuery(
							exports.mek_mysql:getConnection(),
							"INSERT INTO faction_ranks SET faction_id=?, name='Lider Rütbe', permissions=?, isDefault='0', isLeader='1', wage='0'",
							data.id,
							permissions
						)
						local res, nums, rid1 = dbPoll(qh3, 10000)
						local rankID = tonumber(rid1)
						FactionRanks[rankID] = {}
						FactionRanks[rankID]["name"] = "Lider Rütbe"
						FactionRanks[rankID]["permissions"] = permissions
						FactionRanks[rankID]["isDefault"] = 0
						FactionRanks[rankID]["isLeader"] = 1
						FactionRanks[rankID]["faction_id"] = data.id
						table.insert(RanksByFaction[data.id], tonumber(rankID))
						factionRanks[rankID] = "Lider Rütbe"
						factionWages[rankID] = 0
						rank_order = rank_order .. rankID .. ","
						dbFree(qh3)
					elseif i == 2 then
						local qh4 = dbQuery(
							exports.mek_mysql:getConnection(),
							"INSERT INTO faction_ranks SET faction_id=?, name='Varsayılan Rütbe', permissions='', isDefault='1', isLeader='0', wage='0'",
							data.id
						)
						local res, nums, rid2 = dbPoll(qh4, 10000)
						local rankID = tonumber(rid2)
						FactionRanks[rankID] = {}
						FactionRanks[rankID]["name"] = "Varsayılan Rütbe"
						FactionRanks[rankID]["permissions"] = ""
						FactionRanks[rankID]["isDefault"] = 1
						FactionRanks[rankID]["isLeader"] = 0
						FactionRanks[rankID]["faction_id"] = data.id
						table.insert(RanksByFaction[data.id], tonumber(rankID))
						factionRanks[rankID] = "Varsayılan Rütbe"
						factionWages[rankID] = 0
						rank_order = rank_order .. rankID .. ","
						dbFree(qh4)
					end
				end

				dbExec(
					exports.mek_mysql:getConnection(),
					"UPDATE `factions` SET `rank_order` = ? WHERE `id` = ?",
					rank_order,
					data.id
				)
				setElementData(theTeam, "rank_order", rank_order)
				setElementData(theTeam, "ranks", factionRanks)
				setElementData(theTeam, "wages", factionWages)
				dutyAllow[id] = {}
				dutyAllow[id] = {
					id,
					name,
					{},
				}
				setElementData(resourceRoot, "dutyAllowTable", dutyAllow)
				locations[id] = {}
				custom[id] = {}
				exports.mek_global:sendMessageToAdmins(
					"[ADM] "
						.. exports.mek_global:getPlayerFullAdminTitle(client)
						.. " isimli yetkili '"
						.. data.name
						.. "' birliğini oluşturdu."
				)
                triggerClientEvent(root, "faction.cacheRanks", root, FactionRanks)

                -- Yeni birlik admin panelinden oluşturulduğunda ilk üye (lider) eklenmiyor sorununu düzelt
                local leaderRank = getLeaderRank(data.id)
                local creatorCharId = getElementData(client, "dbid")
                if leaderRank and creatorCharId then
                    if dbExec(
                        exports.mek_mysql:getConnection(),
                        "INSERT INTO characters_faction SET faction_leader = 1, faction_id = ?, faction_rank = ?, faction_phone = NULL, character_id=?",
                        data.id,
                        leaderRank,
                        creatorCharId
                    ) then
                        -- Oluşturan oyuncunun faction element datasını güncelle
                        local factionInfo = getElementData(client, "faction") or {}
                        local max = 0
                        for _, info in pairs(factionInfo) do
                            if not max then
                                max = info.count
                            end
                            if info.count >= max then
                                max = info.count
                            end
                        end
                        factionInfo[data.id] = { rank = leaderRank, leader = true, phone = nil, perks = {}, count = max + 1 }
                        setElementData(client, "faction", factionInfo)
                    end
                end

                return triggerClientEvent(client, "factions.editFaction.callback", resourceRoot, "ok")
			else
				return not triggerClientEvent(
					client,
					"factions.editFaction.callback",
					resourceRoot,
					"Birlik değişikliği başarısız oldu."
				)
			end
		end
	else
		dbFree(qh)
		return not triggerClientEvent(
			client,
			"factions.editFaction.callback",
			resourceRoot,
			"Birlik değişikliği başarısız oldu."
		)
	end
end)

addEvent("factions.delete", true)
addEventHandler("factions.delete", resourceRoot, function(factionID)
	factionID = tonumber(factionID)
	dbExec(exports.mek_mysql:getConnection(), "DELETE FROM factions WHERE id=?", factionID)
	dbExec(exports.mek_mysql:getConnection(), "DELETE FROM faction_ranks WHERE faction_id=?", factionID)

	for key, value in pairs(getPlayersInFaction(factionID)) do
		local factionInfo = getElementData(value, "faction")
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
		setElementData(value, "faction", factionInfo)

		if getElementData(value, "duty") and getElementData(value, "duty") > 0 then
			takeAllWeapons(value)
			setElementData(value, "duty", 0)
		end
	end

	dbExec(exports.mek_mysql:getConnection(), "DELETE FROM characters_faction WHERE faction_id=?", factionID)

	local theTeam = exports.mek_pool:getElementByID("team", factionID)
	local vehs = 0

	for i, veh in pairs(getElementsByType("vehicle")) do
		if veh and isElement(veh) and getElementData(veh, "faction") == factionID then
			local vehid = getElementData(veh, "dbid")
			executeCommandHandler("delveh", client, vehid)
			executeCommandHandler("delveh", client, vehid)
			exports["mek_vehicle-manager"]:addVehicleLogs(
				vehid,
				"Birlik silindiği için araç yok edildi. ("
					.. (theTeam and getTeamName(theTeam) or "Bilinmiyor")
					.. ").",
				client
			)
			vehs = vehs + 1
		end
	end

	local ints = 0
	for i, int in pairs(getElementsByType("interior")) do
		if
			int
			and isElement(int)
			and getElementData(int, "status")
			and getElementData(int, "status").faction == factionID
		then
			local intid = getElementData(int, "dbid")
			triggerEvent("interior:factionfsell", client, factionID, intid)
			ints = ints + 1
		end
	end

	dbExec(exports.mek_mysql:getConnection(), "DELETE FROM duty_custom WHERE faction_id = " .. factionID)
	dbExec(exports.mek_mysql:getConnection(), "DELETE FROM duty_locations WHERE faction_id = " .. factionID)
	dbExec(exports.mek_mysql:getConnection(), "DELETE FROM duty_allowed WHERE faction = " .. factionID)

	custom[factionID] = nil

	if locations[factionID] then
		for k, v in pairs(locations[factionID]) do
			exports.mek_duty:destroyDutyColShape(factionID, k)
		end
		locations[factionID] = nil
	end

	dutyAllow[factionID] = nil
	setElementData(resourceRoot, "dutyAllowTable", dutyAllow)

	for k, v in ipairs(dutyAllowChanges) do
		if v[1] == factionID then
			dutyAllowChanges[k] = nil
		end
	end

	exports.mek_global:sendMessageToAdmins(
		"[ADM] "
			.. exports.mek_global:getPlayerFullAdminTitle(client)
			.. " isimli yetkili '"
			.. (theTeam and getTeamName(theTeam) or "Bilinmiyor")
			.. "' birliğini sildi. "
			.. ints
			.. " mülk ve "
			.. vehs
			.. " araç da yok edildi."
	)
	sendMessageToAllFactionMembers(
		factionID,
		"'"
			.. (theTeam and getTeamName(theTeam) or "Bilinmiyor")
			.. "' birliğiniz silindi. İşlemi gerçekleştiren: "
			.. exports.mek_global:getPlayerFullAdminTitle(client)
	)

	if theTeam then
		destroyElement(theTeam)
	end

	triggerClientEvent(client, "showFactionList", resourceRoot)
end)

addEvent("factions.listMember", true)
addEventHandler("factions.listMember", resourceRoot, function(fact_id)
	dbQuery(
		function(qh, client, fact_id)
			fact_id = tonumber(fact_id)
			local res, nums, id = dbPoll(qh, 0)
			if nums and tonumber(nums) then
				if nums > 0 then
					local qh2 = dbQuery(exports.mek_mysql:getConnection(), "SELECT * FROM factions WHERE id=?", fact_id)
					local res2, nums2, id2 = dbPoll(qh2, 10000)
					if res2 and nums2 > 0 then
						local members = {}
						for _, member in ipairs(res) do
							member.faction_rank_name = getRankName(member.faction_rank)
							member.username = exports.mek_cache:getUsernameFromID(member.account_id) or "Bilinmiyor"

							local player = getPlayerFromName(tostring(member.name))
							member.online = player and 1 or 0
							member.duty = player and (getCurrentFactionDuty(player) == fact_id) or false
							table.insert(members, member)
						end

						table.sort(members, function(a, b)
							if a.online == b.online then
								if a.faction_leader == b.faction_leader then
									return a.faction_rank > b.faction_rank
								else
									return a.faction_leader > b.faction_leader
								end
							else
								return a.online > b.online
							end
						end)

						return triggerClientEvent(
							client,
							"factions.listMember",
							resourceRoot,
							res2[1].name,
							"ok",
							members
						)
					else
						dbFree(qh2)
						return not triggerClientEvent(
							client,
							"factions.listMember",
							resourceRoot,
							fact_id,
							"Sunucudan bilgi alınırken hatalar oluştu."
						)
					end
				else
					return triggerClientEvent(
						client,
						"factions.listMember",
						resourceRoot,
						fact_id,
						"Bu birliğin şu anda üyesi bulunmamaktadır."
					)
				end
			else
				dbFree(qh)
				return not triggerClientEvent(
					client,
					"factions.listMember",
					resourceRoot,
					fact_id,
					"Sunucudan bilgi alınırken hatalar oluştu."
				)
			end
		end,
		{ client, fact_id },
		exports.mek_mysql:getConnection(),
		"SELECT c.name, c.account_id, cf.faction_leader, cf.faction_rank FROM characters_faction cf LEFT JOIN characters c ON c.id=cf.character_id WHERE cf.faction_id=? ORDER BY c.name",
		fact_id
	)
end)
