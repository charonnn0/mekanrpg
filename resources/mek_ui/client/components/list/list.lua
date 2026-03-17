List = {}
List.alias = "list"
List.initialOptions = {
	position = {
		x = 0,
		y = 0,
	},
	size = {
		x = 0,
		y = 0,
	},

	padding = 10,
	rowHeight = 35,

	name = "",

	header = false,
	items = {},

	variant = "soft",
	color = "gray",

	disabled = false,
}

local lastTick = getTickCount()

List.render = function(options, store)
	local position = options.position or List.initialOptions.position
	local size = options.size or List.initialOptions.size

	local padding = options.padding or List.initialOptions.padding
	local rowHeight = options.rowHeight or List.initialOptions.rowHeight

	local name = options.name or List.initialOptions.name

	local header = options.header or List.initialOptions.header
	local items = options.items or List.initialOptions.items

	local variant = options.variant or List.initialOptions.variant
	local color = options.color or List.initialOptions.color

	local disabled = options.disabled or List.initialOptions.disabled

	local fonts = useFonts()
	local theme = useTheme()

	local listColor = useListVariant(variant, color)

	local listStore = store.get(name)

	if not listStore then
		store.set(name, {
			current = 1,
			max = math.floor((size.y - 60) / rowHeight),
		})
		return
	end

	listStore.max = math.floor((size.y - 50) / rowHeight)

	local hover = inArea(position.x, position.y, size.x, size.y)

	local pressed = false

	if variant == AVAILABLE_VARIANTS.OUTLINED then
		drawRoundedRectangle({
			position = position,
			size = size,
			color = listColor.textColor,
			radius = 5,
		})

		drawRoundedRectangle({
			position = {
				x = position.x + 1,
				y = position.y + 1,
			},
			size = {
				x = size.x - 2,
				y = size.y - 2,
			},
			color = listColor.background,
			radius = 5,
		})
	elseif variant ~= AVAILABLE_VARIANTS.TRANSPARENT then
		drawRoundedRectangle({
			position = position,
			size = size,
			color = listColor.background,
			radius = 5,
		})
	end

	if #items > listStore.max then
		drawScrollBar({
			position = position,
			size = size,
			current = math.floor(listStore.current),
			total = #items,
			visibleCount = listStore.max,
		})
	end

	if hover and #items > listStore.max then
		if pressedKeys.mouse_wheel_down then
			listStore.current = math.min(listStore.current + 1, #items - listStore.max + 1)
			store.set(name, listStore)
		elseif pressedKeys.mouse_wheel_up then
			listStore.current = math.max(listStore.current - 1, 1)
			store.set(name, listStore)
		end
	end

	if header then
		local headerWidth = dxGetTextWidth(header, 1, fonts.h5.black)
		local fontSize = headerWidth + 2 * padding > size.x and (size.x / (headerWidth + 2 * padding)) or 1
		dxDrawText(
			header,
			position.x + padding,
			position.y + padding,
			position.x + size.x - padding,
			position.y + size.y - padding,
			rgba(GRAY[100]),
			fontSize,
			fonts.h5.black,
			"left",
			"top",
			false,
			false,
			false,
			true
		)
	else
		position.y = position.y - rowHeight - padding
	end

	local i = 1
	for _ = listStore.current, listStore.current + listStore.max - 1 do
		local item = items[_]
		if item then
			local itemPosition = {
				x = position.x + padding,
				y = position.y + (padding + 10) + rowHeight + (i - 1) * (rowHeight + 5),
			}
			local itemSize = {
				x = size.x - padding * 2,
				y = rowHeight,
			}

			local hover = inArea(itemPosition.x, itemPosition.y, itemSize.x, itemSize.y)

			if hover then
				drawRoundedRectangle({
					position = itemPosition,
					size = itemSize,
					color = listColor.itemColor,
					radius = 5,
				})
				if isKeyPressed("mouse1") then
					pressed = item.key
				end
			end
			if item.icon ~= "" then
				dxDrawText(
					item.icon,
					itemPosition.x + 10,
					itemPosition.y,
					itemPosition.x + itemSize.x,
					itemPosition.y + itemSize.y,
					rgba(GRAY[400], 1),
					0.4,
					fonts.icon,
					"left",
					"center",
					false,
					false,
					false,
					true
				)
				itemPosition.x = itemPosition.x + 20
			end

			dxDrawText(
				item.text,
				itemPosition.x + padding,
				itemPosition.y,
				itemPosition.x + itemSize.x - padding,
				itemPosition.y + itemSize.y,
				rgba(theme[item.color or "GRAY"][400], 1),
				1,
				fonts.body.regular,
				"left",
				"center",
				false,
				false,
				false,
				true
			)
			i = i + 1
		end
	end

	store.set(name, listStore)
	return {
		current = listStore.current,
		max = listStore.max,
		pressed = not disabled and pressed or false,
	}
end

createComponent(List.alias, List.initialOptions, List.render)

function drawList(options)
	return components[List.alias].render(options)
end
