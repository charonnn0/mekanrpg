Camera = {}
Camera.options = {
	invertMouseLook = false,
	mouseSensitivity = 0.15,
}
Camera.mouseFrameDelay = 0
Camera.rotation = {
	x = 0,
	y = 0,
}
Camera.defaultAngle = {
	x = 0,
	y = 0,
	z = 1,
}
Camera.fov = 0
Camera.speed = 0
Camera.strafeSpeed = 0
Camera.renderTarget = {
	[Phone.enums.Rotation.Horizontal] = nil,
	[Phone.enums.Rotation.Vertical] = nil,
}
Camera.rightHandZ = 0
Camera.rightHandMinZ = -15
Camera.rightHandMaxZ = 15
Camera.loading = false
Camera.screenSource = {
	[Phone.enums.Rotation.Horizontal] = nil,
	[Phone.enums.Rotation.Vertical] = nil,
}

Camera.enums = {}
Camera.enums.Filters = {
	BLACK_WHITE = "black-white",
}

Camera.filters = {
	[Camera.enums.Filters.BLACK_WHITE] = exports.mek_assets:createShader("blackwhite.fx"),
}
Camera.activeFilter = nil

local PI = math.pi
local cameraGapSize = 65
local cameraShootButtonSize = 40
local lastClick = 0

Camera.moveCamera = function(_, _, absoluteX, absoluteY)
	if not Phone.visible then
		return
	end

	if Phone.currentApp ~= Phone.enums.Apps.Camera then
		return
	end

	if isCursorShowing() or isMTAWindowActive() then
		Camera.mouseFrameDelay = 5
		return
	elseif Camera.mouseFrameDelay > 0 then
		Camera.mouseFrameDelay = Camera.mouseFrameDelay - 1
		return
	end

	absoluteX = absoluteX - screenSize.x / 2
	absoluteY = absoluteY - screenSize.y / 2

	if Camera.options.invertMouseLook then
		absoluteY = -absoluteY
	end

	Camera.rotation.x = Camera.rotation.x + absoluteX * Camera.options.mouseSensitivity * 0.01745
	Camera.rotation.y = Camera.rotation.y - absoluteY * Camera.options.mouseSensitivity * 0.01745

	if Camera.rotation.x > PI then
		Camera.rotation.x = Camera.rotation.x - 2 * PI
	elseif Camera.rotation.x < -PI then
		Camera.rotation.x = Camera.rotation.x + 2 * PI
	end

	if Camera.rotation.y > PI then
		Camera.rotation.y = Camera.rotation.y - 2 * PI
	elseif Camera.rotation.y < -PI then
		Camera.rotation.y = Camera.rotation.y + 2 * PI
	end

	Camera.rotation.y = math.clamp(Camera.rotation.y, -PI / 4, PI / 2.05)
end
addEventHandler("onClientCursorMove", root, Camera.moveCamera)

Camera.renderMatrix = function()
	local cameraAngleX = Camera.rotation.x
	local cameraAngleY = Camera.rotation.y

	local freeModeAngleZ = math.sin(cameraAngleY)
	local freeModeAngleY = math.cos(cameraAngleY) * math.cos(cameraAngleX)
	local freeModeAngleX = math.cos(cameraAngleY) * math.sin(cameraAngleX)

	local cameraPositionX, cameraPositionY, cameraPositionZ = getPedBonePosition(localPlayer, 25)

	cameraPositionX = cameraPositionX - ((math.sin(math.rad(localPlayer.rotation.z))) * 0.05)
	cameraPositionY = cameraPositionY + ((math.cos(math.rad(localPlayer.rotation.z))) * 0.05)
	cameraPositionZ = cameraPositionZ + 0.3

	local cameraTargetX = cameraPositionX + freeModeAngleX * 100
	local cameraTargetY = cameraPositionY + freeModeAngleY * 100
	local cameraTargetZ = cameraPositionZ + freeModeAngleZ * 100

	local camAngleX = cameraPositionX - cameraTargetX
	local camAngleY = cameraPositionY - cameraTargetY
	local camAngleZ = 0

	local angleLength = math.sqrt(camAngleX * camAngleX + camAngleY * camAngleY + camAngleZ * camAngleZ)

	local camNormalizedAngleX = camAngleX / angleLength
	local camNormalizedAngleY = camAngleY / angleLength
	local camNormalizedAngleZ = 0

	local normalX = (camNormalizedAngleY * Camera.defaultAngle.y - camNormalizedAngleZ * Camera.defaultAngle.y)
	local normalY = (camNormalizedAngleZ * Camera.defaultAngle.z - camNormalizedAngleX * Camera.defaultAngle.z)
	local normalZ = (camNormalizedAngleX * Camera.defaultAngle.x - camNormalizedAngleY * Camera.defaultAngle.x)

	cameraPositionX = cameraPositionX + freeModeAngleX * Camera.speed
	cameraPositionY = cameraPositionY + freeModeAngleY * Camera.speed
	cameraPositionZ = cameraPositionZ + freeModeAngleZ * Camera.speed

	cameraPositionX = cameraPositionX + normalX * Camera.strafeSpeed
	cameraPositionY = cameraPositionY + normalY * Camera.strafeSpeed
	cameraPositionZ = cameraPositionZ + normalZ * Camera.strafeSpeed

	cameraTargetX = cameraPositionX + freeModeAngleX * 100
	cameraTargetY = cameraPositionY + freeModeAngleY * 100
	cameraTargetZ = cameraPositionZ + freeModeAngleZ * 100

	setCameraMatrix(
		cameraPositionX,
		cameraPositionY,
		cameraPositionZ,
		cameraTargetX,
		cameraTargetY,
		cameraTargetZ,
		0,
		Camera.fov
	)
	setPedLookAt(localPlayer, cameraPositionX, cameraPositionY, cameraPositionZ)
end

addEventHandler("onClientKey", root, function(button, state)
	if not Phone.visible then
		return
	end

	if Phone.currentApp ~= Phone.enums.Apps.Camera then
		return
	end

	if state then
		if button == "space" then
			cancelEvent()
		elseif button == "lshift" then
			cancelEvent()
		elseif button == "lctrl" or button == "rctrl" then
			cancelEvent()
		end
	end
end)

Camera.aspectRatio = 3 / 4

Phone.addApp(Phone.enums.Apps.Camera, function(position, size)
	local cameraRenderTargetSize = {
		x = size.x,
		y = (size.y - cameraGapSize * 2) * Camera.aspectRatio,
	}
	local cameraRenderTargetPosition = {
		x = position.x,
		y = position.y + cameraGapSize,
	}
	local filter = Camera.filters[Camera.activeFilter]

	if Phone.rotation == Phone.enums.Rotation.Vertical then
		cameraInnerSize = {
			x = screenSize.x / 2,
			y = screenSize.y,
		}
	else
		cameraInnerSize = {
			x = screenSize.x,
			y = screenSize.y / 2,
		}
		cameraRenderTargetSize = {
			x = size.x,
			y = size.y,
		}
	end

	if not Camera.screenSource[Phone.rotation] then
		Camera.screenSource[Phone.rotation] = dxCreateScreenSource(screenSize.x, screenSize.y)
	end

	if not Camera.renderTarget[Phone.rotation] then
		Camera.renderTarget[Phone.rotation] = dxCreateRenderTarget(cameraInnerSize.x, cameraInnerSize.y, true)
	end

	if getKeyState("mouse_wheel_up") and lastClick + 50 < getTickCount() then
		lastClick = getTickCount()
		Camera.rightHandZ = math.min(Camera.rightHandZ + 1, Camera.rightHandMaxZ)
	end

	if getKeyState("mouse_wheel_down") and lastClick + 50 < getTickCount() then
		lastClick = getTickCount()
		Camera.rightHandZ = math.max(Camera.rightHandZ - 1, Camera.rightHandMinZ)
	end

	Camera.renderMatrix()

	if not Camera.loading then
		dxUpdateScreenSource(Camera.screenSource[Phone.rotation])

		if Camera.activeFilter == Camera.enums.Filters.BLACK_WHITE then
			dxSetShaderValue(filter, "screenSource", Camera.screenSource[Phone.rotation])
		end

		dxSetRenderTarget(Camera.renderTarget[Phone.rotation], true)
		dxDrawImageSection(
			0,
			0,
			cameraInnerSize.x,
			cameraInnerSize.y,
			screenSize.x / 2 - cameraInnerSize.x / 2,
			0,
			cameraInnerSize.x,
			cameraInnerSize.y,
			Camera.activeFilter and filter or Camera.screenSource[Phone.rotation]
		)
		dxSetRenderTarget()
	end

	dxDrawImage(
		cameraRenderTargetPosition.x,
		position.y + size.y / 2 - cameraRenderTargetSize.y / 2,
		cameraRenderTargetSize.x,
		cameraRenderTargetSize.y,
		Camera.renderTarget[Phone.rotation]
	)

	if Phone.rotation == Phone.enums.Rotation.Horizontal then
		dxDrawRectangle(position.x, position.y, cameraGapSize, size.y, rgba(theme.BLACK, 0.85))

		dxDrawRectangle(position.x + size.x - cameraGapSize, position.y, cameraGapSize, size.y, rgba(theme.BLACK, 0.85))

		cameraButtonPosition = {
			x = position.x + size.x - cameraGapSize / 2 - cameraShootButtonSize / 2,
			y = position.y + size.y / 2 - cameraShootButtonSize / 2,
		}

		cameraFilterPosition = {
			x = cameraButtonPosition.x,
			y = position.y + cameraShootButtonSize + 10,
		}
	else
		dxDrawRectangle(position.x, position.y, size.x, cameraGapSize, rgba(theme.BLACK, 0.85))

		dxDrawRectangle(position.x, position.y + size.y - cameraGapSize, size.x, cameraGapSize, rgba(theme.BLACK, 0.85))

		cameraButtonPosition = {
			x = position.x + size.x / 2 - cameraShootButtonSize / 2,
			y = position.y + size.y - cameraGapSize / 2 - cameraShootButtonSize / 2 - 30,
		}

		cameraFilterPosition = {
			x = position.x + size.x - cameraShootButtonSize - 10,
			y = cameraButtonPosition.y,
		}
	end

	local changeRotationButton = drawButton({
		position = {
			x = position.x,
			y = position.y,
		},
		size = {
			x = cameraGapSize,
			y = cameraGapSize,
		},
		textProperties = {
			align = "center",
			color = theme.WHITE,
			font = fonts.icon,
			scale = 0.5,
		},

		variant = "plain",
		color = "gray",
		disabled = Camera.loading,

		text = "",
	})

	drawRoundedRectangle({
		position = cameraButtonPosition,
		size = {
			x = cameraShootButtonSize,
			y = cameraShootButtonSize,
		},
		radius = cameraShootButtonSize / 2,
		color = theme.WHITE,
		alpha = 1,
	})

	local cameraButton = drawButton({
		position = cameraButtonPosition,
		size = {
			x = cameraShootButtonSize,
			y = cameraShootButtonSize,
		},
		textProperties = {
			align = "center",
			color = theme.GRAY[900],
			font = fonts.icon,
			scale = 0.5,
		},

		variant = "plain",
		color = "blue",
		disabled = Camera.loading,

		text = "",
	})

	local cameraFilter = drawButton({
		position = cameraFilterPosition,
		size = {
			x = cameraShootButtonSize,
			y = cameraShootButtonSize,
		},
		textProperties = {
			align = "center",
			color = theme.GRAY[100],
			font = fonts.icon,
			scale = 0.5,
		},

		variant = "plain",
		color = "blue",
		disabled = Camera.loading,

		text = "",
	})

	if cameraFilter.pressed then
		if Camera.activeFilter then
			Camera.activeFilter = nil
		else
			Camera.activeFilter = Camera.enums.Filters.BLACK_WHITE
		end
	end

	if Camera.loading then
		dxDrawRectangle(position.x, position.y, size.x, size.y, rgba(theme.GRAY[900], 0.85))

		drawSpinner({
			position = {
				x = position.x + size.x / 2 - 32,
				y = position.y + size.y / 2 - 32,
			},
			size = 64,

			speed = 2,

			variant = "soft",
			color = "blue",

			label = "İşleniyor...",
		})
	end

	if changeRotationButton.pressed then
		Phone.rotation = Phone.rotation == Phone.enums.Rotation.Horizontal and Phone.enums.Rotation.Vertical
			or Phone.enums.Rotation.Horizontal
	end

	local isMouseMiddleButtonClicked = getKeyState("mouse3") and getTickCount() - lastClick > 100

	if (cameraButton.pressed or isMouseMiddleButtonClicked) and not Camera.loading then
		lastClick = getTickCount()
		local pixels = dxGetTexturePixels(Camera.renderTarget[Phone.rotation])
		local pixelsData = dxConvertPixels(pixels, "jpeg", 80)
		local base64Raw = encodeString("base64", pixelsData)
		Camera.loading = true

		uploadImageToAPI(base64Raw, function(row)
			Camera.loading = false
			if not row then
				return
			end
			triggerServerEvent("phone.gallery.add", localPlayer, Phone.number, {
				width = row.width,
				height = row.height,
				id = row.id,
			})
		end)
	end
end, "public/apps/camera.png", "Kamera")

addEvent("phone.gallery.onProcessComplete", true)
addEventHandler("phone.gallery.onProcessComplete", root, function()
	Camera.loading = false
end)
