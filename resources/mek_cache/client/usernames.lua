local usernameCache = {}
local searched = {}
local searched1 = {}
local refreshCacheRate = 10

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
			table.insert(usernameCache, username)
			return username
		end
	end

	if not searched[clue] then
		triggerServerEvent("requestUsernameCacheFromServer", resourceRoot, clue)
		searched[clue] = true
		setTimer(function()
			local index = clue
			searched[index] = nil
		end, refreshCacheRate * 1000 * 60, 1)
	end

	return false
end

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

	if not searched1[id] or (getTickCount() - searched1[id]) > refreshCacheRate * 1000 * 60 then
		searched1[id] = getTickCount()
		triggerServerEvent("fetchUsernameFromAccountID", resourceRoot, id)
	end

	return false
end

addEvent("foundUsernameFromAccountID", true)
addEventHandler("foundUsernameFromAccountID", root, function(id, found)
	if found then
		usernameCache[id] = found
	end
end)

function retrieveUsernameCacheFromServer(clue)
	if clue then
		table.insert(usernameCache, clue)
	end
end
addEvent("retrieveUsernameCacheFromServer", true)
addEventHandler("retrieveUsernameCacheFromServer", root, retrieveUsernameCacheFromServer)
