local MAX_STAMINA = 100.0
local JUMP_STAMINA_COST = 6.5
local IDLE_RECOVERY_RATE_HIGH_STAMINA = 0.0065
local IDLE_RECOVERY_RATE_LOW_STAMINA = 0.004875
local WALK_DRAIN_RATE = 0.0020
local IDLE_SPEED_THRESHOLD = 0.05
local WALK_SPEED_MIN_THRESHOLD = 0.1
local WALK_SPEED_MAX_THRESHOLD = 0.2

local currentStamina = MAX_STAMINA
local isPlayerJumping = false
local areControlsToggledOff = false
local isAdminDuty = false

addEventHandler("onClientResourceStart", resourceRoot, function()
	isAdminDuty = getElementData(localPlayer, "duty_admin") or false
end)

addEventHandler("onClientElementDataChange", localPlayer, function(dataName, oldValue, newValue)
	if dataName == "duty_admin" then
		isAdminDuty = newValue
		if isAdminDuty then
			currentStamina = MAX_STAMINA
			setPlayerStaminaState(false)
		end
	end
end)

addEventHandler("onClientPreRender", root, function(timeSlice)
	if not isAdminDuty then
		if
			localPlayer:getData("logged")
			and not exports.mek_superman:isPlayerFlying(localPlayer)
			and not localPlayer.vehicle
			and not localPlayer:getData("dead")
			and not localPlayer:getData("cked")
		then
			local playerVelX, playerVelY, playerVelZ = getElementVelocity(localPlayer)
			local actualSpeed = (playerVelX * playerVelX + playerVelY * playerVelY) ^ 0.5

			if playerVelZ >= 0.1 and not isPlayerJumping then
				isPlayerJumping = true
				currentStamina = currentStamina - JUMP_STAMINA_COST

				if currentStamina <= 0 then
					currentStamina = 0
					setPlayerStaminaState(true)
				end
			end

			if playerVelZ < 0.05 then
				isPlayerJumping = false
			end

			if actualSpeed < IDLE_SPEED_THRESHOLD and not isPlayerJumping then
				if currentStamina < MAX_STAMINA then
					if currentStamina > 25 then
						currentStamina = currentStamina + IDLE_RECOVERY_RATE_HIGH_STAMINA * timeSlice
					else
						currentStamina = currentStamina + IDLE_RECOVERY_RATE_LOW_STAMINA * timeSlice
					end

					if currentStamina > 0 and areControlsToggledOff then
						setPlayerStaminaState(false)
					end
				else
					currentStamina = MAX_STAMINA
				end
			elseif actualSpeed >= WALK_SPEED_MIN_THRESHOLD and actualSpeed <= WALK_SPEED_MAX_THRESHOLD then
				if currentStamina > 0 then
					currentStamina = currentStamina - WALK_DRAIN_RATE * timeSlice
				else
					currentStamina = 0
					setPlayerStaminaState(true)
				end
			end
		end
	end
end)

addEventHandler("onClientKey", root, function(button, press)
	if press and currentStamina < 1 then
		if not (button == "t" or button == "b" or button == "z" or button == "lshift" or button == "tab") then
			cancelEvent()
		end
	end
end)

function setPlayerStaminaState(isTired)
	if isTired and not areControlsToggledOff then
		toggleAllControls(false)
		toggleControl("chatbox", true)
		setPedAnimation(localPlayer)
		setPedAnimation(localPlayer, "ped", "idle_tired", 1000, true, false, true)
		areControlsToggledOff = true
	elseif not isTired and areControlsToggledOff then
		toggleAllControls(true)
		toggleControl("chatbox", true)
		setPedAnimation(localPlayer)
		areControlsToggledOff = false
	end
end

function getStamina()
	return math.floor(currentStamina)
end
