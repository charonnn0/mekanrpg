local panelWindow, panelGridlist, panelLabel, okButton, noButton
local loading = false

addEvent("vehicle.showVehicleData", true)
addEventHandler("vehicle.showVehicleData", localPlayer, function(vehicles, playerName)
	loading = false

	if isElement(panelWindow) then
		destroyElement(panelWindow)
	end

	panelWindow = guiCreateWindow(0.38, 0.25, 0.22, 0.50, "Araçlar - " .. playerName:gsub("_", " "), true)
	guiWindowSetSizable(panelWindow, false)

	panelLabel = guiCreateLabel(
		0.00,
		0.05,
		1.01,
		0.09,
		"Bu panelde sahip olduğunuz araçlar\nalt alta listelenmektedir.",
		true,
		panelWindow
	)
	guiSetFont(panelLabel, "default-bold-small")
	guiLabelSetHorizontalAlign(panelLabel, "center", false)
	guiLabelSetVerticalAlign(panelLabel, "center")

	panelGridlist = guiCreateGridList(0.03, 0.15, 0.95, 0.70, true, panelWindow)
	guiGridListAddColumn(panelGridlist, "ID", 0.15)
	guiGridListAddColumn(panelGridlist, "Araç", 0.6)
	guiGridListAddColumn(panelGridlist, "Durum", 0.1)

	for _, data in ipairs(vehicles) do
		local vehicleID, vehicleName, status, faction, deleted = unpack(data)
		local displayName = vehicleName

		if faction > 0 then
			displayName = displayName .. " (Birlik Aracı)"
		end

		if deleted > 0 then
			displayName = displayName .. " (Silinmiş Araç)"
		end

		local row = guiGridListAddRow(panelGridlist)
		guiGridListSetItemText(panelGridlist, row, 1, tostring(vehicleID), false, false)
		guiGridListSetItemText(panelGridlist, row, 2, displayName, false, false)
		guiGridListSetItemText(panelGridlist, row, 3, status, false, false)

		local r, g, b = 0, 255, 0
		if status == "İnaktif" then
			r, g, b = 255, 0, 0
		end
		guiGridListSetItemColor(panelGridlist, row, 3, r, g, b)
	end

	okButton = guiCreateButton(0.52, 0.89, 0.46, 0.09, "Getir", true, panelWindow)
	guiSetFont(okButton, "default-bold-small")

	noButton = guiCreateButton(0.03, 0.89, 0.46, 0.09, "Kapat", true, panelWindow)
	guiSetFont(noButton, "default-bold-small")

	showCursor(true)
end)

addEventHandler("onClientGUIClick", guiRoot, function()
	if source == okButton then
		local selectedRow = guiGridListGetSelectedItem(panelGridlist)
		if selectedRow == -1 then
			outputChatBox("[!]#FFFFFF Lütfen bir araç seçin.", 255, 0, 0, true)
			return
		end

		local vehicleID = guiGridListGetItemText(panelGridlist, selectedRow, 1)
		local vehicleName = guiGridListGetItemText(panelGridlist, selectedRow, 2)
		local btnText = guiGetText(okButton)

		if vehicleName:find("Silinmiş Araç") and btnText == "Aktif Et" then
			outputChatBox("[!]#FFFFFF Bu araç silinmiş, aktif edilemez.", 255, 0, 0, true)
			return
		end

		destroyElement(panelWindow)
		showCursor(false)

		if btnText == "İnaktif Et" then
			triggerServerEvent("vehicle.inactiveVehicle", localPlayer, tonumber(vehicleID))
		else
			triggerServerEvent("vehicle.activeVehicle", localPlayer, tonumber(vehicleID))
		end
	elseif source == noButton then
		destroyElement(panelWindow)
		showCursor(false)
	elseif source == panelGridlist then
		local row = guiGridListGetSelectedItem(panelGridlist)
		if row ~= -1 then
			local status = guiGridListGetItemText(panelGridlist, row, 3)
			guiSetText(okButton, (status == "İnaktif" and "Aktif Et" or "İnaktif Et"))
		end
	end
end)

-- Yeni komut: aracpanel
addCommandHandler("aracpanel", function(_, targetPlayer)
	if loading then
		outputChatBox("[!]#FFFFFF Araç verileri yükleniyor, lütfen bekleyin.", 0, 0, 255, true)
		return
	end

	loading = true

	if targetPlayer and exports.mek_integration:isPlayerManager(localPlayer) then
		local targetPlayer = exports.mek_global:findPlayerByPartialNick(localPlayer, targetPlayer)
		if targetPlayer then
			local dbid = getElementData(targetPlayer, "dbid") or 0
			local faction = getElementData(targetPlayer, "faction") or 0
			triggerServerEvent("vehicle.getVehicleData", localPlayer, dbid, faction, targetPlayer:getName())
		else
			outputChatBox("[!]#FFFFFF Belirtilen oyuncu bulunamadı.", 255, 0, 0, true)
			loading = false
		end
	else
		triggerServerEvent(
			"vehicle.getVehicleData",
			localPlayer,
			false,
			getElementData(localPlayer, "faction"),
			getPlayerName(localPlayer)
		)
	end
end)

