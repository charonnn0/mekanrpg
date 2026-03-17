wLicense, licenseList, bAcceptLicense, bCancel = nil

local carla = createPed(211, 1099, -767.7998046875, 976.52996826172)
setPedRotation(carla, 180)
setElementDimension(carla, 15)
setElementInterior(carla, 5)
setElementData(carla, "name", "Carla Cooper")
setPedAnimation(carla, "FOOD", "FF_Sit_Look", -1, true, false, false)
setElementData(carla, "interaction", {
	callbackEvent = "onLicense",
	args = {},
	description = carla:getData("name"):gsub("_", " "),
})

local dominick = createPed(187, 1108.599609375, -767.2998046875, 976.59997558594)
setPedRotation(dominick, 180)
setElementDimension(dominick, 15)
setElementInterior(dominick, 5)
setElementData(dominick, "name", "Dominick Hollingsworth")
setPedAnimation(dominick, "FOOD", "FF_Sit_Look", -1, true, false, false)
setElementData(dominick, "interaction", {
	callbackEvent = "showRecoverLicenseWindow",
	args = {},
	description = dominick:getData("name"):gsub("_", " "),
})

local cost = {
	["car"] = 550,
	["bike"] = 300,
	["boat"] = 950,
}

function showLicenseWindow()
	closewLicense()
	triggerServerEvent("license.server", localPlayer)

	local carLicense = getElementData(localPlayer, "car_license")
	local bikeLicense = getElementData(localPlayer, "bike_license")
	local boatLicense = getElementData(localPlayer, "boat_license")

	local width, height = 300, 400
	local scrWidth, scrHeight = guiGetScreenSize()
	local x = scrWidth / 2 - (width / 2)
	local y = scrHeight / 2 - (height / 2)

	wLicense = guiCreateWindow(x, y, width, height, "Sürücü Kursu - Ehliyet Başvurusu", false)

	licenseList = guiCreateGridList(0.05, 0.05, 0.9, 0.8, true, wLicense)
	local column = guiGridListAddColumn(licenseList, "Ehliyet", 0.6)
	local column2 = guiGridListAddColumn(licenseList, "Fiyat", 0.3)

	if carLicense ~= 1 then
		local row = guiGridListAddRow(licenseList)
		guiGridListSetItemText(licenseList, row, column, "Araba Ehliyeti", false, false)
		guiGridListSetItemText(licenseList, row, column2, "₺" .. cost["car"], true, false)
	end

	if bikeLicense ~= 1 then
		local row2 = guiGridListAddRow(licenseList)
		guiGridListSetItemText(licenseList, row2, column, "Motosiklet Ehliyeti", false, false)
		guiGridListSetItemText(licenseList, row2, column2, "₺" .. cost["bike"], true, false)
	end

	if boatLicense ~= 1 then
		local row3 = guiGridListAddRow(licenseList)
		guiGridListSetItemText(licenseList, row3, column, "Tekne Ehliyeti", false, false)
		guiGridListSetItemText(licenseList, row3, column2, "₺" .. cost["boat"], true, false)
	end

	bAcceptLicense = guiCreateButton(0.05, 0.85, 0.45, 0.1, "Test Yap", true, wLicense)
	bCancel = guiCreateButton(0.05 + 0.45, 0.85, 0.45, 0.1, "İptal", true, wLicense)

	showCursor(true)

	addEventHandler("onClientGUIClick", bAcceptLicense, acceptLicense)
	addEventHandler("onClientGUIClick", bCancel, cancelLicense)
end
addEvent("onLicense", true)
addEventHandler("onLicense", root, showLicenseWindow)

local gui = {}
function showRecoverLicenseWindow()
	closeRecoverLicenseWindow()
	showCursor(true)

	local carLicense = getElementData(localPlayer, "car_license")
	local bikeLicense = getElementData(localPlayer, "bike_license")
	local boatLicense = getElementData(localPlayer, "boat_license")

	local width, height = 300, 400
	local scrWidth, scrHeight = guiGetScreenSize()
	local x = scrWidth / 2 - (width / 2)
	local y = scrHeight / 2 - (height / 2)

	gui.wLicense = guiCreateWindow(x, y, width, height, "Sürücü Kursu - Ehliyeti Kurtarma", false)

	gui.licenseList = guiCreateGridList(0.05, 0.05, 0.9, 0.8, true, gui.wLicense)
	gui.column = guiGridListAddColumn(gui.licenseList, "Ehliyet", 0.6)
	gui.column2 = guiGridListAddColumn(gui.licenseList, "Fiyat", 0.3)

	gui.row = guiGridListAddRow(gui.licenseList)
	guiGridListSetItemText(gui.licenseList, gui.row, gui.column, "Araba Ehliyeti", false, false)
	guiGridListSetItemText(gui.licenseList, gui.row, gui.column2, "₺" .. cost["car"] / 10, true, false)

	gui.row2 = guiGridListAddRow(gui.licenseList)
	guiGridListSetItemText(gui.licenseList, gui.row2, gui.column, "Motosiklet Ehliyeti", false, false)
	guiGridListSetItemText(gui.licenseList, gui.row2, gui.column2, "₺" .. cost["bike"] / 10, true, false)

	gui.row3 = guiGridListAddRow(gui.licenseList)
	guiGridListSetItemText(gui.licenseList, gui.row3, gui.column, "Tekne Ehliyeti", false, false)
	guiGridListSetItemText(gui.licenseList, gui.row3, gui.column2, "₺" .. cost["boat"] / 10, true, false)

	gui.bRecover = guiCreateButton(0.05, 0.85, 0.45, 0.1, "Kurtar", true, gui.wLicense)
	gui.bCancel = guiCreateButton(0.5, 0.85, 0.45, 0.1, "İptal", true, gui.wLicense)

	addEventHandler("onClientGUIClick", gui.bRecover, function()
		local row, col = guiGridListGetSelectedItem(gui.licenseList)
		if (row == -1) or (col == -1) then
			exports.mek_infobox:addBox("error", "Lütfen önce bir ehliyet seçin.")
			return false
		end

		local licenseText = guiGridListGetItemText(gui.licenseList, guiGridListGetSelectedItem(gui.licenseList), 1)
		local licenseCost = 0

		if licenseText == "Araba Ehliyeti" then
			if carLicense ~= 1 then
				triggerServerEvent(
					"shop.storeKeeperSay",
					localPlayer,
					"Üzgünüz, kayıtlarımızda size ait bir ehliyet bulamadık. Lütfen diğer odadaki acente Carla Cooper ile görüşün.",
					getElementData(dominick, "name")
				)
				return false
			end
			triggerServerEvent(
				"license.recover",
				localPlayer,
				licenseText,
				cost["car"] / 10,
				133,
				getElementData(dominick, "name")
			)
		end

		if licenseText == "Motosiklet Ehliyeti" then
			if bikeLicense ~= 1 then
				triggerServerEvent(
					"shop.storeKeeperSay",
					localPlayer,
					"Üzgünüz, kayıtlarımızda size ait bir ehliyet bulamadık. Lütfen diğer odadaki acente Carla Cooper ile görüşün.",
					getElementData(dominick, "name")
				)
				return false
			end
			triggerServerEvent(
				"license.recover",
				localPlayer,
				licenseText,
				cost["bike"] / 10,
				153,
				getElementData(dominick, "name")
			)
		end

		if licenseText == "Tekne Ehliyeti" then
			if boatLicense ~= 1 then
				triggerServerEvent(
					"shop.storeKeeperSay",
					localPlayer,
					"Üzgünüz, kayıtlarımızda size ait bir ehliyet bulamadık. Lütfen diğer odadaki acente Carla Cooper ile görüşün.",
					getElementData(dominick, "name")
				)
				return false
			end
			triggerServerEvent(
				"license.recover",
				localPlayer,
				licenseText,
				cost["boat"] / 10,
				155,
				getElementData(dominick, "name")
			)
		end
	end, false)

	addEventHandler("onClientGUIClick", gui.bCancel, function()
		closeRecoverLicenseWindow()
	end, false)
end
addEvent("showRecoverLicenseWindow", true)
addEventHandler("showRecoverLicenseWindow", root, showRecoverLicenseWindow)

function closeRecoverLicenseWindow()
	if gui.wLicense and isElement(gui.wLicense) then
		destroyElement(gui.wLicense)
		gui.wLicense = nil
		showCursor(false)
	end
end

function acceptLicense(button, state)
	if button == "left" then
		if source == bAcceptLicense then
			local row, col = guiGridListGetSelectedItem(licenseList)
			if (row == -1) or (col == -1) then
				exports.mek_infobox:addBox("error", "Lütfen önce bir ehliyet seçin.")
				return false
			end

			local license = 0
			local licenseText = guiGridListGetItemText(licenseList, guiGridListGetSelectedItem(licenseList), 1)
			local licenseCost = 0

			if licenseText == "Araba Ehliyeti" then
				license = 1
				licenseCost = cost["car"]
				minimumAge = 16
			end
			if licenseText == "Motosiklet Ehliyeti" then
				license = 2
				licenseCost = cost["bike"]
				minimumAge = 16
			end
			if licenseText == "Tekne Ehliyeti" then
				license = 3
				licenseCost = cost["boat"]
			end

			if license <= 0 then
				return false
			end

			if minimumAge then
				local characterAge = tonumber(getElementData(localPlayer, "age")) or 0
				if characterAge < minimumAge then
					exports.mek_infobox:addBox(
						"error",
						"Bir "
							.. tostring(licenseText)
							.. " alabilmek için en az "
							.. tostring(minimumAge)
							.. " yaşında olmalısınız."
					)
					return false
				end
			end

			if source == bAcceptLicense then
				if not exports.mek_global:hasMoney(localPlayer, licenseCost) then
					exports.mek_infobox:addBox(
						"error",
						"Bu ehliyet için gerekli olan ₺" .. licenseCost .. " paranız yok."
					)
					return false
				end
			end

			if source == bAcceptLicense then
				if license == 1 then
					if getElementData(localPlayer, "car_license") < 0 then
						exports.mek_infobox:addBox(
							"error",
							"Bir "
								.. licenseText
								.. " alabilmek için "
								.. -tostring(getElementData(localPlayer, "car_license"))
								.. " saat daha beklemeniz gerekiyor."
						)
					elseif getElementData(localPlayer, "car_license") == 0 then
						triggerServerEvent("license.payFee", localPlayer, licenseCost, "Araba Ehliyeti")
						createlicenseTestIntroWindow()
						destroyElement(licenseList)
						destroyElement(bAcceptLicense)
						destroyElement(bCancel)
						destroyElement(wLicense)
						wLicense, licenseList, bAcceptLicense, bCancel = nil, nil, nil, nil
						showCursor(false)
					elseif getElementData(localPlayer, "car_license") == 3 then
						initiateDrivingTest()
					end
				elseif license == 2 then
					if getElementData(localPlayer, "bike_license") < 0 then
						exports.mek_infobox:addBox(
							"error",
							"Bir "
								.. licenseText
								.. " alabilmek için "
								.. -tostring(getElementData(localPlayer, "bike_license"))
								.. " saat daha beklemeniz gerekiyor."
						)
					elseif getElementData(localPlayer, "bike_license") == 0 then
						triggerServerEvent("license.payFee", localPlayer, licenseCost, "Motosiklet Ehliyeti")
						createlicenseBikeTestIntroWindow()
						destroyElement(licenseList)
						destroyElement(bAcceptLicense)
						destroyElement(bCancel)
						destroyElement(wLicense)
						wLicense, licenseList, bAcceptLicense, bCancel = nil, nil, nil, nil
						showCursor(false)
					elseif getElementData(localPlayer, "bike_license") == 3 then
						initiateBikeTest()
					end
				elseif license == 3 then
					if getElementData(localPlayer, "boat_license") < 0 then
						exports.mek_infobox:addBox(
							"error",
							"Bir "
								.. licenseText
								.. " alabilmek için "
								.. -tostring(getElementData(localPlayer, "boat_license"))
								.. " saat daha beklemeniz gerekiyor."
						)
					elseif getElementData(localPlayer, "boat_license") == 0 then
						triggerServerEvent("license.payFee", localPlayer, licenseCost, "Tekne Ehliyeti")
						createlicenseBoatTestIntroWindow()
						destroyElement(licenseList)
						destroyElement(bAcceptLicense)
						destroyElement(bCancel)
						destroyElement(wLicense)
						wLicense, licenseList, bAcceptLicense, bCancel = nil, nil, nil, nil
						showCursor(false)
					end
				end
			end
		end
	end
end

function cancelLicense(button, state)
	if (source == bCancel) and (button == "left") then
		destroyElement(licenseList)
		destroyElement(bAcceptLicense)
		destroyElement(bCancel)
		destroyElement(wLicense)
		wLicense, licenseList, bAcceptLicense, bCancel = nil, nil, nil, nil
		showCursor(false)
	end
end

function closewLicense()
	if wLicense and isElement(wLicense) then
		destroyElement(wLicense)
		wLicense = nil
		showCursor(false)
	end
end

bindKey("accelerate", "down", function()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if not vehicle or getVehicleOccupant(vehicle) ~= localPlayer then
		return
	end

	if isElementFrozen(vehicle) and getVehicleEngineState(vehicle) then
		local vehicleType = getVehicleType(vehicle)
		if vehicleType ~= "vehicle" and vehicleType ~= "Bike" and vehicleType ~= "Boat" then
			outputChatBox(
				"[!]#FFFFFF Aracınızın el freni kaldırılmış, 'G' tuşuna basarak indirebilirsiniz.",
				0,
				0,
				255,
				true
			)
		end
	elseif not getVehicleEngineState(vehicle) then
		outputChatBox(
			"[!]#FFFFFF Aracınızın motoru çalışmamaktadır. 'J' tuşuna basarak motoru çalıştırabilirsiniz.",
			0,
			0,
			255,
			true
		)
	end
end)
