local handbrakeTimers = {}

local NO_HANDBRAKE_VEHICLE_TYPES = {
	["BMX"] = true,
	["Bike"] = true,
}

local SPECIAL_HANDBRAKE_MODELS = {
	[573] = true,
	[556] = true,
	[444] = true,
}

function toggleHandbrake(player, vehicle, forceOnGround)
	local vehicleType = getVehicleType(vehicle)
	local vehicleModel = getElementModel(vehicle)

	if not getElementData(vehicle, "handbrake") then
		if NO_HANDBRAKE_VEHICLE_TYPES[vehicleType] then
			outputChatBox("[!]#FFFFFF Bu aracın el freni yoktur.", player, 255, 0, 0, true)
			return
		end

		local canEngageHandbrake = isVehicleOnGround(vehicle)
			or forceOnGround
			or vehicleType == "Boat"
			or vehicleType == "Helicopter"
			or SPECIAL_HANDBRAKE_MODELS[vehicleModel]

		if not canEngageHandbrake then
			return
		end

		if isTimer(handbrakeTimers[vehicle]) then
			killTimer(handbrakeTimers[vehicle])
		end

		setElementData(vehicle, "handbrake", true)
		setControlState(player, "handbrake", true)
		triggerClientEvent(root, "playVehicleSound", root, "public/sounds/handbrake_on.mp3", vehicle)

		handbrakeTimers[vehicle] = setTimer(function()
			if isElement(vehicle) and isElement(player) then
				setElementFrozen(vehicle, true)
				setControlState(player, "handbrake", false)
			end
		end, 3000, 1)
	else
		if isTimer(handbrakeTimers[vehicle]) then
			killTimer(handbrakeTimers[vehicle])
			handbrakeTimers[vehicle] = nil
		end

		setElementData(vehicle, "handbrake", false)
		setElementFrozen(vehicle, false)
		setControlState(player, "handbrake", false)

		triggerEvent("vehicle.handbrake.lifted", vehicle, player)
		triggerClientEvent(root, "playVehicleSound", root, "public/sounds/handbrake_off.mp3", vehicle)
	end
end

addEvent("vehicle.handbrake.lifted", true)
addEvent("vehicle.handbrake", true)

addEventHandler("vehicle.handbrake", root, function(forceOnGround)
	if client and source and client ~= source and getElementType(source) ~= "vehicle" then
		if exports.mek_sac then
			exports.mek_sac:banForEventAbuse(client, getEventName())
		end
		return
	end

	toggleHandbrake(client, source, forceOnGround)
end)
