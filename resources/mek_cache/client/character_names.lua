local characterNameCache = {}
local searched = {}
local refreshCacheRate = 10

local pendingRequests = {}
local requestTimer = nil

function sendPendingRequests()
	if #pendingRequests > 0 then
		triggerServerEvent("requestCharacterNameCacheFromServer", localPlayer, pendingRequests)
		pendingRequests = {}
		requestTimer = nil
	end
end

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
			characterNameCache[id] = getPlayerName(player):gsub("_", " ")
			return characterNameCache[id]
		end
	end

	if searched[id] then
		return false
	end
	searched[id] = true

	table.insert(pendingRequests, id)
	
	if not requestTimer then
		requestTimer = setTimer(sendPendingRequests, 50, 1)
	end

	setTimer(function()
		local index = id
		searched[index] = nil
	end, refreshCacheRate * 1000 * 60, 1)

	return "Yükleniyor..."
end

function retrieveCharacterNameCacheFromServer(characterName, id)
	if characterName and id then
		characterNameCache[id] = characterName
	end
end
addEvent("retrieveCharacterNameCacheFromServer", true)
addEventHandler("retrieveCharacterNameCacheFromServer", root, retrieveCharacterNameCacheFromServer)
