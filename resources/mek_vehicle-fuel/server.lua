local fuellessVehicles = {
	[594] = true,
	[537] = true,
	[538] = true,
	[569] = true,
	[590] = true,
	[606] = true,
	[607] = true,
	[610] = true,
	[590] = true,
	[569] = true,
	[611] = true,
	[584] = true,
	[608] = true,
	[435] = true,
	[450] = true,
	[591] = true,
	[472] = true,
	[473] = true,
	[493] = true,
	[595] = true,
	[484] = true,
	[430] = true,
	[453] = true,
	[452] = true,
	[446] = true,
	[454] = true,
	[497] = true,
	[509] = true,
	[510] = true,
	[481] = true,
}

local fuelStations = {}

local fuelStationCoordinates = {
	{ 1944.234375, -1775.49609375, 13.39999961853, 3 },
	{ 1939.234375, -1775.49609375, 13.39999961853, 3 },
	{ 1934.234375, -1775.49609375, 13.39999961853, 3 },
	{ 1004.0546875, -940.1923828125, 42.1796875, 3 },
	{ 1004.0546875, -933.1923828125, 42.1796875, 3 },
	{ 1003.7177734375, -1353.6240234375, 13.331588745117, 3 },
	{ 1003.7177734375, -1347.6240234375, 13.331588745117, 3 },
	{ 1003.7177734375, -1342.6240234375, 13.331588745117, 3 },
	{ 117.09375, -1790.2734375, 1.4576441049576, 5 },
	{ 117.09375, -1777.2734375, 1.4576441049576, 5 },
}

for i = 1, #fuelStationCoordinates do
	local x, y, z, radius = unpack(fuelStationCoordinates[i])
	local colShape = createColSphere(x, y, z, radius)
	table.insert(fuelStations, colShape)

	local pickup = createPickup(x, y, z, 3, 1239, 0)
	setElementData(pickup, "text", "/yakital")
end

function fillFuelCommand(thePlayer, commandName, amount)
	local isInFuelStationZone = false
	for _, colShape in ipairs(fuelStations) do
		if isElementWithinColShape(thePlayer, colShape) then
			isInFuelStationZone = true
			break
		end
	end

	if not isInFuelStationZone then
		outputChatBox("[!]#FFFFFF Yakıt almak için yakıt istasyonunda olmalısınız.", thePlayer, 255, 0, 0, true)
		return
	end

	local vehicle = getPedOccupiedVehicle(thePlayer)
	if not vehicle then
		outputChatBox("[!]#FFFFFF Yakıt almak için bir araçta olmalısınız.", thePlayer, 255, 0, 0, true)
		return
	end

	if getPedOccupiedVehicleSeat(thePlayer) ~= 0 then
		outputChatBox("[!]#FFFFFF Sadece sürücü koltuğundan yakıt alabilirsiniz.", thePlayer, 255, 0, 0, true)
		return
	end

	if fuellessVehicles[getElementModel(vehicle)] then
		outputChatBox("[!]#FFFFFF Bu araç yakıt gerektirmez.", thePlayer, 255, 0, 0, true)
		return
	end

	local fuelAmount = tonumber(amount)
	if fuelAmount then
		fuelAmount = math.floor(fuelAmount)
	end

	if not fuelAmount then
		outputChatBox("Kullanım: /" .. commandName .. " [Litre]", thePlayer, 255, 194, 14)
		return
	end

	if fuelAmount > 100 then
		outputChatBox("[!]#FFFFFF Miktar maksimum 100 litre olmalıdır.", thePlayer, 255, 0, 0, true)
		return
	elseif fuelAmount <= 0 then
		outputChatBox("[!]#FFFFFF Miktar sıfır veya sıfırdan küçük olamaz.", thePlayer, 255, 0, 0, true)
		return
	end

	local currentFuel = math.floor(getElementData(vehicle, "fuel") or 0)
	local projectedFuel = currentFuel + fuelAmount

	if currentFuel >= 100 then
		outputChatBox("[!]#FFFFFF Aracınızın yakıt deposu zaten dolu.", thePlayer, 255, 0, 0, true)
		return
	elseif projectedFuel > 100 then
		outputChatBox("[!]#FFFFFF Aracınızın yakıt deposu bu kadar yakıt alamaz.", thePlayer, 255, 0, 0, true)
		return
	end

	local fuelPricePerLiter = 2
	local requiredMoney = fuelAmount * fuelPricePerLiter

	requiredMoney = math.floor(requiredMoney)

	local playerMoney = exports.mek_global:getMoney(thePlayer)
	if playerMoney < requiredMoney then
		outputChatBox(
			"[!]#FFFFFF Maalesef, bu miktar yakıt için " .. requiredMoney .. "₺ gerekmekte.",
			thePlayer,
			255,
			0,
			0,
			true
		)
		return
	end

	exports.mek_global:takeMoney(thePlayer, requiredMoney)
	setVehicleEngineState(vehicle, false)
	toggleControl(thePlayer, "brake_reverse", false)

	outputChatBox(
		"[!]#FFFFFF Belirtilen miktarda yakıt dolduruluyor, lütfen bekleyiniz...",
		thePlayer,
		0,
		255,
		0,
		true
	)

	setTimer(function()
		if not isElement(thePlayer) or not isElement(vehicle) then
			return
		end

		setElementData(vehicle, "fuel", projectedFuel)
		outputChatBox(
			"[!]#FFFFFF " .. requiredMoney .. "₺'ye " .. fuelAmount .. " litre yakıt dolduruldu.",
			thePlayer,
			0,
			255,
			0,
			true
		)

		toggleControl(thePlayer, "brake_reverse", true)
		setVehicleEngineState(vehicle, true)
	end, 5000, 1)
end
addCommandHandler("yakital", fillFuelCommand, false, false)

function fillFuelTank(vehicle, fuel)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	local currentFuel = tonumber(getElementData(vehicle, "fuel")) or 0
	local engine = getElementData(vehicle, "engine") or false
	local maxFuel = 100

	if math.floor(currentFuel) >= maxFuel then
		outputChatBox("[!]#FFFFFF Bu araç zaten tamamen dolu.", source, 255, 0, 0, true)
		return
	end

	if fuel <= 0 then
		outputChatBox("[!]#FFFFFF Bu yakıt bidonu boş.", source, 255, 0, 0, true)
		return
	end

	if engine then
		outputChatBox(
			"[!]#FFFFFF Çalışan araçlara yakıt dolduramazsın, lütfen önce motoru kapat.",
			source,
			255,
			0,
			0,
			true
		)
		return
	end

	local fuelToAdd = math.min(fuel, maxFuel - currentFuel)
	local newFuel = currentFuel + fuelToAdd

	setElementData(vehicle, "fuel", newFuel)
	triggerClientEvent(source, "syncFuel", vehicle, newFuel)

	outputChatBox(
		("[!]#FFFFFF Yakıt bidonundan aracına %d litre benzin doldurdun."):format(fuelToAdd),
		source,
		0,
		255,
		0,
		true
	)
	exports.mek_global:sendLocalMeAction(source, "küçük bir benzin bidonundan aracına yakıt doldurur.")

	exports.mek_item:takeItem(source, 57, fuel)
	if fuelToAdd < fuel then
		exports.mek_item:giveItem(source, 57, fuel - fuelToAdd)
	end
end
addEvent("fillFuelTankVehicle", true)
addEventHandler("fillFuelTankVehicle", root, fillFuelTank)

setTimer(function()
	for _, player in ipairs(getElementsByType("player")) do
		if isPedInVehicle(player) then
			local vehicle = getPedOccupiedVehicle(player)
			if vehicle then
				local seat = getPedOccupiedVehicleSeat(player)
				if seat == 0 then
					local model = getElementModel(vehicle)
					if not fuellessVehicles[model] then
						local engine = getElementData(vehicle, "engine") or false
						if engine then
							local fuel = getElementData(vehicle, "fuel") or 100
							if fuel >= 0 then
								local oldx = getElementData(vehicle, "oldx") or 0
								local oldy = getElementData(vehicle, "oldy") or 0
								local oldz = getElementData(vehicle, "oldz") or 0

								local x, y, z = getElementPosition(vehicle)

								local ignore = math.abs(oldz - z) > 50
									or math.abs(oldy - y) > 1000
									or math.abs(oldx - x) > 1000

								if not ignore then
									local distance = getDistanceBetweenPoints2D(x, y, oldx, oldy)
									if distance < 10 then
										distance = 10
									end

									local handlingTable = getModelHandling(model)
									local mass = handlingTable.mass

									local newFuel = (distance / 500) + (mass / 20000)
									newFuel = fuel - ((newFuel / 100) * 100)

									setElementData(vehicle, "fuel", newFuel)

									if newFuel < 0 then
										setElementData(vehicle, "fuel", 0)
										setVehicleEngineState(vehicle, false)
										setElementData(vehicle, "engine", false)
										setElementData(vehicle, "vehicle_radio", 0)
										setVehicleOverrideLights(vehicle, 1)
										toggleControl(player, "brake_reverse", false)
									end
								end

								setElementData(vehicle, "oldx", x)
								setElementData(vehicle, "oldy", y)
								setElementData(vehicle, "oldz", z)
							end
						end
					end
				end
			end
		end
	end

	for _, vehicle in ipairs(exports.mek_pool:getPoolElementsByType("vehicle")) do
		local engine = getElementData(vehicle, "engine") or false
		if engine then
			local driver = getVehicleOccupant(vehicle)
			if not driver then
				local fuel = getElementData(vehicle, "fuel") or 100
				if fuel >= 0 then
					local oldx = getElementData(vehicle, "oldx") or 0
					local oldy = getElementData(vehicle, "oldy") or 0
					local oldz = getElementData(vehicle, "oldz") or 0

					local x, y, z = getElementPosition(vehicle)
					local model = getElementModel(vehicle)

					local distance = getDistanceBetweenPoints2D(x, y, oldx, oldy)
					if distance < 10 then
						distance = 10
					end

					local handlingTable = getModelHandling(model)
					local mass = handlingTable.mass

					local newFuel = (distance / 500) + (mass / 20000)
					newFuel = fuel - ((newFuel / 100) * 100)

					setElementData(vehicle, "fuel", newFuel)

					if newFuel < 0 then
						setElementData(vehicle, "fuel", 0)
						setVehicleEngineState(vehicle, false)
						setElementData(vehicle, "engine", false)
						setElementData(vehicle, "vehicle_radio", 0)
						setVehicleOverrideLights(vehicle, 1)
					end
				end
			end
		end
	end
end, 10000, 0)
