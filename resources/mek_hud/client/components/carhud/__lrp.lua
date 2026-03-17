local screenW, screenH = guiGetScreenSize()
local abx, aby = (screenW / 1366), (screenH / 768)

local circleShader = nil

local function hou_circle(x, y, width, height, color, angleStart, angleSweep, borderWidth)
	height = height or width
	color = color or tocolor(255, 255, 255)
	borderWidth = borderWidth or 1e9
	angleStart = angleStart or 0
	angleSweep = angleSweep or 360 - angleStart

	local angleEnd

	if angleSweep < 360 then
		angleEnd = math.fmod(angleStart + angleSweep, 360) + 0
	else
		angleStart = 0
		angleEnd = 360
	end

	x = x - width / 2
	y = y - height / 2

	if not circleShader then
		circleShader = dxCreateShader("public/images/lrp_speedo/olds/circle/hou_circle.fx")
	end

	if not circleShader then
		return
	end

	dxSetShaderValue(circleShader, "sCircleWidthInPixel", width)
	dxSetShaderValue(circleShader, "sCircleHeightInPixel", height)
	dxSetShaderValue(circleShader, "sBorderWidthInPixel", borderWidth)
	dxSetShaderValue(circleShader, "sAngleStart", math.rad(angleStart) - math.pi)
	dxSetShaderValue(circleShader, "sAngleEnd", math.rad(angleEnd) - math.pi)

	dxDrawImage(x, y, width, height, circleShader, 0, 0, 0, color)
end

local function getVehicleSpeed(vehicle)
	if isElement(vehicle) and isPedInVehicle(localPlayer) and getPedOccupiedVehicle(localPlayer) == vehicle then
		local vx, vy, vz = getElementVelocity(vehicle)
		return math.sqrt(vx * vx + vy * vy + vz * vz) * 165
	end

	return 0
end

createHudComponent("carhud/lrp_speedo", function()
	local occupiedVehicle = localPlayer:getOccupiedVehicle()
	if not occupiedVehicle then
		return
	end

	local kmh = math.floor(getVehicleSpeed(occupiedVehicle))
	local fuel = math.floor(occupiedVehicle:getData("fuel") or 50)
	local odometer = math.floor(occupiedVehicle:getData("odometer") or 0)

	dxDrawImage(
		abx * 1095,
		aby * 500,
		abx * 255,
		aby * 255,
		"public/images/lrp_speedo/arkaplan.png",
		0,
		0,
		0,
		tocolor(0, 0, 0, 150),
		false
	)

	dxDrawImage(
		abx * 1100,
		aby * 505,
		abx * 245,
		aby * 245,
		"public/images/lrp_speedo/arkaplan.png",
		0,
		0,
		0,
		tocolor(18, 18, 20, 255),
		false
	)

	dxDrawImage(
		abx * 1070,
		aby * 480,
		abx * 300,
		aby * 300,
		"public/images/lrp_speedo/arka.png",
		0,
		0,
		0,
		tocolor(255, 255, 255, 25),
		false
	)

	dxDrawText(
		"Kilometre",
		abx * 1735,
		aby * 610,
		abx * 710,
		aby * 680,
		tocolor(255, 255, 255, 150),
		1,
		exports.mek_huds:getFont("sf-medium", 9),
		"center",
		"center",
		false,
		false,
		false,
		false,
		false
	)

	dxDrawText(
		"Yağ Durumu %100",
		abx * 1730,
		aby * 400,
		abx * 710,
		aby * 680,
		tocolor(255, 255, 255, 150),
		1,
		exports.mek_huds:getFont("sf-medium", 9),
		"center",
		"center",
		false,
		false,
		false,
		false,
		false
	)

	dxDrawImage(
		abx * 1285,
		aby * 705,
		abx * 10,
		aby * 10,
		"public/images/lrp_speedo/olds/gasolina.png",
		0,
		0,
		0,
		tocolor(254, 161, 78),
		false
	)

	dxDrawImage(
		abx * 1148,
		aby * 705,
		abx * 15,
		aby * 15,
		"public/images/lrp_speedo/hiz.png",
		0,
		0,
		0,
		tocolor(200, 120, 255, 255),
		false
	)

	if kmh < 805 then
		dxDrawText(
			kmh,
			abx * 1735,
			aby * 500,
			abx * 710,
			aby * 680,
			tocolor(255, 255, 255, 255),
			1,
			exports.mek_huds:getFont("sertfont", 35),
			"center",
			"center",
			false,
			false,
			false,
			false,
			false
		)

		dxDrawText(
			odometer,
			abx * 1735,
			aby * 650,
			abx * 710,
			aby * 680,
			tocolor(255, 255, 255, 150),
			1,
			exports.mek_huds:getFont("sertfont", 25),
			"center",
			"center",
			false,
			false,
			false,
			false,
			false
		)

		hou_circle(
			abx * 1208,
			aby * 630,
			abx * 200,
			aby * 200,
			tocolor(200, 120, 255, 100),
			220,
			90,
			5
		)

		hou_circle(
			abx * 1208,
			aby * 630,
			abx * 200,
			aby * 200,
			tocolor(200, 120, 255),
			220,
			kmh / 2.6,
			5
		)

		hou_circle(
			abx * 1235,
			aby * 630,
			abx * 200,
			aby * 200,
			tocolor(254, 161, 78),
			50,
			90,
			5
		)
	end
end, {
	name = "Mekan Speedo",
})


