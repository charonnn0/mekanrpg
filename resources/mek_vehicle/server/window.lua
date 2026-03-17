local spamTimersSeatbeltWindow = {}

function toggleWindow(thePlayer)
	if not thePlayer then
		thePlayer = source
	end

	local theVehicle = getPedOccupiedVehicle(thePlayer)
	if theVehicle then
		if hasVehicleWindows(theVehicle) then
			if isTimer(spamTimersSeatbeltWindow[thePlayer]) then
				return
			end

			if not (isVehicleWindowUp(theVehicle)) then
				setElementData(theVehicle, "windows", false)
				triggerClientEvent(root, "playVehicleSound", root, "public/sounds/window.mp3", theVehicle)

				for i = 0, getVehicleMaxPassengers(theVehicle) do
					local player = getVehicleOccupant(theVehicle, i)
					if player then
						triggerEvent("setTintName", player)
					end
				end
			else
				setElementData(theVehicle, "windows", true)
				triggerClientEvent(root, "playVehicleSound", root, "public/sounds/window.mp3", theVehicle)

				for i = 0, getVehicleMaxPassengers(theVehicle) do
					local player = getVehicleOccupant(theVehicle, i)
					if player then
						triggerEvent("resetTintName", theVehicle, player)
					end
				end
			end
			spamTimersSeatbeltWindow[thePlayer] = setTimer(function() end, 1000, 1)
		end
	end
end
addEvent("vehicle:togWindow", true)
addEventHandler("vehicle:togWindow", root, toggleWindow)
addCommandHandler("togwindow", toggleWindow)
