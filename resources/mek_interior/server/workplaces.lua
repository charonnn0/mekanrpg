local function getInteriorWorkplaceData(interior, includeInactive)
	if not isElement(interior) then
		return nil
	end

	local status = getElementData(interior, "status") or {}
	local settings = getElementData(interior, "settings") or {}

	-- Sadece işletme tipi veya işyeri flag'i olanları al
	local isBusinessType = status.type == 1
	local isWorkplace = settings.isWorkplace == 1 or settings.isWorkplace == true or settings.isWorkplace == "1"

	if not isBusinessType and not isWorkplace then
		return nil
	end

	local id = getElementData(interior, "dbid") or 0
	if not id or id <= 0 then
		return nil
	end

	local name = getElementData(interior, "name") or "Bilinmiyor"

	-- Aktif / pasif
	local active = settings.workplaceActive == 1 or settings.workplaceActive == true or settings.workplaceActive == "1"
	if not active and not includeInactive then
		-- Pasif işyerlerini normal listede gösterme
		return nil
	end

	-- Giriş ücreti
	local entrance = getElementData(interior, "entrance") or {}
	local fee = entrance.fee or entrance[7] or 0

	-- Çalışma saatleri
	local openTime = settings.workplaceOpenTime or "20:00"
	local closeTime = settings.workplaceCloseTime or "00:00"

	-- Logo / banner URL
	local logoUrl = settings.workplaceLogoUrl or ""
	local bannerUrl = settings.workplaceBannerUrl or ""

	-- Sahip bilgisi
	local ownerIdRaw = status.owner
	local ownerId = tonumber(ownerIdRaw) or 0
	local ownerName = "Hiçbiri"
	local ownerOnline = false
	if ownerId > 0 then
		ownerName = exports.mek_cache:getCharacterName(ownerId) or "Bilinmiyor"
		local ownerPlayer = exports.mek_cache:getPlayerFromCharacterID(ownerId)
		ownerOnline = isElement(ownerPlayer)
	end

	return {
		id = id,
		name = name,
		active = active,
		fee = fee,
		openTime = openTime,
		closeTime = closeTime,
		logoUrl = logoUrl,
		bannerUrl = bannerUrl,
		ownerId = ownerId,
		ownerName = ownerName,
		ownerOnline = ownerOnline,
	}
end

local function buildActiveWorkplacesList()
	local result = {}

	for _, interior in ipairs(exports.mek_pool:getPoolElementsByType("interior")) do
		local data = getInteriorWorkplaceData(interior, false)
		if data then
			table.insert(result, data)
		end
	end

	return result
end

local function buildAdminWorkplacesList()
	local result = {}

	for _, interior in ipairs(exports.mek_pool:getPoolElementsByType("interior")) do
		local data = getInteriorWorkplaceData(interior, true)
		if data then
			table.insert(result, data)
		end
	end

	return result
end

-- /aktifisyerleri komutu
addCommandHandler("aktifisyerleri", function(player)
	if not isElement(player) or getElementType(player) ~= "player" then
		return
	end

	local list = buildActiveWorkplacesList()

	triggerClientEvent(player, "workplace.showActiveList", player, list)
end)

-- /aktifisyerlerik - admin paneli (aktif/pasif, sahip bilgisi vb.)
addCommandHandler("aktifisyerlerik", function(player)
	if not isElement(player) or getElementType(player) ~= "player" then
		return
	end

	if not exports.mek_integration:isPlayerTrialAdmin(player) and not exports.mek_integration:isPlayerManager(player) then
		outputChatBox("[!]#FFFFFF Bu komutu sadece yetkililer kullanabilir.", player, 255, 0, 0, true)
		return
	end

	local list = buildAdminWorkplacesList()

	triggerClientEvent(player, "workplace.showAdminList", player, list)
end)

-- Admin panelinden işyeri aktif/pasif toggle
addEvent("workplace.adminToggle", true)
addEventHandler("workplace.adminToggle", root, function(intID, newState)
	if not client or getElementType(client) ~= "player" then
		return
	end

	if not exports.mek_integration:isPlayerTrialAdmin(client) and not exports.mek_integration:isPlayerManager(client) then
		return
	end

	local id = tonumber(intID)
	if not id or id <= 0 then
		return
	end

	local interior = exports.mek_pool:getElementByID("interior", id)
	if not interior then
		return
	end

	local settings = getElementData(interior, "settings") or {}

	local active = newState and true or false
	settings.workplaceActive = active and 1 or 0

	-- DB'ye kaydet
	dbExec(
		exports.mek_mysql:getConnection(),
		"UPDATE `interiors` SET `settings` = ? WHERE `id` = ?",
		toJSON(settings),
		id
	)

	setElementData(interior, "settings", settings)

	-- Admin listesi yeniden gönder
	local list = buildAdminWorkplacesList()
	triggerClientEvent(client, "workplace.showAdminList", client, list)
end)

-- Konuma git isteği (aktif işyerleri panelinden)
addEvent("workplace.goto", true)
addEventHandler("workplace.goto", root, function(intID)
	if not client or getElementType(client) ~= "player" then
		return
	end

	local id = tonumber(intID)
	if not id or id <= 0 then
		return
	end

	-- Var olan /mgps mantığını kullan
	if type(findInteriorGPS) == "function" then
		findInteriorGPS(client, "mgps", id)
	end
end)


