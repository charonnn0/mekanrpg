local flashingVehicles = {}
local quickFlashState = 0

addEventHandler("onClientResourceStart", resourceRoot, function()
	bindKey("p", "down", toggleFlashers)

	for _, vehicle in ipairs(getElementsByType("vehicle")) do
		if isElementStreamedIn(vehicle) then
			local flasherState = getElementData(vehicle, "police_flashers")
			if flasherState and flasherState > 0 then
				flashingVehicles[vehicle] = true
			end
		end
	end
end)

function toggleFlashers()
	local theVehicle = getPedOccupiedVehicle(localPlayer)
	if theVehicle then
		triggerServerEvent("legal.toggleFlashers", theVehicle)
	end
end
addCommandHandler("togglecarflashers", toggleFlashers, false, false)

addEventHandler("onClientElementStreamIn", root, function()
	if getElementType(source) == "vehicle" and getElementData(source, "police_flashers") then
		local flasherState = getElementData(source, "police_flashers")
		if flasherState and flasherState > 0 then
			flashingVehicles[source] = true
		else
			local headlightColors = getElementData(source, "headlight_colors") or { 255, 255, 255 }
			setVehicleHeadLightColor(source, headlightColors[1], headlightColors[2], headlightColors[3])
		end
	end
end)

addEventHandler("onClientElementStreamOut", root, function()
	if getElementType(source) == "vehicle" then
		flashingVehicles[source] = nil
	end
end)

addEventHandler("onClientElementDataChange", root, function(theKey, oldValue, newValue)
	if theKey == "police_flashers" and isElementStreamedIn(source) and getElementType(source) == "vehicle" then
		local flasherState = getElementData(source, "police_flashers")
		if flasherState then
			flashingVehicles[source] = true
		end
	end
end)

function doFlashes()
	quickFlashState = (quickFlashState + 1) % 12
	for vehicle in pairs(flashingVehicles) do
		if not (isElement(vehicle)) then
			flashingVehicles[vehicle] = nil
		else
			local flasherState = getElementData(vehicle, "police_flashers") or 0
			_G["doFlashersFor" .. flasherState](vehicle)
		end
	end
end
setTimer(doFlashes, 50, 0)

function doFlashersFor0(vehicle)
	flashingVehicles[vehicle] = nil
	local headlightColors = getElementData(vehicle, "headlight_colors") or { 255, 255, 255 }
	setVehicleHeadLightColor(vehicle, headlightColors[1], headlightColors[2], headlightColors[3])
	setVehicleLightState(vehicle, 0, 0)
	setVehicleLightState(vehicle, 1, 0)
	setVehicleLightState(vehicle, 2, 0)
	setVehicleLightState(vehicle, 3, 0)
end

function doFlashersFor2(vehicle, backOnly, thePlayer)
	local state = quickFlashState < 6 and 1 or 0
	if not backOnly then
		setVehicleHeadLightColor(vehicle, 128, 64, 0)
		setVehicleLightState(vehicle, 0, 1 - state)
		setVehicleLightState(vehicle, 1, state)
	end
	setVehicleLightState(vehicle, 2, 1 - state)
	setVehicleLightState(vehicle, 3, state)
end

function doFlashersFor1(vehicle)
	doQuickFlashers(vehicle, 255, 0, 0, 0, 0, 255)
	doFlashersFor2(vehicle, true)
end

function doFlashersFor3(vehicle)
	doQuickFlashers(vehicle, 255, 0, 0, 255, 0, 0)
	doFlashersFor2(vehicle, true)
end

function doQuickFlashers(vehicle, r1, g1, b1, r2, g2, b2)
	if quickFlashState < 6 then
		setVehicleLightState(vehicle, 0, 1)
		setVehicleLightState(vehicle, 1, 0)
	else
		setVehicleLightState(vehicle, 0, 0)
		setVehicleLightState(vehicle, 1, 1)
	end

	if quickFlashState == 0 or quickFlashState == 2 or quickFlashState == 4 then
		setVehicleHeadLightColor(vehicle, r1, g1, b1)
	elseif quickFlashState == 6 or quickFlashState == 8 or quickFlashState == 10 then
		setVehicleHeadLightColor(vehicle, r2, g2, b2)
	else
		setVehicleHeadLightColor(vehicle, 255, 255, 255)
	end
end
