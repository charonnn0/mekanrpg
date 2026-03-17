screenSize = Vector2(guiGetScreenSize())

fonts = useFonts()
theme = useTheme()

addEventHandler("onClientElementDataChange", root, function(dataName, oldValue)
	if source == occupiedVehicle then
		if dataName == "gps_destination" then
			local dataValue = getElementData(source, dataName) or false

			if dataValue then
				gpsThread = coroutine.create(makeRoute)
				coroutine.resume(gpsThread, unpack(dataValue))
				waypointInterpolation = false
			else
				endRoute()
			end
		end
	end
end)

function setGPSDestination(worldX, worldY)
	if occupiedVehicle then
		setElementData(occupiedVehicle, "gps_destination", nil, false)
		setElementData(occupiedVehicle, "gps_destination", { worldX, worldY, localPlayer }, true)
	end
end

function resetGPSDestination(worldX, worldY)
	if occupiedVehicle then
		setElementData(occupiedVehicle, "gps_destination", nil, true)
	end
end

function addGPSLine(x, y)
	table.insert(gpsLines, { x, y })
end

function processGPSLines() end

function clearGPSRoute()
	resetGPSDestination()
	gpsLines = {}
end

addEventHandler("onClientVehicleEnter", root, function(player)
	if player == localPlayer then
		occupiedVehicle = source
	end
end)
