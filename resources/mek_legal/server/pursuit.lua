local supportPlayers = {}
local followPlayers = {}

local function getFactionColor(factionID)
	if factionID == 1 then
		return 65, 65, 255
	elseif factionID == 2 then
		return 255, 130, 130
	elseif factionID == 3 then
		return 0, 80, 0
	end
	return 255, 255, 255
end

local function getPlayerFactionID(thePlayer)
	local factionDetails = getElementData(thePlayer, "faction")
	if type(factionDetails) ~= "table" then
		return nil
	end

	for id in pairs(factionDetails) do
		if exports.mek_faction:isPlayerInFaction(thePlayer, id) then
			return id
		end
	end
	return nil
end

local function toggleCallType(thePlayer, callTable, eventName, callLabel, reason)
	local factionID = getPlayerFactionID(thePlayer)
	if not factionID or factionID < 1 or factionID > 3 then
		outputChatBox("[!]#FFFFFF Bu işlemi yalnızca legal birlik üyeleri yapabilir.", thePlayer, 255, 0, 0, true)
		return
	end

	local isActive = callTable[thePlayer]
	local actionState = not isActive
	local message = isActive and "kapattı." or "açtı."

	local r, g, b = getFactionColor(factionID)

	local theTeam = exports.mek_faction:getFactionFromID(factionID)
	local factionRanks = getElementData(theTeam, "ranks") or {}
	local playerFactionRank = exports.mek_faction:getPlayerFactionRank(thePlayer, factionID)
	local factionRankTitle = factionRanks[playerFactionRank] or "Bilinmeyen"
	local playerName = getPlayerName(thePlayer):gsub("_", " ")

	for _, player in ipairs(getElementsByType("player")) do
		local pFactionID = getPlayerFactionID(player)
		if pFactionID and pFactionID >= 1 and pFactionID <= 3 then
			triggerClientEvent(player, eventName, player, actionState, thePlayer, reason, factionID)

			local msgText
			if eventName == "legal.pursuit.panic" and actionState then
				msgText = "[OPERATÖR] "
					.. factionRankTitle
					.. " "
					.. playerName
					.. " panik butonuna bastı, tüm birimler desteğe yönelsin!"
			else
				msgText = "[OPERATÖR] "
					.. factionRankTitle
					.. " "
					.. playerName
					.. " "
					.. callLabel
					.. " çağrısını "
					.. message
			end

			outputChatBox(msgText, player, r, g, b, true)
		end
	end

	callTable[thePlayer] = actionState and true or nil
end

function supportCommand(thePlayer, _, ...)
	local reason = table.concat({ ... }, " ")
	toggleCallType(thePlayer, supportPlayers, "legal.pursuit.support", "destek", reason)
end
addCommandHandler("destek", supportCommand, false, false)

function followCommand(thePlayer, _, ...)
	local reason = table.concat({ ... }, " ")
	toggleCallType(thePlayer, followPlayers, "legal.pursuit.follow", "takip", reason)
end
addCommandHandler("takip", followCommand, false, false)

function panicCommand(thePlayer, _, ...)
	local reason = table.concat({ ... }, " ")
	toggleCallType(thePlayer, supportPlayers, "legal.pursuit.panic", "panik", reason)
end
addCommandHandler("panik", panicCommand, false, false)

addEventHandler("onPlayerQuit", root, function()
	local factionID = getPlayerFactionID(source)
	if not factionID then
		return
	end

	local r, g, b = getFactionColor(factionID)
	local playerName = exports.mek_global:getPlayerName(source)

	local function notifyEnd(callTable, eventName, label)
		if callTable[source] then
			for _, player in ipairs(getElementsByType("player")) do
				local pFactionID = getPlayerFactionID(player)
				if pFactionID and pFactionID >= 1 and pFactionID <= 3 then
					triggerClientEvent(player, eventName, player, false, source)
					outputChatBox(
						"[OPERATÖR] " .. playerName .. " isimli kişi " .. label .. " çağrısını kapattı.",
						player,
						r,
						g,
						b,
						true
					)
				end
			end
			callTable[source] = nil
		end
	end

	notifyEnd(supportPlayers, "legal.support", "destek")
	notifyEnd(followPlayers, "legal.follow", "takip")
end)

addEventHandler("onElementDataChange", root, function(dataName, oldValue)
	if dataName ~= "faction" then
		return
	end

	local thePlayer = source
	local oldFactionID, newFactionID

	if type(oldValue) == "table" then
		for id in pairs(oldValue) do
			oldFactionID = id
			break
		end
	end

	newFactionID = getPlayerFactionID(thePlayer)

	if not newFactionID or newFactionID < 1 or newFactionID > 3 then
		local r, g, b = 255, 255, 255
		if oldFactionID then
			r, g, b = getFactionColor(oldFactionID)
		end

		local function forceEnd(callTable, eventName, label)
			if callTable[thePlayer] then
				callTable[thePlayer] = nil
				for _, player in ipairs(getElementsByType("player")) do
					local pFactionID = getPlayerFactionID(player)
					if pFactionID and pFactionID >= 1 and pFactionID <= 3 then
						local playerName = exports.mek_global:getPlayerName(thePlayer)
						triggerClientEvent(player, eventName, player, false, thePlayer)
						outputChatBox(
							"[OPERATÖR] " .. playerName .. " isimli kişinin " .. label .. " çağrısı kapatıldı.",
							player,
							r,
							g,
							b,
							true
						)
					end
				end
			end
		end

		forceEnd(supportPlayers, "legal.pursuit.support", "destek")
		forceEnd(followPlayers, "legal.pursuit.follow", "takip")
		forceEnd(supportPlayers, "legal.pursuit.panic", "panik")

		for player, _ in pairs(supportPlayers) do
			if isElement(player) then
				triggerClientEvent(thePlayer, "legal.pursuit.support", thePlayer, false, player)
				triggerClientEvent(thePlayer, "legal.pursuit.panic", thePlayer, false, player)
			end
		end

		for player, _ in pairs(followPlayers) do
			if isElement(player) then
				triggerClientEvent(thePlayer, "legal.pursuit.follow", thePlayer, false, player)
			end
		end
	else
		for player, _ in pairs(supportPlayers) do
			if isElement(player) then
				triggerClientEvent(
					thePlayer,
					"legal.pursuit.support",
					thePlayer,
					true,
					player,
					"",
					getPlayerFactionID(player)
				)
			end
		end

		for player, _ in pairs(followPlayers) do
			if isElement(player) then
				triggerClientEvent(
					thePlayer,
					"legal.pursuit.follow",
					thePlayer,
					true,
					player,
					"",
					getPlayerFactionID(player)
				)
			end
		end
	end
end)
