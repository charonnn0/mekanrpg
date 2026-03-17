Alert = {}
Alert.alias = "alert"
Alert.initialOptions = {
	position = {
		x = 0,
		y = 0,
	},
	size = {
		x = 0,
		y = 0,
	},

	radius = 4,
	padding = 0,

	header = "",
	description = "",

	variant = "soft",
	color = "gray",
}

Alert.render = function(options, store)
	local position = options.position or Alert.initialOptions.position
	local size = options.size or Alert.initialOptions.size

	local radius = options.radius or Alert.initialOptions.radius
	local padding = options.padding or Alert.initialOptions.padding

	local header = options.header or Alert.initialOptions.header
	local description = options.description or Alert.initialOptions.description

	local variant = options.variant or Alert.initialOptions.variant
	local color = options.color or Alert.initialOptions.color

	local fonts = useFonts()
	local containerColor = useAlertVariant(variant, color)

	drawRoundedRectangle({
		position = position,
		size = size,

		color = containerColor.background,
		alpha = 1,
		radius = radius,

		section = false,
	})

	dxDrawText(
		header,
		position.x + padding,
		position.y + padding,
		position.x + size.x,
		position.y + size.y,
		rgba(containerColor.textColor, 1),
		1,
		fonts.h6.bold,
		"left",
		"top",
		false,
		false,
		false,
		true
	)
	dxDrawText(
		description,
		position.x + padding,
		position.y + padding + 20,
		position.x + size.x,
		position.y + size.y,
		rgba(containerColor.textColor, 0.75),
		1,
		fonts.body.regular,
		"left",
		"top",
		false,
		false,
		false,
		true
	)
end

createComponent(Alert.alias, Alert.initialOptions, Alert.render)

function drawAlert(options)
	return components[Alert.alias].render(options)
end
