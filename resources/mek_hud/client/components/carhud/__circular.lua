local vehicleItems = {
	{ icon = "", prefix = "" },
	{ icon = "", prefix = "" },
	{ icon = "", prefix = "KM" },
}

createHudComponent("carhud/circular", function()
	local occupiedVehicle = localPlayer:getOccupiedVehicle()
	if not occupiedVehicle then
		return
	end

	local engineState = getVehicleEngineState(occupiedVehicle)
	local speed = math.floor(exports.mek_global:getVehicleVelocity(occupiedVehicle) or 0)
	local fuel = math.floor(occupiedVehicle:getData("fuel") or 0)
	local odometer = math.floor(occupiedVehicle:getData("odometer") or 0)

	local activeHud = getCurrentRenderingHud("hud")

	local cardPosition = {
		x = screenSize.x - (PADDING * 2) - CIRCULAR_CONTAINER_SIZE.x,
		y = screenSize.y - (PADDING * 2) - CIRCULAR_CONTAINER_SIZE.y,
	}

	if activeHud == "circular" then
		cardPosition.y = cardPosition.y - CIRCULAR_CONTAINER_SIZE.y - 3
	end

	drawRoundedRectangle({
		position = cardPosition,
		size = CIRCULAR_CONTAINER_SIZE,

		color = theme.GRAY[900],

		radius = 15,
		alpha = 0.9,

		section = false,
	})

	if occupiedVehicle:getEngineState() then
		local gear = getVehicleCurrentGear(occupiedVehicle)
		drawRoundedRectangle({
			position = cardPosition,
			size = CIRCULAR_CONTAINER_SIZE,

			color = theme.GRAY[800],

			radius = 15,
			alpha = 0.9,

			section = {
				percentage = (getVehicleRPM(occupiedVehicle, gear, speed) / MAX_RPM) * 100,
				direction = "left",
			},
		})
		if speed == 0 then
			gear = "N"
		elseif isVehicleReversing(occupiedVehicle, gear) then
			gear = "R"
		end

		dxDrawText(
			gear,
			cardPosition.x - 10,
			cardPosition.y,
			CIRCULAR_CONTAINER_SIZE.x + cardPosition.x - 10,
			CIRCULAR_CONTAINER_SIZE.y + cardPosition.y,
			rgba(theme.GRAY[700]),
			1,
			fonts.h6.bold,
			"right",
			"center"
		)
	end

	cardPosition.x = cardPosition.x + 20

	for index, data in ipairs(vehicleItems) do
		local text = ""

		if index == 1 then
			text = string.format("%03d", speed)
		elseif index == 2 then
			text = fuel
		elseif index == 3 then
			text = odometer
		end

		local textWidth = dxGetTextWidth(text, 1, fonts.body.regular)

		if data.icon ~= "" then
			dxDrawText(
				data.icon,
				cardPosition.x,
				cardPosition.y,
				cardPosition.x + CIRCULAR_CONTAINER_SIZE.x,
				cardPosition.y + CIRCULAR_CONTAINER_SIZE.y,
				rgba(engineState and getServerColor(2) or theme.GRAY[500]),
				0.5,
				fonts.icon,
				"left",
				"center",
				true,
				true
			)
		else
			dxDrawText(
				data.prefix,
				cardPosition.x,
				cardPosition.y,
				cardPosition.x + CIRCULAR_CONTAINER_SIZE.x,
				cardPosition.y + CIRCULAR_CONTAINER_SIZE.y,
				rgba(engineState and getServerColor(2) or theme.GRAY[500]),
				1,
				fonts.body.bold,
				"left",
				"center",
				true,
				true
			)
		end

		dxDrawText(
			text,
			cardPosition.x + PADDING * 2.5,
			cardPosition.y,
			cardPosition.x + CIRCULAR_CONTAINER_SIZE.x,
			cardPosition.y + CIRCULAR_CONTAINER_SIZE.y,
			rgba(engineState and getServerColor(2) or theme.GRAY[500]),
			1,
			fonts.body.regular,
			"left",
			"center",
			true,
			true
		)

		cardPosition.x = cardPosition.x + textWidth + (PADDING * 4)
	end
end, {
	name = "Circular",
})
