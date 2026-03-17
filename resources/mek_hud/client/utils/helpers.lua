MAX_RPM = 9500

BULLET_WEAPONS = {
	[22] = true,
	[23] = true,
	[24] = true,
	[25] = true,
	[26] = true,
	[27] = true,
	[28] = true,
	[29] = true,
	[32] = true,
	[30] = true,
	[31] = true,
	[33] = true,
	[34] = true,
	[35] = true,
	[36] = true,
	[37] = true,
	[38] = true,
	[16] = true,
	[17] = true,
	[18] = true,
	[39] = true,
	[41] = true,
	[42] = true,
	[43] = true,
}

function removeHEXFromString(str)
	return string.gsub(str, "#%x%x%x%x%x%x", "")
end

function drawTextWithShadow(
	text,
	x,
	y,
	width,
	height,
	color,
	size,
	font,
	alignX,
	alignY,
	clip,
	wordBreak,
	postGUI,
	colorCoded,
	subPixelPositioning,
	fRotation,
	fRotationCenterX,
	fRotationCenterY,
	fLineSpacing
)
	dxDrawText(
		text,
		x + 1,
		y + 1,
		width,
		height,
		tocolor(0, 0, 0, 255),
		size,
		font,
		alignX,
		alignY,
		clip,
		wordBreak,
		postGUI,
		colorCoded,
		subPixelPositioning,
		fRotation,
		fRotationCenterX,
		fRotationCenterY,
		fLineSpacing
	)
	dxDrawText(
		text,
		x,
		y,
		width,
		height,
		color,
		size,
		font,
		alignX,
		alignY,
		clip,
		wordBreak,
		postGUI,
		colorCoded,
		subPixelPositioning,
		fRotation,
		fRotationCenterX,
		fRotationCenterY,
		fLineSpacing
	)
end

function dxDrawBorderText(
	message,
	left,
	top,
	width,
	height,
	color,
	scale,
	font,
	alignX,
	alignY,
	clip,
	wordBreak,
	postGUI
)
	color, scale, font, alignX, alignY, clip, wordBreak, postGUI =
		color or tocolor(255, 255, 255),
		scale or 1,
		font or "default",
		alignX or "left",
		alignY or "top",
		clip or false,
		wordBreak or false,
		postGUI or false
	dxDrawText(
		message:gsub("#%x%x%x%x%x%x", ""),
		left + 1,
		top + 1,
		width + 1,
		height + 1,
		rgba(theme.BLACK),
		scale,
		font,
		alignX,
		alignY,
		clip,
		wordBreak,
		postGUI
	)
	dxDrawText(
		message:gsub("#%x%x%x%x%x%x", ""),
		left + 1,
		top - 1,
		width + 1,
		height - 1,
		rgba(theme.BLACK),
		scale,
		font,
		alignX,
		alignY,
		clip,
		wordBreak,
		postGUI
	)
	dxDrawText(
		message:gsub("#%x%x%x%x%x%x", ""),
		left - 1,
		top + 1,
		width - 1,
		height + 1,
		rgba(theme.BLACK),
		scale,
		font,
		alignX,
		alignY,
		clip,
		wordBreak,
		postGUI
	)
	dxDrawText(
		message:gsub("#%x%x%x%x%x%x", ""),
		left - 1,
		top - 1,
		width - 1,
		height - 1,
		rgba(theme.BLACK),
		scale,
		font,
		alignX,
		alignY,
		clip,
		wordBreak,
		postGUI
	)
	dxDrawText(message, left, top, width, height, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, true)
end

function getVehicleRPM(vehicle, gear, speed)
	local vehicleRPM = 0
	if vehicle then
		if getVehicleEngineState(vehicle) == true then
			if getVehicleCurrentGear(vehicle) > 0 then
				vehicleRPM = math.floor(((speed / gear) * 160) + 0.5)
				if vehicleRPM < 650 then
					vehicleRPM = math.random(650, 750)
				elseif vehicleRPM >= 9000 then
					vehicleRPM = math.random(9000, MAX_RPM)
				end
			else
				vehicleRPM = math.floor((speed * 160) + 0.5)
				if vehicleRPM < 650 then
					vehicleRPM = math.random(650, 750)
				elseif vehicleRPM >= 9000 then
					vehicleRPM = math.random(9000, MAX_RPM)
				end
			end
		else
			vehicleRPM = 0
		end

		return tonumber(vehicleRPM)
	else
		return 0
	end
end

function isVehicleReversing(theVehicle, gear)
	local getMatrix = getElementMatrix(theVehicle)
	local getVelocity = Vector3(getElementVelocity(theVehicle))
	local getVectorDirection = (getVelocity.x * getMatrix[2][1])
		+ (getVelocity.y * getMatrix[2][2])
		+ (getVelocity.z * getMatrix[2][3])
	if gear == 0 and getVectorDirection < 0 then
		return true
	end
	return false
end
