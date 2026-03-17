local hostname = "localhost"
local username = "root"
local password = "ahmet123"
local database = "mekanrp"
local port = 3306

local connection = nil

addEventHandler("onResourceStart", resourceRoot, function()
	connection =
		dbConnect("mysql", "dbname=" .. database .. ";host=" .. hostname, username, password, "autoreconnect=1")
	if connection then
		outputDebugString("[MySQL] Successfully connected to database.")
	else
		outputDebugString("[MySQL] Failed to connect to database.")
	end
end)

function getConnection()
	return connection
end

function getSmallestID(tableName)
	if not tableName then
		return false
	end

	local query = dbQuery(
		connection,
		string.format(
			[[
        SELECT MIN(t1.id + 1) AS nextID
        FROM %s t1
        LEFT JOIN %s t2 ON t1.id + 1 = t2.id
        WHERE t2.id IS NULL
    ]],
			tableName,
			tableName
		)
	)

	local result = dbPoll(query, -1)
	if result and result[1] then
		return tonumber(result[1].nextID) or 1
	end

	return false
end
