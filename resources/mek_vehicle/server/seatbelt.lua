local spamTimersSeatbeltWindow = {}

function seatbelt(thePlayer)
	if getPedOccupiedVehicle(thePlayer) then
		local theVehicle = getPedOccupiedVehicle(thePlayer)
		if
			(getVehicleType(theVehicle) == "BMX" or getVehicleType(theVehicle) == "Bike")
			or (noBeltVehicles[getElementModel(theVehicle)] and getVehicleOccupant(theVehicle, 0) ~= thePlayer)
		then
			outputChatBox(
				"[!]#FFFFFF Kullandığınız araçta emniyet kemeri bulunmamaktadır.",
				thePlayer,
				255,
				0,
				0,
				true
			)
		else
			if isTimer(spamTimersSeatbeltWindow[thePlayer]) then
				return
			end

			if getElementData(thePlayer, "seatbelt") then
				setElementData(thePlayer, "seatbelt", false)
				triggerClientEvent(root, "playVehicleSound", root, "public/sounds/seatbelt.mp3", thePlayer)
			else
				setElementData(thePlayer, "seatbelt", true)
				triggerClientEvent(root, "playVehicleSound", root, "public/sounds/seatbelt.mp3", thePlayer)
			end

			spamTimersSeatbeltWindow[thePlayer] = setTimer(function() end, 1500, 1)
		end
	end
end
addCommandHandler("seatbelt", seatbelt)
addCommandHandler("belt", seatbelt)
addEvent("vehicle.seatbelt.toggle", true)
addEventHandler("vehicle.seatbelt.toggle", root, seatbelt)

function removeSeatbelt(thePlayer)
	if getElementData(thePlayer, "seatbelt") and not isPedInVehicle(thePlayer) then
		setElementData(thePlayer, "seatbelt", false)
		triggerClientEvent(root, "playVehicleSound", root, "public/sounds/seatbelt.mp3", thePlayer)
	end
end
addEventHandler("onVehicleExit", root, removeSeatbelt)

setTimer(function()
	for _, player in ipairs(getElementsByType("player")) do
		local vehicle = getPedOccupiedVehicle(player)
		if vehicle and isElement(vehicle) then
			local seat = getPedOccupiedVehicleSeat(player)
			if seat == 0 or seat == 1 then
				local seatbelt = getElementData(player, "seatbelt")
				if not seatbelt then
					local engine = getElementData(vehicle, "engine")
					if engine then
						local vehicleType = getVehicleType(vehicle)
						if vehicleType ~= "BMX" and vehicleType ~= "Bike" and vehicleType ~= "Boat" then
							local brand = getElementData(vehicle, "brand")
							local soundPath = "public/sounds/seatbelt_warning.wav"

							if brand then
								local brandPath = "public/sounds/belt/" .. string.lower(brand) .. ".mp3"
								if fileExists(brandPath) then
									soundPath = brandPath
								end
							end

							for i = 1, 2 do
								setTimer(function()
									if isElement(vehicle) and isElement(player) then
										if not getElementData(player, "seatbelt") then
											triggerClientEvent(
												player,
												"playVehicleSound",
												resourceRoot,
												soundPath,
												vehicle
											)
										end
									end
								end, 1000 * (i - 1), 1)
							end
						end
					end
				end
			end
		end
	end
end, 1000 * 15, 0)