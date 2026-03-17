local paginationSize = {
	x = 36,
	y = 36,
}

local lastClick = getTickCount()

function drawSlider(options)
	local position = options.position
	local size = options.size
	local containerSize = options.containerSize

	local count = options.count
	local current = options.current

	local alpha = options.alpha

	local content = options.content
	local switch = options.switch

	local centerPosition = {
		x = position.x + size.x / 2 - containerSize.x / 2,
		y = position.y + size.y / 2 - containerSize.y / 2,
	}

	content(centerPosition.x, centerPosition.y, containerSize.x, containerSize.y)

	local paginationPosition = {
		x = position.x + size.x / 2 - paginationSize.x / 2,
		y = position.y + size.y - paginationSize.y - 16,
	}

	for i = 1, count do
		local x = paginationPosition.x + (i - 1) * (paginationSize.x + 10) - (count - 1) * (paginationSize.x + 10) / 2
		local y = position.y + size.y - 60

		local isCurrent = i == current
		local hover = inArea(x, y, paginationSize.x, paginationSize.y)

		drawRoundedRectangle({
			position = {
				x = x,
				y = y,
			},
			size = {
				x = paginationSize.x,
				y = paginationSize.y,
			},

			color = isCurrent and theme.BLUE[800] or theme.GRAY[900],
			alpha = alpha,
			radius = 8,

			borderWidth = 1,
			borderColor = isCurrent and theme.BLUE[400] or theme.GRAY[800],
		})

		dxDrawText(
			i,
			x,
			y,
			x + paginationSize.x,
			y + paginationSize.y,
			isCurrent and rgba(theme.BLUE[300]) or rgba(theme.GRAY[300], alpha),
			1,
			fonts.h5.regular,
			"center",
			"center"
		)

		if hover and isKeyPressed("mouse1") and lastClick + 300 <= getTickCount() then
			lastClick = getTickCount()
			switch(i)
		end
	end
end
