ranks = {}
rank_perms = {}
factionRanks = {}
wages = {}
wRanks = nil
bRanksSave, bRanksClose = nil
ranks_gui = {
	checkbox = {},
	label = {},
	edit = {},
}

function btEditRanks(button, state)
	if (source == gButtonEditRanks) and (button == "left") and (state == "up") then
		local factionType = tonumber(getElementData(theTeam, "type"))
		lRanks = {}
		tRanks = {}
		tRankWages = {}

		guiSetInputEnabled(true)

		local sX, sY = guiGetScreenSize()
		local wX, wY = 538, 354
		local sX, sY, wX, wY = (sX / 2) - (wX / 2), (sY / 2) - (wY / 2), wX, wY

		wRanks = guiCreateWindow(sX, sY, wX, wY, "Rütbe Yönetimi", false)
		guiWindowSetSizable(wRanks, false)
		guiSetAlpha(wRanks, 1.0)

		ranksLabel1 = guiCreateLabel(9, 27, 172, 15, "Birlik Rütbe Listesi", false, wRanks)
		guiSetFont(ranksLabel1, "default-bold-small")
		guiLabelSetColor(ranksLabel1, 57, 146, 204)
		guiLabelSetHorizontalAlign(ranksLabel1, "center", false)
		ranksLabel2 = guiCreateLabel(288, 27, 142, 15, "Birlik İzinler Listesi", false, wRanks)
		guiSetFont(ranksLabel2, "default-bold-small")
		guiLabelSetColor(ranksLabel2, 57, 146, 204)
		guiLabelSetHorizontalAlign(ranksLabel2, "center", false)
		ranksLabel3 = guiCreateLabel(
			193,
			48,
			335,
			32,
			"İzinler, bu rütbenin erişebildiği şeylerdir. İzni açıp kapatmak için kutuyu işaretlemeniz/işaretini kaldırmanız yeterlidir.",
			false,
			wRanks
		)
		guiLabelSetHorizontalAlign(ranksLabel3, "center", true)

		ranksGridlist = guiCreateGridList(9, 76, 175, 211, false, wRanks)
		guiGridListAddColumn(ranksGridlist, "Birlik Rütbe Listesi", 0.9)
		guiGridListSetSortingEnabled(ranksGridlist, false)

		btRanksClose = guiCreateButton(489, 28, 38, 15, "Kapat", false, wRanks)
		btRanksMvUp = guiCreateButton(9, 292, 85, 22, "Yukarı Taşı", false, wRanks)
		btRanksMvDn = guiCreateButton(99, 292, 85, 22, "Aşağı Taşı", false, wRanks)
		btRanksUpdOrd = guiCreateButton(9, 48, 175, 22, "Rütbe Sırasını Güncelle", false, wRanks)
		btRanksAdd = guiCreateButton(9, 320, 55, 22, "Ekle", false, wRanks)
		btRanksRem = guiCreateButton(129, 320, 55, 22, "Sil", false, wRanks)
		btRanksRen = guiCreateButton(69, 320, 55, 22, "Yeniden İsimlendir", false, wRanks)
		btRanksApply = guiCreateButton(284, 313, 158, 30, "Rütbe Ayarlarını Güncelle", false, wRanks)
		guiSetFont(btRanksApply, "default-bold-small")
		ranksScrollPane = guiCreateScrollPane(192, 87, 337, 220, false, wRanks)

		triggerServerEvent("faction.getRankInfo", localPlayer, faction_tab)

		addEventHandler("onClientGUIClick", btRanksClose, closeRanks, false)
		addEventHandler("onClientGUIClick", btRanksAdd, btAddRanks, false)
		addEventHandler("onClientGUIClick", btRanksRem, btRemoveRank, false)
		addEventHandler("onClientGUIClick", btRanksRen, btRenameRank, false)
		addEventHandler("onClientGUIClick", ranksGridlist, selectRankOffList, false)
		addEventHandler("onClientGUIClick", btRanksApply, applyPermissions, false)
		addEventHandler("onClientGUIClick", btRanksMvUp, updateRankOrder, false)
		addEventHandler("onClientGUIClick", btRanksMvDn, updateRankOrder, false)
		addEventHandler("onClientGUIClick", btRanksUpdOrd, updateRankOrder, false)
	end
end

function saveRanks(button, state)
	if (source == bRanksSave) and (button == "left") and (state == "up") then
		local found = false
		local isNumber = true
		for key, value in ipairs(tRanks) do
			if (string.find(guiGetText(tRanks[key]), ";")) or (string.find(guiGetText(tRanks[key]), "'")) then
				found = true
			end
		end

		local factionType = tonumber(getElementData(theTeam, "type"))
		if
			(factionType == 2)
			or (factionType == 3)
			or (factionType == 4)
			or (factionType == 5)
			or (factionType == 6)
			or (factionType == 7)
		then
			for key, value in ipairs(tRankWages) do
				if not (tostring(type(tonumber(guiGetText(tRankWages[key])))) == "number") then
					isNumber = false
				end
			end
		end

		if found then
			outputChatBox(
				"[!]#FFFFFF Sıralamalarınız geçersiz karakterler içeriyor, lütfen '@.;' gibi karakterler içermediğinden emin olun.",
				255,
				0,
				0,
				true
			)
		elseif not isNumber then
			outputChatBox(
				"[!]#FFFFFF Maaşınız rakamdan ibaret değildir, lütfen rakam girdiğinizden ve para birimi sembolü kullanmadığınızdan emin olun.",
				255,
				0,
				0,
				true
			)
		else
			local sendRanks = {}
			local sendWages = {}

			for key, value in ipairs(tRanks) do
				sendRanks[key] = guiGetText(tRanks[key])
			end

			if
				(factionType == 2)
				or (factionType == 3)
				or (factionType == 4)
				or (factionType == 5)
				or (factionType == 6)
				or (factionType == 7)
			then
				for key, value in ipairs(tRankWages) do
					sendWages[key] = guiGetText(tRankWages[key])
				end
			end

			hideFactionMenu()
			if
				(factionType == 2)
				or (factionType == 3)
				or (factionType == 4)
				or (factionType == 5)
				or (factionType == 6)
				or (factionType == 7)
			then
				triggerServerEvent("cguiUpdateRanks", localPlayer, sendRanks, sendWages)
			else
				triggerServerEvent("cguiUpdateRanks", localPlayer, sendRanks)
			end
		end
	end
end

function closeRanks(button, state)
	if (source == btRanksClose) and (button == "left") and (state == "up") then
		if wRanks then
			destroyElement(wRanks)
			ranks_gui.checkbox = {}
			guiSetInputEnabled(false)
		end
	end
end

function btAddRanks()
	local sX, sY = guiGetScreenSize()
	local wX, wY = 347, 129
	local sX, sY, wX, wY = (sX / 2) - (wX / 2), (sY / 2) - (wY / 2), wX, wY

	wAddRank = guiCreateWindow(sX, sY, wX, wY, "Birlik Rütbesi Ekle", false)
	guiWindowSetSizable(wAddRank, false)
	guiSetAlpha(wAddRank, 1.00)

	lAddRank1 = guiCreateLabel(9, 74, 223, 15, "Rütbe İsmi", false, wAddRank)
	guiLabelSetHorizontalAlign(lAddRank1, "center", false)
	lAddRank2 = guiCreateLabel(9, 26, 224, 15, "İzinleri Şuradan Ayarla...", false, wAddRank)
	guiLabelSetHorizontalAlign(lAddRank2, "center", false)
	lAddRank3 = guiCreateLabel(239, 20, 15, 99, "|  |  |  |  |  |  |", false, wAddRank)
	guiLabelSetHorizontalAlign(lAddRank3, "left", true)
	lAddRank4 = guiCreateLabel(239, 23, 15, 99, "|  |  |  |  |  |  |", false, wAddRank)
	guiLabelSetHorizontalAlign(lAddRank4, "left", true)

	eAddrank = guiCreateEdit(9, 94, 225, 23, "", false, wAddRank)
	guiEditSetMaxLength(eAddrank, 32)

	combAddRank = guiCreateComboBox(45, 44, 154, 23, "", false, wAddRank)

	bAddRankCreate = guiCreateButton(250, 35, 85, 28, "Oluştur", false, wAddRank)
	guiSetFont(bAddRankCreate, "default-bold-small")
	guiSetProperty(bAddRankCreate, "NormalTextColour", "FFAAAAAA")
	bAddRankClose = guiCreateButton(250, 78, 85, 28, "Kapat", false, wAddRank)
	guiSetProperty(bAddRankClose, "NormalTextColour", "FFAAAAAA")

	guiComboBoxClear(combAddRank)
	for i, rank in ipairs(ranks) do
		guiComboBoxAddItem(combAddRank, rank[2])
	end
	guiComboBoxSetSelected(combAddRank, #ranks - 1)
	local x, y = guiGetSize(combAddRank, false)
	guiSetSize(combAddRank, x, 25 + (#ranks * 20), false)

	addEventHandler("onClientGUIClick", bAddRankCreate, addRank, false)
	addEventHandler("onClientGUIClick", bAddRankClose, closeAddFactionRankPanel, false)
end

function addRank()
	local rank = guiGetText(eAddrank)
	if rank == "" then
		outputChatBox("[!]#FFFFFF Bir rütbe ismi girin.", 255, 0, 0, true)
		return
	end

	local perms = guiComboBoxGetItemText(combAddRank, guiComboBoxGetSelected(combAddRank))

	for i, rankID in ipairs(ranks) do
		if rankID[2] == perms then
			perms = rankID[1]
			break
		end
	end
	triggerServerEvent("faction.addFactionRank", resourceRoot, rank, perms, faction_tab)
end

function closeAddFactionRankPanel()
	if wAddRank then
		destroyElement(wAddRank)
	end
end
addEvent("faction.closeAddFactionRankPanel", true)
addEventHandler("faction.closeAddFactionRankPanel", root, closeAddFactionRankPanel)

function btRenameRank()
	local sX, sY = guiGetScreenSize()
	local wX, wY = 245, 113
	local sX, sY, wX, wY = (sX / 2) - (wX / 2), (sY / 2) - (wY / 2), wX, wY
	local row = guiGridListGetSelectedItem(ranksGridlist)
	local currentRank = guiGridListGetItemText(ranksGridlist, row, 1)

	wRenameRank = guiCreateWindow(sX, sY, wX, wY, "Birlik Rütbesini Yeniden Adlandır", false)
	guiWindowSetSizable(wRenameRank, false)

	lRenameRank1 = guiCreateLabel(
		-18,
		28,
		277,
		15,
		"'" .. currentRank .. "' rütbe isminizi şu şekilde değiştirin:",
		false,
		wRenameRank
	)
	guiLabelSetHorizontalAlign(lRenameRank1, "center", false)

	editRenameRank = guiCreateEdit(16, 48, 216, 21, "", false, wRenameRank)
	guiEditSetMaxLength(editRenameRank, 32)

	btRenameRankChange = guiCreateButton(53, 77, 63, 26, "Değiştir", false, wRenameRank)
	guiSetProperty(btRenameRankChange, "NormalTextColour", "FFAAAAAA")
	btRenameRankCancel = guiCreateButton(125, 77, 63, 26, "İptal", false, wRenameRank)
	guiSetProperty(btRenameRankCancel, "NormalTextColour", "FFAAAAAA")

	addEventHandler("onClientGUIClick", btRenameRankChange, renameRank, false)
	addEventHandler("onClientGUIClick", btRenameRankCancel, function()
		destroyElement(wRenameRank)
	end, false)
end

function btRemoveRank()
	local sX, sY = guiGetScreenSize()
	local wX, wY = 285, 138
	local sX, sY, wX, wY = (sX / 2) - (wX / 2), (sY / 2) - (wY / 2), wX, wY

	wRemoveRank = guiCreateWindow(660, 366, 285, 138, "Birlik Rütbesi Silme", false)
	guiWindowSetSizable(wRemoveRank, false)

	local row = guiGridListGetSelectedItem(ranksGridlist)
	local rankName = guiGridListGetItemText(ranksGridlist, row, 1)
	lRemoveRank1 = guiCreateLabel(
		26,
		24,
		225,
		30,
		"'" .. rankName .. "' rütbesini silmek istediğinizden emin misiniz?",
		false,
		wRemoveRank
	)
	guiSetFont(lRemoveRank1, "default-bold-small")
	guiLabelSetHorizontalAlign(lRemoveRank1, "center", false)
	local def_rank = guiGridListGetItemText(ranksGridlist, guiGridListGetRowCount(ranksGridlist) - 1, 1)
	lRemoveRank2 = guiCreateLabel(
		10,
		58,
		257,
		31,
		"Bu rütbeye sahip olanların hepsine '" .. def_rank .. "' rütbesi verilecektir.",
		false,
		wRemoveRank
	)
	guiLabelSetHorizontalAlign(lRemoveRank2, "center", false)

	btRemoveRankDel = guiCreateButton(68, 96, 67, 29, "Sil", false, wRemoveRank)
	guiSetProperty(btRemoveRankDel, "NormalTextColour", "FFAAAAAA")
	btRemoveRankCancel = guiCreateButton(141, 96, 67, 29, "İptal", false, wRemoveRank)
	guiSetProperty(btRemoveRankCancel, "NormalTextColour", "FFAAAAAA")

	addEventHandler("onClientGUIClick", btRemoveRankDel, removeRank, false)
	addEventHandler("onClientGUIClick", btRemoveRankCancel, function()
		destroyElement(wRemoveRank)
	end, false)
end

function setRankInfo(rankTbl, rankperms, perms, wageTable)
	ranks = rankTbl
	rank_perms = rankperms
	wages = wageTable
	wasOrderChanged = nil

	guiGridListClear(ranksGridlist)
	for i, rank in ipairs(rankTbl) do
		local row = guiGridListAddRow(ranksGridlist)
		guiGridListSetItemText(ranksGridlist, row, 1, rank[2], false, false)
	end

	for i = 1, #ranks_gui.checkbox do
		if isElement(ranks_gui.checkbox[i]) then
			destroyElement(ranks_gui.checkbox[i])
		end
	end
	ranks_gui.checkbox = {}

	if not isElement(ranksLabel5) then
		ranksLabel5 = guiCreateLabel(
			0,
			0,
			337,
			15,
			"İzinlerini özelleştirmek için bir rütbe seçin:",
			false,
			ranksScrollPane
		)
		guiLabelSetHorizontalAlign(ranksLabel5, "center", true)
		guiSetFont(ranksLabel5, "default-bold-small")
		guiLabelSetColor(ranksLabel5, 57, 146, 204)
	end

	for i, perm in ipairs(perms) do
		ranks_gui.checkbox[i] = guiCreateCheckBox(0, (i * 25) - 5, 337, 20, perm, false, false, ranksScrollPane)
		guiSetEnabled(ranks_gui.checkbox[i], false)
		if #perms == i then
			ranks_gui.label[1] = guiCreateLabel(0, (i * 25 + 25), 39, 15, "Maaş:", false, ranksScrollPane)
			ranks_gui.edit[1] = guiCreateEdit(39, (i * 25 + 25), 89, 24, "", false, ranksScrollPane)
			guiSetEnabled(ranks_gui.edit[1], false)
		end
	end

	guiSetEnabled(btRanksUpdOrd, false)
end
addEvent("faction.setRankInfo", true)
addEventHandler("faction.setRankInfo", root, setRankInfo)

function selectRankOffList()
	local row = guiGridListGetSelectedItem(ranksGridlist)
	if not row or row == -1 then
		return
	end

	local rankID = ranks[row + 1][1]
	local isDefault = tonumber(factionRanks[rankID]["isDefault"])
	local isLeader = tonumber(factionRanks[rankID]["isLeader"])
	local perms = rank_perms[rankID]
	guiSetEnabled(btRanksMvDn, true)
	guiSetEnabled(btRanksMvUp, true)

	if isDefault == 0 and isLeader == 0 then
		guiSetEnabled(btRanksRem, true)
		for i, box in ipairs(ranks_gui.checkbox) do
			guiSetEnabled(box, true)
			guiCheckBoxSetSelected(box, false)
		end
	else
		guiSetEnabled(btRanksRem, false)
		for i, box in ipairs(ranks_gui.checkbox) do
			guiSetEnabled(box, false)
			guiCheckBoxSetSelected(box, false)
		end
	end

	for _, i in pairs(perms) do
		if ranks_gui.checkbox[i] then
			guiCheckBoxSetSelected(ranks_gui.checkbox[i], true)
		end
	end

	if row == 0 then
		guiSetEnabled(btRanksMvUp, false)
	end
	if row == guiGridListGetRowCount(ranksGridlist) - 1 then
		guiSetEnabled(btRanksMvDn, false)
	end

	guiSetText(ranks_gui.edit[1], wages[rankID] or "")
	guiSetEnabled(ranks_gui.edit[1], true)

	guiSetText(ranksLabel5, "'" .. ranks[row + 1][2] .. "' için izinler düzenlemesi")
end

function applyPermissions()
	local row = guiGridListGetSelectedItem(ranksGridlist)
	if not row or row == -1 then
		outputChatBox("[!]#FFFFFF Önce bir rütbe seçin.", 255, 0, 0, true)
		return
	end
	local rankID = ranks[row + 1][1]

	local permissions = {}
	for i, box in ipairs(ranks_gui.checkbox) do
		if guiCheckBoxGetSelected(box) then
			table.insert(permissions, i)
		end
	end
	local wage = guiGetText(ranks_gui.edit[1])
	factionRanks[rankID]["permissions"] = table.concat(permissions, ",")
	triggerServerEvent("faction.updateRankPermissions", resourceRoot, rankID, permissions, wage, faction_tab)
	hideFactionMenu()
end

function updateRankOrder()
	if source == btRanksMvUp or source == btRanksMvDn then
		local row = guiGridListGetSelectedItem(ranksGridlist)
		if not row or row == -1 then
			outputChatBox("[!]#FFFFFF Önce bir rütbe seçin.", 255, 0, 0, true)
			return
		end

		local rankTbl = ranks[row + 1]
		table.remove(ranks, row + 1)
		if source == btRanksMvUp then
			table.insert(ranks, row, rankTbl)
		else
			table.insert(ranks, row + 2, rankTbl)
		end

		guiGridListClear(ranksGridlist)
		for i, rank in ipairs(ranks) do
			local row = guiGridListAddRow(ranksGridlist)
			guiGridListSetItemText(ranksGridlist, row, 1, rank[2], false, false)
		end
		guiSetEnabled(btRanksUpdOrd, true)
	elseif source == btRanksUpdOrd then
		local rankIDs = {}
		for i, rank in ipairs(ranks) do
			table.insert(rankIDs, rank[1])
		end
		triggerServerEvent("faction.updateRankOrder", resourceRoot, rankIDs, faction_tab)
	end
end

function renameRank()
	local rankName = guiGetText(editRenameRank)
	if rankName == "" then
		outputChatBox("[!]#FFFFFF Bir rütbe ismi girin.", 255, 0, 0, true)
		return
	end

	local row = guiGridListGetSelectedItem(ranksGridlist)
	if not row or row == -1 then
		return
	end
	local rankID = ranks[row + 1][1]

	triggerServerEvent("faction.setFactionRankName", resourceRoot, rankID, rankName, faction_tab)
	destroyElement(wRenameRank)
end

function removeRank()
	local row = guiGridListGetSelectedItem(ranksGridlist)
	if not row or row == -1 then
		return
	end
	local rankID = ranks[row + 1][1]

	triggerServerEvent("faction.removeFactionRank", resourceRoot, rankID, faction_tab)
	destroyElement(wRemoveRank)
end

function cacheRanks(FactionRanks)
	if not factionRanks then
		return
	end
	factionRanks = FactionRanks
end
addEvent("faction.cacheRanks", true)
addEventHandler("faction.cacheRanks", root, cacheRanks)
