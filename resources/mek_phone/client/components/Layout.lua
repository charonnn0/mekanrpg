local function renderHeader(position, size)
	dxDrawText(
		time,
		position.x,
		position.y,
		size.x + position.x,
		size.y + position.y,
		rgba(styles.foreground),
		1,
		fonts.UbuntuBold.body,
		"left",
		"center"
	)
	dxDrawImage(
		size.x + position.x - 50,
		size.y + position.y - 18,
		63,
		18,
		"public/frames/status_bar.png"
	)
end

local function renderFooter(position, size)
	local hover = inArea(position.x, position.y, size.x, size.y + 5)

	drawRoundedRectangle({
		position = position,
		size = size,

		color = styles.foreground,
		alpha = 1,
		radius = 2,

		section = false,
		postGUI = false,
	})

	if hover and isKeyPressed("mouse1") then
		Phone.goToApp(Phone.enums.Apps.Home)
	end
end

Phone.components.layout = function()
	if Phone.rotation == Phone.enums.Rotation.Vertical and Phone.currentApp ~= Phone.enums.Apps.Camera then
		renderHeader({
			x = Phone.innerPosition.x + 35,
			y = Phone.innerPosition.y + 16,
		}, {
			x = Phone.innerSize.x - 70,
			y = 15,
		})
	end

	renderFooter({
		x = Phone.innerPosition.x + Phone.innerSize.x / 4,
		y = Phone.innerPosition.y + Phone.innerSize.y - 10,
	}, {
		x = Phone.innerSize.x / 2,
		y = 5,
	})
end
