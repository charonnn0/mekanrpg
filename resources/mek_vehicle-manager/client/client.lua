local vehList1 = {}
local vehTabPanel = false
local sx, sy = guiGetScreenSize()

local targetTab = {}
local targetList = {}
local colID = {}
local colPlate = {}
local colName = {}
local colPlate = {}
local colLastUsed = {}
local colCarHP = {}
local colTinted = {}
local colOwner = {}
local colDeleted = {}
local colCreatedBy = {}
local colCreatedDate = {}
local colRegistered = {}

function createVehManagerWindow(data)
	if not exports.mek_integration:isPlayerManager(localPlayer) then
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", 255, 0, 0, true)
		return
	end

	if gWin then
		closeVehManager()
	end

	showCursor(true)

	gWin = guiCreateWindow(sx / 2 - 400, sy / 2 - 300, 800, 600, "Araç Yöneticisi", false)
	guiWindowSetSizable(gWin, false)
	vehTabPanel = guiCreateTabPanel(0.0113, 0.1417, 0.9775, 0.8633, true, gWin)

	bDelVeh = guiCreateButton(0.0113, 0.035, 0.0938, 0.045, "Sil", true, gWin)
	guiSetFont(bDelVeh, "default-bold-small")
	bRestoreVeh = guiCreateButton(0.0113, 0.085, 0.0938, 0.045, "Düzelt", true, gWin)
	guiSetFont(bRestoreVeh, "default-bold-small")

	bToggleInt = guiCreateButton(0.1175, 0.035, 0.1, 0.045, "Kütüphane", true, gWin)
	guiSetFont(bToggleInt, "default-bold-small")
	bGotoVeh = guiCreateButton(0.1175, 0.085, 0.1, 0.045, "Işınlan", true, gWin)
	guiSetFont(bGotoVeh, "default-bold-small")

	bRemoveVeh = guiCreateButton(0.23, 0.085, 0.1, 0.045, "Kaldır", true, gWin)
	guiSetFont(bRemoveVeh, "default-bold-small")

	bAdminNote = guiCreateButton(0.3425, 0.035, 0.1, 0.045, "Kontrol Et", true, gWin)
	guiSetFont(bAdminNote, "default-bold-small")
	bSearch = guiCreateButton(0.3425, 0.085, 0.1, 0.045, "Ara", true, gWin)
	guiSetFont(bSearch, "default-bold-small")

	bClose = guiCreateButton(0.455, 0.035, 0.1, 0.09, "Kapat", true, gWin)
	guiSetFont(bClose, "default-bold-small")

	targetTab[1] = guiCreateTab("Standart Araçlar", vehTabPanel)
	targetTab[2] = guiCreateTab("Benzersiz Araçlar", vehTabPanel)

	targetList[1] = guiCreateGridList(0, 0, 1, 1, true, targetTab[1])
	targetList[2] = guiCreateGridList(0, 0, 1, 1, true, targetTab[2])

	for i = 1, 2 do
		colID[i] = guiGridListAddColumn(targetList[i], "ID", 0.07)
		colName[i] = guiGridListAddColumn(targetList[i], "İsim", 0.3)
		colPlate[i] = guiGridListAddColumn(targetList[i], "Plaka", 0.1)
		colTinted[i] = guiGridListAddColumn(targetList[i], "Cam Filmi", 0.05)
		colRegistered[i] = guiGridListAddColumn(targetList[i], "Kayıtlı", 0.05)
		colLastUsed[i] = guiGridListAddColumn(targetList[i], "Son Kullanılan", 0.1)
		colCarHP[i] = guiGridListAddColumn(targetList[i], "HP", 0.06)
		colOwner[i] = guiGridListAddColumn(targetList[i], "Sahibi", 0.15)
	end

	local allVehicles = getElementsByType("vehicle")
	local standardVehs = {}
	local uniqueVehs = {}
	for index, veh in ipairs(allVehicles) do
		if (getElementData(veh, "dbid") or 0) > 0 then
			if getElementData(veh, "unique") then
				table.insert(uniqueVehs, veh)
			else
				table.insert(standardVehs, veh)
			end
		end
	end

	local disabledVehicles = {}
	local ckedVehicles = {}
	local inactiveVehicles = {}
	local deletedVehicles = {}

	local lTotal = guiCreateLabel(
		460,
		25,
		164,
		17,
		"Standart Araçlar: " .. exports.mek_global:formatMoney(#standardVehs),
		false,
		gWin
	)
	local lActive = guiCreateLabel(
		460,
		42,
		164,
		17,
		"Benzersiz Araçlar: " .. exports.mek_global:formatMoney(#uniqueVehs),
		false,
		gWin
	)

	loadTab(standardVehs, 1)
	loadTab(uniqueVehs, 2)

	function getListFromActiveTab(vehTabPanel)
		if vehTabPanel then
			if guiGetSelectedTab(vehTabPanel) == targetTab[1] then
				return targetList[1], 1
			elseif guiGetSelectedTab(vehTabPanel) == targetTab[2] then
				return targetList[2], 2
			elseif guiGetSelectedTab(vehTabPanel) == targetTab[3] then
				return targetList[3], 3
			elseif guiGetSelectedTab(vehTabPanel) == targetTab[4] then
				return targetList[4], 4
			elseif guiGetSelectedTab(vehTabPanel) == targetTab[5] then
				return targetList[5], 5
			elseif guiGetSelectedTab(vehTabPanel) == targetTab[6] then
				return targetList[6], 6
			else
				return false, false
			end
		else
			return false, false
		end
	end

	addEventHandler("onClientGUIClick", bClose, function()
		if source == bClose then
			closeVehManager()
		end
	end)

	addEventHandler("onClientGUIClick", bSearch, function(button)
		if button == "left" then
			showCursor(true)
			guiSetInputEnabled(true)
			wInteriorSearch = guiCreateWindow(sx / 2 - 176, sy / 2 - 52, 352, 104, "Araç Arama", false)
			guiWindowSetSizable(wInteriorSearch, false)

			local lText = guiCreateLabel(
				10,
				22,
				341,
				16,
				"Bir araçla ilgili tüm bilgileri girin (ID, İsim, Sahibi, Model, ...):",
				false,
				wInteriorSearch
			)
			guiSetFont(lText, "default-small")

			local eSearch = guiCreateEdit(10, 38, 331, 31, "Ara...", false, wInteriorSearch)
			addEventHandler("onClientGUIFocus", eSearch, function()
				guiSetText(eSearch, "")
			end, false)

			local bCancel = guiCreateButton(10, 73, 169, 22, "İptal", false, wInteriorSearch)
			guiSetFont(bCancel, "default-bold-small")
			addEventHandler("onClientGUIClick", bCancel, function(button)
				if button == "left" and wInteriorSearch then
					destroyElement(wInteriorSearch)
					wInteriorSearch = nil
				end
			end, false)

			local bGo = guiCreateButton(179, 73, 162, 22, "Işınlan", false, wInteriorSearch)
			guiSetFont(bGo, "default-bold-small")
			addEventHandler("onClientGUIClick", bGo, function(button)
				if button == "left" and wInteriorSearch then
					triggerServerEvent("vehicleManager.search", localPlayer, guiGetText(eSearch))
					destroyElement(wInteriorSearch)
					wInteriorSearch = nil
				end
			end, false)
		end
	end, false)

	addEventHandler("onClientGUIClick", bDelVeh, function(button)
		if button == "left" then
			local row, col = -1, -1
			local activeList = getListFromActiveTab(vehTabPanel)
			if activeList then
				local row, col = guiGridListGetSelectedItem(activeList)
				if row ~= -1 and col ~= -1 then
					local gridID = guiGridListGetItemText(activeList, row, 1)
					triggerServerEvent("vehicleManager.delVeh", localPlayer, gridID)
				else
					guiSetText(gWin, "Öncelikle aşağıdaki listeden bir araç seçmeniz gerekiyor.")
				end
			end
		end
	end, false)

	addEventHandler("onClientGUIClick", bToggleInt, function(button)
		if button == "left" then
			triggerServerEvent("vehicleManager.sendLibraryToClient", localPlayer)
		end
	end, false)

	addEventHandler("onClientGUIClick", bGotoVeh, function(button)
		if button == "left" then
			local row, col = -1, -1
			local activeList = getListFromActiveTab(vehTabPanel)
			if activeList then
				local row, col = guiGridListGetSelectedItem(activeList)
				if row ~= -1 and col ~= -1 then
					local gridID = guiGridListGetItemText(activeList, row, 1)
					triggerServerEvent("vehicleManager.gotoVeh", localPlayer, gridID)
				else
					guiSetText(gWin, "Öncelikle aşağıdaki listeden bir araç seçmeniz gerekiyor.")
				end
			end
		end
	end, false)

	addEventHandler("onClientGUIClick", bRestoreVeh, function(button)
		if button == "left" then
			local row, col = -1, -1
			local activeList = getListFromActiveTab(vehTabPanel)
			if activeList then
				local row, col = guiGridListGetSelectedItem(activeList)
				if row ~= -1 and col ~= -1 then
					local gridID = guiGridListGetItemText(activeList, row, 1)
					triggerServerEvent("vehicleManager.restoreVeh", localPlayer, gridID)
				else
					guiSetText(gWin, "Öncelikle aşağıdaki listeden bir araç seçmeniz gerekiyor.")
				end
			end
		end
	end, false)

	addEventHandler("onClientGUIClick", bRemoveVeh, function(button)
		if button == "left" then
			local row, col = -1, -1
			local activeList = getListFromActiveTab(vehTabPanel)
			if activeList then
				local row, col = guiGridListGetSelectedItem(activeList)
				if row ~= -1 and col ~= -1 then
					local gridID = guiGridListGetItemText(activeList, row, 1)
					triggerServerEvent("vehicleManager.removeVeh", localPlayer, gridID)
				else
					guiSetText(gWin, "Öncelikle aşağıdaki listeden bir araç seçmeniz gerekiyor.")
				end
			end
		end
	end, false)

	addEventHandler("onClientGUIClick", bForceSell, function(button)
		if button == "left" then
			local row, col = -1, -1
			local activeList = getListFromActiveTab(vehTabPanel)
			if activeList then
				local row, col = guiGridListGetSelectedItem(activeList)
				if row ~= -1 and col ~= -1 then
					local gridID = guiGridListGetItemText(activeList, row, 1)
					triggerServerEvent("vehicleManager.forceSellInt", localPlayer, gridID)
				else
					guiSetText(gWin, "Öncelikle aşağıdaki listeden bir araç seçmeniz gerekiyor.")
				end
			end
		end
	end, false)

	addEventHandler("onClientGUIClick", bAdminNote, function(button)
		if button == "left" then
			local row, col = -1, -1
			local activeList = getListFromActiveTab(vehTabPanel)
			if activeList then
				local row, col = guiGridListGetSelectedItem(activeList)
				if row ~= -1 and col ~= -1 then
					local gridID = guiGridListGetItemText(activeList, row, 1)
					triggerServerEvent("vehicleManager.openAdminNote", localPlayer, gridID)
				else
					guiSetText(gWin, "Öncelikle aşağıdaki listeden bir araç seçmeniz gerekiyor.")
				end
			end
		end
	end, false)

	function fetchSearchResults(interiorsResultList)
		if interiorsResultList then
			local i = 4
			guiGridListClear(targetList[i])
			local activeList, index = getListFromActiveTab(vehTabPanel)
			if index ~= i then
				guiSetSelectedTab(vehTabPanel, targetTab[i])
			end
			for _, record in ipairs(interiorsResultList) do
				local row = guiGridListAddRow(targetList[i])
				guiGridListSetItemText(targetList[i], row, colID[i], record.id or "?", false, true)
				guiGridListSetItemText(targetList[i], row, colName[i], "", false, false)
				guiGridListSetItemText(
					targetList[i],
					row,
					colPlate[i],
					record.plate,
					false,
					false
				)
				guiGridListSetItemText(
					targetList[i],
					row,
					colRegistered[i],
					record.registered == "1" and "Evet" or "Hayır",
					false,
					false
				)
				guiGridListSetItemText(
					targetList[i],
					row,
					colOwner[i],
					exports.mek_cache:getCharacterNameFromID(getElementData(veh, "owner")) or "Bilinmiyor",
					false,
					false
				)
				guiGridListSetItemText(
					targetList[i],
					row,
					colLastUsed[i],
					formatLastUsed(record.last_used_sec),
					false,
					false
				)
				guiGridListSetItemText(targetList[i], row, colCarHP[i], math.round(tonumber(record.hp)), false, false)
				guiGridListSetItemText(
					targetList[i],
					row,
					colTinted[i],
					record.tinted == "1" and "Evet" or "Hayır",
					false,
					false
				)
			end
		end
	end
	addEvent("vehicleManager.FetchSearchResults", true)
	addEventHandler("vehicleManager.FetchSearchResults", localPlayer, fetchSearchResults)
end
addEvent("createVehManagerWindow", true)
addEventHandler("createVehManagerWindow", localPlayer, createVehManagerWindow)
addCommandHandler("vehicles", createVehManagerWindow)
addCommandHandler("vehs", createVehManagerWindow)

function loadTab(vehs, i)
	for index, veh in ipairs(vehs) do
		local row = guiGridListAddRow(targetList[i])
		guiGridListSetItemText(targetList[i], row, colID[i], getElementData(veh, "dbid") or "?", false, true)
		guiGridListSetItemText(targetList[i], row, colName[i], exports.mek_global:getVehicleName(veh), false, false)
		guiGridListSetItemText(
			targetList[i],
			row,
			colPlate[i],
			getElementData(veh, "plate"),
			false,
			false
		)
		guiGridListSetItemText(
			targetList[i],
			row,
			colRegistered[i],
			getElementData(veh, "registered") == 1 and "Evet" or "Hayır",
			false,
			false
		)
		guiGridListSetItemText(
			targetList[i],
			row,
			colOwner[i],
			exports.mek_cache:getCharacterNameFromID(getElementData(veh, "owner")) or "Bilinmiyor",
			false,
			false
		)
		guiGridListSetItemText(
			targetList[i],
			row,
			colLastUsed[i],
			formatLastUsed(getElementData(veh, "last_used_sec")),
			false,
			false
		)
		guiGridListSetItemText(targetList[i], row, colCarHP[i], math.round(getElementHealth(veh)), false, false)
		guiGridListSetItemText(
			targetList[i],
			row,
			colTinted[i],
			getElementData(veh, "tinted") and "Evet" or "Hayır",
			false,
			false
		)
	end
end

function formatLastUsed(sec)
	if sec or not tonumber(sec) then
		return "Asla"
	else
		return exports.mek_datetime:formatTimeInterval(sec) .. " önce"
	end
end

function formartDays(days)
	if not days then
		return "Bilinmiyor", false
	elseif tonumber(days) == 0 then
		return "Today", false
	elseif tonumber(days) >= 14 then
		return days .. " gün önce (in-aktif)", true
	else
		return days .. " gün önce", false
	end
end

function intTypeName(intType)
	local intTypeName = "Bilinmiyor"
	if intType == "0" then
		intTypeName = "House"
	elseif intType == "1" then
		intTypeName = "Business"
	elseif intType == "2" then
		intTypeName = "Government"
	elseif intType == "3" then
		intTypeName = "Rentable"
	end
	return intTypeName
end

function cked(ckStatus)
	local cked = ""
	if ckStatus == "1" then
		cked = " - CKlı"
	end
	return cked
end

function charName(name)
	local charName = ""
	if name then
		charName = name:gsub("_", " ")
	end
	return charName
end

function accountName(name)
	local accountName = ""
	if name then
		accountName = " (" .. name .. ")"
	end
	return accountName
end

function closeVehManager()
	if gWin then
		removeEventHandler("onClientGUIClick", root, singleClickedGate)
		destroyElement(gWin)
		gWin = nil
		if wInteriorSearch then
			destroyElement(wInteriorSearch)
			wInteriorSearch = nil
		end
		showCursor(false)
		guiSetInputEnabled(false)
		vehTabPanel = nil
	end
end

function singleClickedGate()
	if source == bClose then
		closeVehManager()
	end
end

local bAddNote = nil
local gAdminNote = nil
local newNoteLabel, newNoteMemo = nil
local notes = {}
local currentNote = nil

function drawAdminNotes(tabAdminNote)
	if tabAdminNote and isElement(tabAdminNote) then
		cleanAllNotesGUI()
		guiSetText(bAddNote, "Yeni Not Ekle")
		gAdminNote = guiCreateGridList(0, 0, 1, 1, true, tabAdminNote)
		local note_colDate = guiGridListAddColumn(gAdminNote, "Tarih", 0.25)
		local note_colNote = guiGridListAddColumn(gAdminNote, "İçerik", 0.5)
		local note_colCreator = guiGridListAddColumn(gAdminNote, "Yaratıcı", 0.1)
		local note_colNoteID = guiGridListAddColumn(gAdminNote, "Not Girişi", 0.1)
		for i, note in ipairs(notes) do
			local row = guiGridListAddRow(gAdminNote)
			guiGridListSetItemText(gAdminNote, row, note_colDate, note.date, false, true)
			guiGridListSetItemText(gAdminNote, row, note_colNote, note.note, false, false)
			guiGridListSetItemText(gAdminNote, row, note_colCreator, note.creatorname, false, false)
			guiGridListSetItemText(gAdminNote, row, note_colNoteID, note.id, false, false)
		end
		addEventHandler("onClientGUIDoubleClick", gAdminNote, function(button, state)
			if source == gAdminNote then
				local row, col = guiGridListGetSelectedItem(source)
				if row ~= -1 and col ~= -1 then
					local noteID = guiGridListGetItemText(source, row, 4)
					drawNewNote(tabAdminNote, #notes < 1, noteID, button == "left")
				end
			end
		end)
	end
end

function drawNewNote(tabAdminNote, isNotesEmpty, noteID, editExiting)
	if tabAdminNote and isElement(tabAdminNote) then
		cleanAllNotesGUI()
		guiSetText(bAddNote, "Notları Göster")
		local margin = 0.01
		local textH = 0.1
		local text = "Aşağıda yeni bir not girişi oluşturabilirsiniz:"
		if noteID then
			currentNote = getNoteFromID(noteID)
			if editExiting then
				text = "Not düzenleniyor #"
					.. noteID
					.. " tarafından "
					.. currentNote.creatorname
					.. ". Bu notun sahibi düzenleme tamamlandıktan sonra siz olacaksınız:"
				currentNote.edit = true
			else
				text = "Not görüntüleniyor #"
					.. noteID
					.. " tarafından "
					.. currentNote.creatorname
					.. ". Düzenlemek için sol çift tıklayın."
			end
		elseif isNotesEmpty then
			text = "Bu araçta herhangi bir not bulunamadı. " .. text
		end
		local curMemo = currentNote and currentNote.note or nil
		newNoteLabel = guiCreateLabel(margin, margin * 2, 1 - margin * 2, textH, text, true, tabAdminNote)
		newNoteMemo = guiCreateMemo(margin, margin * 2 + textH, 1 - margin * 2, 0.85, curMemo or "", true, tabAdminNote)
		if currentNote and not currentNote.edit then
			guiMemoSetReadOnly(newNoteMemo, true)
		end
	end
end

function getNoteFromID(id)
	for i, note in pairs(notes) do
		if tonumber(note.id) == tonumber(id) then
			return note
		end
	end
end

function cleanAllNotesGUI()
	if newNoteLabel and isElement(newNoteLabel) then
		destroyElement(newNoteLabel)
		newNoteLabel = nil
		destroyElement(newNoteMemo)
		newNoteMemo = nil
	end
	if gAdminNote and isElement(gAdminNote) then
		destroyElement(gAdminNote)
		gAdminNote = nil
	end
	currentNote = nil
end

function createCheckVehWindow(adminTitle, result1, result2, notes1)
	closeCheckVehWindow()
	showCursor(true)
	guiSetInputEnabled(true)
	notes = notes1
	checkVehWindow = guiCreateWindow(sx / 2 - 300, sy / 2 - 233, 600, 466, "Araç Yöneticisi", false)
	guiWindowSetSizable(checkVehWindow, false)

	local lVehModelID = guiCreateLabel(12, 27, 365, 17, "Araç Adı / ID: ", false, checkVehWindow)
	local lOwner = guiCreateLabel(12, 44, 365, 17, "Sahibi: ", false, checkVehWindow)
	local lLastUsed = guiCreateLabel(12, 112, 365, 17, "Son Kullanım: ", false, checkVehWindow)
	local lCarHP = guiCreateLabel(12, 78, 365, 17, "Motor: ", false, checkVehWindow)
	local lDriveType = guiCreateLabel(372, 95, 365, 17, "Çekiş Türü: ", false, checkVehWindow)
	local lDeleted = guiCreateLabel(372, 27, 365, 17, "Silinmiş: ", false, checkVehWindow)
	local lMileageAndHP = guiCreateLabel(372, 61, 365, 17, "Kilometre: ", false, checkVehWindow)
	local lPlate = guiCreateLabel(12, 61, 365, 17, "Plaka: ", false, checkVehWindow)
	local lActivity = guiCreateLabel(372, 44, 365, 17, "Aktif: ", false, checkVehWindow)
	local lSuspensionHeight = guiCreateLabel(372, 78, 365, 17, "Süspansiyon Yüksekliği: ", false, checkVehWindow)
	local lCreateDate = guiCreateLabel(372, 112, 365, 17, "Oluşturulma Tarihi: ", false, checkVehWindow)
	local lCreateBy = guiCreateLabel(372, 129, 365, 17, "Oluşturan: ", false, checkVehWindow)
	local lPosition = guiCreateLabel(12, 95, 365, 17, "Konum: ", false, checkVehWindow)
	local lAdminNote = guiCreateLabel(12, 133, 80, 17, "Yetkili Notu: ", false, checkVehWindow)
	local checkIntTabPanel = guiCreateTabPanel(12, 156, 576, 269, false, checkVehWindow)
	local tabAdminNote = guiCreateTab("Yetkili Not", checkIntTabPanel)

	local bCopyAdminInfo =
		guiCreateButton(110, 133, 220, 20, "Yetkili Adını ve Tarihi Kopyala", false, checkVehWindow)

	local tabHistory = guiCreateTab("Geçmiş", checkIntTabPanel)
	local gHistory = guiCreateGridList(0, 0, 1, 1, true, tabHistory)
	local colDate = guiGridListAddColumn(gHistory, "Tarih", 0.25)
	local colAction = guiGridListAddColumn(gHistory, "İşlem", 0.5)
	local colActor = guiGridListAddColumn(gHistory, "Kişi", 0.1)
	local colLogID = guiGridListAddColumn(gHistory, "Log Kaydı", 0.1)

	local ownerName = "Bilinmiyor"
	if result1[1].factionName or result1[1].owner then
		ownerName = (result1[1].factionName or result1[1].owner:gsub("_", " "))
	end

	guiSetText(
		lVehModelID,
		"Araç Adı / ID: "
			.. (getVehicleNameFromModel(result1[1].model) or "Bilinmiyor")
			.. " (ID #"
			.. (result1[1].id or "Bilinmiyor")
			.. ")"
	)
	guiSetText(lOwner, "Sahibi: " .. (ownerName or ""))
	guiSetText(lLastUsed, "Son Kullanım: " .. formartDays(result1[1].lastUsed or 0))
	guiSetText(
		lCarHP,
		"HP: "
			.. math.floor(tonumber(result1[1].hp) / 10)
			.. "% ("
			.. math.floor(tonumber(result1[1].hp))
			.. ")"
			.. "     Yakıt: "
			.. (result1[1].fuel .. "%" or "Bilinmiyor")
			.. "     Kaplama: "
			.. (result1[1].paintjob == "0" and "Yok" or result1[1].paintjob)
	)
	guiSetText(lDriveType, "Çekiş Türü: " .. (result1[1].driveType or "Varsayılan"))
	guiSetText(lDeleted, "Silinmiş: " .. (result1[1].deleted or "Hayır"))
	guiSetText(lMileageAndHP, "Kilometre: " .. (math.floor(tonumber(result1[1].odometer)) or "0") .. " KM")
	guiSetText(lPlate, "Plaka: " .. result1[1].plate)
	guiSetText(lActivity, "Aktiflik Durumu: " .. (result1[1].activity and "Aktif" or "İnaktif"))
	guiSetText(lSuspensionHeight, "Süspansiyon Yüksekliği: " .. (result1[1].suspensionLowerLimit or "Varsayılan"))
	guiSetText(lCreateDate, "Oluşturulma Tarihi: " .. (result1[1].creationDate or "Bilinmiyor"))
	guiSetText(lCreateBy, "Oluşturan: " .. (result1[1].creator or ""))
	guiSetText(
		lPosition,
		"Konum: "
			.. result1[1].posX
			.. ", "
			.. result1[1].posY
			.. ", "
			.. result1[1].posZ
			.. " (Interior: "
			.. result1[1].currdimension
			.. ", Dimension: "
			.. result1[1].currInterior
			.. ")"
	)

	if result2 then
		for _, h in ipairs(result2) do
			local row = guiGridListAddRow(gHistory)
			guiGridListSetItemText(gHistory, row, colDate, h[1] or "Yok", false, true)
			guiGridListSetItemText(gHistory, row, colAction, h[2] or "Yok", false, false)
			guiGridListSetItemText(gHistory, row, colActor, h[3] or "Yok", false, false)
			guiGridListSetItemText(gHistory, row, colLogID, h[4] or "Yok", false, false)
		end
	end

	bAddNote = guiCreateButton(212, 430, 90, 28, "Yeni Not Ekle", false, checkVehWindow)
	guiSetFont(bAddNote, "default-bold-small")
	addEventHandler("onClientGUIClick", bAddNote, function(button)
		if button == "left" then
			if guiGetText(bAddNote) == "Yeni Not Ekle" then
				drawNewNote(tabAdminNote, #notes < 1)
			else
				drawAdminNotes(tabAdminNote)
			end
		end
	end, false)

	if notes and #notes > 0 then
		drawAdminNotes(tabAdminNote, notes)
	else
		drawNewNote(tabAdminNote, #notes < 1)
	end

	local bGotoVeh1, bRestoreVeh1, bDelVeh1 = nil
	if result1[1].deleted then
		bRestoreVeh1 = guiCreateButton(12, 430, 90, 28, "Aracı Geri Yükle", false, checkVehWindow)
		guiSetFont(bRestoreVeh1, "default-bold-small")
		addEventHandler("onClientGUIClick", bRestoreVeh1, function(button)
			if button == "left" then
				if triggerServerEvent("vehicleManager.restoreVeh", localPlayer, result1[1].id) then
					triggerServerEvent("vehicleManager.checkveh", localPlayer, localPlayer, "checkveh", result1[1].id)
				end
			end
		end, false)

		bRemoveVeh1 = guiCreateButton(112, 430, 90, 28, "Aracı Kaldır", false, checkVehWindow)
		guiSetFont(bRemoveVeh1, "default-bold-small")
		addEventHandler("onClientGUIClick", bRemoveVeh1, function(button)
			if button == "left" then
				if triggerServerEvent("vehicleManager.removeVeh", localPlayer, result1[1].id) then
					closeCheckVehWindow()
				end
			end
		end, false)
		guiSetEnabled(bRemoveVeh1, exports.mek_integration:isPlayerManager(localPlayer))
	else
		bGotoVeh1 = guiCreateButton(12, 430, 90, 28, "Araca Işınlan", false, checkVehWindow)
		guiSetFont(bGotoVeh1, "default-bold-small")
		addEventHandler("onClientGUIClick", bGotoVeh1, function(button)
			if button == "left" then
				triggerServerEvent("vehicleManager.gotoVeh", localPlayer, result1[1].id)
			end
		end, false)

		bDelVeh1 = guiCreateButton(112, 430, 90, 28, "Aracı Sil", false, checkVehWindow)
		guiSetFont(bDelVeh1, "default-bold-small")
		addEventHandler("onClientGUIClick", bDelVeh1, function(button)
			if button == "left" then
				if triggerServerEvent("vehicleManager.delVeh", localPlayer, result1[1].id) then
					triggerServerEvent("vehicleManager.checkveh", localPlayer, localPlayer, "checkveh", result1[1].id)
				end
			end
		end, false)
	end

	local bSave = guiCreateButton(412, 430, 90, 28, "Kaydet", false, checkVehWindow)
	guiSetFont(bSave, "default-bold-small")
	addEventHandler("onClientGUIClick", bSave, function(button)
		if button == "left" then
			local noteMemo = nil
			if newNoteMemo and isElement(newNoteMemo) then
				noteMemo = guiGetText(newNoteMemo) or nil
			end

			if noteMemo == "" or noteMemo == "\n" then
				noteMemo = nil
			end

			if noteMemo or (currentNote and currentNote.edit and currentNote.note ~= noteMemo) then
				triggerServerEvent(
					"vehicleManager.saveAdminNote",
					localPlayer,
					result1[1].id,
					noteMemo,
					currentNote and currentNote.id
				)
				exports.mek_global:playSoundSuccess()
				closeCheckVehWindow()
			else
				outputChatBox("[!]#FFFFFF Kaydedilecek bir şey yok.", 255, 0, 0, true)
			end
		end
	end, false)

	local bClose = guiCreateButton(509, 430, 79, 28, "Kapat", false, checkVehWindow)
	guiSetFont(bClose, "default-bold-small")

	addEventHandler("onClientGUIClick", bClose, function(button)
		if button == "left" then
			closeCheckVehWindow()
		end
	end, false)

	addEventHandler("onClientGUIClick", bCopyAdminInfo, function(button)
		if button == "left" then
			local time = getRealTime()
			local date = time.monthday
			local month = time.month + 1
			local year = time.year + 1900
			local adminUsername = getElementData(localPlayer, "account_username")
			local content = " ("
				.. adminTitle
				.. " "
				.. adminUsername
				.. " - "
				.. date
				.. "/"
				.. month
				.. "/"
				.. year
				.. ")"
			if setClipboard(content) then
				guiSetText(checkVehWindow, "Kopyalandı: '" .. content .. "'")
			end
		end
	end, false)
end
addEvent("createCheckVehWindow", true)
addEventHandler("createCheckVehWindow", localPlayer, createCheckVehWindow)

function closeCheckVehWindow()
	if checkVehWindow and isElement(checkVehWindow) then
		destroyElement(checkVehWindow)
		checkVehWindow = nil
		showCursor(false)
		guiSetInputEnabled(false)
		bAddNote = nil
		gAdminNote = nil
		newNoteLabel = nil
		newNoteMemo = nil
		notes = {}
		currentNote = nil
	end
end
