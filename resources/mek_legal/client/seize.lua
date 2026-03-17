function seizeUI(targetPlayer, data)
	if isElement(window) then
		destroyElement(window)
	end

	window = guiCreateWindow(
		0,
		0,
		549,
		335,
		getTeamName(getPlayerTeam(localPlayer)) .. " - El Koy | Görevli: " .. getPlayerName(localPlayer):gsub("_", " "),
		false
	)
	guiWindowSetSizable(window, false)
	guiWindowSetMovable(window, false)
	exports.mek_global:centerWindow(window)

	tab = guiCreateTabPanel(10, 20, 539, 275, false, window)
	tab1 = guiCreateTab("Silaha El Koyma", tab)

	label = guiCreateLabel(
		45,
		16,
		9999,
		9999,
		"Aşağıdan kullanıcının el koyulmasını istediğiniz silahı seçebilir ve el koyabilirsiniz.",
		false,
		tab1
	)

	grid = guiCreateGridList(7, 85, 515, 155, false, tab1)
	guiGridListAddColumn(grid, "Silah Adı", 0.5)
	guiGridListAddColumn(grid, "Güncel Hakkı", 0.45)

	for _, value in ipairs(data) do
		if value[1] == 115 then
			local itemID = value[1]
			local itemValue = value[2]
			local row = guiGridListAddRow(grid)
			local weaponRights = #tostring(split(itemValue, ":")[5]) > 0 and split(itemValue, ":")[5] or 3

			local checkString = string.sub(exports.mek_item:getItemName(itemID, itemValue), -4)
			if checkString == " (D)" then
				weaponRights = "-"
			end

			weaponRights = itemID == 115 and weaponRights or "-"
			guiGridListSetItemText(
				grid,
				row,
				1,
				tostring(exports.mek_item:getItemName(value[1], value[2])),
				false,
				true
			)
			guiGridListSetItemText(grid, row, 2, weaponRights, false, true)
			guiGridListSetItemData(grid, row, 2, tostring(split(itemValue, ":")[2]))
		end
	end

	submit = guiCreateButton(9, 300, 267, 31, "El Koy", false, window)

	addEventHandler("onClientGUIClick", submit, function()
		if guiGetSelectedTab(tab) == tab1 then
			local row = guiGridListGetSelectedItem(grid)
			if row ~= -1 then
				if guiGridListGetItemText(grid, row, 2) == "-" then
					outputChatBox("[!]#FFFFFF Görev silahına el koyamazsınız.", 255, 0, 0, true)
					destroyElement(window)
					return
				end

				triggerServerEvent(
					"legal.seize.takeWeapon",
					localPlayer,
					targetPlayer,
					guiGridListGetItemData(grid, row, 2)
				)
				destroyElement(window)
			else
				outputChatBox("[!]#FFFFFF Lütfen listeden bir silah seçiniz.", 255, 0, 0, true)
			end
		end
	end, false)

	close = guiCreateButton(286, 300, 254, 31, "Kapat", false, window)

	addEventHandler("onClientGUIClick", close, function()
		destroyElement(window)
	end, false)
end
addEvent("legal.seize.ui", true)
addEventHandler("legal.seize.ui", root, seizeUI)
