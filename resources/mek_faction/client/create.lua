addEvent("faction.create.gui", true)
addEventHandler("faction.create.gui", root, function()
	guiSetInputMode("no_binds_when_editing")

	local screenW, screenH = guiGetScreenSize()
	local factionWindow =
		guiCreateWindow((screenW - 288) / 2, (screenH - 321) / 2, 288, 321, "Birlik Kurma Arayüzü", false)
	guiWindowSetSizable(factionWindow, false)

	local nameLabel = guiCreateLabel(10, 26, 63, 26, "Birlik Adı:", false, factionWindow)
	guiLabelSetHorizontalAlign(nameLabel, "center", false)
	guiLabelSetVerticalAlign(nameLabel, "center")
	local nameEdit = guiCreateEdit(73, 26, 204, 26, "", false, factionWindow)
	guiCreateLabel(73, 52, 204, 15, "Max. 36 Karakter.", false, factionWindow)

	local typeLabel = guiCreateLabel(10, 77, 63, 26, "Birlik Tipi:", false, factionWindow)
	guiLabelSetHorizontalAlign(typeLabel, "center", false)
	guiLabelSetVerticalAlign(typeLabel, "center")

	local radioButtons = {}
	local yPos = 77

	for id, name in pairs(getFactionTypes()) do
		id = tonumber(id)
		if id ~= 2 and id ~= 3 and id ~= 4 then
			local btn = guiCreateRadioButton(73, yPos, 204, 26, name, false, factionWindow)
			table.insert(radioButtons, { id = id, element = btn })
			yPos = yPos + 26
		end
	end

	if #radioButtons > 0 then
		guiRadioButtonSetSelected(radioButtons[1].element, true)
	end

	local createButton = guiCreateButton(10, 217, 267, 39, "Kur (₺10,000)", false, factionWindow)
	guiSetProperty(createButton, "NormalTextColour", "FFAAAAAA")
	addEventHandler("onClientGUIClick", createButton, function()
		local selectedType
		for _, data in ipairs(radioButtons) do
			if guiRadioButtonGetSelected(data.element) then
				selectedType = data.id
				break
			end
		end

		if selectedType and guiGetText(nameEdit) ~= "" then
			local factionData = {
				name = guiGetText(nameEdit),
				type = selectedType,
				max_interiors = 20,
				max_vehicles = 40,
				before_tax_value = 0,
				free_wage_amount = 0,
			}

			triggerServerEvent("factions.create", localPlayer, factionData)
			destroyElement(factionWindow)
		else
			exports.mek_infobox:addBox("error", "Birlik adı girmelisiniz.")
		end
	end)

	local closeButton = guiCreateButton(10, 266, 267, 39, "Kapat", false, factionWindow)
	guiSetProperty(closeButton, "NormalTextColour", "FFAAAAAA")
	addEventHandler("onClientGUIClick", closeButton, function()
		destroyElement(factionWindow)
	end)
end)
