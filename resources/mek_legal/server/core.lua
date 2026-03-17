function removeTazerAnimation(thePlayer)
	if isElement(thePlayer) and getElementType(thePlayer) == "player" then
		setPedAnimation(thePlayer)
		toggleAllControls(thePlayer, true, true, true)
	end
end

addCommandHandler("tazerkaldir", function(thePlayer, commandName, targetPlayer)
	if
		not exports.mek_faction:isPlayerInFaction(thePlayer, { 1, 3 })
		and not exports.mek_integration:isPlayerManager(thePlayer)
	then
		outputChatBox("[!]#FFFFFF Bu işlemi yalnızca legal birlik üyeleri yapabilir.", thePlayer, 255, 0, 0, true)
		return
	end

	if not targetPlayer then
		outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID]", thePlayer, 255, 194, 14)
		return
	end

	local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
	if not targetPlayer then
		return
	end

	local px, py, pz = getElementPosition(thePlayer)
	local tx, ty, tz = getElementPosition(targetPlayer)
	local distance = getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz)

	if distance > 10 and not exports.mek_integration:isPlayerManager(thePlayer) then
		outputChatBox(
			"[!]#FFFFFF " .. targetPlayerName .. " isimli kişiye yeterince yakın değilsiniz.",
			thePlayer,
			255,
			0,
			0,
			true
		)
		return
	end

	if getElementData(targetPlayer, "tazed") then
		removeTazerAnimation(targetPlayer)
		setElementData(targetPlayer, "tazed", false)

		outputChatBox(
			"[!]#FFFFFF " .. targetPlayerName .. " isimli kişinin tazer etkisi kaldırıldı.",
			thePlayer,
			0,
			255,
			0,
			true
		)
		outputChatBox(
			"[!]#FFFFFF " .. getPlayerName(thePlayer):gsub("_", " ") .. " isimli kişi üzerinizdeki tazer etkisini kaldırıldı.",
			targetPlayer,
			0,
			255,
			0,
			true
		)
	else
		outputChatBox("[!]#FFFFFF " .. targetPlayerName .. " isimli kişi tazerlenmemiş.", thePlayer, 255, 0, 0, true)
	end
end, false, false)

addCommandHandler("aracat", function(thePlayer, commandName, action, targetPlayer, seatID)
	if not action or not targetPlayer then
		outputChatBox(
			"Kullanım: /" .. commandName .. " [bindir/at] [Karakter Adı / ID] [Koltuk ID]",
			thePlayer,
			255,
			194,
			14
		)
		outputChatBox(">> Bindirirken Koltuk ID zorunludur. Örn: /aracat bindir 123 1", thePlayer, 255, 194, 14)
		outputChatBox(">> Atarken Koltuk ID gerekli değildir. Örn: /aracat at 123", thePlayer, 255, 194, 14)
		return
	end

	local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
	if not targetPlayer then
		return
	end

	local theVehicle, targetSeatID, numericSeatID
	local actionType = string.lower(action)

	if actionType == "bindir" then
		if not exports.mek_faction:isPlayerInFaction(thePlayer, { 1, 2, 3, 4 }) then
			outputChatBox(
				"[!]#FFFFFF Bu işlemi yalnızca legal birlik üyeleri yapabilir.",
				thePlayer,
				255,
				0,
				0,
				true
			)
			return
		end

		if not seatID then
			outputChatBox(
				"Kullanım: /" .. commandName .. " bindir [Karakter Adı / ID] [Koltuk ID]",
				thePlayer,
				255,
				194,
				14
			)
			outputChatBox(
				">> Koltuk ID'leri: 0 (Sürücü), 1 (Ön Yolcu), 2 (Sol Arka), 3 (Sağ Arka)",
				thePlayer,
				255,
				194,
				14
			)
			return
		end

		numericSeatID = tonumber(seatID)
		if not numericSeatID or numericSeatID < 0 or numericSeatID > 3 then
			outputChatBox(
				"[!]#FFFFFF Geçersiz koltuk ID'si. Geçerli ID'ler 0, 1, 2, 3'tür.",
				thePlayer,
				255,
				0,
				0,
				true
			)
			outputChatBox(
				">> Koltuk ID'leri: 0 (Sürücü), 1 (Ön Yolcu), 2 (Sol Arka), 3 (Sağ Arka)",
				thePlayer,
				255,
				194,
				14
			)
			return
		end
	end

	local lastVehicleID = getElementData(thePlayer, "last_vehicle_id")
	if not lastVehicleID then
		outputChatBox("[!]#FFFFFF Son zamanlarda herhangi bir araca binmediniz.", thePlayer, 255, 0, 0, true)
		return
	end

	theVehicle = exports.mek_pool:getElementByID("vehicle", lastVehicleID)
	if not isElement(theVehicle) or getElementType(theVehicle) ~= "vehicle" then
		outputChatBox(
			"[!]#FFFFFF Son bindiğiniz araç artık geçerli değil veya mevcut değil.",
			thePlayer,
			255,
			0,
			0,
			true
		)
		return
	end

	local playerX, playerY, playerZ = getElementPosition(thePlayer)
	local targetX, targetY, targetZ = getElementPosition(targetPlayer)
	local vehicleX, vehicleY, vehicleZ = getElementPosition(theVehicle)

	local distanceToTarget = getDistanceBetweenPoints3D(playerX, playerY, playerZ, targetX, targetY, targetZ)
	local targetToVehicleDistance = getDistanceBetweenPoints3D(targetX, targetY, targetZ, vehicleX, vehicleY, vehicleZ)

	local MAX_DISTANCE = 10

	if distanceToTarget > MAX_DISTANCE then
		outputChatBox(
			"[!]#FFFFFF " .. targetPlayerName .. " isimli kişiye yeterince yakın değilsiniz.",
			thePlayer,
			255,
			0,
			0,
			true
		)
		return
	end

	if actionType == "bindir" then
		if not exports.mek_faction:isPlayerInFaction(thePlayer, { 1, 2, 3, 4 }) then
			outputChatBox(
				"[!]#FFFFFF Bu işlemi yalnızca legal birlik üyeleri yapabilir.",
				thePlayer,
				255,
				0,
				0,
				true
			)
			return
		end

		if targetToVehicleDistance > MAX_DISTANCE then
			outputChatBox(
				"[!]#FFFFFF " .. targetPlayerName .. " isimli kişi son bindiğiniz araca çok uzak.",
				thePlayer,
				255,
				0,
				0,
				true
			)
			return
		end

		if getVehicleOccupant(theVehicle, numericSeatID) then
			outputChatBox("[!]#FFFFFF Hedef koltuk zaten dolu.", thePlayer, 255, 0, 0, true)
			return
		end

		warpPedIntoVehicle(targetPlayer, theVehicle, numericSeatID)
		outputChatBox(
			"[!]#FFFFFF "
				.. targetPlayerName
				.. " isimli kişiyi #"
				.. lastVehicleID
				.. " ID'li araca (koltuk: "
				.. numericSeatID
				.. ") bindirdiniz.",
			thePlayer,
			0,
			255,
			0,
			true
		)
		outputChatBox(
			"[!]#FFFFFF "
				.. getPlayerName(thePlayer):gsub("_", " ")
				.. " isimli kişi tarafından #"
				.. lastVehicleID
				.. " ID'li araca (koltuk: "
				.. numericSeatID
				.. ") bindirildiniz.",
			targetPlayer,
			0,
			255,
			0,
			true
		)
	elseif actionType == "at" then
		local occupiedVehicle = getPedOccupiedVehicle(targetPlayer)
		if not occupiedVehicle or occupiedVehicle ~= theVehicle then
			outputChatBox(
				"[!]#FFFFFF " .. targetPlayerName .. " isimli kişi en son bindiğiniz araçta değil.",
				thePlayer,
				255,
				0,
				0,
				true
			)
			return
		end

		removePedFromVehicle(targetPlayer)
		outputChatBox(
			"[!]#FFFFFF "
				.. targetPlayerName
				.. " isimli kişiyi #"
				.. lastVehicleID
				.. " ID'li araçtan çıkardınız.",
			thePlayer,
			0,
			255,
			0,
			true
		)
		outputChatBox(
			"[!]#FFFFFF "
				.. getPlayerName(thePlayer):gsub("_", " ")
				.. " isimli kişi tarafından #"
				.. lastVehicleID
				.. " ID'li araçtan çıkarıldınız.",
			targetPlayer,
			0,
			255,
			0,
			true
		)
	else
		outputChatBox(
			"Kullanım: /" .. commandName .. " [bindir/at] [Karakter Adı / ID] [Koltuk ID]",
			thePlayer,
			255,
			194,
			14
		)
		outputChatBox(">> Bindirirken Koltuk ID zorunludur. Örn: /aracat bindir 123 1", thePlayer, 255, 194, 14)
		outputChatBox(">> Atarken Koltuk ID gerekli değildir. Örn: /aracat at 123", thePlayer, 255, 194, 14)
	end
end, false, false)

addCommandHandler("gorevde", function(thePlayer)
	local onlineFactions = {
		[1] = 0,
		[2] = 0,
		[3] = 0,
		[4] = 0,
	}

	for i, player in ipairs(getElementsByType("player")) do
		if getElementData(player, "logged") then
			local faction = getElementData(player, "faction")
			if onlineFactions[faction] ~= nil then
				onlineFactions[faction] = onlineFactions[faction] + 1
			end
		end
	end

	local message = string.format(
		"[!]#FFFFFF Görevdeki: İEM: %d | İŞH: %d | JGK: %d | İBB: %d",
		onlineFactions[1],
		onlineFactions[2],
		onlineFactions[3],
		onlineFactions[4]
	)

	outputChatBox(message, thePlayer, 87, 52, 32, true)
end, false, false)

addCommandHandler("cezakes", function(thePlayer, commandName, amount, ...)
	if not exports.mek_faction:isPlayerInFaction(thePlayer, { 1, 3 }) then
		outputChatBox("[!]#FFFFFF Bu işlemi yalnızca legal birlik üyeleri yapabilir.", thePlayer, 255, 0, 0, true)
		return
	end

	local amount = tonumber(amount)
	local plate = table.concat({ ... }, " ")

	if not amount or amount <= 0 then
		outputChatBox("Kullanım: /" .. commandName .. " [Ceza Tutarı] [Plaka]", thePlayer, 255, 194, 14)
		if amount and amount <= 0 then
			outputChatBox(
				"[!]#FFFFFF Lütfen geçerli ve pozitif bir ceza tutarı giriniz.",
				thePlayer,
				255,
				0,
				0,
				true
			)
		end
		return
	end

	if not plate or plate == "" then
		outputChatBox("Kullanım: /" .. commandName .. " [Ceza Tutarı] [Plaka]", thePlayer, 255, 194, 14)
		return
	end

	local foundVehicle = nil
	for i, vehicle in ipairs(exports.mek_pool:getPoolElementsByType("vehicle")) do
		if getElementData(vehicle, "plate") == plate then
			foundVehicle = vehicle
			break
		end
	end

	if not foundVehicle then
		outputChatBox("[!]#FFFFFF Bu plakalı araç bulunamadı.", thePlayer, 255, 0, 0, true)
		return
	end

	local px, py, pz = getElementPosition(thePlayer)
	local vx, vy, vz = getElementPosition(foundVehicle)
	local distance = getDistanceBetweenPoints3D(px, py, pz, vx, vy, vz)

	if distance > 10 then
		outputChatBox(
			"[!]#FFFFFF '" .. getElementData(foundVehicle, "plate") .. "' plakalı araca yeterince yakın değilsiniz.",
			thePlayer,
			255,
			0,
			0,
			true
		)
		return
	end

	local dbid = getElementData(foundVehicle, "dbid")
	if not dbid or dbid <= 0 then
		outputChatBox("[!]#FFFFFF Bu araca ceza kesilemez.", thePlayer, 255, 0, 0, true)
		return
	end

	local currentFines = getElementData(foundVehicle, "fines") or 0
	local newFines = currentFines + amount

	if dbExec(exports.mek_mysql:getConnection(), "UPDATE vehicles SET fines = ? WHERE id = ?", newFines, dbid) then
		setElementData(foundVehicle, "fines", newFines)

		exports.mek_global:sendLocalMeAction(
			thePlayer,
			"ceza makbuzunu aracın camı ile sileceğin arasına sıkıştırır."
		)
		outputChatBox(
			"[!]#FFFFFF '"
				.. plate
				.. "' plakalı araca başarıyla ₺"
				.. exports.mek_global:formatMoney(amount)
				.. " ceza kesildi.",
			thePlayer,
			0,
			255,
			0,
			true
		)
	else
		outputChatBox("[!]#FFFFFF Veritabanı hatası oluştu, ceza kesilemedi.", thePlayer, 255, 0, 0, true)
	end
end, false, false)
