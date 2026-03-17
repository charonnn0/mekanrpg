local driver = false
local shooting = false
lastSlot = 0
settings = {}

local bikes = {
	[581] = true,
	[509] = true,
	[481] = true,
	[462] = true,
	[521] = true,
	[463] = true,
	[510] = true,
	[522] = true,
	[461] = true,
	[448] = true,
	[468] = true,
	[586] = true,
}

local function setupDriveby(player, seat)
	if seat == 0 then
		driver = true
	else
		driver = false
	end

	setPedWeaponSlot(localPlayer, 0)
	if settings.autoEquip then
		toggleDriveby()
	end
end
addEventHandler("onClientPlayerVehicleEnter", localPlayer, setupDriveby)

addEventHandler("onClientResourceStart", resourceRoot, function()
	bindKey("mouse2", "down", "Toggle Driveby", "")
	bindKey("e", "down", "Next driveby weapon", "1")
	bindKey("q", "down", "Previous driveby weapon", "-1")
	toggleControl("vehicle_next_weapon", false)
	toggleControl("vehicle_previous_weapon", false)
	triggerServerEvent("driveby.clientScriptLoaded", localPlayer)
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
	toggleControl("vehicle_next_weapon", true)
	toggleControl("vehicle_previous_weapon", true)
end)

addEvent("driveby.sendDriveBySettings", true)
addEventHandler("driveby.sendDriveBySettings", localPlayer, function(newSettings)
	settings = newSettings
	local newTable = {}
	for key, vehicleID in ipairs(settings.blockedVehicles) do
		newTable[vehicleID] = true
	end
	settings.blockedVehicles = newTable
end)

function toggleDriveby()
	if not isPedInVehicle(localPlayer) then
		return
	end

	local vehicleID = getElementModel(getPedOccupiedVehicle(localPlayer))
	if settings.blockedVehicles[vehicleID] or bikes[vehicleID] then
		return
	end

	local windows = getElementData(getPedOccupiedVehicle(localPlayer), "windows") or false
	if exports.mek_vehicle:hasVehicleWindows(getPedOccupiedVehicle(localPlayer)) and not windows then
		return
	end

	local dead = getElementData(localPlayer, "dead") or false
	local safezone = getElementData(localPlayer, "safezone") or false
	if dead or safezone then
		return
	end

	if exports.mek_network:getNetworkStatus() then
		return
	end

	if exports.mek_superman:isPlayerFlying(localPlayer) then
		return
	end

	local equipedWeapon = getPedWeaponSlot(localPlayer)
	if equipedWeapon == 0 then
		if driver then
			weaponsTable = settings.driver
		else
			weaponsTable = settings.passenger
		end

		local switchTo
		local switchToWeapon
		local lastSlotAmmo = getPedTotalAmmo(localPlayer, lastSlot)
		if not lastSlotAmmo or lastSlotAmmo == 0 or getSlotFromWeapon(getPedWeapon(localPlayer, lastSlot)) == 0 then
			for key, weaponID in ipairs(weaponsTable) do
				local slot = getSlotFromWeapon(weaponID)
				local weapon = getPedWeapon(localPlayer, slot)
				if weapon == 1 then
					weapon = 0
				end

				if weapon == weaponID then
					if getPedTotalAmmo(localPlayer, slot) ~= 0 then
						if not switchTo or slot == 4 then
							switchTo = slot
							switchToWeapon = weaponID
						end
					end
				end
			end
		else
			local lastSlotWeapon = getPedWeapon(localPlayer, lastSlot)
			for key, weaponID in ipairs(weaponsTable) do
				if weaponID == lastSlotWeapon then
					switchTo = lastSlot
					switchToWeapon = lastSlotWeapon
					break
				end
			end
		end

		if not switchTo then
			return
		end

		setPedDoingGangDriveby(localPlayer, true)
		setPedWeaponSlot(localPlayer, switchTo)
		limitDrivebySpeed(switchToWeapon)
		toggleControl("vehicle_look_left", false)
		toggleControl("vehicle_look_right", false)
		toggleControl("vehicle_secondary_fire", false)
		toggleTurningKeys(vehicleID, false)
		addEventHandler("onClientPlayerVehicleExit", localPlayer, removeKeyToggles)
	else
		setPedDoingGangDriveby(localPlayer, false)
		setPedWeaponSlot(localPlayer, 0)
		limitDrivebySpeed(switchToWeapon)
		toggleControl("vehicle_look_left", true)
		toggleControl("vehicle_look_right", true)
		toggleControl("vehicle_secondary_fire", true)
		toggleTurningKeys(vehicleID, true)
		removeEventHandler("onClientPlayerVehicleExit", localPlayer, removeKeyToggles)
	end
end
addCommandHandler("Toggle Driveby", toggleDriveby)

function removeKeyToggles(vehicle)
	toggleControl("vehicle_look_left", true)
	toggleControl("vehicle_look_right", true)
	toggleControl("vehicle_secondary_fire", true)
	toggleTurningKeys(getElementModel(vehicle), true)
	removeEventHandler("onClientPlayerVehicleExit", localPlayer, removeKeyToggles)
end

function switchDrivebyWeapon(key, progress)
	progress = tonumber(progress)
	if not progress then
		return
	end

	if shooting then
		return
	end

	if not isPedInVehicle(localPlayer) then
		return
	end

	local currentWeapon = getPedWeapon(localPlayer)
	if currentWeapon == 1 then
		currentWeapon = 0
	end

	local currentSlot = getPedWeaponSlot(localPlayer)
	if currentSlot == 0 then
		return
	end

	if driver then
		weaponsTable = settings.driver
	else
		weaponsTable = settings.passenger
	end

	local switchTo
	for key, weaponID in ipairs(weaponsTable) do
		if weaponID == currentWeapon then
			local i = key + progress
			while i ~= key do
				nextWeapon = weaponsTable[i]
				if nextWeapon then
					local slot = getSlotFromWeapon(nextWeapon)
					local weapon = getPedWeapon(localPlayer, slot)
					if weapon == nextWeapon then
						switchToWeapon = weapon
						switchTo = slot
						break
					end
				end
				if not weaponsTable[i + progress] then
					if progress < 0 then
						i = #weaponsTable
					else
						i = 1
					end
				else
					i = i + progress
				end
			end
			break
		end
	end

	if not switchTo then
		return
	end
	lastSlot = switchTo
	setPedWeaponSlot(localPlayer, switchTo)
	limitDrivebySpeed(switchToWeapon)
end
addCommandHandler("Next driveby weapon", switchDrivebyWeapon)
addCommandHandler("Previous driveby weapon", switchDrivebyWeapon)

local limiterTimer
function limitDrivebySpeed(weaponID)
	local speed = settings.shotdelay[tostring(weaponID)]
	if not speed then
		if not isControlEnabled("vehicle_fire") then
			toggleControl("vehicle_fire", true)
		end
		removeEventHandler("onClientPlayerVehicleExit", localPlayer, unbindFire)
		removeEventHandler("onClientPlayerWasted", localPlayer, unbindFire)
		unbindKey("vehicle_fire", "both", limitedKeyPress)
	else
		if isControlEnabled("vehicle_fire") then
			toggleControl("vehicle_fire", false)
			addEventHandler("onClientPlayerVehicleExit", localPlayer, unbindFire)
			addEventHandler("onClientPlayerWasted", localPlayer, unbindFire)
			bindKey("vehicle_fire", "both", limitedKeyPress, speed)
		end
	end
end

function unbindFire()
	unbindKey("vehicle_fire", "both", limitedKeyPress)
	if not isControlEnabled("vehicle_fire") then
		toggleControl("vehicle_fire", true)
	end
	removeEventHandler("onClientPlayerVehicleExit", localPlayer, unbindFire)
	removeEventHandler("onClientPlayerWasted", localPlayer, unbindFire)
end

local block
function limitedKeyPress(key, keyState, speed)
	if keyState == "down" then
		if block == true then
			return
		end
		shooting = true
		pressKey("vehicle_fire")
		block = true
		setTimer(function()
			block = false
		end, speed, 1)
		limiterTimer = setTimer(pressKey, speed, 0, "vehicle_fire")
	else
		shooting = false
		for k, timer in ipairs(getTimers()) do
			if timer == limiterTimer then
				killTimer(limiterTimer)
			end
		end
	end
end

function pressKey(controlName)
	setPedControlState(controlName, true)
	setTimer(setPedControlState, 150, 1, controlName, false)
end

function toggleTurningKeys(vehicleID, state)
	if bikes[vehicleID] then
		if not settings.steerBikes then
			toggleControl("vehicle_left", state)
			toggleControl("vehicle_right", state)
		end
	else
		if not settings.steerCars then
			toggleControl("vehicle_left", state)
			toggleControl("vehicle_right", state)
		end
	end
end

local function onWeaponSwitchWhileDriveby(prevSlot, curSlot)
	if isPedDoingGangDriveby(source) then
		limitDrivebySpeed(getPedWeapon(source, curSlot))
	end
end
addEventHandler("onClientPlayerWeaponSwitch", localPlayer, onWeaponSwitchWhileDriveby)
