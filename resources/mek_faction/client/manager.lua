local function togWindow(win, state)
	if win and isElement(win) then
		guiSetEnabled(win, state)
	end
end

local function canEditFaction(thePlayer)
	return exports.mek_integration:isPlayerManager(thePlayer)
end

local fGUI = {
	gridlist = {},
	window = {},
	button = {},
	label = {},
}

local factions_tmp

local function getFactionTableFromID(id, table)
	for _, fact in pairs(table) do
		if fact.id == id then
			return fact
		end
	end
end

function showFactionList(factions)
	factions_tmp = factions

	if not fGUI.window[1] and not isElement(fGUI.window[1]) then
		fGUI.window[1] = guiCreateWindow(115, 175, 800, 600, "Birlik Yöneticisi", false)
		guiWindowSetSizable(fGUI.window[1], false)
		exports.mek_global:centerWindow(fGUI.window[1])
		fGUI.button[1] = guiCreateButton(674, 552, 116, 38, "Kapat", false, fGUI.window[1])
		fGUI.button[2] = guiCreateButton(10, 552, 116, 38, "Birlik Oluştur", false, fGUI.window[1])
		fGUI.button[3] = guiCreateButton(136, 552, 116, 38, "Birliği Düzenle", false, fGUI.window[1])
		fGUI.button[4] = guiCreateButton(262, 552, 116, 38, "Üyeleri Listele", false, fGUI.window[1])
		fGUI.button[5] = guiCreateButton(388, 552, 116, 38, "Birliği Sil", false, fGUI.window[1])
		fGUI.button[6] = guiCreateButton(514, 552, 116, 38, "Yenile", false, fGUI.window[1])
		
		local canEdit = canEditFaction(localPlayer)
		guiSetEnabled(fGUI.button[2], canEdit)
		guiSetEnabled(fGUI.button[3], canEdit)
		guiSetEnabled(fGUI.button[5], canEdit)
		
		addEventHandler("onClientGUIClick", fGUI.window[1], function()
			if source == fGUI.button[1] then
				closeFactionList()
			elseif source == fGUI.button[2] then
				editFaction()
			elseif source == fGUI.button[3] and fGUI.gridlist[1] then
				local row, col = guiGridListGetSelectedItem(fGUI.gridlist[1])
				if row ~= -1 and col ~= -1 then
					local gridID = guiGridListGetItemText(fGUI.gridlist[1], row, 1)
					editFaction(gridID)
				else
					outputChatBox("[!]#FFFFFF Öncelikle listeden bir öğe seçmeniz gerekiyor.", 255, 0, 0, true)
					triggerEvent("errorSound", localPlayer)
				end
			elseif source == fGUI.button[4] then
				local row, col = guiGridListGetSelectedItem(fGUI.gridlist[1])
				if row ~= -1 and col ~= -1 then
					listMember(guiGridListGetItemText(fGUI.gridlist[1], row, 1))
				else
					outputChatBox("[!]#FFFFFF Öncelikle listeden bir öğe seçmeniz gerekiyor.", 255, 0, 0, true)
					triggerEvent("errorSound", localPlayer)
				end
			elseif source == fGUI.button[5] then
				local row, col = guiGridListGetSelectedItem(fGUI.gridlist[1])
				if row ~= -1 and col ~= -1 then
					local gridID = guiGridListGetItemText(fGUI.gridlist[1], row, 1)
					delConfirm(gridID)
				else
					outputChatBox("[!]#FFFFFF Öncelikle listeden bir öğe seçmeniz gerekiyor.", 255, 0, 0, true)
					triggerEvent("errorSound", localPlayer)
				end
			elseif source == fGUI.button[6] then
				showFactionList()
			end
		end)
		addEventHandler("onClientGUIDoubleClick", fGUI.window[1], function()
			if source == fGUI.gridlist[1] then
				local row, col = guiGridListGetSelectedItem(fGUI.gridlist[1])
				if row ~= -1 and col ~= -1 then
					local text = guiGridListGetItemText(fGUI.gridlist[1], row, col)
					if setClipboard(text) then
						triggerEvent("successSound", localPlayer)
						outputChatBox("Kopyalandı: '" .. text .. "'.")
					end
				end
			end
		end)
	end

	if not factions then
		if not fGUI.label[1] then
			if fGUI.gridlist[1] and isElement(fGUI.gridlist[1]) then
				destroyElement(fGUI.gridlist[1])
				fGUI.gridlist[1] = nil
			end
			fGUI.label[1] = guiCreateLabel(0, 0, 1, 1, "Sunucudan bilgi alınıyor...", true, fGUI.window[1])
			guiLabelSetHorizontalAlign(fGUI.label[1], "center")
			guiLabelSetVerticalAlign(fGUI.label[1], "center")
			triggerServerEvent("factions.fetchFactionList", resourceRoot)
			guiSetEnabled(fGUI.window[1], false)
		end
	else
		destroyElement(fGUI.label[1])
		fGUI.label[1] = nil
		fGUI.gridlist[1] = guiCreateGridList(9, 26, 781, 520, false, fGUI.window[1])
		guiGridListSetSelectionMode(fGUI.gridlist[1], 2)
		fGUI.gridlist.colID = guiGridListAddColumn(fGUI.gridlist[1], "ID", 0.08)
		fGUI.gridlist.colName = guiGridListAddColumn(fGUI.gridlist[1], "Birlik İsmi", 0.23)
		fGUI.gridlist.colPlayers = guiGridListAddColumn(fGUI.gridlist[1], "Aktif Üyeleri", 0.1)
		fGUI.gridlist.colType = guiGridListAddColumn(fGUI.gridlist[1], "Tip", 0.1)
		fGUI.gridlist.colInts = guiGridListAddColumn(fGUI.gridlist[1], "Mülkler", 0.07)
		fGUI.gridlist.colVehs = guiGridListAddColumn(fGUI.gridlist[1], "Araçlar", 0.07)
		fGUI.gridlist.colBeforeTax = guiGridListAddColumn(fGUI.gridlist[1], "Vergi Öncesi Tutar", 0.14)
		fGUI.gridlist.colFreeWage = guiGridListAddColumn(fGUI.gridlist[1], "Birlik Tahsil Edilmeden Önce Ücret", 0.20)
		guiSetEnabled(fGUI.window[1], true)

		for _, value in ipairs(factions) do
			local row = guiGridListAddRow(fGUI.gridlist[1])
			guiGridListSetItemText(fGUI.gridlist[1], row, fGUI.gridlist.colID, value.id, false, true)
			guiGridListSetItemData(fGUI.gridlist[1], row, fGUI.gridlist.colID, value.id)
			guiGridListSetItemText(fGUI.gridlist[1], row, fGUI.gridlist.colName, value.name, false, false)
			guiGridListSetItemText(fGUI.gridlist[1], row, fGUI.gridlist.colPlayers, value.members, false, false)
			guiGridListSetItemText(
				fGUI.gridlist[1],
				row,
				fGUI.gridlist.colType,
				getFactionTypes(value.type),
				false,
				false
			)
			guiGridListSetItemText(
				fGUI.gridlist[1],
				row,
				fGUI.gridlist.colInts,
				value.ints .. " / " .. value.max_interiors,
				false,
				false
			)
			guiGridListSetItemText(
				fGUI.gridlist[1],
				row,
				fGUI.gridlist.colVehs,
				value.vehs .. " / " .. value.max_vehicles,
				false,
				false
			)
			guiGridListSetItemText(
				fGUI.gridlist[1],
				row,
				fGUI.gridlist.colBeforeTax,
				"₺" .. exports.mek_global:formatMoney(value.before_tax),
				false,
				false
			)
			guiGridListSetItemText(
				fGUI.gridlist[1],
				row,
				fGUI.gridlist.colFreeWage,
				"₺" .. exports.mek_global:formatMoney(value.free_wage),
				false,
				false
			)
		end
	end
end
addEvent("showFactionList", true)
addEventHandler("showFactionList", resourceRoot, showFactionList)

function showFactionListCmd()
	if exports.mek_integration:isPlayerManager(localPlayer) then
		showFactionList()
	end
end
addCommandHandler("showfactions", showFactionListCmd, false, false)
addCommandHandler("factions", showFactionListCmd, false, false)
addCommandHandler("makefaction", showFactionListCmd, false, false)
addCommandHandler("renamefaction", showFactionListCmd, false, false)
addCommandHandler("delfaction", showFactionListCmd, false, false)

function closeFactionList()
	if fGUI.window[1] and isElement(fGUI.window[1]) then
		destroyElement(fGUI.window[1])
		fGUI.window[1] = nil
		closeEditFaction()
		closeDelConfirm()
		closeListMember()
	end
end

local editFact = {
	checkbox = {},
	edit = {},
	button = {},
	window = {},
	label = {},
	combobox = {},
}

function editFaction(fact_id)
	closeEditFaction()
	guiSetInputEnabled(true)
	local data = fact_id and getFactionTableFromID(tonumber(fact_id), factions_tmp) or nil
	editFact.window[1] = guiCreateWindow(155, 453, 385, 300, fact_id and "Birliği Düzenle" or "Birlik Oluştur", false)
	guiWindowSetSizable(editFact.window[1], false)
	exports.mek_global:centerWindow(editFact.window[1])
	togWindow(fGUI.window[1], false)

	editFact.label[1] = guiCreateLabel(20, 26, 97, 29, "Birlik Adı:", false, editFact.window[1])
	guiLabelSetVerticalAlign(editFact.label[1], "center")
	editFact.edit.name = guiCreateEdit(117, 26, 246, 29, data and data.name or "", false, editFact.window[1])
	guiEditSetMaxLength(editFact.edit.name, 200)
	editFact.label[2] = guiCreateLabel(20, 65, 97, 29, "Birlik ID:", false, editFact.window[1])
	guiLabelSetVerticalAlign(editFact.label[2], "center")

	editFact.label[6] = guiCreateLabel(20, 130, 140, 29, "Vergi Öncesi Tutar:", false, editFact.window[1])
	guiLabelSetVerticalAlign(editFact.label[6], "center")

	editFact.edit.beforeTax =
		guiCreateEdit(172, 130, 190, 29, data and data.before_tax or "0", false, editFact.window[1])

	editFact.label[7] =
		guiCreateLabel(20, 162, 140, 29, "Birliğe ücret uygulanmadan önceki ücret miktarı:", false, editFact.window[1])
	guiLabelSetVerticalAlign(editFact.label[7], "center")

	editFact.edit.freeWage = guiCreateEdit(172, 165, 190, 29, data and data.free_wage or "0", false, editFact.window[1])

	editFact.combobox[1] = guiCreateComboBox(120, 100, 245, 29, "Birlik tipi seçin:", false, editFact.window[1])
	local types = getFactionTypes()
	for id, name in pairs(types) do
		guiComboBoxAddItem(editFact.combobox[1], name)
	end
	exports.mek_global:guiComboBoxAdjustHeight(editFact.combobox[1], size(types))
	if data then
		guiSetText(editFact.combobox[1], types[tostring(data.type or 5)])
	end
	editFact.edit.id = guiCreateEdit(117, 65, 246, 29, data and data.id or "otomatik", false, editFact.window[1])
	guiSetEnabled(editFact.edit.id, false)
	guiEditSetMaxLength(editFact.edit.id, 10)
	editFact.label[3] = guiCreateLabel(20, 100, 97, 29, "Birlik Tipi:", false, editFact.window[1])
	guiLabelSetVerticalAlign(editFact.label[3], "center")
	editFact.label[4] = guiCreateLabel(20, 205, 97, 29, "Maksimum Mülk:", false, editFact.window[1])
	guiLabelSetVerticalAlign(editFact.label[4], "center")
	editFact.edit.max_interiors =
		guiCreateEdit(117, 205, 62, 29, data and data.max_interiors or "20", false, editFact.window[1])
	guiEditSetMaxLength(editFact.edit.max_interiors, 10)
	editFact.label[5] = guiCreateLabel(204, 205, 97, 29, "Maksimum Araç:", false, editFact.window[1])
	guiLabelSetVerticalAlign(editFact.label[5], "center")
	editFact.edit.max_vehicles =
		guiCreateEdit(301, 205, 62, 29, data and data.max_vehicles or "40", false, editFact.window[1])
	guiEditSetMaxLength(editFact.edit.max_vehicles, 10)
	editFact.button[1] = guiCreateButton(179, 250, 88, 40, "İptal", false, editFact.window[1])
	editFact.button[2] = guiCreateButton(277, 250, 88, 40, "Gönder", false, editFact.window[1])
	addEventHandler("onClientGUIClick", editFact.window[1], function()
		if source == editFact.button[1] then
			closeEditFaction()
		elseif source == editFact.button[2] then
			local submit_data = {}
			submit_data.name = guiGetText(editFact.edit.name)
			submit_data.type = nil
			
			for type_id, type_name in pairs(types) do
				if guiGetText(editFact.combobox[1]) == type_name then
					submit_data.type = tonumber(type_id)
					break
				end
			end

			submit_data.max_interiors = tonumber(guiGetText(editFact.edit.max_interiors))
			submit_data.max_vehicles = tonumber(guiGetText(editFact.edit.max_vehicles))
			submit_data.before_tax_value = tonumber(guiGetText(editFact.edit.beforeTax))
			submit_data.free_wage_amount = tonumber(guiGetText(editFact.edit.freeWage))

			if string.len(submit_data.name) < 3 then
				triggerEvent("errorSound", localPlayer)
				return not outputChatBox("[!]#FFFFFF Birlik adı en az 3 karakter uzunluğunda olmalıdır.", 255, 0, 0, true)
			elseif not submit_data.type then
				triggerEvent("errorSound", localPlayer)
				return not outputChatBox("[!]#FFFFFF Geçersiz birlik türü.", 255, 0, 0, true)
			elseif not submit_data.max_interiors or submit_data.max_interiors < 0 then
				triggerEvent("errorSound", localPlayer)
				return not outputChatBox("[!]#FFFFFF Maksimum mülk sayısı pozitif olmalıdır.", 255, 0, 0, true)
			elseif not submit_data.max_vehicles or submit_data.max_vehicles < 0 then
				triggerEvent("errorSound", localPlayer)
				return not outputChatBox("[!]#FFFFFF Maksimum araç sayısı pozitif olmalıdır.", 255, 0, 0, true)
			else
				triggerServerEvent("factions.editFaction", resourceRoot, submit_data, fact_id)
				togWindow(editFact.window[1], false)
			end
		end
	end)
end

function closeEditFaction()
	if editFact.window[1] and isElement(editFact.window[1]) then
		destroyElement(editFact.window[1])
		editFact.window[1] = nil
		togWindow(fGUI.window[1], true)
		guiSetInputEnabled(false)
	end
end

addEvent("factions.editFaction.callback", true)
addEventHandler("factions.editFaction.callback", resourceRoot, function(response)
	if response == "ok" then
		triggerEvent("successSound", localPlayer)
		closeEditFaction()
		showFactionList()
	else
		triggerEvent("errorSound", localPlayer)
		outputChatBox(response, 255, 0, 0)
		togWindow(editFact.window[1], true)
	end
end)

local delGUI = {
	button = {},
	window = {},
	label = {},
}
function delConfirm(fact_id)
	closeDelConfirm()
	togWindow(fGUI.window[1], false)
	local fact = getFactionTableFromID(tonumber(fact_id), factions_tmp)
	delGUI.window[1] = guiCreateWindow(429, 298, 437, 206, "Birliği Sil", false)
	guiWindowSetSizable(delGUI.window[1], false)
	exports.mek_global:centerWindow(delGUI.window[1])

	delGUI.label[1] = guiCreateLabel(
		15,
		43,
		412,
		110,
		"Şu anda #" 
			.. fact.id 
			.. " (" 
			.. fact.name 
			.. ") ID'li birliği silmek üzeresiniz.\n\n"
			.. "Birliğe ait tüm mülkler, araçlar, eşyalar ve benzeri varlıklar da kalıcı olarak silinecektir.\n"
			.. "Bu işlem geri alınamaz.\n\n"
			.. "Devam etmek istediğinize emin misiniz?",
		false,
		delGUI.window[1]
	)
	guiLabelSetHorizontalAlign(delGUI.label[1], "left", true)
	delGUI.button[1] = guiCreateButton(17, 158, 200, 33, "İptal", false, delGUI.window[1])
	delGUI.button[2] = guiCreateButton(223, 158, 200, 33, "İlerle", false, delGUI.window[1])
	addEventHandler("onClientGUIClick", delGUI.window[1], function()
		if source == delGUI.button[1] then
			closeDelConfirm()
		elseif source == delGUI.button[2] then
			closeDelConfirm()
			triggerServerEvent("factions.delete", resourceRoot, fact_id)
		end
	end)
end

function closeDelConfirm()
	if delGUI.window[1] and isElement(delGUI.window[1]) then
		destroyElement(delGUI.window[1])
		delGUI.window[1] = nil
		togWindow(fGUI.window[1], true)
	end
end

local listMemberGUI = {
	gridlist = {},
	window = {},
	button = {},
	label = {},
	col = {},
}

local fact_id_tmp
function listMember(fact_id, response, data)
	closeListMember()
	togWindow(fGUI.window[1], false)
	local wExtend = 45
	listMemberGUI.window[1] = guiCreateWindow(519, 255, 555 + wExtend, 372, "Birlik Üyelerini Listeleme", false)
	guiWindowSetSizable(listMemberGUI.window[1], false)
	exports.mek_global:centerWindow(listMemberGUI.window[1])

	if data then
		if listMemberGUI.label[1] and isElement(listMemberGUI.label[1]) then
			destroyElement(listMemberGUI.label[1])
			listMemberGUI.label[1] = nil
		end
		
		listMemberGUI.gridlist[1] = guiCreateGridList(9, 26, 536 + wExtend, 299, false, listMemberGUI.window[1])
		listMemberGUI.col.faction_leader = guiGridListAddColumn(listMemberGUI.gridlist[1], "Lider", 0.1)
		listMemberGUI.col.faction_rank = guiGridListAddColumn(listMemberGUI.gridlist[1], "Rütbe", 0.33)
		listMemberGUI.col.name = guiGridListAddColumn(listMemberGUI.gridlist[1], "Üye", 0.27)
		listMemberGUI.col.username = guiGridListAddColumn(listMemberGUI.gridlist[1], "Hesap Adı", 0.15)
		listMemberGUI.col.duty = guiGridListAddColumn(listMemberGUI.gridlist[1], "Görev", 0.08)
		
		for _, member in ipairs(data) do
			local row = guiGridListAddRow(listMemberGUI.gridlist[1])
			guiGridListSetItemText(
				listMemberGUI.gridlist[1],
				row,
				listMemberGUI.col.faction_leader,
				member.faction_leader == 1 and "Evet" or "Hayır",
				false,
				false
			)
			guiGridListSetItemText(
				listMemberGUI.gridlist[1],
				row,
				listMemberGUI.col.faction_rank,
				member.faction_rank_name or "",
				false,
				false
			)
			guiGridListSetItemText(
				listMemberGUI.gridlist[1],
				row,
				listMemberGUI.col.name,
				member.name and string.gsub(member.name, "_", " ") or "",
				false,
				false
			)
			guiGridListSetItemText(
				listMemberGUI.gridlist[1],
				row,
				listMemberGUI.col.username,
				member.username or "",
				false,
				false
			)
			guiGridListSetItemColor(
				listMemberGUI.gridlist[1],
				row,
				listMemberGUI.col.name,
				member.online == 1 and 0 or 255,
				255,
				member.online == 1 and 0 or 255,
				member.online == 1 and 255 or 200
			)
			guiGridListSetItemText(
				listMemberGUI.gridlist[1],
				row,
				listMemberGUI.col.duty,
				member.duty and "Görevde" or "Görev Dışı",
				false,
				false
			)
			guiGridListSetItemColor(
				listMemberGUI.gridlist[1],
				row,
				listMemberGUI.col.duty,
				member.duty and 0 or 255,
				255,
				member.duty and 0 or 255,
				member.duty and 255 or 200
			)
		end
		addEventHandler("onClientGUIDoubleClick", listMemberGUI.gridlist[1], function()
			local row, col = guiGridListGetSelectedItem(listMemberGUI.gridlist[1])
			if row ~= -1 and col ~= -1 then
				local text = guiGridListGetItemText(listMemberGUI.gridlist[1], row, 2)
					.. " - "
					.. guiGridListGetItemText(listMemberGUI.gridlist[1], row, 3)
					.. " ("
					.. guiGridListGetItemText(listMemberGUI.gridlist[1], row, 4)
					.. ")"
				if setClipboard(text) then
					outputChatBox("Kopyalandı: '" .. text .. "'.")
					triggerEvent("successSound", localPlayer)
				end
			end
		end)
		togWindow(listMemberGUI.window[1], true)
	else
		if response then
			if listMemberGUI.gridlist[1] and isElement(listMemberGUI.gridlist[1]) then
				destroyElement(listMemberGUI.gridlist[1])
				listMemberGUI.gridlist[1] = nil
			end
			if listMemberGUI.label[1] and isElement(listMemberGUI.label[1]) then
				guiSetText(listMemberGUI.label[1], response)
			end
			togWindow(listMemberGUI.window[1], true)
		else
			if listMemberGUI.gridlist[1] and isElement(listMemberGUI.gridlist[1]) then
				destroyElement(listMemberGUI.gridlist[1])
				listMemberGUI.gridlist[1] = nil
			end
			listMemberGUI.label[1] =
				guiCreateLabel(0, 0, 1, 1, "Sunucudan bilgi alınıyor...", true, listMemberGUI.window[1])
			guiLabelSetHorizontalAlign(listMemberGUI.label[1], "center")
			guiLabelSetVerticalAlign(listMemberGUI.label[1], "center")
			triggerServerEvent("factions.listMember", resourceRoot, fact_id)
			togWindow(listMemberGUI.window[1], false)
			fact_id_tmp = fact_id
		end
	end

	listMemberGUI.button[1] = guiCreateButton(451 + wExtend, 332, 94, 30, "Kapat", false, listMemberGUI.window[1])
	listMemberGUI.button[2] = guiCreateButton(350 + wExtend, 332, 94, 30, "Yenile", false, listMemberGUI.window[1])
	addEventHandler("onClientGUIClick", listMemberGUI.window[1], function()
		if source == listMemberGUI.button[1] then
			closeListMember()
		elseif source == listMemberGUI.button[2] then
			listMember(fact_id_tmp)
		end
	end)
end
addEvent("factions.listMember", true)
addEventHandler("factions.listMember", resourceRoot, listMember)

function closeListMember()
	if listMemberGUI.window[1] and isElement(listMemberGUI.window[1]) then
		destroyElement(listMemberGUI.window[1])
		listMemberGUI.window[1] = nil
		togWindow(fGUI.window[1], true)
	end
end

addCommandHandler("showfactionplayers", function(cmd, fact_id)
	if canAccessFactionManager(localPlayer) then
		if not fact_id or not tonumber(fact_id) or tonumber(fact_id) < 1 then
			return not outputChatBox("Kullanım: /" .. cmd .. " [Birlik ID]")
		end
		listMember(fact_id)
	end
end, false, false)
