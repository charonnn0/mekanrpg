atms = {}

addEventHandler("onResourceStart", resourceRoot, function()
	local result = dbPoll(dbQuery(exports.mek_mysql:getConnection(), "SELECT * FROM atms"), -1)
	for _, row in ipairs(result) do
		atms[row.id] = createObject(2942, row.x, row.y, row.z, 0, 0, row.rotation)
		setElementInterior(atms[row.id], row.interior)
		setElementDimension(atms[row.id], row.dimension)
		setElementFrozen(atms[row.id], true)
		setObjectBreakable(atms[row.id], false)
		setElementData(atms[row.id], "atm", true)
		setElementData(atms[row.id], "dbid", row.id)
		setElementData(atms[row.id], "interaction", {
			callbackEvent = "atm.onInteraction",
			args = {},
			description = "ATM",
		})
	end
end)

function addBankHistory(player, actionType, amount)
	local characterID = getElementData(player, "dbid")
	if not characterID then
		return
	end

	dbExec(
		exports.mek_mysql:getConnection(),
		"INSERT INTO `bank_history` (`character_id`, `action`, `amount`, `timestamp`) VALUES (?, ?, ?, NOW())",
		characterID,
		actionType,
		amount
	)
end

function addBankHistoryByID(characterID, actionType, amount)
	if not characterID then
		return
	end

	dbExec(
		exports.mek_mysql:getConnection(),
		"INSERT INTO `bank_history` (`character_id`, `action`, `amount`, `timestamp`) VALUES (?, ?, ?, NOW())",
		characterID,
		actionType,
		amount
	)
end
