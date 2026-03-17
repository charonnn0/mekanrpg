local timerLoadAllElevators = 30000

mysql = exports.mek_mysql

addEvent("onPlayerInteriorChange", true)

INTERIOR_X = 1
INTERIOR_Y = 2
INTERIOR_Z = 3
INTERIOR_INT = 4
INTERIOR_DIM = 5
INTERIOR_ANGLE = 6
INTERIOR_FEE = 7

INTERIOR_TYPE = 1
INTERIOR_DISABLED = 2
INTERIOR_LOCKED = 3
INTERIOR_OWNER = 4
INTERIOR_COST = 5
INTERIOR_SUPPLIES = 6

function createElevator(thePlayer, commandName, oneway)
	if exports.mek_integration:isPlayerSeniorAdmin(thePlayer) then
		if not getElementData(thePlayer, "adm:addelevator") then
			local x, y, z = getElementPosition(thePlayer)
			local rx, ry, rz = getElementRotation(thePlayer)
			local dim = getElementDimension(thePlayer)
			local int = getElementInterior(thePlayer)
			setElementData(thePlayer, "adm:addelevator", { x, y, z, rz, int, dim })
			outputChatBox(
				"[!]#FFFFFF Kaynak noktası kaydedildi. Lütfen varış noktasına tekrar /" .. commandName .. " yazın.",
				thePlayer,
				0,
				255,
				0,
				true
			)
			return false
		end

		local sourceP = getElementData(thePlayer, "adm:addelevator")

		local x1, y1, z1 = getElementPosition(thePlayer)
		local rx1, ry1, rz1 = getElementRotation(thePlayer)
		local interiorwithin = getElementInterior(thePlayer)
		local dimensionwithin = getElementDimension(thePlayer)
		local ix = tonumber(ix)
		local iy = tonumber(iy)
		local iz = tonumber(iz)
		local id = exports.mek_mysql:getSmallestID("elevators")

		if id then
			if oneway then
				if oneway == "1" then
					oneway = "1"
				else
					oneway = "0"
				end
			else
				oneway = "0"
			end

			local query = dbExec(
				mysql:getConnection(),
				[[
					INSERT INTO elevators 
					SET id = ?, x = ?, y = ?, z = ?, 
						tpx = ?, tpy = ?, tpz = ?, 
						dimensionwithin = ?, interiorwithin = ?, 
						dimension = ?, interior = ?, 
						rot = ?, tprot = ?, oneway = ?
				]],
				id,
				x1,
				y1,
				z1,
				sourceP[1],
				sourceP[2],
				sourceP[3],
				dimensionwithin,
				interiorwithin,
				sourceP[6],
				sourceP[5],
				rz1,
				sourceP[4],
				oneway
			)
			if query then
				loadOneElevator(id)
				outputChatBox(
					"[!]#FFFFFF Asansör ve asansör kumandası ID #" .. id .. " ile oluşturuldu. Envanterinizi kontrol edin!",
					thePlayer,
					0,
					255,
					0,
					true
				)
				exports.mek_item:giveItem(thePlayer, 73, id)
				removeElementData(thePlayer, "adm:addelevator")
			end
		else
			outputChatBox(
				"[!]#FFFFFF Asansör oluşturulurken bir hata oluştu. Tekrar deneyin.",
				thePlayer,
				255,
				0,
				0,
				true
			)
		end
	end
end
addCommandHandler("addelevator", createElevator, false, false)
addCommandHandler("adde", createElevator, false, false)

function getOposite(rot)
	if not rot or not tonumber(rot) then
		return 0
	end
	rot = tonumber(rot)
	if rot > 180 then
		return rot - 180
	else
		return rot + 180
	end
end

function findElevator(elevatorID)
	elevatorID = tonumber(elevatorID)
	if elevatorID > 0 then
		local possibleInteriors = getElementsByType("elevator")
		for _, elevator in ipairs(possibleInteriors) do
			local eleID = getElementData(elevator, "dbid")
			if eleID == elevatorID then
				local elevatorEntrance = getElementData(elevator, "entrance")
				local elevatorExit = getElementData(elevator, "exit")
				local elevatorStatus = getElementData(elevator, "status")

				return elevatorID, elevatorEntrance, elevatorExit, elevatorStatus, elevator
			end
		end
	end
	return 0
end

function findElevatorElement(elevatorID)
	elevatorID = tonumber(elevatorID)
	if elevatorID > 0 then
		local possibleInteriors = getElementsByType("elevator")
		for _, elevator in ipairs(possibleInteriors) do
			local eleID = getElementData(elevator, "dbid")
			if eleID == elevatorID then
				return elevator
			end
		end
	end
	return false
end

function reloadOneElevator(elevatorID, skipcheck)
	local dbid, entrance, exit, status, elevatorElement = findElevator(elevatorID)
	if dbid > 0 or skipcheck then
		local realElevatorElement = findElevatorElement(dbid)
		if not realElevatorElement then
			return
		end

		triggerClientEvent(root, "deleteInteriorElement", realElevatorElement, tonumber(dbid))
		destroyElement(realElevatorElement)
		loadOneElevator(tonumber(dbid), false)
	end
end

local loadedElevators = 0
local initializeSoFarDetector = 0
local stats_numberOfElevators = 0
local timerDelay = 0

function loadOneElevator(elevatorID, massLoad)
	thread:query(
		"SELECT rot, tprot, id, x, y, z, tpx, tpy, tpz, dimensionwithin, interiorwithin, dimension, interior, car, disabled, oneway FROM `elevators` WHERE id = "
			.. elevatorID,
		function(res, rows, err)
			for index, row in ipairs(res) do
				for k, v in pairs(row) do
					if v == null then
						row[k] = nil
					else
						row[k] = tonumber(v) or v
					end
				end

				local elevatorElement = createElement("elevator", "ele" .. tostring(row.id))
				setElementData(elevatorElement, "dbid", row.id)

				setElementData(
					elevatorElement,
					"entrance",
					{ row.x, row.y, row.z, row.interiorwithin, row.dimensionwithin, row.rot, 0 }
				)
				setElementData(
					elevatorElement,
					"exit",
					{ row.tpx, row.tpy, row.tpz, row.interior, row.dimension, row.tprot, 0 }
				)
				setElementData(elevatorElement, "status", {
					row.car,
					row.disabled == 1,
					name = "Asansör",
					type = 4,
				})
				setElementData(elevatorElement, "oneway", row.oneway == 1 or false)

				if massLoad then
					loadedElevators = loadedElevators + 1
					local newInitializeSoFarDetector = math.ceil(loadedElevators / (stats_numberOfElevators / 100))
					if
						loadedElevators == 1
						or loadedElevators == stats_numberOfElevators
						or initializeSoFarDetector ~= newInitializeSoFarDetector
					then
						triggerClientEvent(
							root,
							"elevator:initializeSoFar",
							root,
							loadedElevators,
							stats_numberOfElevators
						)
						initializeSoFarDetector = newInitializeSoFarDetector
					end
				else
					triggerClientEvent(root, "interior.schedulePickupLoading", root, elevatorElement)
				end
				exports.mek_pool:allocateElement(elevatorElement, tonumber(row.id), true)
			end
		end
	)
	return true
end

function loadAllElevators(res)
	triggerClientEvent(root, "interior.clearElevators", root)
	dbQuery(function(queryHandle)
		local res, rows = dbPoll(queryHandle, 0)
		if rows > 0 then
			for index, row in ipairs(res) do
				loadOneElevator(row.id)
			end
		end
	end, mysql:getConnection(), "SELECT id FROM elevators")
end
setTimer(loadAllElevators, timerLoadAllElevators, 1)

function isInteriorLocked(dimension)
	local data = {}
	local result = (
		dimension
		and (
			dbQuery(function(queryHandle)
				local res, rows = dbPoll(queryHandle, 0)
				if rows > 0 then
					data = res
				end
			end, mysql:getConnection(), "SELECT type, locked FROM interiors WHERE id = ?", dimension)
		)
	)
end

local elevatorTimer = {}

function enterElevator(goingin)
	local pickup = source
	local player = client

	if getElementType(pickup) ~= "elevator" then
		return false
	end

	local elevatorStatus = getElementData(pickup, "status")
	if elevatorStatus[INTERIOR_TYPE] == 3 then
		outputChatBox("[!]#FFFFFF Kapı kolunu deniyorsun ama kilitli görünüyor.", player, 255, 0, 0, true)
		return false
	end

	vehicle = getPedOccupiedVehicle(player)
	if (vehicle and elevatorStatus[INTERIOR_TYPE] ~= 0 and getVehicleOccupant(vehicle) == player) or not vehicle then
		if not vehicle and elevatorStatus[INTERIOR_TYPE] == 2 then
			outputChatBox("[!]#FFFFFF Bu giriş sadece araçlar için.", player, 255, 0, 0, true)
			return false
		end
	end

	if elevatorStatus[INTERIOR_DISABLED] then
		outputChatBox("[!]#FFFFFF Bu mülk şu anda devre dışı.", player, 255, 0, 0, true)
		return false
	end

	local currentCP = nil
	local otherCP = nil
	if goingin then
		currentCP = getElementData(pickup, "entrance")
		otherCP = getElementData(pickup, "exit")
	else
		currentCP = getElementData(pickup, "exit")
		otherCP = getElementData(pickup, "entrance")
	end

	local locked = false
	local movingInSameInt = false
	if currentCP[INTERIOR_DIM] == 0 and otherCP[INTERIOR_DIM] ~= 0 then
		locked = isInteriorLocked(otherCP[INTERIOR_DIM])
	elseif currentCP[INTERIOR_DIM] ~= 0 and otherCP[INTERIOR_DIM] == 0 then
		locked = isInteriorLocked(currentCP[INTERIOR_DIM])
	elseif
		currentCP[INTERIOR_DIM] ~= 0
		and otherCP[INTERIOR_DIM] ~= 0
		and currentCP[INTERIOR_DIM] ~= otherCP[INTERIOR_DIM]
	then
		locked = isInteriorLocked(currentCP[INTERIOR_DIM]) or isInteriorLocked(otherCP[INTERIOR_DIM])
	else
		locked = false
		movingInSameInt = true
	end

	local oneway = getElementData(pickup, "oneway")
	if oneway then
		if goingin then
			outputChatBox("[!]#FFFFFF Görünüşe göre bu kapı yalnızca diğer taraftan açılabiliyor.", player, 255, 0, 0, true)
			return false
		end
	end

	if locked then
		outputChatBox("[!]#FFFFFF Kapı kolunu deniyorsun ama kilitli görünüyor.", player, 255, 0, 0, true)
		return false
	end

	local dbid, entrance, exit, interiorType, interiorElement =
		exports.mek_interior:findProperty(player, otherCP[INTERIOR_DIM])
	if dbid > 0 then
	else
		dbid, entrance, exit, interiorType, interiorElement =
			exports.mek_interior:findProperty(player, currentCP[INTERIOR_DIM])
	end

	if vehicle then
		setTimer(
			warpVehicleIntoInteriorfunction,
			500,
			1,
			vehicle,
			otherCP[INTERIOR_INT],
			otherCP[INTERIOR_DIM],
			2,
			otherCP[INTERIOR_X],
			otherCP[INTERIOR_Y],
			otherCP[INTERIOR_Z],
			currentCP,
			otherCP,
			interiorElement,
			movingInSameInt
		)
		if interiorElement and isElement(interiorElement) and getElementType(interiorElement) == "interior" then
			setElementData(interiorElement, "last_used", getRealTime().timestamp)
			dbExec(mysql:getConnection(), "UPDATE interiors SET last_used = NOW() WHERE id = ?", dbid)
			exports["mek_interior-manager"]:addInteriorLogs(dbid, "ENTERED/EXITED", player)
		end
	elseif isElement(player) then
		if movingInSameInt then
			setElementPosition(player, otherCP[INTERIOR_X], otherCP[INTERIOR_Y], otherCP[INTERIOR_Z], true)
		else
			exports.mek_interior:setPlayerInsideInterior(interiorElement, player, otherCP, movingInSameInt)
		end
		return true
	else
		outputChatBox("[!]#FFFFFF Kapı kolunu deniyorsun ama kilitli görünüyor.", player, 255, 0, 0, true)
		return false
	end

	return false
end
addEvent("elevator.enter", true)
addEventHandler("elevator.enter", root, enterElevator)

function warpVehicleIntoInteriorfunction(
	vehicle,
	interior,
	dimension,
	offset,
	x,
	y,
	z,
	pickup,
	other,
	interiorElement,
	movingInSameInt
)
	if isElement(vehicle) then
		if elevatorTimer[vehicle] then
			return false
		end

		elevatorTimer[vehicle] = true

		setElementFrozen(vehicle, true)
		setElementVelocity(vehicle, 0, 0, 0)
		setElementAngularVelocity(vehicle, 0, 0, 0)

		local offset = getElementData(vehicle, "groundoffset") or 2
		local rx, ry, rz = getVehicleRotation(vehicle)

		setVehicleRotation(vehicle, 0, 0, rz)
		setElementPosition(vehicle, x, y, z - 1 + offset)
		setElementInterior(vehicle, interior)
		setElementDimension(vehicle, dimension)
		setElementRotation(vehicle, 0, 0, getOposite(other[INTERIOR_ANGLE]))

		setElementData(vehicle, "health", getElementHealth(vehicle))
		for i = 0, getVehicleMaxPassengers(vehicle) do
			local player = getVehicleOccupant(vehicle, i)
			if player then
				triggerClientEvent(player, "cantFallOffBike", player)
				setElementDimension(player, dimension)
				setElementInterior(player, interior)
				setCameraInterior(player, interior)
				triggerClientEvent(player, "setPlayerInsideInterior", interiorElement, other, interiorElement)
			end
		end

		setTimer(function()
			setElementAngularVelocity(vehicle, 0, 0, 0)
			setElementHealth(vehicle, getElementData(vehicle, "health") or 1000)
			setElementData(vehicle, "health", nil)
			setElementFrozen(vehicle, false)
			elevatorTimer[vehicle] = false
		end, 1000, 1)
	end
end

function fadeToBlack(player)
	fadeCamera(player, true, 0, 0, 0, 0)
	fadeCamera(player, false, 1, 0, 0, 0)
end

function fadeFromBlack(player)
	setTimer(fadeCamera, 2000, 1, player, true, 1, 0, 0, 0)
end

function deleteElevator(thePlayer, commandName, id)
	if exports.mek_integration:isPlayerSeniorAdmin(thePlayer) then
		if not (tonumber(id)) then
			outputChatBox("Kullanım: /" .. commandName .. " [ID]", thePlayer, 255, 194, 14)
		else
			id = tonumber(id)

			local dbid, entrance, exit, status, elevatorElement = findElevator(id)

			if elevatorElement then
				local query = dbExec(mysql:getConnection(), "DELETE FROM elevators WHERE id = ?", dbid)
				if query then
					reloadOneElevator(dbid)
					if commandName ~= "PROPERTYCLEANUP" then
						outputChatBox("[!]#FFFFFF Asansör #" .. id .. " silindi!", thePlayer, 0, 255, 0, true)
					end
				else
					if commandName ~= "PROPERTYCLEANUP" then
						outputChatBox("[!]#FFFFFF Bir sorun oluştu.", thePlayer, 255, 0, 0, true)
					end
				end
			else
				if commandName ~= "PROPERTYCLEANUP" then
					outputChatBox("[!]#FFFFFF Asansör bulunamadı.", thePlayer, 255, 0, 0, true)
				end
			end
		end
	end
end
addCommandHandler("delelevator", deleteElevator, false, false)
addCommandHandler("dele", deleteElevator, false, false)

function getNearbyElevators(thePlayer, commandName)
	if exports.mek_integration:isPlayerSeniorAdmin(thePlayer) then
		local posX, posY, posZ = getElementPosition(thePlayer)
		local dimension = getElementDimension(thePlayer)
		outputChatBox("[!]#FFFFFF Yakındaki Asansörler:", thePlayer, 0, 255, 0, true)
		local found = false

		local possibleElevators = getElementsByType("elevator")
		for _, elevator in ipairs(possibleElevators) do
			local elevatorEntrance = getElementData(elevator, "entrance")
			local elevatorExit = getElementData(elevator, "exit")

			for _, point in ipairs({ elevatorEntrance, elevatorExit }) do
				if point[INTERIOR_DIM] == dimension then
					local distance = getDistanceBetweenPoints3D(
						posX,
						posY,
						posZ,
						point[INTERIOR_X],
						point[INTERIOR_Y],
						point[INTERIOR_Z]
					)
					if distance <= 11 then
						local dbid = getElementData(elevator, "dbid")
						if point == elevatorEntrance then
							outputChatBox(
								"ID " .. dbid .. ", " .. elevatorExit[INTERIOR_DIM] .. " boyutuna çıkıyor.",
								thePlayer,
								255,
								126,
								0
							)
						else
							outputChatBox(
								"ID " .. dbid .. ", " .. elevatorEntrance[INTERIOR_DIM] .. " boyutuna çıkıyor.",
								thePlayer,
								255,
								126,
								0
							)
						end
						found = true
					end
				end
			end
		end

		if not found then
			outputChatBox("[!]#FFFFFF Yok.", thePlayer, 255, 0, 0, true)
		end
	end
end
addCommandHandler("nearbyelevators", getNearbyElevators, false, false)
addCommandHandler("nearbye", getNearbyElevators, false, false)

function fixNearbyElevator(thePlayer)
	local posX, posY, posZ = getElementPosition(thePlayer)
	local dimension = getElementDimension(thePlayer)
	outputChatBox("[!]#FFFFFF Yakındaki Asansörler Düzeltiliyor:", thePlayer, 0, 255, 0, true)
	local found = false
	local possibleElevators = getElementsByType("elevator")
	for _, elevator in ipairs(possibleElevators) do
		local elevatorEntrance = getElementData(elevator, "entrance")
		local elevatorExit = getElementData(elevator, "exit")
		elevator = elevator

		for _, point in ipairs({ elevatorEntrance, elevatorExit }) do
			if point[INTERIOR_DIM] == dimension then
				local distance = getDistanceBetweenPoints3D(
					posX,
					posY,
					posZ,
					point[INTERIOR_X],
					point[INTERIOR_Y],
					point[INTERIOR_Z]
				)
				if distance <= 11 then
					local dbid = getElementData(elevator, "dbid")
					if point == elevatorEntrance then
						reloadOneElevator(dbid)
						outputChatBox(
							"ID " .. dbid .. " düzeltildi, int ID #" .. elevatorExit[INTERIOR_DIM] .. " 'e çıkıyor.",
							thePlayer,
							255,
							126,
							0
						)
					else
						reloadOneElevator(dbid)
						outputChatBox(
							"ID " .. dbid .. " düzeltildi, int ID #" .. elevatorEntrance[INTERIOR_DIM] .. " 'e çıkıyor.",
							thePlayer,
							255,
							126,
							0
						)
					end
					found = true
				end
			end
		end
	end

	if not found then
		outputChatBox("[!]#FFFFFF Yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("fixnearbyelevators", fixNearbyElevator, false, false)
addCommandHandler("fixnearbye", fixNearbyElevator, false, false)

function delNearbyElevators(thePlayer, commandName)
	if
		exports.mek_integration:isPlayerServerManager(thePlayer)
		or exports.mek_integration:isPlayerGeneralAdmin(thePlayer)
		or exports.mek_integration:isPlayerSeniorAdmin(thePlayer)
	then
		local posX, posY, posZ = getElementPosition(thePlayer)
		local dimension = getElementDimension(thePlayer)
		outputChatBox("[!]#FFFFFF Yakındaki Asansörler Siliniyor:", thePlayer, 0, 255, 0, true)
		local found = false

		local possibleElevators = getElementsByType("elevator")
		for _, elevator in ipairs(possibleElevators) do
			local elevatorEntrance = getElementData(elevator, "entrance")
			local elevatorExit = getElementData(elevator, "exit")

			for _, point in ipairs({ elevatorEntrance, elevatorExit }) do
				if point[INTERIOR_DIM] == dimension then
					local distance = getDistanceBetweenPoints3D(
						posX,
						posY,
						posZ,
						point[INTERIOR_X],
						point[INTERIOR_Y],
						point[INTERIOR_Z]
					)
					if distance <= 11 then
						local dbid = getElementData(elevator, "dbid")
						if point == elevatorEntrance then
							if deleteElevator(thePlayer, "dele", dbid) then
								outputChatBox("[!]#FFFFFF Asansör ID #" .. dbid .. " silindi.", thePlayer, 0, 255, 0, true)
							end
						else
							if deleteElevator(thePlayer, "dele", dbid) then
								outputChatBox("[!]#FFFFFF Asansör ID #" .. dbid .. " silindi.", thePlayer, 0, 255, 0, true)
							end
						end
						found = true
					end
				end
			end
		end

		if not found then
			outputChatBox("[!]#FFFFFF Yok.", thePlayer, 255, 0, 0, true)
		end
	end
end
addCommandHandler("delnearbyelevators", delNearbyElevators, false, false)
addCommandHandler("delnearbye", delNearbyElevators, false, false)

function deleteElevatorsFromInterior(thePlayer, commandName, intID)
	if (exports.mek_integration:isPlayerTrialAdmin(thePlayer)) or commandName == "PROPERTYCLEANUP" then
		if (not tonumber(intID) or tonumber(intID) % 1 ~= 0) and commandName ~= "PROPERTYCLEANUP" then
			outputChatBox("Kullanım: /" .. commandName .. " [ID]", thePlayer, 255, 194, 14)
			outputChatBox("Bir mülkdeki tüm asansörleri siler, Int 0 = Dünya Haritası.", thePlayer, 220, 170, 0)
		else
			if tonumber(intID) == 0 and not exports.mek_integration:isPlayerSeniorAdmin(thePlayer) then
				outputChatBox("[!]#FFFFFF Sadece Kıdemli Yetkililer dünya haritasındaki tüm asansörleri silebilir.", thePlayer, 255, 0, 0, true)
				return false
			end

			if commandName ~= "PROPERTYCLEANUP" then
				outputChatBox("[!]#FFFFFF Mülk ID #" .. intID .. " içindeki Asansörler Siliniyor:", thePlayer, 0, 255, 0, true)
			end
			local found = false

			dbQuery(
				function(queryHandle, thePlayer)
					local res, rows, err = dbPoll(queryHandle, 0)
					if rows > 0 then
						local row = res[1]
						if deleteElevator(thePlayer, "PROPERTYCLEANUP", tonumber(row["id"])) then
							if commandName ~= "PROPERTYCLEANUP" then
								outputChatBox(
									"[!]#FFFFFF Asansör ID #" .. tonumber(row["id"]) .. " silindi.",
									thePlayer,
									0,
									255,
									0,
									true
								)
								found = true
							end
						end
					end
				end,
				{ thePlayer },
				mysql:getConnection(),
				"SELECT `id` FROM `elevators` WHERE `dimensionwithin` = ? OR `dimension` = ?",
				intID,
				intID
			)
		end
	end
end
addCommandHandler("delefromint", deleteElevatorsFromInterior, false, false)
addCommandHandler("deleteElevatorsFromInterior", deleteElevatorsFromInterior, false, false)

addEvent("toggleCarTeleportMode", false)
addEventHandler("toggleCarTeleportMode", root, function(player)
	local elevatorStatus = getElementData(source, "status")
	local mode = (elevatorStatus[INTERIOR_TYPE] + 1) % 4
	local query =
		dbExec(mysql:getConnection(), "UPDATE elevators SET car = ? WHERE id = ?", mode, getElementData(source, "dbid"))
	if query then
		elevatorStatus[INTERIOR_TYPE] = mode
		setElementData(source, "status", elevatorStatus)
		if mode == 0 then
			outputChatBox("[!]#FFFFFF Asansör girişi 'sadece oyuncular' olarak değiştirildi.", player, 0, 255, 0, true)
		elseif mode == 1 then
			outputChatBox("[!]#FFFFFF Asansör girişi 'oyuncular ve araçlar' olarak değiştirildi.", player, 0, 255, 0, true)
		elseif mode == 2 then
			outputChatBox("[!]#FFFFFF Asansör girişi 'sadece araçlar' olarak değiştirildi.", player, 0, 255, 0, true)
		else
			outputChatBox("[!]#FFFFFF Asansör girişi 'giriş yasak' olarak değiştirildi.", player, 0, 255, 0, true)
		end
	else
		outputChatBox("[!]#FFFFFF Bir sorun oluştu.", player, 255, 0, 0, true)
	end
end)

function toggleElevator(thePlayer, commandName, id)
	if exports.mek_integration:isPlayerSeniorAdmin(thePlayer) then
		id = tonumber(id)
		if not id then
			outputChatBox("Kullanım: /" .. commandName .. " [ID]", thePlayer, 255, 194, 14)
		else
			local dbid, entrance, exit, status, elevatorElement = findElevator(id)

			if elevatorElement then
				if status[INTERIOR_DISABLED] then
					dbExec(mysql:getConnection(), "UPDATE elevators SET disabled = 0 WHERE id = ?", dbid)
				else
					dbExec(mysql:getConnection(), "UPDATE elevators SET disabled = 1 WHERE id = ?", dbid)
				end
				reloadOneElevator(dbid)
			else
				outputChatBox("[!]#FFFFFF Asansör bulunamadı.", thePlayer, 255, 194, 14)
			end
		end
	end
end
addCommandHandler("toggleelevator", toggleElevator)
addCommandHandler("togglee", toggleElevator)
