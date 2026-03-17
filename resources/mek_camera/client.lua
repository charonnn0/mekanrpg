local cameraSystem = {
	isMoving = false,
	cameraObject1 = nil,
	cameraObject2 = nil,
}

function removeCameraHandler()
	if cameraSystem.isMoving then
		cameraSystem.isMoving = false
		killTimer(timerRemoveCamera)
		killTimer(timerDestroyObject1)
		killTimer(timerDestroyObject2)
		removeEventHandler("onClientRender", root, updateCameraPosition)
	end
end

function updateCameraPosition()
	if cameraSystem.isMoving then
		local posX1, posY1, posZ1 = getElementPosition(cameraSystem.cameraObject1)
		local posX2, posY2, posZ2 = getElementPosition(cameraSystem.cameraObject2)
		setCameraMatrix(posX1, posY1, posZ1, posX2, posY2, posZ2)
	else
		removeEventHandler("onClientRender", root, updateCameraPosition)
	end
end

function smoothMoveCamera(
	startX1,
	startY1,
	startZ1,
	targetX1,
	targetY1,
	targetZ1,
	startX2,
	startY2,
	startZ2,
	targetX2,
	targetY2,
	targetZ2,
	duration,
	isLinear
)
	if cameraSystem.isMoving then
		return false
	end

	isLinear = isLinear or false

	local easingType = isLinear and "Linear" or "InOutQuad"

	cameraSystem.cameraObject1 = createObject(1337, startX1, startY1, startZ1)
	cameraSystem.cameraObject2 = createObject(1337, targetX1, targetY1, targetZ1)
	setElementCollisionsEnabled(cameraSystem.cameraObject1, false)
	setElementCollisionsEnabled(cameraSystem.cameraObject2, false)
	setElementAlpha(cameraSystem.cameraObject1, 0)
	setElementAlpha(cameraSystem.cameraObject2, 0)
	setObjectScale(cameraSystem.cameraObject1, 0.01)
	setObjectScale(cameraSystem.cameraObject2, 0.01)
	moveObject(cameraSystem.cameraObject1, duration, startX2, startY2, startZ2, 0, 0, 0, easingType)
	moveObject(cameraSystem.cameraObject2, duration, targetX2, targetY2, targetZ2, 0, 0, 0, easingType)

	cameraSystem.isMoving = true
	timerRemoveCamera = setTimer(removeCameraHandler, duration, 1)
	timerDestroyObject1 = setTimer(destroyElement, duration, 1, cameraSystem.cameraObject1)
	timerDestroyObject2 = setTimer(destroyElement, duration, 1, cameraSystem.cameraObject2)
	addEventHandler("onClientRender", root, updateCameraPosition)

	return true
end

addCommandHandler("camera", function()
	local x, y, z, lx, ly, lz = getCameraMatrix()
	outputChatBox(x .. ", " .. y .. ", " .. z .. ", " .. lx .. ", " .. ly .. ", " .. lz)
end)
