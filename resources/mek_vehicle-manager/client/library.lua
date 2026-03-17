local GUIEditor_Window = {}
local GUIEditor_Button = {}
local GUIEditor_Grid = {}
local GUIEditor_Label = {}
local GUIEditor_Edit = {}
local GUIEditor_Memo = {}
local GUIEditor_Checkbox = {}
local col = {}
local sx, sy = guiGetScreenSize()
local gui = {}
carshops = {}

function showLibrary(vehs, thePed)
	if isElement(GUIEditor_Window[1]) then
		closeLibrary()
	end

	showCursor(true)

	local w, h = 784, 562

	GUIEditor_Window[1] = guiCreateWindow((sx - w) / 2, (sy - h) / 2, w, h, "Araç Kütüphanesi", false)
	guiWindowSetSizable(GUIEditor_Window[1], false)
	grid = guiCreateGridList(0.0115, 0.0463, 0.9758, 0.8541, true, GUIEditor_Window[1])

	col.id = guiGridListAddColumn(grid, "ID", 0.06)
	col.enabled = guiGridListAddColumn(grid, "Aktiflik", 0.06)
	col.mtamodel = guiGridListAddColumn(grid, "GTA Model", 0.15)
	col.brand = guiGridListAddColumn(grid, "Marka", 0.15)
	col.model = guiGridListAddColumn(grid, "Model", 0.15)
	col.year = guiGridListAddColumn(grid, "Yıl", 0.1)
	col.price = guiGridListAddColumn(grid, "Fiyat", 0.1)
	col.tax = guiGridListAddColumn(grid, "Vergi", 0.1)
	col.updatedby = guiGridListAddColumn(grid, "Güncellenmiş", 0.15)
	col.updatedate = guiGridListAddColumn(grid, "Tarih", 0.2)
	col.createdby = guiGridListAddColumn(grid, "Oluşturulma", 0.15)
	col.createdate = guiGridListAddColumn(grid, "Oluşturulma Tarihi", 0.2)
	col.notes = guiGridListAddColumn(grid, "Not", 0.5)
	col.spawnto = guiGridListAddColumn(grid, "Oluşma Bölgesi", 0.2)

	carshops = exports.mek_carshop:getCarShops()

	for i = 1, #vehs do
		local row = guiGridListAddRow(grid)
		guiGridListSetItemText(grid, row, col.id, vehs[i].id or "", false, true)
		guiGridListSetItemText(grid, row, col.enabled, ((vehs[i].enabled == "1") and "Evet" or "Hayır"), false, true)
		guiGridListSetItemText(
			grid,
			row,
			col.mtamodel,
			getVehicleNameFromModel(tonumber(vehs[i].vehmtamodel)) .. " (" .. vehs[i].vehmtamodel .. ")",
			false,
			false
		)
		guiGridListSetItemText(grid, row, col.brand, vehs[i].vehbrand, false, false)
		guiGridListSetItemText(grid, row, col.model, vehs[i].vehmodel, false, false)
		guiGridListSetItemText(grid, row, col.year, vehs[i].vehyear, false, false)
		guiGridListSetItemText(
			grid,
			row,
			col.price,
			"₺" .. exports.mek_global:formatMoney(vehs[i].vehprice),
			false,
			false
		)
		guiGridListSetItemText(grid, row, col.tax, "₺" .. exports.mek_global:formatMoney(vehs[i].vehtax), false, false)
		guiGridListSetItemText(grid, row, col.notes, (vehs[i].notes or ""), false, false)
		guiGridListSetItemText(grid, row, col.createdby, (vehs[i].createdby or "Hiç Kimse"), false, false)
		guiGridListSetItemText(grid, row, col.createdate, (vehs[i].createdate or "Hiç Kimse"), false, true)
		guiGridListSetItemText(grid, row, col.updatedby, (vehs[i].updatedby or "Hiç Kimse"), false, false)
		guiGridListSetItemText(grid, row, col.updatedate, vehs[i].updatedate, false, true)
		local spawntoText = ""
		if vehs[i].spawnto ~= "0" and carshops[tonumber(vehs[i].spawnto)] then
			spawntoText = carshops[tonumber(vehs[i].spawnto)].nicename
		end
		guiGridListSetItemText(grid, row, col.spawnto, (spawntoText or vehs[i].spawnto), false, false)
	end

	if thePed and isElement(thePed) and getElementData(thePed, "carshop") then
		local drivetestPrice = 25
		local orderPrice = 0

		GUIEditor_Button["testdrive"] = guiCreateButton(
			0.0115,
			0.9181,
			0.1237,
			0.0587,
			"Test Et (₺" .. drivetestPrice .. ")",
			true,
			GUIEditor_Window[1]
		)
		guiSetFont(GUIEditor_Button["testdrive"], "default-bold-small")

		addEventHandler("onClientGUIClick", GUIEditor_Button["testdrive"], function(button)
			if button == "left" then
				local row, col = -1, -1
				local row, col = guiGridListGetSelectedItem(grid)
				if row ~= -1 and col ~= -1 then
					local vehShopID = guiGridListGetItemText(grid, row, 1)
					triggerServerEvent(
						"vehicleManager.createTestVehicle",
						localPlayer,
						tonumber(vehShopID),
						thePed,
						false
					)
					closeLibrary()
					triggerEvent("playSuccess", localPlayer)
				else
					guiSetText(GUIEditor_Window[1], "Araç listesinden bir araç seçmelisiniz.")
					triggerEvent("playError", localPlayer)
					triggerServerEvent(
						"shop.storeKeeperSay",
						localPlayer,
						"Hangisini denemek istersiniz?",
						getElementData(thePed, "name")
					)
				end
			end
		end, false)

		GUIEditor_Button["ordervehicle"] =
			guiCreateButton(0.148, 0.9181, 0.1237, 0.0587, "Sipariş ver", true, GUIEditor_Window[1])
		guiSetFont(GUIEditor_Button["ordervehicle"], "default-bold-small")

		addEventHandler("onClientGUIClick", GUIEditor_Button["ordervehicle"], function(button)
			if button == "left" then
				local row, col = -1, -1
				local row, col = guiGridListGetSelectedItem(grid)
				if row ~= -1 and col ~= -1 then
					local vehShopID = guiGridListGetItemText(grid, row, 1)
					triggerServerEvent("vehicleManager.orderVehicle", localPlayer, tonumber(vehShopID), thePed)
					closeLibrary()
					triggerEvent("playSuccess", localPlayer)
				else
					guiSetText(GUIEditor_Window[1], "Araç listesinden bir araç seçmelisiniz.")
					triggerEvent("playError", localPlayer)
					triggerServerEvent(
						"shop.storeKeeperSay",
						localPlayer,
						"Hangisini sipariş etmek istersiniz?",
						getElementData(thePed, "name")
					)
				end
			end
		end, false)

		local playerOrderedFromShop =
			getElementData(localPlayer, "carshop:grotti:orderedvehicle:" .. getElementData(thePed, "carshop"))
		if playerOrderedFromShop then
			guiSetEnabled(GUIEditor_Button["ordervehicle"], false)
			GUIEditor_Button["cancelorder"] =
				guiCreateButton(0.148, 0.9181, 0.1237, 0.0587, "Siparişi iptal et", true, GUIEditor_Window[1])
			guiSetFont(GUIEditor_Button["cancelorder"], "default-bold-small")
			addEventHandler("onClientGUIClick", GUIEditor_Button["cancelorder"], function(button)
				if button == "left" then
					triggerServerEvent(
						"vehicleManager.orderVehicle:cancel",
						localPlayer,
						getElementData(thePed, "carshop")
					)
					triggerServerEvent("shop.storeKeeperSay", localPlayer, "Elbette!", getElementData(thePed, "name"))
					closeLibrary()
					triggerEvent("playSuccess", localPlayer)
				end
			end, false)
		end
	else
		GUIEditor_Button[1] = guiCreateButton(0.0115, 0.9181, 0.1237, 0.0587, "Oluştur", true, GUIEditor_Window[1])
		guiSetFont(GUIEditor_Button[1], "default-bold-small")
		addEventHandler("onClientGUIClick", GUIEditor_Button[1], function()
			if source == GUIEditor_Button[1] then
				local veh = {}
				addNewVehicle(veh)
			end
		end)
		guiSetEnabled(GUIEditor_Button[1], false)

		GUIEditor_Button[2] = guiCreateButton(0.148, 0.9181, 0.1237, 0.0587, "Düzenle", true, GUIEditor_Window[1])
		guiSetFont(GUIEditor_Button[2], "default-bold-small")
		addEventHandler("onClientGUIClick", GUIEditor_Button[2], function(button)
			if button == "left" then
				local row, col = -1, -1
				local row, col = guiGridListGetSelectedItem(grid)
				if row ~= -1 and col ~= -1 then
					triggerServerEvent(
						"vehicleManager.getCurrentVehicleRecord",
						localPlayer,
						tonumber(guiGridListGetItemText(grid, row, 1))
					)
				else
					guiSetText(GUIEditor_Window[1], "Araç listesinden bir araç seçmelisiniz.")
					triggerEvent("playError", localPlayer)
				end
			end
		end, false)
		guiSetEnabled(GUIEditor_Button[2], false)

		GUIEditor_Button[3] = guiCreateButton(0.2844, 0.9181, 0.1237, 0.0587, "Handling", true, GUIEditor_Window[1])
		guiSetFont(GUIEditor_Button[3], "default-bold-small")
		guiSetEnabled(GUIEditor_Button[3], false)
		addEventHandler("onClientGUIClick", GUIEditor_Button[3], function(button)
			if button == "left" then
				local row, col = -1, -1
				local row, col = guiGridListGetSelectedItem(grid)
				if row ~= -1 and col ~= -1 then
					local vehShopID = guiGridListGetItemText(grid, row, 1)
					exports.mek_global:fadeToBlack()
					setTimer(function()
						triggerServerEvent(
							"vehicleManager.createTestVehicle",
							localPlayer,
							tonumber(vehShopID),
							thePed,
							true
						)
					end, 1000, 1)
					closeLibrary()
				else
					guiSetText(GUIEditor_Window[1], "Araç listesinden bir araç seçmelisiniz.")
					triggerEvent("playError", localPlayer)
				end
			end
		end, false)
		guiSetEnabled(GUIEditor_Button[3], false)

		GUIEditor_Button[4] = guiCreateButton(0.4209, 0.9181, 0.1237, 0.0587, "Sil", true, GUIEditor_Window[1])
		guiSetFont(GUIEditor_Button[4], "default-bold-small")
		addEventHandler("onClientGUIClick", GUIEditor_Button[4], function(button)
			if button == "left" then
				local row, col = -1, -1
				local row, col = guiGridListGetSelectedItem(grid)
				if row ~= -1 and col ~= -1 then
					local createdby = guiGridListGetItemText(grid, row, 11)
					if
						createdby ~= getElementData(localPlayer, "account_username")
						and not exports.mek_integration:isPlayerServerManager(localPlayer)
					then
						guiSetText(
							GUIEditor_Window[1],
							"Yalnızca eklediğiniz arabaları silebilirsiniz. Bu araç uygun değilse, "
								.. createdby
								.. " raporunu ver."
						)
						triggerEvent("playError", localPlayer)
					else
						local id = guiGridListGetItemText(grid, row, 1)
						local brand = guiGridListGetItemText(grid, row, 4)
						local model = guiGridListGetItemText(grid, row, 5)
						showConfirmDelete(id, brand, model, createdby)
					end
				else
					guiSetText(GUIEditor_Window[1], "Araç listesinden bir araç seçmelisiniz.")
					triggerEvent("playError", localPlayer)
				end
			end
		end, false)
		guiSetEnabled(GUIEditor_Button[4], false)

		GUIEditor_Button[5] = guiCreateButton(0.5574, 0.9181, 0.1237, 0.0587, "Yenile", true, GUIEditor_Window[1])
		guiSetFont(GUIEditor_Button[5], "default-bold-small")
		addEventHandler("onClientGUIClick", GUIEditor_Button[5], function()
			if source == GUIEditor_Button[5] then
				refreshLibrary()
			end
		end)
		guiSetEnabled(GUIEditor_Button[5], false)

		GUIEditor_Button[7] =
			guiCreateButton(0.6939, 0.9181, 0.1237, 0.0587, "Galerileri Yenile", true, GUIEditor_Window[1])
		guiSetFont(GUIEditor_Button[7], "default-bold-small")
		addEventHandler("onClientGUIClick", GUIEditor_Button[7], function()
			if source == GUIEditor_Button[7] then
				triggerServerEvent("vehicleManager.refreshCarShops", localPlayer)
			end
		end)
		guiSetEnabled(GUIEditor_Button[7], false)

		if exports.mek_integration:isPlayerServerManager(localPlayer) then
			guiSetEnabled(GUIEditor_Button[1], true)
			guiSetEnabled(GUIEditor_Button[2], true)
			guiSetEnabled(GUIEditor_Button[3], true)
			guiSetEnabled(GUIEditor_Button[4], true)
			guiSetEnabled(GUIEditor_Button[5], true)
			guiSetEnabled(GUIEditor_Button[7], true)
		elseif exports.mek_integration:isPlayerTrialAdmin(localPlayer) then
			guiSetEnabled(GUIEditor_Button[5], true)
			guiSetEnabled(GUIEditor_Button[7], true)
		end
	end

	GUIEditor_Button[6] = guiCreateButton(0.8304, 0.9181, 0.1569, 0.0587, "Kapat", true, GUIEditor_Window[1])
	guiSetFont(GUIEditor_Button[6], "default-bold-small")

	addEventHandler("onClientGUIClick", GUIEditor_Button[6], function()
		if source == GUIEditor_Button[6] then
			closeLibrary()
		end
	end)
end
addEvent("vehicleManager.showLibrary", true)
addEventHandler("vehicleManager.showLibrary", localPlayer, showLibrary)

function closeLibrary()
	if isElement(GUIEditor_Window[1]) then
		destroyElement(GUIEditor_Window[1])
		GUIEditor_Window[1] = nil
	end
	showCursor(false)
end

function refreshLibrary(ped)
	triggerServerEvent("vehicleManager.sendLibraryToClient", localPlayer, ped)
end
addEvent("vehicleManager.sendLibraryToServer", true)
addEventHandler("vehicleManager.sendLibraryToServer", localPlayer, refreshLibrary)

function addNewVehicle(veh)
	if GUIEditor_Window[1] then
		guiSetEnabled(GUIEditor_Window[1], false)
	end

	if GUIEditor_Window[2] then
		closeAddNewVehicle()
		return false
	end
	guiSetInputEnabled(true)

	this = {}
	local fuel = veh.fuel or {}

	local w, h = 438, 392 + 30 + 40
	GUIEditor_Window[2] = guiCreateWindow(
		(sx - w) / 2,
		(sy - h) / 2,
		w,
		h,
		(veh.update and "Aracı Düzenle" or "Yeni Araç Ekle"),
		false
	)
	guiSetProperty(GUIEditor_Window[2], "AlwaysOnTop", "true")
	guiSetProperty(GUIEditor_Window[2], "SizingEnabled", "false")

	GUIEditor_Label[1] =
		guiCreateLabel(0.0251, 0.06, 0.4292, 0.0459, "GTA Model (Adı veya ID):", true, GUIEditor_Window[2])
	guiSetFont(GUIEditor_Label[1], "default-bold-small")
	GUIEditor_Edit[1] = guiCreateEdit(0.0388, 0.11, 0.4155, 0.06, (veh.mtaModel or ""), true, GUIEditor_Window[2])
	if veh.update then
		guiSetEnabled(GUIEditor_Edit[1], false)
	end
	GUIEditor_Label[2] = guiCreateLabel(0.0251, 0.185, 0.4292, 0.0459, "Marka:", true, GUIEditor_Window[2])
	guiSetFont(GUIEditor_Label[2], "default-bold-small")
	GUIEditor_Edit[2] = guiCreateEdit(0.0388, 0.235, 0.4155, 0.06, (veh.brand or ""), true, GUIEditor_Window[2])
	GUIEditor_Label[3] = guiCreateLabel(0.0251, 0.31, 0.4292, 0.0459, "Model:", true, GUIEditor_Window[2])
	guiSetFont(GUIEditor_Label[3], "default-bold-small")
	GUIEditor_Edit[3] = guiCreateEdit(0.0388, 0.36, 0.4155, 0.06, (veh.model or ""), true, GUIEditor_Window[2])
	GUIEditor_Label[4] = guiCreateLabel(0.516, 0.06, 0.4292, 0.0459, "Yıl:", true, GUIEditor_Window[2])
	guiSetFont(GUIEditor_Label[4], "default-bold-small")
	GUIEditor_Edit[4] = guiCreateEdit(0.5411, 0.11, 0.4155, 0.06, (veh.year or ""), true, GUIEditor_Window[2])
	GUIEditor_Label[5] = guiCreateLabel(0.516, 0.185, 0.4292, 0.0459, "Fiyat:", true, GUIEditor_Window[2])
	guiSetFont(GUIEditor_Label[5], "default-bold-small")
	GUIEditor_Edit[5] = guiCreateEdit(0.5388, 0.235, 0.4178, 0.06, (veh.price or ""), true, GUIEditor_Window[2])
	GUIEditor_Label[6] = guiCreateLabel(0.516, 0.31, 0.4292, 0.0459, "Vergi:", true, GUIEditor_Window[2])
	guiSetFont(GUIEditor_Label[6], "default-bold-small")
	GUIEditor_Edit[6] = guiCreateEdit(0.5434, 0.36, 0.4132, 0.06, (veh.tax or ""), true, GUIEditor_Window[2])

	GUIEditor_Label["spawnto"] =
		guiCreateLabel(0.0251, 0.435, 0.4292, 0.0459, "Oluşma Bölgesi:", true, GUIEditor_Window[2])
	guiSetFont(GUIEditor_Label["spawnto"], "default-bold-small")

	carshops = exports.mek_carshop:getCarShops()

	gui["spawnto"] = guiCreateComboBox(0.0388, 0.485, 0.4155, 0.06, "Hiç Biri", true, GUIEditor_Window[2])
	exports.mek_global:guiComboBoxAdjustHeight(gui["spawnto"], #carshops + 1)
	guiComboBoxAddItem(gui["spawnto"], "Hiç Biri")
	for i = 1, #carshops do
		guiComboBoxAddItem(gui["spawnto"], carshops[i].nicename)
	end
	guiComboBoxSetSelected(gui["spawnto"], tonumber(veh.spawnto) or -1)

	GUIEditor_Label["doortype"] = guiCreateLabel(0.516, 0.435, 0.4292, 0.0459, "Kapılar:", true, GUIEditor_Window[2])
	guiSetFont(GUIEditor_Label["doortype"], "default-bold-small")

	gui["doortype"] = guiCreateComboBox(0.5388, 0.485, 0.2, 0.06, "Default", true, GUIEditor_Window[2])
	exports.mek_global:guiComboBoxAdjustHeight(gui["doortype"], 3)
	guiComboBoxAddItem(gui["doortype"], "Default")
	guiComboBoxAddItem(gui["doortype"], "Scissor")
	guiComboBoxAddItem(gui["doortype"], "Butterfly")
	guiComboBoxSetSelected(gui["doortype"], veh.doortype or 0)

	local fuelType, fuelConsumption, fuelCapacity
	if not fuel.type then
		fuelType = "Petrol"
		fuel.type = "petrol"
	else
		if fuel.type == "petrol" then
			fuelType = "Petrol"
		elseif fuel.type == "diesel" then
			fuelType = "Diesel"
		elseif fuel.type == "electric" then
			fuelType = "Electricity"
		elseif fuel.type == "jet" then
			fuelType = "JET A-1"
		elseif fuel.type == "avgas" then
			fuelType = "100LL AVGAS"
		else
			fuelType = "Petrol"
			fuel.type = "petrol"
		end
	end
	if not fuel.con then
		fuelConsumption = "0"
		fuel.con = 0
	else
		fuelConsumption = tostring(fuel.con)
	end
	if not fuel.cap then
		fuelCapacity = 50
		fuel.cap = 50
	else
		fuelCapacity = tostring(fuel.cap)
	end
	this.fuel = fuel

	GUIEditor_Label[7] =
		guiCreateLabel(0.0251, 0.5383 + 0.1046 + 0.015, 0.4292, 0.0459, "Notlar:", true, GUIEditor_Window[2])
	guiSetFont(GUIEditor_Label[7], "default-bold-small")

	GUIEditor_Memo[1] = guiCreateMemo(0.0388, 0.6224 + 0.07, 0.9178, 0.15, (veh.note or ""), true, GUIEditor_Window[2])

	GUIEditor_Checkbox[1] = guiCreateCheckBox(0.8, 0.435, 0.15, 0.0459, "Aktif", false, true, GUIEditor_Window[2])
	if veh.enabled and tonumber(veh.enabled) == 1 then
		guiCheckBoxSetSelected(GUIEditor_Checkbox[1], true)
	end

	if veh.update then
		GUIEditor_Checkbox[2] =
			guiCreateCheckBox(0.8, 0.495, 0.151, 0.0459, "Kopyala", false, true, GUIEditor_Window[2])
	end

	GUIEditor_Button[8] = guiCreateButton(0.0388, 0.8622, 0.4475, 0.0944, "İptal", true, GUIEditor_Window[2])
	guiSetFont(GUIEditor_Button[8], "default-bold-small")
	addEventHandler("onClientGUIClick", GUIEditor_Button[8], function()
		if source == GUIEditor_Button[8] then
			closeAddNewVehicle()
		end
	end)

	GUIEditor_Button[9] = guiCreateButton(0.516, 0.8622, 0.4406, 0.0944, "Onayla", true, GUIEditor_Window[2])
	guiSetFont(GUIEditor_Button[9], "default-bold-small")
	addEventHandler("onClientGUIClick", GUIEditor_Button[9], function()
		if source == GUIEditor_Button[9] then
			validateCreateVehicle(veh)
		end
	end)
end
addEvent("vehicleManager.showEditVehicleRecord", true)
addEventHandler("vehicleManager.showEditVehicleRecord", localPlayer, addNewVehicle)

function editFuel(fuel)
	if GUIEditor_Window[3] then
		closeEditFuel()
		return false
	end

	local w, h = 438, 392 + 30
	GUIEditor_Window[3] = guiCreateWindow((sx - w) / 2, (sy - h) / 2, w, h, "Yakıt Ayarları", false)
	guiSetProperty(GUIEditor_Window[3], "AlwaysOnTop", "true")
	guiSetProperty(GUIEditor_Window[3], "SizingEnabled", "false")

	GUIEditor_Label["engine"] = guiCreateLabel(0.0251, 0.0867, 0.4292, 0.0459, "Motor Tipi:", true, GUIEditor_Window[3])
	guiSetFont(GUIEditor_Label["doortype"], "default-bold-small")

	gui["engine"] = guiCreateComboBox(0.0388, 0.1327, 0.2, 0.0791, "Benzin", true, GUIEditor_Window[3])
	exports.mek_global:guiComboBoxAdjustHeight(gui["engine"], 5)
	guiComboBoxAddItem(gui["engine"], "Petrol")
	guiComboBoxAddItem(gui["engine"], "Diesel")
	guiComboBoxAddItem(gui["engine"], "Electric")
	guiComboBoxAddItem(gui["engine"], "Turbine (jet a-1)")
	guiComboBoxAddItem(gui["engine"], "Piston (avgas)")
	guiComboBoxSetSelected(gui["engine"], fuel.engine or 0)

	GUIEditor_Label[8] =
		guiCreateLabel(0.0251, 0.185, 0.4292, 0.0459, "Tüketim (litre/kilometre):", true, GUIEditor_Window[3])
	guiSetFont(GUIEditor_Label[8], "default-bold-small")

	GUIEditor_Edit[8] = guiCreateEdit(0.0388, 0.235, 0.4155, 0.06, (fuel.con or ""), true, GUIEditor_Window[3])

	GUIEditor_Label[9] = guiCreateLabel(0.516, 0.185, 0.4292, 0.0459, "Kapasite (litre):", true, GUIEditor_Window[3])
	guiSetFont(GUIEditor_Label[9], "default-bold-small")

	GUIEditor_Edit[9] = guiCreateEdit(0.5388, 0.235, 0.4178, 0.06, (fuel.cap or ""), true, GUIEditor_Window[3])

	GUIEditor_Button[11] = guiCreateButton(0.0388, 0.8622, 0.4475, 0.0944, "İptal", true, GUIEditor_Window[3])
	guiSetFont(GUIEditor_Button[11], "default-bold-small")
	addEventHandler("onClientGUIClick", GUIEditor_Button[11], function()
		if source == GUIEditor_Button[11] then
			closeEditFuel()
		end
	end)
end

function closeEditFuel()
	if GUIEditor_Window[3] then
		destroyElement(GUIEditor_Window[3])
		GUIEditor_Window[3] = nil
	end
end

function closeAddNewVehicle()
	if GUIEditor_Window[3] then
		destroyElement(GUIEditor_Window[3])
		GUIEditor_Window[3] = nil
	end
	if GUIEditor_Window[2] then
		destroyElement(GUIEditor_Window[2])
		GUIEditor_Window[2] = nil
	end

	if GUIEditor_Window[1] then
		guiSetEnabled(GUIEditor_Window[1], true)
	end

	guiSetInputEnabled(false)
end

function validateCreateVehicle(data)
	if guiGetText(GUIEditor_Button[9]) == "Oluştur" or guiGetText(GUIEditor_Button[9]) == "Güncelle" then
		local veh = {}

		veh.mtaModel = guiGetText(GUIEditor_Edit[1])

		if not tonumber(veh.mtaModel) then
			veh.mtaModel = getVehicleModelFromName(veh.mtaModel)
		end

		veh.brand = guiGetText(GUIEditor_Edit[2])
		veh.model = guiGetText(GUIEditor_Edit[3])
		veh.year = guiGetText(GUIEditor_Edit[4])
		veh.price = guiGetText(GUIEditor_Edit[5])
		veh.tax = guiGetText(GUIEditor_Edit[6])
		veh.note = guiGetText(GUIEditor_Memo[1])

		if data and data.update then
			veh.update = true
			veh.id = data.id
		else
			veh.update = false
		end

		if
			GUIEditor_Checkbox[1]
			and isElement(GUIEditor_Checkbox[1])
			and guiCheckBoxGetSelected(GUIEditor_Checkbox[1])
		then
			veh.enabled = true
		else
			veh.enabled = false
		end

		if
			GUIEditor_Checkbox[2]
			and isElement(GUIEditor_Checkbox[2])
			and guiCheckBoxGetSelected(GUIEditor_Checkbox[2])
		then
			veh.copy = true
		else
			veh.copy = false
		end

		local item = guiComboBoxGetSelected(gui["spawnto"])
		veh.spawnto = (item == -1) and 0 or item

		local item = guiComboBoxGetSelected(gui["doortype"])
		veh.doortype = (item == -1) and 0 or item

		triggerServerEvent("vehicleManager.createVehicle", localPlayer, veh)
		closeAddNewVehicle()
	else
		local allGood = true
		local input = guiGetText(GUIEditor_Edit[1])
		local vehName = getVehicleNameFromModel(input)
		local vehModel = getVehicleModelFromName(input)

		if vehName and vehName ~= "" then
			guiSetText(GUIEditor_Label[1], "GTA Model (✔):")
			guiLabelSetColor(GUIEditor_Label[1], 0, 255, 0)
		elseif vehModel and tonumber(vehModel) then
			guiSetText(GUIEditor_Label[1], "GTA Model (✔):")
			guiLabelSetColor(GUIEditor_Label[1], 0, 255, 0)
		elseif exports.mek_integration:isPlayerServerManager(localPlayer) then
			guiSetText(GUIEditor_Label[1], "GTA Model (✔):")
			guiLabelSetColor(GUIEditor_Label[1], 0, 255, 0)
		else
			guiSetText(GUIEditor_Label[1], "GTA Model (❌):")
			guiLabelSetColor(GUIEditor_Label[1], 255, 0, 0)
			allGood = false
		end

		if #guiGetText(GUIEditor_Edit[2]) > 0 then
			guiSetText(GUIEditor_Label[2], "Marka (✔):")
			guiLabelSetColor(GUIEditor_Label[2], 0, 255, 0)
		else
			guiSetText(GUIEditor_Label[2], "Marka (❌):")
			guiLabelSetColor(GUIEditor_Label[2], 255, 0, 0)
			allGood = false
		end

		if #guiGetText(GUIEditor_Edit[3]) > 0 then
			guiSetText(GUIEditor_Label[3], "Model (✔):")
			guiLabelSetColor(GUIEditor_Label[3], 0, 255, 0)
		else
			guiSetText(GUIEditor_Label[3], "Model (❌):")
			guiLabelSetColor(GUIEditor_Label[3], 255, 0, 0)
			allGood = false
		end

		input = guiGetText(GUIEditor_Edit[4])
		if #input > 0 and tonumber(input) and tonumber(input) > 1000 and tonumber(input) < 3000 then
			guiSetText(GUIEditor_Label[4], "Yıl (✔):")
			guiLabelSetColor(GUIEditor_Label[4], 0, 255, 0)
		else
			guiSetText(GUIEditor_Label[4], "Yıl (❌):")
			guiLabelSetColor(GUIEditor_Label[4], 255, 0, 0)
			allGood = false
		end

		input = guiGetText(GUIEditor_Edit[5])
		if #input > 0 and tonumber(input) and tonumber(input) > 0 then
			guiSetText(GUIEditor_Label[5], "Fiyat (✔):")
			guiLabelSetColor(GUIEditor_Label[5], 0, 255, 0)
		else
			guiSetText(GUIEditor_Label[5], "Fiyat (❌):")
			guiLabelSetColor(GUIEditor_Label[5], 255, 0, 0)
			allGood = false
		end

		input = guiGetText(GUIEditor_Edit[6])
		if #input > 0 and tonumber(input) and tonumber(input) >= 0 then
			guiSetText(GUIEditor_Label[6], "Vergi (✔):")
			guiLabelSetColor(GUIEditor_Label[6], 0, 255, 0)
		else
			guiSetText(GUIEditor_Label[6], "Vergi (❌):")
			guiLabelSetColor(GUIEditor_Label[6], 255, 0, 0)
			allGood = false
		end

		if allGood then
			if data and data.update then
				guiSetText(GUIEditor_Button[9], "Güncelle")
			else
				guiSetText(GUIEditor_Button[9], "Oluştur")
			end
			triggerEvent("playSuccess", localPlayer)
		else
			guiSetText(GUIEditor_Button[9], "Onayla")
			triggerEvent("playError", localPlayer)
		end
	end
end

function showConfirmDelete(id, brand, model, createdby)
	local w, h = 394, 111
	GUIEditor_Window[3] = guiCreateWindow((sx - w) / 2, (sy - h) / 2, w, h, "", false)
	guiWindowSetSizable(GUIEditor_Window[3], false)
	guiSetProperty(GUIEditor_Window[3], "AlwaysOnTop", "true")
	guiSetProperty(GUIEditor_Window[3], "TitlebarEnabled", "false")

	GUIEditor_Label[8] = guiCreateLabel(
		0.0254,
		0.2072,
		0.9645,
		0.1982,
		"Araç #" .. id .. " (" .. brand .. " " .. model .. ") silinsin mi?",
		true,
		GUIEditor_Window[3]
	)
	guiLabelSetHorizontalAlign(GUIEditor_Label[8], "center", false)

	GUIEditor_Label[9] =
		guiCreateLabel(0.0254, 0.4054, 0.9492, 0.2162, "Bu işlem geri alınamaz!", true, GUIEditor_Window[3])
	guiLabelSetHorizontalAlign(GUIEditor_Label[9], "center", false)

	GUIEditor_Button[10] = guiCreateButton(0.0254, 0.6577, 0.4695, 0.2613, "İptal", true, GUIEditor_Window[3])
	addEventHandler("onClientGUIClick", GUIEditor_Button[10], function()
		if source == GUIEditor_Button[10] then
			closeConfirmDelete()
		end
	end)

	GUIEditor_Button[11] = guiCreateButton(0.5051, 0.6577, 0.4695, 0.2613, "Onayla", true, GUIEditor_Window[3])
	addEventHandler("onClientGUIClick", GUIEditor_Button[11], function()
		if source == GUIEditor_Button[11] then
			triggerServerEvent("vehicleManager.deleteVehicle", localPlayer, id)
			closeConfirmDelete()
			triggerEvent("playSuccess", localPlayer)
		end
	end)
end

function closeConfirmDelete()
	if GUIEditor_Window[3] then
		destroyElement(GUIEditor_Window[3])
		GUIEditor_Window[3] = nil
	end
end
