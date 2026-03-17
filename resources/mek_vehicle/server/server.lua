mysql = exports.mek_mysql

local toLoad = {}
local threads = {}

local engineTimers = {}
local lockTimers = {}
local storeTimers = {}

vehicleData = {}
safeTable = {}

function getVehicleName(vehicle)
	return exports.mek_global:getVehicleName(vehicle)
end

local function printVehicleCreateSyntax(player, command)
	outputChatBox(
		"Kullanım: /" .. command .. " [Araç Kütüphanesi ID] [Renk 1] [Renk 2] [Sahip] [Birlik Aracı (1/0)]",
		player,
		255,
		194,
		14
	)
	outputChatBox(
		"NOT: Eğer araç birlik aracıyse, sahip alanında belirtilen ID birliğe verilecektir.",
		player,
		255,
		194,
		14
	)
	outputChatBox(
		"NOT: Eğer araç birlik aracıyse, ücret oyuncudan değil birlik kasasından alınır.",
		player,
		255,
		194,
		14
	)
end

function createPermanentVehicle(player, command, ...)
	if exports.mek_integration:isPlayerManager(player) then
		local args = { ... }
		if #args < 5 then
			printVehicleCreateSyntax(player, command)
			return
		end

		local vehShopData = exports["mek_vehicle-manager"]:getInfoFromVehShopID(tonumber(args[1]))
		if not vehShopData then
			outputChatBox(
				"[!]#FFFFFF Geçersiz araç ID’si girildi, lütfen /vehlib komutundan bir araç ID’si kullanın.",
				player,
				255,
				0,
				0,
				true
			)
			return
		end

		local id = tonumber(vehShopData.vehmtamodel)
		if not id then
			outputChatBox(
				"[!]#FFFFFF Bu aracın MTA model ID’si ayarlanmamış, lütfen /vehlib komutuyla ayarlayın.",
				player,
				255,
				0,
				0,
				true
			)
			return
		end

		local primaryColor = tonumber(args[2])
		local secondaryColor = tonumber(args[3])
		local owner = args[4]
		local isFactionOwned = tonumber(args[5]) == 1
		local factionID = -1
		local targetPlayer = nil

		local r = getPedRotation(player)
		local x, y, z = getElementPosition(player)
		x = x + ((math.cos(math.rad(r))) * 5)
		y = y + ((math.sin(math.rad(r))) * 5)

		if isFactionOwned then
			local theTeam = exports.mek_faction:getFactionFromID(tonumber(owner))
			if not theTeam then
				outputChatBox("[!]#FFFFFF ID’si " .. owner .. " olan birlik bulunamadı.", player, 255, 0, 0, true)
				return
			end

			factionID = tonumber(owner)
			owner = -1
		else
			local other, name = exports.mek_global:findPlayerByPartialNick(player, owner)
			if other then
				targetPlayer = other
				owner = getElementData(other, "dbid")

				if not exports.mek_global:canPlayerBuyVehicle(other) then
					outputChatBox("[!]#FFFFFF Bu oyuncunun fazla aracı var.", player, 255, 0, 0, true)
					outputChatBox(
						"[!]#FFFFFF Çok fazla aracınız var, yeni bir araç alamazsınız.",
						other,
						255,
						0,
						0,
						true
					)
					return
				end
			else
				return
			end
		end

		local plate = exports.mek_global:generatePlate()

		local veh = createVehicle(id, x, y, z, 0, 0, r, plate)
		if not veh then
			outputChatBox(
				"[!]#FFFFFF Araç kütüphanesinde geçersiz MTA araç modeli belirtilmiş.",
				player,
				255,
				0,
				0,
				true
			)
			return
		end

		setVehicleColor(veh, primaryColor, secondaryColor, primaryColor, secondaryColor)

		local col = { getVehicleColor(veh, true) }
		local color1 = toJSON({ col[1], col[2], col[3] })
		local color2 = toJSON({ col[4], col[5], col[6] })
		local color3 = toJSON({ col[7], col[8], col[9] })
		local color4 = toJSON({ col[10], col[11], col[12] })

		local vehicleName = getVehicleName(veh)
		destroyElement(veh)

		local dimension = getElementDimension(player)
		local interior = getElementInterior(player)

		local var1, var2 = getRandomVariant(id)

		local queryHandle = dbQuery(
			exports.mek_mysql:getConnection(),
			[[
				INSERT INTO vehicles SET
					model = ?,
					x = ?, y = ?, z = ?,
					rotx = '0', roty = '0', rotz = ?,
					color1 = ?, color2 = ?, color3 = ?, color4 = ?,
					faction = ?, owner = ?, plate = ?,
					currx = ?, curry = ?, currz = ?,
					currrx = '0', currry = '0', currrz = ?,
					locked = 1,
					interior = ?, currinterior = ?,
					dimension = ?, currdimension = ?,
					variant1 = ?, variant2 = ?,
					creationDate = NOW(),
					createdBy = ?,
					vehicle_shop_id = ?
			]],
			id,
			x,
			y,
			z,
			r,
			color1,
			color2,
			color3,
			color4,
			factionID,
			owner,
			plate,
			x,
			y,
			z,
			r,
			interior,
			interior,
			dimension,
			dimension,
			var1,
			var2,
			getElementData(player, "account_id"),
			args[1]
		)
		local result, _, lastInsertID = dbPoll(queryHandle, 5000)

		if result then
			local owner = ""
			if not isFactionOwned then
				exports.mek_item:giveItem(targetPlayer, 3, tonumber(lastInsertID))
				owner = getPlayerName(targetPlayer):gsub("_", " ")
			else
				owner = "Birlik #" .. factionID
			end

			dbExec(
				exports.mek_mysql:getConnection(),
				"INSERT INTO `vehicle_logs` (`vehID`, `action`, `actor`) VALUES (?, ?, ?) ",
				lastInsertID,
				command .. " " .. vehicleName .. " (" .. owner .. ")",
				getElementData(player, "account_id")
			)

			exports.mek_global:sendMessageToAdmins(
				"[ADM] "
					.. exports.mek_global:getPlayerFullAdminTitle(player)
					.. " isimli yetkili "
					.. vehicleName
					.. " (ID #"
					.. lastInsertID
					.. ") aracını "
					.. owner
					.. " için oluşturdu."
			)
			if not isFactionOwned then
				outputChatBox(
					"[!]#FFFFFF "
						.. exports.mek_global:getPlayerFullAdminTitle(player)
						.. " isimli yetkili size "
						.. vehicleName
						.. " (ID #"
						.. lastInsertID
						.. ") aracını verdi.",
					targetPlayer,
					0,
					0,
					255,
					true
				)
			end
			outputChatBox(
				"[!]#FFFFFF "
					.. vehicleName
					.. " (ID #"
					.. lastInsertID
					.. ") başarıyla "
					.. owner
					.. " için oluşturuldu.",
				player,
				0,
				255,
				0,
				true
			)

			reloadVehicle(tonumber(lastInsertID))
		else
			dbFree(queryHandle)
		end
	end
end
addCommandHandler("makeveh", createPermanentVehicle, false, false)

function printMakeVehError(thePlayer, commandName)
	outputChatBox(
		"Kullanım: /"
			.. commandName
			.. " [ID from Veh Lib] [color1] [color2] [Owner] [Faction Vehicle (1/0)] [-1=carshop price] [Tinted Windows] ",
		thePlayer,
		255,
		194,
		14
	)
	outputChatBox(
		"NOTE: If it is a faction vehicle, ownership will be given to the 'owner''s faction.",
		thePlayer,
		255,
		194,
		14
	)
	outputChatBox(
		"NOTE: If it is a faction vehicle, the cost is taken from the faction fund, rather than the player.",
		thePlayer,
		255,
		194,
		14
	)
end

function createCivilianPermVehicle(thePlayer, commandName, ...)
	if exports.mek_integration:isPlayerGeneralAdmin(thePlayer) then
		local args = { ... }
		if #args < 4 then
			outputChatBox(
				"Kullanım: /"
					.. commandName
					.. " [id/name] [color1 (-1 for random)] [color2 (-1 for random)] [Job ID -1 for none]",
				thePlayer,
				255,
				194,
				14
			)
			outputChatBox("Job 1 = Delivery Driver", thePlayer, 255, 194, 14)
			outputChatBox("Job 2 = Taxi Driver", thePlayer, 255, 194, 14)
			outputChatBox("Job 3 = Bus Driver", thePlayer, 255, 194, 14)
			outputChatBox("Job 4 = Sigara Kaçakçılığı", thePlayer, 255, 194, 14)
		else
			local vehicleID = tonumber(args[1])
			local col1, col2, job

			if not vehicleID then
				local vehicleEnd = 1
				repeat
					vehicleID = getVehicleModelFromName(table.concat(args, " ", 1, vehicleEnd))
					vehicleEnd = vehicleEnd + 1
				until vehicleID or vehicleEnd == #args
				if vehicleEnd == #args then
					outputChatBox("Invalid Vehicle Name.", thePlayer, 255, 0, 0)
					return
				else
					col1 = tonumber(args[vehicleEnd])
					col2 = tonumber(args[vehicleEnd + 1])
					job = tonumber(args[vehicleEnd + 2])
				end
			else
				col1 = tonumber(args[2])
				col2 = tonumber(args[3])
				job = tonumber(args[4])
			end

			local id = vehicleID

			local r = getPedRotation(thePlayer)
			local x, y, z = getElementPosition(thePlayer)
			local interior = getElementInterior(thePlayer)
			local dimension = getElementDimension(thePlayer)
			x = x + ((math.cos(math.rad(r))) * 5)
			y = y + ((math.sin(math.rad(r))) * 5)

			local plate = exports.mek_global:generatePlate()

			local vehicle = createVehicle(id, x, y, z, 0, 0, r, plate)
			if not vehicle then
				outputChatBox("[!]#FFFFFF Geçersiz araç ID veya aracınızı /aracpanel ile aktifleştiriniz.", thePlayer, 255, 0, 0, true)
			else
				local vehicleName = getVehicleName(vehicle)
				destroyElement(vehicle)

				local var1, var2 = exports.mek_vehicle:getRandomVariant(id)
				local smallestID = exports.mek_mysql:getSmallestID("vehicles")
				local insertid = dbExec(
					mysql:getConnection(),
					"INSERT INTO vehicles SET id = ?, job = ?, model = ?, x = ?, y = ?, z = ?, rotx = ?, roty = ?, rotz = ?, color1 = ?, color2 = ?, color3 = ?, color4 = ?, faction = ?, owner = ?, plate = ?, currx = ?, curry = ?, currz = ?, currrx = ?, currry = ?, currrz = ?, interior = ?, currinterior = ?, dimension = ?, currdimension = ?, variant1 = ?, variant2 = ?, creationDate = NOW(), createdBy = ?",
					smallestID,
					job,
					args[1],
					x,
					y,
					z,
					0.0,
					0.0,
					r,
					"[ [ 0, 0, 0 ] ]",
					"[ [ 0, 0, 0 ] ]",
					"[ [ 0, 0, 0 ] ]",
					"[ [0, 0, 0] ]",
					-1,
					-2,
					plate,
					x,
					y,
					z,
					0,
					0,
					r,
					interior,
					interior,
					dimension,
					dimension,
					var1,
					var2,
					getElementData(thePlayer, "account_id")
				)
				insertid = smallestID
				if insertid then
					reloadVehicle(insertid)

					local adminID = getElementData(thePlayer, "account_id")
					local addLog = dbExec(
						mysql:getConnection(),
						"INSERT INTO `vehicle_logs` (`vehID`, `action`, `actor`) VALUES ('"
							.. tostring(insertid)
							.. "', '"
							.. commandName
							.. " "
							.. vehicleName
							.. " (job "
							.. job
							.. ")', '"
							.. adminID
							.. "')"
					) or false
					if not addLog then
						outputDebugString("Failed to add vehicle logs.")
					end
				end
			end
		end
	end
end
addCommandHandler("makecivveh", createCivilianPermVehicle, false, false)

function loadAllVehicles(res)
	local vehicleLoadList = {}
	dbQuery(function(queryHandle)
		local res, rows, err = dbPoll(queryHandle, 0)
		if rows > 0 then
			Async:foreach(res, function(row)
				vehicleData[tonumber(row.id)] = {}
				for key, value in pairs(row) do
					vehicleData[tonumber(row.id)][key] = value
				end
				loadOneVehicle(row.id)
			end)
		end
	end, mysql:getConnection(), "SELECT * FROM vehicles WHERE deleted = 0 AND activity = 1 ORDER BY id ASC")
end
addEventHandler("onResourceStart", resourceRoot, loadAllVehicles)

function resume()
	for key, value in ipairs(threads) do
		coroutine.resume(value)
	end
end

function reloadVehicle(id)
	local theVehicle = exports.mek_pool:getElementByID("vehicle", tonumber(id))
	if theVehicle then
		removeSafe(tonumber(id))
		exports.mek_save:saveVehicleMods(theVehicle)
		destroyElement(theVehicle)
	end

	loadOneVehicle(id, false)
	return true
end

function loadOneVehicle(id, hasCoroutine, loadDeletedOne)
	if hasCoroutine == nil then
		hasCoroutine = false
	end

	if loadDeletedOne then
		loadDeletedOne = "AND deleted = 0 "
	else
		loadDeletedOne = ""
	end

	local row = "SELECT v.*, "
		.. "TO_SECONDS(last_used) AS last_used_sec, (CASE WHEN last_login IS NOT NULL THEN TO_SECONDS(last_login) ELSE NULL END) AS owner_last_login "
		.. "FROM vehicles v "
		.. "LEFT JOIN characters c ON v.owner = c.id "
		.. "WHERE v.id = "
		.. id
		.. " "
		.. loadDeletedOne
		.. "AND activity = 1 "
		.. "LIMIT 1"

	dbQuery(function(queryHandle)
		local res, rows, err = dbPoll(queryHandle, 0)
		if rows > 0 then
			for index, row in ipairs(res) do
				if hasCoroutine then
					coroutine.yield()
				end

				for k, v in pairs(row) do
					if v == nil then
						row[k] = nil
					else
						row[k] = tonumber(row[k]) or row[k]
					end
				end

				local var1, var2 = row.variant1, row.variant2
				if not isValidVariant(row.model, var1, var2) then
					var1, var2 = getRandomVariant(row.model)
					dbExec(
						mysql:getConnection(),
						"UPDATE vehicles SET variant1 = ?, variant2 = ? WHERE id = ?",
						var1,
						var2,
						row.id
					)
				end

				local vehicle = createVehicle(
					row.model,
					row.currx,
					row.curry,
					row.currz,
					row.currrx,
					row.currry,
					row.currrz,
					row.plate,
					false,
					var1,
					var2
				)
				if vehicle then
					setElementData(vehicle, "dbid", row.id)
					exports.mek_pool:allocateElement(vehicle, row.id)

					if row.paintjob ~= 0 then
						setVehiclePaintjob(vehicle, row.paintjob)
					end

					local color1 = fromJSON(row.color1)
					local color2 = fromJSON(row.color2)
					local color3 = fromJSON(row.color3)
					local color4 = fromJSON(row.color4)
					setVehicleColor(
						vehicle,
						color1[1],
						color1[2],
						color1[3],
						color2[1],
						color2[2],
						color2[3],
						color3[1],
						color3[2],
						color3[3],
						color4[1],
						color4[2],
						color4[3]
					)

					if armoredCars[row.model] then
						setVehicleDamageProof(vehicle, true)
					end

					if tonumber(row.armor) == 1 then
						setElementData(vehicle, "armor", 1)
						setElementHealth(vehicle, 1500)
					end

					local upgrades = row["upgrades"] and fromJSON(row["upgrades"]) or {}
					if type(upgrades) ~= "table" then
						upgrades = {}
					end

					for slot, upgrade in pairs(upgrades) do
						local upgradeID = tonumber(upgrade)
						if upgradeID and upgradeID > 0 then
							addVehicleUpgrade(vehicle, upgradeID)
						end
					end

					local upgradeItems = row["upgrade_items"] and fromJSON(row["upgrade_items"]) or {}
					if type(upgradeItems) ~= "table" then
						upgradeItems = {}
					end
					setElementData(vehicle, "upgrade_items", upgradeItems)

					local panelStates = fromJSON(row["panelStates"])
					for panel, state in ipairs(panelStates) do
						setVehiclePanelState(vehicle, panel - 1, tonumber(state) or 0)
					end

					local doorStates = fromJSON(row["doorStates"])
					for door, state in ipairs(panelStates) do
						setVehicleDoorState(vehicle, door - 1, tonumber(state) or 0)
					end

					local headlightColors = fromJSON(row["headlights"])
					if headlightColors then
						setVehicleHeadLightColor(vehicle, headlightColors[1], headlightColors[2], headlightColors[3])
					end
					setElementData(vehicle, "headlight_colors", headlightColors)

					local wheelStates = fromJSON(row["wheelStates"])
					setVehicleWheelStates(
						vehicle,
						tonumber(wheelStates[1]),
						tonumber(wheelStates[2]),
						tonumber(wheelStates[3]),
						tonumber(wheelStates[4])
					)

					setVehicleLocked(vehicle, row.owner ~= -1 and row.locked == 1)

					setVehicleSirensOn(vehicle, row.sirens == 1)

					if row.job > 0 then
						toggleVehicleRespawn(vehicle, true)
						setVehicleRespawnDelay(vehicle, 60000)
						setVehicleIdleRespawnDelay(vehicle, 15 * 60000)
						setElementData(vehicle, "job", row.job)
					else
						setElementData(vehicle, "job", 0)
					end

					setVehicleRespawnPosition(vehicle, row.x, row.y, row.z, row.rotx, row.roty, row.rotz)
					setElementData(vehicle, "respawn_position", { row.x, row.y, row.z, row.rotx, row.roty, row.rotz })

					setElementData(vehicle, "vehicle_shop_id", row.vehicle_shop_id)
					setElementData(vehicle, "fuel", row.fuel)
					setElementData(vehicle, "oldx", row.currx)
					setElementData(vehicle, "oldy", row.curry)
					setElementData(vehicle, "oldz", row.currz)
					setElementData(vehicle, "faction", tonumber(row.faction))
					setElementData(vehicle, "faction_rank", tonumber(row.faction_rank) or 1)
					setElementData(vehicle, "owner", tonumber(row.owner))
					setElementData(vehicle, "windows", false)
					setElementData(vehicle, "plate", row.plate)
					setElementData(vehicle, "registered", row.registered)
					setElementData(vehicle, "neon", row.neon)
					setElementData(vehicle, "plate_design", tonumber(row.plate_design))
					setElementData(vehicle, "activity", tonumber(row.activity) == 1)
					setElementData(vehicle, "fines", tonumber(row.fines))

					setElementData(vehicle, "vehicle_radio", 0)

					if row.last_used_sec ~= nil then
						setElementData(vehicle, "last_used", row.last_used_sec)
					end

					if row.owner_last_login ~= nil then
						setElementData(vehicle, "owner_last_login", row.owner_last_login)
					end

					local customTextures = fromJSON(row.textures) or {}
					setElementData(vehicle, "textures", customTextures)

					setElementData(vehicle, "deleted", row.deleted)

					setElementInterior(vehicle, row.currinterior)
					setElementDimension(vehicle, row.currdimension)

					setElementData(vehicle, "dimension", row.dimension)
					setElementData(vehicle, "interior", row.interior)

					setVehicleOverrideLights(vehicle, row.lights == 0 and 1 or row.lights)

					if row.hp <= 350 then
						setElementHealth(vehicle, 300)
						setVehicleDamageProof(vehicle, true)
						setVehicleEngineState(vehicle, false)
						setElementData(vehicle, "engine", false)
						setElementData(vehicle, "engine_broke", true)
					else
						setElementHealth(vehicle, row.hp)
						setVehicleEngineState(vehicle, row.engine == 1)
						setElementData(vehicle, "engine", row.engine == 1)
						setElementData(vehicle, "engine_broke", false)
					end
					setVehicleFuelTankExplodable(vehicle, false)

					setElementData(vehicle, "handbrake", row.handbrake == 1)
					if row.handbrake == 1 then
						setElementFrozen(vehicle, true)
					end

					local hasInterior, interior = exports["mek_vehicle-interiors"]:add(vehicle)
					if
						hasInterior
						and row.safepositionX
						and row.safepositionY
						and row.safepositionZ
						and row.safepositionRZ
					then
						addSafe(
							row.id,
							row.safepositionX,
							row.safepositionY,
							row.safepositionZ,
							row.safepositionRZ,
							interior
						)
					end

					if row.tinted == 1 then
						setElementData(vehicle, "tinted", true)
					end
					setElementData(vehicle, "odometer", tonumber(row.odometer))

					if getResourceFromName("mek_vehicle-manager") then
						exports["mek_vehicle-manager"]:loadCustomVehProperties(tonumber(row.id), vehicle)
					end

					if #customTextures > 0 then
						for somenumber, texture in ipairs(customTextures) do
							exports["mek_item-texture"]:addTexture(vehicle, texture[1], texture[2])
						end
					end

					if getResourceFromName("mek_item") then
						exports["mek_item"]:loadItems(vehicle)
					end

					return vehicle
				end
			end
		end
	end, mysql:getConnection(), row)
end

function vehicleExploded()
	local job = getElementData(source, "job")
	if not job or job <= 0 then
		setTimer(respawnVehicle, 60000, 1, source)
	end
end
addEventHandler("onVehicleExplode", root, vehicleExploded)

function vehicleRespawn(exploded)
	local id = getElementData(source, "dbid")
	local faction = getElementData(source, "faction")
	local factionRank = getElementData(source, "faction_rank")
	local job = getElementData(source, "job")
	local owner = getElementData(source, "owner")
	local windows = getElementData(source, "windows")
	local vehicleRadio = getElementData(source, "vehicle_radio") or 0

	if job > 0 then
		toggleVehicleRespawn(source, true)
		setVehicleRespawnDelay(source, 60000)
		setVehicleIdleRespawnDelay(source, 15 * 60000)
		setElementFrozen(source, true)
		setElementData(source, "handbrake", true)
	end

	local model = getElementModel(source)
	if armoredCars[tonumber(model)] then
		setVehicleDamageProof(source, true)
	else
		setVehicleDamageProof(source, false)
	end

	if getElementData(source, "armor") == 1 then
		setElementHealth(source, 1500)
	end

	setVehicleFuelTankExplodable(source, false)
	setVehicleEngineState(source, false)
	setVehicleLandingGearDown(source, true)

	setElementData(source, "engine_broke", false)

	setElementData(source, "dbid", id)
	setElementData(source, "fuel", 100)
	setElementData(source, "engine", false)
	setElementData(source, "windows", windows)
	setElementData(source, "vehicle_radio", vehicleRadio)

	local x, y, z = getElementPosition(source)
	setElementData(source, "oldx", x)
	setElementData(source, "oldy", y)
	setElementData(source, "oldz", z)

	setElementData(source, "faction", faction)
	setElementData(source, "faction_rank", factionRank)
	setElementData(source, "owner", owner)

	setVehicleOverrideLights(source, 1)
	setElementFrozen(source, false)

	setVehicleSirensOn(source, false)

	setVehicleLightState(source, 0, 0)
	setVehicleLightState(source, 1, 0)

	local dimension = getElementDimension(source)
	local interior = getElementInterior(source)

	setElementDimension(source, dimension)
	setElementInterior(source, interior)

	if owner == -1 then
		setVehicleLocked(source, false)
		setElementFrozen(source, true)
		setElementData(source, "handbrake", true)
	end

	setElementFrozen(source, getElementData(source, "handbrake"))
end
addEventHandler("onVehicleRespawn", resourceRoot, vehicleRespawn)

function setEngineStatusOnEnter(thePlayer, seat)
	if seat == 0 then
		local engine = getElementData(source, "engine") or false
		local model = getElementModel(source)

		if not enginelessVehicle[model] then
			if not engine then
				toggleControl(thePlayer, "brake_reverse", false)
				setVehicleEngineState(source, false)
			else
				toggleControl(thePlayer, "brake_reverse", true)
				setVehicleEngineState(source, true)
			end
		else
			toggleControl(thePlayer, "brake_reverse", true)
			setVehicleEngineState(source, true)
			setElementData(source, "engine", true)
		end
	end
	triggerEvent("sendCurrentInventory", thePlayer, source)
end
addEventHandler("onVehicleEnter", root, setEngineStatusOnEnter)

function vehicleExit(thePlayer, seat)
	if isElement(thePlayer) then
		if getElementType(thePlayer) ~= "player" then
			return
		end

		toggleControl(thePlayer, "brake_reverse", true)

		local dbid = getElementData(source, "dbid")
		setElementData(thePlayer, "last_vehicle_id", dbid)

		setElementFrozen(thePlayer, false)
	end
end
addEventHandler("onVehicleExit", root, vehicleExit)

function bindKeys()
	for _, player in ipairs(getElementsByType("player")) do
		if not (isKeyBound(player, "j", "down", toggleEngine)) then
			bindKey(player, "j", "down", toggleEngine)
		end

		if not (isKeyBound(player, "l", "down", toggleLights)) then
			bindKey(player, "l", "down", toggleLights)
		end

		if not (isKeyBound(player, "k", "down", toggleLock)) then
			bindKey(player, "k", "down", toggleLock)
		end
	end
end

function bindKeysOnJoin()
	bindKey(source, "j", "down", toggleEngine)
	bindKey(source, "l", "down", toggleLights)
	bindKey(source, "k", "down", toggleLock)
end
addEventHandler("onResourceStart", resourceRoot, bindKeys)
addEventHandler("onPlayerJoin", root, bindKeysOnJoin)

function toggleEngine(source, key, keystate)
	local vehicle = getPedOccupiedVehicle(source)
	if vehicle then
		local seat = getPedOccupiedVehicleSeat(source)
		if seat == 0 then
			if isTimer(engineTimers[source]) then
				return
			end

			local model = getElementModel(vehicle)

			if not enginelessVehicle[model] then
				local engine = getElementData(vehicle, "engine") or false
				local vehID = getElementData(vehicle, "dbid")

				if not engine then
					if canPlayerStartEngine(vehicle, source) then
						local fuel = getElementData(vehicle, "fuel") or 100
						local engineBroke = getElementData(vehicle, "engine_broke") or false

						if engineBroke then
							exports.mek_global:sendLocalMeAction(
								source,
								"aracı çalıştırmayı dener ancak başaramaz.",
								false,
								true
							)
							outputChatBox("[!]#FFFFFF Aracın motoru arızalı.", source, 255, 0, 0, true)
						elseif exports.mek_item:hasItem(vehicle, 74) then
							while exports.mek_item:hasItem(vehicle, 74) do
								exports.mek_item:takeItem(vehicle, 74)
							end
							blowVehicle(vehicle)
						elseif fuel > 0 then
							randomVehicleEngine = 1
							exports.mek_global:sendLocalMeAction(
								source,
								"aracın motorunu çalıştırmaya çalışır.",
								false,
								true
							)
							triggerClientEvent(root, "playVehicleSound", root, "public/sounds/engine_on.wav", vehicle)
							setTimer(function()
								if randomVehicleEngine == 1 then
									toggleControl(source, "brake_reverse", true)
									setVehicleEngineState(vehicle, true)
									setElementData(vehicle, "engine", true)
									setElementData(
										vehicle,
										"vehicle_radio",
										tonumber(getElementData(vehicle, "vehicle_radio_old") or 0)
									)
									setElementData(vehicle, "last_used", getRealTime().timestamp)
									dbExec(
										mysql:getConnection(),
										"UPDATE vehicles SET last_used = NOW() WHERE id = ?",
										vehID
									)
									exports["mek_vehicle-manager"]:addVehicleLogs(
										vehID,
										"Motor çalıştırıldı.",
										source
									)
									exports.mek_global:sendLocalDoAction(
										source,
										"Aracın motoru çalıştırıldı.",
										false,
										true
									)
								else
									exports.mek_global:sendLocalDoAction(
										source,
										"Aracın motoru çalıştırılmadı.",
										false,
										true
									)
								end
							end, 3000, 1)
						elseif fuel <= 0 then
							exports.mek_global:sendLocalMeAction(
								source,
								"motoru çalıştırmayı dener ancak başaramaz.",
								false,
								true
							)
							outputChatBox("[!]#FFFFFF Araçta hiç benzin yok.", source, 255, 0, 0, true)
						end
					else
						outputChatBox(
							"[!]#FFFFFF Aracı çalıştırmak için bir anahtara ihtiyacınız var.",
							source,
							255,
							0,
							0,
							true
						)
					end
				else
					exports.mek_global:sendLocalMeAction(source, "aracın motorunu kapatır.", false, true)
					triggerClientEvent(root, "playVehicleSound", root, "public/sounds/engine_off.mp3", vehicle)
					toggleControl(source, "brake_reverse", false)
					setVehicleEngineState(vehicle, false)
					setElementData(vehicle, "engine", false)
					setElementData(vehicle, "vehicle_radio", 0)
					setVehicleOverrideLights(vehicle, 1)
				end

				engineTimers[source] = setTimer(function() end, 3000, 1)
			end
		end
	end
end
addEvent("toggleEngine", true)
addEventHandler("toggleEngine", root, toggleEngine)
addCommandHandler("engine", toggleEngine)

function toggleLock(source, key, keystate)
	if isTimer(lockTimers[source]) then
		return
	end

	local vehicle = getPedOccupiedVehicle(source)

	if vehicle then
		triggerEvent("lockUnlockInsideVehicle", source, vehicle)
	else
		local dimension = getElementDimension(source)
		if dimension >= 19000 then
			local targetVehicle = exports.mek_pool:getElementByID("vehicle", dimension - 20000)
			if targetVehicle and exports["mek_vehicle-interiors"]:isNearExit(source, targetVehicle) then
				local locked = isVehicleLocked(targetVehicle)
				setVehicleLocked(targetVehicle, not locked)

				local sound = locked and "public/sounds/unlock.mp3" or "public/sounds/lock.mp3"
				local action = locked and "aracın kilidini açar." or "aracı kilitler."

				triggerClientEvent(root, "playVehicleSound", root, sound, targetVehicle)
				exports.mek_global:sendLocalMeAction(source, action)

				lockTimers[source] = setTimer(function() end, 1500, 1)
				return
			end
		end

		local interiorFound, interiorDistance = exports.mek_interior:lockUnlockHouseEvent(source, true)
		local x, y, z = getElementPosition(source)
		local nearbyVehicles = exports.mek_global:getNearbyElements(source, "vehicle", 30)

		local closestVehicle = nil
		local closestDistance = 31

		for _, veh in ipairs(nearbyVehicles) do
			local dbid = tonumber(getElementData(veh, "dbid"))
			local dist = getDistanceBetweenPoints3D(x, y, z, getElementPosition(veh))

			if
				dist < closestDistance
				and (
					exports.mek_global:isAdminOnDuty(source)
					or exports.mek_item:hasItem(source, 3, dbid)
					or exports.mek_faction:isPlayerInFaction(source, getElementData(veh, "faction"))
				)
			then
				closestVehicle = veh
				closestDistance = dist
			end
		end

		if interiorFound and closestVehicle then
			if closestDistance < interiorDistance then
				triggerEvent("lockUnlockOutsideVehicle", source, closestVehicle)
			else
				triggerEvent("lockUnlockHouse", source)
			end
		elseif closestVehicle then
			triggerEvent("lockUnlockOutsideVehicle", source, closestVehicle)
		elseif interiorFound then
			triggerEvent("lockUnlockHouse", source)
		end
	end

	lockTimers[source] = setTimer(function() end, 1500, 1)
end
addCommandHandler("lock", toggleLock, false, false)
addEvent("togLockVehicle", true)
addEventHandler("togLockVehicle", root, toggleLock)

function checkLock(thePlayer, seat, jacked)
	local locked = isVehicleLocked(source)

	if locked and not jacked then
		cancelEvent()
		outputChatBox("[!]#FFFFFF Aracın kapıları kilitli.", thePlayer, 255, 0, 0, true)
	end
end
addEventHandler("onVehicleStartExit", root, checkLock)

function toggleLights(source, key, keystate)
	local vehicle = getPedOccupiedVehicle(source)
	if vehicle then
		local model = getElementModel(vehicle)
		if not lightlessVehicle[model] then
			local lights = getVehicleOverrideLights(vehicle)
			local seat = getPedOccupiedVehicleSeat(source)

			if seat == 0 then
				if lights ~= 2 then
					setVehicleOverrideLights(vehicle, 2)
					local trailer = getVehicleTowedByVehicle(vehicle)
					if trailer then
						setVehicleOverrideLights(trailer, 2)
					end
				elseif lights ~= 1 then
					setVehicleOverrideLights(vehicle, 1)
					local trailer = getVehicleTowedByVehicle(vehicle)
					if trailer then
						setVehicleOverrideLights(trailer, 1)
					end
				end
			end
		end
	end
end
addCommandHandler("lights", toggleLights, true)

addEvent("togLightsVehicle", true)
addEventHandler("togLightsVehicle", root, function()
	toggleLights(client)
end)

function setRealInVehicle(thePlayer)
	if isVehicleLocked(source) then
		removePedFromVehicle(thePlayer)
		setVehicleLocked(source, true)
	else
		local dbid = getElementData(source, "dbid") or 0

		local owner = getElementData(source, "owner") or -1
		local faction = getElementData(source, "faction") or -1

		local carshopCost = getElementData(source, "carshop:cost") or 0
		local plate = getElementData(source, "plate") or "?"

		local fines = getElementData(source, "fines") or 0

		local butterflyDoorCheck = getElementData(source, "vDoorType") or 0
		if butterflyDoorCheck == 2 then
			butterflyDoorText = "#54d200VAR#ffc20e"
		else
			butterflyDoorText = "#ff0000YOK#ffc20e"
		end

		local ownerName = "?"
		if faction > 0 then
			ownerName = exports.mek_cache:getFactionNameFromID(faction)
		elseif owner > 0 then
			ownerName = exports.mek_cache:getCharacterNameFromID(owner):gsub("_", " ")
		end

		if dbid < 0 then
			outputChatBox(
				"[Araç] Bu " .. exports.mek_global:getVehicleName(source) .. " bir sivil araçtır.",
				thePlayer,
				255,
				194,
				14,
				true
			)
		else
			outputChatBox(
				"[Araç] Sahibi: " .. ownerName .. " / Model: " .. exports.mek_global:getVehicleName(source),
				thePlayer,
				255,
				194,
				14,
				true
			)
			outputChatBox(
				"[Araç] Fiyatı: ₺" .. exports.mek_global:formatMoney(carshopCost) .. " / Plaka: " .. plate,
				thePlayer,
				255,
				194,
				14,
				true
			)
			local armorText = getElementData(source, "armor") == 1 and "#00FF00VAR" or "#FF0000YOK"
			outputChatBox(
				"[Araç] Cezası: ₺"
					.. exports.mek_global:formatMoney(fines)
					.. " / Kelebek Kapı: "
					.. butterflyDoorText
					.. " / Araç Zırhı: "
					.. armorText,
				thePlayer,
				255,
				194,
				14,
				true
			)
		end
	end
end
addEventHandler("onVehicleEnter", root, setRealInVehicle)

function doBreakdown()
	if exports.mek_item:hasItem(source, 74) then
		while exports.mek_item:hasItem(source, 74) do
			exports.mek_item:takeItem(source, 74)
		end
		blowVehicle(source)
	else
		local health = getElementHealth(source)
		local engineBroke = getElementData(source, "engine_broke") or false

		if health <= 350 and not engineBroke then
			setElementHealth(source, 300)
			setVehicleDamageProof(source, true)
			setVehicleEngineState(source, false)
			setElementData(source, "engine_broke", false)
			setElementData(source, "engine", false)
			setElementData(source, "vehicle_radio", 0)

			local player = getVehicleOccupant(source)
			if player then
				toggleControl(player, "brake_reverse", false)
			end
		end
	end
end
addEventHandler("onVehicleDamage", root, doBreakdown)

function sellVehicle(thePlayer, commandName, targetPlayerName)
	if isPedInVehicle(thePlayer) then
		if not targetPlayerName then
			outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName =
				exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayerName)
			if targetPlayer and getElementData(targetPlayer, "dbid") then
				local px, py, pz = getElementPosition(thePlayer)
				local tx, ty, tz = getElementPosition(targetPlayer)
				if getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz) < 20 then
					local theVehicle = getPedOccupiedVehicle(thePlayer)
					if theVehicle then
						local vehicleID = getElementData(theVehicle, "dbid")
						if
							getElementData(theVehicle, "owner") == getElementData(thePlayer, "dbid")
							or exports.mek_integration:isPlayerServerOwner(thePlayer)
						then
							if getElementData(targetPlayer, "dbid") ~= getElementData(theVehicle, "owner") then
								if exports.mek_item:hasSpaceForItem(targetPlayer, 3, vehicleID) then
									if exports.mek_global:canPlayerBuyVehicle(targetPlayer) then
										local query = dbExec(
											mysql:getConnection(),
											"UPDATE vehicles SET owner = ?, last_used = NOW() WHERE id = ?",
											getElementData(targetPlayer, "dbid"),
											vehicleID
										)
										if query then
											setElementData(
												theVehicle,
												"owner",
												getElementData(targetPlayer, "dbid"),
												true
											)
											setElementData(
												theVehicle,
												"owner_last_login",
												getRealTime().timestamp,
												true
											)
											setElementData(theVehicle, "last_used", getRealTime().timestamp, true)

											exports.mek_item:takeItem(thePlayer, 3, vehicleID)

											if not exports.mek_item:hasItem(targetPlayer, 3, vehicleID) then
												exports.mek_item:giveItem(targetPlayer, 3, vehicleID)
											end

											outputChatBox(
												"[!]#FFFFFF Başarıyla "
													.. getVehicleName(theVehicle)
													.. " markalı araç "
													.. targetPlayerName
													.. " isimli oyuncuya sattınız.",
												thePlayer,
												0,
												255,
												0,
												true
											)
											outputChatBox(
												"[!]#FFFFFF "
													.. getPlayerName(thePlayer):gsub("_", " ")
													.. " isimli oyuncu size "
													.. getVehicleName(theVehicle)
													.. " markalı aracı sattı.",
												targetPlayer,
												0,
												255,
												0,
												true
											)
											exports.mek_logs:addLog(
												"sell",
												getPlayerName(thePlayer):gsub("_", " ")
													.. " isimli oyuncu "
													.. targetPlayerName
													.. " isimli oyuncuya "
													.. getVehicleName(theVehicle)
													.. " markalı aracı sattı."
											)

											local adminID = getElementData(thePlayer, "account_id")
											local addLog = dbExec(
												mysql:getConnection(),
												"INSERT INTO `vehicle_logs` (`vehID`, `action`, `actor`) VALUES ('"
													.. tostring(vehicleID)
													.. "', '"
													.. commandName
													.. " to "
													.. getPlayerName(targetPlayer)
													.. "', '"
													.. adminID
													.. "')"
											)
											if not addLog then
												outputDebugString("Failed to add vehicle logs.")
											end
										else
											outputChatBox("[!]#FFFFFF Bir sorun oluştu.", thePlayer, 255, 0, 0, true)
										end
									else
										outputChatBox(
											"[!]#FFFFFF " .. targetPlayerName .. " isimli oyuncunun çok aracı var.",
											thePlayer,
											255,
											0,
											0,
											true
										)
									end
								else
									outputChatBox(
										"[!]#FFFFFF " .. targetPlayerName .. " isimli oyuncunun envanteri dolu.",
										thePlayer,
										255,
										0,
										0,
										true
									)
								end
							else
								outputChatBox(
									"[!]#FFFFFF Kendinize kendi aracınızı satamazsınız.",
									thePlayer,
									255,
									0,
									0,
									true
								)
							end
						else
							outputChatBox("[!]#FFFFFF Bu araç sizin değil.", thePlayer, 255, 0, 0, true)
						end
					else
						outputChatBox("[!]#FFFFFF Bir araçda olmalısınız.", thePlayer, 255, 0, 0, true)
					end
				else
					outputChatBox(
						"[!]#FFFFFF " .. targetPlayerName .. " isimli oyuncudan çok uzaktasın.",
						thePlayer,
						255,
						0,
						0,
						true
					)
				end
			end
		end
	end
end
addCommandHandler("sell", sellVehicle, false, false)
addCommandHandler("aracsat", sellVehicle, false, false)
addEvent("sellVehicle", true)
addEventHandler("sellVehicle", resourceRoot, sellVehicle)

local function playVehicleLockSound(vehicle, locked)
	local sound = locked and "public/sounds/lock.mp3" or "public/sounds/unlock.mp3"
	local action = locked and "aracı kilitler." or "aracın kilidini açar."
	triggerClientEvent(root, "playVehicleSound", root, sound, vehicle)
	exports.mek_global:sendLocalMeAction(source, action)
end

local function toggleVehicleLockState(vehicle, lockState)
	setVehicleLocked(vehicle, lockState)
	playVehicleLockSound(vehicle, lockState)
end

function lockUnlockInside(vehicle)
	if not isElement(vehicle) then
		return
	end

	local model = getElementModel(vehicle)
	local owner = getElementData(vehicle, "owner")
	local dbid = getElementData(vehicle, "dbid")

	if not locklessVehicle[model] or exports.mek_item:hasItem(source, 3, dbid) then
		local seat = getPedOccupiedVehicleSeat(source)
		if seat == 0 or exports.mek_item:hasItem(source, 3, dbid) then
			local isLocked = isVehicleLocked(vehicle)
			toggleVehicleLockState(vehicle, not isLocked)
			lockTimers[source] = setTimer(function() end, 1000, 1)
		end
	end
end
addEvent("lockUnlockInsideVehicle", true)
addEventHandler("lockUnlockInsideVehicle", root, lockUnlockInside)

function lockUnlockOutside(vehicle)
	if not isElement(vehicle) then
		return
	end

	local dbid = getElementData(vehicle, "dbid")
	local isLocked = isVehicleLocked(vehicle)
	toggleVehicleLockState(vehicle, not isLocked)

	if not storeTimers[vehicle] or not isTimer(storeTimers[vehicle]) then
		storeTimers[vehicle] = setTimer(storeVehicleLockState, 180000, 1, vehicle, dbid)
	end
end
addEvent("lockUnlockOutsideVehicle", true)
addEventHandler("lockUnlockOutsideVehicle", root, lockUnlockOutside)

function storeVehicleLockState(vehicle, dbid)
	if not isElement(vehicle) then
		return
	end

	local dbid = getElementData(vehicle, "dbid")
	if tonumber(dbid) and tonumber(dbid) > 0 then
		local state = isVehicleLocked(vehicle) and 1 or 0
		dbExec(
			mysql:getConnection(),
			"UPDATE vehicles SET locked = ? WHERE id = ? LIMIT 1",
			tostring(state),
			tostring(dbid)
		)
	end
	storeTimers[vehicle] = nil
end

function setVehiclePosition(thePlayer, commandName)
	local vehicle = getPedOccupiedVehicle(thePlayer)
	if not vehicle then
		outputChatBox("[!]#FFFFFF Araç içerisinde değilsiniz.", thePlayer, 255, 0, 0, true)
	else
		local playerid = getElementData(thePlayer, "dbid")
		local playerfid = getElementData(thePlayer, "faction")
		local owner = getElementData(vehicle, "owner")
		local dbid = getElementData(vehicle, "dbid")
		local carfid = getElementData(vehicle, "faction")
		local x, y, z = getElementPosition(vehicle)

		if
			(owner == playerid)
			or (exports.mek_item:hasItem(thePlayer, 3, dbid))
			or (exports.mek_integration:isPlayerTrialAdmin(thePlayer))
		then
			if dbid < 0 then
				outputChatBox("[!]#FFFFFF Bir sorun oluştu.", thePlayer, 255, 0, 0, true)
			else
				setElementData(vehicle, "requires.vehpos", nil)
				local rx, ry, rz = getVehicleRotation(vehicle)

				local interior = getElementInterior(thePlayer)
				local dimension = getElementDimension(thePlayer)

				dbExec(
					mysql:getConnection(),
					"UPDATE vehicles SET x = ?, y = ?, z = ?, rotx = ?, roty = ?, rotz = ?, currx = ?, curry = ?, currz = ?, currrx = ?, currry = ?, currrz = ?, interior = ?, currinterior = ?, dimension = ?, currdimension = ? WHERE id = ?",
					x,
					y,
					z,
					rx,
					ry,
					rz,
					x,
					y,
					z,
					rx,
					ry,
					rz,
					interior,
					interior,
					dimension,
					dimension,
					dbid
				)
				setVehicleRespawnPosition(vehicle, x, y, z, rx, ry, rz)
				setElementData(vehicle, "respawn_position", { x, y, z, rx, ry, rz })
				setElementData(vehicle, "interior", interior)
				setElementData(vehicle, "dimension", dimension)
				outputChatBox("[!]#FFFFFF Aracınızı başarıyla park ettiniz.", thePlayer, 0, 255, 0, true)

				local adminID = getElementData(thePlayer, "account_id")
				local addLog = dbExec(
					mysql:getConnection(),
					"INSERT INTO `vehicle_logs` (`vehID`, `action`, `actor`) VALUES ('"
						.. tostring(dbid)
						.. "', '"
						.. commandName
						.. "', '"
						.. adminID
						.. "')"
				)
				if not addLog then
					outputDebugString("Failed to add vehicle logs.")
				end
			end
		end
	end
end
addCommandHandler("vehpos", setVehiclePosition, false, false)
addCommandHandler("park", setVehiclePosition, false, false)

function setVehiclePosition2(thePlayer, commandName, vehicleID)
	if exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
		local vehicleID = tonumber(vehicleID)
		if not vehicleID or vehicleID < 0 then
			outputChatBox("Kullanım: /" .. commandName .. " [Araç ID]", thePlayer, 255, 194, 14)
		else
			local vehicle = exports.mek_pool:getElementByID("vehicle", vehicleID)
			if vehicle then
				setElementData(vehicle, "requires.vehpos")
				local x, y, z = getElementPosition(vehicle)
				local rx, ry, rz = getVehicleRotation(vehicle)

				local interior = getElementInterior(thePlayer)
				local dimension = getElementDimension(thePlayer)

				dbExec(
					mysql:getConnection(),
					"UPDATE vehicles SET x = ?, y = ?, z = ?, rotx = ?, roty = ?, rotz = ?, currx = ?, curry = ?, currz = ?, currrx = ?, currry = ?, currrz = ?, interior = ?, currinterior = ?, dimension = ?, currdimension = ? WHERE id = ?",
					x,
					y,
					z,
					rx,
					ry,
					rz,
					x,
					y,
					z,
					rx,
					ry,
					rz,
					interior,
					interior,
					dimension,
					dimension,
					vehicleID
				)
				setVehicleRespawnPosition(vehicle, x, y, z, rx, ry, rz)
				setElementData(vehicle, "respawn_position", { x, y, z, rx, ry, rz })
				setElementData(vehicle, "interior", interior)
				setElementData(vehicle, "dimension", dimension)
				outputChatBox("[!]#FFFFFF Aracınızı başarıyla park ettiniz.", thePlayer, 0, 255, 0, true)
			else
				outputChatBox("[!]#FFFFFF Bir sorun oluştu.", thePlayer, 255, 0, 0, true)
			end
		end
	end
end
addCommandHandler("avehpos", setVehiclePosition2, false, false)
addCommandHandler("apark", setVehiclePosition2, false, false)

function setVehiclePosition3(vehicle)
	local playerid = getElementData(source, "dbid")
	local owner = getElementData(vehicle, "owner")
	local dbid = getElementData(vehicle, "dbid")
	local x, y, z = getElementPosition(vehicle)

	if
		(owner == playerid)
		or (exports.mek_item:hasItem(source, 3, dbid))
		or (exports.mek_integration:isPlayerTrialAdmin(source))
	then
		if dbid < 0 then
			outputChatBox("[!]#FFFFFF Bir sorun oluştu.", source, 255, 0, 0, true)
		else
			setElementData(vehicle, "requires.vehpos")
			local rx, ry, rz = getVehicleRotation(vehicle)

			local interior = getElementInterior(source)
			local dimension = getElementDimension(source)

			dbExec(
				mysql:getConnection(),
				"UPDATE vehicles SET x = ?, y = ?, z = ?, rotx = ?, roty = ?, rotz = ?, currx = ?, curry = ?, currz = ?, currrx = ?, currry = ?, currrz = ?, interior = ?, currinterior = ?, dimension = ?, currdimension = ? WHERE id = ?",
				x,
				y,
				z,
				rx,
				ry,
				rz,
				x,
				y,
				z,
				rx,
				ry,
				rz,
				interior,
				interior,
				dimension,
				dimension,
				dbid
			)
			setVehicleRespawnPosition(vehicle, x, y, z, rx, ry, rz)
			setElementData(vehicle, "respawn_position", { x, y, z, rx, ry, rz })
			setElementData(vehicle, "interior", interior)
			setElementData(vehicle, "dimension", dimension)
			outputChatBox("[!]#FFFFFF Aracınızı başarıyla park ettiniz.", thePlayer, 0, 255, 0, true)
		end
	else
		outputChatBox("[!]#FFFFFF Bu aracı park edemezsiniz.", source, 255, 0, 0, true)
	end
end
addEvent("parkVehicle", true)
addEventHandler("parkVehicle", root, setVehiclePosition3)

function detachVehicle(thePlayer)
	if isPedInVehicle(thePlayer) and getPedOccupiedVehicleSeat(thePlayer) == 0 then
		local vehicle = getPedOccupiedVehicle(thePlayer)
		if getVehicleTowedByVehicle(vehicle) then
			detachTrailerFromVehicle(vehicle)
			outputChatBox("[!]#FFFFFF Römork koptu.", thePlayer, 0, 255, 0)
		else
			outputChatBox("[!]#FFFFFF Araçta römork yok.", thePlayer, 255, 0, 0)
		end
	end
end
addCommandHandler("detach", detachVehicle)

function addSafe(dbid, x, y, z, rz, interior)
	local tempobject = createObject(2332, x, y, z, 0, 0, rz)
	setElementInterior(tempobject, interior)
	setElementDimension(tempobject, dbid + 20000)
	safeTable[dbid] = tempobject
end

function removeSafe(dbid)
	if safeTable[dbid] then
		destroyElement(safeTable[dbid])
		safeTable[dbid] = nil
	end
end

function getSafe(dbid)
	return safeTable[dbid]
end

function canPlayerStartEngine(vehicle, player)
	local dbid = getElementData(vehicle, "dbid") or -1
	if dbid < 0 then
		return true
	end

	if (getElementData(vehicle, "job") or 0) ~= 0 then
		return true
	end

	if not getElementData(vehicle, "owner") or getElementData(vehicle, "owner") == -2 then
		if getElementModel(vehicle) == 410 and getElementData(player, "car_license") == 3 then
			return true
		elseif getElementModel(vehicle) == 468 and getElementData(player, "car_license") == 3 then
			return true
		end
	end

	if exports.mek_integration:isPlayerTrialAdmin(player, true) then
		return true
	end

	local faction = tonumber(getElementData(vehicle, "faction") or -1)
	if faction ~= -1 and exports.mek_faction:isPlayerInFaction(player, faction) then
		return true
	end

	return exports.mek_item:hasItem(player, 3, dbid) or exports.mek_item:hasItem(vehicle, 3, dbid)
end
