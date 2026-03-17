local memberPermissions = {
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

function hasMemberPermissionTo(player, fID, action)
	if not player or not action or not fID then
		return false
	end

	if not isElement(player) or getElementType(player) ~= "player" or type(action) ~= "string" then
		return false
	end

	local fID = tonumber(fID)
	local rankID = 0
	local faction = getElementData(player, "faction")

	for i, v in pairs(faction) do
		if i == fID then
			rankID = tonumber(v.rank)
		end
	end

	local perm = factionRanks[rankID]["permissions"] or ""
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
	elseif permissions == "Yeni Üye" then
		return {}
	end
end
