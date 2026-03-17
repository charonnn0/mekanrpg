local speed = 0
local strafespeed = 0
local rotX, rotY = 0, 0
local velocityX, velocityY, velocityZ
local startX, startY, startZ

local options = {
	invertMouseLook = false,
	normalMaxSpeed = 2,
	slowMaxSpeed = 0.2,
	fastMaxSpeed = 12,
	smoothMovement = true,
	acceleration = 0.3,
	decceleration = 0.15,
	mouseSensitivity = 0.1,
	maxYAngle = 188,
	key_fastMove = "lshift",
	key_slowMove = "lalt",
	key_forward = "w",
	key_backward = "s",
	key_left = "a",
	key_right = "d",
}

local mouseFrameDelay = 0

local getKeyState = getKeyState
do
	local mta_getKeyState = getKeyState
	function getKeyState(key)
		if isMTAWindowActive() then
			return false
		else
			return mta_getKeyState(key)
		end
	end
end

local function freecamFrame()
	local cameraAngleX = rotX
	local cameraAngleY = rotY

	local freeModeAngleZ = math.sin(cameraAngleY)
	local freeModeAngleY = math.cos(cameraAngleY) * math.cos(cameraAngleX)
	local freeModeAngleX = math.cos(cameraAngleY) * math.sin(cameraAngleX)
	local camPosX, camPosY, camPosZ = getCameraMatrix()

	local camTargetX = camPosX + freeModeAngleX * 100
	local camTargetY = camPosY + freeModeAngleY * 100
	local camTargetZ = camPosZ + freeModeAngleZ * 100

	local mspeed = options.normalMaxSpeed
	if getKeyState(options.key_fastMove) then
		mspeed = options.fastMaxSpeed
	elseif getKeyState(options.key_slowMove) then
		mspeed = options.slowMaxSpeed
	end

	if options.smoothMovement then
		local acceleration = options.acceleration
		local decceleration = options.decceleration

		local speedKeyPressed = false
		if getKeyState(options.key_forward) then
			speed = speed + acceleration
			speedKeyPressed = true
		end
		if getKeyState(options.key_backward) then
			speed = speed - acceleration
			speedKeyPressed = true
		end

		local strafeSpeedKeyPressed = false
		if getKeyState(options.key_right) then
			if strafespeed > 0 then
				strafespeed = 0
			end
			strafespeed = strafespeed - acceleration / 2
			strafeSpeedKeyPressed = true
		end
		if getKeyState(options.key_left) then
			if strafespeed < 0 then
				strafespeed = 0
			end
			strafespeed = strafespeed + acceleration / 2
			strafeSpeedKeyPressed = true
		end

		if speedKeyPressed ~= true then
			if speed > 0 then
				speed = speed - decceleration
			elseif speed < 0 then
				speed = speed + decceleration
			end
		end

		if strafeSpeedKeyPressed ~= true then
			if strafespeed > 0 then
				strafespeed = strafespeed - decceleration
			elseif strafespeed < 0 then
				strafespeed = strafespeed + decceleration
			end
		end

		if speed > -decceleration and speed < decceleration then
			speed = 0
		elseif speed > mspeed then
			speed = mspeed
		elseif speed < -mspeed then
			speed = -mspeed
		end

		if strafespeed > -(acceleration / 2) and strafespeed < (acceleration / 2) then
			strafespeed = 0
		elseif strafespeed > mspeed then
			strafespeed = mspeed
		elseif strafespeed < -mspeed then
			strafespeed = -mspeed
		end
	else
		speed = 0
		strafespeed = 0
		if getKeyState(options.key_forward) then
			speed = mspeed
		end
		if getKeyState(options.key_backward) then
			speed = -mspeed
		end
		if getKeyState(options.key_left) then
			strafespeed = mspeed
		end
		if getKeyState(options.key_right) then
			strafespeed = -mspeed
		end
	end

	local camAngleX = camPosX - camTargetX
	local camAngleY = camPosY - camTargetY
	local camAngleZ = 0

	local angleLength = math.sqrt(camAngleX * camAngleX + camAngleY * camAngleY + camAngleZ * camAngleZ)

	local camNormalizedAngleX = camAngleX / angleLength
	local camNormalizedAngleY = camAngleY / angleLength
	local camNormalizedAngleZ = 0

	local normalAngleX = 0
	local normalAngleY = 0
	local normalAngleZ = 1

	local normalX = (camNormalizedAngleY * normalAngleZ - camNormalizedAngleZ * normalAngleY)
	local normalY = (camNormalizedAngleZ * normalAngleX - camNormalizedAngleX * normalAngleZ)
	local normalZ = (camNormalizedAngleX * normalAngleY - camNormalizedAngleY * normalAngleX)

	camPosX = camPosX + freeModeAngleX * speed
	camPosY = camPosY + freeModeAngleY * speed
	camPosZ = camPosZ + freeModeAngleZ * speed

	camPosX = camPosX + normalX * strafespeed
	camPosY = camPosY + normalY * strafespeed
	camPosZ = camPosZ + normalZ * strafespeed

	velocityX = (freeModeAngleX * speed) + (normalX * strafespeed)
	velocityY = (freeModeAngleY * speed) + (normalY * strafespeed)
	velocityZ = (freeModeAngleZ * speed) + (normalZ * strafespeed)

	camTargetX = camPosX + freeModeAngleX * 100
	camTargetY = camPosY + freeModeAngleY * 100
	camTargetZ = camPosZ + freeModeAngleZ * 100

	setCameraMatrix(camPosX, camPosY, camPosZ, camTargetX, camTargetY, camTargetZ)
	setElementPosition(localPlayer, camPosX, camPosY, camPosZ)
end

local function freecamMouse(cX, cY, aX, aY)
	if isCursorShowing() or isMTAWindowActive() then
		mouseFrameDelay = 5
		return
	elseif mouseFrameDelay > 0 then
		mouseFrameDelay = mouseFrameDelay - 1
		return
	end

	local width, height = guiGetScreenSize()
	aX = aX - width / 2
	aY = aY - height / 2

	if options.invertMouseLook then
		aY = -aY
	end

	rotX = rotX + aX * options.mouseSensitivity * 0.01745
	rotY = rotY - aY * options.mouseSensitivity * 0.01745

	local PI = math.pi
	if rotX > PI then
		rotX = rotX - 2 * PI
	elseif rotX < -PI then
		rotX = rotX + 2 * PI
	end

	if rotY > PI then
		rotY = rotY - 2 * PI
	elseif rotY < -PI then
		rotY = rotY + 2 * PI
	end

	if rotY < -PI / 2.05 then
		rotY = -PI / 2.05
	elseif rotY > PI / 2.05 then
		rotY = PI / 2.05
	end
end

function getFreecamVelocity()
	return velocityX, velocityY, velocityZ
end

function setFreecamEnabled(x, y, z)
	startX, startY, startZ = getElementPosition(localPlayer)
	addEventHandler("onClientRender", root, freecamFrame)
	addEventHandler("onClientCursorMove", root, freecamMouse)
	setElementData(localPlayer, "freecam_state", true, false)
	setPedWeaponSlot(localPlayer, 0)
	toggleAllControls(false, true, false)
	return true
end

function setFreecamDisabled()
	velocityX, velocityY, velocityZ = 0, 0, 0
	speed = 0
	strafespeed = 0
	removeEventHandler("onClientRender", root, freecamFrame)
	removeEventHandler("onClientCursorMove", root, freecamMouse)
	setElementData(localPlayer, "freecam_state", false, false)
	setCameraTarget(localPlayer, localPlayer)
	toggleAllControls(true)
	triggerEvent("onClientPlayerWeaponCheck", localPlayer)
	return true
end

function isFreecamEnabled()
	return getElementData(localPlayer, "freecam_state")
end

function getFreecamOption(theOption, value)
	return options[theOption]
end

function setFreecamOption(theOption, value)
	if options[theOption] ~= nil then
		options[theOption] = value
		return true
	else
		return false
	end
end

addEvent("doSetFreecamEnabled", true)
addEventHandler("doSetFreecamEnabled", root, setFreecamEnabled)

addEvent("doSetFreecamDisabled", true)
addEventHandler("doSetFreecamDisabled", root, setFreecamDisabled)

addEvent("doSetFreecamOption", true)
addEventHandler("doSetFreecamOption", root, setFreecamOption)

function onStart()
	for i, player in pairs(getElementsByType("player")) do
		if getElementData(player, "freecam_state") then
			setElementCollisionsEnabled(player, false)
		end
	end
end
addEventHandler("onClientResourceStart", resourceRoot, onStart)

function onDataChange(name)
	if getElementType(source) == "player" and name == "freecam_state" then
		setElementCollisionsEnabled(source, not getElementData(source, "freecam_state"))
	end
end
addEventHandler("onClientElementDataChange", root, onDataChange)

function toggleFreecam()
	if not isEnabled(localPlayer) then
		if getElementData(localPlayer, "logged") and exports.mek_integration:isPlayerTrialAdmin(localPlayer) then
			setElementAlpha(localPlayer, 0)
			setElementFrozen(localPlayer, true)
			setFreecamEnabled(x, y, z)
			if getElementData(localPlayer, "reconx") then
				exports.mek_admin:toggleRecon(false)
			end
			triggerServerEvent("freecam.asyncActivateFreecam", localPlayer)
		end
	elseif isEnabled(localPlayer) then
		setElementAlpha(localPlayer, 255)
		setElementFrozen(localPlayer, false)
		setFreecamDisabled()
		triggerServerEvent("freecam.asyncDeactivateFreecam", localPlayer)
	end
end
addCommandHandler("freecam", toggleFreecam, false, false)



local showMessage = false
local messageText = ""

function showBigRedMessage(msg)
    messageText = msg
    showMessage = true
end

function hideBigRedMessage()
    showMessage = false
end

addEventHandler("onClientRender", root, function()
    if showMessage then
        local screenW, screenH = guiGetScreenSize()
        dxDrawText(
            messageText, 
            0, 0, screenW, screenH, 
            tocolor(255, 0, 0, 255),
            5,
            "default-bold",
            "center", "center", 
            false, false, true
        )
    end
end)

addEvent("showRedMessageForAll", true)
addEventHandler("showRedMessageForAll", root, function(msg)
    showBigRedMessage(msg)
end)