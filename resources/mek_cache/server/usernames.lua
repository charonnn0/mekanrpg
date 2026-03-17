local mysql = exports.mek_mysql
local refreshCacheRate = 10
local usernameCache = {}
local searched = {}

function getUsername(clue)
	if not clue or #clue < 1 then
		return false
	end

	for _, username in pairs(usernameCache) do
		if username and string.lower(username) == string.lower(clue) then
			return username
		end
	end

	for _, player in pairs(getElementsByType("player")) do
		local username = getElementData(player, "account_username")
		if username and string.lower(username) == string.lower(clue) then
			usernameCache[getElementData(player, "account_id")] = username
			return username
		end
	end

	if not searched[clue] then
		dbQuery(function(queryHandle)
			local result = dbPoll(queryHandle, 0)
			if result and #result > 0 then
				local row = result[1]
				local username = row["username"]
				local id = tonumber(row["id"])
				if username then
					usernameCache[id] = username
					for _, player in pairs(getElementsByType("player")) do
						triggerClientEvent(player, "retrieveUsernameCacheFromServer", resourceRoot, username, clue)
					end
				end
			end
		end, mysql:getConnection(), "SELECT `username`, `id` FROM `accounts` WHERE `username` = ? LIMIT 1", clue)

		searched[clue] = true
		setTimer(function()
			searched[clue] = nil
		end, refreshCacheRate * 1000 * 60, 1)
	end
	return false
end

function requestUsernameCacheFromServer(clue)
	local found = getUsername(clue)
	triggerClientEvent(client, "retrieveUsernameCacheFromServer", source, found)
end
addEvent("requestUsernameCacheFromServer", true)
addEventHandler("requestUsernameCacheFromServer", root, requestUsernameCacheFromServer)

function getUsernameFromID(id)
	if not id or not tonumber(id) then
		return false
	else
		id = tonumber(id)
	end

	if usernameCache[id] then
		return usernameCache[id]
	end

	for _, player in pairs(getElementsByType("player")) do
		if id == getElementData(player, "account_id") then
			usernameCache[id] = getElementData(player, "account_username")
			return usernameCache[id]
		end
	end

	if searched[id] then
		return false
	end
	searched[id] = true

	dbQuery(function(queryHandle)
		local result = dbPoll(queryHandle, 0)
		if result and #result > 0 then
			local row = result[1]
			local username = row["username"]
			if username then
				usernameCache[id] = username
				for _, player in pairs(getElementsByType("player")) do
					triggerClientEvent(player, "retrieveUsernameCacheFromServer", resourceRoot, username, id)
				end
			end
		end
	end, mysql:getConnection(), "SELECT `username`, `id` FROM `accounts` WHERE `id` = ? LIMIT 1", id)

	setTimer(function()
		searched[id] = nil
	end, refreshCacheRate * 1000 * 60, 1)

	return false
end

local accountCache = {}
local accountCacheSearched = {}

function getAccountFromCharacterID(id)
	if id and tonumber(id) then
		id = tonumber(id)
	else
		return false
	end

	if accountCache[id] then
		return accountCache[id]
	end

	for _, player in pairs(getElementsByType("player")) do
		if getElementData(player, "dbid") == id then
			accountCache[id] =
				{ id = getElementData(player, "account_id"), username = getElementData(player, "account_username") }
			return accountCache[id]
		end
	end

	if accountCacheSearched[id] then
		return false
	end
	accountCacheSearched[id] = true

	dbQuery(
		function(queryHandle)
			local result = dbPoll(queryHandle, 0)
			if result and #result > 0 then
				local row = result[1]
				local accountID = tonumber(row["id"])
				local username = row["username"]
				if accountID and username then
					accountCache[id] = { id = accountID, username = username }
					for _, player in pairs(getElementsByType("player")) do
						triggerClientEvent(player, "retrieveAccountCacheFromServer", resourceRoot, accountCache[id], id)
					end
				end
			end
		end,
		mysql:getConnection(),
		"SELECT a.id AS id, username FROM accounts a LEFT JOIN characters c ON a.id = c.account_id WHERE c.id = ? LIMIT 1",
		id
	)

	setTimer(function()
		accountCacheSearched[id] = nil
	end, refreshCacheRate * 1000 * 60, 1)

	return false
end

addEvent("fetchUsernameFromAccountID", true)
addEventHandler("fetchUsernameFromAccountID", root, function(id)
	local found = getUsernameFromID(id)
	triggerClientEvent(client, "foundUsernameFromAccountID", source, id, found)
end)
