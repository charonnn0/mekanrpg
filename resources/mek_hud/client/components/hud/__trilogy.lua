local CONTAINER_SIZE = {
	x = 120,
	y = 80,
}

local containerPosition = {
	x = screenSize.x - CONTAINER_SIZE.x - PADDING * 2,
	y = PADDING * 4,
}

local barSize = {
	x = 120,
	y = 15,
}

local font = dxCreateFont(":mek_ui/public/fonts/Pricedown.ttf", 25) or "default"

createHudComponent("hud/trilogy", function(store)
	local weapon = localPlayer:getWeapon()

	local time = store.get("time") or ""
	local money = store.get("money_no-format") or 0
	local ammo = store.get("ammo") or ""

	local x, y = containerPosition.x, containerPosition.y

	dxDrawImage(x, y, 128, 128, "public/images/weapons/" .. weapon .. ".png")
	if BULLET_WEAPONS[weapon] then
		dxDrawText(ammo, x, y, 115 + x, 115 + y, tocolor(225, 225, 225), 1, fonts.body.regular, "right", "bottom")
	end

	x, y = x - 150, y + 5
	dxDrawBorderText(time, x, y, CONTAINER_SIZE.x + x, 0, tocolor(255, 255, 255), 1, font, "right", "top")
	dxDrawBorderText(money, x, y + 30, CONTAINER_SIZE.x + x, 0, tocolor(85, 152, 78), 1, font, "right", "top")

	y = y + 75
	for _, key in ipairs({ "health", "armor" }) do
		local value = store.get(key)
		if value <= 0 then
			return false
		end

		local r, g, b = 225, 225, 225

		if key == "health" then
			r, g, b = 255, 0, 0
		end

		dxDrawRectangle(x, y, barSize.x, barSize.y, rgba(theme.BLACK))
		dxDrawRectangle(x + 2, y + 2, barSize.x - 4, barSize.y - 4, tocolor(r, g, b, 100))
		dxDrawRectangle(x + 2 + (barSize.x - 4), y + 2, -(barSize.x - 4) * value / 100, barSize.y - 4, tocolor(r, g, b))

		y = y + barSize.y + 5
	end
end, {
	name = "Trilogy",
})
