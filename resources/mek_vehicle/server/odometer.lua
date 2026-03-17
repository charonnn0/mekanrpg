function handleOdoMeterRequest(totalDistance, syncDistance)
	if not totalDistance then
		local theVehicle = getPedOccupiedVehicle(client)
		if theVehicle == source then
			local totDistance = getElementData(theVehicle, "odometer") or 0
			triggerClientEvent(client, "vehicle.distance", theVehicle, totDistance)
		end
	else
		if not syncDistance then
			return
		end

		local theVehicle = getPedOccupiedVehicle(client)
		if theVehicle == source then
			local theSeat = getPedOccupiedVehicleSeat(client)
			if theSeat == 0 then
				local totDistance = getElementData(theVehicle, "odometer") or 0
				setElementData(theVehicle, "odometer", totDistance + syncDistance)
			end
		end
	end
end
addEvent("vehicle.distance", true)
addEventHandler("vehicle.distance", root, handleOdoMeterRequest)

function syncOdoOnEnter(thePlayer)
	local odometer = getElementData(source, "odometer") or 0
	triggerClientEvent(thePlayer, "vehicle.distance", source, odometer)
end
addEventHandler("onVehicleEnter", root, syncOdoOnEnter)
