local vehicle = nil

local extraVehTexNames = {
	[596] = { "vehiclepoldecals128", "vehiclepoldecals128lod" },
	[597] = { "vehiclepoldecals128", "vehiclepoldecals128lod" },
	[598] = { "vehiclepoldecals128", "vehiclepoldecals128lod" },
}

local gui = {}

function vehTex_showGui(editVehicle)
	if gui.window then
		vehTex_hideGui()
	end

	vehicle = editVehicle
	if not vehicle then
		return false
	end

	local sw, sh = guiGetScreenSize()
	local width = 600
	local height = 400
	local x = (sw - width) / 2
	local y = (sh - height) / 2

	local vehID = getElementData(vehicle, "dbid")

	local windowTitle = "#" .. tostring(vehID) .. " ID'li Aracın Kaplama Listesi"
	gui.window = guiCreateWindow(x, y, width, height, windowTitle, false)
	gui.list = guiCreateGridList(10, 25, width - 20, height - 120, false, gui.window)
	gui.remove = guiCreateButton(10, height - 90, width - 20, 25, "Seçili Kaplamayı Kaldır", false, gui.window)
	gui.add = guiCreateButton(10, height - 60, width - 20, 25, "Yeni Kaplama Ekle", false, gui.window)
	gui.cancel = guiCreateButton(10, height - 30, width - 20, 25, "İptal", false, gui.window)

	guiGridListAddColumn(gui.list, "Kaplama", 0.2)
	guiGridListAddColumn(gui.list, "URL", 0.8)

	guiWindowSetSizable(gui.window, false)
	guiSetEnabled(gui.remove, false)
	showCursor(true)

	local currentTextures = getElementData(vehicle, "textures")
	for k, v in ipairs(currentTextures) do
		local row = guiGridListAddRow(gui.list)
		guiGridListSetItemText(gui.list, row, 1, v[1], false, false)
		guiGridListSetItemText(gui.list, row, 2, v[2], false, false)
	end

	addEventHandler("onClientGUIClick", gui.window, vehTex_WindowClick)
end
addEvent("item-texture.vehicleTexture")
addEventHandler("item-texture.vehicleTexture", root, vehTex_showGui)

function vehTex_WindowClick(button, state)
	if button == "left" and state == "up" then
		if source == gui.cancel then
			vehTex_hideGui()
		elseif source == gui.list then
			local texID = guiGridListGetItemText(gui.list, guiGridListGetSelectedItem(gui.list), 1)

			if texID ~= "" then
				guiSetEnabled(gui.remove, true)
			else
				guiSetEnabled(gui.remove, false)
			end
		elseif source == gui.add then
			vehTex_addGui()
		elseif source == gui.remove then
			local row, column = guiGridListGetSelectedItem(gui.list)
			local texname = guiGridListGetItemText(gui.list, row, 1)
			if texname ~= "" then
				guiGridListRemoveRow(gui.list, row)
				triggerServerEvent("item-texture.removeTexture", localPlayer, vehicle, texname)
			end
		end
	end
end

function vehTex_hideGui()
	if gui.window then
		if gui.window2 then
			destroyElement(gui.window2)
			gui.window2 = nil
			guiSetInputEnabled(false)
		end
		if gui.window3 then
			destroyElement(gui.window3)
			gui.window3 = nil
		end
		destroyElement(gui.window)
		gui.window = nil
		vehicle = nil

		showCursor(false)
	end
end

function vehTex_addGui()
	if gui.window2 then
		vehTex_addGui_hide()
	end

	gui.window2 = guiCreateWindow(634, 416, 456, 166, "Yeni Araç Kaplaması Ekle", false)
	guiWindowSetSizable(gui.window2, false)

	gui.addLabel1 = guiCreateLabel(31, 63, 30, 17, "URL:", false, gui.window2)
	gui.addUrl = guiCreateEdit(71, 59, 374, 25, "", false, gui.window2)
	gui.addLabel2 = guiCreateLabel(10, 27, 51, 18, "Kaplama:", false, gui.window2)
	gui.addCombo = guiCreateComboBox(69, 24, 199, 79, "", false, gui.window2)
	gui.addCancel = guiCreateButton(16, 109, 199, 43, "İptal", false, gui.window2)
	gui.addApply = guiCreateButton(230, 109, 214, 43, "Uygula", false, gui.window2)

	addEventHandler("onClientGUIClick", gui.addCancel, vehTex_addGui_hide, false)
	addEventHandler("onClientGUIClick", gui.addApply, vehTex_addGui_apply, false)

	guiSetInputEnabled(true)

	local alreadyAdded = {}
	local currentTextures = getElementData(vehicle, "textures")
	for k, v in ipairs(currentTextures) do
		alreadyAdded[v[1]] = true
	end

	local model = getElementModel(vehicle)
	local texnames = engineGetModelTextureNames(tostring(model))
	if extraVehTexNames[model] then
		for k, v in ipairs(extraVehTexNames[model]) do
			table.insert(texnames, v)
		end
	end

	for k, v in ipairs(texnames) do
		if not alreadyAdded[tostring(v)] then
			guiComboBoxAddItem(gui.addCombo, tostring(v))
		end
	end
end

function vehTex_addGui_hide()
	if gui.window2 then
		destroyElement(gui.window2)
		gui.window2 = nil
		guiSetInputEnabled(false)
		if gui.window3 then
			destroyElement(gui.window3)
			gui.window3 = nil
		end
	end
end

function vehTex_error(msg)
	if gui.window3 then
		vehTex_error_hide()
	end

	local sw, sh = guiGetScreenSize()
	local width = 400
	local height = 150
	local x = (sw - width) / 2
	local y = (sh - height) / 2

	gui.window3 = guiCreateWindow(x, y, width, height, "Hata", false)
	guiWindowSetSizable(gui.window3, false)

	gui.errorLabel = guiCreateLabel(10, 20, width - 20, height - 40, tostring(msg), false, gui.window3)
	guiLabelSetHorizontalAlign(gui.errorLabel, "center", true)
	guiLabelSetVerticalAlign(gui.errorLabel, "center")

	gui.errorBtn = guiCreateButton(10, height - 35, width - 20, 30, "Tamam", false, gui.window3)
	addEventHandler("onClientGUIClick", gui.errorBtn, vehTex_error_hide, false)
end

function vehTex_error_hide()
	if gui.window3 then
		destroyElement(gui.window3)
		gui.window3 = nil
	end
	if gui.addApply then
		guiSetEnabled(gui.addApply, true)
		guiSetText(gui.addApply, "Uygula")
	end
end

function vehTex_addGui_apply()
	guiSetEnabled(gui.addApply, false)
	guiSetText(gui.addApply, "Lütfen bekleyin...")

	local texurl = guiGetText(gui.addUrl)
	local texname = tostring(guiComboBoxGetItemText(gui.addCombo, guiComboBoxGetSelected(gui.addCombo)))
	if not texname or texname == "" or texname == " " then
		vehTex_error("Değiştirmek istediğiniz kaplamayı seçmediniz.")
		return false
	end

	if not exports.mek_global:isImageURL(texurl) then
		vehTex_error(
			"Geçersiz bir URL girdiniz veya desteklenmeyen bir site kullandınız. Desteklenen resim yükleme sunucusu: i.imgur.com"
		)
		return false
	end

	local path = getPath(texurl)
	if fileExists(path) then
		vehTex_apply(texname, texurl)
	else
		triggerServerEvent("item-texture.validateFile", resourceRoot, vehicle, texname, texurl)
		guiSetText(gui.addApply, "Lütfen bekleyin. İndiriliyor...")
	end
end

function vehTex_fileValidationResult(editVehicle, texname, texurl, approved, msg)
	if not editVehicle or not vehicle then
		return false
	end

	if editVehicle ~= vehicle then
		return false
	end

	if approved then
		vehTex_apply(texname, texurl)
		return true
	else
		vehTex_error("Dosya doğrulaması başarısız! \n" .. tostring(msg))
		return false
	end
end
addEvent("item-texture.fileValidationResult", true)
addEventHandler("item-texture.fileValidationResult", resourceRoot, vehTex_fileValidationResult)

function vehTex_apply(texname, texurl)
	triggerServerEvent("item-texture.addTexture", localPlayer, vehicle, texname, texurl)
	vehTex_addGui_hide()
end
