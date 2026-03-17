local mysql = exports.mek_mysql

local charCache = {}
local singleCharCache = {}
local cacheUsed = 0

local function fetchCharacterName(id, callback)
	dbQuery(function(queryHandle)
		local result = dbPoll(queryHandle, 0)
		if result and #result > 0 then
			local row = result[1]
			local name = row["name"]

			if name then
				local formattedName = name:gsub("_", " ")
				charCache[id] = formattedName
				singleCharCache[id] = formattedName

				for _, player in ipairs(getElementsByType("player")) do
					triggerClientEvent(player, "retrieveCharacterNameCacheFromServer", resourceRoot, formattedName, id)
				end

				if callback then
					callback(formattedName)
				end
			end
		else
			charCache[id] = false
			singleCharCache[id] = false
			if callback then
				callback(false)
			end
		end
	end, mysql:getConnection(), "SELECT name FROM characters WHERE id = ? LIMIT 1", id)
end

function getCharacterName(id, singleName)
	id = tonumber(id)
	if not id or id < 1 then
		return false
	end

	if not charCache[id] then
		fetchCharacterName(id)
	else
		cacheUsed = cacheUsed + 1
	end

	return singleName and singleCharCache[id] or charCache[id]
end

function requestCharacterNameCacheFromServer(id, singleName)
	local found = getCharacterName(id, singleName)
	if found then
		triggerClientEvent(client, "retrieveCharacterNameCacheFromServer", client, found, id)
	end
end
addEvent("requestCharacterNameCacheFromServer", true)
addEventHandler("requestCharacterNameCacheFromServer", root, requestCharacterNameCacheFromServer)

function clearCharacterName(id)
	charCache[id] = nil
	singleCharCache[id] = nil
end

function clearCharacterCache()
	charCache = {}
	singleCharCache = {}
end
