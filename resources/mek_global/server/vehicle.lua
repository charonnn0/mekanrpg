function canPlayerBuyVehicle(player)
	if not isElement(player) then
		return false, "Element bulunamadı."
	end

	if not getElementData(player, "logged") then
		return false, "Oyuncu giriş yapmamış."
	end

	local playerDBID = getElementData(player, "dbid")
	local maxVehicles = tonumber(getElementData(player, "max_vehicles") or 0)

	local queryHandle = dbQuery(
		exports.mek_mysql:getConnection(),
		"SELECT COUNT(*) AS vehicle_count FROM vehicles WHERE owner = ? AND deleted = 0",
		playerDBID
	)
	local result, rows = dbPoll(queryHandle, -1)

	dbFree(queryHandle)

	if result and rows > 0 then
		local vehicleCount = tonumber(result[1].vehicle_count)
		if vehicleCount < maxVehicles then
			return true
		else
			return false,
				"Maksimum araç sayısına ulaştınız. Daha fazla araç alabilmek için araç slotu satın almanız gerekiyor."
		end
	else
		return false, "Veritabanı hatası veya araç bulunamadı."
	end
end
