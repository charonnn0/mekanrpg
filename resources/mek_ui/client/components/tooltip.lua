Tooltip = {}
Tooltip.alias = "tooltip"
Tooltip.initialOptions = {
	position = {
		x = 0,
		y = 0,
	},
	size = {
		x = 0,
		y = 0,
	},

	radius = 4,
	text = "",
	description = "",

	alpha = 1,

	align = "center",
	alignY = "top",
	hover = false,
}

Tooltip.render = function(options, store)
	local position = options.position or Tooltip.initialOptions.position
	local size = options.size or Tooltip.initialOptions.size

	local radius = options.radius or Tooltip.initialOptions.radius
	local text = options.text or Tooltip.initialOptions.text
	local description = options.description or Tooltip.initialOptions.description

	local alpha = options.alpha or Tooltip.initialOptions.alpha

	local align = options.align or Tooltip.initialOptions.align
	local alignYPosition = options.alignY or Tooltip.initialOptions.alignY

	local fonts = useFonts()

	local hover = options.hover or inArea(position.x, position.y, size.x, size.y)
	if hover then
		local textWidth = dxGetTextWidth(text, 1, fonts.body.bold)
		local descriptionWidth = dxGetTextWidth(description, 1, fonts.body.regular)

		if descriptionWidth > textWidth then
			textWidth = descriptionWidth
		end

		local tooltipSize = {
			x = textWidth + 20,
			y = description ~= "" and 40 or 25,
		}

		local alignX = 0
		local alignY = 0

		if align == "center" then
			alignX = position.x + size.x / 2 - tooltipSize.x / 2
		elseif align == "right" then
			alignX = position.x + size.x - tooltipSize.x
		elseif align == "left" then
			alignX = position.x
		end

		if alignYPosition == "center" then
			alignY = position.y + size.y / 2 - tooltipSize.y / 2
		elseif alignYPosition == "top" then
			alignY = position.y - tooltipSize.y
		elseif alignYPosition == "bottom" then
			alignY = position.y + size.y
		end

		local tooltipPosition = {
			x = alignX,
			y = alignY,
		}

		drawRoundedRectangle({
			position = tooltipPosition,
			size = tooltipSize,

			color = GRAY[800],
			alpha = alpha,
			radius = radius,
			postGUI = true,
		})
		dxDrawText(
			text,
			tooltipPosition.x,
			tooltipPosition.y + 5,
			tooltipPosition.x + tooltipSize.x,
			tooltipPosition.y + tooltipSize.y + 5,
			rgba(WHITE, alpha),
			1,
			fonts.body.light,
			"center",
			"top",
			true,
			true,
			true,
			true
		)
		dxDrawText(
			description,
			tooltipPosition.x,
			tooltipPosition.y - 5,
			tooltipPosition.x + tooltipSize.x,
			tooltipPosition.y + tooltipSize.y - 5,
			rgba(GRAY[200], alpha),
			1,
			fonts.caption.light,
			"center",
			"bottom",
			true,
			true,
			true,
			true
		)
	end
end

createComponent(Tooltip.alias, Tooltip.initialOptions, Tooltip.render)

function drawTooltip(options)
	return components[Tooltip.alias].render(options)
end
