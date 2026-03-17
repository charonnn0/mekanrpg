local skullSize = {
	x = 32,
	y = 32,
}

local skullPosition = {
	x = screenSize.x / 2 - skullSize.x / 2,
	y = screenSize.y - skullSize.y - 10,
}

function renderSkull()
	local store = useStore("hud")
	local injury = store.get("injury")

	if not injury then
		return
	end

	dxDrawImage(skullPosition.x, skullPosition.y, skullSize.x, skullSize.y, "public/images/hud/native/skull.png")
end
