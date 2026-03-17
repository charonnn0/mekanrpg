gFactionWindow, gMemberGrid, gMOTDLabel, colName, colRank, colWage, colDuty, colLastLogin, colOnline, colPhone, gButtonKick, gButtonPromote, gButtonDemote, gButtonEditRanks, gButtonEditMOTD, gButtonInvite, gButtonLeader, gButtonQuit, gButtonExit, wConfirmQuit, eNote =
	nil
theMotd, theTeam, arrUsernames, arrRanks, arrPerks, arrLeaders, arrOnline, arrFactionRanks, arrFactionWages, arrLastLogin, membersOnline, membersOffline, gButtonRespawn, gButtonPerk =
	nil
tabVehicles, gVehicleGrid, colVehID, colVehModel, colVehPlates, colVehLocation, gButtonVehRespawn, gButtonAllVehRespawn, gButtonYes, gButtonNo, showrespawnUI =
	nil
local tmpPhone = nil
local promotionWindow = {}
local promotionButton = {}
local promotionLabel = {}
local promotionRadio = {}
local ftab = {}

local function checkF3()
	if not f3state and getKeyState("f3") then
		hideFactionMenu()
	else
		f3state = getKeyState("f3")
	end
end

function showFactionMenu(
	motd,
	memberUsernames,
	memberRanks,
	memberPerks,
	memberLeaders,
	memberOnline,
	memberLastLogin,
	factionRanks,
	factionWages,
	factionTheTeam,
	note,
	fnote,
	vehicleIDs,
	vehicleModels,
	vehiclePlates,
	vehicleLocations,
	memberOnDuty,
	phone,
	membersPhone,
	fromShowF,
	factionID,
	properties,
	factionRankID,
	rankOrder
)
	if gFactionWindow == nil then
		invitedPlayer = nil
		arrUsernames = memberUsernames
		arrRanks = memberRanks
		arrLeaders = memberLeaders
		arrPerks = memberPerks
		arrOnline = memberOnline
		arrLastLogin = memberLastLogin
		faction_tab = factionID
		arrFactionRanks = factionRanks
		arrFactionWages = factionWages

		if motd == nil then
			motd = ""
		end

		theMotd = motd
		tmpPhone = phone

		local thePlayer = localPlayer
		theTeam = factionTheTeam
		local teamName = getTeamName(theTeam)
		local playerName = getPlayerName(thePlayer)
		gFactionWindow = guiCreateWindow(0.1, 0.25, 0.85, 0.525, "Birlik Arayüzü", true)
		local width, height = guiGetSize(gFactionWindow, false)
		
		if height < 500 then
			guiSetSize(gFactionWindow, width, 500, false)
			local posx, posy = guiGetPosition(gFactionWindow, false)
			local screenx, screeny = guiGetScreenSize()
			guiSetPosition(gFactionWindow, posx, (screeny - 500) / 2, false)
		end
		
		guiWindowSetSizable(gFactionWindow, false)
		guiSetInputEnabled(true)

		ftabs = guiCreateTabPanel(0, 0.04, 1, 1, true, gFactionWindow)
		ftab[factionID] = guiCreateTab("#" .. factionID .. " - " .. teamName, ftabs)
		setElementData(ftab[factionID], "factionID", factionID)
		addEventHandler("onClientGUITabSwitched", ftab[factionID], loadFaction, false)

		local factionTable = getElementData(localPlayer, "faction")
		local organizedTable = {}
		for i, k in pairs(factionTable) do
			organizedTable[k.count] = i
		end

		for k, id in ipairs(organizedTable) do
			if id ~= factionID then
				ftab[id] = guiCreateTab("#" .. id .. " - " .. getFactionName(id), ftabs)
				setElementData(ftab[id], "factionID", id)
				addEventHandler("onClientGUITabSwitched", ftab[id], loadFaction, false)
			end
		end

		tabs = guiCreateTabPanel(0.008, 0.01, 0.985, 0.97, true, ftab[factionID])
		tabOverview = guiCreateTab("Genel Bakış", tabs)

		gMemberGrid = guiCreateGridList(0.01, 0.015, 0.8, 0.905, true, tabOverview)

		colName = guiGridListAddColumn(gMemberGrid, "İsim", 0.20)
		colRank = guiGridListAddColumn(gMemberGrid, "Rütbe", 0.20)
		colOnline = guiGridListAddColumn(gMemberGrid, "Durum", 0.115)
		colLastLogin = guiGridListAddColumn(gMemberGrid, "Son Giriş", 0.13)

		local factionType = tonumber(getElementData(theTeam, "type"))

		if
			(factionType == 2)
			or (factionType == 3)
			or (factionType == 4)
			or (factionType == 5)
			or (factionType == 6)
			or (factionType == 7)
		then
			colWage = guiGridListAddColumn(gMemberGrid, "Maaş (₺)", 0.06)
		end

		if phone then
			colPhone = guiGridListAddColumn(gMemberGrid, "Telefon No.", 0.08)
		end

		local factionPackages = exports.mek_duty:getFactionPackages(factionID)
		if factionPackages and factionType >= 2 then
			colDuty = guiGridListAddColumn(gMemberGrid, "Görev", 0.06)
		end

		local localPlayerIsLeader = nil
		local counterOnline, counterOffline = 0, 0

		for k, v in ipairs(rankOrder) do
			local rID = tonumber(v)
			for x, y in pairs(memberRanks) do
				local y = tonumber(y)
				if rID == y then
					local row = guiGridListAddRow(gMemberGrid)
					guiGridListSetItemText(
						gMemberGrid,
						row,
						colName,
						string.gsub(tostring(memberUsernames[x]), "_", " "),
						false,
						false
					)

					local theRank = tonumber(rID)
					local rankName = factionRanks[theRank]
					guiGridListSetItemText(gMemberGrid, row, colRank, tostring(rankName), false, false)
					guiGridListSetItemData(gMemberGrid, row, colRank, tostring(theRank))

					local login = "Asla"
					if not memberLastLogin[x] then
						login = "Asla"
					else
						if memberLastLogin[x] == 0 then
							login = "Bugün"
						else
							login = tostring(memberLastLogin[x]) .. " gün önce"
						end
					end
					guiGridListSetItemText(gMemberGrid, row, colLastLogin, login, false, false)

					if
						(factionType == 2)
						or (factionType == 3)
						or (factionType == 4)
						or (factionType == 5)
						or (factionType == 6)
						or (factionType == 7)
					then
						local rankWage = factionWages[theRank] or 0
						guiGridListSetItemText(gMemberGrid, row, colWage, tostring(rankWage), false, true)
					end

					if memberOnline[x] then
						guiGridListSetItemText(gMemberGrid, row, colOnline, "Çevrimiçi", false, false)
						guiGridListSetItemColor(gMemberGrid, row, colOnline, 0, 255, 0)
						counterOnline = counterOnline + 1
					else
						guiGridListSetItemText(gMemberGrid, row, colOnline, "Çevrimdışı", false, false)
						guiGridListSetItemColor(gMemberGrid, row, colOnline, 255, 0, 0)
						counterOffline = counterOffline + 1
					end

					if colDuty then
						if memberOnDuty[x] then
							guiGridListSetItemText(gMemberGrid, row, colDuty, "Görevde", false, false)
							guiGridListSetItemColor(gMemberGrid, row, colDuty, 0, 255, 0)
						else
							guiGridListSetItemText(gMemberGrid, row, colDuty, "Görev Dışı", false, false)
							guiGridListSetItemColor(gMemberGrid, row, colDuty, 255, 0, 0)
						end
					end

					if phone and colPhone then
						if membersPhone[x] then
							guiGridListSetItemText(
								gMemberGrid,
								row,
								colPhone,
								tostring(phone) .. "-" .. tostring(membersPhone[x]),
								false,
								true
							)
						else
							guiGridListSetItemText(gMemberGrid, row, colPhone, "", false, true)
						end
					end
				end
			end
		end

		membersOnline = counterOnline
		membersOffline = counterOffline

		guiSetText(
			ftab[factionID],
			"#" .. factionID .. " - "
				.. tostring(teamName)
				.. " ("
				.. (counterOnline + counterOffline)
				.. " Üyeden "
				.. counterOnline
				.. "'i Çevrimiçi)"
		)

		if hasMemberPermissionTo(localPlayer, factionID, "del_member") then
			gButtonKick = guiCreateButton(0.825, 0.076, 0.16, 0.06, "Birlikten At", true, tabOverview)
			addEventHandler("onClientGUIClick", gButtonKick, btKickPlayer, false)
		end
		if hasMemberPermissionTo(localPlayer, factionID, "change_member_rank") then
			gButtonPromote = guiCreateButton(0.825, 0.1526, 0.16, 0.06, "Rütbesini Düzenle", true, tabOverview)
			addEventHandler("onClientGUIClick", gButtonPromote, btPromotePlayer, false)
		end

		if
			(factionType == 2)
			or (factionType == 3)
			or (factionType == 4)
			or (factionType == 5)
			or (factionType == 6)
			or (factionType == 7)
		then
			if hasMemberPermissionTo(localPlayer, factionID, "modify_ranks") then
				gButtonEditRanks =
					guiCreateButton(0.825, 0.2292, 0.16, 0.06, "Rütbeleri ve Maaşları Düzenle", true, tabOverview)
				addEventHandler("onClientGUIClick", gButtonEditRanks, btEditRanks, false)
			end
		else
			if hasMemberPermissionTo(localPlayer, factionID, "modify_ranks") then
				gButtonEditRanks = guiCreateButton(0.825, 0.2292, 0.16, 0.06, "Rütbeleri Düzenle", true, tabOverview)
				addEventHandler("onClientGUIClick", gButtonEditRanks, btEditRanks, false)
			end
		end
		if hasMemberPermissionTo(localPlayer, factionID, "edit_motd") then
			gButtonEditMOTD = guiCreateButton(0.825, 0.3058, 0.16, 0.06, "MOTD'yi Düzenle", true, tabOverview)
			addEventHandler("onClientGUIClick", gButtonEditMOTD, btEditMOTD, false)
		end
		if hasMemberPermissionTo(localPlayer, factionID, "add_member") then
			gButtonInvite = guiCreateButton(0.825, 0.3824, 0.16, 0.06, "Üye Davet Et", true, tabOverview)
			addEventHandler("onClientGUIClick", gButtonInvite, btInvitePlayer, false)
		end
		if hasMemberPermissionTo(localPlayer, factionID, "respawn_vehs") then
			gButtonRespawnui = guiCreateButton(0.825, 0.459, 0.16, 0.06, "Araçları Yenile", true, tabOverview)
			addEventHandler("onClientGUIClick", gButtonRespawnui, showrespawn, false)
		end

		local _y = 0.5356
		if phone then
			gAssignPhone = guiCreateButton(0.825, _y, 0.16, 0.06, "Telefon No.", true, tabOverview)
			addEventHandler("onClientGUIClick", gAssignPhone, btPhoneNumber, false)
			_y = _y + 0.0766
		end

		if factionType >= 2 then
			if hasMemberPermissionTo(localPlayer, factionID, "set_member_duty") then
				gButtonPerk = guiCreateButton(0.825, _y, 0.16, 0.06, "Görev Yetkilerini Düzenle", true, tabOverview)
				addEventHandler("onClientGUIClick", gButtonPerk, btButtonPerk, false)
			end
		end

		if hasMemberPermissionTo(localPlayer, factionID, "respawn_vehs") then
			tabVehicles = guiCreateTab("(Lider) Araçlar", tabs)

			gVehicleGrid = guiCreateGridList(0.01, 0.015, 0.8, 0.905, true, tabVehicles)

			colVehID = guiGridListAddColumn(gVehicleGrid, "ID", 0.1)
			colVehModel = guiGridListAddColumn(gVehicleGrid, "Model", 0.30)
			colVehPlates = guiGridListAddColumn(gVehicleGrid, "Plaka", 0.1)
			colVehLocation = guiGridListAddColumn(gVehicleGrid, "Konum", 0.4)
			gButtonVehRespawn = guiCreateButton(0.825, 0.076, 0.16, 0.06, "Aracı Yenile", true, tabVehicles)
			gButtonAllVehRespawn = guiCreateButton(0.825, 0.1526, 0.16, 0.06, "Araçları Yenile", true, tabVehicles)

			for index, vehID in ipairs(vehicleIDs) do
				local row = guiGridListAddRow(gVehicleGrid)
				guiGridListSetItemText(gVehicleGrid, row, colVehID, tostring(vehID), false, true)
				guiGridListSetItemText(gVehicleGrid, row, colVehModel, tostring(vehicleModels[index]), false, false)
				guiGridListSetItemText(gVehicleGrid, row, colVehPlates, tostring(vehiclePlates[index]), false, false)
				guiGridListSetItemText(
					gVehicleGrid,
					row,
					colVehLocation,
					tostring(vehicleLocations[index]),
					false,
					false
				)
			end
			addEventHandler("onClientGUIClick", gButtonVehRespawn, btRespawnOneVehicle, false)
			addEventHandler("onClientGUIClick", gButtonAllVehRespawn, showrespawn, false)
		end

		if hasMemberPermissionTo(localPlayer, factionID, "manage_interiors") then
			tabProperties = guiCreateTab("(Lider) Mülkler", tabs)

			gPropertyGrid = guiCreateGridList(0.01, 0.015, 0.8, 0.905, true, tabProperties)

			colProID = guiGridListAddColumn(gPropertyGrid, "ID", 0.1)
			colName = guiGridListAddColumn(gPropertyGrid, "İsim", 0.30)
			colProLocation = guiGridListAddColumn(gPropertyGrid, "Konum", 0.4)

			for index, int in ipairs(properties) do
				local row = guiGridListAddRow(gPropertyGrid)
				guiGridListSetItemText(gPropertyGrid, row, colProID, tostring(int[1]), false, true)
				guiGridListSetItemText(gPropertyGrid, row, colName, tostring(int[2]), false, false)
				guiGridListSetItemText(gPropertyGrid, row, colProLocation, tostring(int[3]), false, false)
			end
		end
		if hasMemberPermissionTo(localPlayer, factionID, "modify_factionl_note") then
			tabNote = guiCreateTab("(Lider) Not", tabs)
			eNote = guiCreateMemo(0.01, 0.02, 0.98, 0.87, note or "", true, tabNote)
			gButtonSaveNote = guiCreateButton(0.79, 0.90, 0.2, 0.08, "Kaydet", true, tabNote)
			addEventHandler("onClientGUIClick", gButtonSaveNote, btUpdateNote, false)
		end

		if hasMemberPermissionTo(localPlayer, factionID, "modify_faction_note") then
			tabFNote = guiCreateTab("Not", tabs)
			fNote = guiCreateMemo(0.01, 0.02, 0.98, 0.87, fnote or "", true, tabFNote)
			guiMemoSetReadOnly(fNote, false)

			gButtonSaveFNote = guiCreateButton(0.79, 0.90, 0.2, 0.08, "Kaydet", true, tabFNote)
			addEventHandler("onClientGUIClick", gButtonSaveFNote, btUpdateFNote, false)
		else
			tabFNote = guiCreateTab("Not", tabs)
			fNote = guiCreateMemo(0.01, 0.02, 0.98, 0.87, fnote or "", true, tabFNote)
			guiMemoSetReadOnly(fNote, true)
		end

		if factionType >= 2 then
			if hasMemberPermissionTo(localPlayer, factionID, "modify_duty_settings") then
				tabDuty = guiCreateTab("(Lider) Görev Ayarları", tabs)
				addEventHandler("onClientGUITabSwitched", tabDuty, createDutyMain)
			end
		end

		gButtonQuit = guiCreateButton(0.825, 0.7834, 0.16, 0.06, "Birlikten Ayrıl", true, tabOverview)
		gButtonExit = guiCreateButton(0.825, 0.86, 0.16, 0.06, "Arayüzü Kapat", true, tabOverview)
		gMOTDLabel = guiCreateLabel(0.015, 0.935, 0.95, 0.15, tostring(motd), true, tabOverview)
		guiSetFont(gMOTDLabel, "default-bold-small")

		addEventHandler("onClientGUIClick", gButtonQuit, btQuitFaction, false)
		addEventHandler("onClientGUIClick", gButtonExit, hideFactionMenu, false)

		guiSetEnabled(gButtonQuit, isPlayerInFaction(localPlayer, factionID))

		addEventHandler("onClientRender", root, checkF3)
		f3state = getKeyState("f3")
	else
		hideFactionMenu()
	end
	showCursor(true)
end
addEvent("showFactionMenu", true)
addEventHandler("showFactionMenu", root, showFactionMenu)

function showrespawn()
	local sx, sy = guiGetScreenSize()

	showrespawnUI = guiCreateWindow(sx / 2 - 150, sy / 2 - 50, 300, 100, "Araç Yenilemesi", false)
	local lQuestion = guiCreateLabel(
		0.05,
		0.25,
		0.9,
		0.3,
		"Birlik araçlarını yeniden canlandırmak istediğinizden emin misiniz?",
		true,
		showrespawnUI
	)
	guiLabelSetHorizontalAlign(lQuestion, "center", true)
	gButtonRespawn = guiCreateButton(0.1, 0.65, 0.37, 0.23, "Evet", true, showrespawnUI)
	gButtonNo = guiCreateButton(0.53, 0.65, 0.37, 0.23, "Hayır", true, showrespawnUI)

	addEventHandler("onClientGUIClick", gButtonRespawn, btRespawnVehicles, false)
	addEventHandler("onClientGUIClick", gButtonNo, btRespawnVehicles, false)
end
addEvent("showrespawn", true)
addEventHandler("showrespawn", root, showrespawn)

lRanks = {}
tRanks = {}
tRankWages = {}
wRanks = nil
bRanksSave, bRanksClose = nil

function saveRanks(button, state)
	if (source == bRanksSave) and (button == "left") and (state == "up") then
		local found = false
		local isNumber = true
		for key, value in ipairs(tRanks) do
			if (string.find(guiGetText(tRanks[key]), ";")) or (string.find(guiGetText(tRanks[key]), "'")) then
				found = true
			end
		end

		local factionType = tonumber(getElementData(theTeam, "type"))
		if
			(factionType == 2)
			or (factionType == 3)
			or (factionType == 4)
			or (factionType == 5)
			or (factionType == 6)
			or (factionType == 7)
		then
			for key, value in ipairs(tRankWages) do
				if not (tostring(type(tonumber(guiGetText(tRankWages[key])))) == "number") then
					isNumber = false
				end
			end
		end

		if found then
			outputChatBox(
				"[!]#FFFFFF Sıralamalarınız geçersiz karakterler içeriyor, lütfen '@.;' gibi karakterler içermediğinden emin olun.",
				255,
				0,
				0,
				true
			)
		elseif not isNumber then
			outputChatBox(
				"[!]#FFFFFF Maaşınız rakamdan ibaret değildir, lütfen rakam girdiğinizden ve para birimi sembolü kullanmadığınızdan emin olun.",
				255,
				0,
				0,
				true
			)
		else
			local sendRanks = {}
			local sendWages = {}

			for key, value in ipairs(tRanks) do
				sendRanks[key] = guiGetText(tRanks[key])
			end

			if
				(factionType == 2)
				or (factionType == 3)
				or (factionType == 4)
				or (factionType == 5)
				or (factionType == 6)
				or (factionType == 7)
			then
				for key, value in ipairs(tRankWages) do
					sendWages[key] = guiGetText(tRankWages[key])
				end
			end

			hideFactionMenu()
			if
				(factionType == 2)
				or (factionType == 3)
				or (factionType == 4)
				or (factionType == 5)
				or (factionType == 6)
				or (factionType == 7)
			then
				triggerServerEvent("cguiUpdateRanks", localPlayer, sendRanks, sendWages, faction_tab)
			else
				triggerServerEvent("cguiUpdateRanks", localPlayer, sendRanks, nil, faction_tab)
			end
		end
	end
end

function closeRanks(button, state)
	if (source == bRanksClose) and (button == "left") and (state == "up") then
		if wRanks then
			destroyElement(wRanks)
			lRanks, tRanks, tRankWages, wRanks, bRanksSave, bRanksClose = nil, nil, nil, nil, nil, nil
			guiSetInputEnabled(false)
		end
	end
end

wMOTD, tMOTD, bUpdate, bMOTDClose = nil
function btEditMOTD(button, state)
	if (source == gButtonEditMOTD) and (button == "left") and (state == "up") then
		if not wMOTD then
			local width, height = 300, 200
			local scrWidth, scrHeight = guiGetScreenSize()
			local x = scrWidth / 2 - (width / 2)
			local y = scrHeight / 2 - (height / 2)

			wMOTD = guiCreateWindow(x, y, width, height, "Günün Mesajı", false)
			tMOTD = guiCreateEdit(0.1, 0.2, 0.85, 0.1, tostring(theMotd), true, wMOTD)

			guiSetInputEnabled(true)

			bUpdate = guiCreateButton(0.1, 0.6, 0.85, 0.15, "Güncelle", true, wMOTD)
			addEventHandler("onClientGUIClick", bUpdate, sendMOTD, false)

			bMOTDClose = guiCreateButton(0.1, 0.775, 0.85, 0.15, "Kapat", true, wMOTD)
			addEventHandler("onClientGUIClick", bMOTDClose, closeMOTD, false)
		else
			guiBringToFront(wMOTD)
		end
	end
end

function closeMOTD(button, state)
	if (source == bMOTDClose) and (button == "left") and (state == "up") then
		if wMOTD then
			destroyElement(wMOTD)
			wMOTD, tMOTD, bUpdate, bMOTDClose = nil, nil, nil, nil
		end
	end
end

function sendMOTD(button, state)
	if (source == bUpdate) and (button == "left") and (state == "up") then
		local motd = guiGetText(tMOTD)

		local found1 = string.find(motd, ";")
		local found2 = string.find(motd, "'")

		if found1 or found2 then
			outputChatBox("[!]#FFFFFF Mesajınız geçersiz karakterler içeriyor.", 255, 0, 0, true)
		else
			guiSetText(gMOTDLabel, tostring(motd))
			theMOTD = motd
			triggerServerEvent("cguiUpdateMOTD", localPlayer, motd, faction_tab)
		end
	end
end

function btUpdateNote(button, state)
	if button == "left" and state == "up" then
		triggerServerEvent("faction.note", localPlayer, guiGetText(eNote), faction_tab)
	end
end

function btUpdateFNote(button, state)
	if button == "left" and state == "up" then
		triggerServerEvent("faction.fnote", localPlayer, guiGetText(fNote), faction_tab)
	end
end

wInvite, tInvite, lNameCheck, bInvite, bInviteClose, invitedPlayer = nil
function btInvitePlayer(button, state)
	if (source == gButtonInvite) and (button == "left") and (state == "up") then
		if not wInvite then
			local width, height = 300, 200
			local scrWidth, scrHeight = guiGetScreenSize()
			local x = scrWidth / 2 - (width / 2)
			local y = scrHeight / 2 - (height / 2)

			wInvite = guiCreateWindow(x, y, width, height, "Üye Davet Et", false)
			tInvite = guiCreateEdit(0.1, 0.2, 0.85, 0.1, "Karakter Adı", true, wInvite)
			addEventHandler("onClientGUIChanged", tInvite, checkNameExists)

			lNameCheck = guiCreateLabel(
				0.1,
				0.325,
				0.8,
				0.3,
				"Oyuncu bulunamadı veya birden fazla oyuncu bulundu.",
				true,
				wInvite
			)
			guiSetFont(lNameCheck, "default-bold-small")
			guiLabelSetColor(lNameCheck, 255, 0, 0)
			guiLabelSetHorizontalAlign(lNameCheck, "center")

			guiSetInputEnabled(true)

			bInvite = guiCreateButton(0.1, 0.6, 0.85, 0.15, "Davet Et", true, wInvite)
			guiSetEnabled(bInvite, false)
			addEventHandler("onClientGUIClick", bInvite, sendInvite, false)

			bCloseInvite = guiCreateButton(0.1, 0.775, 0.85, 0.15, "Kapat", true, wInvite)
			addEventHandler("onClientGUIClick", bCloseInvite, closeInvite, false)
		else
			guiBringToFront(wInvite)
		end
	end
end

function closeInvite(button, state)
	if (source == bCloseInvite) and (button == "left") and (state == "up") then
		if wInvite then
			destroyElement(wInvite)
			wInvite, tInvite, lNameCheck, bInvite, bInviteClose, invitedPlayer = nil, nil, nil, nil, nil, nil
		end
	end
end

function sendInvite(button, state)
	if (source == bInvite) and (button == "left") and (state == "up") then
		triggerServerEvent("cguiInvitePlayer", localPlayer, invitedPlayer, faction_tab)
	end
end

function checkNameExists(theEditBox)
	local found = nil
	local foundstr = ""
	local count = 0

	local players = getElementsByType("player")
	for key, value in ipairs(players) do
		local username = string.lower(tostring(getPlayerName(value)))
		if
			(string.find(username, string.lower(tostring(guiGetText(theEditBox))))) and (guiGetText(theEditBox) ~= "")
		then
			count = count + 1
			found = value
			foundstr = username
		end
	end

	if count > 1 then
		guiSetText(lNameCheck, "Birden fazla bulundu.")
		guiLabelSetColor(lNameCheck, 255, 255, 0)
		guiSetEnabled(bInvite, false)
	elseif count == 1 then
		guiSetText(lNameCheck, "Oyuncu bulundu. (" .. foundstr .. ")")
		guiLabelSetColor(lNameCheck, 0, 255, 0)
		invitedPlayer = found
		guiSetEnabled(bInvite, true)
	elseif count == 0 then
		guiSetText(lNameCheck, "Oyuncu bulunamadı veya birden fazla oyuncu bulundu.")
		guiLabelSetColor(lNameCheck, 255, 0, 0)
		guiSetEnabled(bInvite, false)
	end
	guiLabelSetHorizontalAlign(lNameCheck, "center")
end

function btQuitFaction(button, state)
	if (button == "left") and (state == "up") and (source == gButtonQuit) then
		local numLeaders = 0
		local isLeader = false
		local localUsername = getPlayerName(localPlayer)

		for k, v in ipairs(arrUsernames) do
			if v == localUsername then
				isLeader = arrLeaders[k]
			end
		end

		for k, v in ipairs(arrLeaders) do
			numLeaders = numLeaders + 1
		end

		local sx, sy = guiGetScreenSize()
		wConfirmQuit = guiCreateWindow(sx / 2 - 125, sy / 2 - 50, 250, 100, "Ayrılma Onayı", false)
		local lQuestion = guiCreateLabel(
			0.05,
			0.25,
			0.9,
			0.3,
			"Gerçekten " .. getTeamName(theTeam) .. " isimli birlikten ayrılmak mı istiyorsunuz?",
			true,
			wConfirmQuit
		)
		guiLabelSetHorizontalAlign(lQuestion, "center", true)
		local bYes = guiCreateButton(0.1, 0.65, 0.37, 0.23, "Evet", true, wConfirmQuit)
		local bNo = guiCreateButton(0.53, 0.65, 0.37, 0.23, "Hayır", true, wConfirmQuit)
		addEventHandler("onClientGUIClick", root, function(button)
			if button == "left" and (source == bYes or source == bNo) then
				if source == bYes then
					hideFactionMenu()
					triggerServerEvent("cguiQuitFaction", localPlayer, faction_tab)
				end
				if wConfirmQuit then
					destroyElement(wConfirmQuit)
					wConfirmQuit = nil
				end
			end
		end)
	end
end

function btKickPlayer(button, state)
	if (button == "left") and (state == "up") and (source == gButtonKick) then
		local playerName =
			string.gsub(guiGridListGetItemText(gMemberGrid, guiGridListGetSelectedItem(gMemberGrid), 1), " ", "_")

		if playerName ~= "" then
			local row = guiGridListGetSelectedItem(gMemberGrid)
			guiGridListRemoveRow(gMemberGrid, row)

			local theTeamName = getTeamName(theTeam)

			outputChatBox(
				"[!]#FFFFFF  "
					.. playerName:gsub("_", " ")
					.. " isimli oyuncuyu '"
					.. tostring(theTeamName)
					.. "' isimli birlikten attınız.",
				0,
				255,
				0,
				true
			)
			triggerServerEvent("cguiKickPlayer", localPlayer, playerName, faction_tab)
		else
			outputChatBox("[!]#FFFFFF Lütfen atılacak bir üye seçin.", 255, 0, 0, true)
		end
	end
end

function btButtonPerk(button, state)
	if (button == "left") and (state == "up") and (source == gButtonPerk) then
		local bPerkActivePlayer = guiGridListGetItemText(gMemberGrid, guiGridListGetSelectedItem(gMemberGrid), 1)
		local playerName = string.gsub(bPerkActivePlayer, " ", "_")
		if playerName == "" then
			outputChatBox("[!]#FFFFFF Lütfen yönetmek için bir üye seçin.", 255, 0, 0, true)
			return
		end
		triggerServerEvent("duty.getPackages", resourceRoot, faction_tab)
	end
end

wPerkWindow, bPerkSave, bPerkClose, bPerkChkTable, bPerkActivePlayer = nil
function gotPackages(factionPackages)
	bPerkChkTable = {}
	local bPerkActivePlayer = guiGridListGetItemText(gMemberGrid, guiGridListGetSelectedItem(gMemberGrid), 1)
	local playerName = string.gsub(bPerkActivePlayer, " ", "_")

	guiSetInputEnabled(true)

	local width, height = 500, 540
	local scrWidth, scrHeight = guiGetScreenSize()
	local x = scrWidth / 2 - (width / 2)
	local y = scrHeight / 2 - (height / 2)

	wPerkWindow = guiCreateWindow(x, y, width, height, playerName .. " için birlik avantajları", false)

	local factionPerks = false
	for k, v in ipairs(arrUsernames) do
		if v == playerName then
			factionPerks = arrPerks[k]
		end
	end

	if not factionPerks then
		outputChatBox(
			"[!]#FFFFFF " .. playerName .. " isimli oyuncunun birlik avantajları yüklenemedi.",
			255,
			0,
			0,
			true
		)
		factionPerks = {}
	end

	local y = 0
	for index, factionPackage in pairs(factionPackages) do
		y = (y or 0) + 20
		local tmpChk =
			guiCreateCheckBox(0.05 * width, y + 3, 0.4 * width, 17, factionPackage[2], false, false, wPerkWindow)
		guiSetFont(tmpChk, "default-bold-small")
		setElementData(tmpChk, "factionPackage:ID", factionPackage[1], false)
		setElementData(tmpChk, "factionPackage:selected", bPerkActivePlayer, false)

		for index, permissionID in pairs(factionPerks) do
			if permissionID == factionPackage[1] then
				guiCheckBoxSetSelected(tmpChk, true)
			end
		end

		table.insert(bPerkChkTable, tmpChk)
	end

	bPerkSave = guiCreateButton(0.05, 0.900, 0.9, 0.045, "Kaydet", true, wPerkWindow)
	bPerkClose = guiCreateButton(0.05, 0.950, 0.9, 0.045, "Kapat", true, wPerkWindow)
	addEventHandler("onClientGUIClick", bPerkSave, function(button, state)
		if (source == bPerkSave) and (button == "left") and (state == "up") then
			if wPerkWindow then
				local collectedPerks = {}
				for _, checkBox in ipairs(bPerkChkTable) do
					if guiCheckBoxGetSelected(checkBox) then
						table.insert(collectedPerks, getElementData(checkBox, "factionPackage:ID") or -1)
					end
				end

				triggerServerEvent("faction.perks:edit", localPlayer, collectedPerks, playerName, faction_tab)
				destroyElement(wPerkWindow)
				wPerkWindow, bPerkSave, bPerkClose, bPerkChkTable, bPerkActivePlayer = nil
				guiSetInputEnabled(false)
			end
		end
	end, false)
	addEventHandler("onClientGUIClick", bPerkClose, function(button, state)
		if (source == bPerkClose) and (button == "left") and (state == "up") then
			if wPerkWindow then
				destroyElement(wPerkWindow)
				wPerkWindow, bPerkSave, bPerkClose, bPerkChkTable, bPerkActivePlayer = nil
				guiSetInputEnabled(false)
			end
		end
	end, false)
end
addEvent("duty.gotPackages", true)
addEventHandler("duty.gotPackages", resourceRoot, gotPackages)

function btRespawnOneVehicle(button, state)
	if button == "left" and state == "up" then
		local vehID = guiGridListGetItemText(gVehicleGrid, guiGridListGetSelectedItem(gVehicleGrid), 1)
		if vehID then
			triggerServerEvent("cguiRespawnOneVehicle", localPlayer, vehID, faction_tab)
		else
			outputChatBox("Please select a vehicle to respawn.", 255, 0, 0)
		end
	end
end

local wPhone, tPhone
function btPhoneNumber(button, state)
	if (button == "left") and (state == "up") and (source == gAssignPhone) then
		local row = guiGridListGetSelectedItem(gMemberGrid)
		local playerName = guiGridListGetItemText(gMemberGrid, guiGridListGetSelectedItem(gMemberGrid), 1)

		if playerName ~= "" then
			local currentPhone = guiGridListGetItemText(gMemberGrid, row, colPhone):gsub(tmpPhone .. "%-", "")
			if not wPhone then
				local width, height = 300, 200
				local scrWidth, scrHeight = guiGetScreenSize()
				local x = scrWidth / 2 - (width / 2)
				local y = scrHeight / 2 - (height / 2)

				wPhone = guiCreateWindow(x, y, width, height, "Telefon Numarası", false)
				tPhone = guiCreateEdit(0.3, 0.325, 0.85, 0.1, currentPhone, true, wPhone)
				guiSetProperty(tPhone, "ValidationString", "[0-9]{0,2}")

				local tPre = guiCreateLabel(0.1, 0.325, 0.18, 0.1, tostring(tmpPhone) .. " -", true, wPhone)
				guiLabelSetHorizontalAlign(tPre, "right")
				guiSetFont(tPre, "default-bold-small")
				guiLabelSetVerticalAlign(tPre, "center")

				guiCreateLabel(0.1, 0.2, 0.8, 0.08, playerName .. " isimli oyuncunun telefon numarası:", true, wPhone)

				guiSetInputEnabled(true)

				bSet = guiCreateButton(0.1, 0.6, 0.85, 0.15, "0", true, wPhone)
				addEventHandler("onClientGUIClick", bSet, setPhoneNumber, false)

				bClosePhone = guiCreateButton(0.1, 0.775, 0.85, 0.15, "Kapat", true, wPhone)
				addEventHandler("onClientGUIClick", bClosePhone, closePhone, false)

				addEventHandler("onClientGUIChanged", tPhone, function(element)
					guiSetEnabled(
						bSet,
						guiGetText(element) == ""
							or (
								#guiGetText(element) == 2
								and type(tonumber(guiGetText(element))) == "number"
								and numberIsUnused(tonumber(guiGetText(element)))
							)
					)
				end, false)
			else
				guiBringToFront(wPhone)
			end
		else
			outputChatBox("[!]#FFFFFF Lütfen lideri açmak için bir üye seçin.", 255, 0, 0, true)
		end
	end
end

function closePhone(button, state)
	if wPhone then
		destroyElement(wPhone)
		wPhone = nil
	end
end

function setPhoneNumber(button, state)
	local text = guiGetText(tPhone)
	local num = tonumber(text)

	if text == "" then
		guiGridListSetItemText(gMemberGrid, guiGridListGetSelectedItem(gMemberGrid), colPhone, "", false, false)
	elseif #text and num then
		guiGridListSetItemText(
			gMemberGrid,
			guiGridListGetSelectedItem(gMemberGrid),
			colPhone,
			tostring(tmpPhone) .. "-" .. ("%02d"):format(num),
			false,
			true
		)
	else
		return "Geçersiz biçim."
	end
	local playerName = guiGridListGetItemText(gMemberGrid, guiGridListGetSelectedItem(gMemberGrid), 1):gsub(" ", "_")

	triggerServerEvent("faction.setPhone", localPlayer, playerName, num, faction_tab)
	closePhone(button, state)
end

function numberIsUnused(number)
	local testText = tostring(tmpPhone) .. "-" .. ("%02d"):format(number)
	for i = 0, guiGridListGetRowCount(gMemberGrid) do
		if
			guiGridListGetItemText(gMemberGrid, i, colPhone) == testText
			and i ~= guiGridListGetSelectedItem(gMemberGrid)
		then
			return false
		end
	end
	return true
end

function btPromotePlayer(button, state)
	if (button == "left") and (state == "up") and (source == gButtonPromote) then
		local rfunction
		btPromotePlayer()
		local row = guiGridListGetSelectedItem(gMemberGrid)
		local playerName =
			string.gsub(guiGridListGetItemText(gMemberGrid, guiGridListGetSelectedItem(gMemberGrid), 1), " ", "_")
		local currentRank = guiGridListGetItemText(gMemberGrid, row, 2)
		if playerName == "" then
			outputChatBox("[!]#FFFFFF Rütbesini değiştirmek istediğiniz oyuncuyu önce seçin.", 255, 0, 0, true)
			return
		end
		triggerServerEvent("faction.showChangeRankGUI", resourceRoot, playerName, faction_tab)
	end
end

function setPromotionRanks(rankTbl, rankName, playerName)
	local row = guiGridListGetSelectedItem(gMemberGrid)
	local playerName =
		string.gsub(guiGridListGetItemText(gMemberGrid, guiGridListGetSelectedItem(gMemberGrid), 1), " ", "_")
	local currentRank = guiGridListGetItemText(gMemberGrid, row, 2)
	if playerName ~= "" then
		local currRankNumber = tonumber(guiGridListGetItemData(gMemberGrid, row, colRank))
		local sX, sY = guiGetScreenSize()
		local wX, wY = 210, 316
		local sX, sY, wX, wY = (sX / 2) - (wX / 2), (sY / 2) - (wY / 2), wX, wY

		wPromotions = guiCreateWindow(sX, sY, wX, wY, "Birlik Rütbesini Değiştir", false)
		guiWindowSetSizable(wPromotions, false)

		lPromotions1 = guiCreateLabel(14, 26, 150, 15, "Seçili Üye:", false, wPromotions)
		lPromotions2 = guiCreateLabel(13, 45, 182, 15, playerName, false, wPromotions)
		guiLabelSetHorizontalAlign(lPromotions2, "center", false)
		lPromotions3 = guiCreateLabel(14, 65, 89, 15, "Seçili Rütbe:", false, wPromotions)
		lPromotions4 = guiCreateLabel(13, 85, 182, 15, currentRank, false, wPromotions)
		guiLabelSetHorizontalAlign(lPromotions4, "center", false)

		promotionsGridlist = guiCreateGridList(9, 105, 192, 168, false, wPromotions)
		guiGridListAddColumn(promotionsGridlist, "Rütbe Listesi", 0.9)

		bPromotionsUpdate = guiCreateButton(9, 280, 93, 27, "Güncelle", false, wPromotions)
		bPromotionsCancel = guiCreateButton(112, 280, 89, 27, "İptal", false, wPromotions)
		for i, rank in ipairs(rankTbl) do
			local row = guiGridListAddRow(promotionsGridlist)
			guiGridListSetItemText(promotionsGridlist, row, 1, rank[2], false, false)
		end

		addEventHandler("onClientGUIClick", bPromotionsUpdate, saveNewRank, false)
		addEventHandler("onClientGUIClick", bPromotionsCancel, function()
			destroyElement(wPromotions)
		end, false)
	else
		outputChatBox("[!]#FFFFFF Lütfen terfi ettirilecek/düşürülecek bir üye seçin.", 255, 0, 0, true)
	end
end
addEvent("faction.showChangeRankGUI", true)
addEventHandler("faction.showChangeRankGUI", root, setPromotionRanks)

function saveNewRank()
	local playerName = guiGetText(lPromotions2)
	local oldRank = guiGetText(lPromotions4)

	local row = guiGridListGetSelectedItem(promotionsGridlist)
	if not row or row == -1 then
		outputChatBox("[!]#FFFFFF Bu oyuncunun rütbesini ayarlamak istediğiniz rütbeyi seçin.", 255, 0, 0, true)
		return
	end

	local newRank = guiGridListGetItemText(promotionsGridlist, row, 1)
	triggerServerEvent("faction.saveNewRank", resourceRoot, playerName, oldRank, newRank, faction_tab)
	hideFactionMenu()
	destroyElement(wPromotions)
end

function reselectItem(grid, row, col)
	guiGridListSetSelectedItem(grid, row, col)
end

function loadFaction(tab)
	if wInvite then
		destroyElement(wInvite)
		wInvite, tInvite, lNameCheck, bInvite, bInviteClose, invitedPlayer = nil, nil, nil, nil, nil, nil
	end

	if wPhone then
		destroyElement(wPhone)
		wPhone = nil
	end

	if wMOTD then
		destroyElement(wMOTD)
		wMOTD, tMOTD, bUpdate, bMOTDClose = nil, nil, nil, nil
	end

	if isElement(wRanks) then
		destroyElement(wRanks)
		lRanks, tRanks, tRankWages, wRanks, bRanksSave, bRanksClose = nil, nil, nil, nil, nil, nil
	end

	local t = getElementData(resourceRoot, "duty_gui") or {}
	if t[localPlayer] then
		t[localPlayer] = nil
		setElementData(resourceRoot, "duty_gui", t)
	end

	if isElement(DutyCreate.window[1]) then
		destroyElement(DutyCreate.window[1])
	end

	if isElement(DutyLocations.window[1]) then
		destroyElement(DutyLocations.window[1])
	end

	if isElement(DutySkins.window[1]) then
		destroyElement(DutySkins.window[1])
	end

	if isElement(DutyLocationMaker.window[1]) then
		destroyElement(DutyLocationMaker.window[1])
	end

	if isElement(DutyVehicleAdd.window[1]) then
		destroyElement(DutyVehicleAdd.window[1])
	end

	if isElement(promotionWindow[1]) then
		destroyElement(promotionWindow[1])
	end

	if tabs then
		destroyElement(tabs)
	end

	tabs = guiCreateTabPanel(0.008, 0.01, 0.985, 0.97, true, tab)
	tabOverview = guiCreateTab("Genel Bakış", tabs)

	gMemberGrid = guiCreateGridList(0.01, 0.015, 0.8, 0.905, true, tabOverview)
	colName = guiGridListAddColumn(gMemberGrid, "İsim", 0.20)
	colRank = guiGridListAddColumn(gMemberGrid, "Rütbe", 0.20)
	colOnline = guiGridListAddColumn(gMemberGrid, "Durum", 0.115)
	colLastLogin = guiGridListAddColumn(gMemberGrid, "Son Giriş", 0.13)

	gButtonQuit = guiCreateButton(0.825, 0.7834, 0.16, 0.06, "Birlikten Ayrıl", true, tabOverview)
	gButtonExit = guiCreateButton(0.825, 0.86, 0.16, 0.06, "Arayüzü Kapat", true, tabOverview)
	addEventHandler("onClientGUIClick", gButtonQuit, btQuitFaction, false)
	addEventHandler("onClientGUIClick", gButtonExit, hideFactionMenu, false)

	triggerServerEvent("faction.loadFaction", resourceRoot, getElementData(tab, "factionID"))
	faction_tab = getElementData(tab, "factionID")
	guiSetText(tab, "Yükleniyor...")
end

function fillFactionMenu(
	motd,
	memberUsernames,
	memberRanks,
	memberPerks,
	memberLeaders,
	memberOnline,
	memberLastLogin,
	factionRanks,
	factionWages,
	factionTheTeam,
	note,
	fnote,
	vehicleIDs,
	vehicleModels,
	vehiclePlates,
	vehicleLocations,
	memberOnDuty,
	phone,
	membersPhone,
	fromShowF,
	factionID,
	properties,
	factionRankID,
	rankOrder
)
	if faction_tab ~= factionID or not isElement(tabs) then
		return
	end

	invitedPlayer = nil
	arrUsernames = memberUsernames
	arrRanks = memberRanks
	arrLeaders = memberLeaders
	arrPerks = memberPerks
	arrOnline = memberOnline
	arrLastLogin = memberLastLogin
	arrFactionRanks = factionRanks
	arrFactionWages = factionWages

	if motd == nil then
		motd = ""
	end
	theMotd = motd
	tmpPhone = phone
	local thePlayer = localPlayer
	theTeam = factionTheTeam
	local teamName = getTeamName(theTeam)
	local playerName = getPlayerName(thePlayer)

	local factionType = tonumber(getElementData(theTeam, "type"))
	if
		(factionType == 2)
		or (factionType == 3)
		or (factionType == 4)
		or (factionType == 5)
		or (factionType == 6)
		or (factionType == 7)
	then
		colWage = guiGridListAddColumn(gMemberGrid, "Maaş (₺)", 0.06)
	end

	if phone then
		colPhone = guiGridListAddColumn(gMemberGrid, "Telefon No.", 0.08)
	end

	local factionPackages = exports.mek_duty:getFactionPackages(factionID)
	if factionPackages and factionType >= 2 then
		colDuty = guiGridListAddColumn(gMemberGrid, "Görev", 0.06)
	end

	local localPlayerIsLeader = nil
	local counterOnline, counterOffline = 0, 0
	for k, v in ipairs(rankOrder) do
		local rID = tonumber(v)
		for x, y in pairs(memberRanks) do
			local y = tonumber(y)
			if rID == y then
				local row = guiGridListAddRow(gMemberGrid)
				guiGridListSetItemText(
					gMemberGrid,
					row,
					colName,
					string.gsub(tostring(memberUsernames[x]), "_", " "),
					false,
					false
				)

				local theRank = tonumber(rID)
				local rankName = factionRanks[theRank]
				guiGridListSetItemText(gMemberGrid, row, colRank, tostring(rankName), false, false)
				guiGridListSetItemData(gMemberGrid, row, colRank, tostring(theRank))

				local login = "Asla"
				if not memberLastLogin[x] then
					login = "Asla"
				else
					if memberLastLogin[x] == 0 then
						login = "Bugün"
					else
						login = tostring(memberLastLogin[x]) .. " gün önce"
					end
				end
				guiGridListSetItemText(gMemberGrid, row, colLastLogin, login, false, false)

				if
					(factionType == 2)
					or (factionType == 3)
					or (factionType == 4)
					or (factionType == 5)
					or (factionType == 6)
					or (factionType == 7)
				then
					local rankWage = factionWages[theRank] or 0
					guiGridListSetItemText(gMemberGrid, row, colWage, tostring(rankWage), false, true)
				end

				if memberOnline[x] then
					guiGridListSetItemText(gMemberGrid, row, colOnline, "Çevrimiçi", false, false)
					guiGridListSetItemColor(gMemberGrid, row, colOnline, 0, 255, 0)
					counterOnline = counterOnline + 1
				else
					guiGridListSetItemText(gMemberGrid, row, colOnline, "Çevrimdışı", false, false)
					guiGridListSetItemColor(gMemberGrid, row, colOnline, 255, 0, 0)
					counterOffline = counterOffline + 1
				end

				if tostring(memberUsernames[x]) == playerName then
					localPlayerIsLeader = memberLeaders[x]
				elseif fromShowF then
					localPlayerIsLeader = fromShowF
				end

				if colDuty then
					if memberOnDuty[x] then
						guiGridListSetItemText(gMemberGrid, row, colDuty, "Görevde", false, false)
						guiGridListSetItemColor(gMemberGrid, row, colDuty, 0, 255, 0)
					else
						guiGridListSetItemText(gMemberGrid, row, colDuty, "Görev Dışı", false, false)
						guiGridListSetItemColor(gMemberGrid, row, colDuty, 255, 0, 0)
					end
				end

				if phone and colPhone then
					if membersPhone[x] then
						guiGridListSetItemText(
							gMemberGrid,
							row,
							colPhone,
							tostring(phone) .. "-" .. tostring(membersPhone[x]),
							false,
							true
						)
					else
						guiGridListSetItemText(gMemberGrid, row, colPhone, "", false, true)
					end
				end
			end
		end
	end
	membersOnline = counterOnline
	membersOffline = counterOffline

	guiSetText(
		ftab[factionID],
		"#" .. factionID .. " - "
			.. tostring(teamName)
			.. " ("
			.. (counterOnline + counterOffline)
			.. " Üyeden "
			.. counterOnline
			.. "'i Çevrimiçi)"
	)

	if hasMemberPermissionTo(localPlayer, factionID, "del_member") then
		gButtonKick = guiCreateButton(0.825, 0.076, 0.16, 0.06, "Birlikten At", true, tabOverview)
		addEventHandler("onClientGUIClick", gButtonKick, btKickPlayer, false)
	end

	if hasMemberPermissionTo(localPlayer, factionID, "change_member_rank") then
		gButtonPromote = guiCreateButton(0.825, 0.1526, 0.16, 0.06, "Rütbesini Düzenle", true, tabOverview)
		addEventHandler("onClientGUIClick", gButtonPromote, btPromotePlayer, false)
	end

	if
		(factionType == 2)
		or (factionType == 3)
		or (factionType == 4)
		or (factionType == 5)
		or (factionType == 6)
		or (factionType == 7)
	then
		if hasMemberPermissionTo(localPlayer, factionID, "modify_ranks") then
			gButtonEditRanks =
				guiCreateButton(0.825, 0.2292, 0.16, 0.06, "Rütbeleri ve Maaşları Düzenle", true, tabOverview)
			addEventHandler("onClientGUIClick", gButtonEditRanks, btEditRanks, false)
		end
	else
		if hasMemberPermissionTo(localPlayer, factionID, "modify_ranks") then
			gButtonEditRanks = guiCreateButton(0.825, 0.2292, 0.16, 0.06, "Rütbeleri Düzenle", true, tabOverview)
			addEventHandler("onClientGUIClick", gButtonEditRanks, btEditRanks, false)
		end
	end

	if hasMemberPermissionTo(localPlayer, factionID, "edit_motd") then
		gButtonEditMOTD = guiCreateButton(0.825, 0.3058, 0.16, 0.06, "MOTD'yi Düzenle", true, tabOverview)
		addEventHandler("onClientGUIClick", gButtonEditMOTD, btEditMOTD, false)
	end

	if hasMemberPermissionTo(localPlayer, factionID, "add_member") then
		gButtonInvite = guiCreateButton(0.825, 0.3824, 0.16, 0.06, "Üye Davet Et", true, tabOverview)
		addEventHandler("onClientGUIClick", gButtonInvite, btInvitePlayer, false)
	end

	local _y = 0.5356
	if phone then
		gAssignPhone = guiCreateButton(0.825, _y, 0.16, 0.06, "Telefon No.", true, tabOverview)
		addEventHandler("onClientGUIClick", gAssignPhone, btPhoneNumber, false)
		_y = _y + 0.0766
	end

	if factionType >= 2 then
		if hasMemberPermissionTo(localPlayer, factionID, "set_member_duty") then
			gButtonPerk = guiCreateButton(0.825, _y, 0.16, 0.06, "Görev Yetkilerini Düzenle", true, tabOverview)
			addEventHandler("onClientGUIClick", gButtonPerk, btButtonPerk, false)
		end
	end
	if hasMemberPermissionTo(localPlayer, factionID, "respawn_vehs") then
		gButtonRespawnui = guiCreateButton(0.825, 0.459, 0.16, 0.06, "Araçları Yenile", true, tabOverview)
		addEventHandler("onClientGUIClick", gButtonRespawnui, showrespawn, false)

		tabVehicles = guiCreateTab("(Lider) Araçlar", tabs)

		gVehicleGrid = guiCreateGridList(0.01, 0.015, 0.8, 0.905, true, tabVehicles)

		colVehID = guiGridListAddColumn(gVehicleGrid, "ID", 0.1)
		colVehModel = guiGridListAddColumn(gVehicleGrid, "Model", 0.30)
		colVehPlates = guiGridListAddColumn(gVehicleGrid, "Plaka", 0.1)
		colVehLocation = guiGridListAddColumn(gVehicleGrid, "Konum", 0.4)
		gButtonVehRespawn = guiCreateButton(0.825, 0.076, 0.16, 0.06, "Aracı Yenile", true, tabVehicles)
		gButtonAllVehRespawn = guiCreateButton(0.825, 0.1526, 0.16, 0.06, "Araçları Yenile", true, tabVehicles)

		for index, vehID in ipairs(vehicleIDs) do
			local row = guiGridListAddRow(gVehicleGrid)
			guiGridListSetItemText(gVehicleGrid, row, colVehID, tostring(vehID), false, true)
			guiGridListSetItemText(gVehicleGrid, row, colVehModel, tostring(vehicleModels[index]), false, false)
			guiGridListSetItemText(gVehicleGrid, row, colVehPlates, tostring(vehiclePlates[index]), false, false)
			guiGridListSetItemText(gVehicleGrid, row, colVehLocation, tostring(vehicleLocations[index]), false, false)
		end
		addEventHandler("onClientGUIClick", gButtonVehRespawn, btRespawnOneVehicle, false)
		addEventHandler("onClientGUIClick", gButtonAllVehRespawn, showrespawn, false)
	end

	if hasMemberPermissionTo(localPlayer, factionID, "manage_interiors") then
		tabProperties = guiCreateTab("(Lider) Mülkler", tabs)

		gPropertyGrid = guiCreateGridList(0.01, 0.015, 0.8, 0.905, true, tabProperties)

		colProID = guiGridListAddColumn(gPropertyGrid, "ID", 0.1)
		colName = guiGridListAddColumn(gPropertyGrid, "İsim", 0.30)
		colProLocation = guiGridListAddColumn(gPropertyGrid, "Konum", 0.4)

		for index, int in ipairs(properties) do
			local row = guiGridListAddRow(gPropertyGrid)
			guiGridListSetItemText(gPropertyGrid, row, colProID, tostring(int[1]), false, true)
			guiGridListSetItemText(gPropertyGrid, row, colName, tostring(int[2]), false, false)
			guiGridListSetItemText(gPropertyGrid, row, colProLocation, tostring(int[3]), false, false)
		end
	end

	if hasMemberPermissionTo(localPlayer, factionID, "modify_factionl_note") then
		tabNote = guiCreateTab("(Lider) Not", tabs)
		eNote = guiCreateMemo(0.01, 0.02, 0.98, 0.87, note or "", true, tabNote)
		gButtonSaveNote = guiCreateButton(0.79, 0.90, 0.2, 0.08, "Kaydet", true, tabNote)
		addEventHandler("onClientGUIClick", gButtonSaveNote, btUpdateNote, false)
	end

	if hasMemberPermissionTo(localPlayer, factionID, "modify_faction_note") then
		tabFNote = guiCreateTab("Not", tabs)
		fNote = guiCreateMemo(0.01, 0.02, 0.98, 0.87, fnote or "", true, tabFNote)
		guiMemoSetReadOnly(fNote, false)

		gButtonSaveFNote = guiCreateButton(0.79, 0.90, 0.2, 0.08, "Kaydet", true, tabFNote)
		addEventHandler("onClientGUIClick", gButtonSaveFNote, btUpdateFNote, false)
	else
		tabFNote = guiCreateTab("Not", tabs)
		fNote = guiCreateMemo(0.01, 0.02, 0.98, 0.87, fnote or "", true, tabFNote)
		guiMemoSetReadOnly(fNote, true)
	end

	if factionType >= 2 then
		if hasMemberPermissionTo(localPlayer, factionID, "modify_duty_settings") then
			tabDuty = guiCreateTab("(Lider) Görev Ayarları", tabs)
			addEventHandler("onClientGUITabSwitched", tabDuty, createDutyMain)
		end
	end

	gMOTDLabel = guiCreateLabel(0.015, 0.935, 0.95, 0.15, tostring(motd), true, tabOverview)
	guiSetFont(gMOTDLabel, "default-bold-small")
	guiSetEnabled(gButtonQuit, isPlayerInFaction(localPlayer, factionID))
end
addEvent("faction.fillFactionMenu", true)
addEventHandler("faction.fillFactionMenu", resourceRoot, fillFactionMenu)

function hideFactionMenu()
	showCursor(false)
	guiSetInputEnabled(false)

	if gFactionWindow then
		destroyElement(gFactionWindow)
	end

	gFactionWindow, gMemberGrid = nil
	triggerServerEvent("faction.hide", localPlayer)

	if wInvite then
		destroyElement(wInvite)
		wInvite, tInvite, lNameCheck, bInvite, bInviteClose, invitedPlayer = nil, nil, nil, nil, nil, nil
	end

	if wPhone then
		destroyElement(wPhone)
		wPhone = nil
	end

	if wMOTD then
		destroyElement(wMOTD)
		wMOTD, tMOTD, bUpdate, bMOTDClose = nil, nil, nil, nil
	end

	if isElement(wRanks) then
		destroyElement(wRanks)
		lRanks, tRanks, tRankWages, wRanks, bRanksSave, bRanksClose = nil, nil, nil, nil, nil, nil
	end

	local t = getElementData(resourceRoot, "duty_gui") or {}
	if t[localPlayer] then
		t[localPlayer] = nil
		setElementData(resourceRoot, "duty_gui", t)
	end

	if isElement(DutyCreate.window[1]) then
		destroyElement(DutyCreate.window[1])
	end

	if isElement(DutyLocations.window[1]) then
		destroyElement(DutyLocations.window[1])
	end

	if isElement(DutySkins.window[1]) then
		destroyElement(DutySkins.window[1])
	end

	if isElement(DutyLocationMaker.window[1]) then
		destroyElement(DutyLocationMaker.window[1])
	end

	if isElement(DutyVehicleAdd.window[1]) then
		destroyElement(DutyVehicleAdd.window[1])
	end

	if isElement(promotionWindow[1]) then
		destroyElement(promotionWindow[1])
	end

	gFactionWindow, gMemberGrid, gMOTDLabel, colName, colRank, colWage, colLastLogin, colOnline, gButtonKick, gButtonPromote, gButtonDemote, gButtonEditRanks, gButtonEditMOTD, gButtonInvite, gButtonLeader, gButtonQuit, gButtonExit =
		nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
	theMotd, theTeam, arrUsernames, arrRanks, arrLeaders, arrOnline, arrFactionRanks, arrFactionWages, arrLastLogin, membersOnline, membersOffline =
		nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
	removeEventHandler("onClientRender", root, checkF3)
end
addEvent("hideFactionMenu", true)
addEventHandler("hideFactionMenu", root, hideFactionMenu)

function resourceStopped()
	showCursor(false)
	guiSetInputEnabled(false)

	setElementData(localPlayer, "savedLocations", false)
	setElementData(localPlayer, "savedSkins", false)
end
addEventHandler("onClientResourceStop", resourceRoot, resourceStopped)

function btRespawnVehicles(button, state)
	if button == "left" then
		if source == gButtonRespawn then
			hideFactionMenu()
			destroyElement(showrespawnUI)
			triggerServerEvent("cguiRespawnVehicles", localPlayer, faction_tab)
		elseif source == gButtonNo then
			hideFactionMenu()
			destroyElement(showrespawnUI)
		end
	end
end

Duty = {
	gridlist = {},
	button = {},
	label = {},
}

customEditID = 0
locationEditID = 0

function beginLoad()
	guiGridListAddRow(Duty.gridlist[1])
	guiGridListSetItemText(Duty.gridlist[1], 0, 2, "Yükleniyor", false, false)

	guiGridListAddRow(Duty.gridlist[2])
	guiGridListSetItemText(Duty.gridlist[2], 0, 1, "Yükleniyor", false, false)

	guiGridListAddRow(Duty.gridlist[3])
	guiGridListSetItemText(Duty.gridlist[3], 0, 1, "Yükleniyor", false, false)

	triggerServerEvent("fetchDutyInfo", resourceRoot, faction_tab)
end

function importData(custom, locations, factionID, message)
	if not isElement(gFactionWindow) then
		return
	end

	custom = custom or {}
	locations = locations or {}

	customg = custom
	locationsg = locations
	factionIDg = factionID
	forceDutyClose = true
	forceLocationClose = true

	if locationEditID == 0 then
		forceLocationClose = false
	end

	if customEditID == 0 then
		forceDutyClose = false
	end

	guiGridListClear(Duty.gridlist[1])
	guiGridListClear(Duty.gridlist[2])
	guiGridListClear(Duty.gridlist[3])

	for k, v in pairs(custom) do
		local row = guiGridListAddRow(Duty.gridlist[2])

		guiGridListSetItemText(Duty.gridlist[2], row, 1, tostring(v[1]), false, true)
		guiGridListSetItemText(Duty.gridlist[2], row, 2, v[2], false, false)
		t = {}
		for key, val in pairs(v[4]) do
			table.insert(t, key)
		end
		guiGridListSetItemText(Duty.gridlist[2], row, 3, table.concat(t, ", "), false, false)
		if customEditID == tonumber(v[1]) then
			forceDutyClose = false
		end
	end

	for k, v in pairs(locations) do
		if not v[10] then
			local row = guiGridListAddRow(Duty.gridlist[1])

			guiGridListSetItemText(Duty.gridlist[1], row, 1, tostring(v[1]), false, true)
			guiGridListSetItemText(Duty.gridlist[1], row, 2, tostring(v[2]), false, false)
			guiGridListSetItemText(Duty.gridlist[1], row, 3, tostring(v[6]), false, false)
			guiGridListSetItemText(Duty.gridlist[1], row, 4, tostring(v[8]), false, false)
			guiGridListSetItemText(Duty.gridlist[1], row, 5, tostring(v[7]), false, false)
			guiGridListSetItemText(Duty.gridlist[1], row, 6, tostring(v[3]), false, false)
			guiGridListSetItemText(Duty.gridlist[1], row, 7, tostring(v[4]), false, false)
			guiGridListSetItemText(Duty.gridlist[1], row, 8, tostring(v[5]), false, false)
		else
			local row = guiGridListAddRow(Duty.gridlist[3])

			guiGridListSetItemText(Duty.gridlist[3], row, 1, tostring(v[1]), false, true)
			guiGridListSetItemText(Duty.gridlist[3], row, 2, tostring(v[9]), false, true)
			guiGridListSetItemText(Duty.gridlist[3], row, 3, getVehicleNameFromModel(v[10]), false, false)
		end

		if locationEditID == tonumber(v[1]) then
			forceLocationClose = false
		end
	end

	if forceLocationClose or forceDutyClose then
		outputChatBox("[!]#FFFFFF" .. message, 255, 0, 0, true)

		if forceDutyClose then
			if DutyCreate.window[1] then
				destroyElement(DutyCreate.window[1])
			end
			if DutyLocations.window[1] then
				destroyElement(DutyLocations.window[1])
			end
			if DutySkins.window[1] then
				destroyElement(DutySkins.window[1])
			end
		end

		if forceLocationClose then
			if DutyLocationMaker.window[1] then
				destroyElement(DutyLocationMaker.window[1])
			end
		end
	end
end
addEvent("importDutyData", true)
addEventHandler("importDutyData", resourceRoot, importData)

function refreshUI()
	guiGridListClear(Duty.gridlist[1])
	guiGridListClear(Duty.gridlist[2])
	guiGridListClear(Duty.gridlist[3])

	for k, v in pairs(customg) do
		local row = guiGridListAddRow(Duty.gridlist[2])

		guiGridListSetItemText(Duty.gridlist[2], row, 1, tostring(v[1]), false, true)
		guiGridListSetItemText(Duty.gridlist[2], row, 2, v[2], false, false)
		t = {}
		for key, val in pairs(v[4]) do
			table.insert(t, key)
		end
		guiGridListSetItemText(Duty.gridlist[2], row, 3, table.concat(t, ", "), false, false)
	end

	for k, v in pairs(locationsg) do
		if not v[10] then
			local row = guiGridListAddRow(Duty.gridlist[1])

			guiGridListSetItemText(Duty.gridlist[1], row, 1, tostring(v[1]), false, true)
			guiGridListSetItemText(Duty.gridlist[1], row, 2, v[2], false, false)
			guiGridListSetItemText(Duty.gridlist[1], row, 3, v[6], false, false)
			guiGridListSetItemText(Duty.gridlist[1], row, 4, v[8], false, false)
			guiGridListSetItemText(Duty.gridlist[1], row, 5, v[7], false, false)
			guiGridListSetItemText(Duty.gridlist[1], row, 6, v[3], false, false)
			guiGridListSetItemText(Duty.gridlist[1], row, 7, v[4], false, false)
			guiGridListSetItemText(Duty.gridlist[1], row, 8, v[5], false, false)
		else
			local row = guiGridListAddRow(Duty.gridlist[3])

			guiGridListSetItemText(Duty.gridlist[3], row, 1, tostring(v[1]), false, true)
			guiGridListSetItemText(Duty.gridlist[3], row, 2, tostring(v[9]), false, true)
			guiGridListSetItemText(Duty.gridlist[3], row, 3, getVehicleNameFromModel(v[10]), false, false)
		end
	end
end

function processLocationEdit()
	local r, c = guiGridListGetSelectedItem(Duty.gridlist[1])
	if r >= 0 then
		local x = guiGridListGetItemText(Duty.gridlist[1], r, 6)
		local y = guiGridListGetItemText(Duty.gridlist[1], r, 7)
		local z = guiGridListGetItemText(Duty.gridlist[1], r, 8)
		local rot = guiGridListGetItemText(Duty.gridlist[1], r, 3)
		local i = guiGridListGetItemText(Duty.gridlist[1], r, 4)
		local d = guiGridListGetItemText(Duty.gridlist[1], r, 5)
		local name = guiGridListGetItemText(Duty.gridlist[1], r, 2)
		locationEditID = tonumber(guiGridListGetItemText(Duty.gridlist[1], r, 1))
		createDutyLocationMaker(x, y, z, rot, i, d, name)
	end
end

function processDutyEdit()
	local r, c = guiGridListGetSelectedItem(Duty.gridlist[2])
	if r >= 0 then
		local id = guiGridListGetItemText(Duty.gridlist[2], r, 1)
		customEditID = tonumber(id)
		createDuty()
	end
end

function createDutyMain()
	if isElement(Duty.gridlist[1]) then
		beginLoad()
		return
	end

	Duty.gridlist[1] = guiCreateGridList(0.0047, 0.046, 0.3, 0.89, true, tabDuty)
	guiGridListAddColumn(Duty.gridlist[1], "ID", 0.1)
	guiGridListAddColumn(Duty.gridlist[1], "İsim", 0.2)
	guiGridListAddColumn(Duty.gridlist[1], "Radius", 0.1)
	guiGridListAddColumn(Duty.gridlist[1], "Interior", 0.1)
	guiGridListAddColumn(Duty.gridlist[1], "Dimension", 0.12)
	guiGridListAddColumn(Duty.gridlist[1], "X", 0.1)
	guiGridListAddColumn(Duty.gridlist[1], "Y", 0.1)
	guiGridListAddColumn(Duty.gridlist[1], "Z", 0.1)

	Duty.button[1] = guiCreateButton(0.005, 0.939, 0.09, 0.0504, "Konum Ekle", true, tabDuty)
	guiSetProperty(Duty.button[1], "NormalTextColour", "FFAAAAAA")
	addEventHandler("onClientGUIClick", Duty.button[1], createDutyLocationMaker, false)

	Duty.label[1] = guiCreateLabel(0.0059, 0.0076, 0.2625, 0.03, "Görev Yerleri", true, tabDuty)
	guiLabelSetHorizontalAlign(Duty.label[1], "center", false)
	Duty.button[2] = guiCreateButton(0.1, 0.939, 0.099, 0.0504, "Konumu Kaldır", true, tabDuty)
	guiSetProperty(Duty.button[2], "NormalTextColour", "FFAAAAAA")
	addEventHandler("onClientGUIClick", Duty.button[2], removeLocation, false)

	Duty.button[3] = guiCreateButton(0.205, 0.939, 0.099, 0.0504, "Görev Yerini Düzenle", true, tabDuty)
	guiSetProperty(Duty.button[3], "NormalTextColour", "FFAAAAAA")
	addEventHandler("onClientGUIClick", Duty.button[3], processLocationEdit, false)
	addEventHandler("onClientGUIDoubleClick", Duty.gridlist[1], processLocationEdit, false)

	Duty.gridlist[2] = guiCreateGridList(0.66, 0.046, 0.3, 0.89, true, tabDuty)
	guiGridListAddColumn(Duty.gridlist[2], "ID", 0.2)
	guiGridListAddColumn(Duty.gridlist[2], "İsim", 0.3)
	guiGridListAddColumn(Duty.gridlist[2], "Konumlar", 0.4)

	Duty.label[2] = guiCreateLabel(0.68, 0.0076, 0.2636, 0.03, "Görev Avantajları", true, tabDuty)
	guiLabelSetHorizontalAlign(Duty.label[2], "center", false)
	Duty.button[4] = guiCreateButton(0.66, 0.939, 0.09, 0.0504, "Yeni Görev Ekle", true, tabDuty)
	guiSetProperty(Duty.button[4], "NormalTextColour", "FFAAAAAA")
	addEventHandler("onClientGUIClick", Duty.button[4], createDuty, false)

	Duty.button[5] = guiCreateButton(0.765, 0.939, 0.09, 0.0504, "Görevi Kaldır", true, tabDuty)
	guiSetProperty(Duty.button[5], "NormalTextColour", "FFAAAAAA")
	addEventHandler("onClientGUIClick", Duty.button[5], removeDuty, false)

	Duty.button[6] = guiCreateButton(0.869, 0.939, 0.09, 0.0504, "Görev Avantajlarını Düzenle", true, tabDuty)
	guiSetProperty(Duty.button[6], "NormalTextColour", "FFAAAAAA")
	addEventHandler("onClientGUIClick", Duty.button[6], processDutyEdit, false)
	addEventHandler("onClientGUIDoubleClick", Duty.gridlist[2], processDutyEdit, false)

	Duty.gridlist[3] = guiCreateGridList(0.3355, 0.046, 0.282, 0.472, true, tabDuty)
	guiGridListAddColumn(Duty.gridlist[3], "ID", 0.1)
	guiGridListAddColumn(Duty.gridlist[3], "Araç ID", 0.4)
	guiGridListAddColumn(Duty.gridlist[3], "Araç", 0.5)

	Duty.label[3] = guiCreateLabel(0.325, 0.0076, 0.2886, 0.03, "Görev Araçlarının Konumları", true, tabDuty)
	guiLabelSetHorizontalAlign(Duty.label[3], "center", false)
	Duty.button[8] = guiCreateButton(0.3355, 0.5304, 0.1, 0.0504, "Görev Aracı Ekle", true, tabDuty)
	guiSetProperty(Duty.button[8], "NormalTextColour", "FFAAAAAA")
	addEventHandler("onClientGUIClick", Duty.button[8], createVehicleAdd, false)

	Duty.button[9] = guiCreateButton(0.5177, 0.5304, 0.1, 0.0504, "Görev Aracını Kaldır", true, tabDuty)
	guiSetProperty(Duty.button[9], "NormalTextColour", "FFAAAAAA")
	addEventHandler("onClientGUIClick", Duty.button[9], removeVehicle, false)

	beginLoad()
end

DutyCreate = {
	label = {},
	button = {},
	window = {},
	gridlist = {},
	edit = {},
}

function grabDetails(dutyID)
	triggerServerEvent("duty.grab", resourceRoot, faction_tab)

	guiGridListAddRow(DutyCreate.gridlist[1])
	guiGridListSetItemText(DutyCreate.gridlist[1], 0, 2, "Yükleniyor", false, false)

	guiGridListAddRow(DutyCreate.gridlist[2])
	guiGridListSetItemText(DutyCreate.gridlist[2], 0, 2, "Yükleniyor", false, false)

	guiGridListAddRow(DutyCreate.gridlist[3])
	guiGridListSetItemText(DutyCreate.gridlist[3], 0, 1, "Yükleniyor", false, false)

	guiGridListAddRow(DutyCreate.gridlist[4])
	guiGridListSetItemText(DutyCreate.gridlist[4], 0, 1, "Yükleniyor", false, false)
end

function isItemAllowed(id)
	for k, v in pairs(allowListg) do
		if tonumber(id) == tonumber(v[1]) then
			return true
		end
	end
	return false
end

function populateDuty(allowList)
	dutyItems = {}
	allowListg = allowList
	guiGridListClear(DutyCreate.gridlist[1])
	guiGridListClear(DutyCreate.gridlist[2])
	guiGridListClear(DutyCreate.gridlist[3])
	guiGridListClear(DutyCreate.gridlist[4])

	if customEditID ~= 0 then
		dutyItems = customg[customEditID][5]
		for k, v in pairs(customg[customEditID][5]) do
			if tonumber(v[2]) >= 0 then
				local row = guiGridListAddRow(DutyCreate.gridlist[4])

				guiGridListSetItemText(DutyCreate.gridlist[4], row, 1, exports.mek_item:getItemName(v[2]), false, false)
				guiGridListSetItemText(DutyCreate.gridlist[4], row, 2, tostring(v[2]), false, true)
				guiGridListSetItemData(DutyCreate.gridlist[4], row, 1, { v[1], tonumber(v[2]), v[3] })

				if not isItemAllowed(v[1]) then
					guiGridListSetItemColor(DutyCreate.gridlist[4], row, 1, 255, 0, 0)
					guiGridListSetItemColor(DutyCreate.gridlist[4], row, 2, 255, 0, 0)
				end
			else
				local row = guiGridListAddRow(DutyCreate.gridlist[3])
				if tonumber(v[2]) == -100 then
					guiGridListSetItemText(DutyCreate.gridlist[3], row, 1, "Zırh", false, false)
					guiGridListSetItemText(DutyCreate.gridlist[3], row, 2, tostring(v[3]), false, false)
					guiGridListSetItemData(DutyCreate.gridlist[3], row, 2, { v[1], tonumber(v[2]), v[3], v[4] })
				else
					guiGridListSetItemText(
						DutyCreate.gridlist[3],
						row,
						1,
						exports.mek_item:getItemName(v[2]),
						false,
						false
					)
					guiGridListSetItemText(DutyCreate.gridlist[3], row, 2, tostring(v[3]), false, false)
					guiGridListSetItemData(DutyCreate.gridlist[3], row, 2, { v[1], tonumber(v[2]), v[3], v[4] })
				end

				if not isItemAllowed(v[1]) then
					guiGridListSetItemColor(DutyCreate.gridlist[3], row, 1, 255, 0, 0)
					guiGridListSetItemColor(DutyCreate.gridlist[3], row, 2, 255, 0, 0)
				end
			end
		end
		guiSetText(DutyCreate.edit[3], customg[customEditID][2])
	end

	for k, v in pairs(allowList) do
		if tonumber(v[2]) >= 0 then
			if customEditID == 0 or (customEditID ~= 0 and not customg[customEditID][5][tostring(v[1])]) then
				local row = guiGridListAddRow(DutyCreate.gridlist[2])

				guiGridListSetItemText(DutyCreate.gridlist[2], row, 1, exports.mek_item:getItemName(v[2]), false, false)
				guiGridListSetItemText(
					DutyCreate.gridlist[2],
					row,
					2,
					exports.mek_item:getItemDescription(v[2], v[3]),
					false,
					false
				)
				guiGridListSetItemData(DutyCreate.gridlist[2], row, 1, { v[1], tonumber(v[2]), v[3] })
			end
		else
			if customEditID == 0 or (customEditID ~= 0 and not customg[customEditID][5][tostring(v[1])]) then
				local row = guiGridListAddRow(DutyCreate.gridlist[1])
				if tonumber(v[2]) == -100 then
					guiGridListSetItemText(DutyCreate.gridlist[1], row, 1, "Zırh", false, false)
					guiGridListSetItemText(DutyCreate.gridlist[1], row, 2, v[3], false, false)
					guiGridListSetItemData(DutyCreate.gridlist[1], row, 1, { v[1], tonumber(v[2]), v[3] })
				else
					guiGridListSetItemText(
						DutyCreate.gridlist[1],
						row,
						1,
						exports.mek_item:getItemName(v[2]),
						false,
						false
					)
					guiGridListSetItemText(DutyCreate.gridlist[1], row, 2, v[3], false, false)
					guiGridListSetItemData(DutyCreate.gridlist[1], row, 1, { v[1], tonumber(v[2]), v[3] })
				end
			end
		end
	end
end
addEvent("gotAllow", true)
addEventHandler("gotAllow", resourceRoot, populateDuty)

function populateLocations()
	if customEditID == 0 then
		tempLocations = getElementData(localPlayer, "savedLocations") or {}
	else
		tempLocations = getElementData(localPlayer, "savedLocations") or customg[customEditID][4]
	end

	for k, v in pairs(locationsg) do
		if not tempLocations[v[1]] then
			local row = guiGridListAddRow(DutyLocations.gridlist[1])

			guiGridListSetItemText(DutyLocations.gridlist[1], row, 1, tostring(v[1]), false, true)
			guiGridListSetItemText(DutyLocations.gridlist[1], row, 2, tostring(v[2]), false, false)
		end
	end

	for k, v in pairs(tempLocations) do
		local row = guiGridListAddRow(DutyLocations.gridlist[2])

		guiGridListSetItemText(DutyLocations.gridlist[2], row, 1, tostring(k), false, true)
		guiGridListSetItemText(DutyLocations.gridlist[2], row, 2, tostring(v), false, false)
	end
end

function populateSkins()
	if customEditID == 0 then
		dutyNewSkins = getElementData(localPlayer, "savedSkins") or {}
	else
		dutyNewSkins = getElementData(localPlayer, "savedSkins") or customg[customEditID][3]
	end

	for k, v in pairs(dutyNewSkins) do
		local row = guiGridListAddRow(DutySkins.gridlist[1])
		guiGridListSetItemText(DutySkins.gridlist[1], row, 1, tostring(v[1]), false, false)
		guiGridListSetItemText(DutySkins.gridlist[1], row, 2, tostring(v[2]), false, false)
		guiGridListSetItemText(DutySkins.gridlist[1], row, 3, tostring(v[3]), false, false)
	end
end

function checkAmmo()
	local r, c = guiGridListGetSelectedItem(DutyCreate.gridlist[1])
	if r >= 0 then
		if tonumber(guiGetText(DutyCreate.edit[2])) then
			if
				tonumber(guiGridListGetItemText(DutyCreate.gridlist[1], r, 2))
				>= tonumber(guiGetText(DutyCreate.edit[2]))
			then
				guiLabelSetColor(DutyCreate.label[2], 0, 255, 0)
				guiSetText(DutyCreate.label[2], "Geçerli")
				guiSetEnabled(DutyCreate.button[3], true)
				return
			end
		end
	end
	guiLabelSetColor(DutyCreate.label[2], 255, 0, 0)
	guiSetText(DutyCreate.label[2], "Geçersiz")
	guiSetEnabled(DutyCreate.button[3], false)
end

function addDutyItem()
	local r, c = guiGridListGetSelectedItem(DutyCreate.gridlist[2])
	if r >= 0 then
		local info = guiGridListGetItemData(DutyCreate.gridlist[2], r, 1)
		local row = guiGridListAddRow(DutyCreate.gridlist[4])

		guiGridListSetItemText(DutyCreate.gridlist[4], row, 1, exports.mek_item:getItemName(info[2]), false, false)
		guiGridListSetItemText(DutyCreate.gridlist[4], row, 2, tostring(info[2]), false, false)
		guiGridListSetItemData(DutyCreate.gridlist[4], row, 1, info)

		dutyItems[tostring(info[1])] = { info[1], tonumber(info[2]), info[3] }
		guiGridListRemoveRow(DutyCreate.gridlist[2], r)
	end
end

function removeDutyWeapon()
	local r, c = guiGridListGetSelectedItem(DutyCreate.gridlist[3])
	if r >= 0 then
		local info = guiGridListGetItemData(DutyCreate.gridlist[3], r, 2)
		local red, g, b = guiGridListGetItemColor(DutyCreate.gridlist[3], r, 1)
		dutyItems[tostring(info[1])] = nil
		guiGridListRemoveRow(DutyCreate.gridlist[3], r)
		if red == 255 and g ~= 0 and b ~= 0 then
			local row = guiGridListAddRow(DutyCreate.gridlist[1])
			if tonumber(info[1]) == -100 then
				guiGridListSetItemText(DutyCreate.gridlist[1], row, 1, "Zırh", false, false)
				guiGridListSetItemText(DutyCreate.gridlist[1], row, 2, tostring(info[4]), false, false)
				guiGridListSetItemData(DutyCreate.gridlist[1], row, 1, info)
			else
				guiGridListSetItemText(
					DutyCreate.gridlist[1],
					row,
					1,
					exports.mek_item:getItemName(info[2]),
					false,
					false
				)
				guiGridListSetItemText(DutyCreate.gridlist[1], row, 2, tostring(info[4]), false, false)
				guiGridListSetItemData(DutyCreate.gridlist[1], row, 1, info)
			end
		end
	end
end

function removeDutyItem()
	local r, c = guiGridListGetSelectedItem(DutyCreate.gridlist[4])
	if r >= 0 then
		local info = guiGridListGetItemData(DutyCreate.gridlist[4], r, 1)
		local red, g, b = guiGridListGetItemColor(DutyCreate.gridlist[4], r, 1)
		dutyItems[tostring(info[1])] = nil
		guiGridListRemoveRow(DutyCreate.gridlist[4], r)
		if red == 255 and g ~= 0 and b ~= 0 then
			local row = guiGridListAddRow(DutyCreate.gridlist[2])

			guiGridListSetItemText(
				DutyCreate.gridlist[2],
				row,
				1,
				exports.mek_item:getItemName(tonumber(info[2])),
				false,
				false
			)
			guiGridListSetItemText(
				DutyCreate.gridlist[2],
				row,
				2,
				exports.mek_item:getItemDescription(tonumber(info[2]), info[3]),
				false,
				false
			)
			guiGridListSetItemData(DutyCreate.gridlist[2], row, 1, info)
		end
	end
end

function createDuty()
	if isElement(DutyCreate.window[1]) then
		destroyElement(DutyCreate.window[1])
		dutyItems = nil
	end

	DutyCreate.window[1] = guiCreateWindow(450, 310, 768, 566, "Görev Düzenleme Arayüzü - Ana", false)
	guiWindowSetSizable(DutyCreate.window[1], false)
	exports.mek_global:centerWindow(DutyCreate.window[1])

	DutyCreate.button[1] = guiCreateButton(600, 512, 158, 44, "İptal", false, DutyCreate.window[1])
	guiSetProperty(DutyCreate.button[1], "NormalTextColour", "FFAAAAAA")
	addEventHandler("onClientGUIClick", DutyCreate.button[1], closeTheGUI, false)

	DutyCreate.button[2] = guiCreateButton(454, 512, 138, 44, "Kaydet", false, DutyCreate.window[1])
	guiSetProperty(DutyCreate.button[2], "NormalTextColour", "FFAAAAAA")
	addEventHandler("onClientGUIClick", DutyCreate.button[2], saveGUI, false)

	DutyCreate.gridlist[1] = guiCreateGridList(11, 34, 427, 192, false, DutyCreate.window[1])
	guiGridListAddColumn(DutyCreate.gridlist[1], "Silah İsmi", 0.5)
	guiGridListAddColumn(DutyCreate.gridlist[1], "Maksimum Cephane Miktarı", 0.5)

	DutyCreate.gridlist[2] = guiCreateGridList(12, 247, 426, 208, false, DutyCreate.window[1])
	guiGridListAddColumn(DutyCreate.gridlist[2], "Eşya İsmi", 0.3)
	guiGridListAddColumn(DutyCreate.gridlist[2], "Açıklama", 0.7)

	DutyCreate.button[3] = guiCreateButton(444, 34, 128, 41, "-->", false, DutyCreate.window[1])
	guiSetProperty(DutyCreate.button[3], "NormalTextColour", "FFAAAAAA")
	addEventHandler("onClientGUIClick", DutyCreate.gridlist[1], checkAmmo)
	addEventHandler("onClientGUIClick", DutyCreate.button[3], function()
		local r, c = guiGridListGetSelectedItem(DutyCreate.gridlist[1])
		if r >= 0 then
			local maxammo = guiGridListGetItemText(DutyCreate.gridlist[1], r, 2)
			local info = guiGridListGetItemData(DutyCreate.gridlist[1], r, 1)
			local ammo = guiGetText(DutyCreate.edit[2])

			local row = guiGridListAddRow(DutyCreate.gridlist[3])
			if tonumber(info[2]) == -100 then
				guiGridListSetItemText(DutyCreate.gridlist[3], row, 1, "Zırh", false, false)
				guiGridListSetItemData(DutyCreate.gridlist[3], row, 2, info)
				guiGridListSetItemText(DutyCreate.gridlist[3], row, 2, ammo, false, false)
			else
				guiGridListSetItemText(
					DutyCreate.gridlist[3],
					row,
					1,
					exports.mek_item:getItemName(tonumber(info[2])),
					false,
					false
				)
				guiGridListSetItemData(DutyCreate.gridlist[3], row, 2, info)
				guiGridListSetItemText(DutyCreate.gridlist[3], row, 2, ammo, false, false)
			end

			dutyItems[tostring(info[1])] = { info[1], tonumber(info[2]), tonumber(ammo), info[3] }

			guiGridListRemoveRow(DutyCreate.gridlist[1], r)
		end
	end, false)
	DutyCreate.button[4] = guiCreateButton(444, 249, 128, 41, "-->", false, DutyCreate.window[1])
	guiSetProperty(DutyCreate.button[4], "NormalTextColour", "FFAAAAAA")
	addEventHandler("onClientGUIClick", DutyCreate.button[4], addDutyItem, false)
	addEventHandler("onClientGUIDoubleClick", DutyCreate.gridlist[2], addDutyItem, false)

	DutyCreate.gridlist[3] = guiCreateGridList(582, 34, 176, 192, false, DutyCreate.window[1])
	guiGridListAddColumn(DutyCreate.gridlist[3], "Silah", 0.5)
	guiGridListAddColumn(DutyCreate.gridlist[3], "Cephane", 0.3)

	DutyCreate.edit[2] = guiCreateEdit(445, 81, 127, 27, "Cephane Miktarı", false, DutyCreate.window[1])
	DutyCreate.label[2] = guiCreateLabel(444, 108, 128, 77, "Geçersiz", false, DutyCreate.window[1])
	guiLabelSetColor(DutyCreate.label[2], 255, 0, 0)
	addEventHandler("onClientGUIChanged", DutyCreate.edit[2], checkAmmo)

	DutyCreate.gridlist[4] = guiCreateGridList(582, 248, 176, 207, false, DutyCreate.window[1])
	guiGridListAddColumn(DutyCreate.gridlist[4], "Eşya", 0.5)
	guiGridListAddColumn(DutyCreate.gridlist[4], "ID", 0.3)
	guiLabelSetHorizontalAlign(DutyCreate.label[2], "center", false)

	DutyCreate.button[5] = guiCreateButton(444, 185, 128, 41, "<---", false, DutyCreate.window[1])
	guiSetProperty(DutyCreate.button[5], "NormalTextColour", "FFAAAAAA")
	addEventHandler("onClientGUIClick", DutyCreate.button[5], removeDutyWeapon, false)
	addEventHandler("onClientGUIDoubleClick", DutyCreate.gridlist[3], removeDutyWeapon, false)
	DutyCreate.button[6] = guiCreateButton(444, 414, 128, 41, "<--", false, DutyCreate.window[1])
	guiSetProperty(DutyCreate.button[6], "NormalTextColour", "FFAAAAAA")
	addEventHandler("onClientGUIClick", DutyCreate.button[6], removeDutyItem, false)
	addEventHandler("onClientGUIDoubleClick", DutyCreate.gridlist[4], removeDutyItem, false)
	DutyCreate.button[7] = guiCreateButton(12, 511, 138, 45, "Kıyafetler", false, DutyCreate.window[1])
	guiSetProperty(DutyCreate.button[7], "NormalTextColour", "FFAAAAAA")
	addEventHandler("onClientGUIClick", DutyCreate.button[7], function()
		createSkins()
		setTimer(createSkins, 1000, 1)
	end, false)

	DutyCreate.button[8] = guiCreateButton(160, 512, 138, 44, "Konumlar", false, DutyCreate.window[1])
	guiSetProperty(DutyCreate.button[8], "NormalTextColour", "FFAAAAAA")
	addEventHandler("onClientGUIClick", DutyCreate.button[8], createLocations, false)

	DutyCreate.label[3] = guiCreateLabel(57, 19, 319, 15, "Mevcut Silahlar", false, DutyCreate.window[1])
	guiLabelSetHorizontalAlign(DutyCreate.label[3], "center", false)
	DutyCreate.label[4] = guiCreateLabel(582, 17, 176, 17, "Görev Silahları", false, DutyCreate.window[1])
	guiLabelSetHorizontalAlign(DutyCreate.label[4], "center", false)
	DutyCreate.label[5] = guiCreateLabel(57, 228, 319, 15, "Mevcut Eşyalar", false, DutyCreate.window[1])
	guiLabelSetHorizontalAlign(DutyCreate.label[5], "center", false)
	DutyCreate.label[6] = guiCreateLabel(583, 227, 175, 21, "Görev Eşyaları", false, DutyCreate.window[1])
	guiLabelSetHorizontalAlign(DutyCreate.label[6], "center", false)
	DutyCreate.label[7] = guiCreateLabel(14, 463, 88, 32, "Görev İsmi:", false, DutyCreate.window[1])
	guiLabelSetVerticalAlign(DutyCreate.label[7], "center")
	DutyCreate.edit[3] = guiCreateEdit(83, 462, 240, 33, "", false, DutyCreate.window[1])

	guiSetEnabled(DutyCreate.button[3], false)
	grabDetails()
end

DutyLocations = {
	gridlist = {},
	window = {},
	button = {},
	label = {},
}

function addLocationToDuty()
	local r, c = guiGridListGetSelectedItem(DutyLocations.gridlist[1])
	if r >= 0 then
		local id = guiGridListGetItemText(DutyLocations.gridlist[1], r, 1)
		local name = guiGridListGetItemText(DutyLocations.gridlist[1], r, 2)

		guiGridListRemoveRow(DutyLocations.gridlist[1], r)
		local row = guiGridListAddRow(DutyLocations.gridlist[2])

		guiGridListSetItemText(DutyLocations.gridlist[2], row, 1, tostring(id), false, true)
		guiGridListSetItemText(DutyLocations.gridlist[2], row, 2, tostring(name), false, false)
		tempLocations[id] = name
	end
end

function removeLocationFromDuty()
	local r, c = guiGridListGetSelectedItem(DutyLocations.gridlist[2])
	if r >= 0 then
		local id = guiGridListGetItemText(DutyLocations.gridlist[2], r, 1)
		local name = guiGridListGetItemText(DutyLocations.gridlist[2], r, 2)
		guiGridListRemoveRow(DutyLocations.gridlist[2], r)

		local row = guiGridListAddRow(DutyLocations.gridlist[1])
		guiGridListSetItemText(DutyLocations.gridlist[1], row, 1, tostring(id), false, true)
		guiGridListSetItemText(DutyLocations.gridlist[1], row, 2, tostring(name), false, false)
		tempLocations[id] = nil
	end
end

function createLocations()
	if isElement(DutyLocations.window[1]) then
		destroyElement(DutyLocations.window[1])
		tempLocations = nil
	end
	DutyLocations.window[1] = guiCreateWindow(573, 285, 520, 423, "Görev Düzenleme Arayüzü - Konumlar", false)
	guiWindowSetSizable(DutyLocations.window[1], false)
	exports.mek_global:centerWindow(DutyLocations.window[1])

	DutyLocations.gridlist[1] = guiCreateGridList(9, 36, 240, 297, false, DutyLocations.window[1])
	guiGridListAddColumn(DutyLocations.gridlist[1], "ID", 0.2)
	guiGridListAddColumn(DutyLocations.gridlist[1], "İsim", 0.9)

	DutyLocations.gridlist[2] = guiCreateGridList(270, 36, 240, 297, false, DutyLocations.window[1])
	guiGridListAddColumn(DutyLocations.gridlist[2], "ID", 0.2)
	guiGridListAddColumn(DutyLocations.gridlist[2], "İsim", 0.9)

	DutyLocations.button[1] = guiCreateButton(9, 332, 240, 27, "-->", false, DutyLocations.window[1])
	guiSetProperty(DutyLocations.button[1], "NormalTextColour", "FFAAAAAA")
	addEventHandler("onClientGUIClick", DutyLocations.button[1], addLocationToDuty, false)
	addEventHandler("onClientGUIDoubleClick", DutyLocations.gridlist[1], addLocationToDuty, false)
	DutyLocations.button[2] = guiCreateButton(270, 332, 240, 27, "<--", false, DutyLocations.window[1])
	guiSetProperty(DutyLocations.button[2], "NormalTextColour", "FFAAAAAA")
	addEventHandler("onClientGUIClick", DutyLocations.button[2], removeLocationFromDuty, false)
	addEventHandler("onClientGUIDoubleClick", DutyLocations.gridlist[2], removeLocationFromDuty, false)
	DutyLocations.label[1] = guiCreateLabel(10, 19, 233, 17, "Tüm konumlar", false, DutyLocations.window[1])
	guiLabelSetHorizontalAlign(DutyLocations.label[1], "center", false)
	DutyLocations.label[2] = guiCreateLabel(270, 19, 233, 17, "Görev konumları", false, DutyLocations.window[1])
	guiLabelSetHorizontalAlign(DutyLocations.label[2], "center", false)
	DutyLocations.button[3] = guiCreateButton(270, 367, 146, 36, "Kaydet", false, DutyLocations.window[1])
	guiSetProperty(DutyLocations.button[3], "NormalTextColour", "FFAAAAAA")
	addEventHandler("onClientGUIClick", DutyLocations.button[3], saveGUI, false)

	DutyLocations.button[4] = guiCreateButton(103, 367, 146, 36, "İptal", false, DutyLocations.window[1])
	guiSetProperty(DutyLocations.button[4], "NormalTextColour", "FFAAAAAA")
	addEventHandler("onClientGUIClick", DutyLocations.button[4], closeTheGUI, false)

	populateLocations()
end

DutySkins = {
	edit = {},
	button = {},
	window = {},
	label = {},
	gridlist = {},
}

function skinAlreadyExists(skin, dupont, model)
	for k, v in pairs(dutyNewSkins) do
		if skin == v[1] and dupont == v[2] and model == v[3] then
			return true
		end
	end
end

function addSkin()
	local raw = guiGetText(DutySkins.edit[1])
	if string.find(raw, ";") then
		local howAboutIt = split(raw, ";")
		if tonumber(howAboutIt[1]) and tonumber(howAboutIt[2]) and tonumber(howAboutIt[3]) then
			if not skinAlreadyExists(tonumber(howAboutIt[1]), tonumber(howAboutIt[2]), tonumber(howAboutIt[3])) then
				table.insert(dutyNewSkins, { howAboutIt[1], howAboutIt[2], howAboutIt[3] })
				local row = guiGridListAddRow(DutySkins.gridlist[1])

				guiGridListSetItemText(DutySkins.gridlist[1], row, 1, tostring(howAboutIt[1]), false, false)
				guiGridListSetItemText(DutySkins.gridlist[1], row, 2, tostring(howAboutIt[2]), false, false)
				guiGridListSetItemText(DutySkins.gridlist[1], row, 3, tostring(howAboutIt[3]), false, false)
			else
				outputChatBox("[!]#FFFFFF Aynı kıyafeti iki kez ekleyemezsiniz.", 255, 0, 0, true)
			end
		else
			outputChatBox("[!]#FFFFFF Lütfen sadece rakam kullanın.", 255, 0, 0, true)
		end
	end
	guiSetText(DutySkins.edit[1], "")
end

function removeSkin()
	local r, c = guiGridListGetSelectedItem(DutySkins.gridlist[1])
	if r >= 0 then
		local skin = guiGridListGetItemText(DutySkins.gridlist[1], r, 1)
		local dupont = guiGridListGetItemText(DutySkins.gridlist[1], r, 2)
		local model = guiGridListGetItemText(DutySkins.gridlist[1], r, 3)

		for k, v in pairs(dutyNewSkins) do
			if tonumber(v[1]) == tonumber(skin) and tostring(v[2]) == dupont and tostring(v[3]) == model then
				table.remove(dutyNewSkins, k)
				break
			end
		end

		guiGridListRemoveRow(DutySkins.gridlist[1], r)
	end
end

local function formatSkin(v)
	return v[1] .. (v[2] ~= 0 and (";" .. v[2]) or "")
end

function createSkins()
	if isElement(DutySkins.window[1]) then
		destroyElement(DutySkins.window[1])
		dutyNewSkins = nil
	end

	DutySkins.window[1] = guiCreateWindow(697, 240, 294, 425, "", false)
	guiWindowSetSizable(DutySkins.window[1], false)
	exports.mek_global:centerWindow(DutySkins.window[1])

	DutySkins.gridlist[1] = guiCreateGridList(9, 36, 275, 275, false, DutySkins.window[1])
	guiGridListAddColumn(DutySkins.gridlist[1], "SkinID", 0.3)
	guiGridListAddColumn(DutySkins.gridlist[1], "DupontID", 0.3)
	guiGridListAddColumn(DutySkins.gridlist[1], "ModelID", 0.4)
	DutySkins.label[1] = guiCreateLabel(12, 18, 272, 18, "Görev Kıyafetleri", false, DutySkins.window[1])
	guiLabelSetHorizontalAlign(DutySkins.label[1], "center", false)
	DutySkins.edit[1] = guiCreateEdit(11, 313, 139, 29, "", false, DutySkins.window[1])
	DutySkins.button[1] = guiCreateButton(152, 313, 53, 29, "Ekle", false, DutySkins.window[1])
	guiSetProperty(DutySkins.button[1], "NormalTextColour", "FFAAAAAA")
	addEventHandler("onClientGUIClick", DutySkins.button[1], addSkin, false)
	DutySkins.button[2] = guiCreateButton(231, 313, 53, 29, "Sil", false, DutySkins.window[1])
	guiSetProperty(DutySkins.button[2], "NormalTextColour", "FFAAAAAA")
	addEventHandler("onClientGUIClick", DutySkins.button[2], removeSkin, false)
	addEventHandler("onClientGUIDoubleClick", DutySkins.gridlist[1], removeSkin, false)
	DutySkins.label[2] = guiCreateLabel(
		11,
		345,
		273,
		29,
		"Kullanım: SkinID;DupontID;ModelID\nÖrnek: 121;622;0",
		false,
		DutySkins.window[1]
	)
	guiLabelSetHorizontalAlign(DutySkins.label[2], "center", false)
	DutySkins.button[3] = guiCreateButton(9, 381, 99, 34, "İptal", false, DutySkins.window[1])
	guiSetProperty(DutySkins.button[3], "NormalTextColour", "FFAAAAAA")
	addEventHandler("onClientGUIClick", DutySkins.button[3], closeTheGUI, false)

	DutySkins.button[4] = guiCreateButton(185, 381, 99, 34, "Kaydet", false, DutySkins.window[1])
	guiSetProperty(DutySkins.button[4], "NormalTextColour", "FFAAAAAA")
	addEventHandler("onClientGUIClick", DutySkins.button[4], saveGUI, false)

	populateSkins()
end

DutyVehicleAdd = {
	button = {},
	window = {},
	edit = {},
}

function createVehicleAdd()
	if isElement(DutyVehicleAdd.window[1]) then
		destroyElement(DutyVehicleAdd.window[1])
	end

	DutyVehicleAdd.window[1] = guiCreateWindow(685, 338, 335, 85, "Yeni Görev Aracı Ekle", false)
	guiWindowSetSizable(DutyVehicleAdd.window[1], false)
	exports.mek_global:centerWindow(DutyVehicleAdd.window[1])

	DutyVehicleAdd.edit[1] = guiCreateEdit(9, 26, 181, 40, "Araç ID", false, DutyVehicleAdd.window[1])
	DutyVehicleAdd.button[1] = guiCreateButton(192, 26, 62, 40, "Ekle", false, DutyVehicleAdd.window[1])
	guiSetProperty(DutyVehicleAdd.button[1], "NormalTextColour", "FFAAAAAA")
	addEventHandler("onClientGUIClick", DutyVehicleAdd.button[1], saveGUI, false)

	DutyVehicleAdd.button[2] = guiCreateButton(263, 26, 62, 40, "Kapat", false, DutyVehicleAdd.window[1])
	guiSetProperty(DutyVehicleAdd.button[2], "NormalTextColour", "FFAAAAAA")
	addEventHandler("onClientGUIClick", DutyVehicleAdd.button[2], closeTheGUI, false)
end

DutyLocationMaker = {
	button = {},
	window = {},
	edit = {},
	label = {},
}

function createDutyLocationMaker(x, y, z, r, i, d, name)
	if isElement(DutyLocationMaker.window[1]) then
		destroyElement(DutyLocationMaker.window[1])
	end
	DutyLocationMaker.window[1] = guiCreateWindow(638, 285, 488, 198, "Görev Konumu Ekle", false)
	guiWindowSetSizable(DutyLocationMaker.window[1], false)
	exports.mek_global:centerWindow(DutyLocationMaker.window[1])

	DutyLocationMaker.label[1] = guiCreateLabel(8, 24, 44, 19, "X Değeri:", false, DutyLocationMaker.window[1])
	DutyLocationMaker.edit[1] = guiCreateEdit(56, 24, 135, 20, "", false, DutyLocationMaker.window[1])
	DutyLocationMaker.label[2] = guiCreateLabel(201, 24, 53, 19, "Y Değeri:", false, DutyLocationMaker.window[1])
	DutyLocationMaker.edit[2] = guiCreateEdit(253, 23, 88, 20, "", false, DutyLocationMaker.window[1])
	DutyLocationMaker.label[3] = guiCreateLabel(355, 25, 52, 18, "Z Değeri:", false, DutyLocationMaker.window[1])
	DutyLocationMaker.edit[3] = guiCreateEdit(406, 23, 71, 20, "", false, DutyLocationMaker.window[1])
	DutyLocationMaker.label[4] = guiCreateLabel(8, 60, 49, 18, "Radius:", false, DutyLocationMaker.window[1])
	DutyLocationMaker.edit[4] = guiCreateEdit(53, 58, 82, 20, "1-10", false, DutyLocationMaker.window[1])
	DutyLocationMaker.label[5] = guiCreateLabel(162, 61, 72, 17, "Interior:", false, DutyLocationMaker.window[1])
	DutyLocationMaker.edit[5] = guiCreateEdit(216, 58, 93, 20, "", false, DutyLocationMaker.window[1])
	DutyLocationMaker.label[6] = guiCreateLabel(336, 60, 60, 18, "Dimension:", false, DutyLocationMaker.window[1])
	DutyLocationMaker.edit[6] = guiCreateEdit(402, 58, 75, 20, "", false, DutyLocationMaker.window[1])
	DutyLocationMaker.label[7] = guiCreateLabel(9, 92, 57, 21, "İsim:", false, DutyLocationMaker.window[1])
	DutyLocationMaker.label[8] = guiCreateLabel(
		10,
		119,
		467,
		28,
		"Görev ismi sadece kimliğinizin tespiti için kullanılır.",
		false,
		DutyLocationMaker.window[1]
	)
	guiLabelSetHorizontalAlign(DutyLocationMaker.label[8], "center", false)
	DutyLocationMaker.edit[7] = guiCreateEdit(51, 91, 426, 22, "", false, DutyLocationMaker.window[1])
	DutyLocationMaker.button[1] =
		guiCreateButton(10, 149, 115, 37, "Geçerli Konumu Ekle", false, DutyLocationMaker.window[1])
	guiSetProperty(DutyLocationMaker.button[1], "NormalTextColour", "FFAAAAAA")
	addEventHandler("onClientGUIClick", DutyLocationMaker.button[1], curPos, false)

	DutyLocationMaker.button[2] = guiCreateButton(184, 149, 115, 37, "Kapat", false, DutyLocationMaker.window[1])
	guiSetProperty(DutyLocationMaker.button[2], "NormalTextColour", "FFAAAAAA")
	addEventHandler("onClientGUIClick", DutyLocationMaker.button[2], closeTheGUI, false)

	DutyLocationMaker.button[3] = guiCreateButton(357, 149, 115, 37, "Kaydet", false, DutyLocationMaker.window[1])
	guiSetProperty(DutyLocationMaker.button[3], "NormalTextColour", "FFAAAAAA")
	addEventHandler("onClientGUIClick", DutyLocationMaker.button[3], saveGUI, false)

	if name then
		guiSetText(DutyLocationMaker.edit[1], x)
		guiSetText(DutyLocationMaker.edit[2], y)
		guiSetText(DutyLocationMaker.edit[3], z)
		guiSetText(DutyLocationMaker.edit[4], r)
		guiSetText(DutyLocationMaker.edit[5], i)
		guiSetText(DutyLocationMaker.edit[6], d)
		guiSetText(DutyLocationMaker.edit[7], name)
	end
end

function duplicateVeh(type, id, faction)
	for k, v in ipairs(locationsg) do
		if v[10] == id then
			return true
		end
	end
end

function closeTheGUI()
	if source == DutyCreate.button[1] then
		destroyElement(DutyCreate.window[1])
		customEditID = 0
		tempLocations = nil
		dutyNewSkins = nil
		dutyItems = nil
		setElementData(localPlayer, "savedLocations", false)
		setElementData(localPlayer, "savedSkins", false)
	elseif source == DutyLocations.button[4] then
		tempLocations = nil
		destroyElement(DutyLocations.window[1])
	elseif source == DutySkins.button[3] then
		dutyNewSkins = nil
		destroyElement(DutySkins.window[1])
	elseif source == DutyVehicleAdd.button[2] then
		destroyElement(DutyVehicleAdd.window[1])
	elseif source == DutyLocationMaker.button[2] then
		locationEditID = 0
		destroyElement(DutyLocationMaker.window[1])
	end
end

function saveGUI()
	if source == DutyCreate.button[2] then
		local name = guiGetText(DutyCreate.edit[3])
		if name ~= "" then
			if customEditID ~= 0 then
				triggerServerEvent(
					"duty.addDuty",
					resourceRoot,
					dutyItems,
					getElementData(localPlayer, "savedLocations") or customg[customEditID][4],
					getElementData(localPlayer, "savedSkins") or customg[customEditID][3],
					name,
					factionIDg,
					customEditID
				)
			else
				triggerServerEvent(
					"duty.addDuty",
					resourceRoot,
					dutyItems,
					getElementData(localPlayer, "savedLocations") or {},
					getElementData(localPlayer, "savedSkins") or {},
					name,
					factionIDg,
					customEditID
				)
			end
			tempLocations = nil
			dutyNewSkins = nil
			dutyItems = nil
			customEditID = 0
			setElementData(localPlayer, "savedLocations", false)
			setElementData(localPlayer, "savedSkins", false)
		else
			outputChatBox("[!]#FFFFFF Lütfen bu görev için bir isim girin.", 255, 0, 0, true)
			return
		end
		destroyElement(DutyCreate.window[1])
	elseif source == DutyLocations.button[3] then
		setElementData(localPlayer, "savedLocations", tempLocations)
		tempLocations = nil
		destroyElement(DutyLocations.window[1])
	elseif source == DutySkins.button[4] then
		setElementData(localPlayer, "savedSkins", dutyNewSkins)
		dutyNewSkins = nil
		destroyElement(DutySkins.window[1])
	elseif source == DutyVehicleAdd.button[1] then
		local id = guiGetText(DutyVehicleAdd.edit[1])
		if not duplicateVeh("location", id, factionIDg) then
			triggerServerEvent("duty.addVehicle", resourceRoot, tonumber(id), factionIDg)
			destroyElement(DutyVehicleAdd.window[1])
		else
			outputChatBox("[!]#FFFFFF Bu araç zaten eklendi.", 255, 0, 0, true)
		end
	elseif source == DutyLocationMaker.button[3] then
		local x = tonumber(guiGetText(DutyLocationMaker.edit[1]))
		local y = tonumber(guiGetText(DutyLocationMaker.edit[2]))
		local z = tonumber(guiGetText(DutyLocationMaker.edit[3]))
		local r = tonumber(guiGetText(DutyLocationMaker.edit[4]))
		local i = tonumber(guiGetText(DutyLocationMaker.edit[5]))
		local d = tonumber(guiGetText(DutyLocationMaker.edit[6]))
		local name = guiGetText(DutyLocationMaker.edit[7])

		if x and y and z and r and i and d and name then
			if r >= 1 and r <= 10 then
				if string.len(name) > 0 then
					triggerServerEvent(
						"duty.addLocation",
						resourceRoot,
						x,
						y,
						z,
						r,
						i,
						d,
						name,
						factionIDg,
						(locationEditID ~= 0 and locationEditID or nil)
					)
				else
					outputChatBox("[!]#FFFFFF Bir isim girmelisiniz.", 255, 0, 0, true)
					return
				end
			else
				outputChatBox("[!]#FFFFFF Radius 1 ile 10 arasında olmalıdır.", 255, 0, 0, true)
				return
			end
		else
			outputChatBox("[!]#FFFFFF Lütfen tüm bilgileri doğru bir şekilde giriniz.", 255, 0, 0, true)
			return
		end
		locationEditID = 0
		destroyElement(DutyLocationMaker.window[1])
	end
end

function curPos()
	local x, y, z = getElementPosition(localPlayer)
	local dim = getElementDimension(localPlayer)
	local int = getElementInterior(localPlayer)
	return guiSetText(DutyLocationMaker.edit[1], x),
		guiSetText(DutyLocationMaker.edit[2], y),
		guiSetText(DutyLocationMaker.edit[3], z),
		guiSetText(DutyLocationMaker.edit[5], int),
		guiSetText(DutyLocationMaker.edit[6], dim)
end

function removeLocation()
	local r, c = guiGridListGetSelectedItem(Duty.gridlist[1])
	if r >= 0 then
		local removeid = guiGridListGetItemText(Duty.gridlist[1], r, 1)
		triggerServerEvent("duty.removeLocation", resourceRoot, removeid, factionIDg)
		locationsg[tonumber(removeid)] = nil
		refreshUI()
	end
end

function removeDuty()
	local r, c = guiGridListGetSelectedItem(Duty.gridlist[2])
	if r >= 0 then
		local removeid = guiGridListGetItemText(Duty.gridlist[2], r, 1)
		triggerServerEvent("duty.removeDuty", resourceRoot, removeid, factionIDg)
		customg[tonumber(removeid)] = nil
		refreshUI()
	end
end

function removeVehicle()
	local r, c = guiGridListGetSelectedItem(Duty.gridlist[3])
	if r >= 0 then
		local removeid = guiGridListGetItemText(Duty.gridlist[3], r, 1)
		triggerServerEvent("duty.removeLocation", resourceRoot, removeid, factionIDg)
		locationsg[tonumber(removeid)] = nil
		refreshUI()
	end
end
