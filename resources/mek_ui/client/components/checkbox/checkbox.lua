Checkbox = {}
Checkbox.alias = "checkbox"
Checkbox.initialOptions = {
	position = {
		x = 0,
		y = 0,
	},
	size = 24,

	name = "",

	text = "",
	helperText = {
		text = "",
		color = GRAY[200],
	},

	variant = DEFAULT_VARIANT,
	color = DEFAULT_COLOR,
	alpha = 1,

	checked = false,
	disabled = false,
}

-- FontAwesome check icon unicode: U+F00C
local CHECK_ICON = utf8.char(0xF00C)

Checkbox.render = function(options, store)
	local position = options.position or Checkbox.initialOptions.position
	local size = options.size or Checkbox.initialOptions.size

	local name = options.name or Checkbox.initialOptions.name

	local text = options.text or Checkbox.initialOptions.text
	local helperText = options.helperText or Checkbox.initialOptions.helperText

	local variant = options.variant or Checkbox.initialOptions.variant
	local color = options.color or Checkbox.initialOptions.color
	local alpha = options.alpha or Checkbox.initialOptions.alpha

	local disabled = options.disabled or Checkbox.initialOptions.disabled
	local defaultChecked = options.checked or Checkbox.initialOptions.checked

	local fonts = useFonts()

	local checkboxStore = store.get(name)

	local checkboxColor = useCheckboxVariant(variant, color)

	if not checkboxStore then
		store.set(name, {
			checked = defaultChecked,
			textWidth = dxGetTextWidth(text, 1, fonts.caption.regular),
		})

		checkboxStore = store.get(name)
	end

	local checked = checkboxStore.checked
	local textWidth = checkboxStore.textWidth or 0

	local hover = inArea(position.x, position.y, size + textWidth, size)
	local pressed = false

	checkboxColor.background = hover and checkboxColor.hover or checkboxColor.background

	if variant == AVAILABLE_VARIANTS.OUTLINED then
		drawRoundedRectangle({
			position = position,
			size = {
				x = size,
				y = size,
			},
			
			color = checkboxColor.textColor,
			alpha = alpha,
			radius = 5,
		})
		drawRoundedRectangle({
			position = {
				x = position.x + 1,
				y = position.y + 1,
			},
			size = {
				x = size - 2,
				y = size - 2,
			},
			
			color = checkboxColor.background,
			alpha = alpha,
			radius = 4,
		})
	else
		drawRoundedRectangle({
			position = position,
			size = {
				x = size,
				y = size,
			},
			
			color = checkboxColor.background,
			alpha = alpha,
			radius = 5,
		})
	end

	if checked then
		dxDrawText(
			CHECK_ICON,
			position.x,
			position.y,
			position.x + size,
			position.y + size,
			rgba(checkboxColor.textColor, alpha),
			0.4,
			fonts.icon,
			"center",
			"center"
		)
	end

	dxDrawText(
		text,
		position.x + size + 5,
		position.y,
		position.x + size + textWidth,
		position.y + size,
		rgba(WHITE, alpha),
		1,
		fonts.caption.regular,
		"left",
		"center"
	)

	if helperText.text ~= "" then
		dxDrawText(
			helperText.text,
			position.x,
			position.y + size,
			position.x + size + textWidth,
			position.y + size + 20,
			rgba(helperText.color, alpha),
			1,
			fonts.caption.regular,
			"left",
			"center"
		)
	end

	if hover and isKeyPressed("mouse1") then
		store.set(name, {
			checked = not checked,
			textWidth = textWidth,
		})
		pressed = true
	end

	return {
		checked = checkboxStore.checked,
		pressed = pressed,
	}
end

createComponent(Checkbox.alias, Checkbox.initialOptions, Checkbox.render)

function drawCheckbox(options)
	return components[Checkbox.alias].render(options)
end
