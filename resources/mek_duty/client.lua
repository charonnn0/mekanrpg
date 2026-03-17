function openDutyWindow()
	local availablePackages, allowList = fetchAvailablePackages(localPlayer)
	if #availablePackages > 0 then
		local dutyLevel = getElementData(localPlayer, "duty")
		if not dutyLevel or dutyLevel == 0 then
			selectPackageGUI_open(availablePackages, allowList)
		else
			triggerServerEvent("duty.offDuty", localPlayer)
		end
	else
		outputChatBox("[!]#FFFFFF Bu noktada sizin için herhangi bir görev bulunmamaktadır.", 255, 0, 0, true)
	end
end
addCommandHandler("duty", openDutyWindow, false, false)

function itemIsAllowed(allowList, id)
	for key, value in pairs(allowList) do
		for k, v in pairs(value) do
			if tonumber(id) == tonumber(v[1]) then
				return true
			end
		end
	end
	return false
end

local gAvailablePackages = nil
local gChks = {}
local gButtons = {}
local gui = {}

function selectPackageGUI_open(availablePackages, allowList)
	gAvailablePackages = availablePackages
	local screenWidth, screenHeight = guiGetScreenSize()
	local windowWidth, windowHeight = 680, 516
	local left = screenWidth / 2 - windowWidth / 2
	local top = screenHeight / 2 - windowHeight / 2
	gui["_root"] = guiCreateWindow(left, top, windowWidth, windowHeight, "Görev Seçimi", false)
	guiWindowSetSizable(gui["_root"], false)

	gui["tabSelection"] = guiCreateTabPanel(10, 25, 651, 471, false, gui["_root"])
	for pIndex, packageDetails in ipairs(availablePackages) do
		local guiTabName = "package" .. tostring(packageDetails[1])
		gui[guiTabName] = guiCreateTab(packageDetails[2], gui["tabSelection"])
		setElementData(gui[guiTabName], "tab:factionID", packageDetails.factionID)

		local xAxis = 10
		local yAxis = 20

		for index, itemDetails in pairs(packageDetails[5]) do
			local guiPrefix = guiTabName .. "-package" .. tostring(index) .. "-"

			gui[guiPrefix .. "chk1"] =
				guiCreateCheckBox(xAxis + 30, yAxis + 50, 16, 17, "chk", false, false, gui[guiTabName])
			setElementData(gui[guiPrefix .. "chk1"], "button:action", "İt")
			setElementData(gui[guiPrefix .. "chk1"], "button:itemDetails", itemDetails)
			setElementData(gui[guiPrefix .. "chk1"], "button:itemID", index)
			setElementData(gui[guiPrefix .. "chk1"], "button:grantID", packageDetails[1])
			setElementData(gui[guiPrefix .. "chk1"], "button:chk", gui[guiPrefix .. "chk1"])
			addEventHandler("onClientGUIClick", gui[guiPrefix .. "chk1"], selectPackageGUI_process)
			addEventHandler("onClientGUIDoubleClick", gui[guiPrefix .. "chk1"], selectPackageGUI_process)
			table.insert(gChks, gui[guiPrefix .. "chk1"])

			gui[guiPrefix .. "pushButton1"] = guiCreateButton(
				xAxis,
				yAxis,
				71,
				51,
				exports.mek_item:getItemName(itemDetails[2]),
				false,
				gui[guiTabName]
			)
			setElementData(gui[guiPrefix .. "pushButton1"], "button:action", "İt")
			setElementData(gui[guiPrefix .. "pushButton1"], "button:chk", gui[guiPrefix .. "chk1"])
			addEventHandler("onClientGUIClick", gui[guiPrefix .. "pushButton1"], selectPackageGUI_process)
			gButtons[gui[guiPrefix .. "chk1"]] = gui[guiPrefix .. "pushButton1"]

			gui[guiPrefix .. "label_3"] =
				guiCreateLabel(xAxis, yAxis + 6, 71, 13, itemDetails[3], false, gui[guiTabName])
			guiLabelSetHorizontalAlign(gui[guiPrefix .. "label_3"], "left", false)
			guiLabelSetVerticalAlign(gui[guiPrefix .. "label_3"], "center")
			guiSetProperty(gui[guiPrefix .. "label_3"], "AlwaysOnTop", "True")

			if not itemIsAllowed(allowList, itemDetails[1]) then
				guiLabelSetColor(gui[guiPrefix .. "label_3"], 255, 0, 0)
				guiSetEnabled(gui[guiPrefix .. "pushButton1"], false)
				guiSetEnabled(gui[guiPrefix .. "chk1"], false)
			end

			xAxis = xAxis + 80

			if xAxis >= 650 then
				xAxis = 10
				yAxis = yAxis + 70
			end
		end

		local skinTable = {}

		if packageDetails[3] then
			for i, a in pairs(packageDetails[3]) do
				local a = table.concat(a, ";")
				table.insert(skinTable, tostring(a))
			end
		end

		local xAxis = 0
		local yAxis = 200

		local count = 0
		for index, value in pairs(skinTable) do
			count = count + 1

			local skinExploded = split(value, ";")
			local skinID = skinExploded[1]
			local skinImg = ("%03d"):format(skinID:gsub(":(.*)$", ""), 10)

			gui[guiTabName .. "-radio-" .. skinID] =
				guiCreateRadioButton(xAxis + 30, yAxis + 80, 15, 15, "", false, gui[guiTabName])
			setElementData(gui[guiTabName .. "-radio-" .. skinID], "button:skin", value)
			setElementData(gui[guiTabName .. "-radio-" .. skinID], "button:grantID", packageDetails[1])
			table.insert(gChks, gui[guiTabName .. "-radio-" .. skinID])

			if index == 1 then
				guiRadioButtonSetSelected(gui[guiTabName .. "-radio-" .. skinID], true)
			end

			gui[guiTabName .. "-skin-" .. skinID] = guiCreateStaticImage(
				xAxis,
				yAxis,
				75,
				75,
				":mek_item/public/images/skins/" .. skinImg .. ".png",
				false,
				gui[guiTabName]
			)
			setElementData(gui[guiTabName .. "-skin-" .. skinID], "button:action", "Radyo")
			setElementData(
				gui[guiTabName .. "-skin-" .. skinID],
				"button:element",
				gui[guiTabName .. "-radio-" .. skinID]
			)
			addEventHandler("onClientGUIClick", gui[guiTabName .. "-skin-" .. skinID], selectPackageGUI_process)
			xAxis = xAxis + 80

			if count == 8 then
				count = 0
				xAxis = 10
				yAxis = yAxis + 100
			end
		end

		gui[guiTabName .. "-cancel"] = guiCreateButton(10, 400, 200, 35, "İptal", false, gui[guiTabName])
		setElementData(gui[guiTabName .. "-cancel"], "button:action", "İptal")
		addEventHandler("onClientGUIClick", gui[guiTabName .. "-cancel"], selectPackageGUI_process)

		gui[guiTabName .. "-spawn"] = guiCreateButton(440, 400, 200, 35, "Kullan", false, gui[guiTabName])
		setElementData(gui[guiTabName .. "-spawn"], "button:action", "Kullan")
		setElementData(gui[guiTabName .. "-spawn"], "button:grantID", packageDetails[1])
		addEventHandler("onClientGUIClick", gui[guiTabName .. "-spawn"], selectPackageGUI_process)
	end
end

function selectPackageGUI_process(mouseButton, mouseState, absoluteX, absoluteY)
	if source and isElement(source) and mouseButton == "left" and mouseState == "up" then
		local theGUIelement = source
		local btnAction = getElementData(theGUIelement, "button:action")
		if btnAction then
			if btnAction == "İptal" then
				destroyElement(gui["_root"])
				gui = {}
				gChks = {}
				gAvailablePackages = {}
			elseif btnAction == "Radyo" then
				local victimElement = getElementData(theGUIelement, "button:element")
				if victimElement then
					guiRadioButtonSetSelected(victimElement, true)
				end
			elseif btnAction == "Kullan" then
				local grantID = getElementData(theGUIelement, "button:grantID")
				if grantID then
					local spawnRequest = {}
					local spawnSkin = {}

					for tableIndex, chkBox in ipairs(gChks) do
						local rowGrantID = getElementData(chkBox, "button:grantID")
						if rowGrantID == grantID then
							local rowItemDetails = getElementData(chkBox, "button:itemDetails")
							if rowItemDetails then
								if guiCheckBoxGetSelected(chkBox) then
									table.insert(spawnRequest, rowItemDetails)
								end
							end

							local rowSkinDetails = getElementData(chkBox, "button:skin")
							if rowSkinDetails then
								if guiRadioButtonGetSelected(chkBox) then
									spawnSkin = rowSkinDetails
								end
							end
						end
					end

					local factionID = getElementData(guiGetSelectedTab(gui["tabSelection"]), "tab:factionID")
					destroyElement(gui["_root"])
					gui = {}
					gChks = {}
					gAvailablePackages = {}
					triggerServerEvent("duty.request", localPlayer, grantID, spawnRequest, spawnSkin, factionID)
				end
			elseif btnAction == "İt" then
				local guiChk = getElementData(theGUIelement, "button:chk")
				if guiChk then
					local newstate = not guiCheckBoxGetSelected(guiChk)
					chkItemDetails = getElementData(guiChk, "button:itemDetails")
					if chkItemDetails and chkItemDetails[1] then
						for tableIndex, chkBox in ipairs(gChks) do
							cchkItemDetails = getElementData(chkBox, "button:itemDetails")
							if cchkItemDetails and cchkItemDetails[1] then
								if cchkItemDetails[1] == chkItemDetails[1] then
									guiCheckBoxSetSelected(chkBox, false)
									guiSetEnabled(gButtons[chkBox], not newstate)
								end
							end
						end
					end

					guiCheckBoxSetSelected(guiChk, newstate)
					guiSetEnabled(gButtons[guiChk], true)
				end
			end
		end
	end
end
