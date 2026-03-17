local mysql = exports.mek_mysql

function getAllVehs(thePlayer, commandName, ...)
	if client then
		if client ~= source then
			exports.mek_sac:banForEventAbuse(client, eventName)
			return
		end
		thePlayer = client
	end

	if not thePlayer then
		return
	end

	if exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
		local vehicleList = {}
		local mQuery1 = nil

		dbQuery(
			function(queryHandle, thePlayer)
				local res, rows, err = dbPoll(queryHandle, 0)
				if rows > 0 then
					for index, row in ipairs(res) do
						table.insert(vehicleList, {
							row["vID"],
							row["type"],
							row["name"],
							row["cost"],
							row["name"],
							row["username"],
							row["cked"],
							row["DiffDate"],
							row["locked"],
							row["supplies"],
							row["safepositionX"],
							row["disabled"],
							row["deleted"],
							row["iAdminNote"],
							row["iCreatedDate"],
							row["iCreator"],
							row["`vehicles`.`x`"],
							row["`vehicles`.`y`"],
							row["`vehicles`.`z`"],
						})
					end
					triggerClientEvent(
						thePlayer,
						"createVehManagerWindow",
						thePlayer,
						vehicleList,
						getElementData(thePlayer, "account_username")
					)
				end
			end,
			{ thePlayer },
			mysql:getConnection(),
			"SELECT vehicles.id AS vID, type, name, cost, name, username, cked, locked, supplies, safepositionX, disabled, deleted, vehicles.adminnote AS iAdminNote, vehicles.createdDate AS iCreatedDate, vehicles.creator AS iCreator, DATEDIFF(NOW(), last_used) AS DiffDate, vehicles.x, vehicles.y, vehicles.y FROM vehicles LEFT JOIN characters ON vehicles.owner = characters.id LEFT JOIN accounts ON characters.account_id = accounts.id ORDER BY vehicles.createdDate DESC"
		)
	end
end
addEvent("vehicleManager.openIt", true)
addEventHandler("vehicleManager.openIt", root, getAllVehs)


function delVehCmd(vehID)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not exports.mek_integration:isPlayerManager(client) then
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", client, 255, 0, 0, true)
		return
	end

	executeCommandHandler("delveh", client, vehID)
end
addEvent("vehicleManager.delVeh", true)
addEventHandler("vehicleManager.delVeh", root, delVehCmd)

function gotoVeh(vehID)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not exports.mek_integration:isPlayerManager(client) then
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", client, 255, 0, 0, true)
		return
	end

	executeCommandHandler("gotocar", client, vehID)
end
addEvent("vehicleManager.gotoVeh", true)
addEventHandler("vehicleManager.gotoVeh", root, gotoVeh)

function restoreVeh(vehID)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not exports.mek_integration:isPlayerManager(client) then
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", client, 255, 0, 0, true)
		return
	end

	executeCommandHandler("restoreveh", client, vehID)
end
addEvent("vehicleManager.restoreVeh", true)
addEventHandler("vehicleManager.restoreVeh", root, restoreVeh)

function removeVeh(vehID)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not exports.mek_integration:isPlayerManager(client) then
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", client, 255, 0, 0, true)
		return
	end

	executeCommandHandler("removeveh", client, vehID)
end
addEvent("vehicleManager.removeVeh", true)
addEventHandler("vehicleManager.removeVeh", root, removeVeh)

function forceSellInt(vehID)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not exports.mek_integration:isPlayerManager(client) then
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", client, 255, 0, 0, true)
		return
	end

	executeCommandHandler("fsell", client, vehID)
end
addEvent("vehicleManager.forceSellInt", true)
addEventHandler("vehicleManager.forceSellInt", root, forceSellInt)

function openAdminNote(vehID)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not exports.mek_integration:isPlayerManager(client) then
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", client, 255, 0, 0, true)
		return
	end

	executeCommandHandler("checkint", client, vehID)
end
addEvent("vehicleManager.openAdminNote", true)
addEventHandler("vehicleManager.openAdminNote", root, openAdminNote)

function vehiclesearch(keyword)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not exports.mek_integration:isPlayerManager(client) then
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", client, 255, 0, 0, true)
		return
	end

	if keyword and keyword ~= "" and keyword ~= "Ara..." then
		local vehiclesResultList = {}
		local mQuery1 = nil
		dbQuery(
			function(queryHandle, client)
				local res, rows = dbPoll(queryHandle, 0)
				if rows > 0 then
					for index, row in ipairs(res) do
						table.insert(vehiclesResultList, row)
					end
					triggerClientEvent(
						client,
						"vehicleManager.fetchSearchResults",
						client,
						vehiclesResultList,
						getElementData(client, "account_username")
					)
				end
			end,
			{ client },
			mysql:getConnection(),
			"SELECT *, v.id AS id, TO_SECONDS(last_used) AS last_used_sec FROM vehicles v LEFT JOIN vehicles_shop s ON v.vehicle_shop_id=s.id LEFT JOIN characters c ON v.owner=c.id LEFT JOIN factions f ON v.faction=f.id WHERE v.id LIKE '%"
				.. keyword
				.. "%'  OR vehmtamodel LIKE '%"
				.. keyword
				.. "%' OR vehbrand LIKE '%"
				.. keyword
				.. "%' OR vehyear LIKE '%"
				.. keyword
				.. "%' OR c.name LIKE '%"
				.. keyword
				.. "%' OR f.name LIKE '%"
				.. keyword
				.. "%' OR f.name LIKE '%"
				.. keyword
				.. "%' ORDER BY v.id DESC"
		)
	end
end
addEvent("vehicleManager.search", true)
addEventHandler("vehicleManager.search", root, vehiclesearch)

function checkVeh(thePlayer, commandName, vehID)
	if exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
		if not tonumber(vehID) or (tonumber(vehID) <= 0) or (tonumber(vehID) % 1 ~= 0) then
			local veh = getPedOccupiedVehicle(thePlayer) or false
			vehID = isElement(veh) and getElementData(veh, "dbid") or false
			if not vehID then
				outputChatBox("You must be in a vehicle.", thePlayer, 255, 194, 14)
				outputChatBox("Or use Kullanım: /" .. commandName .. " [Vehicle ID]", thePlayer, 255, 194, 14)
				return false
			elseif vehID <= 0 then
				outputChatBox("You can't /checkveh on temp vehicle.", thePlayer, 255, 0, 0)
				return false
			end
		end

		dbQuery(
			function(queryHandle, thePlayer)
				local result, rows = dbPoll(queryHandle, 0)
				if rows > 0 then
					local row = result[1]
					if not row then
						outputChatBox("Vehicle ID #" .. vehID .. " doesn't exist!", thePlayer, 255, 0, 0)
						return false
					end

					local result1 = {}
					local result2 = {}

					table.insert(result1, {
						id = row["vID"],
						model = row["vModel"],
						posX = row["vPosX"],
						posY = row["vPosY"],
						posZ = row["vPosZ"],
						fuel = row["vFuel"],
						paintjob = row["vPaintjob"],
						hp = row["vHp"],
						plate = row["vPlate"],
						factionName = row["fFactionName"],
						owner = row["cOwner"],
						currdimension = row["vCurrdimension"],
						currInterior = row["vCurrInterior"],
						creator = row["aCreator"],
						plate = row["vPlate"],
						odometer = row["vOdometer"],
						suspensionLowerLimit = row["vSuspensionLowerLimit"],
						driveType = row["vDriveType"],
						note = row["vNote"],
						deleted = row["vDeleted"],
						activity = row["vActivity"],
						lastUsed = row["vLastUsed"],
						creationDate = row["vCreationDate"],
					})

					dbQuery(
						function(queryHandle, thePlayer)
							local result, rows = dbPoll(queryHandle, 0)
							if rows > 0 then
								local notes = {}

								for _, row in ipairs(result) do
									if row then
										table.insert(result2, {
											row["date"],
											row["action"],
											row["adminname"],
											row["logid"],
											row["vehID"],
										})
									end
								end

								dbQuery(
									function(queryHandle, thePlayer)
										local result, rows, err = dbPoll(queryHandle, 0)
										if rows > 0 then
											for _, row in ipairs(result) do
												row.creatorname = formatCreator(row.creatorname, row.creator)
												table.insert(notes, row)
											end
										end
										triggerClientEvent(
											thePlayer,
											"createCheckVehWindow",
											thePlayer,
											exports.mek_global:getPlayerAdminTitle(thePlayer),
											result1,
											result2,
											notes
										)
									end,
									{ thePlayer },
									mysql:getConnection(),
									"SELECT n.id, n.note, a.username AS creatorname, n.date, n.creator FROM vehicle_notes n LEFT JOIN accounts a ON n.creator=a.id WHERE n.vehid = ? ORDER BY n.date DESC",
									vehID
								)
							end
						end,
						{ thePlayer },
						mysql:getConnection(),
						"SELECT `vehicle_logs`.`date` AS `date`, `vehicle_logs`.`vehID` as `vehID`, `vehicle_logs`.`action` AS `action`, `accounts`.`username` AS `adminname`, `vehicle_logs`.`log_id` AS `logid` FROM `vehicle_logs` LEFT JOIN `accounts` ON `vehicle_logs`.`actor` = `accounts`.`id` WHERE `vehicle_logs`.`vehID` = ? ORDER BY `vehicle_logs`.`date` DESC",
						vehID
					)
				end
			end,
			{ thePlayer },
			mysql:getConnection(),
			"SELECT `vehicles`.`job` AS `vjob`,`vehicles`.`id` AS `vID`, `vehicles`.`model` AS `vModel`, `vehicles`.`currx` AS `vPosX`, `vehicles`.`curry` AS `vPosY`, `vehicles`.`currz` AS `vPosZ`, `vehicles`.`fuel` AS `vFuel`, `vehicles`.`paintjob` AS `vPaintjob`, `vehicles`.`hp` AS `vHp`, `factions`.`name` AS `fFactionName`, `characters`.`name` AS `cOwner`, `vehicles`.`job` AS `vJob`, `vehicles`.`tinted` AS `vTintedwindows`,`vehicles`.`currdimension` AS `vCurrdimension`, `vehicles`.`currinterior` AS `vCurrInterior`, `vehicles`.`plate` AS `vPlate`, `vehicles`.`odometer` AS `vOdometer`, `vehicles`.`suspensionLowerLimit` AS `vSuspensionLowerLimit`, `vehicles`.`driveType` AS `vDriveType`, (SELECT `username` FROM `accounts` WHERE `id` = `vehicles`.`deleted`) AS `vDeleted`, `vehicles`.`activity` AS `vActivity`, DATEDIFF(NOW(), `vehicles`.`last_used`) AS `vLastUsed`, `vehicles`.`creationDate` AS `vCreationDate`, `accounts`.`username` AS `aCreator` FROM `vehicles` LEFT JOIN `characters` ON `vehicles`.`owner`=`characters`.`id` LEFT JOIN `accounts` ON `vehicles`.`createdBy`=`accounts`.`id` LEFT JOIN `factions` ON`vehicles`.`faction`=`factions`.`id` WHERE `vehicles`.`id` = ? ORDER BY `vehicles`.`creationDate` DESC",
			vehID
		)
	end
end
addCommandHandler("checkveh", checkVeh)
addCommandHandler("checkvehicle", checkVeh)
addEvent("vehicleManager.checkveh", true)
addEventHandler("vehicleManager.checkveh", root, checkVeh)

function formatCreator(creator, creatorID)
	if creator and creatorID then
		if creator == nil then
			if creatorID == "0" then
				return "SİSTEM"
			else
				return "?"
			end
		else
			return creator
		end
	else
		return "?"
	end
end

function saveAdminNote(vehID, adminNote, noteID)
	if client and client and client ~= client then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not exports.mek_integration:isPlayerManager(client) then
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", client, 255, 0, 0, true)
		return
	end

	if not vehID or not adminNote then
		outputChatBox("Internal Error!", client, 255, 0, 0)
		return false
	end

	if #adminNote > 500 then
		outputChatBox("Admin note has failed to add. Reason: Exceeded 500 characters.", client, 255, 0, 0)
		return false
	end

	if noteID then
		if
			dbExec(
				mysql:getConnection(),
				"UPDATE vehicle_notes SET note = ?, creator = ? WHERE id = ? AND vehid = ?",
				adminNote,
				getElementData(client, "account_id"),
				noteID,
				vehID
			)
		then
			outputChatBox(
				"You have successfully updated admin note entry #" .. noteID .. " on vehicle #" .. vehID .. ".",
				client,
				0,
				255,
				0
			)
			return true
		end
	else
		local insertQuery = dbExec(
			mysql:getConnection(),
			"INSERT INTO vehicle_notes SET note = ?, creator = ?, vehid = ?",
			adminNote,
			getElementData(client, "account_id"),
			vehID
		)
		if insertedID then
			outputChatBox(
				"You have successfully added a new admin note entry to vehicle #" .. vehID .. ".",
				client,
				0,
				255,
				0
			)
			return true
		end
	end
end
addEvent("vehicleManager.saveAdminNote", true)
addEventHandler("vehicleManager.saveAdminNote", root, saveAdminNote)
