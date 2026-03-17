local mysql = exports.mek_mysql
local characterNameCache = {}
local searched = {}
local refreshCacheRate = 60

function getCharacterNameFromID(id)
	if not id or not tonumber(id) then
		return false
	else
		id = tonumber(id)
	end

	if characterNameCache[id] then
		return characterNameCache[id]
	end

	for _, player in pairs(getElementsByType("player")) do
		if id == getElementData(player, "dbid") then
			characterNameCache[id] = getPlayerName(player)
			return characterNameCache[id]
		end
	end

	if searched[id] then
		return false
	end
	searched[id] = true

	dbQuery(function(queryHandle)
		local result = dbPoll(queryHandle, -1)
		if result and #result > 0 and result[1].name then
			local characterName = string.gsub(result[1].name, "_", " ")
			characterNameCache[id] = characterName
			for _, player in pairs(getElementsByType("player")) do
				triggerClientEvent(player, "retrieveCharacterNameCacheFromServer", resourceRoot, characterName, id)
			end
		end
		searched[id] = nil
	end, mysql:getConnection(), "SELECT `name` FROM `characters` WHERE `id` = ? LIMIT 1", id)

	return false
end

function getCharacterIDFromName(charName)
	if not charName then
		return false
	end

	charName = string.gsub(charName, " ", "_")

	local queryHandle = dbQuery(exports.mek_mysql:getConnection(), "SELECT id FROM characters WHERE `name` = ? LIMIT 1", charName)
	local result = dbPoll(queryHandle, -1)

	if result and #result > 0 then
		local id = tonumber(result[1].id)
		if id and id > 0 then
			return id
		end
	end

	return false
end

function requestCharacterNameCacheFromServer(ids)
	if type(ids) == "table" then
		for _, id in ipairs(ids) do
			local found = getCharacterNameFromID(id)
			if found then
				triggerClientEvent(client, "retrieveCharacterNameCacheFromServer", client, found, id)
			end
		end
	else
		local id = ids
		local found = getCharacterNameFromID(id)
		if found then
			triggerClientEvent(client, "retrieveCharacterNameCacheFromServer", client, found, id)
		end
	end
end
addEvent("requestCharacterNameCacheFromServer", true)
addEventHandler("requestCharacterNameCacheFromServer", root, requestCharacterNameCacheFromServer)
