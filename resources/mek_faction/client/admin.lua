DutyAllow = {
	label = {},
	edit = {},
	button = {},
	window = {},
	gridlist = {},
	combobox = {},
}

weapBanList = {
	[-8] = true,
	[-35] = true,
	[-36] = true,
	[-37] = true,
	[-38] = true,
	[-39] = true,
	[-40] = true,
}

function createAdminDuty(factionT, dutyT)
	if isElement(DutyAllow.window[1]) then
		destroyElement(DutyAllow.window[1])
	end

	factionTable = factionT
	dutyChanges = dutyT

	DutyAllow.window[1] = guiCreateWindow(562, 250, 564, 351, "Yönetici Görev Ayarları", false)
	exports.mek_global:centerWindow(DutyAllow.window[1])
	guiWindowSetSizable(DutyAllow.window[1], false)
	guiWindowSetMovable(DutyAllow.window[1], true)
	guiSetInputEnabled(true)

	DutyAllow.gridlist[1] = guiCreateGridList(9, 75, 545, 224, false, DutyAllow.window[1])
	guiGridListAddColumn(DutyAllow.gridlist[1], "ID", 0.1)
	guiGridListAddColumn(DutyAllow.gridlist[1], "İsim", 0.3)
	guiGridListAddColumn(DutyAllow.gridlist[1], "Açıklama", 0.6)
	DutyAllow.label[1] = guiCreateLabel(10, 308, 73, 21, "Eşya ID:", false, DutyAllow.window[1])
	guiLabelSetVerticalAlign(DutyAllow.label[1], "center")
	DutyAllow.edit[1] = guiCreateEdit(83, 308, 78, 21, "", false, DutyAllow.window[1])
	DutyAllow.button[1] = guiCreateButton(318, 303, 108, 30, "İzin Ver", false, DutyAllow.window[1])
	guiSetProperty(DutyAllow.button[1], "NormalTextColour", "FFAAAAAA")
	DutyAllow.button[2] = guiCreateButton(436, 303, 108, 30, "Sil", false, DutyAllow.window[1])
	guiSetProperty(DutyAllow.button[2], "NormalTextColour", "FFAAAAAA")
	DutyAllow.label[2] = guiCreateLabel(11, 59, 543, 16, "İzin Verilen Öğeler", false, DutyAllow.window[1])
	guiLabelSetHorizontalAlign(DutyAllow.label[2], "center", false)
	DutyAllow.label[3] = guiCreateLabel(9, 348, 74, 24, "Görüş:", false, DutyAllow.window[1])
	guiLabelSetVerticalAlign(DutyAllow.label[3], "center")
	DutyAllow.label[4] = guiCreateLabel(163, 308, 68, 20, "Eşya Değeri:", false, DutyAllow.window[1])
	guiLabelSetVerticalAlign(DutyAllow.label[4], "center")
	DutyAllow.edit[2] = guiCreateEdit(230, 308, 78, 21, "1", false, DutyAllow.window[1])
	DutyAllow.combobox[1] = guiCreateComboBox(1, 25, 242, 998, "Bir birlik seçimi yapın.", false, DutyAllow.window[1])
	exports.mek_global:guiComboBoxAdjustHeight(DutyAllow.combobox[1], #factionT)
	DutyAllow.button[3] = guiCreateButton(442, 25, 102, 35, "Uygula", false, DutyAllow.window[1])
	guiSetProperty(DutyAllow.button[3], "NormalTextColour", "FFAAAAAA")
	DutyAllow.combobox[2] = guiCreateComboBox(255, 25, 124, 19, "", false, DutyAllow.window[1])
	exports.mek_global:guiComboBoxAdjustHeight(DutyAllow.combobox[2], 2)
	guiComboBoxAddItem(DutyAllow.combobox[2], "Eşyalar")
	guiComboBoxAddItem(DutyAllow.combobox[2], "Silahlar")
	guiComboBoxSetSelected(DutyAllow.combobox[2], 0)

	local row = guiGridListAddRow(DutyAllow.gridlist[1])
	guiGridListSetItemText(DutyAllow.gridlist[1], row, 2, "Bir birlik seçimi yapın.", false, false)

	for k, v in pairs(factionT) do
		guiComboBoxAddItem(DutyAllow.combobox[1], v[2])
	end
	addEventHandler("onClientGUIComboBoxAccepted", DutyAllow.combobox[1], toggleFaction)
	addEventHandler("onClientGUIComboBoxAccepted", DutyAllow.combobox[2], toggleView)

	addEventHandler("onClientGUIClick", DutyAllow.button[1], allowItem, false)
	addEventHandler("onClientGUIClick", DutyAllow.button[2], removeItem, false)
	addEventHandler("onClientGUIClick", DutyAllow.button[3], closeGUI, false)
end
addEvent("adminDutyAllow", true)
addEventHandler("adminDutyAllow", resourceRoot, createAdminDuty)

function populateList(key)
	local selection = guiComboBoxGetSelected(DutyAllow.combobox[2])
	guiGridListClear(DutyAllow.gridlist[1])
	if selection == 0 then
		for k, v in pairs(factionTable[key][3]) do
			if tonumber(v[2]) > 0 then
				local row = guiGridListAddRow(DutyAllow.gridlist[1])

				guiGridListSetItemText(DutyAllow.gridlist[1], row, 1, v[2], false, true)
				guiGridListSetItemText(DutyAllow.gridlist[1], row, 2, exports.mek_item:getItemName(v[2]), false, false)
				guiGridListSetItemText(
					DutyAllow.gridlist[1],
					row,
					3,
					exports.mek_item:getItemDescription(v[2], v[3]),
					false,
					false
				)
				guiGridListSetItemData(DutyAllow.gridlist[1], row, 1, tonumber(v[1]))
			end
		end
	elseif selection == 1 then
		for k, v in pairs(factionTable[key][3]) do
			if tonumber(v[2]) < 0 then
				local row = guiGridListAddRow(DutyAllow.gridlist[1])
				if tonumber(v[2]) == -100 then
					guiGridListSetItemText(DutyAllow.gridlist[1], row, 1, v[2], false, true)
					guiGridListSetItemText(DutyAllow.gridlist[1], row, 2, "Zırh", false, false)
					guiGridListSetItemText(DutyAllow.gridlist[1], row, 3, v[3], false, false)
				else
					guiGridListSetItemText(DutyAllow.gridlist[1], row, 1, v[2], false, true)
					guiGridListSetItemText(
						DutyAllow.gridlist[1],
						row,
						2,
						exports.mek_item:getItemName(v[2]),
						false,
						false
					)
					guiGridListSetItemText(DutyAllow.gridlist[1], row, 3, v[3], false, false)
				end
				guiGridListSetItemData(DutyAllow.gridlist[1], row, 1, tonumber(v[1]))
			end
		end
	end
	guiSetText(DutyAllow.edit[1], "")
	guiSetText(DutyAllow.edit[2], "")
end

function toggleView()
	local item = guiComboBoxGetSelected(DutyAllow.combobox[2])
	guiGridListClear(DutyAllow.gridlist[1])

	if item == 1 then
		guiSetText(DutyAllow.label[2], "İzin Verilen Silahlar")

		guiGridListSetColumnTitle(DutyAllow.gridlist[1], 2, "İsim")
		guiGridListSetColumnTitle(DutyAllow.gridlist[1], 3, "Maksimum Cephane")

		guiSetText(DutyAllow.label[1], "Silah ID:")
		guiSetText(DutyAllow.label[4], "Maksimum Cephane:")
	elseif item == 0 then
		guiSetText(DutyAllow.label[2], "İzin Verilen Eşyalar")

		guiGridListSetColumnTitle(DutyAllow.gridlist[1], 2, "İsim")
		guiGridListSetColumnTitle(DutyAllow.gridlist[1], 3, "Açıklama")

		guiSetText(DutyAllow.label[1], "Eşya ID:")
		guiSetText(DutyAllow.label[4], "Eşya Değeri:")
	end
	if guiComboBoxGetSelected(DutyAllow.combobox[1]) and guiComboBoxGetSelected(DutyAllow.combobox[1]) > -1 then
		populateList(
			findFactionID(guiComboBoxGetItemText(DutyAllow.combobox[1], guiComboBoxGetSelected(DutyAllow.combobox[1])))
		)
	end
end

function toggleFaction()
	local selected = guiComboBoxGetSelected(DutyAllow.combobox[1])
	if selected and selected > -1 then
		populateList(findFactionID(guiComboBoxGetItemText(DutyAllow.combobox[1], selected)))
	end
end

function findFactionID(name)
	for k, v in pairs(factionTable) do
		if v[2] == name then
			return tonumber(k)
		end
	end
end

function closeGUI()
	destroyElement(DutyAllow.window[1])
	guiSetInputEnabled(false)
	triggerServerEvent("dutyAdmin:Save", resourceRoot, factionTable, dutyChanges)
end

function allowItem()
	local itemID = guiGetText(DutyAllow.edit[1])
	local itemValue = guiGetText(DutyAllow.edit[2])
	local selection = guiComboBoxGetSelected(DutyAllow.combobox[2])
	local faction = guiComboBoxGetSelected(DutyAllow.combobox[1])
	local maxIndex = getElementData(resourceRoot, "maxIndex") + 1
	if not tonumber(itemID) then
		return
	end

	if not exports.mek_item:isItem(itemID) and selection == 0 then
		outputChatBox("[!]#FFFFFF Bu bir eşya değil.", 255, 0, 0, true)
		return
	elseif tonumber(itemID) == 16 then
		outputChatBox(
			"[!]#FFFFFF Kıyafetleri birlik görevi sırasında birlik liderleri tarafından yüklenmesi gerekiyor.",
			255,
			0,
			0,
			true
		)
		return
	elseif not getWeaponNameFromID(itemID) and selection == 1 and tonumber(itemID) ~= 100 then
		outputChatBox("[!]#FFFFFF Bu bir silah değil.", 255, 0, 0, true)
		return
	end

	if faction and faction > -1 then
		local faction = findFactionID(guiComboBoxGetItemText(DutyAllow.combobox[1], faction))
		if tonumber(itemID) then
			if selection == 0 then
				table.insert(factionTable[faction][3], { maxIndex, tonumber(itemID), itemValue })
				table.insert(dutyChanges, { faction, 1, maxIndex, tonumber(itemID), itemValue })
				setElementData(resourceRoot, "maxIndex", maxIndex)
			elseif selection == 1 then
				if tonumber(itemValue) then
					if not weapBanList[-tonumber(itemID)] then
						table.insert(factionTable[faction][3], { maxIndex, -tonumber(itemID), itemValue })
						table.insert(dutyChanges, { faction, 1, maxIndex, -tonumber(itemID), itemValue })
						setElementData(resourceRoot, "maxIndex", maxIndex)
					else
						outputChatBox("[!]#FFFFFF Bu silahın eklenmesi yasaktır.", 255, 0, 0, true)
					end
				else
					outputChatBox("[!]#FFFFFF Maksimum Cephane bir sayı olmalıdır.", 255, 0, 0, true)
				end
			end
			populateList(faction)
		else
			outputChatBox("[!]#FFFFFF Eşya ID'si bir sayı olmalıdır.", 255, 0, 0, true)
		end
	else
		outputChatBox("[!]#FFFFFF Lütfen önce bir seçim yapın.", 255, 0, 0, true)
	end
end

function removeItem()
	local r, c = guiGridListGetSelectedItem(DutyAllow.gridlist[1])
	local faction = guiComboBoxGetSelected(DutyAllow.combobox[1])
	if r and r >= -1 and c and c >= -1 and faction and faction >= 0 then
		local faction = findFactionID(guiComboBoxGetItemText(DutyAllow.combobox[1], faction))
		local id = guiGridListGetItemData(DutyAllow.gridlist[1], r, 1)
		for k, v in pairs(factionTable[faction][3]) do
			if tonumber(id) == tonumber(v[1]) then
				table.insert(dutyChanges, { faction, 0, v[1] })
				table.remove(factionTable[faction][3], k)
				populateList(faction)
			end
		end
	else
		outputChatBox("[!]#FFFFFF Lütfen önce bir seçim yapın.", 255, 0, 0, true)
	end
end
