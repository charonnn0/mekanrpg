local limitSpeed = {}
local ccEnabled = false
local theVehicle = nil
local targetSpeed = 0

function doCruiseControl()
	if not isElement(theVehicle) or not getVehicleEngineState(theVehicle) then
		deactivateCruiseControl()
		return false
	end

	local x, y = angle(theVehicle)

	if x < 5 then
		local targetSpeedTmp = getElementSpeed(theVehicle)
		if targetSpeedTmp > targetSpeed then
			setPedControlState("accelerate", false)
		elseif targetSpeedTmp < targetSpeed then
			setPedControlState("accelerate", true)
		end
	end
end

function activateCruiseControl()
	addEventHandler("onClientRender", root, doCruiseControl)
	ccEnabled = true
	bindMe()
end

function deactivateCruiseControl()
	removeEventHandler("onClientRender", root, doCruiseControl)
	setPedControlState("accelerate", false)
	ccEnabled = false
end

function applyCruiseControl()
	theVehicle = getPedOccupiedVehicle(localPlayer)
	if theVehicle then
		if getVehicleOccupant(theVehicle) == localPlayer then
			if getVehicleEngineState(theVehicle) == true then
				if ccEnabled then
					deactivateCruiseControl()
				else
					targetSpeed = getElementSpeed(theVehicle)
					if targetSpeed > 10 then
						if
							getVehicleType(theVehicle) == "Automobile"
							or getVehicleType(theVehicle) == "Bike"
							or getVehicleType(theVehicle) == "Boat"
							or getVehicleType(theVehicle) == "Train"
							or getVehicleType(theVehicle) == "Plane"
							or getVehicleType(theVehicle) == "Helicopter"
						then
							activateCruiseControl()
						end
					end
				end
			end
		end
	end
end

addEventHandler("onClientPlayerVehicleExit", localPlayer, function(veh, seat)
	if seat == 0 then
		if ccEnabled then
			deactivateCruiseControl()
		end
	end
end)

function increaseCruiseControl()
	if ccEnabled then
		targetSpeed = targetSpeed + 5

		local tV = getPedOccupiedVehicle(localPlayer)
		if tV then
			local maxSpeed = limitSpeed[getElementModel(tV)]
			if maxSpeed then
				if targetSpeed > maxSpeed then
					targetSpeed = maxSpeed
				end
			end
		end
	end
end

function decreaseCruiseControl()
	if ccEnabled then
		targetSpeed = targetSpeed - 5
	end
end

function startAccel()
	if ccEnabled then
		deactivateCruiseControl()
	end
end

function stopAccel()
	if ccEnabled then
		deactivateCruiseControl()
	end
end

function restrictBikes(manual)
	local tV = getPedOccupiedVehicle(localPlayer)
	if tV then
		local maxSpeed = limitSpeed[getElementModel(tV)]
		if maxSpeed then
			tS = exports.mek_global:getVehicleVelocity(tV)
			if tS > maxSpeed then
				toggleControl("accelerate", false)
			else
				toggleControl("accelerate", true)
			end
		end
	end
end

function bindMe()
	bindKey("brake_reverse", "down", stopAccel)
	bindKey("accelerate", "down", startAccel)
end

function getElementSpeed(element, unit)
	if unit == nil then
		unit = 0
	end

	if isElement(element) then
		local x, y, z = getElementVelocity(element)
		if unit == "mph" or unit == 1 or unit == "1" then
			return (x ^ 2 + y ^ 2 + z ^ 2) ^ 0.5 * 100
		else
			return (x ^ 2 + y ^ 2 + z ^ 2) ^ 0.5 * 1.61 * 100
		end
	else
		return false
	end
end

bindKey("-", "down", decreaseCruiseControl)
bindKey("num_sub", "down", decreaseCruiseControl)

bindKey("=", "down", increaseCruiseControl)
bindKey("num_add", "down", increaseCruiseControl)

addCommandHandler("cc", applyCruiseControl)
addCommandHandler("cruisecontrol", applyCruiseControl)

addEventHandler("onClientRender", root, restrictBikes)
bindMe()

bindKey("c", "down", function()
	applyCruiseControl()
end)
