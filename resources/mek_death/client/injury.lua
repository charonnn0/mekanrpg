setTimer(function()
	if getElementData(localPlayer, "injury") then
		if not getPedOccupiedVehicle(localPlayer) then
			local x, y, z = getElementPosition(localPlayer)
			fxAddBlood(x, y, z + 0.5, 0.00000, 0.00000, 0.00000, 0, 1)
		end
	end
end, 100, 0)
