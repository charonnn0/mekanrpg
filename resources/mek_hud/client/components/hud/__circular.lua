local CIRCULAR_SIZE = 48
CIRCULAR_CONTAINER_SIZE = {
	x = CIRCULAR_SIZE * 4 + (PADDING * 4),
	y = 32,
}

createHudComponent("hud/circular", function(store)
	local localStore = useStore("circular")
	local placement = localStore.get("direction") or "horizontal"
	local color = localStore.get("textColor") or "gray"

	local textColor = color == "gray" and theme.GRAY[300] or theme.GRAY[700]

	local circularPosition = {
		x = placement == "horizontal" and screenSize.x - (PADDING * 2) - CIRCULAR_SIZE
			or screenSize.x - CIRCULAR_SIZE - PADDING * 2,
		y = PADDING * 2,
	}

	for key, data in pairs(CIRCLE_VALUES) do
		local value, text = getHudDataValue(store, key)

		drawRoundedRectangle({
			position = circularPosition,
			size = {
				x = CIRCULAR_SIZE,
				y = CIRCULAR_SIZE,
			},

			color = theme.GRAY[900],
			alpha = 0.9,
			radius = CIRCULAR_SIZE / 2,
			section = false,
		})

		drawRoundedRectangle({
			position = {
				x = circularPosition.x + 1,
				y = circularPosition.y + 1,
			},
			size = {
				x = CIRCULAR_SIZE - 2,
				y = CIRCULAR_SIZE - 2,
			},

			color = data.color,
			alpha = 0.3,
			radius = CIRCULAR_SIZE / 2,
			section = false,
		})

		drawRoundedRectangle({
			position = {
				x = circularPosition.x + 1,
				y = circularPosition.y + 1,
			},
			size = {
				x = CIRCULAR_SIZE - 2,
				y = CIRCULAR_SIZE - 2,
			},

			color = data.color,
			alpha = 0.5,
			radius = CIRCULAR_SIZE / 2,
			section = {
				percentage = value,
				direction = "top",
			},
		})

		dxDrawText(
			data.icon,
			circularPosition.x,
			circularPosition.y,
			circularPosition.x + CIRCULAR_SIZE,
			circularPosition.y + CIRCULAR_SIZE,
			rgba(data.iconColor, 1),
			0.5,
			fonts.icon,
			"center",
			"center",
			true,
			true
		)
		dxDrawText(
			text,
			circularPosition.x,
			circularPosition.y + CIRCULAR_SIZE,
			circularPosition.x + CIRCULAR_SIZE,
			circularPosition.y + CIRCULAR_SIZE + 20,
			rgba(textColor, 1),
			1,
			fonts.body.regular,
			"center",
			"bottom",
			true,
			true
		)

		if placement == "vertical" then
			circularPosition.y = circularPosition.y + (PADDING * 3) + CIRCULAR_SIZE
		else
			circularPosition.x = circularPosition.x - ((PADDING * 1.2) + CIRCULAR_SIZE)
		end
	end

	local cardPosition = {
		x = screenSize.x - (PADDING * 2) - CIRCULAR_CONTAINER_SIZE.x,
		y = screenSize.y - (PADDING * 2) - CIRCULAR_CONTAINER_SIZE.y,
	}

	drawRoundedRectangle({
		position = cardPosition,
		size = CIRCULAR_CONTAINER_SIZE,

		color = theme.GRAY[900],

		radius = 15,
		alpha = 0.9,

		section = false,
	})

	cardPosition.x = cardPosition.x + 20

	for index, data in ipairs(INFORMATION_CARD_ITEMS) do
		local text = getHudCardItemValue(index) or ""
		local textWidth = dxGetTextWidth(text, 1, fonts.body.regular)

		if data.icon ~= "" then
			dxDrawText(
				data.icon,
				cardPosition.x,
				cardPosition.y,
				cardPosition.x + CIRCULAR_CONTAINER_SIZE.x,
				cardPosition.y + CIRCULAR_CONTAINER_SIZE.y,
				rgba(theme.GRAY[300], 1),
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
				rgba(theme.GRAY[300], 1),
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
			rgba(theme.GRAY[300], 1),
			1,
			fonts.body.regular,
			"left",
			"center",
			true,
			true
		)

		cardPosition.x = cardPosition.x + textWidth + (PADDING * 5)
	end
end, {
	name = "Circular",

	options = {
		{
			key = "direction",
			text = "Yön",
			default = 1,
			options = {
				{ value = "horizontal", text = "Yatay" },
				{ value = "vertical", text = "Dikey" },
			},
		},
		{
			key = "textColor",
			text = "Yazı Renkleri",
			default = 1,
			options = {
				{ value = "gray", text = "Beyaz" },
				{ value = "black", text = "Siyah" },
			},
		},
	},
})
