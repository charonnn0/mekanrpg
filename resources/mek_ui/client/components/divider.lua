Divider = {}
Divider.alias = "divider"
Divider.initialOptions = {
	position = {
		x = 0,
		y = 0,
	},
	size = {
		x = 0,
		y = 0,
	},
	text = "",
}

Divider.render = function(options)
	local position = options.position or Divider.initialOptions.position
	local size = options.size or Divider.initialOptions.size
	local text = options.text or Divider.initialOptions.text

	local fonts = useFonts()

	if text ~= "" then
		local textWidth = dxGetTextWidth(text, 1, fonts.h6.thin) + 20
		local textPosition = {
			x = position.x + size.x / 2 - textWidth / 2,
			y = position.y + size.y / 2 - 10,
		}
		dxDrawLine(
			position.x,
			position.y + size.y / 2,
			textPosition.x - 10,
			position.y + size.y / 2,
			rgba(GRAY[900]),
			1
		)
		drawRoundedRectangle({
			position = {
				x = textPosition.x - 5,
				y = textPosition.y,
			},
			size = {
				x = textWidth + 10,
				y = 20,
			},
			color = GRAY[900],
			radius = 5,
		})
		dxDrawText(
			text,
			textPosition.x,
			textPosition.y,
			textPosition.x + textWidth,
			textPosition.y + 20,
			rgba(GRAY[500]),
			1,
			fonts.body.thin,
			"center",
			"center"
		)
		dxDrawLine(
			textPosition.x + textWidth + 10,
			position.y + size.y / 2,
			position.x + size.x,
			position.y + size.y / 2,
			rgba(GRAY[900]),
			1
		)
	else
		dxDrawLine(
			position.x,
			position.y + size.y / 2,
			position.x + size.x,
			position.y + size.y / 2,
			rgba(GRAY[500]),
			1
		)
	end
	return {}
end

createComponent(Divider.alias, Divider.initialOptions, Divider.render)

function drawDivider(options)
	return components[Divider.alias].render(options)
end
