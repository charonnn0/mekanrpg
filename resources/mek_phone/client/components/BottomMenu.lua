local containerSize = {
	x = Phone.innerSize.x,
	y = 50,
}

local containerPosition = {
	x = Phone.innerPosition.x,
	y = Phone.innerPosition.y + Phone.innerSize.y - containerSize.y - 15,
}

Phone.bottomMenuPadding = containerSize.y + 15

Phone.components.BottomMenu = function(actions, onClick, activePage)
	local GRID_COLUMNS = #actions

	dxDrawRectangle(containerPosition.x, containerPosition.y, containerSize.x, containerSize.y, rgba(theme.GRAY[900]))

	dxDrawRectangle(containerPosition.x, containerPosition.y, containerSize.x, 1, rgba(theme.GRAY[800]))

	local iconSize = containerSize.x / #actions

	for i = 1, GRID_COLUMNS do
		local action = actions[i]
		local icon = action.icon
		local value = action.value

		local iconPosition = {
			x = containerPosition.x + iconSize * (i - 1),
			y = containerPosition.y + (containerSize.y - iconSize) / 2,
		}

		local hover = inArea(iconPosition.x, iconPosition.y, iconSize, iconSize)
		local opacity = activePage == value and 1 or 0.5

		dxDrawText(
			icon,
			iconPosition.x,
			iconPosition.y,
			iconPosition.x + iconSize,
			iconPosition.y + iconSize,
			rgba(theme.GRAY[100], opacity),
			0.5,
			fonts.icon,
			"center",
			"center"
		)

		if hover and isKeyPressed("mouse1") then
			onClick(value)
		end
	end
end
