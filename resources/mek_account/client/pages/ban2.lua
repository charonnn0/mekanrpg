local CONTAINER_SIZES = {
	x = 500,
	y = 540,
}

local x, y = screenSize.x / 2 - CONTAINER_SIZES.x / 2, screenSize.y / 2 - CONTAINER_SIZES.y / 2 - 50

local banDetails = {}

function renderbanPage()
	dxDrawRectangle(0, 0, screenSize.x, screenSize.y, rgba(theme.GRAY[900], 100))

	local nowTick = getTickCount()
	local hoverOffset = math.sin(nowTick / 1200) * 8
	local breathingScale = 1 + (math.sin(nowTick / 1800) * 0.03)

	local LOGO_SIZES = { x = 150, y = 150 }
	local currentLogoW = LOGO_SIZES.x * breathingScale
	local currentLogoH = LOGO_SIZES.y * breathingScale

	local logoX = (screenSize.x - 150) / 2 - (currentLogoW - LOGO_SIZES.x) / 2
	local logoY = (screenSize.y / 2 - 300) + hoverOffset - (currentLogoH - LOGO_SIZES.y) / 2

	local alpha = 1

	local outerGlowSize = 30 * breathingScale
	dxDrawImage(
		logoX - outerGlowSize,
		logoY - outerGlowSize,
		currentLogoW + outerGlowSize * 2,
		currentLogoH + outerGlowSize * 2,
		":mek_ui/public/images/logo.png",
		0, 0, 0,
		tocolor(147, 51, 234, 40 * alpha)
	)

	local glowPulse = math.abs(math.sin(nowTick / 1200)) 
	local innerGlowSize = (10 + (5 * glowPulse)) * breathingScale
	dxDrawImage(
		logoX - innerGlowSize,
		logoY - innerGlowSize,
		currentLogoW + innerGlowSize * 2,
		currentLogoH + innerGlowSize * 2,
		":mek_ui/public/images/logo.png",
		0, 0, 0,
		tocolor(168, 85, 247, (60 + (40 * glowPulse)) * alpha)
	)

	dxDrawImage(
		logoX,
		logoY,
		currentLogoW,
		currentLogoH,
		":mek_ui/public/images/logo.png",
		0, 0, 0,
		tocolor(255, 255, 255, alpha * 255)
	)

	drawTypography({
		position = {
			x = x,
			y = y + 200,
		},

		text = "Sunucudan yasaklandınız.",
		alignX = "left",
		alignY = "top",
		color = theme.WHITE[50],
		scale = "h1",
		wrap = false,

		fontWeight = "bold",
	})

	drawList({
		position = {
			x = x,
			y = y + 300,
		},
		size = {
			x = CONTAINER_SIZES.x,
			y = CONTAINER_SIZES.y - 300,
		},

		padding = 20,
		rowHeight = 35,

		name = "ban_details",
		header = "Yasak Detayları",
		items = {
			{ icon = "", text = "Yasaklayan: " .. (banDetails.admin or "Bilinmiyor"), key = "" },
			{ icon = "", text = "Yasaklanma Sebebi: " .. (banDetails.reason or "Belirtilmedi"), key = "" },
			{ icon = "", text = "Yasaklanma Tarihi: " .. (banDetails.date or "-"), key = "" },
			{
				icon = "",
				text = "Bitiş Süresi: "
					.. (
						(banDetails.endTick == -1) and "Sınırsız"
						or exports.mek_datetime:secondsToTimeDesc((banDetails.endTick or 0) / 1000)
					),
				key = "",
			},
		},

		variant = "soft",
		color = "gray",
	})

	drawTypography({
		position = {
			x = x,
			y = y + 250,
		},

		text = "Kuralları ihlal ettiğiniz için sunucudan yasaklandınız. Aşağıdan detayları\ngörüntüleyebilirsiniz.",
		alignX = "left",
		alignY = "top",
		color = theme.GRAY[300],
		scale = "body",
		wrap = false,

		fontWeight = "regular",
	})
end

addEvent("account.banPage", true)
addEventHandler("account.banPage", root, function(_banDetails)
	if _banDetails then
        banDetails = {}
        
        banDetails.admin = _banDetails.admin or _banDetails[1] or "Sistem"
        banDetails.reason = _banDetails.reason or _banDetails[2] or "Belirtilmedi"
        banDetails.date = _banDetails.date or _banDetails[3] or "-"
        banDetails.endTick = _banDetails.endTick or _banDetails[4] or 0

		setPlayerHudComponentVisible("all", false)
		setPlayerHudComponentVisible("crosshair", true)
		setCameraMatrix(
			-350.67303466797,
			2229.3159179688,
			46.286087036133,
			-257.8219909668,
			2193.5864257812,
			36.182357788086
		)
		fadeCamera(true)
		showCursor(true)
		showChat(false)
		Music.play()

		loading = false
		removeEventHandler("onClientRender", root, renderLoading)

		addEventHandler("onClientRender", root, renderSplash)
		addEventHandler("onClientRender", root, renderbanPage)
		addEventHandler("onClientKey", root, function()
			cancelEvent()
		end)
	end
end)

addEvent("account.playBanSound", true)
addEventHandler("account.playBanSound", root, function()
	playSound("public/sounds/ban.mp3", false)
end)
