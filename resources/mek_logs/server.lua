function addLog(logType, message)
	if logType and message then
		local time = getRealTime()
		local timestamp = string.format(
			"%04d-%02d-%02d %02d:%02d:%02d",
			time.year + 1900,
			time.month + 1,
			time.monthday,
			time.hour,
			time.minute,
			time.second
		)

		dbExec(
			exports.mek_mysql:getConnection(),
			"INSERT INTO logs (log_type, message, timestamp) VALUES (?, ?, ?)",
			logType,
			message,
			timestamp
		)

		triggerClientEvent(root, "logs.newLog", root, {
			log_type = logType,
			message = message,
			timestamp = timestamp,
		})
	end
end

addEvent("logs.fetchLogs", true)
addEventHandler("logs.fetchLogs", root, function(page, pageSize, logType, startDate, endDate, keyword)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not exports.mek_integration:isPlayerManager(client) then
		return
	end

	local startIndex = (page - 1) * pageSize
	local query = "SELECT * FROM logs WHERE 1 = 1"
	local params = {}

	if logType and logType ~= "Tümü" then
		query = query .. " AND log_type = ?"
		table.insert(params, logType)
	end

	if startDate ~= "" then
		query = query .. " AND timestamp >= ?"
		table.insert(params, startDate)
	end

	if endDate ~= "" then
		query = query .. " AND timestamp <= ?"
		table.insert(params, endDate)
	end

	if keyword ~= "" then
		query = query .. " AND message LIKE ?"
		table.insert(params, "%" .. keyword .. "%")
	end

	query = query .. " ORDER BY timestamp DESC LIMIT ? OFFSET ?"
	table.insert(params, pageSize)
	table.insert(params, startIndex)

	dbQuery(function(queryHandle, client)
		local result = dbPoll(queryHandle, 0)
		if result then
			triggerClientEvent(client, "logs.receiveLogs", client, result)
		else
			triggerClientEvent(client, "logs.receiveLogs", client, {})
		end
	end, { client }, exports.mek_mysql:getConnection(), query, unpack(params))
end)

addEvent("logs.fetchLogTypes", true)
addEventHandler("logs.fetchLogTypes", root, function()
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not exports.mek_integration:isPlayerManager(client) then
		return
	end

	dbQuery(function(queryHandle, client)
		local result = dbPoll(queryHandle, 0)
		if result then
			local types = {}
			for _, row in ipairs(result) do
				table.insert(types, row.log_type)
			end
			triggerClientEvent(client, "logs.receiveLogTypes", client, types)
		end
	end, { source }, exports.mek_mysql:getConnection(), "SELECT DISTINCT log_type FROM logs")
end)
