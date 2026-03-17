function giveCarLicense()
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

	setElementData(source, "car_license", 1)
	dbExec(
		exports.mek_mysql:getConnection(),
		"UPDATE characters SET car_license = 1 WHERE id = ?",
		getElementData(source, "dbid")
	)
	exports.mek_infobox:addBox(source, "success", "Tebrikler! Araba sınavını geçtiniz ve ehliyetinizi aldınız!")
	exports.mek_item:giveItem(source, 133, getPlayerName(source):gsub("_", " "))
	executeCommandHandler("stats", source, getPlayerName(source))
end
addEvent("acceptCarLicense", true)
addEventHandler("acceptCarLicense", root, giveCarLicense)

function passTheory(skipSQL)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	setElementData(source, "car_license", 3)

	if not skipSQL then
		dbExec(
			exports.mek_mysql:getConnection(),
			"UPDATE characters SET car_license = 3 WHERE id = ?",
			getElementData(source, "dbid")
		)
	end
end
addEvent("theoryComplete", true)
addEventHandler("theoryComplete", root, passTheory)

-- /givelicense komutu - Oyuncu ID'sine göre ehliyet verme
function giveLicenseCommand(player, command, targetPlayerID, licenseType)
	-- Yetki kontrolü (isteğe bağlı - sadece yetkili kişiler kullanabilsin)
	if not exports.mek_integration:isPlayerTrialAdmin(player) then
		exports.mek_infobox:addBox(player, "error", "Bu komutu kullanma yetkiniz yok!")
		return
	end
	
	-- Parametre kontrolü
	if not targetPlayerID or not licenseType then
		exports.mek_infobox:addBox(player, "warning", "Kullanım: /givelicense [OyuncuID] [car/bike/truck]")
		exports.mek_infobox:addBox(player, "info", "Örnek: /givelicense 3 car - 3 ID'li oyuncuya araba ehliyeti verir")
		return
	end
	
	-- ID'yi number'a çevirme
	local targetID = tonumber(targetPlayerID)
	if not targetID then
		exports.mek_infobox:addBox(player, "error", "Geçerli bir oyuncu ID giriniz!")
		return
	end
	
	-- Oyuncuyu ID'ye göre bulma
	local targetPlayer = nil
	for _, v in ipairs(getElementsByType("player")) do
		if getElementData(v, "id") == targetID then
			targetPlayer = v
			break
		end
	end
	
	if not targetPlayer then
		exports.mek_infobox:addBox(player, "error", targetID .. " ID'li oyuncu bulunamadı!")
		return
	end
	
	-- Oyuncunun database ID'sini al
	local dbID = getElementData(targetPlayer, "dbid")
	if not dbID then
		exports.mek_infobox:addBox(player, "error", "Oyuncunun database ID'si bulunamadı!")
		return
	end
	
	-- Ehliyet tipine göre işlem
	licenseType = licenseType:lower()
	
	if licenseType == "car" then
		-- Araba ehliyeti verme
		setElementData(targetPlayer, "car_license", 1)
		dbExec(
			exports.mek_mysql:getConnection(),
			"UPDATE characters SET car_license = 1 WHERE id = ?",
			dbID
		)
		exports.mek_infobox:addBox(targetPlayer, "success", "Yönetici size araba ehliyeti verdi!")
		exports.mek_infobox:addBox(player, "success", targetID .. " ID'li oyuncuya araba ehliyeti verildi!")
		
	elseif licenseType == "bike" then
		-- Motosiklet ehliyeti verme
		setElementData(targetPlayer, "motor_license", 1)
		dbExec(
			exports.mek_mysql:getConnection(),
			"UPDATE characters SET motor_license = 1 WHERE id = ?",
			dbID
		)
		exports.mek_infobox:addBox(targetPlayer, "success", "Yönetici size motosiklet ehliyeti verdi!")
		exports.mek_infobox:addBox(player, "success", targetID .. " ID'li oyuncuya motosiklet ehliyeti verildi!")
		
	elseif licenseType == "truck" then
		-- Kamyon ehliyeti verme
		setElementData(targetPlayer, "truck_license", 1)
		dbExec(
			exports.mek_mysql:getConnection(),
			"UPDATE characters SET truck_license = 1 WHERE id = ?",
			dbID
		)
		exports.mek_infobox:addBox(targetPlayer, "success", "Yönetici size kamyon ehliyeti verdi!")
		exports.mek_infobox:addBox(player, "success", targetID .. " ID'li oyuncuya kamyon ehliyeti verildi!")
		
	else
		exports.mek_infobox:addBox(player, "error", "Geçersiz ehliyet tipi! (car/bike/truck)")
		return
	end
	
	-- İstatistikleri güncelleme
	executeCommandHandler("stats", targetPlayer, getPlayerName(targetPlayer))
end
addCommandHandler("givelicense", giveLicenseCommand)