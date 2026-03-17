local function handleEngineFailure(vehicle, driver, vehicleID)
	setVehicleEngineState(vehicle, false)
	setElementData(vehicle, "engine", false)
	setElementData(vehicle, "vehicle_radio", 0)
	exports.mek_global:sendLocalDoAction(driver, "Aracın motoru arızalandı.")

	if exports.mek_item:hasItem(vehicle, 3, vehicleID) then
		exports.mek_item:takeItem(vehicle, 3, vehicleID)
		exports.mek_item:giveItem(driver, 3, vehicleID)
	end
end

addEventHandler("onVehicleDamage", root, function()
	local vehicle = source
	local health = getElementHealth(vehicle)
	local driver = getVehicleController(vehicle)
	local vehicleID = getElementData(vehicle, "dbid")

	if not driver or not vehicleID then
		return
	end

	if health <= 300 then
		if math.random(1, 2) == 1 then
			handleEngineFailure(vehicle, driver, vehicleID)
		end
	elseif health <= 400 then
		if math.random(1, 5) == 1 then
			handleEngineFailure(vehicle, driver, vehicleID)
		end
	end
end)
