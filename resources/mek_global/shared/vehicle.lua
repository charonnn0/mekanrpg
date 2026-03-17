local _getVehicleName = getVehicleName
function getVehicleName(theVehicle)
	if not theVehicle or (getElementType(theVehicle) ~= "vehicle") then
		return "?"
	end

	local name = _getVehicleName(theVehicle)
	local year = getElementData(theVehicle, "year")
	local brand = getElementData(theVehicle, "brand")
	local model = getElementData(theVehicle, "model")

	if year and brand and model then
		name = tostring(year) .. " " .. tostring(brand) .. " " .. tostring(model)
	end

	return name
end

local function randomLetter()
	return string.char(math.random(65, 90))
end

function generatePlate()
	local letter1 = randomLetter()
	local letter2 = randomLetter()
	local letter3 = randomLetter()
	local plate = "34 " .. letter1 .. letter2 .. letter3 .. " " .. math.random(10, 99)
	return plate
end

function isVehicleEmpty(vehicle)
	if not isElement(vehicle) or getElementType(vehicle) ~= "vehicle" then
		return true
	end

	local passengers = getVehicleMaxPassengers(vehicle)
	if type(passengers) == "number" then
		for seat = 4, passengers do
			if getVehicleOccupant(vehicle, seat) then
				return false
			end
		end
	end

	return true
end

function getVehicleVelocity(vehicle, player)
	local speedx, speedy, speedz = getElementVelocity(vehicle)
	local actualspeed = (speedx ^ 2 + speedy ^ 2 + speedz ^ 2) ^ 0.5
	if player and isElement(player) then
		return actualspeed * 111.847
	else
		return actualspeed * 180
	end
end
