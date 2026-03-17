mysql = exports.mek_mysql
local driveTestTimeSec = 1 * 60
local driveTestTimeVehLibSec = 30 * 60
local vehLibTest = {}
vehLibTest.int, vehLibTest.dim, vehLibTest.x, vehLibTest.y, vehLibTest.z, vehLibTest.rot =
	0, 400, 1428.71484375, -2593.26953125, 13.273954391479, 270

local dealerPlaces = {
	["grotti"] = {},
	["JeffersonCarShop"] = {},
	["IdlewoodBikeShop"] = {},
	["SandrosCars"] = {},
	["IndustrialVehicleShop"] = {},
	["BoatShop"] = {},
}
dealerPlaces["grotti"].int, dealerPlaces["grotti"].dim, dealerPlaces["grotti"].x, dealerPlaces["grotti"].y, dealerPlaces["grotti"].z, dealerPlaces["grotti"].rot =
	0, 0, 523.51953125, -1286.2919921875, 16.925954818726, 309.75823974609
dealerPlaces["JeffersonCarShop"].int, dealerPlaces["JeffersonCarShop"].dim, dealerPlaces["JeffersonCarShop"].x, dealerPlaces["JeffersonCarShop"].y, dealerPlaces["JeffersonCarShop"].z, dealerPlaces["JeffersonCarShop"].rot =
	0, 0, 2124.986328125, -1126.1943359375, 25.361940383911, 351.9560546875
dealerPlaces["IdlewoodBikeShop"].int, dealerPlaces["IdlewoodBikeShop"].dim, dealerPlaces["IdlewoodBikeShop"].x, dealerPlaces["IdlewoodBikeShop"].y, dealerPlaces["IdlewoodBikeShop"].z, dealerPlaces["IdlewoodBikeShop"].rot =
	0, 0, 1885.306640625, -1840.1572265625, 13.23556137085, 255.51647949219
dealerPlaces["SandrosCars"].int, dealerPlaces["SandrosCars"].dim, dealerPlaces["SandrosCars"].x, dealerPlaces["SandrosCars"].y, dealerPlaces["SandrosCars"].z, dealerPlaces["SandrosCars"].rot =
	0, 0, 2118.1103515625, -2128.248046875, 13.452997207642, 32.043975830078
dealerPlaces["IndustrialVehicleShop"].int, dealerPlaces["IndustrialVehicleShop"].dim, dealerPlaces["IndustrialVehicleShop"].x, dealerPlaces["IndustrialVehicleShop"].y, dealerPlaces["IndustrialVehicleShop"].z, dealerPlaces["IndustrialVehicleShop"].rot =
	0, 0, 2109.900390625, -2100.8876953125, 13.205016136169, 129.36264038086
dealerPlaces["BoatShop"].int, dealerPlaces["BoatShop"].dim, dealerPlaces["BoatShop"].x, dealerPlaces["BoatShop"].y, dealerPlaces["BoatShop"].z, dealerPlaces["BoatShop"].rot =
	0, 0, 174.587890625, -1939.248046875, -0.15370398759842, 206

local startDriveTestConvo = {
	"Tamam, yapalım!",
	"Tamam, gidelim!",
	"Haydi yuvarlanalım. Ne bekliyorsun?",
	"Utanmayın, sadece deneyin.",
	"Eminim hoşunuza gidecek, hadi gidelim!",
}

local finishDriveTestConvo = {
	"Yani ne düşünüyorsun?",
	"Fena değil ha?",
	"Bunu sipariş etmelisiniz!",
	"Böylece..?",
	"Masrafa değer, evet?",
}

local orderVehicleConvo = {
	"Peki, bu model stoklara girer girmez size bir SMS göndereceğiz.",
}

local dealershipPed = {}

function createDepavlovPCs(which)
	if which == getThisResource() or which == "Christopher Jackson" then
		dealershipPed[1] = createPed(147, 527.6103515625, -1293.4130859375, 17.2421875, 0, false)
		setElementInterior(dealershipPed[1], 0)
		setElementDimension(dealershipPed[1], 0)
		setElementFrozen(dealershipPed[1], true)
		setElementData(dealershipPed[1], "name", "Christopher Jackson")
		setElementData(dealershipPed[1], "interaction", {
			callbackEvent = "vehicleManager.sendLibraryToServer",
			args = { dealershipPed[1] },
			description = getElementData(dealershipPed[1], "name"):gsub("_", " "),
		})
		setElementData(dealershipPed[1], "carshop", "grotti")
	end

	if which == getThisResource() or which == "William Martinez" then
		dealershipPed[2] = createPed(17, 520.4482421875, -1284.4833984375, 17.2421875, 215.87640380859, false)
		setElementInterior(dealershipPed[2], 0)
		setElementDimension(dealershipPed[2], 0)
		setElementFrozen(dealershipPed[2], true)
		setElementData(dealershipPed[2], "name", "William Martinez")
		setElementData(dealershipPed[2], "interaction", {
			callbackEvent = "vehicleManager.sendLibraryToServer",
			args = { dealershipPed[2] },
			description = getElementData(dealershipPed[2], "name"):gsub("_", " "),
		})
		setElementData(dealershipPed[2], "carshop", "grotti")
	end

	if which == getThisResource() or which == "Joseph Moore" then
		dealershipPed[3] = createPed(28, 2131.64453125, -1123.9873046875, 25.413467407227, 82.066375732422, false)
		setElementInterior(dealershipPed[3], 0)
		setElementDimension(dealershipPed[3], 0)
		setElementFrozen(dealershipPed[3], true)
		setElementData(dealershipPed[3], "name", "Joseph Moore")
		setElementData(dealershipPed[3], "interaction", {
			callbackEvent = "vehicleManager.sendLibraryToServer",
			args = { dealershipPed[3] },
			description = getElementData(dealershipPed[3], "name"):gsub("_", " "),
		})
		setElementData(dealershipPed[3], "carshop", "JeffersonCarShop")
	end

	if which == getThisResource() or which == "Brandon Harris" then
		dealershipPed[4] = createPed(66, 2118.0244140625, -1125.4140625, 25.304183959961, 264.10162353516, false)
		setElementInterior(dealershipPed[4], 0)
		setElementDimension(dealershipPed[4], 0)
		setElementFrozen(dealershipPed[4], true)
		setElementData(dealershipPed[4], "name", "Brandon Harris")
		setElementData(dealershipPed[4], "interaction", {
			callbackEvent = "vehicleManager.sendLibraryToServer",
			args = { dealershipPed[4] },
			description = getElementData(dealershipPed[4], "name"):gsub("_", " "),
		})
		setElementData(dealershipPed[4], "carshop", "JeffersonCarShop")
	end

	if which == getThisResource() or which == "Jacob Jones" then
		dealershipPed[5] = createPed(143, 1882.861328125, -1843.5009765625, 13.572708129883, 360, false)
		setElementInterior(dealershipPed[5], 0)
		setElementDimension(dealershipPed[5], 0)
		setElementFrozen(dealershipPed[5], true)
		setElementData(dealershipPed[5], "name", "Jacob Jones")
		setElementData(dealershipPed[5], "interaction", {
			callbackEvent = "vehicleManager.sendLibraryToServer",
			args = { dealershipPed[5] },
			description = getElementData(dealershipPed[5], "name"):gsub("_", " "),
		})
		setElementData(dealershipPed[5], "carshop", "IdlewoodBikeShop")
	end

	if which == getThisResource() or which == "James Thomas" then
		dealershipPed[6] = createPed(23, 1886.6220703125, -1844.0029296875, 13.571912765503, 352, false)
		setElementInterior(dealershipPed[6], 0)
		setElementDimension(dealershipPed[6], 0)
		setElementFrozen(dealershipPed[6], true)
		setElementData(dealershipPed[6], "name", "James Thomas")
		setElementData(dealershipPed[6], "interaction", {
			callbackEvent = "vehicleManager.sendLibraryToServer",
			args = { dealershipPed[6] },
			description = getElementData(dealershipPed[6], "name"):gsub("_", " "),
		})
		setElementData(dealershipPed[6], "carshop", "IdlewoodBikeShop")
	end

	if which == getThisResource() or which == "Ryan Martin" then
		dealershipPed[7] = createPed(30, 2112.4951171875, -2132.220703125, 13.6328125, 269.64431762695, false)
		setElementInterior(dealershipPed[7], 0)
		setElementDimension(dealershipPed[7], 0)
		setElementFrozen(dealershipPed[7], true)
		setElementData(dealershipPed[7], "name", "Ryan Martin")
		setElementData(dealershipPed[7], "interaction", {
			callbackEvent = "vehicleManager.sendLibraryToServer",
			args = { dealershipPed[7] },
			description = getElementData(dealershipPed[7], "name"):gsub("_", " "),
		})
		setElementData(dealershipPed[7], "carshop", "SandrosCars")
	end

	if which == getThisResource() or which == "James Jackson" then
		dealershipPed[8] = createPed(73, 2112.2451171875, -2127.640625, 13.6328125, 269.64431762695, false)
		setElementInterior(dealershipPed[8], 0)
		setElementDimension(dealershipPed[8], 0)
		setElementFrozen(dealershipPed[8], true)
		setElementData(dealershipPed[8], "name", "James Jackson")
		setElementData(dealershipPed[8], "interaction", {
			callbackEvent = "vehicleManager.sendLibraryToServer",
			args = { dealershipPed[8] },
			description = getElementData(dealershipPed[8], "name"):gsub("_", " "),
		})
		setElementData(dealershipPed[8], "carshop", "SandrosCars")
	end

	if which == getThisResource() or which == "John Garcia" then
		dealershipPed[9] = createPed(16, 2116.90234375, -2090.86328125, 13.554370880127, 142.99200439453, false)
		setElementInterior(dealershipPed[9], 0)
		setElementDimension(dealershipPed[9], 0)
		setElementFrozen(dealershipPed[9], true)
		setElementData(dealershipPed[9], "name", "John Garcia")
		setElementData(dealershipPed[9], "interaction", {
			callbackEvent = "vehicleManager.sendLibraryToServer",
			args = { dealershipPed[9] },
			description = getElementData(dealershipPed[9], "name"):gsub("_", " "),
		})
		setElementData(dealershipPed[9], "carshop", "IndustrialVehicleShop")
	end

	if which == getThisResource() or which == "William White" then
		dealershipPed[10] = createPed(27, 2120.048828125, -2092.8984375, 13.546875, 146.20004272461, false)
		setElementInterior(dealershipPed[10], 0)
		setElementDimension(dealershipPed[10], 0)
		setElementFrozen(dealershipPed[10], true)
		setElementData(dealershipPed[10], "name", "William White", true)
		setElementData(dealershipPed[10], "interaction", {
			callbackEvent = "vehicleManager.sendLibraryToServer",
			args = { dealershipPed[10] },
			description = getElementData(dealershipPed[10], "name"):gsub("_", " "),
		})
		setElementData(dealershipPed[10], "carshop", "IndustrialVehicleShop")
	end

	if which == getThisResource() or which == "Nicholas Davis" then
		dealershipPed[11] = createPed(101, 174.39082336426, -1928.7536621094, 3.2781250476837, 168.58502197266, false)
		setElementInterior(dealershipPed[11], 0)
		setElementDimension(dealershipPed[11], 0)
		setElementFrozen(dealershipPed[11], true)
		setElementData(dealershipPed[11], "name", "Nicholas Davis", true)
		setElementData(dealershipPed[11], "interaction", {
			callbackEvent = "vehicleManager.sendLibraryToServer",
			args = { dealershipPed[11] },
			description = getElementData(dealershipPed[11], "name"):gsub("_", " "),
		})
		setElementData(dealershipPed[11], "carshop", "BoatShop")
	end

	if which == getThisResource() or which == "Anthony Anderson" then
		dealershipPed[12] = createPed(97, 163.45254516602, -1931.322265625, 4.1581702232361, 62.971862792969, false)
		setElementInterior(dealershipPed[12], 0)
		setElementDimension(dealershipPed[12], 0)
		setElementFrozen(dealershipPed[12], true)
		setElementData(dealershipPed[12], "name", "Anthony Anderson", true)
		setElementData(dealershipPed[12], "interaction", {
			callbackEvent = "vehicleManager.sendLibraryToServer",
			args = { dealershipPed[12] },
			description = getElementData(dealershipPed[12], "name"):gsub("_", " "),
		})
		setElementData(dealershipPed[12], "carshop", "BoatShop")
	end
end
addEventHandler("onResourceStart", resourceRoot, createDepavlovPCs)

-- Güvenlik: Client'tan gelen thePed'in gerçekten tanımlı bir NPC olup olmadığını kontrol et
function isValidDealershipPed(thePed)
	if not thePed or not isElement(thePed) then
		return false
	end
	for i = 1, #dealershipPed do
		if dealershipPed[i] == thePed then
			return true
		end
	end
	return false
end

function setHandling(
	theVehicle,
	saveToSQL,
	maxVelocityS,
	accelerationS,
	engineInertiaS,
	lowerLimitS,
	suspensionBiasS,
	suspensionForceS,
	suspensionDampingS,
	steeringLockS,
	driveTypeS,
	massWeightS,
	dragCoeffS,
	brakeForceS,
	brakeBiasS,
	tracMultiplyS,
	tracBiasS,
	centerOfMass
)
	if theVehicle then
		setVehicleHandling(theVehicle, "maxVelocity", tonumber(maxVelocityS))
		setVehicleHandling(theVehicle, "engineAcceleration", tonumber(accelerationS))
		setVehicleHandling(theVehicle, "engineInertia", tonumber(engineInertiaS))
		setVehicleHandling(theVehicle, "suspensionLowerLimit", tonumber(lowerLimitS))
		setVehicleHandling(theVehicle, "suspensionFrontRearBias", tonumber(suspensionBiasS))
		setVehicleHandling(theVehicle, "suspensionForceLevel", tonumber(suspensionForceS))
		setVehicleHandling(theVehicle, "suspensionDamping", tonumber(suspensionDampingS))
		setVehicleHandling(theVehicle, "steeringLock", tonumber(steeringLockS))
		setVehicleHandling(theVehicle, "driveType", tostring(driveTypeS))
		setVehicleHandling(theVehicle, "mass", tonumber(massWeightS))
		setVehicleHandling(theVehicle, "dragCoeff", tonumber(dragCoeffS))
		setVehicleHandling(theVehicle, "brakeBias", tonumber(brakeBiasS))
		setVehicleHandling(theVehicle, "brakeDeceleration", tonumber(brakeForceS))
		setVehicleHandling(theVehicle, "tractionMultiplier", tonumber(tracMultiplyS))
		setVehicleHandling(theVehicle, "tractionBias", tonumber(tracBiasS))
		setVehicleHandling(theVehicle, "centerOfMass", centerOfMass)
	end

	saveHandling(theVehicle, saveToSQL, client)
end
addEvent("handlingSystem:setHandling", true)
addEventHandler("handlingSystem:setHandling", root, setHandling)

function resetHandling(theVehicle, mode)
	if theVehicle and (mode == 1 or mode == 0) then
		if mode == 0 then
			setVehicleHandling(theVehicle, true)
			triggerClientEvent(client, "vehicleManager.editHandling", client, mode)
		elseif mode == 1 then
			deleteUniqueHandling(theVehicle, client)
		end
	end
end
addEvent("handlingSystem:resetHandling", true)
addEventHandler("handlingSystem:resetHandling", root, resetHandling)

function deleteUniqueHandling(theVehicle, player)
	local dbid = getElementData(theVehicle, "dbid")
	if dbid and tonumber(dbid) then
		local existed = dbPoll(
			dbQuery(mysql:getConnection(), "SELECT * FROM `vehicles_custom` WHERE `id` = ? LIMIT 1", dbid),
			-1
		) or false
		if existed and existed.id then
			existed = true
		else
			existed = false
		end

		if existed then
			local mQuery1 = dbExec(
				mysql:getConnection(),
				"UPDATE `vehicles_custom` SET `handling` = '', `updatedby` = ?, `updatedate` = NOW() WHERE `id` = ?",
				getElementData(player, "account_id"),
				dbid
			)
			exports.mek_global:sendMessageToAdmins(
				"[ADM] "
					.. getElementData(player, "account_username")
					.. " has reset unique handling for vehicle #"
					.. dbid
					.. "."
			)
			exports.mek_vehicle:reloadVehicle(tonumber(dbid))
			outputChatBox(
				"[!] You have reset unique handling for vehicle #" .. dbid .. ".",
				player,
				0,
				255,
				0
			)
		else
			exports.mek_vehicle:reloadVehicle(tonumber(dbid))
			outputChatBox(
				"[!] You have reset unique handling for vehicle #" .. dbid .. ".",
				player,
				0,
				255,
				0
			)
		end
	end
end

function saveHandling(theVehicle1, saveToSQL, who)
	if not theVehicle1 then
		return false
	end

	local h = getVehicleHandling(theVehicle1)
	local sHandling = toJSON({
		h[handlings[1][1]],
		h[handlings[2][1]],
		h[handlings[3][1]],
		h[handlings[4][1]],
		h[handlings[5][1]],
		h[handlings[6][1]],
		h[handlings[7][1]],
		h[handlings[8][1]],
		h[handlings[9][1]],
		h[handlings[10][1]],
		h[handlings[11][1]],
		h[handlings[12][1]],
		h[handlings[13][1]],
		h[handlings[14][1]],
		h[handlings[15][1]],
		h[handlings[16][1]],
		h[handlings[17][1]],
		h[handlings[18][1]],
		h[handlings[19][1]],
		h[handlings[20][1]],
		h[handlings[21][1]],
		h[handlings[22][1]],
		h[handlings[23][1]],
		h[handlings[24][1]],
		h[handlings[25][1]],
		h[handlings[26][1]],
		h[handlings[27][1]],
		h[handlings[28][1]],
		h[handlings[29][1]],
		tonumber(h[handlings[30][1]]),
		h[handlings[31][1]],
		h[handlings[32][1]],
		h[handlings[33][1]],
	})

	if saveToSQL == 0 then
		local id = getElementData(theVehicle1, "vehicle_shop_id")
		if not id then
			return false
		end
		local updateQuery = dbExec(
			mysql:getConnection(),
			"UPDATE `vehicles_shop` SET `handling` = ?, `updatedby` = ?, `updatedate` = NOW() WHERE `id` = ?",
			sHandling,
			getElementData(who, "account_id"),
			tostring(id)
		)
		outputChatBox("You have changed handlings of all instances of vehicle shop id #" .. id, who)
		exports.mek_global:sendMessageToAdmins(
			"[ADM] "
				.. getElementData(who, "account_username")
				.. " has changed handlings of all instances of vehicle shop id #"
				.. id
		)
	elseif saveToSQL == 1 then
		local dbid = getElementData(theVehicle1, "dbid")
		if not dbid or not tonumber(dbid) then
			return false
		end

		dbQuery(function(queryHandle, who)
			local res, rows, err = dbPoll(queryHandle, 0)
			if rows > 0 then
				local row = res[1]
				local veh = exports.mek_pool:getElementByID("vehicle", tonumber(dbid))

				if not row or not row.id then
					if
						not dbExec(
							mysql:getConnection(),
							"INSERT INTO `vehicles_custom` SET `id` = ?, `handling` = ?, `createdby` = ?, `createdate` = NOW()",
							tostring(dbid),
							sHandling,
							getElementData(who, "account_id")
						)
					then
						return false
					else
						exports.mek_vehicle:reloadVehicle(tonumber(dbid))
					end
				else
					if
						not dbExec(
							mysql:getConnection(),
							"UPDATE `vehicles_custom` SET `handling` = ?, `updatedby` = ?, `updatedate` = NOW() WHERE `id` = ?",
							sHandling,
							getElementData(who, "account_id"),
							tostring(dbid)
						)
					then
						return false
					else
						exports.mek_vehicle:reloadVehicle(tonumber(dbid))
					end
				end

				outputChatBox("You have saved unique handlings for vehicle id #" .. dbid, who)
				exports.mek_global:sendMessageToAdmins(
					"[ADM] "
						.. getElementData(who, "account_username")
						.. " saved unique handlings for vehicle id #"
						.. dbid
				)
			end
		end, { who }, mysql:getConnection(), "SELECT * FROM `vehicles_custom` WHERE `id` = ? LIMIT 1", dbid)
	end
end

function reloadAllInstancesOf(vehicle_shop_id)
	local count = 0
	if vehicle_shop_id and tonumber(vehicle_shop_id) then
		vehicle_shop_id = tonumber(vehicle_shop_id)
		for i, veh in pairs(getElementsByType("vehicle")) do
			local dbid = getElementData(veh, "dbid")
			local shopid = getElementData(veh, "vehicle_shop_id")
			if dbid and shopid and dbid > 0 and shopid > 0 and shopid == vehicle_shop_id then
				exports.mek_vehicle:reloadVehicle(tonumber(dbid))
				outputChatBox("[!] Vehicle ID#" .. dbid .. " reloaded.", client)
				outputChatBox(vehicle_shop_id, client)
				count = count + 1
			end
		end
	end
	outputChatBox(
		"You have reloaded " .. count .. " instances of vehicle shop id #" .. vehicle_shop_id .. " in game.",
		client
	)
	exports.mek_global:sendMessageToAdmins(
		"[ADM] "
			.. getElementData(client, "account_username")
			.. " has reloaded "
			.. count
			.. " instances of vehicle shop id #"
			.. vehicle_shop_id
			.. " in game."
	)
end
addEvent("vehicleManager.reloadAllInstancesOf", true)
addEventHandler("vehicleManager.reloadAllInstancesOf", root, reloadAllInstancesOf)

local availableDim = {}
local timerTestDrive = {}
function getAvailableDimForTestVeh(veh)
	local dim = nil
	for i = 1, 5000 do
		if availableDim[i] == nil then
			availableDim[i] = veh
			dim = i
			break
		end
	end
	return dim
end

function freeDimForTestVeh(veh, thePed)
	if thePed then
		destroyElement(veh)
	end
	if veh then
		for i = 1, #availableDim do
			if availableDim[i] == veh then
				availableDim[i] = nil
				if timerTestDrive[veh] and isTimer(timerTestDrive[veh]) then
					killTimer(timerTestDrive[veh])
				end
				destroyElement(veh)
				break
			end
		end
	end
end

function getInfoFromVehShopID(vehShopID)
	if not vehShopID then
		return false
	end

	local query = dbQuery(mysql:getConnection(), "SELECT * FROM `vehicles_shop` WHERE `id` = ? LIMIT 1", vehShopID)
	local result = dbPoll(query, -1)

	if result and #result > 0 then
		return result[1]
	end

	return false
end

function createTestVehicle(vehShopID, thePed, fromVehLib)
	if not client or not getElementType(client) == "player" then
		return false
	end

	if not fromVehLib and not isValidDealershipPed(thePed) then
		outputChatBox("[!] Geçersiz işlem.", client, 255, 0, 0)
		return false
	end

	if not fromVehLib then
		if exports.mek_global:takeMoney(client, 25) then
		else
			triggerEvent(
				"shop.storeKeeperSay",
				client,
				"25 lira alabilir miyim lütfen?",
				getElementData(thePed, "name")
			)
			return false
		end
	end

	exports.mek_global:fadeToBlack(client)

	local vehShopData = getInfoFromVehShopID(vehShopID)
	if not vehShopData then
		return false
	end
	local vehicleID = tonumber(vehShopData.vehmtamodel)
	local plate = exports.mek_global:generatePlate()

	local destination = vehLibTest
	if not fromVehLib and thePed then
		local location = getElementData(thePed, "carshop")
		destination = dealerPlaces[location]
	else
		thePed = false
	end

	local int, dim = destination.int, destination.dim
	local x, y, z = destination.x, destination.y, destination.z
	local r = destination.rot

	local veh = createVehicle(vehicleID, x, y, z, 0, 0, 180, plate)
	if not veh then
		outputChatBox("[!]#FFFFFF Geçersiz araç ID veya aracınızı /aracpanel komudu ile aktifleştiriniz.", client, 255, 0, 0, true)
		return false
	end

	local timeLimited = nil

	if fromVehLib then
		dim = getAvailableDimForTestVeh(veh)
		timeLimited = driveTestTimeVehLibSec
	else
		timeLimited = driveTestTimeSec
	end

	setElementInterior(veh, int)
	setElementDimension(veh, dim)
	setElementRotation(veh, 0, 0, r)

	local px, py, pz = getElementPosition(client)
	local rx, ry, rz = getElementRotation(client)
	local savepos = { getElementInterior(client), getElementDimension(client), px, py, pz, rx, ry, rz }

	removePedFromVehicle(client)
	warpPedIntoVehicle3(client, veh)

	totalTempVehicles = totalTempVehicles + 1
	local dbid = -totalTempVehicles
	exports.mek_pool:allocateElement(veh, dbid)

	setVehicleOverrideLights(veh, 1)
	setVehicleEngineState(veh, false)
	setVehicleFuelTankExplodable(veh, false)
	setVehicleVariant(veh, exports.mek_vehicle:getRandomVariant(getElementModel(veh)))

	setElementData(veh, "dbid", dbid)
	setElementData(veh, "fuel", 100)
	setElementData(veh, "engine", false)
	setElementData(veh, "oldx", x)
	setElementData(veh, "oldy", y)
	setElementData(veh, "oldz", z)
	setElementData(veh, "faction", -1)
	setElementData(veh, "owner", -1)
	setElementData(veh, "job", 0)
	setElementData(veh, "handbrake", false)

	setElementData(veh, "brand", vehShopData.vehbrand)
	setElementData(veh, "model", vehShopData.vehmodel)
	setElementData(veh, "year", vehShopData.vehyear)
	setElementData(veh, "vehicle_shop_id", vehShopData.id)

	setElementData(veh, "isTestDriveCar", client)

	exports["mek_vehicle-interiors"]:add(veh)

	setElementData(client, "testdrivepos", savepos)
	triggerClientEvent(client, "vehicleManager.testdrivetimerGUI", client, veh, timeLimited, thePed)

	loadHandlingToVeh(veh, vehShopData.handling)

	if not fromVehLib then
		local ran = math.random(1, #startDriveTestConvo)
		triggerEvent("shop.storeKeeperSay", client, startDriveTestConvo[ran], getElementData(thePed, "name"))
		triggerClientEvent(client, "vehicleManager.editHandling", client, 2)
	else
		triggerClientEvent(client, "vehicleManager.editHandling", client, 0)
	end

	if timerTestDrive[veh] and isTimer(timerTestDrive[veh]) then
		killTimer(timerTestDrive[veh])
	end
	timerTestDrive[veh] = setTimer(function()
		finishTestDrive(veh, thePed)
	end, 1000 * timeLimited, 1)
end
addEvent("vehicleManager.createTestVehicle", true)
addEventHandler("vehicleManager.createTestVehicle", root, createTestVehicle)

function loadHandlingToVeh(veh, handlingTable)
	if not veh or type(handlingTable) ~= "string" then
		return false
	end

	local h = fromJSON(handlingTable)
	if not h then
		return false
	end

	for i = 1, #handlings do
		local handlingName = handlings[i][1]
		local value = h[i]
		if handlingName and value ~= nil then
			setVehicleHandling(veh, handlingName, value)
		end
	end
end

function finishTestDrive(veh, thePed, orderFinish, forSpawn)
	if orderFinish then
		triggerEvent("vehicleManager.orderVehicle", client, getElementData(veh, "vehicle_shop_id"), thePed)
	end

	local anyPlayer = nil
	if timerTestDrive[veh] and isTimer(timerTestDrive[veh]) then
		killTimer(timerTestDrive[veh])
	end

	local found = false
	for i = 0, getVehicleMaxPassengers(veh) do
		local player = getVehicleOccupant(veh, i)
		if player then
			anyPlayer = player
			removePedFromVehicle(player)
			local savedpos = getElementData(player, "testdrivepos") or false
			if savedpos and (not forSpawn or player ~= client) then
				setCameraInterior(player, savedpos[1])
				setElementInterior(player, savedpos[1])
				setElementDimension(player, savedpos[2])
				setElementPosition(player, savedpos[3], savedpos[4], savedpos[5], true)
				setElementRotation(player, savedpos[6], savedpos[7], savedpos[8])
				setTimer(function()
					exports.mek_global:fadeFromBlack(player)
				end, 2000, 1)
				found = true
				break
			end
		end
	end

	if not found and not forSpawn then
		local savedpos = getElementData(client, "testdrivepos") or false
		if savedpos then
			setCameraInterior(client, savedpos[1])
			setElementInterior(client, savedpos[1])
			setElementDimension(client, savedpos[2])
			setElementPosition(client, savedpos[3], savedpos[4], savedpos[5], true)
			setElementRotation(client, savedpos[6], savedpos[7], savedpos[8])
			setTimer(function()
				exports.mek_global:fadeFromBlack(client)
			end, 2000, 1)
		end
	end

	if thePed and anyPlayer and not orderFinish and not forSpawn then
		local ran = math.random(1, #finishDriveTestConvo)
		triggerEvent("shop.storeKeeperSay", anyPlayer, finishDriveTestConvo[ran], getElementData(thePed, "name"))
	end
	freeDimForTestVeh(veh, thePed)
end
addEvent("vehicleManager.finishTestDrive", true)
addEventHandler("vehicleManager.finishTestDrive", root, finishTestDrive)

function orderVehicle(vehShopID, thePed)
	if not isValidDealershipPed(thePed) then
		outputChatBox("[!] Geçersiz işlem.", source, 255, 0, 0)
		return false
	end

	setElementData(
		source,
		"carshop:grotti:orderedvehicle:" .. getElementData(thePed, "carshop"),
		tonumber(vehShopID),
		true
	)
	local ran = math.random(1, #orderVehicleConvo)
	triggerEvent("shop.storeKeeperSay", source, orderVehicleConvo[ran], getElementData(thePed, "name"))
end
addEvent("vehicleManager.orderVehicle", true)
addEventHandler("vehicleManager.orderVehicle", root, orderVehicle)

function cancelOrderVehicle(shopname)
	if shopname then
		removeElementData(client, "carshop:grotti:orderedvehicle:" .. shopname)
	end
end
addEvent("vehicleManager.orderVehicle:cancel", true)
addEventHandler("vehicleManager.orderVehicle:cancel", root, cancelOrderVehicle)

local function enterVehicle(player, seat, jacked)
	local testCar = getElementData(source, "isTestDriveCar")
	if testCar and (testCar ~= player) then
		cancelEvent()
	end
end
addEventHandler("onVehicleStartEnter", root, enterVehicle)

local function exitVehicle(player, seat, jacked)
	if getElementData(source, "isTestDriveCar") then
		cancelEvent()
	end
end
addEventHandler("onVehicleStartExit", root, exitVehicle)

function warpPedIntoVehicle3(thePlayer, theVehicle)
	warpPedIntoVehicle2(thePlayer, theVehicle, 0)
	local x, y, z = getElementPosition(theVehicle)
	setElementPosition(thePlayer, x + 2, y, z)
end
