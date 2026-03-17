components = {
	["bonnet_dummy"] = { 0, 0, 0, "y" },
	["boot_dummy"] = { 0, 0, 0, "y2" },
	["door_lf_dummy"] = { 0, -1, 0 },
	["door_rf_dummy"] = { 0, -1, 0 },
	["door_rr_dummy"] = { 0, -0.75, 0 },
	["door_lr_dummy"] = { 0, -0.75, 0 },
}

componentDetails = {
	["bonnet_dummy"] = { 0, "Kaput" },
	["boot_dummy"] = { 1, "Bagaj" },
	["door_lf_dummy"] = { 2, "Sol Ön Kapı" },
	["door_rf_dummy"] = { 3, "Sağ Ön Kapı" },
	["door_lr_dummy"] = { 4, "Sol Arka Kapı" },
	["door_rr_dummy"] = { 5, "Sağ Arka Kapı" },
}

vehicleTrunkState = {
	CLOSED = 0,
	OPEN = 1,
}

function getNearestVehicleComponent(vehicle, playerPosition)
	assert(
		isElement(vehicle),
		"Bad argument @ 'getNearestVehicleComponent' [Expected element at argument 1, got " .. type(vehicle) .. "]"
	)
	assert(vehicle.type == "vehicle", "Expected vehicle, got " .. vehicle.type)

	local vehicleRotation = vehicle.rotation

	local nearestComponent
	local distance = 9999

	for componentName, offsets in pairs(components) do
		local x, y, z = getVehicleComponentPosition(vehicle, componentName, "world")
		if x then
			local x0, y0, z0, x1, y1, z1 = getElementBoundingBox(vehicle)
			if offsets[4] then
				x, y, z = getElementPosition(vehicle)
				if offsets[4] == "y" then
					offsets[2] = (math.abs(y0)) + offsets[1]
				elseif offsets[4] == "y2" then
					offsets[2] = -(math.abs(y0))
				end
			end
			local vehMatrix = Matrix(x, y, z, vehicleRotation)
			componentPosition = vehMatrix:transformPosition(unpack(offsets))
			componentPosition.z = playerPosition.z
			local dist = getDistanceBetweenPoints3D(playerPosition, componentPosition)

			if dist <= 0.75 then
				if dist <= distance then
					distance = dist
					nearestComponent = componentName
				end
			end
		end
	end

	return nearestComponent, componentPosition
end

function isVehicleLightsEnabled(vehicle)
	local lights = false
	for i = 0, 3 do
		local state = getVehicleLightState(vehicle, i)
		if state == 0 then
			lights = true
			break
		end
	end
	return lights
end
