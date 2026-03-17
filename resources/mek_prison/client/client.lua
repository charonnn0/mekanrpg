screenSize = Vector2(guiGetScreenSize())

PrisonGUI = {
	gridlist = {},
	column = {},
	window = {},
	button = {},
	label = {},
}

ToggleGateGUI = {
	button = {},
	window = {},
	combobox = {},
	label = {},
}

newPrisonerGUI = {
	edit = {},
	button = {},
	window = {},
	label = {},
	memo = {},
}

result = {}

function PrisonGUIF(result)
	showCursor(true)

	local scr = { guiGetScreenSize() }
	local w, h = 928, 324
	local x, y = (scr[1] / 2) - (w / 2), (scr[2] / 2) - (h / 2)
	PrisonGUI.window[1] = guiCreateWindow(x, y, w, h, "Hapishane Arayüzü", false)
	guiWindowSetSizable(PrisonGUI.window[1], false)

	PrisonGUI.gridlist[1] = guiCreateGridList(9, 21, 902, 217, false, PrisonGUI.window[1])
	guiGridListSetSortingEnabled(PrisonGUI.gridlist[1], true)
	PrisonGUI.column[1] = guiGridListAddColumn(PrisonGUI.gridlist[1], "Sıra ID", 0.1)
	PrisonGUI.column[7] = guiGridListAddColumn(PrisonGUI.gridlist[1], "Hücre", 0.05)
	PrisonGUI.column[2] = guiGridListAddColumn(PrisonGUI.gridlist[1], "İsim", 0.2)
	PrisonGUI.column[3] = guiGridListAddColumn(PrisonGUI.gridlist[1], "Mahkeme Tarihi", 0.15)
	PrisonGUI.column[4] = guiGridListAddColumn(PrisonGUI.gridlist[1], "Kalan Gün", 0.1)
	PrisonGUI.column[8] = guiGridListAddColumn(PrisonGUI.gridlist[1], "Kalan Saat", 0.1)
	PrisonGUI.column[5] = guiGridListAddColumn(PrisonGUI.gridlist[1], "Son Güncelleyen", 0.1)
	PrisonGUI.column[9] = guiGridListAddColumn(PrisonGUI.gridlist[1], "Ceza", 0.1)
	PrisonGUI.column[6] = guiGridListAddColumn(PrisonGUI.gridlist[1], "Suçlar", 0.5)

	PrisonGUI.button[1] = guiCreateButton(13, 241, 100, 73, "Kapat", false, PrisonGUI.window[1])
	guiSetProperty(PrisonGUI.button[1], "NormalTextColour", "FFAAAAAA")
	PrisonGUI.button[2] = guiCreateButton(129, 243, 119, 30, "Serbest Bırak", false, PrisonGUI.window[1])
	guiSetProperty(PrisonGUI.button[2], "NormalTextColour", "FFAAAAAA")
	PrisonGUI.button[3] = guiCreateButton(130, 280, 119, 30, "Yeni Mahkum Ekle", false, PrisonGUI.window[1])
	guiSetProperty(PrisonGUI.button[3], "NormalTextColour", "FFAAAAAA")
	PrisonGUI.button[4] = guiCreateButton(263, 243, 119, 30, "Mahkumu Güncelle", false, PrisonGUI.window[1])
	guiSetProperty(PrisonGUI.button[4], "NormalTextColour", "FFAAAAAA")
	PrisonGUI.button[5] = guiCreateButton(588, 242, 134, 30, "Seçilen Kapıyı Aç", false, PrisonGUI.window[1])
	guiSetProperty(PrisonGUI.button[5], "NormalTextColour", "FFAAAAAA")
	PrisonGUI.button[6] = guiCreateButton(588, 282, 134, 30, "Tüm Kapıları Aç", false, PrisonGUI.window[1])
	guiSetProperty(PrisonGUI.button[6], "NormalTextColour", "FFAAAAAA")

	if pd_offline_jail or exports.mek_integration:isPlayerTrialAdmin(localPlayer) then
		PrisonGUI.button[7] = guiCreateButton(263, 280, 119, 30, "İnaktif Mahkum Ekle", false, PrisonGUI.window[1])
		guiSetProperty(PrisonGUI.button[7], "NormalTextColour", "FFAAAAAA")
		addEventHandler("onClientGUIClick", PrisonGUI.button[7], function()
			addPrisonerGUI(source)
		end, false)
	end

	for _, res in ipairs(result) do
		local row = guiGridListAddRow(PrisonGUI.gridlist[1])
		guiGridListSetItemText(PrisonGUI.gridlist[1], row, PrisonGUI.column[1], tostring(res[1]), false, true)
		guiGridListSetItemText(
			PrisonGUI.gridlist[1],
			row,
			PrisonGUI.column[2],
			tostring(res[3]:gsub("_", " ")),
			false,
			false
		)
		guiGridListSetItemText(PrisonGUI.gridlist[1], row, PrisonGUI.column[3], tostring(res[5]), false, false)

		if getPlayerFromName(tostring(res[3])) then
			guiGridListSetItemColor(PrisonGUI.gridlist[1], row, PrisonGUI.column[2], 0, 255, 0)
		end

		local days, hours, remainingtime = cleanMath(res[4])
		if remainingtime <= 0 then
			days = PRISONER_STATUS.Awaiting
			hours = PRISONER_STATUS.OnlineTime
		end

		guiGridListSetItemText(PrisonGUI.gridlist[1], row, PrisonGUI.column[4], tostring(days), false, false)
		guiGridListSetItemText(PrisonGUI.gridlist[1], row, PrisonGUI.column[8], tostring(hours), false, false)

		if days == PRISONER_STATUS.LifeTime then
			guiGridListSetItemColor(PrisonGUI.gridlist[1], row, PrisonGUI.column[4], 255, 0, 0)
			guiGridListSetItemColor(PrisonGUI.gridlist[1], row, PrisonGUI.column[8], 255, 0, 0)
		elseif days == PRISONER_STATUS.Awaiting and hours == PRISONER_STATUS.Release then
			guiGridListSetItemColor(PrisonGUI.gridlist[1], row, PrisonGUI.column[4], 255, 255, 0)
			guiGridListSetItemColor(PrisonGUI.gridlist[1], row, PrisonGUI.column[8], 255, 255, 0)
		elseif hours == PRISONER_STATUS.OnlineTime then
			guiGridListSetItemColor(PrisonGUI.gridlist[1], row, PrisonGUI.column[4], 0, 93, 1)
			guiGridListSetItemColor(PrisonGUI.gridlist[1], row, PrisonGUI.column[8], 0, 93, 1)
		end

		guiGridListSetItemText(
			PrisonGUI.gridlist[1],
			row,
			PrisonGUI.column[5],
			tostring(res[6]:gsub("_", " ")),
			false,
			false
		)
		guiGridListSetItemText(PrisonGUI.gridlist[1], row, PrisonGUI.column[6], tostring(res[7]), false, false)
		guiGridListSetItemText(PrisonGUI.gridlist[1], row, PrisonGUI.column[7], tostring(res[8]), false, false)
		guiGridListSetItemText(PrisonGUI.gridlist[1], row, PrisonGUI.column[9], tostring(res[9]), false, false)
	end

	updateGates()

	addEventHandler("onClientGUIClick", PrisonGUI.button[1], function()
		destroyElement(PrisonGUI.window[1])
		showCursor(false)
	end, false)

	addEventHandler("onClientGUIClick", PrisonGUI.button[3], function()
		addPrisonerGUI(source)
	end, false)

	addEventHandler("onClientGUIClick", PrisonGUI.button[2], function()
		local row, column = guiGridListGetSelectedItem(PrisonGUI.gridlist[1])
		if row >= 0 and column >= 0 then
			local removeID = guiGridListGetItemText(PrisonGUI.gridlist[1], row, 1)
			local targetPlayer = getPlayerFromName(guiGridListGetItemText(PrisonGUI.gridlist[1], row, 3))

			if not isCloseTo(localPlayer, targetPlayer) then
				exports.mek_infobox:addBox(
					"error",
					"Mahkumu serbest bırakmanız için yakınında olmanız gerekmektedir."
				)
				return
			end

			triggerServerEvent("removePrisoner", resourceRoot, column, removeID, true)
		else
			exports.mek_infobox:addBox("error", "Öncelikle bir şey seçin.")
		end
	end, false)

	addEventHandler("onClientGUIClick", PrisonGUI.button[4], function()
		local row, column = guiGridListGetSelectedItem(PrisonGUI.gridlist[1])
		if row >= 0 and column >= 0 then
			local targetPlayer = getPlayerFromName(guiGridListGetItemText(PrisonGUI.gridlist[1], row, 3))
			if not isCloseTo(localPlayer, targetPlayer) then
				exports.mek_infobox:addBox(
					"error",
					"Mahkum durumunu güncellemeniz için yakınında olmanız gerekmektedir."
				)
				return
			end

			local ID = guiGridListGetItemText(PrisonGUI.gridlist[1], row, 1)
			local name = guiGridListGetItemText(PrisonGUI.gridlist[1], row, 3)
			local cell = guiGridListGetItemText(PrisonGUI.gridlist[1], row, 2)
			local days = guiGridListGetItemText(PrisonGUI.gridlist[1], row, 5)
			local hours = guiGridListGetItemText(PrisonGUI.gridlist[1], row, 6)
			local charges = guiGridListGetItemText(PrisonGUI.gridlist[1], row, 10)
			local fines = guiGridListGetItemText(PrisonGUI.gridlist[1], row, 9)
			local row = row + 1

			addPrisonerGUI(source, name, cell, days, hours, charges, row, fines, ID)
		elseif row == -1 then
			exports.mek_infobox:addBox("error", "Öncelikle bir şey seçin.")
		end
	end, false)

	addEventHandler("onClientGUIDoubleClick", PrisonGUI.gridlist[1], gridlistDoubleClick, false)

	addEventHandler("onClientGUIClick", PrisonGUI.button[5], function()
		toggleGate()
	end, false)

	addEventHandler("onClientGUIClick", PrisonGUI.button[6], function()
		local gui = {}
		gui._placeHolders = {}

		local screenWidth, screenHeight = guiGetScreenSize()
		local windowWidth, windowHeight = 265, 143
		local left = screenWidth / 2 - windowWidth / 2
		local top = screenHeight / 2 - windowHeight / 2
		gui["_root"] = guiCreateWindow(left, top, windowWidth, windowHeight, "Tüm Kapıları Aç", false)
		guiWindowSetSizable(gui["_root"], false)

		gui["label"] = guiCreateLabel(
			10,
			35,
			231,
			56,
			"Hapishanedeki bütün kapıları açmak\n istediğinizden emin misiniz?",
			false,
			gui["_root"]
		)
		guiLabelSetHorizontalAlign(gui["label"], "center", false)
		guiLabelSetVerticalAlign(gui["label"], "center")

		gui["pushButton"] = guiCreateButton(30, 95, 81, 31, "Evet", false, gui["_root"])
		addEventHandler("onClientGUIClick", gui["pushButton"], function()
			triggerServerEvent("triggerAllGates", resourceRoot)
			setTimer(updateGates, 500, 1)
			destroyElement(gui["_root"])
			local gui = nil
		end, false)

		gui["pushButton_2"] = guiCreateButton(150, 95, 81, 31, "Hayır", false, gui["_root"])
		addEventHandler("onClientGUIClick", gui["pushButton_2"], function()
			destroyElement(gui["_root"])
			local gui = nil
		end, false)
	end, false)
end
addEvent("PrisonGUI", true)
addEventHandler("PrisonGUI", root, PrisonGUIF)

addEvent("PrisonGUI:Close", true)
addEventHandler("PrisonGUI:Close", root, function()
	destroyElement(PrisonGUI.window[1])
	showCursor(false)
end)

addEvent("PrisonGUI:Kapat", true)
addEventHandler("PrisonGUI:Kapat", root, function()
	destroyElement(PrisonGUI.window[1])
	showCursor(false)
end)

function gridlistDoubleClick()
	local row, column = guiGridListGetSelectedItem(PrisonGUI.gridlist[1])
	if row >= 0 and column >= 0 then
		local targetPlayer = getPlayerFromName(guiGridListGetItemText(PrisonGUI.gridlist[1], row, 3))
		if not isCloseTo(localPlayer, targetPlayer) then
			exports.mek_infobox:addBox(
				"error",
				"Mahkum durumunu güncellemeniz için yakınında olmanız gerekmektedir."
			)
			return
		end

		local ID = guiGridListGetItemText(PrisonGUI.gridlist[1], row, 1)
		local name = guiGridListGetItemText(PrisonGUI.gridlist[1], row, 3)
		local cell = guiGridListGetItemText(PrisonGUI.gridlist[1], row, 2)
		local days = guiGridListGetItemText(PrisonGUI.gridlist[1], row, 5)
		local hours = guiGridListGetItemText(PrisonGUI.gridlist[1], row, 6)
		local charges = guiGridListGetItemText(PrisonGUI.gridlist[1], row, 10)
		local fines = guiGridListGetItemText(PrisonGUI.gridlist[1], row, 9)
		local row = row + 1

		addPrisonerGUI(source, name, cell, days, hours, charges, row, fines, ID)
	elseif row == -1 or column == -1 then
		exports.mek_infobox:addBox("error", "Öncelikle bir şey seçin.")
	end
end

addEvent("PrisonGUI:Refresh", true)
addEventHandler("PrisonGUI:Refresh", localPlayer, function(result)
	destroyElement(PrisonGUI.gridlist[1])

	PrisonGUI.gridlist[1] = guiCreateGridList(9, 21, 902, 217, false, PrisonGUI.window[1])
	guiGridListSetSortingEnabled(PrisonGUI.gridlist[1], true)
	PrisonGUI.column[1] = guiGridListAddColumn(PrisonGUI.gridlist[1], "Sıra ID", 0.1)
	PrisonGUI.column[7] = guiGridListAddColumn(PrisonGUI.gridlist[1], "Hücre", 0.05)
	PrisonGUI.column[2] = guiGridListAddColumn(PrisonGUI.gridlist[1], "İsim", 0.2)
	PrisonGUI.column[3] = guiGridListAddColumn(PrisonGUI.gridlist[1], "Mahkeme Tarihi", 0.15)
	PrisonGUI.column[4] = guiGridListAddColumn(PrisonGUI.gridlist[1], "Kalan Gün", 0.1)
	PrisonGUI.column[8] = guiGridListAddColumn(PrisonGUI.gridlist[1], "Kalan Saat", 0.1)
	PrisonGUI.column[5] = guiGridListAddColumn(PrisonGUI.gridlist[1], "Son Güncelleyen", 0.1)
	PrisonGUI.column[9] = guiGridListAddColumn(PrisonGUI.gridlist[1], "Ceza", 0.1)
	PrisonGUI.column[6] = guiGridListAddColumn(PrisonGUI.gridlist[1], "Suçlar", 0.5)

	for _, res in ipairs(result) do
		local row = guiGridListAddRow(PrisonGUI.gridlist[1])
		guiGridListSetItemText(PrisonGUI.gridlist[1], row, PrisonGUI.column[1], tostring(res[1]), false, true)
		guiGridListSetItemText(
			PrisonGUI.gridlist[1],
			row,
			PrisonGUI.column[2],
			tostring(res[3]:gsub("_", " ")),
			false,
			false
		)
		guiGridListSetItemText(PrisonGUI.gridlist[1], row, PrisonGUI.column[3], tostring(res[5]), false, false)

		if getPlayerFromName(tostring(res[3])) then
			guiGridListSetItemColor(PrisonGUI.gridlist[1], row, PrisonGUI.column[2], 0, 255, 0)
		end

		local days, hours, remainingtime = cleanMath(res[4])
		if remainingtime <= 0 then
			days = PRISONER_STATUS.Awaiting
			hours = PRISONER_STATUS.OnlineTime
		end

		guiGridListSetItemText(PrisonGUI.gridlist[1], row, PrisonGUI.column[4], tostring(days), false, false)
		guiGridListSetItemText(PrisonGUI.gridlist[1], row, PrisonGUI.column[8], tostring(hours), false, false)

		if days == PRISONER_STATUS.LifeTime then
			guiGridListSetItemColor(PrisonGUI.gridlist[1], row, PrisonGUI.column[4], 255, 0, 0)
			guiGridListSetItemColor(PrisonGUI.gridlist[1], row, PrisonGUI.column[8], 255, 0, 0)
		elseif days == PRISONER_STATUS.Awaiting and hours == PRISONER_STATUS.Release then
			guiGridListSetItemColor(PrisonGUI.gridlist[1], row, PrisonGUI.column[4], 255, 255, 0)
			guiGridListSetItemColor(PrisonGUI.gridlist[1], row, PrisonGUI.column[8], 255, 255, 0)
		elseif hours == PRISONER_STATUS.OnlineTime then
			guiGridListSetItemColor(PrisonGUI.gridlist[1], row, PrisonGUI.column[4], 0, 93, 1)
			guiGridListSetItemColor(PrisonGUI.gridlist[1], row, PrisonGUI.column[8], 0, 93, 1)
		end

		guiGridListSetItemText(
			PrisonGUI.gridlist[1],
			row,
			PrisonGUI.column[5],
			tostring(res[6]:gsub("_", " ")),
			false,
			false
		)
		guiGridListSetItemText(PrisonGUI.gridlist[1], row, PrisonGUI.column[6], tostring(res[7]), false, false)
		guiGridListSetItemText(PrisonGUI.gridlist[1], row, PrisonGUI.column[7], tostring(res[8]), false, false)
		guiGridListSetItemText(PrisonGUI.gridlist[1], row, PrisonGUI.column[9], tostring(res[9]), false, false)
	end

	addEventHandler("onClientGUIDoubleClick", PrisonGUI.gridlist[1], gridlistDoubleClick, false)
end, false)

function addPrisonerGUI(source, name, cell, days, hours, charges, row, fines, jailID)
	if isElement(newPrisonerGUI.window[1]) then
		destroyElement(newPrisonerGUI.window[1])
	end

	local arrestLocation = isInArrestColshape(localPlayer)
	if arrestLocation then
		local scr = { guiGetScreenSize() }
		local w, h = 329, 279
		local x, y = (scr[1] / 2) - (w / 2), (scr[2] / 2) - (h / 2)
		guiSetInputEnabled(true)
		newPrisonerGUI.window[1] = guiCreateWindow(x, y, w, h, "Yeni Mahkum Ekle", false)
		guiWindowSetSizable(newPrisonerGUI.window[1], false)

		newPrisonerGUI.button[1] = guiCreateButton(13, 241, 123, 28, "İptal", false, newPrisonerGUI.window[1])
		guiSetProperty(newPrisonerGUI.button[1], "NormalTextColour", "FFAAAAAA")
		newPrisonerGUI.button[2] = guiCreateButton(170, 241, 123, 28, "Mahkum ekle", false, newPrisonerGUI.window[1])
		guiSetProperty(newPrisonerGUI.button[2], "NormalTextColour", "FFAAAAAA")
		newPrisonerGUI.edit[5] = guiCreateEdit(150, 48, 66, 20, "", false, newPrisonerGUI.window[1])
		guiSetText(newPrisonerGUI.edit[5], "0")
		newPrisonerGUI.edit[1] = guiCreateEdit(79, 21, 140, 21, "", false, newPrisonerGUI.window[1])

		if source == PrisonGUI.button[3] then
			newPrisonerGUI.label[1] = guiCreateLabel(13, 22, 67, 15, "Tam adı:", false, newPrisonerGUI.window[1])
			guiSetFont(newPrisonerGUI.label[1], "default-bold-small")
			newPrisonerGUI.label[4] = guiCreateLabel(226, 25, 72, 17, "Bulunamadı.", false, newPrisonerGUI.window[1])
			guiLabelSetColor(newPrisonerGUI.label[4], 255, 0, 0)
			guiSetEnabled(newPrisonerGUI.button[2], false)
			addEventHandler("onClientGUIChanged", newPrisonerGUI.edit[1], checkNameExists)
		elseif source == PrisonGUI.button[7] then
			newPrisonerGUI.label[1] = guiCreateLabel(15, 22, 67, 15, "Tam adı:", false, newPrisonerGUI.window[1])
			guiSetFont(newPrisonerGUI.label[1], "default-bold-small")
			guiSetEnabled(newPrisonerGUI.edit[5], false)
		end

		newPrisonerGUI.label[2] = guiCreateLabel(12, 147, 77, 15, "Suçlar:", false, newPrisonerGUI.window[1])
		guiSetFont(newPrisonerGUI.label[2], "default-bold-small")
		newPrisonerGUI.memo[1] = guiCreateMemo(11, 162, 308, 69, "", false, newPrisonerGUI.window[1])
		newPrisonerGUI.label[3] = guiCreateLabel(14, 48, 30, 15, "Hücre:", false, newPrisonerGUI.window[1])
		guiSetFont(newPrisonerGUI.label[3], "default-bold-small")
		newPrisonerGUI.edit[2] = guiCreateComboBox(45, 48, 66, 200, "", false, newPrisonerGUI.window[1])

		newPrisonerGUI.label[8] = guiCreateLabel(120, 48, 30, 15, "Ceza:", false, newPrisonerGUI.window[1])
		guiSetFont(newPrisonerGUI.label[8], "default-bold-small")
		guiEditSetMaxLength(newPrisonerGUI.edit[5], 6)

		newPrisonerGUI.label[5] = guiCreateLabel(13, 96, 51, 15, "Gün:", false, newPrisonerGUI.window[1])
		guiSetFont(newPrisonerGUI.label[5], "default-bold-small")
		newPrisonerGUI.label[6] =
			guiCreateLabel(7, 77, 301, 15, "============Mahkumiyet Zamanı==========", false, newPrisonerGUI.window[1])
		guiLabelSetHorizontalAlign(newPrisonerGUI.label[6], "center", false)
		newPrisonerGUI.label[7] = guiCreateLabel(148, 96, 51, 15, "Saat:", false, newPrisonerGUI.window[1])
		guiSetFont(newPrisonerGUI.label[7], "default-bold-small")
		newPrisonerGUI.edit[3] = guiCreateEdit(60, 97, 78, 40, "", false, newPrisonerGUI.window[1])
		newPrisonerGUI.edit[4] = guiCreateEdit(199, 96, 83, 41, "", false, newPrisonerGUI.window[1])
		guiSetText(newPrisonerGUI.edit[3], "0")
		guiSetText(newPrisonerGUI.edit[4], "0")

		if name then
			guiSetText(newPrisonerGUI.edit[1], name)
			guiSetText(newPrisonerGUI.edit[2], cell)
			guiSetText(newPrisonerGUI.edit[3], days)
			guiSetText(newPrisonerGUI.edit[4], hours)
			guiSetText(newPrisonerGUI.memo[1], charges)
			guiSetText(newPrisonerGUI.edit[5], fines)
			guiSetText(newPrisonerGUI.window[1], "Mahkumu Güncelle")
			guiSetText(newPrisonerGUI.button[2], "Mahkumu Güncelle")

			guiSetEnabled(newPrisonerGUI.edit[1], false)
			guiSetEnabled(newPrisonerGUI.edit[5], false)

			if not tonumber(days) then
				guiSetEnabled(newPrisonerGUI.edit[3], false)
				guiSetEnabled(newPrisonerGUI.edit[4], false)
			end

			comboNum = -1
			for _, value in pairs(getCells(arrestLocation)) do
				guiComboBoxAddItem(newPrisonerGUI.edit[2], _)
				comboNum = comboNum + 1
			end

			guiComboBoxAddItem(newPrisonerGUI.edit[2], cell)
			guiComboBoxSetSelected(newPrisonerGUI.edit[2], comboNum + 1)
		else
			for _, value in pairs(getCells(arrestLocation)) do
				guiComboBoxAddItem(newPrisonerGUI.edit[2], _)
			end
		end

		addEventHandler("onClientGUIClick", newPrisonerGUI.button[2], function()
			if overLimit(guiGetText(newPrisonerGUI.edit[3]), guiGetText(newPrisonerGUI.edit[4])) then
				exports.mek_infobox:addBox(
					"error",
					tonumber(hourLimit) .. " saat sınırının üzerinde birini hapse atmaya çalışıyorsunuz."
				)
				return
			end

			local item = guiComboBoxGetSelected(newPrisonerGUI.edit[2])
			if item == -1 then
				exports.mek_infobox:addBox("error", "Öncelikle bir hücre seçiniz.")
				return
			end

			if string.len(guiGetText(newPrisonerGUI.edit[1])) > 0 then
				local cell = guiComboBoxGetItemText(newPrisonerGUI.edit[2], item)
				if source == PrisonGUI.button[3] then
					if tonumber(guiGetText(newPrisonerGUI.edit[5])) <= 100000 then
						if
							tonumber(guiGetText(newPrisonerGUI.edit[4]))
								+ tonumber(guiGetText(newPrisonerGUI.edit[3]))
							>= 1
						then
							triggerServerEvent(
								"addPrisoner",
								resourceRoot,
								user,
								cell,
								guiGetText(newPrisonerGUI.edit[3]),
								guiGetText(newPrisonerGUI.edit[4]),
								guiGetText(newPrisonerGUI.memo[1]),
								math.floor(guiGetText(newPrisonerGUI.edit[5])),
								true
							)
						else
							exports.mek_infobox:addBox("error", "Lütfen daha yüksek bir kefalet miktarı girin.")
						end
					else
						exports.mek_infobox:addBox("error", "Maksimum ceza miktarı: ₺100,000")
					end
				elseif source == PrisonGUI.button[4] or source == PrisonGUI.gridlist[1] then
					online = false
					name = guiGetText(newPrisonerGUI.edit[1])
					local players = getElementsByType("player")
					for key, value in ipairs(players) do
						if getPlayerName(value) == guiGetText(newPrisonerGUI.edit[1]) then
							name = value
							online = true
						end
					end
					triggerServerEvent(
						"changePrisoner",
						resourceRoot,
						name,
						cell,
						guiGetText(newPrisonerGUI.edit[3]),
						guiGetText(newPrisonerGUI.edit[4]),
						guiGetText(newPrisonerGUI.memo[1]),
						jailID,
						online
					)
				else
					if
						tonumber(guiGetText(newPrisonerGUI.edit[4])) + tonumber(guiGetText(newPrisonerGUI.edit[3])) > 1
					then
						triggerServerEvent(
							"addPrisoner",
							resourceRoot,
							guiGetText(newPrisonerGUI.edit[1]),
							cell,
							guiGetText(newPrisonerGUI.edit[3]),
							guiGetText(newPrisonerGUI.edit[4]),
							guiGetText(newPrisonerGUI.memo[1]),
							math.floor(guiGetText(newPrisonerGUI.edit[5])),
							false
						)
					else
						exports.mek_infobox:addBox("error", "Lütfen daha yüksek bir kefalet miktarı girin.")
					end
				end
				destroyElement(newPrisonerGUI.window[1])
				guiSetInputEnabled(false)
			else
				exports.mek_infobox:addBox("error", "Öncelikle bir kişi ismi girin.")
			end
		end, false)

		addEventHandler("onClientGUIClick", newPrisonerGUI.button[1], function()
			destroyElement(newPrisonerGUI.window[1])
			guiSetInputEnabled(false)
		end, false)
	else
		exports.mek_infobox:addBox("error", "Tutuklama bölgesinde olmalısınız.")
	end
end

function toggleGate()
	if isElement(ToggleGateGUI.window[1]) then
		destroyElement(ToggleGateGUI.window[1])
	end

	local scr = { guiGetScreenSize() }
	local w, h = 272, 200
	local x, y = (scr[1] / 2) - (w / 2), (scr[2] / 2) - (h / 2)
	ToggleGateGUI.window[1] = guiCreateWindow(x, y, w, h, "Kapı Yönetimi", false)
	guiWindowSetSizable(ToggleGateGUI.window[1], false)

	ToggleGateGUI.combobox[1] = guiCreateComboBox(9, 25, 253, 200, "", false, ToggleGateGUI.window[1])
	ToggleGateGUI.button[1] = guiCreateButton(11, 54, 120, 37, "Kapıyı Aç/Kapat", false, ToggleGateGUI.window[1])
	guiSetProperty(ToggleGateGUI.button[1], "NormalTextColour", "FFAAAAAA")
	ToggleGateGUI.button[2] = guiCreateButton(136, 54, 120, 37, "İptal", false, ToggleGateGUI.window[1])
	guiSetProperty(ToggleGateGUI.button[2], "NormalTextColour", "FFAAAAAA")
	ToggleGateGUI.label[1] = guiCreateLabel(183, 120, 45, 20, "Açık", false, ToggleGateGUI.window[1])
	ToggleGateGUI.label[2] = guiCreateLabel(183, 140, 40, 20, "Kapalı", false, ToggleGateGUI.window[1])
	guiLabelSetColor(ToggleGateGUI.label[1], 0, 255, 0)
	guiLabelSetColor(ToggleGateGUI.label[2], 255, 0, 0)
	local tab = 2
	currentx = 13
	currenty = 100
	for _, value in pairs(getElementData(resourceRoot, "gates")) do
		local tab = tab + 1
		guiComboBoxAddItem(ToggleGateGUI.combobox[1], _)
		ToggleGateGUI.label[tab] = guiCreateLabel(currentx, currenty, 30, 20, _, false, ToggleGateGUI.window[1])
		if value[14] == 0 then
			guiLabelSetColor(ToggleGateGUI.label[tab], 255, 0, 0)
		else
			guiLabelSetColor(ToggleGateGUI.label[tab], 0, 255, 0)
		end
		currenty = currenty + 15
		if currenty == 190 then
			currentx = currentx + 40
			currenty = 100
		end
	end

	addEventHandler("onClientGUIClick", ToggleGateGUI.button[1], function()
		local item = guiComboBoxGetSelected(ToggleGateGUI.combobox[1])
		if item > -1 then
			local gateID = guiComboBoxGetItemText(ToggleGateGUI.combobox[1], item)
			triggerServerEvent("triggerAGate", resourceRoot, gateID)
			destroyElement(ToggleGateGUI.window[1])
			setTimer(updateGates, 500, 1)
		else
			exports.mek_infobox:addBox("error", "Öncelikle bir kapı seçin.")
		end
	end, false)

	addEventHandler("onClientGUIClick", ToggleGateGUI.button[2], function()
		destroyElement(ToggleGateGUI.window[1])
	end, false)
end

function checkNameExists()
	local found = nil
	local count = 0

	local text = guiGetText(newPrisonerGUI.edit[1])
	if text and #text > 0 then
		local players = getElementsByType("player")
		if tonumber(text) then
			local id = tonumber(text)
			for key, value in ipairs(players) do
				if getElementData(value, "id") == id then
					found = value
					count = 1
					break
				end
			end
		elseif text == "*" then
			found = localPlayer
			count = 1
		else
			for key, value in ipairs(players) do
				local username = string.lower(tostring(getPlayerName(value)))
				if string.find(username, string.lower(text)) then
					count = count + 1
					found = value
					break
				end
			end
		end
	end

	if count > 1 then
		guiSetText(newPrisonerGUI.label[4], "Birden fazla eşleşme mevcut.")
		guiLabelSetColor(newPrisonerGUI.label[4], 255, 255, 0)
		guiSetEnabled(newPrisonerGUI.button[2], false)
	elseif count == 1 then
		guiSetText(newPrisonerGUI.label[4], "(ID #" .. getElementData(found, "id") .. ")")
		guiLabelSetColor(newPrisonerGUI.label[4], 0, 255, 0)
		user = found
		guiSetEnabled(newPrisonerGUI.button[2], true)
	elseif count == 0 then
		guiSetText(newPrisonerGUI.label[4], "Bulunamadı.")
		guiLabelSetColor(newPrisonerGUI.label[4], 255, 0, 0)
		guiSetEnabled(newPrisonerGUI.button[2], false)
	end
end

function overLimit(days, hours)
	if hourLimit == 0 then
		return false
	end

	local days = tonumber(days) * 24
	local hours = tonumber(hours)

	if not days or not hours then
		return true
	end

	local sum = days + hours

	if sum > hourLimit then
		return true
	end

	return false
end

function updateGates()
	if isElement(PrisonGUI.label[1]) then
		destroyElement(PrisonGUI.label[1])
		destroyElement(PrisonGUI.label[2])
	end

	closed = 0
	open = 0

	for _, res in pairs(getElementData(resourceRoot, "gates")) do
		if res[14] == 0 then
			closed = closed + 1
		else
			open = open + 1
		end
	end

	PrisonGUI.label[1] = guiCreateLabel(750, 287, 100, 30, open .. " Kapı Açık", false, PrisonGUI.window[1])
	PrisonGUI.label[2] = guiCreateLabel(750, 247, 100, 30, closed .. " Kapı Kapalı", false, PrisonGUI.window[1])
	guiLabelSetColor(PrisonGUI.label[1], 0, 255, 0)
	guiLabelSetColor(PrisonGUI.label[2], 255, 0, 0)
end

addEventHandler("onClientResourceStart", resourceRoot, function()
	local ped = createPed(283, 1817.162109375, -1539.296875, 60.15625)
	setPedAnimation(ped, "COP_AMBIENT", "Coplook_loop", -1, true, false, false)
	setElementFrozen(ped, true)
	setElementRotation(ped, 0, 0, 179)
	setElementDimension(ped, 116)
	setElementInterior(ped, 47)

	setElementData(ped, "name", "Kadir Ateş", false)

	addEventHandler("onClientPedWasted", ped, function()
		setTimer(function()
			destroyElement(ped)
			createShopPed()
		end, 20000, 1)
	end, false)

	addEventHandler("onClientPedDamage", ped, cancelEvent, false)
end)

function renderJailUI()
	local days, hours, remainingTime = cleanMath(getElementData(localPlayer, "pd_jail_time"))
	if not remainingTime then
		removeEventHandler("onClientRender", root, renderJailUI)
		return
	elseif remainingTime <= 0 then
		local currentTick = getTickCount()
		if not lastCheckTime or (currentTick - lastCheckTime) > 5000 then 
			triggerServerEvent("prison.checkJail", localPlayer)
			lastCheckTime = currentTick
		end
		return
	end

	local charges = getElementData(localPlayer, "pd_jail_charges") or "?"

	local fonts = useFonts()
	local theme = useTheme()

	local innerText = ("Kalan Süre: %s gün, %s saat\nSuçlar: %s"):format(days, hours, charges)
	local textWidth = dxGetTextWidth(innerText, 1, fonts.UbuntuRegular.body) + 20
	local textHeight = 50
	local sectionPosX, sectionPosY = screenSize.x / 2 - textWidth / 2, screenSize.y - 75

	dxDrawRectangle(sectionPosX, sectionPosY, textWidth, textHeight, tocolor(0, 0, 0, 200))
	dxDrawText(
		innerText,
		sectionPosX,
		sectionPosY,
		sectionPosX + textWidth,
		sectionPosY + textHeight,
		rgba(theme.GRAY[300]),
		1,
		fonts.UbuntuRegular.body,
		"center",
		"center"
	)
end

addEventHandler("onClientResourceStart", resourceRoot, function()
	if getElementData(localPlayer, "pd_jail_time") then
		if not isEventHandlerAdded("onClientRender", root, renderJailUI) then
			addEventHandler("onClientRender", root, renderJailUI)
		end
	end
end)

addEventHandler("onClientElementDataChange", localPlayer, function(dataName, _, newValue)
	if dataName ~= "pd_jail_time" then
		return
	end

	if newValue then
		if not isEventHandlerAdded("onClientRender", root, renderJailUI) then
			addEventHandler("onClientRender", root, renderJailUI)
		end
	else
		if isEventHandlerAdded("onClientRender", root, renderJailUI) then
			removeEventHandler("onClientRender", root, renderJailUI)
		end
	end
end)
