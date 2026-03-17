function getLoggedInPlayers()
	local players = localPlayer and getElementsByType("player") or getElementsByType("player")

	local loggedInPlayers = {}

	for key, value in ipairs(players) do
		if value:getData("logged") then
			table.insert(loggedInPlayers, value)
		end
	end
	return loggedInPlayers
end

function getAdmins()
	local players = localPlayer and getElementsByType("player") or getElementsByType("player")

	local admins = {}

	for key, value in ipairs(players) do
		if value:getData("logged") and exports.mek_integration:isPlayerTrialAdmin(value) then
			table.insert(admins, value)
		end
	end
	return admins
end

function getAdminTitles()
	return exports.mek_integration:getAdminTitles()
end

function getAdminLevelTitle(number)
	if number and tonumber(number) then
		return adminTitles[number] or "Oyuncu"
	end
end

function getPlayerAdminLevel(thePlayer)
	if thePlayer and isElement(thePlayer) and getElementType(thePlayer) == "player" then
		return getElementData(thePlayer, "admin_level") or 0
	end
end

function getPlayerAdminTitle(thePlayer)
	if thePlayer and isElement(thePlayer) and getElementType(thePlayer) == "player" then
		local adminTitles = getAdminTitles()
		local adminTitle = adminTitles[getPlayerAdminLevel(thePlayer)] or "Oyuncu"
		return adminTitle
	end
end

function getPlayerFullAdminTitle(thePlayer)
	if thePlayer and isElement(thePlayer) and getElementType(thePlayer) == "player" then
		local adminTitle = (
			getPlayerAdminTitle(thePlayer)
			.. " "
			.. _getPlayerName(thePlayer):gsub("_", " ")
			.. " ("
			.. (getElementData(thePlayer, "account_username") or "?")
			.. ")"
		)
		return adminTitle
	end
end

function isAdminOnDuty(thePlayer)
	if thePlayer and isElement(thePlayer) and getElementType(thePlayer) == "player" then
		return exports.mek_integration:isPlayerTrialAdmin(thePlayer, true)
	end
	return false
end
