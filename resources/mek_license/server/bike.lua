function giveBikeLicense()
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	local theVehicle = getPedOccupiedVehicle(source)
	removePedFromVehicle(source)
	if theVehicle then
		respawnVehicle(theVehicle)
		setElementData(theVehicle, "handbrake", true)
		removeElementData(theVehicle, "i:left")
		removeElementData(theVehicle, "i:right")
		setElementFrozen(theVehicle, true)
	end

	setElementData(source, "bike_license", 1)
	dbExec(
		exports.mek_mysql:getConnection(),
		"UPDATE characters SET bike_license = 1 WHERE id = ?",
		getElementData(source, "dbid")
	)
	exports.mek_infobox:addBox(
		source,
		"success",
		"Tebrikler! Motosiklet sınavını geçtiniz ve ehliyetinizi aldınız!"
	)
	exports.mek_item:giveItem(source, 153, getPlayerName(source):gsub("_", " "))
	executeCommandHandler("stats", source, getPlayerName(source))
end
addEvent("acceptBikeLicense", true)
addEventHandler("acceptBikeLicense", root, giveBikeLicense)

addEvent("theoryBikeComplete", true)
addEventHandler("theoryBikeComplete", root, function(skipSQL)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	setElementData(source, "bike_license", 3)

	if not skipSQL then
		dbExec(
			exports.mek_mysql:getConnection(),
			"UPDATE characters SET bike_license = 3 WHERE id = ? ",
			getElementData(source, "dbid")
		)
	end
end)
