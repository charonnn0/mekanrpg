Settings = {}
Settings.padding = 14

Settings.enums = {
	Pages = {
		Main = "main",
		Brightness = "brightness",
		TextSize = "textSize",
	},
}

Settings.currentPage = Settings.enums.Pages.Main

Settings.state = {
	airplaneMode = false,
	wifi = true,
	mobileData = true,
	doNotDisturb = false,
	soundsEnabled = true,
	hapticsEnabled = true,
	showNotifications = true,
	showOnLockScreen = true,
	screenBrightness = 75,
	textSize = 1,
}

local function drawHeader(title, showBack)
	Phone.components.Header(function(headerPosition, headerSize)
		if showBack then
			local backWidth = 70
			local backHover = inArea(
				headerPosition.x,
				headerPosition.y,
				backWidth,
				headerSize.y
			)

			if backHover and isKeyPressed("mouse1") then
				Settings.currentPage = Settings.enums.Pages.Main
			end

			dxDrawText(
				"",
				headerPosition.x,
				headerPosition.y,
				headerPosition.x + 24,
				headerPosition.y + headerSize.y,
				rgba(theme.BLUE[300]),
				0.5,
				fonts.icon,
				"center",
				"center"
			)

			dxDrawText(
				"Ayarlar",
				headerPosition.x + 22,
				headerPosition.y,
				headerPosition.x + backWidth,
				headerPosition.y + headerSize.y,
				rgba(theme.BLUE[300]),
				1,
				fonts.UbuntuRegular.caption,
				"left",
				"center"
			)
		end

		local titleText = title or "Ayarlar"

		dxDrawText(
			titleText,
			headerPosition.x,
			headerPosition.y + 6,
			headerPosition.x + headerSize.x,
			headerPosition.y + headerSize.y,
			rgba(theme.GRAY[100]),
			1,
			fonts.BebasNeueBold.h1,
			"center",
			"center"
		)
	end)
end

local function drawSectionTitle(x, y, text)
	dxDrawText(
		text,
		x,
		y,
		x + 300,
		y + 16,
		rgba(theme.GRAY[500]),
		1,
		fonts.UbuntuBold.caption,
		"left",
		"top"
	)
end

local function drawSwitch(x, y, w, h, value)
	local radius = h / 2
	local bgColor = value and theme.GREEN[500] or theme.GRAY[700]

	drawRoundedRectangle({
		position = { x = x, y = y },
		size = { x = w, y = h },
		color = bgColor,
		alpha = 1,
		radius = radius,
	})

	local knobSize = h - 4
	local knobX = value and (x + w - knobSize - 2) or (x + 2)

	drawRoundedRectangle({
		position = { x = knobX, y = y + 2 },
		size = { x = knobSize, y = knobSize },
		color = theme.GRAY[50],
		alpha = 1,
		radius = knobSize / 2,
	})
end

local function drawChevron(x, y, size)
	dxDrawText(
		"",
		x,
		y,
		x + size,
		y + size,
		rgba(theme.GRAY[600]),
		0.4,
		fonts.icon,
		"center",
		"center"
	)
end

local function drawSlider(x, y, w, h, value)
	local radius = h / 2
	local innerX = x + 4
	local innerW = w - 8

	drawRoundedRectangle({
		position = { x = x, y = y },
		size = { x = w, y = h },
		color = theme.GRAY[800],
		alpha = 1,
		radius = radius,
	})

	local fillW = innerW * math.max(0, math.min(1, value / 100))

	drawRoundedRectangle({
		position = { x = innerX, y = y + 3 },
		size = { x = fillW, y = h - 6 },
		color = theme.BLUE[400],
		alpha = 1,
		radius = radius,
	})

	local knobSize = h + 4
	local knobCenterX = innerX + fillW

	drawRoundedRectangle({
		position = { x = knobCenterX - knobSize / 2, y = y + (h - knobSize) / 2 },
		size = { x = knobSize, y = knobSize },
		color = theme.GRAY[50],
		alpha = 1,
		radius = knobSize / 2,
	})

	local hover = inArea(x, y - 4, w, h + 8)
	if hover and isKeyPressed("mouse1") then
		local cx, cy = getCursorPosition()
		if cx and cy then
			local sx, _ = guiGetScreenSize()
			local absoluteX = cx * sx
			local rel = (absoluteX - innerX) / innerW
			return math.max(0, math.min(100, math.floor(rel * 100)))
		end
	end

	return value
end

local function drawSettingRow(opts)
	local x = opts.x
	local y = opts.y
	local w = opts.w
	local h = opts.h
	local title = opts.title
	local subtitle = opts.subtitle
	local icon = opts.icon
	local iconColor = opts.iconColor or theme.GRAY[100]
	local kind = opts.kind or "switch" -- switch | nav
	local stateKey = opts.stateKey

	local hover = inArea(x, y, w, h)

	drawRoundedRectangle({
		position = { x = x, y = y },
		size = { x = w, y = h },
		color = hover and theme.GRAY[800] or theme.GRAY[900],
		alpha = hover and 1 or 0.9,
		radius = 12,
	})

	local iconSize = h - 18
	local iconX = x + 10
	local iconY = y + (h - iconSize) / 2

	dxDrawText(
		icon,
		iconX,
		iconY,
		iconX + iconSize,
		iconY + iconSize,
		rgba(iconColor),
		0.5,
		fonts.icon,
		"center",
		"center"
	)

	local textX = iconX + iconSize + 8
	local textY = y + 6

	dxDrawText(
		title,
		textX,
		textY,
		textX + w - 80,
		textY + 20,
		rgba(theme.GRAY[50]),
		1,
		fonts.UbuntuBold.body,
		"left",
		"top",
		false,
		false,
		false,
		true
	)

	if subtitle and subtitle ~= "" then
		dxDrawText(
			subtitle,
			textX,
			textY + 18,
			textX + w - 80,
			textY + 38,
			rgba(theme.GRAY[500]),
			1,
			fonts.UbuntuRegular.caption,
			"left",
			"top",
			false,
			false,
			false,
			true
		)
	end

	if kind == "switch" and stateKey then
		local value = Settings.state[stateKey]
		local switchWidth = 44
		local switchHeight = 22
		local switchX = x + w - switchWidth - 14
		local switchY = y + (h - switchHeight) / 2

		drawSwitch(switchX, switchY, switchWidth, switchHeight, value)

		if hover and isKeyPressed("mouse1") then
			Settings.state[stateKey] = not value
		end
	elseif kind == "nav" then
		drawChevron(x + w - 22, y + (h - 18) / 2, 18)

		if hover and isKeyPressed("mouse1") and opts.onClick then
			opts.onClick()
		end
	end
end

local function drawMainPage(position, size)
	drawHeader("Ayarlar", false)

	local contentX = position.x + Settings.padding
	local contentY = position.y + Phone.headerPadding + 26
	local contentW = size.x - Settings.padding * 2
	local rowHeight = 46
	local rowGap = 8
	local maxContentY = position.y + size.y - 18

	local function nextRow()
		contentY = contentY + rowHeight + rowGap
	end

	-- Genel
	if contentY < maxContentY then
		drawSectionTitle(contentX, contentY, "GENEL")
	end
	contentY = contentY + 22

	if contentY + rowHeight < maxContentY then
		drawSettingRow({
			x = contentX,
			y = contentY,
			w = contentW,
			h = rowHeight,
			title = "Uçak Modu",
			subtitle = "Tüm bağlantıları devre dışı bırak",
			icon = "",
			iconColor = theme.ORANGE[400],
			kind = "switch",
			stateKey = "airplaneMode",
		})
	end
	nextRow()

	if contentY + rowHeight < maxContentY then
		drawSettingRow({
			x = contentX,
			y = contentY,
			w = contentW,
			h = rowHeight,
			title = "Wi‑Fi",
			subtitle = Settings.state.wifi and "Açık" or "Kapalı",
			icon = "",
			iconColor = theme.BLUE[400],
			kind = "switch",
			stateKey = "wifi",
		})
	end
	nextRow()

	if contentY + rowHeight < maxContentY then
		drawSettingRow({
			x = contentX,
			y = contentY,
			w = contentW,
			h = rowHeight,
			title = "Mobil Veri",
			subtitle = Settings.state.mobileData and "Ağ kullanılabilir" or "Kapalı",
			icon = "",
			iconColor = theme.GREEN[400],
			kind = "switch",
			stateKey = "mobileData",
		})
	end
	contentY = contentY + rowHeight + rowGap * 2

	-- Ses ve Dokunuş
	if contentY < maxContentY then
		drawSectionTitle(contentX, contentY, "SES VE DOKUNUŞ")
	end
	contentY = contentY + 22

	if contentY + rowHeight < maxContentY then
		drawSettingRow({
			x = contentX,
			y = contentY,
			w = contentW,
			h = rowHeight,
			title = "Zil ve Uyarılar",
			subtitle = Settings.state.soundsEnabled and "Sesli" or "Sessiz",
			icon = "",
			iconColor = theme.RED[400],
			kind = "switch",
			stateKey = "soundsEnabled",
		})
	end
	nextRow()

	if contentY + rowHeight < maxContentY then
		drawSettingRow({
			x = contentX,
			y = contentY,
			w = contentW,
			h = rowHeight,
			title = "Dokunsal Geri Bildirim",
			subtitle = Settings.state.hapticsEnabled and "Açık" or "Kapalı",
			icon = "",
			iconColor = theme.PURPLE[400],
			kind = "switch",
			stateKey = "hapticsEnabled",
		})
	end
	contentY = contentY + rowHeight + rowGap * 2

	-- Bildirimler
	if contentY < maxContentY then
		drawSectionTitle(contentX, contentY, "BİLDİRİMLER")
	end
	contentY = contentY + 22

	if contentY + rowHeight < maxContentY then
		drawSettingRow({
			x = contentX,
			y = contentY,
			w = contentW,
			h = rowHeight,
			title = "Uygulama Bildirimleri",
			subtitle = Settings.state.showNotifications and "Tümü açık" or "Kapalı",
			icon = "",
			iconColor = theme.YELLOW[400],
			kind = "switch",
			stateKey = "showNotifications",
		})
	end
	nextRow()

	if contentY + rowHeight < maxContentY then
		drawSettingRow({
			x = contentX,
			y = contentY,
			w = contentW,
			h = rowHeight,
			title = "Kilit Ekranında Göster",
			subtitle = Settings.state.showOnLockScreen and "Önizleme var" or "Yalnızca simge",
			icon = "",
			iconColor = theme.GRAY[300],
			kind = "switch",
			stateKey = "showOnLockScreen",
		})
	end
	contentY = contentY + rowHeight + rowGap * 2

	-- Ekran
	if contentY < maxContentY then
		drawSectionTitle(contentX, contentY, "EKRAN VE PARLAKLIK")
	end
	contentY = contentY + 22

	if contentY + rowHeight < maxContentY then
		drawSettingRow({
			x = contentX,
			y = contentY,
			w = contentW,
			h = rowHeight,
			title = "Parlaklık",
			subtitle = "Orta",
			icon = "",
			iconColor = theme.BLUE[300],
			kind = "nav",
			onClick = function()
				Settings.currentPage = Settings.enums.Pages.Brightness
			end,
		})
	end
	nextRow()

	if contentY + rowHeight < maxContentY then
		drawSettingRow({
			x = contentX,
			y = contentY,
			w = contentW,
			h = rowHeight,
			title = "Yazı Boyutu",
			subtitle = "Varsayılan",
			icon = "",
			iconColor = theme.GREEN[300],
			kind = "nav",
			onClick = function()
				Settings.currentPage = Settings.enums.Pages.TextSize
			end,
		})
	end
end

local function drawBrightnessPage(position, size)
	drawHeader("Parlaklık", true)

	local contentX = position.x + Settings.padding
	local contentY = position.y + Phone.headerPadding + 32
	local contentW = size.x - Settings.padding * 2

	dxDrawText(
		"Ekran parlaklığını ayarla",
		contentX,
		contentY,
		contentX + contentW,
		contentY + 20,
		rgba(theme.GRAY[400]),
		1,
		fonts.UbuntuRegular.caption,
		"left",
		"top"
	)

	contentY = contentY + 26

	Settings.state.screenBrightness = drawSlider(
		contentX,
		contentY,
		contentW,
		20,
		Settings.state.screenBrightness
	)

	contentY = contentY + 40

	drawSettingRow({
		x = contentX,
		y = contentY,
		w = contentW,
		h = 46,
		title = "Otomatik Parlaklık",
		subtitle = "Ortam ışığına göre ayarla",
		icon = "",
		iconColor = theme.GREEN[400],
		kind = "switch",
		stateKey = "autoBrightness",
	})
end

local function drawTextSizePage(position, size)
	drawHeader("Yazı Boyutu", true)

	local contentX = position.x + Settings.padding
	local contentY = position.y + Phone.headerPadding + 32
	local contentW = size.x - Settings.padding * 2

	dxDrawText(
		"Metin boyutunu ayarla",
		contentX,
		contentY,
		contentX + contentW,
		contentY + 20,
		rgba(theme.GRAY[400]),
		1,
		fonts.UbuntuRegular.caption,
		"left",
		"top"
	)

	contentY = contentY + 26

	local sliderValue = Settings.state.textSize * 50
	sliderValue = drawSlider(contentX, contentY, contentW, 20, sliderValue)
	Settings.state.textSize = math.floor(sliderValue / 50 + 0.5)

	contentY = contentY + 40

	local previewSize = Settings.state.textSize == 0 and fonts.UbuntuRegular.caption
		or (Settings.state.textSize == 1 and fonts.UbuntuRegular.body or fonts.UbuntuRegular.h6)

	dxDrawText(
		"Örnek metin - Yazı boyutu önizleme",
		contentX,
		contentY,
		contentX + contentW,
		contentY + 40,
		rgba(theme.GRAY[50]),
		1,
		previewSize,
		"left",
		"top",
		false,
		false,
		false,
		true
	)
end

Phone.addApp(Phone.enums.Apps.Settings, function(position, size)
	if Settings.currentPage == Settings.enums.Pages.Brightness then
		drawBrightnessPage(position, size)
	elseif Settings.currentPage == Settings.enums.Pages.TextSize then
		drawTextSizePage(position, size)
	else
		drawMainPage(position, size)
	end
end, "public/apps/settings.png", "Ayarlar")
