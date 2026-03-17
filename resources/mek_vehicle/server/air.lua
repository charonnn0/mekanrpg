local spamTimers = {}

addEvent("air.down", true)
addEventHandler("air.down", root, function()
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not isTimer(spamTimers[client]) then
		if client.vehicle then
			if getElementVelocity(client.vehicle) == 0 then
				if exports.mek_item:hasItem(client.vehicle, 314) then
					local orginal = (getVehicleHandling(client.vehicle)["suspensionUpperLimit"] * -0.8)
					local option = getVehicleHandling(client.vehicle)["suspensionLowerLimit"]
					if option - 0.3 < orginal - 0.1 then
						setVehicleHandling(client.vehicle, "suspensionLowerLimit", option + 0.1)
						triggerClientEvent(root, "playVehicleSound", root, "public/sounds/air.mp3", client.vehicle)
						client.vehicle:setData("air_default", nil)
						spamTimers[client] = setTimer(function() end, 3000, 1)
					end
				end
			end
		end
	end
end)

addEvent("air.up", true)
addEventHandler("air.up", root, function()
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not isTimer(spamTimers[client]) then
		if client.vehicle then
			if getElementVelocity(client.vehicle) == 0 then
				if exports.mek_item:hasItem(client.vehicle, 314) then
					local orginal = (getVehicleHandling(client.vehicle)["suspensionUpperLimit"] * -1.5)
					local option = getVehicleHandling(client.vehicle)["suspensionLowerLimit"]
					if option - 0.2 > orginal - 0.3 then
						setVehicleHandling(client.vehicle, "suspensionLowerLimit", option - 0.1)
						triggerClientEvent(root, "playVehicleSound", root, "public/sounds/air.mp3", client.vehicle)
						client.vehicle:setData("air_default", nil)
						spamTimers[client] = setTimer(function() end, 3000, 1)
					end
				end
			end
		end
	end
end)
