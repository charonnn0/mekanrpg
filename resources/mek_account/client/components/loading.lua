function renderQueryLoading()
	dxDrawRectangle(0, 0, screenSize.x, screenSize.y, rgba(theme.GRAY[900], 0.5))
	drawSpinner({
		position = {
			x = (screenSize.x - 128) / 2,
			y = (screenSize.y - 128) / 2,
		},
		size = 128,
		speed = 2,
		variant = "solid",
		color = "white",
		postGUI = true,
	})
end

function renderLoading()
	dxDrawRectangle(0, 0, screenSize.x, screenSize.y, rgba(theme.GRAY[900], 0.9))
	drawSpinner({
		position = {
			x = screenSize.x / 2 - 110 / 2,
			y = screenSize.y / 2 - 110 / 2,
		},
		size = 110,
		speed = 2,
		variant = "soft",
		color = "gray",
	})
	dxDrawText(
		"Lütfen bekleyin, giriş ekranı sizin için hazırlanıyor...",
		0,
		screenSize.y / 2 + 110 / 2 + 20,
		screenSize.x,
		0,
		tocolor(255, 255, 255),
		1,
		fonts.h5.regular,
		"center",
		"top"
	)
end

addEvent("account.removeLoading", true)
addEventHandler("account.removeLoading", root, function()
	removeEventHandler("onClientRender", root, renderLoading)
end)

addEvent("account.removeQueryLoading", true)
addEventHandler("account.removeQueryLoading", root, function()
	loading = false
	removeEventHandler("onClientRender", root, renderQueryLoading)
end)
