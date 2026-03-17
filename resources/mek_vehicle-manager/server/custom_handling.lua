function editVehicle(thePlayer, commandName)
	if exports.mek_integration:isPlayerServerOwner(thePlayer) then
		local theVehicle = getPedOccupiedVehicle(thePlayer) or false
		if not theVehicle then
			outputChatBox("You must be in a vehicle.", thePlayer, 255, 194, 14)
			return false
		end

		local vehID = getElementData(theVehicle, "dbid") or false
		if not vehID or vehID < 0 then
			outputChatBox("This vehicle can not have custom properties.", thePlayer, 255, 194, 14)
			return false
		end

		local vehicle = {}
		dbQuery(function(queryHandle)
			local result = dbPoll(queryHandle, 0)
			if result and #result > 0 then
				local row = result[1]
				vehicle.id = row.id
				vehicle.brand = row.brand
				vehicle.model = row.model
				vehicle.price = row.price
				vehicle.tax = row.tax
				vehicle.handling = row.handling
				vehicle.notes = row.notes
				vehicle.doortype = getRealDoorType(row.doortype)
			end
			triggerClientEvent(thePlayer, "vehicleManager.editVehicle", thePlayer, vehicle)
		end, { thePlayer }, mysql:getConnection(), "SELECT * FROM `vehicles_custom` WHERE `id` = ? LIMIT 1", vehID)
	end
end
addCommandHandler("editvehicle", editVehicle)
addCommandHandler("editveh", editVehicle)

function createUniqueVehicle(data, existed)
	if not data then
		return false
	end

	data.doortype = getRealDoorType(data.doortype) or "NULL"

	local vehicle = exports.mek_pool:getElementByID("vehicle", tonumber(data.id))

	if not existed then
		local mQuery1 = dbExec(
			mysql:getConnection(),
			"INSERT INTO vehicles_custom (id, brand, model, year, price, tax, createdby, notes, doortype) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
			tonumber(data["id"]),
			tostring(data["brand"]),
			tostring(data["model"]),
			tonumber(data["year"]),
			tonumber(data["price"]),
			tonumber(data["tax"]),
			tonumber(getElementData(client, "account_id")),
			tostring(data["note"]),
			tonumber(data["doortype"])
		)
		if not mQuery1 then
			outputChatBox("[!] Failed to create unique vehicle.", client, 255, 0, 0)
			return false
		end
		outputChatBox("[!] Unique vehicle created.", client, 0, 255, 0)
		exports.mek_global:sendMessageToAdmins(
			"[ADM] "
				.. getElementData(client, "account_username")
				.. " has created new unique vehicle #"
				.. data.id
				.. "."
		)
		exports.mek_vehicle:reloadVehicle(tonumber(data.id))
		return true
	else
		local mQuery1 = dbExec(
			mysql:getConnection(),
			"UPDATE vehicles_custom SET brand = ?, model = ?, year = ?, price = ?, tax = ?, updatedby = ?, notes = ?, updatedate = NOW(), doortype = ? WHERE id = ?",
			tostring(data["brand"]),
			tostring(data["model"]),
			tonumber(data["year"]),
			tonumber(data["price"]),
			tonumber(data["tax"]),
			tonumber(getElementData(client, "account_id")),
			tostring(data["note"]),
			tonumber(data["doortype"]),
			tonumber(data["id"])
		)
		if not mQuery1 then
			outputChatBox("[!] Update unique vehicle #" .. data.id .. " failed.", client, 255, 0, 0)
			return false
		end

		outputChatBox("[!] You have updated unique vehicle #" .. data.id .. ".", client, 0, 255, 0)
		exports.mek_global:sendMessageToAdmins(
			"[ADM] " .. getElementData(client, "account_username") .. " has updated unique vehicle #" .. data.id .. "."
		)
		exports.mek_vehicle:reloadVehicle(tonumber(data.id))

		return true
	end
end
addEvent("vehicleManager.createUniqueVehicle", true)
addEventHandler("vehicleManager.createUniqueVehicle", root, createUniqueVehicle)

function resetUniqueVehicle(vehID)
	if exports.mek_integration:isPlayerManager(client) then
		if not vehID or not tonumber(vehID) then
			return false
		end

		local mQuery1 = dbExec(mysql:getConnection(), "DELETE FROM vehicles_custom WHERE id = ?", tonumber(vehID))
		if not mQuery1 then
			outputChatBox("[!] Remove unique vehicle #" .. vehID .. " failed.", client, 255, 0, 0)
			return false
		end
		outputChatBox("[!] You have removed unique vehicle #" .. vehID .. ".", client, 0, 255, 0)
		exports.mek_global:sendMessageToAdmins(
			"[ADM] " .. getElementData(client, "account_username") .. " has removed unique vehicle #" .. vehID .. "."
		)
		exports.mek_vehicle:reloadVehicle(tonumber(vehID))

		return true
	end
end
addEvent("vehicleManager.resetUniqueVehicle", true)
addEventHandler("vehicleManager.resetUniqueVehicle", root, resetUniqueVehicle)

function openUniqueHandling(vehdbid, existed)
	if exports.mek_integration:isPlayerManager(client) then
		local theVehicle = getPedOccupiedVehicle(client) or false
		if not theVehicle then
			outputChatBox("You must be in a vehicle.", client, 255, 194, 14)
			return false
		end

		local vehID = getElementData(theVehicle, "dbid") or false
		if not vehID or vehID < 0 then
			outputChatBox("This vehicle can not have custom properties.", client, 255, 194, 14)
			return false
		end

		if existed then
			triggerClientEvent(client, "vehicleManager.editHandling", client, 1)
		else
			triggerClientEvent(client, "vehicleManager.editHandling", client, 1)
		end

		return true
	end
end
addEvent("vehicleManager.openUniqueHandling", true)
addEventHandler("vehicleManager.openUniqueHandling", root, openUniqueHandling)
