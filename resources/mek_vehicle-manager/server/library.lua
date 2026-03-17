mysql = exports.mek_mysql

function getRealDoorType(doortype)
	if doortype == 1 or doortype == 2 then
		return doortype
	end
	return nil
end

function refreshCarShop()
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not client or not exports.mek_integration:isPlayerManager(client) then
		if client then
			outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", client, 255, 0, 0, true)
		end
		return
	end

	local theResource = getResourceFromName("mek_carshop")
	if theResource then
		if getResourceState(theResource) == "running" then
			restartResource(theResource)
			outputChatBox("[!]#FFFFFF Galeriler başarıyla yenilendi.", client, 0, 255, 0, true)
			exports.mek_global:sendMessageToAdmins(
				"[ADM] " .. exports.mek_global:getPlayerFullAdminTitle(client) .. " isimli yetkili galerileri yeniledi."
			)
		elseif getResourceState(theResource) == "loaded" then
			startResource(theResource)
			outputChatBox("[!]#FFFFFF Galeriler başarıyla yenilendi.", client, 0, 255, 0, true)
			exports.mek_global:sendMessageToAdmins(
				"[ADM] " .. exports.mek_global:getPlayerFullAdminTitle(client) .. " isimli yetkili galerileri yeniledi."
			)
		elseif getResourceState(theResource) == "failed to load" then
			outputChatBox("[!]#FFFFFF Bir sorun oluştu.", client, 255, 0, 0, true)
		end
	end
end
addEvent("vehicleManager.refreshCarShops", true)
addEventHandler("vehicleManager.refreshCarShops", root, refreshCarShop)


function sendLibraryToClient(ped)
	if source then
		client = source
	end

	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	local vehs = {}
	local mQuery1 = nil
	local preparedQ =
		"SELECT `spawnto`, `id`, `vehmtamodel`, `vehbrand`, `vehmodel`, `vehyear`, `vehprice`, `vehtax`, (SELECT `username` FROM `accounts` WHERE `accounts`.`id`=`vehicles_shop`.`createdby`) AS 'createdby', `createdate`, (SELECT `username` FROM `accounts` WHERE `accounts`.`id`=`vehicles_shop`.`updatedby`) AS 'updatedby', `updatedate`, `notes`, `enabled` FROM `vehicles_shop`"
	if ped and isElement(ped) then
		local shopName = getElementData(ped, "carshop")
		if shopName == "grotti" then
			preparedQ = preparedQ .. " WHERE `spawnto`='1'"
		elseif shopName == "JeffersonCarShop" then
			preparedQ = preparedQ .. " WHERE `spawnto`='2'"
		elseif shopName == "IdlewoodBikeShop" then
			preparedQ = preparedQ .. " WHERE `spawnto`='3'"
		elseif shopName == "SandrosCars" then
			preparedQ = preparedQ .. " WHERE `spawnto`='4'"
		elseif shopName == "IndustrialVehicleShop" then
			preparedQ = preparedQ .. " WHERE `spawnto`='5'"
		elseif shopName == "BoatShop" then
			preparedQ = preparedQ .. " WHERE `spawnto`='6'"
		end
	end
	preparedQ = preparedQ

	dbQuery(function(queryHandle, client, ped)
		local res, rows, err = dbPoll(queryHandle, 0)
		if rows > 0 then
			for index, value in ipairs(res) do
				table.insert(vehs, value)
			end
			triggerClientEvent(client, "vehicleManager.showLibrary", client, vehs, ped)
		end
	end, { client, ped }, mysql:getConnection(), preparedQ)
end
addEvent("vehicleManager.sendLibraryToClient", true)
addEventHandler("vehicleManager.sendLibraryToClient", root, sendLibraryToClient)

function openVehlib(thePlayer)
	if exports.mek_integration:isPlayerManager(thePlayer) then
		triggerEvent("vehicleManager.sendLibraryToClient", thePlayer)
	end
end
addCommandHandler("vehlib", openVehlib)
addCommandHandler("vehiclelibrary", openVehlib)

function createVehicleRecord(data)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not exports.mek_integration:isPlayerManager(client) then
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", client, 255, 0, 0, true)
		return
	end

	if not data then
		return false
	end

	local enabled = data.enabled and "1" or "0"
	data.doortype = getRealDoorType(data.doortype) or "NULL"

	if not data.update then
		local query = [[
			INSERT INTO vehicles_shop 
			(vehmtamodel, vehbrand, vehmodel, vehyear, vehprice, vehtax, createdby, notes, enabled, spawnto, doortype)
			VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
		]]
		local result = dbExec(
			mysql:getConnection(),
			query,
			data.mtaModel,
			data.brand,
			data.model,
			data.year,
			data.price,
			data.tax,
			getElementData(client, "account_id"),
			data.note,
			enabled,
			data.spawnto,
			data.doortype
		)
		if not result then
			outputChatBox("[!] Failed to create new vehicle in library.", client, 255, 0, 0)
			return false
		end
		sendLibraryToClient(client)
		outputChatBox("[!] New vehicle created in library.", client, 0, 255, 0)
		exports.mek_global:sendMessageToAdmins(
			"[ADM] " .. getElementData(client, "account_username") .. " has created new vehicle in library."
		)
		return true
	else
		local query
		if data.copy then
			query = [[
				INSERT INTO vehicles_shop 
				(vehmtamodel, vehbrand, vehmodel, vehyear, vehprice, vehtax, createdby, notes, enabled, spawnto, doortype)
				VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
			]]
		else
			query = [[
				UPDATE vehicles_shop 
				SET vehmtamodel = ?, vehbrand = ?, vehmodel = ?, vehyear = ?, vehprice = ?, vehtax = ?, 
					updatedby = ?, notes = ?, updatedate = NOW(), enabled = ?, spawnto = ?, doortype = ? 
				WHERE id = ?
			]]
		end
		local params = data.copy
				and {
					data.mtaModel,
					data.brand,
					data.model,
					data.year,
					data.price,
					data.tax,
					getElementData(client, "account_id"),
					data.note,
					enabled,
					data.spawnto,
					data.doortype,
				}
			or {
				data.mtaModel,
				data.brand,
				data.model,
				data.year,
				data.price,
				data.tax,
				getElementData(client, "account_id"),
				data.note,
				enabled,
				data.spawnto,
				data.doortype,
				data.id,
			}

		local result = dbExec(mysql:getConnection(), query, unpack(params))
		if not result then
			outputChatBox(
				"[!] "
					.. (data.copy and "Failed to create new vehicle" or "Update vehicle #" .. data.id .. " failed")
					.. " in library.",
				client,
				255,
				0,
				0
			)
			return false
		end
		sendLibraryToClient(client)
		outputChatBox(
			"[!] "
				.. (data.copy and "New vehicle created" or "You have updated vehicle #" .. data.id)
				.. " in library.",
			client,
			0,
			255,
			0
		)
		exports.mek_global:sendMessageToAdmins(
			"[ADM] "
				.. getElementData(client, "account_username")
				.. " has "
				.. (data.copy and "created new vehicle" or "updated vehicle #" .. data.id)
				.. " in library."
		)
		return true
	end
end
addEvent("vehicleManager.createVehicle", true)
addEventHandler("vehicleManager.createVehicle", root, createVehicleRecord)

function getCurrentVehicleRecord(id)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not exports.mek_integration:isPlayerManager(client) then
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", client, 255, 0, 0, true)
		return
	end

	dbQuery(function(queryHandle, client)
		local res, rows, err = dbPoll(queryHandle, 0)
		if rows > 0 then
			for _, row in ipairs(res) do
				local veh = {}
				veh.id = row.id
				veh.mtaModel = row.vehmtamodel
				veh.brand = row.vehbrand
				veh.model = row.vehmodel
				veh.price = row.vehprice
				veh.tax = row.vehtax
				veh.year = row.vehyear
				veh.enabled = row.enabled
				veh.update = true
				veh.spawnto = row.spawnto
				veh.doortype = getRealDoorType(tonumber(row.doortype))
				triggerClientEvent(client, "vehicleManager.showEditVehicleRecord", client, veh)
			end
		end
	end, { client }, mysql:getConnection(), "SELECT * FROM vehicles_shop WHERE id = ? LIMIT 1", id)
end
addEvent("vehicleManager.getCurrentVehicleRecord", true)
addEventHandler("vehicleManager.getCurrentVehicleRecord", root, getCurrentVehicleRecord)

function deleteVehicleFromLibrary(id)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not exports.mek_integration:isPlayerManager(client) then
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", client, 255, 0, 0, true)
		return
	end

	if not id then
		return false
	end

	local result = dbExec(mysql:getConnection(), "DELETE FROM vehicles_shop WHERE id = ?", id)
	if not result then
		outputChatBox(
			"[!] Deleting vehicle #" .. id .. " from vehicle library failed.",
			client,
			255,
			0,
			0
		)
		return false
	end

	outputChatBox("[!] You have deleted vehicle #" .. id .. " from vehicle library.", client, 0, 255, 0)
	sendLibraryToClient(client)
	return true
end
addEvent("vehicleManager.deleteVehicle", true)
addEventHandler("vehicleManager.deleteVehicle", root, deleteVehicleFromLibrary)

function loadCustomVehProperties(vehID, theVehicle)
	if not vehID or not tonumber(vehID) then
		return false
	else
		vehID = tonumber(vehID)
	end

	if not theVehicle or not isElement(theVehicle) or not getElementType(theVehicle) == "vehicle" then
		local allVehicles = getElementsByType("vehicle")
		for i, veh in pairs(allVehicles) do
			if tonumber(getElementData(veh, "dbid")) == vehID then
				theVehicle = veh
				break
			end
		end
	end

	if not theVehicle then
		return false
	end

	local toBeSet = {}
	local customHandlings, baseHandlings = nil, nil
	local hasCustomInfo = false
	local res =
		dbPoll(dbQuery(mysql:getConnection(), "SELECT * FROM `vehicles_custom` WHERE `id` = ? LIMIT 1", vehID), -1)
	if res then
		for index, rowVehCustom in ipairs(res) do
			toBeSet.brand = rowVehCustom.brand
			toBeSet.model = rowVehCustom.model
			toBeSet.year = rowVehCustom.year
			toBeSet.price = rowVehCustom.price
			toBeSet.tax = rowVehCustom.tax
			toBeSet.duration = rowVehCustom.duration
			toBeSet.doortype = getRealDoorType(tonumber(rowVehCustom.doortype))
			customHandlings = rowVehCustom.handling
			if rowVehCustom.brand and rowVehCustom.brand ~= "" then
				hasCustomInfo = true
				setElementData(theVehicle, "unique", true, true)
			end
		end
	end

	local vehicleShopID = getElementData(theVehicle, "vehicle_shop_id") or 0

	if vehicleShopID and vehicleShopID ~= 0 then
		local res = dbPoll(
			dbQuery(
				mysql:getConnection(),
				"SELECT * FROM `vehicles_shop` WHERE `id` = ? AND `enabled` = 1 LIMIT 1",
				vehicleShopID
			),
			-1
		)
		if res then
			for index, rowVehShop in ipairs(res) do
				if not hasCustomInfo then
					toBeSet.brand = rowVehShop.vehbrand
					toBeSet.model = rowVehShop.vehmodel
					toBeSet.year = rowVehShop.vehyear
					toBeSet.price = rowVehShop.vehprice
					toBeSet.tax = rowVehShop.vehtax
					toBeSet.doortype = getRealDoorType(tonumber(rowVehShop.doortype))
					toBeSet.duration = rowVehShop.duration
				end

				baseHandlings = rowVehShop.handling
			end
		end
	end

	setElementData(theVehicle, "vehicle_shop_id", vehicleShopID)

	if toBeSet.brand then
		setElementData(theVehicle, "brand", toBeSet.brand)
		setElementData(theVehicle, "model", toBeSet.model)
		setElementData(theVehicle, "year", toBeSet.year)
		setElementData(theVehicle, "carshop:cost", toBeSet.price)
		setElementData(theVehicle, "carshop:taxcost", toBeSet.tax)
		setElementData(theVehicle, "vDoorType", toBeSet.doortype)
	end

	local hasCustomHandling = false
	if customHandlings and type(customHandlings) == "string" then
		local h = fromJSON(customHandlings)
		if h then
			for i = 1, #handlings do
				if i ~= 29 then
					setVehicleHandling(theVehicle, handlings[i][1], h[i] or h[tostring(i)])
				end
			end
			hasCustomHandling = true
		end
	end

	if not hasCustomHandling then
		if baseHandlings and type(baseHandlings) == "string" then
			local h = fromJSON(baseHandlings)
			if h then
				for i = 1, #handlings do
					if i ~= 29 then
						setVehicleHandling(theVehicle, handlings[i][1], h[i] or h[tostring(i)])
					end
				end
			end
		end
	end

	return true
end
addEvent("vehicleManager.loadCustomVehProperties", true)
addEventHandler("vehicleManager.loadCustomVehProperties", root, loadCustomVehProperties)
