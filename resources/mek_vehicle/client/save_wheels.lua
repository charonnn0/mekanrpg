local savedWheelRotations = {}

local frontWheelNames = {
	"wheel_lf_dummy",
	"wheel_rf_dummy",
}

addEventHandler("onClientVehicleStartExit", root, function(_, seat)
	if seat == 0 and isElement(source) then
		savedWheelRotations[source] = {}

		for _, wheelName in ipairs(frontWheelNames) do
			local rx, ry, rz = getVehicleComponentRotation(source, wheelName)
			if rx and ry and rz then
				savedWheelRotations[source][wheelName] = { rx, ry, rz }
			end
		end
	end
end)

addEventHandler("onClientVehicleEnter", root, function(_, seat)
	if seat == 0 then
		savedWheelRotations[source] = nil
	end
end)

addEventHandler("onClientElementDestroy", root, function()
	savedWheelRotations[source] = nil
end)

addEventHandler("onClientPedsProcessed", root, function()
	for vehicle, wheelData in pairs(savedWheelRotations) do
		if isElement(vehicle) then
			for wheelName, targetRotation in pairs(wheelData) do
				if targetRotation and #targetRotation == 3 then
					local currentRotation = { getVehicleComponentRotation(vehicle, wheelName) }
					if
						currentRotation[1]
						and (
							currentRotation[1] ~= targetRotation[1]
							or currentRotation[2] ~= targetRotation[2]
							or currentRotation[3] ~= targetRotation[3]
						)
					then
						setVehicleComponentRotation(vehicle, wheelName, unpack(targetRotation))
					end
				end
			end
		else
			savedWheelRotations[vehicle] = nil
		end
	end
end)
