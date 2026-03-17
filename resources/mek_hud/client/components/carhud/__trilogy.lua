createHudComponent("carhud/triloy", function()
	local occupiedVehicle = localPlayer:getOccupiedVehicle()
	if not occupiedVehicle then
		return
	end

	local speed = math.floor(exports.mek_global:getVehicleVelocity(occupiedVehicle) or 0)
	local fuel = math.floor(occupiedVehicle:getData("fuel")) or 0
	local odometer = math.floor(occupiedVehicle:getData("odometer") or 0)

	dxDrawBorderText(
		"Hız: " .. speed .. " km/h\nYakıt: " .. fuel .. "%" .. "\nKilometre: " .. odometer .. " km",
		screenSize.x - PADDING * 3,
		0,
		screenSize.x - PADDING * 3,
		screenSize.y,
		tocolor(225, 225, 225),
		1,
		fonts.h5.bold,
		"right",
		"center"
	)
end, {
	name = "Trilogy",
})
