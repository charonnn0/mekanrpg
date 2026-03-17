local HUD_WIDTH = 120
local HUD_HEIGHT = 450
local LOGO_SIZE = 64
local PADDING = 40
local INFO_LINE_HEIGHT = 42

createHudComponent("hud/modern", function(store)
	local hudPosX = screenSize.x - HUD_WIDTH
	local hudPosY = -10

	local weapon = localPlayer:getWeapon()

	local hudInfo = {
		{
			data = "₺" .. exports.mek_global:formatMoney(getElementData(localPlayer, "money") or 0),
			label = "Cüzdan",
			icon = "",
			color = theme.GREEN[400],
		},
		{
			data = "₺" .. exports.mek_global:formatMoney(getElementData(localPlayer, "bank_money") or 0),
			label = "Banka",
			icon = "",
			color = theme.GRAY[300],
		},
		{
			data = "%" .. math.floor(getElementData(localPlayer, "hunger") or 0),
			label = "Açlık",
			icon = "",
			color = theme.ORANGE[500],
		},
		{
			data = "%" .. math.floor(getElementData(localPlayer, "thirst") or 0),
			label = "Susuzluk",
			icon = "",
			color = theme.BLUE[400],
		},
		{
			data = "%" .. exports.mek_realism:getStamina() or 0,
			label = "Dayanıklılık",
			icon = "",
			color = theme.YELLOW[500],
		},
		{
			data = getWeaponNameFromID(weapon) or "Yok",
			label = "Silah",
			icon = "",
			color = theme.RED[400],
			isWeapon = true,
		},
	}

	dxDrawGradient(hudPosX, hudPosY, HUD_WIDTH, HUD_HEIGHT, 0, 0, 0, 150, false, false)

	dxDrawImage(hudPosX + PADDING, hudPosY + PADDING, LOGO_SIZE, LOGO_SIZE, ":mek_ui/public/images/logo.png")

	drawTextWithShadow(
		"",
		hudPosX + 55,
		hudPosY + LOGO_SIZE + 57,
		LOGO_SIZE,
		LOGO_SIZE,
		getServerColor(1),
		0.45,
		fonts.icon
	)
	drawTextWithShadow(
		#getElementsByType("player"),
		hudPosX + 79,
		hudPosY + LOGO_SIZE + 55,
		LOGO_SIZE,
		LOGO_SIZE,
		rgba(theme.GRAY[50]),
		1,
		fonts.ProximaNovaBold.h5
	)

	local infoDrawPosY = hudPosY + 150
	for _, info in ipairs(hudInfo) do
		local infoData = info.data

		if info.isWeapon and BULLET_WEAPONS[weapon] then
			local ammoInClip = getPedAmmoInClip(localPlayer, getPedWeaponSlot(localPlayer)) or 0
			local totalAmmo = getPedTotalAmmo(localPlayer) or 0
			local currentAmmo = totalAmmo - ammoInClip

			infoData = infoData .. " (" .. ammoInClip .. "/" .. currentAmmo .. ")"
		end

		drawTextWithShadow(
			info.label,
			hudPosX + 60,
			infoDrawPosY,
			hudPosX + 60,
			LOGO_SIZE,
			rgba(theme.GRAY[100]),
			1,
			fonts.UbuntuBold.body,
			"right"
		)
		drawTextWithShadow(
			infoData,
			hudPosX + 60,
			infoDrawPosY + 15,
			hudPosX + 60,
			LOGO_SIZE,
			rgba(theme.GRAY[200]),
			1,
			fonts.UbuntuRegular.body,
			"right"
		)
		drawTextWithShadow(info.icon, hudPosX + 70, infoDrawPosY + 5, 0, 0, rgba(info.color), 0.7, fonts.icon)
		infoDrawPosY = infoDrawPosY + INFO_LINE_HEIGHT
	end
end, {
	name = "Modern",
})
