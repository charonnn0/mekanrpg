local containerPosition = {
	x = screenSize.x * 0.786,
	y = screenSize.y * 0.025,
}

local barSize = {
	x = screenSize.x * 0.035,
	y = screenSize.y * 0.017,
}

local healthBarSize = {
	x = screenSize.x * 0.095,
	y = screenSize.y * 0.019,
}

local barPadding = screenSize.x * 0.004
local imageSize = screenSize.y * 0.016

local armorR, armorG, armorB = 225, 225, 255
local healthR, healthG, healthB = 180, 25, 29

createHudComponent("hud/native", function(store)
	local x, y = containerPosition.x, containerPosition.y

	local currentDate = getRealTime()
	local year = currentDate.year + 1900
	local month = currentDate.month + 1
	local day = currentDate.monthday
	local hour = currentDate.hour
	local minute = currentDate.minute
	local dateText = string.format("%02d-%02d-%04d", day, month, year)
	local timeText = string.format("%02d:%02d", hour, minute)

	for _, key in ipairs({ "ammo", "breath", "money", "weapon" }) do
		setPlayerHudComponentVisible(key, true)
	end
	setPlayerHudComponentVisible("clock", false)
	setPlayerHudComponentVisible("armour", false)
	setPlayerHudComponentVisible("health", false)

	for _, key in ipairs({ "hunger", "thirst", "stamina" }) do
		local value = key == "stamina" and exports.mek_realism:getStamina() or store.get(key)
		value = math.min(value, 100)

		local r, g, b = 131, 189, 44
		if value >= 60 and value <= 80 then
			r, g, b = 145, 211, 116
		elseif value >= 40 and value <= 60 then
			r, g, b = 192, 138, 49
		elseif value >= 0 and value <= 40 then
			r, g, b = 180, 25, 29
		end

		dxDrawRectangle(x, y, barSize.x, barSize.y, rgba(theme.BLACK))
		dxDrawRectangle(
			x + barPadding / 2,
			y + barPadding / 2,
			barSize.x - barPadding,
			barSize.y - barPadding,
			tocolor(r, g, b, 155)
		)

		dxDrawRectangle(
			x + barPadding / 2,
			y + barPadding / 2,
			(barSize.x - barPadding) * value / 100,
			barSize.y - barPadding,
			tocolor(r, g, b, 155)
		)

		dxDrawImage(x - screenSize.x * 0.004, y, imageSize, imageSize, "public/images/hud/native/" .. key .. ".png")

		x = x + barSize.x * 1.2
	end

	x = x + barSize.x * 1.2

	dxDrawText(
		"[",
		0,
		0,
		screenSize.x * 1.716,
		screenSize.y * 0.115,
		tocolor(0, 0, 0),
		respc(5),
		"default-bold",
		"center",
		"bottom"
	)

	dxDrawBorderedText(
		1,
		timeText,
		0,
		0,
		screenSize.x * 1.803,
		screenSize.y * 0.155,
		tocolor(47, 90, 38),
		respc(2),
		"pricedown",
		"center",
		"center"
	)

	dxDrawBorderedText(
		1,
		dateText,
		0,
		0,
		screenSize.x * 1.803,
		screenSize.y * 0.205,
		tocolor(195, 195, 195),
		respc(1.4),
		"default-bold",
		"center",
		"center"
	)

	dxDrawText(
		"]",
		0,
		0,
		screenSize.x * 1.892,
		screenSize.y * 0.115,
		tocolor(0, 0, 0),
		respc(5),
		"default-bold",
		"center",
		"bottom"
	)

	local playerArmor = math.min(localPlayer.armor)
	local armorBarX = x * 0.895
	local armorBarY = y + barSize.y + barPadding * 11

	if playerArmor > 0 then
		dxDrawRectangle(armorBarX, armorBarY, healthBarSize.x, healthBarSize.y, rgba(theme.BLACK))
		dxDrawRectangle(
			armorBarX + barPadding / 2,
			armorBarY + barPadding / 2,
			healthBarSize.x - barPadding,
			healthBarSize.y - barPadding,
			tocolor(armorR, armorG, armorB, 155)
		)
		dxDrawRectangle(
			armorBarX + barPadding / 2,
			armorBarY + barPadding / 2,
			(healthBarSize.x - barPadding) * playerArmor / 100,
			healthBarSize.y - barPadding,
			tocolor(armorR, armorG, armorB, 155)
		)
	end

	local playerHealth = math.min(localPlayer.health)
	local healthBarX = x * 0.895
	local healthBarY = y + barSize.y + barPadding * 15

	dxDrawRectangle(healthBarX, healthBarY, healthBarSize.x, healthBarSize.y, rgba(theme.BLACK))
	dxDrawRectangle(
		healthBarX + barPadding / 2,
		healthBarY + barPadding / 2,
		healthBarSize.x - barPadding,
		healthBarSize.y - barPadding,
		tocolor(healthR, healthG, healthB, 155)
	)
	dxDrawRectangle(
		healthBarX + barPadding / 2,
		healthBarY + barPadding / 2,
		(healthBarSize.x - barPadding) * playerHealth / 100,
		healthBarSize.y - barPadding,
		tocolor(healthR, healthG, healthB, 155)
	)
end, {
	name = "Native",
})
