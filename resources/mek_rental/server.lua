local RENT_VEHICLE_MODEL = 462
local RENT_VEHICLE_SHOP_ID = 48
local RENT_DURATION = 60 * 60 * 1000
local RENT_LOCATION = { x = 1675.7080078125, y = -2310.490234375, z = 13.542570114136 }
local RENT_RADIUS = 4
local RENT_PRICE = 50

local SPAWN_LOCATION = { x = 1674.91015625, y = -2316.9208984375, z = 13.3828125, rotation = 90 }

local rentalCol = createColSphere(RENT_LOCATION.x, RENT_LOCATION.y, RENT_LOCATION.z, RENT_RADIUS)

local rentalPickup = createPickup(RENT_LOCATION.x, RENT_LOCATION.y, RENT_LOCATION.z, 3, 1239, 0)
setElementData(rentalPickup, "text", "/motorkirala")

local activeRentals = {}

local function stopMotorRental(player, reason)
	if not isElement(player) then
		return
	end

	local rental = activeRentals[player]
	if not rental then
		return
	end

	if isTimer(rental.timer) then
		killTimer(rental.timer)
	end

	if isElement(rental.vehicle) then
		destroyElement(rental.vehicle)
	end

	exports.mek_pool:deallocateElement(rental.vehicle)
	activeRentals[player] = nil

	local msg = "[!]#FFFFFF Kiralamanız sona erdi."
	if reason then
		msg = msg .. " (" .. reason .. ")"
	end
	outputChatBox(msg, player, 255, 0, 0, true)
end

local function startMotorRental(player)
	if not isElementWithinColShape(player, rentalCol) then
		outputChatBox("[!]#FFFFFF Motor kiralamak için alan içinde olmalısınız.", player, 255, 0, 0, true)
		return
	end

	if not exports.mek_global:hasMoney(player, RENT_PRICE) then
		outputChatBox("[!]#FFFFFF Motor kiralamak için yeterli paranız yok.", player, 255, 0, 0, true)
		return
	end

	if activeRentals[player] then
		outputChatBox("[!]#FFFFFF Zaten bir motor kiraladınız.", player, 255, 0, 0, true)
		return
	end

	local vehicle = createVehicle(
		RENT_VEHICLE_MODEL,
		SPAWN_LOCATION.x,
		SPAWN_LOCATION.y,
		SPAWN_LOCATION.z,
		0,
		0,
		SPAWN_LOCATION.rotation,
		"KİRALIK"
	)
	if not vehicle then
		outputChatBox("[!]#FFFFFF Motor oluşturulamadı.", player, 255, 0, 0, true)
		return
	end

	local vehicleShopData = exports["mek_vehicle-manager"]:getInfoFromVehShopID(RENT_VEHICLE_SHOP_ID)
	local dbid = -getElementData(player, "dbid")

	exports.mek_global:takeMoney(player, RENT_PRICE)
	exports.mek_pool:allocateElement(vehicle, dbid)
	setVehicleOverrideLights(vehicle, 1)
	setVehicleEngineState(vehicle, false)
	setVehicleFuelTankExplodable(vehicle, false)
	setVehicleVariant(vehicle, exports.mek_vehicle:getRandomVariant(getElementModel(vehicle)))

	setElementData(vehicle, "rental_motor", true)
	setElementData(vehicle, "dbid", dbid)
	setElementData(vehicle, "fuel", 100)
	setElementData(vehicle, "engine", false)
	setElementData(vehicle, "oldx", x)
	setElementData(vehicle, "oldy", y)
	setElementData(vehicle, "oldz", z)
	setElementData(vehicle, "faction", -1)
	setElementData(vehicle, "owner", -1)
	setElementData(vehicle, "job", 0)
	setElementData(vehicle, "handbrake", false)
	exports["mek_vehicle-interiors"]:add(vehicle)

	setElementData(vehicle, "brand", vehicleShopData.vehbrand)
	setElementData(vehicle, "model", vehicleShopData.vehmodel)
	setElementData(vehicle, "year", vehicleShopData.vehyear)
	setElementData(vehicle, "vehicle_shop_id", vehicleShopData.id)

	warpPedIntoVehicle(player, vehicle)

	local rentalTimer = setTimer(function()
		stopMotorRental(player, "Süre doldu")
	end, RENT_DURATION, 1)

	activeRentals[player] = { vehicle = vehicle, timer = rentalTimer }

	outputChatBox("[!]#FFFFFF Motor başarıyla kiralandı. Süre: 1 saat.", player, 0, 255, 0, true)
end
addCommandHandler("motorkirala", startMotorRental, false, false)

addEventHandler("onPlayerQuit", root, function()
	stopMotorRental(source, "Oyuncu ayrıldı")
end)

addEventHandler("onElementDestroy", root, function()
	if getElementType(source) == "vehicle" and getElementData(source, "rental_motor") then
		for player, rental in pairs(activeRentals) do
			if rental.vehicle == source then
				exports.mek_pool:deallocateElement(source)
				if isTimer(rental.timer) then
					killTimer(rental.timer)
				end
				activeRentals[player] = nil
				if isElement(player) then
					outputChatBox("[!]#FFFFFF Kiraladığınız motor silindi.", player, 255, 0, 0, true)
				end
				break
			end
		end
	end
end)