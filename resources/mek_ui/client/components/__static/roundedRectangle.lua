local INITIAL_ROUNDED_RECTANGLE_OPTIONS = {
	position = {
		x = 0,
		y = 0,
	},
	size = {
		x = 0,
		y = 0,
	},

	color = WHITE,
	alpha = 1,
	radius = 8,

	borderWidth = 0,
	borderColor = BLACK,

	section = false,
	postGUI = false,

	liquidGlass = false,
}

local roundedRectangleSvgPath = [[
<svg viewBox="0 0 [width] [height]" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <filter id="liquidGlass" x="-50%" y="-50%" width="200%" height="200%">
      <feGaussianBlur in="SourceGraphic" stdDeviation="0.5" result="blur"/>
      <feColorMatrix in="blur" type="matrix"
        values="1 0 0 0 0
                0 1 0 0 0
                0 0 1 0 0
                0 0 0 1 0"
        result="softBlur"/>
      <feSpecularLighting in="softBlur" surfaceScale="0.5" specularConstant="0.6"
        specularExponent="30" lighting-color="#ffffff" result="specLight">
        <fePointLight x="-150" y="-80" z="150"/>
      </feSpecularLighting>
      <feComposite in="specLight" in2="SourceGraphic" operator="in" result="specComposite"/>
      <feBlend in="softBlur" in2="specComposite" mode="screen" result="finalGlass"/>
    </filter>

    <linearGradient id="liquidTopHighlight" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#FFFFFF" stop-opacity="[shine1]"/>
      <stop offset="40%" stop-color="#FFFFFF" stop-opacity="[shine2]"/>
      <stop offset="100%" stop-color="#FFFFFF" stop-opacity="0"/>
    </linearGradient>

    <linearGradient id="liquidDiagonal" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#FFFFFF" stop-opacity="[shine3]"/>
      <stop offset="30%" stop-color="#FFFFFF" stop-opacity="[shine2]"/>
      <stop offset="100%" stop-color="#FFFFFF" stop-opacity="0"/>
    </linearGradient>
  </defs>

  <rect width="[width]" height="[height]" rx="[radius]" fill="[borderColor]" />

  <rect x="[borderWidth]" y="[borderWidth]" 
        width="[fillWidth]" height="[fillHeight]" 
        rx="[innerRadius]" fill="[fillColor]" 
        filter="url(#liquidGlass)"/>

  <rect x="[borderWidth]" y="[borderWidth]"
        width="[fillWidth]" height="[fillHeight]"
        rx="[innerRadius]" fill="url(#liquidTopHighlight)" style="mix-blend-mode:soft-light"/>

  <rect x="[borderWidth]" y="[borderWidth]"
        width="[fillWidth]" height="[fillHeight]"
        rx="[innerRadius]" fill="url(#liquidDiagonal)" style="mix-blend-mode:overlay"/>

  <rect x="[borderWidth]" y="[borderWidth]"
        width="[fillWidth]" height="[fillHeight]"
        rx="[innerRadius]" fill="none" stroke="#ffffff"
        stroke-width="0.3" style="opacity:0.06"/>
</svg>
]]

createComponent("roundedRectangle", INITIAL_ROUNDED_RECTANGLE_OPTIONS, function(options, store)
	if PAUSE_RENDERING then
		return false
	end

	local position = options.position or INITIAL_ROUNDED_RECTANGLE_OPTIONS.position
	local size = options.size or INITIAL_ROUNDED_RECTANGLE_OPTIONS.size

	local color = options.color or INITIAL_ROUNDED_RECTANGLE_OPTIONS.color
	local alpha = options.alpha or INITIAL_ROUNDED_RECTANGLE_OPTIONS.alpha
	local radius = options.radius or INITIAL_ROUNDED_RECTANGLE_OPTIONS.radius

	local borderWidth = options.borderWidth or INITIAL_ROUNDED_RECTANGLE_OPTIONS.borderWidth
	local borderColor = options.borderColor or INITIAL_ROUNDED_RECTANGLE_OPTIONS.borderColor

	local section = options.section or INITIAL_ROUNDED_RECTANGLE_OPTIONS.section
	local postGUI = options.postGUI or INITIAL_ROUNDED_RECTANGLE_OPTIONS.postGUI

	local x, y = position.x, position.y
	local width, height = size.x, size.y

	local fillWidth = width - borderWidth * 2
	local fillHeight = height - borderWidth * 2
	local innerRadius = math.max(radius - borderWidth, 0)

	local liquidGlass = options.liquidGlass or INITIAL_ROUNDED_RECTANGLE_OPTIONS.liquidGlass

	local colorAlpha = tocolor(255, 255, 255, alpha * 255)

	local key = "rounded_rect_"
		.. width
		.. "_"
		.. height
		.. "_"
		.. radius
		.. "_"
		.. borderWidth
		.. "_"
		.. borderColor
		.. "_"
		.. color
		.. "_"
		.. (liquidGlass and "glass_" or "")

	if not store.get(key) then
		local shine = liquidGlass and 0.25 or 0

		local shine1 = tostring(shine * 0.3)
		local shine2 = tostring(shine * 0.15)
		local shine3 = tostring(shine * 0.08)

		local svgPath = roundedRectangleSvgPath
			:gsub("%[width%]", width)
			:gsub("%[height%]", height)
			:gsub("%[radius%]", radius)
			:gsub("%[borderWidth%]", borderWidth)
			:gsub("%[fillWidth%]", fillWidth)
			:gsub("%[fillHeight%]", fillHeight)
			:gsub("%[innerRadius%]", innerRadius)
			:gsub("%[borderColor%]", borderColor)
			:gsub("%[fillColor%]", color)
			:gsub("%[shine1%]", shine1)
			:gsub("%[shine2%]", shine2)
			:gsub("%[shine3%]", shine3)

		local svg = svgCreate(width, height, svgPath)
		store.set(key, svg)
	end

	if section then
		local percentage = section.percentage
		local direction = section.direction

		if direction == "left" then
			local sectionWidth = math.min(width, width * percentage / 100)
			dxDrawImageSection(
				x,
				y,
				sectionWidth,
				height,
				0,
				0,
				sectionWidth,
				height,
				store.get(key),
				0,
				0,
				0,
				colorAlpha,
				postGUI
			)
		elseif direction == "right" then
			local sectionWidth = math.min(width, width * percentage / 100)
			dxDrawImageSection(
				x + width - sectionWidth,
				y,
				sectionWidth,
				height,
				width - sectionWidth,
				0,
				sectionWidth,
				height,
				store.get(key),
				0,
				0,
				0,
				colorAlpha,
				postGUI
			)
		elseif direction == "top" then
			local sectionHeight = math.min(height, height * percentage / 100)
			dxDrawImageSection(
				x,
				y,
				width,
				sectionHeight,
				0,
				0,
				width,
				sectionHeight,
				store.get(key),
				0,
				0,
				0,
				colorAlpha,
				postGUI
			)
		elseif direction == "bottom" then
			local sectionHeight = math.min(height, height * percentage / 100)
			dxDrawImageSection(
				x,
				y + height - sectionHeight,
				width,
				sectionHeight,
				0,
				height - sectionHeight,
				width,
				sectionHeight,
				store.get(key),
				0,
				0,
				0,
				colorAlpha,
				postGUI
			)
		else
			dxDrawImage(x, y, width, height, store.get(key), 0, 0, 0, colorAlpha, postGUI)
		end
	else
		dxDrawImage(x, y, width, height, store.get(key), 0, 0, 0, colorAlpha, postGUI)
	end
end)

function drawRoundedRectangle(options)
	return components.roundedRectangle.render(options)
end
