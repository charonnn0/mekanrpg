Typography = {}
Typography.alias = "typography"
Typography.initialOptions = {
	position = {
		x = 0,
		y = 0,
	},
	size = {
		x = 0,
		y = 0,
	},

	text = "",
	alignX = "left",
	alignY = "top",
	color = WHITE,
	alpha = 1,
	scale = "h1",
	fontScale = 1,
	wrap = false,

	fontWeight = "regular",
	fillBackground = false,
}

Typography.render = function(options, store)
	local position = options.position or Typography.initialOptions.position
	local size = options.size or Typography.initialOptions.size

	local text = options.text or Typography.initialOptions.text
	local alignX = options.alignX or Typography.initialOptions.alignX
	local alignY = options.alignY or Typography.initialOptions.alignY
	local color = options.color or Typography.initialOptions.color
	local alpha = options.alpha or Typography.initialOptions.alpha
	local scale = options.scale or Typography.initialOptions.scale
	local fontScale = options.fontScale or 1
	local wrap = options.wrap or Typography.initialOptions.wrap

	local fontWeight = options.fontWeight or Typography.initialOptions.fontWeight
	local fillBackground = options.fillBackground or Typography.initialOptions.fillBackground

	local fonts = useFonts()
	local font = fonts[scale][fontWeight]

	local textWidth = dxGetTextWidth(text, 1, font)
	local textHeight = dxGetFontHeight(1, font)
	local hover = inArea(position.x, position.y, textWidth, textHeight)

	if fillBackground then
		for x = -1, 1 do
			for y = -1, 1 do
				dxDrawText(
					text,
					position.x + x,
					position.y + y,
					position.x + x + size.x,
					position.y + y + size.y,
					tocolor(0, 0, 0, alpha * 255),
					fontScale,
					font,
					alignX,
					alignY,
					wrap
				)
			end
		end
	end

	dxDrawText(
		text,
		position.x,
		position.y,
		position.x + size.x,
		position.y + size.y,
		rgba(color, alpha),
		fontScale,
		font,
		alignX,
		alignY,
		wrap,
		false,
		false,
		false,
		true
	)

	return {
		textWidth = textWidth,
		textHeight = textHeight,
	}
end

createComponent(Typography.alias, Typography.initialOptions, Typography.render)

function drawTypography(options)
	return components[Typography.alias].render(options)
end
