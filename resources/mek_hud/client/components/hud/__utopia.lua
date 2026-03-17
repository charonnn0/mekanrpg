local CONTAINER_SIZES = {
	x = 141,
	y = 144,
}

local healthSize = {
	x = 32,
	y = 97,
}

local armorSize = {
	x = 97,
	y = 32,
}

createHudComponent("hud/utopia", function(store)
	local containerPosition = {
		x = screenSize.x - CONTAINER_SIZES.x - (PADDING * 2),
		y = PADDING * 2,
	}

	local health = store.get("health") or 0
	local armor = store.get("armor") or 0
	local weapon = store.get("weapon") or 0
	local stamina = store.get("stamina") or 0
	local ammo = store.get("ammo") or 0

	dxDrawImage(
		containerPosition.x,
		containerPosition.y,
		CONTAINER_SIZES.x,
		CONTAINER_SIZES.y,
		"public/images/hud/utopia_bg.png",
		0,
		0,
		0,
		tocolor(255, 255, 255, 255),
		false
	)
	dxDrawImage(
		containerPosition.x + CONTAINER_SIZES.x / 2 - 64 / 2,
		containerPosition.y + CONTAINER_SIZES.y / 2 - 64 / 2,
		64,
		64,
		"public/images/weapons/" .. weapon .. ".png",
		0,
		0,
		0,
		tocolor(255, 255, 255, 255),
		false
	)

	if BULLET_WEAPONS[weapon] then
		dxDrawText(
			ammo,
			containerPosition.x + CONTAINER_SIZES.x - 25,
			containerPosition.y + CONTAINER_SIZES.y - 46,
			0,
			0,
			tocolor(225, 225, 225),
			0.8,
			fonts.caption.regular,
			"left",
			"top"
		)
	end

	local healthBarPosition = {
		x = containerPosition.x + 1,
		y = containerPosition.y + 23,
	}

	local healthHeight = healthSize.y * (health / 100)

	dxDrawImageSection(
		healthBarPosition.x,
		healthBarPosition.y + healthSize.y,
		healthSize.x,
		-healthHeight,
		0,
		0,
		healthSize.x,
		-healthHeight,
		"public/images/hud/utopia_hp.png",
		0,
		0,
		0,
		tocolor(255, 255, 255, 255),
		false
	)

	local armorBarPosition = {
		x = containerPosition.x + 24,
		y = containerPosition.y + CONTAINER_SIZES.y / 2 + 7,
	}

	local armorWidth = armorSize.x * (armor / 100)

	dxDrawImageSection(
		armorBarPosition.x,
		armorBarPosition.y + armorSize.y,
		armorWidth,
		armorSize.y,
		0,
		0,
		armorWidth,
		armorSize.y,
		"public/images/hud/utopia_armor.png",
		0,
		0,
		0,
		tocolor(255, 255, 255, 255),
		false
	)

	local staminaBarPosition = {
		x = containerPosition.x + 24,
		y = containerPosition.y + 1,
	}

	local staminaWidth = armorSize.x * (stamina / 100)

	dxDrawImageSection(
		staminaBarPosition.x,
		staminaBarPosition.y,
		staminaWidth,
		armorSize.y,
		0,
		0,
		staminaWidth,
		armorSize.y,
		"public/images/hud/utopia_stamina.png",
		0,
		0,
		0,
		tocolor(255, 255, 255, 255),
		false
	)
end, {
	name = "Utopia",
})
