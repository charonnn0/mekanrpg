function giveBoatLicense()
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	setElementData(source, "boat_license", 1)
	dbExec(
		exports.mek_mysql:getConnection(),
		"UPDATE characters SET boat_license = 1 WHERE id = ?",
		getElementData(source, "dbid")
	)
	exports.mek_infobox:addBox(source, "success", "Tebrikler! Artık suda tam yetkili bir tekne kaptanısın.")
	exports.mek_item:giveItem(source, 155, getPlayerName(source):gsub("_", " "))
	executeCommandHandler("stats", source, getPlayerName(source))
end
addEvent("acceptBoatLicense", true)
addEventHandler("acceptBoatLicense", root, giveBoatLicense)
