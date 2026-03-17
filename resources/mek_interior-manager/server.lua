local mysql = exports.mek_mysql

function getAllInts(thePlayer, commandName, ...)
	if not exports.mek_integration:isPlayerManager(thePlayer) then
		return
	end

	local interiorsList = {}

	local query = [[
		SELECT 
			factions.name AS fowner, 
			interiors.id AS iID, 
			interiors.type AS type, 
			interiors.name AS name, 
			cost, 
			characters.name AS characterName, 
			cked, 
			locked, 
			address, 
			supplies, 
			safepositionX, 
			disabled, 
			deleted, 
			interiors.createdDate AS iCreatedDate, 
			interiors.creator AS iCreator, 
			DATEDIFF(NOW(), last_used) AS DiffDate, 
			interiors.x, 
			interiors.y, 
			interiors.z 
		FROM interiors 
		LEFT JOIN characters ON interiors.owner = characters.id 
		LEFT JOIN factions ON interiors.faction = factions.id 
		ORDER BY interiors.createdDate DESC
	]]

	dbQuery(function(qh)
		local result = dbPoll(qh, 0)
		if result then
			for _, row in ipairs(result) do
				table.insert(interiorsList, {
					row["iID"],
					row["type"],
					row["name"],
					row["cost"],
					row["characterName"],
					row["username"],
					row["cked"],
					row["DiffDate"],
					row["locked"],
					row["supplies"],
					row["safepositionX"],
					row["disabled"],
					row["deleted"],
					"",
					row["iCreatedDate"],
					row["iCreator"],
					row["x"],
					row["y"],
					row["z"],
					row["fowner"],
					row["address"],
				})
			end
		end

		triggerClientEvent(
			thePlayer,
			"createIntManagerWindow",
			thePlayer,
			interiorsList,
			getElementData(thePlayer, "account_username")
		)
	end, exports.mek_mysql:getConnection(), query)
end
addCommandHandler("interiors", getAllInts)
addCommandHandler("ints", getAllInts)

function delIntCmd(intID)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	executeCommandHandler("delint", client, intID)
end
addEvent("interiorManager.delint", true)
addEventHandler("interiorManager.delint", root, delIntCmd)

function disableInt(intID)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	executeCommandHandler("toggleinterior", client, intID)
end
addEvent("interiorManager.disableInt", true)
addEventHandler("interiorManager.disableInt", root, disableInt)

function gotoInt(intID)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	executeCommandHandler("gotohouse", client, intID)
end
addEvent("interiorManager.gotoInt", true)
addEventHandler("interiorManager.gotoInt", root, gotoInt)

function restoreInt(intID)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	executeCommandHandler("restoreInt", client, intID)
end
addEvent("interiorManager.restoreInt", true)
addEventHandler("interiorManager.restoreInt", root, restoreInt)

function removeInt(intID)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	executeCommandHandler("removeint", client, intID)
end
addEvent("interiorManager.removeInt", true)
addEventHandler("interiorManager.removeInt", root, removeInt)

function forceSellInt(intID)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	executeCommandHandler("fsell", client, intID)
end
addEvent("interiorManager.forceSellInt", true)
addEventHandler("interiorManager.forceSellInt", root, forceSellInt)

function openAdminNote(intID)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	executeCommandHandler("checkint", client, intID)
end
addEvent("interiorManager.openAdminNote", true)
addEventHandler("interiorManager.openAdminNote", root, openAdminNote)

function interiorSearch(keyword)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not (keyword and keyword ~= "" and keyword ~= "Ara...") then
		return
	end

	local interiorsResultList = {}

	local query = [[
		SELECT 
			characters.account_id AS accID, 
			factions.name AS fowner, 
			interiors.id AS iID, 
			interiors.type AS type, 
			interiors.name AS name, 
			cost, 
			characters.name AS characterName, 
			cked, 
			locked, 
			address, 
			supplies, 
			safepositionX, 
			disabled, 
			deleted, 
			interiors.createdDate AS iCreatedDate, 
			interiors.creator AS iCreator, 
			DATEDIFF(NOW(), last_used) AS DiffDate, 
			interiors.x, 
			interiors.y, 
			interiors.z 
		FROM interiors 
		LEFT JOIN characters ON interiors.owner = characters.id 
		LEFT JOIN factions ON interiors.faction = factions.id 
		WHERE interiors.id LIKE ? 
			OR interiors.name LIKE ? 
			OR factions.name LIKE ? 
			OR cost LIKE ? 
			OR characters.name LIKE ? 
			OR interiors.creator LIKE ? 
		ORDER BY interiors.createdDate DESC
	]]

	local likeKeyword = "%" .. keyword .. "%"

	dbQuery(
		function(qh)
			local result = dbPoll(qh, 0)
			if result then
				for _, row in ipairs(result) do
					table.insert(interiorsResultList, {
						row["iID"],
						row["type"],
						row["name"],
						row["cost"],
						row["characterName"],
						row["accID"],
						row["cked"],
						row["DiffDate"],
						row["locked"],
						row["supplies"],
						row["safepositionX"],
						row["disabled"],
						row["deleted"],
						"",
						row["iCreatedDate"],
						row["iCreator"],
						row["x"],
						row["y"],
						row["z"],
						row["fowner"],
						row["address"],
					})
				end
			end

			triggerClientEvent(
				client,
				"interiorManager.FetchSearchResults",
				client,
				interiorsResultList,
				getElementData(client, "account_username")
			)
		end,
		exports.mek_mysql:getConnection(),
		query,
		likeKeyword,
		likeKeyword,
		likeKeyword,
		likeKeyword,
		likeKeyword,
		likeKeyword
	)
end
addEvent("interiorManager.Search", true)
addEventHandler("interiorManager.Search", root, interiorSearch)

function checkInt(thePlayer, commandName, intID)
	if exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
		if not tonumber(intID) or tonumber(intID) <= 0 or tonumber(intID) % 1 ~= 0 then
			intID = getElementDimension(thePlayer)
			if intID == 0 then
				outputChatBox("You must be inside an interior.", thePlayer, 255, 194, 14)
				outputChatBox("Or use Kullanım: /" .. commandName .. " [Interior ID]", thePlayer, 255, 194, 14)
				return false
			end
		end

		local query1 = dbQuery(
			exports.mek_mysql:getConnection(),
			"SELECT characters.account_id AS accID, factions.name AS fowner, interiors.id AS iID, interiors.type AS type, interiors.name AS name, cost, characters.name AS characterName, cked, locked, address, safepositionX, safepositionY, safepositionZ, disabled, deleted, tokenUsed, interiors.createdDate AS iCreatedDate, interiors.creator AS iCreator, DATEDIFF(NOW(), last_used) AS DiffDate, interiors.x AS x, interiors.y AS y, interiors.z AS z FROM interiors LEFT JOIN characters ON interiors.owner = characters.id LEFT JOIN factions ON interiors.faction=factions.id WHERE interiors.id = ? ORDER BY interiors.createdDate DESC",
			intID
		)
		local result1 = dbPoll(query1, -1)

		if result1 and #result1 > 0 then
			local row = result1[1]

			local result = {
				row.iID,
				row.type,
				row.name,
				row.cost,
				row.characterName,
				row.accID,
				row.cked,
				row.DiffDate,
				row.locked,
				nil,
				row.safepositionX,
				row.safepositionY,
				row.safepositionZ,
				row.disabled,
				row.deleted,
				"",
				row.iCreatedDate,
				row.iCreator,
				row.x,
				row.y,
				row.z,
				row.fowner,
				row.tokenUsed,
				row.address,
			}

			local logsQuery = dbQuery(
				exports.mek_mysql:getConnection(),
				"SELECT date, intID, action, actor AS admin, log_id AS logid FROM interior_logs WHERE intID = ? ORDER BY date DESC",
				intID
			)
			local logsResult = dbPoll(logsQuery, -1)
			local logs = {}

			for _, row2 in ipairs(logsResult or {}) do
				table.insert(logs, {
					row2.date,
					row2.action,
					exports.mek_cache:getUsernameFromID(row2.admin) or "Bilinmiyor",
					row2.logid,
					row2.intID,
				})
			end

			local notesQuery = dbQuery(
				exports.mek_mysql:getConnection(),
				"SELECT id, note, date, creator FROM interior_notes WHERE intid = ? ORDER BY date DESC",
				intID
			)
			local notesResult = dbPoll(notesQuery, -1)
			local notes = {}

			for _, row3 in ipairs(notesResult or {}) do
				row3.creatorname = formatCreator(exports.mek_cache:getUsernameFromID(row3.creator), row3.creator)
				table.insert(notes, row3)
			end

			local playersQuery = dbQuery(
				exports.mek_mysql:getConnection(),
				"SELECT characters.account_id AS accID, characters.name AS characterName, characters.last_login AS last_login FROM characters WHERE characters.dimension = ?",
				intID
			)
			local playersResult = dbPoll(playersQuery, -1)
			local players = {}

			for _, row4 in ipairs(playersResult or {}) do
				table.insert(players, {
					exports.mek_cache:getUsernameFromID(row4.accID),
					row4.characterName,
					row4.last_login,
				})
			end

			triggerClientEvent(
				thePlayer,
				"createCheckIntWindow",
				thePlayer,
				{ result },
				exports.mek_global:getPlayerAdminTitle(thePlayer),
				logs,
				notes,
				players
			)
		else
			outputChatBox("Interior ID doesn't exist!", thePlayer, 255, 0, 0)
		end
	end
end
addCommandHandler("checkint", checkInt)
addCommandHandler("checkinterior", checkInt)
addEvent("interiorManager.checkint", true)
addEventHandler("interiorManager.checkint", root, checkInt)

function formatCreator(creator, creatorId)
	if creator and creatorId then
		if creator == nil then
			if creatorId == "0" then
				return "SYSTEM"
			else
				return "Bilinmiyor"
			end
		else
			return creator
		end
	else
		return "Bilinmiyor"
	end
end

function saveAdminNote(intID, adminNote, noteId)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not exports.mek_integration:isPlayerTrialAdmin(client) then
		return false
	end

	if not intID or not adminNote then
		return false
	end

	if string.len(adminNote) > 500 then
		outputChatBox("Admin note has failed to add. Reason: Exceeded 500 characters.", source, 255, 0, 0)
		return false
	end

	local accountID = getElementData(source, "account_id")

	if noteId then
		local success = dbExec(
			exports.mek_mysql:getConnection(),
			"UPDATE interior_notes SET note = ?, creator = ? WHERE id = ? AND intid = ?",
			adminNote,
			accountID,
			noteId,
			intID
		)

		if success then
			outputChatBox(
				"You have successfully updated admin note entry #" .. noteId .. " on interior #" .. intID .. ".",
				source,
				0,
				255,
				0
			)
			addInteriorLogs(intID, "Modified admin note entry #" .. noteId, source)
			return true
		else
			outputChatBox("Failed to update the admin note.", source, 255, 0, 0)
			return false
		end
	else
		dbQuery(
			function(qh)
				local result, _, insertId = dbPoll(qh, 0)
				if insertId then
					outputChatBox(
						"You have successfully added a new admin note entry #"
							.. insertId
							.. " to interior #"
							.. intID
							.. ".",
						source,
						0,
						255,
						0
					)
					addInteriorLogs(intID, "Added new admin note entry #" .. insertId, source)
				else
					outputChatBox("Failed to add new admin note.", source, 255, 0, 0)
				end
			end,
			exports.mek_mysql:getConnection(),
			"INSERT INTO interior_notes (note, creator, intid) VALUES (?, ?, ?)",
			adminNote,
			accountID,
			intID
		)
	end
end
addEvent("interiorManager.saveAdminNote", true)
addEventHandler("interiorManager.saveAdminNote", root, saveAdminNote)

function setInteriorFaction(thePlayer, cmd, ...)
	if exports.mek_integration:isPlayerManager(thePlayer) then
		if not (...) then
			outputChatBox("Kullanım: /" .. cmd .. " [Faction Name or Faction ID]", thePlayer, 255, 194, 14)
			return
		end

		local dim = getElementDimension(thePlayer)
		if dim < 1 then
			outputChatBox("You must be inside an interior to perform this action.", thePlayer, 255, 0, 0)
			return
		end

		local clue = table.concat({ ... }, " ")
		local theFaction = nil
		if tonumber(clue) then
			theFaction = exports.mek_pool:getElementByID("team", tonumber(clue))
		else
			theFaction = exports.mek_faction:getFactionFromName(clue)
		end

		if not theFaction then
			outputChatBox("No faction found.", thePlayer, 255, 0, 0)
			return
		end

		local dbid, entrance, exit, interiorType, interiorElement = exports.mek_interior:findProperty(thePlayer)
		if not isElement(interiorElement) then
			outputChatBox("No interior found here.", thePlayer, 255, 0, 0)
			return
		end

		local can, reason = exports.mek_global:canFactionBuyInterior(theFaction)
		if not can then
			outputChatBox(reason, thePlayer, 255, 0, 0)
			return
		end

		local factionId = getElementData(theFaction, "id")
		local factionName = getTeamName(theFaction)
		local intName = getElementData(interiorElement, "name")

		if
			not dbExec(
				exports.mek_mysql:getConnection(),
				"UPDATE interiors SET owner='-1', faction='" .. factionId .. "', locked=0 WHERE id='" .. dbid .. "'"
			)
		then
			outputChatBox("Internal Error.", thePlayer, 255, 0, 0)
			return
		end

		exports.mek_item:deleteAll(interiorType == 1 and 5 or 4, dbid)
		exports.mek_item:giveItem(thePlayer, interiorType == 1 and 5 or 4, dbid)

		exports.mek_interior:realReloadInterior(tonumber(dbid))
		triggerClientEvent(thePlayer, "createBlipAtXY", thePlayer, entrance.type, entrance.x, entrance.y)
		exports.mek_global:sendMessageToAdmins(
			"[INTERIOR] "
				.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
				.. " transferred the ownership of interior '"
				.. intName
				.. "' ID #"
				.. dbid
				.. " to faction '"
				.. factionName
				.. "'."
		)
		return true
	end
end
addCommandHandler("setintfaction", setInteriorFaction, false, false)

function setInteriorToMyFaction(thePlayer, cmd, fID)
	fID = tonumber(fID)

	if not fID then
		outputChatBox("Kullanım: /" .. cmd .. " [Faction ID]", thePlayer, 255, 194, 14)
		return
	end

	local faction, _ = exports.mek_faction:isPlayerInFaction(thePlayer, fID)
	local leader = exports.mek_faction:hasMemberPermissionTo(thePlayer, fID, "manage_interiors")

	if not faction or not leader then
		outputChatBox("You must be a faction leader to perform this action.", thePlayer, 255, 0, 0)
		return
	end

	local dim = getElementDimension(thePlayer)
	if dim < 1 then
		outputChatBox("You must be inside an interior to perform this action.", thePlayer, 255, 0, 0)
		return
	end

	local theFaction = exports.mek_pool:getElementByID("team", fID)
	if not theFaction then
		outputChatBox("No faction found.", thePlayer, 255, 0, 0)
		return
	end

	local dbid, entrance, exit, interiorType, interiorElement = exports.mek_interior:findProperty(thePlayer)
	if not isElement(interiorElement) then
		outputChatBox("No interior found here.", thePlayer, 255, 0, 0)
		return
	end

	local charId = getElementData(thePlayer, "dbid")
	local intStatus = getElementData(interiorElement, "status")
	local intName = getElementData(interiorElement, "name")
	local factionName = getTeamName(theFaction)

	if intStatus.owner ~= charId then
		outputChatBox("You must own this interior to perform this action.", thePlayer, 255, 0, 0)
		return
	end

	local can, reason = exports.mek_global:canPlayerFactionBuyInterior(thePlayer, nil, fID)
	if not can then
		outputChatBox(reason, thePlayer, 255, 0, 0)
		return
	end

	if
		not dbExec(
			exports.mek_mysql:getConnection(),
			"UPDATE interiors SET owner='-1', faction='" .. fID .. "', locked=0 WHERE id='" .. dbid .. "'"
		)
	then
		outputChatBox("Internal Error.", thePlayer, 255, 0, 0)
		return
	end

	exports.mek_item:deleteAll(interiorType == 1 and 5 or 4, dbid)
	exports.mek_item:giveItem(thePlayer, interiorType == 1 and 5 or 4, dbid)

	exports.mek_interior:realReloadInterior(tonumber(dbid))
	triggerClientEvent(thePlayer, "createBlipAtXY", thePlayer, entrance.type, entrance.x, entrance.y)
	exports.mek_global:sendMessageToAdmins(
		"[INTERIOR] "
			.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
			.. " transferred the ownership of interior '"
			.. intName
			.. "' ID #"
			.. dbid
			.. " to his faction '"
			.. factionName
			.. "'."
	)
	outputChatBox("You've set this interior to faction " .. factionName .. ".", thePlayer, 0, 255, 0)
	return true
end
addCommandHandler("setinttomyfaction", setInteriorToMyFaction, false, false)

function addInteriorLogs(intID, action, actor, clearPreviousLogs)
	if intID and action then
		if clearPreviousLogs then
			dbExec(exports.mek_mysql:getConnection(), "DELETE FROM `interior_logs` WHERE `intID`=?", intID)
		end

		local adminID = nil
		if actor and isElement(actor) and getElementType(actor) == "player" then
			adminID = getElementData(actor, "account_id")
		elseif tonumber(actor) then
			adminID = tonumber(actor)
		end

		return dbExec(
			exports.mek_mysql:getConnection(),
			"INSERT INTO `interior_logs` SET `intID`=?, `action`=? " .. (adminID and (", `actor`=" .. adminID) or ""),
			intID,
			action
		)
	else
		outputDebugString("[INTERIOR MANAGER] Lack of agruments #1 or #2 for the function addInteriorLogs().")
		return false
	end
end
