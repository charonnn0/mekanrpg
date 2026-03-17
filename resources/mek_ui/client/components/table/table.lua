Table = {}
Table.alias = "table"
Table.initialOptions = {
	position = {
		x = 0,
		y = 0,
	},
	size = {
		x = 0,
		y = 0,
	},

	padding = 10,

	name = "",

	columns = {},
	rows = {},

	variant = "soft",
	color = "gray",

	radius = DEFAULT_RADIUS,

	disabled = false,
}

local function measureText(text, font, fontSize)
	local textWidth = dxGetTextWidth(text, fontSize, font)
	local textHeight = dxGetFontHeight(fontSize, font)

	return {
		x = textWidth,
		y = textHeight,
	}
end

Table.render = function(options, store)
	local position = options.position or Table.initialOptions.position
	local size = options.size or Table.initialOptions.size

	local padding = options.padding or Table.initialOptions.padding

	local name = options.name or Table.initialOptions.name

	local columns = options.columns or Table.initialOptions.columns
	local rows = options.rows or Table.initialOptions.rows

	local variant = options.variant or Table.initialOptions.variant
	local color = options.color or Table.initialOptions.color

	local radius = options.radius or Table.initialOptions.radius
	local disabled = options.disabled or Table.initialOptions.disabled

	local fonts = useFonts()

	local columnWidth = (size.x - padding * 2) / #columns

	local columnHeight = 20

	local rowHeight = 30

	local headerHeight = columnHeight + padding * 2

	local tableHeight = size.y - headerHeight

	local rowsPerPage = math.floor(tableHeight / rowHeight)

	local pages = math.ceil(#rows / rowsPerPage)

	local tableStore = useStore(name)
	if not tableStore then
		tableStore.set("currentPage", 1)
	end

	local currentPage = tableStore.get("currentPage") or 1

	local headerPosition = {
		x = position.x,
		y = position.y,
	}

	local headerSize = {
		x = size.x,
		y = headerHeight,
	}

	local tablePosition = {
		x = position.x,
		y = position.y + headerHeight + 2,
	}

	local tableSize = {
		x = size.x,
		y = tableHeight,
	}

	local variantData = useTableVariant(variant, color)

	drawRoundedRectangle({
		position = headerPosition,
		size = {
			x = headerSize.x,
			y = headerSize.y,
		},

		color = variantData.header,
		variant = variant,
		radius = radius,
	})

	drawRoundedRectangle({
		position = tablePosition,
		size = {
			x = tableSize.x,
			y = tableSize.y,
		},

		color = variantData.background,
		variant = variant,
		radius = radius,
	})

	local columnPosition = {
		x = headerPosition.x + padding,
		y = headerPosition.y + padding,
	}

	local columnSize = {
		x = columnWidth - padding * 2,
		y = columnHeight,
	}

	for i, column in ipairs(columns) do
		local columnText = column.text

		local columnWidth = column.width and (size.x * column.width) or columnSize.x

		local columnFont = column.font or fonts.body.regular
		local columnFontSize = column.fontSize or 1

		local columnFontColor = column.fontColor or WHITE
		if disabled then
			columnFontColor = GRAY[700]
		end

		local columnTextSize = measureText(columnText, columnFont, columnFontSize)

		local columnTextPosition = {
			x = columnPosition.x,
			y = columnPosition.y + columnSize.y / 2 - columnTextSize.y / 2,
		}

		dxDrawText(
			columnText,
			columnTextPosition.x,
			columnTextPosition.y,
			columnTextPosition.x + columnTextSize.x,
			columnTextPosition.y + columnTextSize.y,
			rgba(columnFontColor, 1),
			columnFontSize,
			columnFont,
			"left",
			"center",
			false,
			false,
			false,
			false,
			false
		)
		columnPosition.x = columnPosition.x + columnWidth
	end

	local rowPosition = {
		x = tablePosition.x + padding,
		y = tablePosition.y + padding,
	}

	local rowSize = {
		x = columnWidth - padding * 2,
		y = rowHeight,
	}

	local rowStart = (currentPage - 1) * rowsPerPage + 1
	local rowEnd = currentPage * rowsPerPage

	local hoverRow = nil
	local pressedRow = nil
	local hoverColumn = nil

	local showingRowCount = 0
	for i = rowStart, rowEnd do
		local row = rows[i]
		if row then
			if not disabled then
				if inArea(rowPosition.x, rowPosition.y, size.x, rowSize.y) then
					hoverRow = row
					if isKeyPressed("mouse1") then
						pressedRow = row
					end
				else
					hoverRow = nil
				end
			end
			for j, column in ipairs(columns) do
				local columnText = row[j]

				local columnWidth = column.width and (size.x * column.width) or columnSize.x

				local columnFont = column.font or fonts.body.light
				local columnFontSize = column.fontSize or 1

				local columnFontColor = column.fontColor or GRAY[hoverRow and 200 or 400]
				if disabled then
					columnFontColor = GRAY[700]
				end

				local columnTextSize = measureText(columnText, columnFont, columnFontSize)

				local columnTextPosition = {
					x = rowPosition.x,
					y = rowPosition.y + rowSize.y / 2 - columnTextSize.y / 2,
				}

				if
					not disabled
					and inArea(columnTextPosition.x, columnTextPosition.y, columnTextSize.x, columnTextSize.y)
				then
					hoverColumn = j
				end

				dxDrawText(
					columnText,
					columnTextPosition.x,
					columnTextPosition.y,
					columnTextPosition.x + columnTextSize.x,
					columnTextPosition.y + columnTextSize.y,
					rgba(columnFontColor, 1),
					columnFontSize,
					columnFont,
					"left",
					"center",
					false,
					false,
					false,
					true,
					false
				)
				rowPosition.x = rowPosition.x + columnWidth
			end
			showingRowCount = showingRowCount + 1
			rowPosition.x = tablePosition.x + padding
			rowPosition.y = rowPosition.y + rowHeight
		end
	end

	local paginationSize = {
		x = 30,
		y = 30,
	}

	local paginationPosition = {
		x = tablePosition.x,
		y = tablePosition.y + tableSize.y + 5,
	}

	for i = 1, pages do
		local paginationText = i
		local active = i == currentPage

		local button = drawButton({
			position = {
				x = paginationPosition.x + (i - 1) * (paginationSize.x + 5),
				y = paginationPosition.y,
			},
			size = paginationSize,
			text = paginationText,
			name = "pagination_" .. i,

			variant = "soft",
			color = active and "blue" or "gray",
			disabled = disabled,
		})

		if button.pressed then
			tableStore.set("currentPage", i)
		end
	end

	dxDrawText(
		#rows .. " satırdan " .. rowStart .. "-" .. showingRowCount .. " arası gösteriliyor",
		paginationPosition.x,
		paginationPosition.y,
		paginationPosition.x + headerSize.x,
		paginationPosition.y + paginationSize.y,
		rgba(GRAY[600], 1),
		1,
		fonts.body.regular,
		"right",
		"center",
		false,
		false,
		false,
		false,
		false
	)

	return {
		hoverRow = hoverRow,
		pressedRow = pressedRow,
		hoverColumn = hoverColumn,
	}
end

createComponent(Table.alias, Table.initialOptions, Table.render)

function drawTable(options)
	return components[Table.alias].render(options)
end
