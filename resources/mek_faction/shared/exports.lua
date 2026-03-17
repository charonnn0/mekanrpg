function canAccessFactionManager(player)
	return exports.mek_integration:isPlayerManager(player)
end

local factionTypes = {
	["0"] = "Çete",
	["1"] = "Mafya",
	["2"] = "Devlet Birliği",
	["3"] = "Hükümet",
	["4"] = "Hastane",
	["5"] = "Diğer",
	["6"] = "Haber/Medya",
	["7"] = "Bayilik",
}

function getFactionTypes(type)
	return type and factionTypes[tostring(type)] or factionTypes
end

function isPlayerInFaction(thePlayer, factionID)
	if not thePlayer or not factionID then
		return false
	end

	if type(factionID) == "number" or type(factionID) == "string" then
		factionID = tonumber(factionID) or -1
		local faction = getElementData(thePlayer, "faction") or {}
		local faction = faction[factionID]

		if faction then
			return true, faction.rank, faction.leader
		end
	elseif type(factionID) == "table" then
		local faction = getElementData(thePlayer, "faction") or {}
		local isInFaction

		for _, fID in pairs(factionID) do
			if faction[fID] then
				isInFaction = fID
				break
			end
		end

		local faction = faction[isInFaction]
		if faction then
			return true, faction.rank, faction.leader
		end
	end
	return false
end

function getPlayerFactionRank(thePlayer, factionID)
	if not thePlayer or not factionID then
		return false
	end

	if type(factionID) == "number" or type(factionID) == "string" then
		factionID = tonumber(factionID) or -1
		local faction = getElementData(thePlayer, "faction") or {}
		local faction = faction[factionID]

		if faction then
			return faction.rank
		end
	elseif type(factionID) == "table" then
		local faction = getElementData(thePlayer, "faction") or {}
		local isInFaction

		for _, fID in pairs(factionID) do
			if faction[fID] then
				isInFaction = fID
				break
			end
		end

		local faction = faction[isInFaction]
		if faction then
			return faction.rank
		end
	end
	return false
end

function isPlayerFactionLeader(thePlayer, factionID)
	if not thePlayer or not factionID then
		return false
	end

	if type(factionID) == "number" or type(factionID) == "string" then
		factionID = tonumber(factionID) or -1
		local faction = getElementData(thePlayer, "faction") or {}
		local faction = faction[factionID]

		if faction then
			return faction.leader
		end
	elseif type(factionID) == "table" then
		local faction = getElementData(thePlayer, "faction") or {}
		local isInFaction

		for _, fID in pairs(factionID) do
			if faction[fID] then
				isInFaction = fID
				break
			end
		end

		local faction = faction[isInFaction]
		if faction then
			return faction.leader
		end
	end
	return false
end

function getFactionFromName(name)
	if not tostring(name) then
		return false
	end
	return getTeamFromName(name)
end

function getFactionType(factionID)
	local theTeam = getFactionFromID(factionID)
	if theTeam then
		local ftype = tonumber(getElementData(theTeam, "type"))
		if ftype then
			return ftype
		end
	end
	return false
end

function getFactionName(factionID)
	local theTeam = getFactionFromID(factionID)
	if theTeam then
		local name = getTeamName(theTeam)
		if name then
			name = tostring(name)
			return name
		end
	end
	return false
end

function getFactionIDFromName(factionName)
	local theTeam = getFactionFromName(factionName)
	if theTeam then
		local id = tonumber(getElementData(theTeam, "id"))
		if id then
			return id
		end
	end
	return false
end

function isInFactionType(element, ftype)
	if not getElementData(element, "faction") then
		return
	end

	for k, v in pairs(getElementData(element, "faction")) do
		local team = getFactionFromID(k)
		if team then
			local teamType = getElementData(team, "type")
			if ftype == teamType then
				return true
			end
		end
	end
	return false
end

function getPlayerFactionTypes(element)
	if not getElementData(element, "faction") then
		return
	end

	local table = {}

	for k, v in pairs(getElementData(element, "faction")) do
		local team = getFactionFromID(k)
		if team then
			local teamType = getElementData(team, "type")
			if table[teamType] then
				table[teamType][getElementData(team, "id")] = team
			else
				table[teamType] = { [getElementData(team, "id")] = team }
			end
		end
	end
	return table
end

function getCurrentFactionDuty(element)
	local playerFaction = getElementData(element, "faction") or {}
	local duty = getElementData(element, "duty") or 0
	local foundPackage = false

	if duty > 0 then
		for k, v in pairs(playerFaction) do
			for key, element in ipairs(v.perks) do
				if tonumber(element) == tonumber(duty) then
					foundPackage = k
					break
				end
			end
		end
	end
	return foundPackage
end

function getFactionFromID(factionID)
	if not tonumber(factionID) then
		return false
	end

	if triggerServerEvent then
		for i, team in pairs(getElementsByType("team")) do
			if getElementData(team, "id") == tonumber(factionID) then
				return team
			end
		end
	else
		return exports.mek_pool:getElementByID("team", tonumber(factionID))
	end
end
