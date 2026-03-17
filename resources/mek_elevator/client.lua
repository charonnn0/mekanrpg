addEventHandler("onClientPlayerVehicleEnter", localPlayer, function(vehicle)
	setElementData(vehicle, "groundoffset", 0.2 + getElementDistanceFromCentreOfMassToBaseOfModel(vehicle))
end)

addEvent("cantFallOffBike", true)
addEventHandler("cantFallOffBike", localPlayer, function()
	setPedCanBeKnockedOffBike(localPlayer, false)
	setTimer(setPedCanBeKnockedOffBike, 5000, 1, localPlayer, true)
end)
