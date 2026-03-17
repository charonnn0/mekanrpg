function createPhoneNumberForCharacter(characterID)
	if not characterID then
		return false
	end

	local phoneNumber = generateUniquePhoneNumber()
	if not phoneNumber then
		return false
	end

	local insertQuery = dbExec(
		exports.mek_mysql:getConnection(),
		"INSERT INTO `phones` (`character_id`, `phone_number`) VALUES (?, ?)",
		characterID,
		phoneNumber
	)
	if insertQuery then
		return phoneNumber
	end

	return false
end

function generateUniquePhoneNumber()
	local maxAttempts = 50
	local attempt = 0

	while attempt < maxAttempts do
		attempt = attempt + 1

		local prefix = math.random(500, 599)
		local mid = math.random(100, 999)
		local last = math.random(1000, 9999)
		local phoneNumber = tonumber(string.format("%d%03d%04d", prefix, mid, last))

		local query = dbQuery(
			exports.mek_mysql:getConnection(),
			"SELECT `phone_number` FROM `phones` WHERE `phone_number` = ?",
			phoneNumber
		)
		local result = dbPoll(query, -1)

		if result and #result == 0 then
			return phoneNumber
		end
	end

	return false
end

function getPlayerByPhoneNumber(targetPhoneNumber)
	for _, player in ipairs(getElementsByType("player")) do
		if player:getData("logged") then
			local hasPhone, _, phoneNumber = exports.mek_item:hasItem(player, 2)
			if hasPhone and tonumber(phoneNumber) == targetPhoneNumber then
				return player
			end
		end
	end
	return false
end