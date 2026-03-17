local bottomApps = {
	Phone.enums.Apps.Contacts,
	Phone.enums.Apps.Gallery,
	Phone.enums.Apps.Camera,
	Phone.enums.Apps.Settings,
}

local topApps = {
	Phone.enums.Apps.Bank,
}

local iconSize = {
	x = 40,
	y = 40,
}

local function renderBottomApps(position, size)
	drawRoundedRectangle({
		position = position,
		size = size,

		color = theme.GRAY[700],
		alpha = 0.7,
		radius = 16,
	})

	for i = 1, #bottomApps do
		local app = bottomApps[i]
		local appPosition = {
			x = position.x + (size.x / #bottomApps) * (i - 1),
			y = position.y,
		}
		local appSize = {
			x = size.x / #bottomApps,
			y = size.y,
		}

		local icon = Phone.apps[app].icon

		local iconPosition = {
			x = appPosition.x + (appSize.x - iconSize.x) / 2,
			y = appPosition.y + (appSize.y - iconSize.y) / 2,
		}

		local hover = inArea(iconPosition.x, iconPosition.y, iconSize.x, iconSize.y)

		dxDrawImage(iconPosition.x, iconPosition.y, iconSize.x, iconSize.y, icon)

		if hover and isKeyPressed("mouse1") then
			Phone.goToApp(app)
		end
	end
end

local function renderTopApps(position, size)
	for i = 1, #topApps do
		local app = topApps[i]

		local icon = Phone.apps[app].icon

		local iconPosition = {
			x = position.x + (iconSize.x + 8) * (i - 1),
			y = position.y,
		}

		local hover = inArea(iconPosition.x, iconPosition.y, iconSize.x, iconSize.y)

		dxDrawImage(iconPosition.x, iconPosition.y, iconSize.x, iconSize.y, icon)
		dxDrawText(
			Phone.apps[app].name,
			iconPosition.x,
			iconPosition.y + 20,
			iconPosition.x + iconSize.x,
			iconPosition.y + iconSize.y + 20,
			rgba(theme.GRAY[50]),
			1,
			fonts.BebasNeueRegular.caption,
			"center",
			"bottom"
		)

		if hover and isKeyPressed("mouse1") then
			Phone.goToApp(app)
		end
	end
end

Phone.addApp(Phone.enums.Apps.Home, function(position, size)
	dxDrawImage(position.x, position.y, size.x, size.y, "public/background/b" .. Phone.backgroundID .. ".png")

	dxDrawText(
		time,
		position.x,
		position.y + 60,
		size.x + position.x,
		0,
		rgba(theme.GRAY[50]),
		1,
		fonts.BebasNeueBold.h0,
		"center"
	)
	dxDrawText(
		dayTime,
		position.x,
		position.y + 100,
		size.x + position.x,
		0,
		rgba(theme.GRAY[200]),
		1,
		fonts.BebasNeueRegular.h5,
		"center"
	)

	renderTopApps({
		x = position.x + 16,
		y = position.y + 140,
	}, {
		x = size.x - 32,
		y = 200,
	})

	renderBottomApps({
		x = position.x + 8,
		y = position.y + size.y - 80,
	}, {
		x = size.x - 16,
		y = 60,
	})
end, false, "Ana Menü")
