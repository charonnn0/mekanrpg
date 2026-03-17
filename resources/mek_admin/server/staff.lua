local staffTitles = exports.mek_integration:getStaffTitles()

function getStaffInfo(username, error)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return false
	end

	local userQuery = dbPrepareString(
		exports.mek_mysql:getConnection(),
		"SELECT id, username, admin_level, manager_level FROM accounts WHERE username = ?",
		username
	)
	local userResultHandle = dbQuery(exports.mek_mysql:getConnection(), userQuery)
	local userResult = dbPoll(userResultHandle, -1)
	local user = userResult and userResult[1] or nil
	dbFree(userResultHandle)

	if not user then
		outputChatBox("[!]#FFFFFF Kullanıcı bulunamadı.", client, 255, 0, 0, true)
		return
	end

	local changelogs = {}
	local changelogsQuery = dbPrepareString(
		exports.mek_mysql:getConnection(),
		"SELECT (CASE WHEN to_rank > from_rank THEN 1 ELSE 0 END) AS promoted, s.id, a1.username, team, from_rank, to_rank, a2.username AS `by`, details, DATE_FORMAT(date,'%b %d, %Y %h:%i %p') AS date FROM staff_changelogs s LEFT JOIN accounts a1 ON s.userid = a1.id LEFT JOIN accounts a2 ON s.`by` = a2.id WHERE s.userid = ? ORDER BY id DESC",
		user.id
	)
	local changelogsResultHandle = dbQuery(exports.mek_mysql:getConnection(), changelogsQuery)
	local changelogsResult = dbPoll(changelogsResultHandle, -1)
	dbFree(changelogsResultHandle)

	if changelogsResult then
		for _, row in ipairs(changelogsResult) do
			table.insert(changelogs, row)
		end
	end

	local staffInfo = {
		user = user,
		changelogs = changelogs,
		error = error,
	}

	triggerClientEvent(client, "staff.openStaffManager", client, staffInfo)
end
addEvent("staff.getStaffInfo", true)
addEventHandler("staff.getStaffInfo", root, getStaffInfo)

function getTeamsData()
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return false
	end

	local staffTitles = exports.mek_integration:getStaffTitles()
	local users = {}

	local queryString = [[
        SELECT a.id, username, admin_level, manager_level, admin_reports, last_login
        FROM accounts a
        WHERE admin_level > 0 OR manager_level > 0
        GROUP BY a.id
        ORDER BY admin_level DESC, admin_reports DESC, manager_level DESC
    ]]

	local queryHandle = dbQuery(exports.mek_mysql:getConnection(), queryString)
	local result = dbPoll(queryHandle, -1)
	dbFree(queryHandle)

	if result then
		for _, row in ipairs(result) do
			for i, title in ipairs(staffTitles) do
				if not users[i] then
					users[i] = {}
				end

				if tonumber(row.admin_level) > 0 and i == 1 then
					if not row.rank then
						row.rank = {}
					end
					row.rank[i] = tonumber(row.admin_level)
					table.insert(users[i], row)
				end

				if tonumber(row.manager_level) > 0 and i == 2 then
					if not row.rank then
						row.rank = {}
					end
					row.rank[i] = tonumber(row.manager_level)
					table.insert(users[i], row)
				end
			end
		end
	end

	triggerClientEvent(client, "staff.openStaffManager", client, nil, users)
end
addEvent("staff.getTeamsData", true)
addEventHandler("staff.getTeamsData", root, getTeamsData)

function getChangelogs()
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return false
	end

	local changelogs = {}

	local queryString = [[
        SELECT 
            (CASE WHEN to_rank > from_rank THEN 1 ELSE 0 END) AS promoted, 
            s.id, 
            a1.username, 
            team, 
            from_rank, 
            to_rank, 
            a2.username AS `by`, 
            details, 
            DATE_FORMAT(date, '%b %d, %Y %h:%i %p') AS date 
        FROM staff_changelogs s 
        LEFT JOIN accounts a1 ON s.userid = a1.id 
        LEFT JOIN accounts a2 ON s.`by` = a2.id 
        ORDER BY id DESC
    ]]

	local queryHandle = dbQuery(exports.mek_mysql:getConnection(), queryString)
	local result = dbPoll(queryHandle, -1)
	dbFree(queryHandle)

	if result then
		for _, row in ipairs(result) do
			table.insert(changelogs, row)
		end
	end

	triggerClientEvent(client, "staff.openStaffManager", client, nil, nil, changelogs)
end
addEvent("staff.getChangelogs", true)
addEventHandler("staff.getChangelogs", root, getChangelogs)

function editStaff(userid, ranks, details)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return false
	end

	if not exports.mek_integration:isPlayerManager(client) then
		return false
	end

	local error = nil
	if not userid or not tonumber(userid) then
		outputChatBox("[!]#FFFFFF Bir sorun oluştu.", client, 255, 0, 0, true)
		return false
	else
		userid = tonumber(userid)
	end

	local target = nil
	for _, player in ipairs(getElementsByType("player")) do
		if getElementData(player, "account_id") == userid then
			target = player
			break
		end
	end

	local staffTitles = exports.mek_integration:getStaffTitles()
	local queryString = "SELECT id, username, admin_level, manager_level FROM accounts WHERE id = ?"
	local user = dbPoll(dbQuery(exports.mek_mysql:getConnection(), queryString, userid), -1)[1]
	local tail = ""

	if not user then
		outputChatBox("[!]#FFFFFF Kullanıcı bulunamadı.", client, 255, 0, 0, true)
		return false
	end

	if details and #details > 0 then
		details = dbPrepareString(exports.mek_mysql:getConnection(), details)
	else
		details = nil
	end

	local changes = {
		{ field = "admin_level", rank = ranks[1], team = 1 },
		{ field = "manager_level", rank = ranks[2], team = 2 },
	}

	for _, change in ipairs(changes) do
		if change.rank and change.rank ~= tonumber(user[change.field]) then
			tail = tail .. change.field .. " = " .. change.rank .. ","
			local query =
				"INSERT INTO staff_changelogs SET userid = ?, details = ?, `by` = ?, team = ?, from_rank = ?, to_rank = ?, `date` = NOW()"
			dbExec(
				exports.mek_mysql:getConnection(),
				query,
				userid,
				details,
				getElementData(client, "account_id"),
				change.team,
				user[change.field],
				change.rank
			)
			exports.mek_global:sendMessageToAdmins(
				"[YETKİ] "
					.. exports.mek_global:getPlayerFullAdminTitle(client)
					.. " isimli yetkili "
					.. user.username
					.. " isimli kullanıcıyı "
					.. staffTitles[change.team][tonumber(user[change.field])]
					.. " yetkisinden "
					.. staffTitles[change.team][change.rank]
					.. " yetkisine "
					.. (change.rank > tonumber(user[change.field]) and "yükseldi" or "düşürdü")
					.. ".",
				true
			)
			exports.mek_logs:addLog(
				"yetki",
				exports.mek_global:getPlayerFullAdminTitle(client)
					.. " isimli yetkili "
					.. user.username
					.. " isimli kullanıcıyı "
					.. staffTitles[change.team][tonumber(user[change.field])]
					.. " yetkisinden "
					.. staffTitles[change.team][change.rank]
					.. " yetkisine "
					.. (change.rank > tonumber(user[change.field]) and "yükseldi" or "düşürdü")
					.. "."
			)
			if target then
				setElementData(target, change.field, change.rank)
			end
		end
	end

	if tail ~= "" then
		tail = string.sub(tail, 1, #tail - 1)
		local updateQuery = "UPDATE accounts SET " .. tail .. " WHERE id = ?"
		if not dbExec(exports.mek_mysql:getConnection(), updateQuery, userid) then
			outputChatBox("[!]#FFFFFF Bir sorun oluştu.", client, 255, 0, 0, true)
			return false
		end
	end

	triggerEvent("staff.getStaffInfo", client, user.username, user.username .. " isimli oyuncunun yetkisi ayarlandı.")
end
addEvent("staff.editStaff", true)
addEventHandler("staff.editStaff", root, editStaff)
