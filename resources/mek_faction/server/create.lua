local allowedPos = {x = 1380.6201171875, y = -1088.9091796875, z = 27.384355545044}

function createFactionCommand(thePlayer, commandName, ...)
    local factionInfo = getElementData(thePlayer, "faction") or {}
    if size(factionInfo) > 0 then
        exports.mek_infobox:addBox(thePlayer, "error", "Zaten birliğiniz var.")
        return
    end

    if getDistanceBetweenPoints3D(allowedPos.x, allowedPos.y, allowedPos.z, getElementPosition(thePlayer)) > 5 then
        exports.mek_infobox:addBox(thePlayer, "error", "Birlik kurmak için gerekli yerde değilsiniz.")
        return
    end

    local args = { ... }
    if #args == 0 then
        -- Argüman verilmediyse eski davranış: GUI aç
        triggerClientEvent(thePlayer, "faction.create.gui", thePlayer)
        return
    end

    -- Admin panelindeki oluşturma akışı gibi: doğrudan sunucuda oluştur
    -- Kullanım: /birlikkur [Birlik Adı] [TipID]
    -- Birlik adı boşluk içerebilir; son argüman sayısalsa tip kabul edilir, değilse varsayılan 5 kullanılır
    local maybeType = tonumber(args[#args])
    local typeId = maybeType or 5
    if maybeType then
        table.remove(args, #args)
    end
    local name = table.concat(args, " ")

    if not name or name == "" or string.len(name) < 3 then
        exports.mek_infobox:addBox(thePlayer, "error", "Kullanım: /" .. commandName .. " [Birlik Adı] [TipID]")
        return
    end

    local factionData = {
        name = name,
        type = typeId,
        max_interiors = 20,
        max_vehicles = 40,
        before_tax_value = 0,
        free_wage_amount = 0,
    }

    -- Aynı event akışını kullan (client=nil olduğu için güvenlik kontrolünden geçer)
    triggerEvent("factions.create", thePlayer, factionData)
end
addCommandHandler("birlikkur", createFactionCommand, false, false)

local factionCreateCooldowns = {}

addEvent("factions.create", true)
addEventHandler("factions.create", root, function(data)
	-- Sunucu-tarafı çağrı (command'dan) ise source'u kullan, değilse client'ı kullan
	local thePlayer = client or source
	
	-- Client-tarafı çağrıda güvenlik kontrolü
	if client then
		if source and client ~= source then
			exports.mek_sac:banForEventAbuse(client, eventName)
			return
		end
	end
	
	-- Geçerli oyuncu kontrolü
	if not thePlayer or not isElement(thePlayer) or getElementType(thePlayer) ~= "player" then
		return
	end

	if getDistanceBetweenPoints3D(allowedPos.x, allowedPos.y, allowedPos.z, getElementPosition(thePlayer)) > 5 then
		exports.mek_infobox:addBox(thePlayer, "error", "Birlik kurmak için belediye binasında olmalısınız.")
		return
	end
	
	-- Cooldown kontrolü (60 saniye)
	local serial = getPlayerSerial(thePlayer)
	local now = getTickCount()
	if factionCreateCooldowns[serial] and (now - factionCreateCooldowns[serial]) < 60000 then
		local remaining = math.ceil((60000 - (now - factionCreateCooldowns[serial])) / 1000)
		exports.mek_infobox:addBox(thePlayer, "error", "Birlik oluşturmak için " .. remaining .. " saniye beklemelisiniz.")
		return
	end

	local qh = dbQuery(exports.mek_mysql:getConnection(), "SELECT id FROM factions WHERE name=? LIMIT 1", data.name)
	local res, nums = dbPoll(qh, 10000)
	if nums > 0 then
		exports.mek_infobox:addBox(thePlayer, "error", "Birlik adı daha önce alınmış.")
		return
	end

	local factionInfo = getElementData(thePlayer, "faction") or {}
	if size(factionInfo) > 0 then
		exports.mek_infobox:addBox(thePlayer, "error", "Zaten birliğiniz var.")
		return
	end
	
	-- Cooldown'u ayarla
	factionCreateCooldowns[serial] = now

	local qh2 = dbQuery(
		exports.mek_mysql:getConnection(),
		"INSERT INTO factions SET money='0', motd='Birliğe hoş geldiniz.', note = '', name=?, type=?, max_interiors=?, max_vehicles=?, before_tax_value=?, before_wage_charge=?",
		data.name,
		data.type,
		data.max_interiors,
		data.max_vehicles,
		data.before_tax_value,
		data.free_wage_amount
	)
	local res, nums, id = dbPoll(qh2, 10000)
	if id and tonumber(id) then
		data.id = id
		data.money = 0
		data.motd = "Birliğe hoş geldiniz."
		data.note = ""
		data.fnote = ""
		local theTeam = loadOneFaction(data)
		local rank_order = ""
		local factionRanks = {}
		local factionWages = {}
		RanksByFaction[data.id] = {}

		local perms = {}
		for i, v in ipairs(memberPermissions) do
			table.insert(perms, i)
		end
		local permissions = table.concat(perms, ",")

		for i = 1, 2 do
			if i == 1 then
				local qh3 = dbQuery(
					exports.mek_mysql:getConnection(),
					"INSERT INTO faction_ranks SET faction_id=?, name='Lider Rütbe', permissions=?, isDefault='0', isLeader='1', wage='0'",
					data.id,
					permissions
				)
				local _, _, rid1 = dbPoll(qh3, 10000)
				local rankID = tonumber(rid1)
				FactionRanks[rankID] = {
					name = "Lider Rütbe",
					permissions = permissions,
					isDefault = 0,
					isLeader = 1,
					faction_id = data.id,
				}
				table.insert(RanksByFaction[data.id], rankID)
				factionRanks[rankID] = "Lider Rütbe"
				factionWages[rankID] = 0
				rank_order = rank_order .. rankID .. ","
				dbFree(qh3)
			else
				local qh4 = dbQuery(
					exports.mek_mysql:getConnection(),
					"INSERT INTO faction_ranks SET faction_id=?, name='Varsayılan Rütbe', permissions='', isDefault='1', isLeader='0', wage='0'",
					data.id
				)
				local _, _, rid2 = dbPoll(qh4, 10000)
				local rankID = tonumber(rid2)
				FactionRanks[rankID] = {
					name = "Varsayılan Rütbe",
					permissions = "",
					isDefault = 1,
					isLeader = 0,
					faction_id = data.id,
				}
				table.insert(RanksByFaction[data.id], rankID)
				factionRanks[rankID] = "Varsayılan Rütbe"
				factionWages[rankID] = 0
				rank_order = rank_order .. rankID .. ","
				dbFree(qh4)
			end
		end

		dbExec(
			exports.mek_mysql:getConnection(),
			"UPDATE `factions` SET `rank_order` = ? WHERE `id` = ?",
			rank_order,
			data.id
		)
		setElementData(theTeam, "rank_order", rank_order)
		setElementData(theTeam, "ranks", factionRanks)
		setElementData(theTeam, "wages", factionWages)
		dutyAllow[data.id] = { data.id, name, {} }
		setElementData(resourceRoot, "dutyAllowTable", dutyAllow)
		locations[data.id] = {}
		custom[data.id] = {}
		exports.mek_global:sendMessageToAdmins(
			"[BİRLİK] "
				.. getPlayerName(thePlayer):gsub("_", " ")
				.. " isimli oyuncu '"
				.. data.name
				.. "' birliğini oluşturdu."
		)
		triggerClientEvent(root, "faction.cacheRanks", root, FactionRanks)

		local theRank = getLeaderRank(data.id)
		local theTeam = exports.mek_pool:getElementByID("team", data.id)

		if
			dbExec(
				exports.mek_mysql:getConnection(),
				"INSERT INTO characters_faction SET faction_leader = 1, faction_id = ?, faction_rank = ?, faction_phone = NULL, character_id=?",
				data.id,
				theRank,
				getElementData(thePlayer, "dbid")
			)
		then
			local max = 0
			for id, _ in pairs(factionInfo) do
				if not max then
					max = _.count
				end
				if _.count >= max then
					max = _.count
				end
			end

			factionInfo[data.id] = { rank = theRank, leader = true, phone = nil, perks = {}, count = max + 1 }
			setElementData(thePlayer, "faction", factionInfo)

			triggerEvent("duty.offDuty", thePlayer)

			exports.mek_infobox:addBox(thePlayer, "success", "Birliğiniz başarıyla oluşturuldu.")
		else
			exports.mek_infobox:addBox(thePlayer, "error", "Birlik oluşturma başarısız oldu.")
		end
	else
		exports.mek_infobox:addBox(thePlayer, "error", "Birlik oluşturma başarısız oldu.")
	end
end)
