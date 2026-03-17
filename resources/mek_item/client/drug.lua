wChemistrySet, gChemicals, colChemSlot, colChemName, chemItems, bMixItems, bChemClose = nil

function showChemistrySet()
	if not wItems then
		if not wChemistrySet then
			local width, height = 600, 500
			local scrWidth, scrHeight = guiGetScreenSize()
			local x = scrWidth / 2 - (width / 2)
			local y = scrHeight / 2 - (height / 2)

			wChemistrySet = guiCreateWindow(x, y, width, height, "Kimya Seti", false)
			guiWindowSetSizable(wChemistrySet, false)

			local items = getItems(localPlayer)

			chemItems = {}

			if items then
				for slot, item in ipairs(items) do
					if item and item[1] >= 30 and item[1] <= 33 then
						chemItems[slot] = {}
						chemItems[slot][1] = getItemName(item[1])
						chemItems[slot][2] = item[1]
						chemItems[slot][3] = slot
					end
				end
			end

			gChemicals = guiCreateGridList(0.025, 0.05, 0.95, 0.85, true, wChemistrySet)

			colChemSlot = guiGridListAddColumn(gChemicals, "Slot", 0.1)
			colChemName = guiGridListAddColumn(gChemicals, "İsim", 0.855)

			guiGridListSetSelectionMode(gChemicals, 1)

			for k, v in pairs(chemItems) do
				local itemid = tonumber(chemItems[k][2])

				local itemtype = getItemType(itemid)

				if itemtype then
					local row = guiGridListAddRow(gChemicals)
					guiGridListSetItemText(gChemicals, row, colChemSlot, tostring(chemItems[k][3]), false, true)
					guiGridListSetItemText(gChemicals, row, colChemName, tostring(chemItems[k][1]), false, false)
				end
			end

			bMixItems = guiCreateButton(0.05, 0.91, 0.7, 0.15, "Karıştır", true, wChemistrySet)
			addEventHandler("onClientGUIClick", bMixItems, mixItems, false)
			guiSetEnabled(bMixItems, false)

			bChemClose = guiCreateButton(0.8, 0.91, 0.15, 0.15, "Kapat", true, wChemistrySet)

			addEventHandler("onClientGUIClick", gChemicals, checkSelectedItems, false)
			addEventHandler("onClientGUIClick", bChemClose, hideChemistrySet, false)
			showCursor(true)
		else
			hideChemistrySet()
		end
	end
end

function hideChemistrySet()
	colChemSlot = nil
	colChemName = nil

	destroyElement(gChemicals)
	gChemicals = nil

	chemItems = nil

	destroyElement(wChemistrySet)
	wChemistrySet = nil

	showCursor(false)
end

function checkSelectedItems()
	if guiGridListGetSelectedCount(gChemicals) == 4 then
		guiSetEnabled(bMixItems, true)
	else
		guiSetEnabled(bMixItems, false)
	end
end

function mixItems(button, state)
	if button == "left" and state == "up" then
		if guiGridListGetSelectedCount(gChemicals) == 4 then
			selected = guiGridListGetSelectedItems(gChemicals)

			if selected then
				local row1 = selected[1]["row"]
				local row2 = selected[3]["row"]

				local row1slot = tonumber(guiGridListGetItemText(gChemicals, row1, 1))
				local row2slot = tonumber(guiGridListGetItemText(gChemicals, row2, 1))

				local row1item = chemItems[row1slot][2]
				local row2item = chemItems[row2slot][2]

				local row1name = chemItems[row1slot][1]
				local row2name = chemItems[row2slot][1]

				triggerServerEvent("mixDrugs", localPlayer, row1item, row2item, row1name, row2name)
			end
		end

		hideChemistrySet()
	end
end