function getFactionFromID(factionID)
	if not tonumber(factionID) then
		return false
	end
	return exports.mek_pool:getElementByID("team", tonumber(factionID))
end

function getPlayersInFaction(factionID, leaderOnly)
	users = {}
	local factionID = tonumber(factionID)
	for k, v in ipairs(getElementsByType("player")) do
		local f = getElementData(v, "faction") or {}
		if f[factionID] then
			f = f[factionID]
			if leaderOnly and f.leader then
				table.insert(users, v)
			elseif not leaderOnly then
				table.insert(users, v)
			end
		end
	end

	return users
end

function sendMessageToAllFactionMembers(fId, message, leaderOnly)
	local told = {}
	dbQuery(
		function(qh)
			local result, rows = dbPoll(qh, 0)
			if result and rows > 0 then
				for i, member in ipairs(result) do
					if not told[member.aid] then
						local foundPlayer = nil
						for i, player in pairs(getElementsByType("player")) do
							if getElementData(player, "account_id") == member.aid then
								foundPlayer = player
								break
							end
						end

						if foundPlayer then
							outputChatBox(">>#FFFFFF " .. message, foundPlayer, 0, 255, 0, true)
						end

						told[member.aid] = true
					end
				end
			end
		end,
		exports.mek_mysql:getConnection(),
		"SELECT c.account_id AS aid, c.id AS cid, name FROM characters_faction cf LEFT JOIN characters c ON cf.character_id = c.id WHERE "
			.. (leaderOnly and "cf.faction_leader=1 AND " or "")
			.. " cf.faction_id = ? ORDER BY (aid)",
		fId
	)
end

function getPlayerFactions(playerName)
	local thePlayerElement = getPlayerFromName(playerName)
	local override = false
	if thePlayerElement then
		if not getElementData(thePlayerElement, "logged") then
			override = true
		else
			local playerFaction = getElementData(thePlayerElement, "faction")

			return 0, playerFaction, thePlayerElement
		end
	end

	if not thePlayerElement or override then
		local q = dbQuery(
			exports.mek_mysql:getConnection(),
			[[
				SELECT 
					faction_id, 
					faction_rank, 
					faction_perks, 
					cf.faction_leader 
				FROM 
					characters c 
				LEFT JOIN 
					characters_faction cf ON c.id = cf.character_id 
				LEFT JOIN 
					factions f ON cf.faction_id = f.id 
				WHERE 
					c.id IS NOT NULL 
					AND cf.id IS NOT NULL 
					AND f.id IS NOT NULL 
					AND c.name = ?;
			]],
			playerName
		)
		local result, rows = dbPoll(q, 10000)

		if not result then
			dbFree(q)
			return 2, {}
		end
		if result and rows > 0 then
			return 1, result, nil
		end
	end

	return 2, -1, 20, 0, {}, nil
end

function getAllFactionPhoneNumbers()
	local phones = {}
	for _, theTeam in ipairs(exports.mek_pool:getPoolElementsByType("team")) do
		local factionId = getElementData(theTeam, "id")
		local phone = getElementData(theTeam, "phone")
		if factionId and phone then
			phones[factionId] = phone
		end
	end
	return phones
end
