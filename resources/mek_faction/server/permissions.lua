memberPermissions = {
	[1] = { "add_member", "Üye Davet Et" },
	[2] = { "del_member", "Üye At" },
	[3] = { "modify_ranks", "Rütbeleri, İzinleri ve Maaşları Düzenleme" },
	[4] = { "modify_faction_note", "Birlik Notunu Düzenleme" },
	[5] = { "modify_factionl_note", "Birlik Lider Notunu Düzenleme" },
	[6] = { "respawn_vehs", "Araçları Yenileme" },
	[7] = { "change_member_rank", "Üye Rütbesi Düzenleme" },
	[8] = { "manage_interiors", "Birlik Mülklerine Erişme" },
	[9] = { "manage_bank", "Birlik Kasası Yönetimi" },
	[10] = { "toggle_chat", "Birlik Sohbeti Kapatma" },
	[11] = { "modify_leader_note", "Lider Notu Düzenleme" },
	[12] = { "edit_motd", "Alt Mesaj Düzenleme" },
	[13] = { "use_fl", "/fl Kullanımı" },
	[14] = { "modify_duty_settings", "Görev Ayarları Düzenleme" },
	[15] = { "set_member_duty", "Üye Görevleri Ayarlama" },
}

function hasMemberPermissionTo(player, factionID, action)
	if not player or not action or not factionID then
		return false
	end

	if
		not isElement(player)
		or getElementType(player) ~= "player"
		or type(action) ~= "string"
		or type(factionID) ~= "number"
	then
		return false
	end

	local factionID = tonumber(factionID)
	local rankID = 0
	local faction = getElementData(player, "faction")

	for i, v in pairs(faction) do
		if i == factionID then
			rankID = tonumber(v.rank)
		end
	end

	local perm = FactionRanks[rankID]["permissions"] or ""
	if perm ~= true then
		local perProfile = split(perm, ",")
		for i, v in ipairs(perProfile) do
			v = tonumber(v)
			if memberPermissions[v][1] == action then
				return true
			end
		end
	end

	return false
end

function getAllRankPermissions(rankID, ignoreLeader)
	if not rankID or type(rankID) ~= "number" then
		return memberPermissions
	end

	local isLeader = getFactionRankData(rankID, "isLeader")
	if isLeader == 1 then
		local perms = {}
		for i, perm in ipairs(memberPermissions) do
			if ignoreLeader and not perm[3] then
				table.insert(perms, i)
			elseif not ignoreLeader then
				table.insert(perms, i)
			end
		end
		return perms
	end

	local perm = getFactionRankData(rankID, "permissions") or ""
	local perProfile = split(perm, ",")

	for i, v in ipairs(perProfile) do
		perProfile[i] = tonumber(v)
	end

	return perProfile
end

function getFactionPermissions(factionID)
	if not factionID or type(factionID) ~= "number" then
		return memberPermissions
	end

	local theTeam = getFactionFromID(factionID)
	local factionType = getElementData(theTeam, "type")

	if theTeam then
		local perms = {}
		for i, perm in ipairs(memberPermissions) do
			table.insert(perms, { perm[1], perm[2] })
			if (i == 16 or i == 17) and factionType <= 1 then
				table.remove(perms, #perms)
			elseif i == 18 and factionID ~= 4 then
				table.remove(perms, #perms)
			end
		end
		return perms
	end
end

function getDefaultPermissionSet(permissions)
	if not permissions or type(permissions) ~= "string" then
		return false
	end

	local permTable = {}
	if permissions == "*" then
		for i = 1, #memberPermissions do
			table.insert(permTable, i)
		end
		return permTable
	elseif permissions == "Üye Davet Et" then
		return {}
	end
end

function setAllRankPermissions(rankID, permTable, newWage, factionID)
	if not rankID or not permTable then
		return false
	end

	if type(rankID) ~= "number" or type(permTable) ~= "table" then
		return false
	end

	local theTeam = getFactionFromID(factionID)
	local factionWages = getElementData(theTeam, "wages")

	table.sort(permTable)
	permTable = table.concat(permTable, ",")

	dbExec(
		exports.mek_mysql:getConnection(),
		"UPDATE `faction_ranks` SET `permissions` = ?, `wage` = ? WHERE `id` = ?",
		permTable,
		newWage,
		rankID
	)
	FactionRanks[rankID]["permissions"] = permTable
	FactionRanks[rankID]["wage"] = newWage
	factionWages[rankID] = newWage
	setElementData(theTeam, "wages", factionWages)
	setTimer(function()
		triggerClientEvent(root, "faction.cacheRanks", root, FactionRanks)
	end, 1000, 1)
	return true
end
