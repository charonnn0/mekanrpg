local font = dxCreateFont(":mek_ui/public/fonts/Pricedown.ttf", 18) or "default"

createHudComponent("carhud/native", function()
	local occupiedVehicle = localPlayer:getOccupiedVehicle()
	if not occupiedVehicle then
		return
	end

	local speed = math.floor(exports.mek_global:getVehicleVelocity(occupiedVehicle) or 0)
	local fuel = math.floor(occupiedVehicle:getData("fuel") or 0) or 0
	local odometer = math.floor(occupiedVehicle:getData("odometer") or 0)

	dxDrawBorderedText(
		2,
		"Hız: #405239"
			.. speed
			.. "#c1c1c1 km/h\n#2f3361Yakıt: #405239"
			.. fuel
			.. "#c1c1c1%"
			.. "\n#2f3361Kilometre: #405239"
			.. odometer
			.. "#c1c1c1 km",
		0,
		0,
		screenSize.x * 0.95,
		screenSize.y * 0.55,
		rgba("#2f3361"),
		1,
		font,
		"right",
		"center",
		false,
		false,
		false,
		true
	)
end, {
	name = "Native",
})
