local orderArea = createColSphere(-33.798828125, -1120.7197265625, 4.6812515258789, 3)

local weapons = {
	colt45 = {
		id = 22,
		price = 180000,
		dbCode = 1,
	},
	deagle = {
		id = 24,
		price = 240000,
		dbCode = 2,
	},
	uzi = {
		id = 28,
		price = 350000,
		dbCode = 3,
	},
	tec9 = {
		id = 32,
		price = 350000,
		dbCode = 4,
	},
}

local WeaponOrderRepository = {}

function WeaponOrderRepository.getCharacterData(characterID, column)
	local queryHandle =
		dbQuery(exports.mek_mysql:getConnection(), "SELECT ?? FROM characters WHERE id = ?", column, characterID)
	local result = dbPoll(queryHandle, -1)
	return result and result[1] and result[1][column] or nil
end

function WeaponOrderRepository.updateCharacter(characterID, column, value)
	dbExec(
		exports.mek_mysql:getConnection(),
		string.format("UPDATE characters SET %s = ? WHERE id = ?", column),
		value,
		characterID
	)
end

function WeaponOrderRepository.createOrder(weapon, ownerID, givenTime, receiveTime)
	dbExec(
		exports.mek_mysql:getConnection(),
		"INSERT INTO weapon_orders (weapon_code, character_id, given_time, receive_time, status) VALUES (?, ?, ?, ?, 0)",
		weapon.dbCode,
		ownerID,
		givenTime,
		receiveTime
	)
end

function WeaponOrderRepository.deleteOrder(ownerID)
	dbExec(exports.mek_mysql:getConnection(), "DELETE FROM weapon_orders WHERE character_id = ?", ownerID)
end

function WeaponOrderRepository.cacheOrder(weaponLabel, ownerID, givenTime, receiveTime, weaponSerial)
	dbExec(
		exports.mek_mysql:getConnection(),
		"INSERT INTO weapon_orders_cache (weapon_label, character_id, given_time, receive_time, status, weapon_serial) VALUES (?, ?, ?, ?, 1, ?)",
		weaponLabel,
		ownerID,
		givenTime,
		receiveTime,
		weaponSerial
	)
end

function WeaponOrderRepository.getOrder(ownerID)
	local queryHandle = dbQuery(
		exports.mek_mysql:getConnection(),
		"SELECT weapon_code, receive_time FROM weapon_orders WHERE character_id = ?",
		ownerID
	)
	local result = dbPoll(queryHandle, -1)
	return result and result[1] or nil
end

local WeaponOrderService = {}

function WeaponOrderService.createOrder(player, weaponName)
	local faction = getElementData(player, "faction")
	if
		size(faction) <= 0
		and not (exports.mek_faction:isInFactionType(player, 0) or exports.mek_faction:isInFactionType(player, 1))
	then
		outputChatBox(
			"[!]#FFFFFF Çete veya Mafya türüne sahip birlikte olmanız gerekmektedir.",
			player,
			255,
			0,
			0,
			true
		)
		return
	end

	local characterID = getElementData(player, "dbid")
	local hasWeaponOrder = tonumber(WeaponOrderRepository.getCharacterData(characterID, "has_weapon_order"))
	local weaponOrderRights = tonumber(WeaponOrderRepository.getCharacterData(characterID, "weapon_order_rights"))

	if weaponOrderRights <= 0 then
		outputChatBox("[!]#FFFFFF Sipariş verme hakkınız bulunmuyor.", player, 255, 0, 0, true)
		return
	end

	if hasWeaponOrder == 1 then
		outputChatBox("[!]#FFFFFF Zaten mevcutta verilmiş bir siparişiniz var.", player, 255, 0, 0, true)
		outputChatBox("[!]#FFFFFF /silahsiparisal ile kalan süreyi görebilirsiniz.", player, 255, 0, 0, true)
		return
	end

	local weapon = weapons[weaponName]
	if not weapon then
		outputChatBox(
			"[!]#FFFFFF Geçerli bir silah adı giriniz. (colt45, deagle, uzi, tec9)",
			player,
			255,
			0,
			0,
			true
		)
		return
	end

	if not isElementWithinColShape(player, orderArea) then
		outputChatBox("[!]#FFFFFF Silah siparişi verebileceğiniz alanda değilsiniz.", player, 255, 0, 0, true)
		return
	end

	if not exports.mek_global:hasMoney(player, weapon.price) then
		outputChatBox(
			"[!]#FFFFFF Üzerinizde "
				.. getWeaponNameFromID(weapon.id)
				.. " sipariş edebilmek için yeterli para bulunmamaktadır. (₺"
				.. exports.mek_global:formatMoney(weapon.price)
				.. ")",
			player,
			255,
			0,
			0,
			true
		)
		return
	end

	exports.mek_global:takeMoney(player, weapon.price)
	WeaponOrderRepository.updateCharacter(characterID, "weapon_order_rights", weaponOrderRights - 1)
	WeaponOrderRepository.updateCharacter(characterID, "has_weapon_order", 1)

	local now = getRealTime().timestamp
	WeaponOrderRepository.createOrder(weapon, characterID, now, now + 3600)

	outputChatBox(
		"[!]#FFFFFF " .. getWeaponNameFromID(weapon.id) .. " siparişiniz alınmıştır. Teslim süresi: 1 saat.",
		player,
		0,
		255,
		0,
		true
	)
	triggerClientEvent(player, "playSuccess", player)

	exports.mek_global:sendMessageToAdmins(
		"[SİLAH-SİPARİŞ] "
			.. getPlayerName(player):gsub("_", " ")
			.. " isimli oyuncu "
			.. getWeaponNameFromID(weapon.id)
			.. " siparişi verdi."
	)
	exports.mek_logs:addLog(
		"silah-sipariş",
		getPlayerName(player):gsub("_", " ")
			.. " isimli oyuncu "
			.. getWeaponNameFromID(weapon.id)
			.. " siparişi verdi."
	)
end

function WeaponOrderService.deliverOrder(player)
	local faction = getElementData(player, "faction")
	if
		size(faction) <= 0
		and not (exports.mek_faction:isInFactionType(player, 0) or exports.mek_faction:isInFactionType(player, 1))
	then
		outputChatBox(
			"[!]#FFFFFF Çete veya Mafya türüne sahip birlikte olmanız gerekmektedir.",
			player,
			255,
			0,
			0,
			true
		)
		return
	end

	local characterID = getElementData(player, "dbid")
	local order = WeaponOrderRepository.getOrder(characterID)

	if not order then
		outputChatBox("[!]#FFFFFF Bekleyen siparişiniz bulunmamaktadır.", player, 255, 0, 0, true)
		return
	end

	local weapon = nil
	for _, v in pairs(weapons) do
		if v.dbCode == tonumber(order.weapon_code) then
			weapon = v
			break
		end
	end

	if not weapon then
		return
	end

	local now = getRealTime().timestamp
	local remaining = order.receive_time - now

	if remaining > 0 then
		outputChatBox(
			"[!]#FFFFFF Siparişinizi almak için " .. math.ceil(remaining / 60) .. " dakika beklemelisiniz.",
			player,
			255,
			0,
			0,
			true
		)
		return
	end

	if not isElementWithinColShape(player, orderArea) then
		outputChatBox(
			"[!]#FFFFFF Siparişinizi teslim almak için sipariş alanına gelmelisiniz.",
			player,
			255,
			0,
			0,
			true
		)
		return
	end

	local weaponSerial = exports.mek_global:createWeaponSerial(1, characterID, characterID)
	local itemValue = weapon.id .. ":" .. weaponSerial .. ":" .. getWeaponNameFromID(weapon.id) .. " (S):0:3"

	if not exports.mek_item:hasSpaceForItem(player, 115, itemValue) then
		outputChatBox("[!]#FFFFFF Envanterinizde yeterli alan yok.", player, 255, 0, 0, true)
		return
	end

	exports.mek_item:giveItem(player, 115, itemValue)

	WeaponOrderRepository.updateCharacter(characterID, "has_weapon_order", 0)
	WeaponOrderRepository.cacheOrder(getWeaponNameFromID(weapon.id), characterID, now, order.receive_time, weaponSerial)
	WeaponOrderRepository.deleteOrder(characterID)

	outputChatBox(
		"[!]#FFFFFF " .. getWeaponNameFromID(weapon.id) .. " siparişiniz teslim edilmiştir.",
		player,
		0,
		0,
		255,
		true
	)
	triggerClientEvent(player, "playSuccess", player)

	exports.mek_global:sendMessageToAdmins(
		"[SİLAH-SİPARİŞ] "
			.. getPlayerName(player):gsub("_", " ")
			.. " isimli oyuncu "
			.. getWeaponNameFromID(weapon.id)
			.. " siparişini teslim aldı."
	)
	exports.mek_logs:addLog(
		"silah-sipariş",
		getPlayerName(player):gsub("_", " ")
			.. " isimli oyuncu "
			.. getWeaponNameFromID(weapon.id)
			.. " siparişini teslim aldı."
	)
end

addCommandHandler("silahsiparishakkim", function(player)
	local faction = getElementData(player, "faction")
	if
		size(faction) <= 0
		and not (exports.mek_faction:isInFactionType(player, 0) or exports.mek_faction:isInFactionType(player, 1))
	then
		outputChatBox(
			"[!]#FFFFFF Çete veya Mafya türüne sahip birlikte olmanız gerekmektedir.",
			player,
			255,
			0,
			0,
			true
		)
		return
	end

	local characterID = getElementData(player, "dbid")
	local weaponOrderRights = tonumber(WeaponOrderRepository.getCharacterData(characterID, "weapon_order_rights"))

	outputChatBox(
		"[!]#FFFFFF Şu anda " .. weaponOrderRights .. " adet silah sipariş hakkınız var.",
		player,
		0,
		0,
		255,
		true
	)
end, false, false)

addCommandHandler("silahsipariset", function(player, _, weaponName)
	WeaponOrderService.createOrder(player, weaponName)
end, false, false)

addCommandHandler("silahsiparisal", function(player)
	WeaponOrderService.deliverOrder(player)
end, false, false)

addCommandHandler("silahsiparisfiyat", function(player, _, weaponName)
	if not weaponName or weaponName == "" then
		outputChatBox("[!]#FFFFFF Mevcut silahların fiyat listesi:", player, 0, 0, 255, true)
		for name, weapon in pairs(weapons) do
			outputChatBox(
				">>#FFFFFF "
					.. getWeaponNameFromID(weapon.id)
					.. " ("
					.. name
					.. "): ₺"
					.. exports.mek_global:formatMoney(weapon.price),
				player,
				0,
				255,
				0,
				true
			)
		end
	else
		local weapon = weapons[weaponName]
		if not weapon then
			outputChatBox(
				"[!]#FFFFFF Geçerli bir silah adı giriniz. (colt45, deagle, uzi, tec9)",
				player,
				255,
				0,
				0,
				true
			)
			return
		end
		outputChatBox(
			"[!]#FFFFFF "
				.. getWeaponNameFromID(weapon.id)
				.. " ("
				.. weaponName
				.. ") fiyatı: ₺"
				.. exports.mek_global:formatMoney(weapon.price),
			player,
			0,
			255,
			0,
			true
		)
	end
end, false, false)

addEventHandler("onElementDataChange", root, function(dataName, oldValue)
	if dataName ~= "hours_played" then
		return
	end

	if not isElement(source) or getElementType(source) ~= "player" then
		return
	end

	local characterID = getElementData(source, "dbid")
	if not characterID then
		return
	end

	local hoursPlayed = tonumber(getElementData(source, "hours_played")) or 0
	if hoursPlayed > 0 and hoursPlayed % 50 == 0 then
		local weaponOrderRights = tonumber(WeaponOrderRepository.getCharacterData(characterID, "weapon_order_rights"))
		WeaponOrderRepository.updateCharacter(characterID, "weapon_order_rights", weaponOrderRights + 1)
		outputChatBox("[!]#FFFFFF Tebrikler! 1 adet silah sipariş hakkı kazandınız.", source, 0, 0, 255, true)
		exports.mek_logs:addLog(
			"silah-sipariş",
			getPlayerName(source):gsub("_", " ")
				.. " isimli oyuncu 50 saat doldurdu ve +1 sipariş hakkı kazandı. (Toplam: "
				.. (weaponOrderRights + 1)
				.. ")"
		)
	end
end)
