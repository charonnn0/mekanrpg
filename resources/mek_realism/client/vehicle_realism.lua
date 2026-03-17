local sx, sy = guiGetScreenSize()
distanceTraveled = 0
local syncTraveled = 0
local oX, oY, oZ
local carSync = false
local lastVehicle = nil

function setUp(startedResource)
	oX, oY, oZ = getElementPosition(localPlayer)
end
addEventHandler("onClientResourceStart", resourceRoot, setUp)

function monitoring()
	local x, y, z = getElementPosition(localPlayer)
	if isPedInVehicle(localPlayer) then
		local x, y, z = getElementPosition(localPlayer)
		local thisTime = getDistanceBetweenPoints3D(x, y, z, oX, oY, oZ)
		distanceTraveled = distanceTraveled + thisTime
		syncTraveled = syncTraveled + thisTime
	end
	oX = x
	oY = y
	oZ = z
end
addEventHandler("onClientRender", root, monitoring)

function getDistanceTraveled()
	return distanceTraveled
end

function receiveDistanceSync(amount)
	if isPedInVehicle(localPlayer) then
		if source == getPedOccupiedVehicle(localPlayer) then
			distanceTraveled = amount or 0
			carSync = true
		end
	end
end
addEvent("vehicle.distance", true)
addEventHandler("vehicle.distance", root, receiveDistanceSync)

function onResourceStart()
	if isPedInVehicle(localPlayer) then
		local theVehicle = getPedOccupiedVehicle(localPlayer)
		if theVehicle then
			carSync = false
			triggerServerEvent("vehicle.distance", theVehicle)
		end
	end
	setTimer(stopCarSync, 1000, 0)
	setTimer(syncBack, 60000, 0)
end
addEventHandler("onClientResourceStart", resourceRoot, onResourceStart)

function syncBack(force)
	if isPedInVehicle(localPlayer) or force then
		local theVehicle = getPedOccupiedVehicle(localPlayer)
		if theVehicle or force then
			if carSync then
				local shit = force and lastVehicle or theVehicle
				if isElement(shit) then
					triggerServerEvent("vehicle.distance", shit, distanceTraveled, syncTraveled)
					syncTraveled = 0
				end
			end
		end
	end
end

function stopCarSync()
	if not (isPedInVehicle(localPlayer)) then
		if carSync then
			syncBack(true)
		end
		carSync = false
		distanceTraveled = 0
		syncTraveled = 0
	else
		lastVehicle = getPedOccupiedVehicle(localPlayer)
	end
end

addEvent("onClientElementDataChange", true)
addEventHandler("onClientElementDataChange", root, function(dataName, oldValue, newValue)
	if dataName == "windows" and getElementType(source) == "vehicle" then
		for _, window in ipairs({ 2, 3, 4, 5 }) do
			setVehicleWindowOpen(source, window, newValue)
		end
	end
end)

bindKey("f5", "down", function()
	triggerServerEvent("vehicle.seatbelt.toggle", localPlayer, localPlayer)
end)

bindKey("x", "down", function()
	triggerServerEvent("vehicle:togWindow", localPlayer)
end)
