local window, tabPanel, gridLists = nil, nil, {}

function createGridList(tab, columns)
	local gridList = guiCreateGridList(10, 10, 660, 270, false, tab)
	for _, col in ipairs(columns) do
		guiGridListAddColumn(gridList, col.name, col.size)
	end
	return gridList
end

function fillGridList(gridList, data)
	for _, row in ipairs(data) do
		local rowIndex = guiGridListAddRow(gridList)
		for i, value in ipairs(row) do
			guiGridListSetItemText(gridList, rowIndex, i, tostring(value or "?"), false, false)
		end
	end
end

function createWindow(normalBans, manualBans, accountBans)
	if isElement(window) then
		destroyElement(window)
		return
	end

	if not exports.mek_integration:isPlayerGeneralAdmin(localPlayer) then
		return
	end

	window = guiCreateWindow(0, 0, 700, 400, "Banlar", false)
	exports.mek_global:centerWindow(window)

	tabPanel = guiCreateTabPanel(10, 24, 680, 315, false, window)

	local tab1 = guiCreateTab("Normal Banlar", tabPanel)
	gridLists[1] = createGridList(tab1, {
		{ name = "Karakter Adı", size = 0.2 },
		{ name = "Yetkili", size = 0.2 },
		{ name = "Sebep", size = 0.15 },
		{ name = "IP", size = 0.16 },
		{ name = "Serial", size = 0.24 },
	})
	fillGridList(gridLists[1], normalBans)

	local tab2 = guiCreateTab("Manuel Banlar", tabPanel)
	gridLists[2] = createGridList(tab2, {
		{ name = "Ban ID", size = 0.1 },
		{ name = "Serial", size = 0.25 },
		{ name = "IP", size = 0.15 },
		{ name = "Yetkili", size = 0.25 },
		{ name = "Sebep", size = 0.15 },
		{ name = "Tarih", size = 0.2 },
	})
	fillGridList(gridLists[2], manualBans)

	local tab3 = guiCreateTab("Hesap Banları", tabPanel)
	gridLists[3] = createGridList(tab3, {
		{ name = "Hesap ID", size = 0.1 },
		{ name = "Kullanıcı Adı", size = 0.8 },
	})
	fillGridList(gridLists[3], accountBans)

	local closeBtn = guiCreateButton(0.01, 0.87, 0.47, 0.10, "Kapat", true, window)
	local unbanBtn = guiCreateButton(0.5, 0.87, 0.48, 0.10, "Banı Aç", true, window)
	guiSetFont(closeBtn, "default-bold-small")
	guiSetFont(unbanBtn, "default-bold-small")

	addEventHandler("onClientGUIClick", root, function()
		if source == closeBtn then
			destroyElement(window)
			showCursor(false)
		elseif source == unbanBtn then
			local selectedTab = guiGetSelectedTab(tabPanel)
			if selectedTab == tab1 then
				local grid = gridLists[1]
				local row = guiGridListGetSelectedItem(grid)
				if row and row ~= -1 then
					local banData = {
						key = guiGridListGetItemText(grid, row, 5),
						serial = guiGridListGetItemText(grid, row, 5),
						ip = guiGridListGetItemText(grid, row, 4),
						reason = guiGridListGetItemText(grid, row, 3),
						admin = guiGridListGetItemText(grid, row, 2),
					}
					triggerServerEvent("bans.removeBan", localPlayer, 1, banData.key)
					destroyElement(window)
					showCursor(false)
				end
			elseif selectedTab == tab2 then
				local grid = gridLists[2]
				local row = guiGridListGetSelectedItem(grid)
				if row and row ~= -1 then
					local banData = {
						key = guiGridListGetItemText(grid, row, 1),
						id = guiGridListGetItemText(grid, row, 1),
						serial = guiGridListGetItemText(grid, row, 2),
						ip = guiGridListGetItemText(grid, row, 3),
						admin = guiGridListGetItemText(grid, row, 4),
						reason = guiGridListGetItemText(grid, row, 5),
						date = guiGridListGetItemText(grid, row, 6),
					}
					triggerServerEvent("bans.removeBan", localPlayer, 2, banData.key)
					destroyElement(window)
					showCursor(false)
				end
			elseif selectedTab == tab3 then
				local grid = gridLists[3]
				local row = guiGridListGetSelectedItem(grid)
				if row and row ~= -1 then
					local banData = {
						key = guiGridListGetItemText(grid, row, 1),
						id = guiGridListGetItemText(grid, row, 1),
						username = guiGridListGetItemText(grid, row, 2),
					}
					triggerServerEvent("bans.removeBan", localPlayer, 3, { banData.id, banData.username })
					destroyElement(window)
					showCursor(false)
				end
			end
		end
	end)
end
addEvent("bans.openWindow", true)
addEventHandler("bans.openWindow", root, createWindow)