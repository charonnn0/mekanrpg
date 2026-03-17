local sw, sh = guiGetScreenSize()
local fonts = useFonts()

local reconTarget = nil
local reconTargets = {}
local pointer = 0

local function addToReconTable(id)
	for _, existingID in pairs(reconTargets) do
		if existingID == id then
			return false
		end
	end
	table.insert(reconTargets, id)
	return true
end

function toggleRecon(state, targetPlayer)
	if state then
		local cur = exports.mek_data:get("reconCurpos")
		if not cur then
			cur = {}
			cur.x, cur.y, cur.z = getElementPosition(localPlayer)
			cur.rx, cur.ry, cur.rz = getElementRotation(localPlayer)
			cur.dim = getElementDimension(localPlayer)
			cur.int = getElementInterior(localPlayer)
		end
		cur.target = getElementData(targetPlayer, "id")
		reconTarget = targetPlayer
		exports.mek_data:save(cur, "reconCurpos")

		setElementData(localPlayer, "reconx", true, false)
		setElementCollisionsEnabled(localPlayer, false)
		setElementAlpha(localPlayer, 0)
		setPedWeaponSlot(localPlayer, 0)

		local t_dim = getElementDimension(targetPlayer)
		local t_int = getElementInterior(targetPlayer)
		setElementDimension(localPlayer, t_dim)
		setElementInterior(localPlayer, t_int)
		setCameraInterior(t_int)

		local x1, y1, z1 = getElementPosition(targetPlayer)
		attachElements(localPlayer, targetPlayer, 0, 0, 5)
		setElementPosition(localPlayer, x1, y1, z1 + 5)
		setCameraTarget(targetPlayer)
	else
		local cur = exports.mek_data:get("reconCurpos")
		if cur then
			detachElements(localPlayer)
			setElementData(localPlayer, "reconx", false, false)

			setElementPosition(localPlayer, cur.x, cur.y, cur.z)
			setElementRotation(localPlayer, cur.rx, cur.ry, cur.rz)

			setElementDimension(localPlayer, cur.dim)
			setElementInterior(localPlayer, cur.int)
			setCameraInterior(cur.int)

			setCameraTarget(localPlayer, nil)
			setElementAlpha(localPlayer, 255)
			setElementCollisionsEnabled(localPlayer, true)

			exports.mek_data:save(nil, "reconCurpos")
			reconTarget = nil
		end
	end
end

function reconPlayer(commandName, targetPlayer)
	if source then
		localPlayer = source
	end

	if getElementData(localPlayer, "logged") and exports.mek_integration:isPlayerTrialAdmin(localPlayer) then
		local reconx = getElementData(localPlayer, "reconx")
		if not targetPlayer then
			if toggleRecon(false) then
				reconTargets = {}
				pointer = 0
			end
		else
			local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(localPlayer, targetPlayer)
			if not targetPlayer then
				return
			end

			if not getElementData(targetPlayer, "logged") then
				return
			end

			if targetPlayer == localPlayer then
				return
			end

			if not exports.mek_integration:canAdminPunish(localPlayer, targetPlayer) then
				outputChatBox("[!]#FFFFFF Kendinizden üst veya eşit yetkideki birini izleyemezsiniz.", 255, 0, 0, true)
				return
			end

			toggleRecon(true, targetPlayer)
		end
	end
end
addEvent("admin.recon", true)
addEventHandler("admin.recon", root, reconPlayer)
addCommandHandler("recon", reconPlayer)

addEventHandler("onClientElementDataChange", root, function(dataName)
	if getElementType(source) == "player" and dataName == "reconx" then
		if getElementData(source, "reconx") then
			addEventHandler("onClientRender", root, displayReconInfo)
		else
			removeEventHandler("onClientRender", root, displayReconInfo)
		end
	end
end)

function displayReconInfo()
	if not reconTarget or not isElement(reconTarget) or not getElementData(reconTarget, "logged") then
		return removeEventHandler("onClientRender", root, displayReconInfo)
	end

	local w, h = 760, 85
	local x, y = (sw - w) / 2, sh - h - 20

	dxDrawRectangle(x, y, w, h, tocolor(10, 10, 10, 200), true)

	local ox, oy = 507, 396
	local xo, yo = x - ox, y - oy
	local factionText = ""

	dxDrawText(
		"HP: " .. math.floor(getElementHealth(reconTarget)),
		517 + xo,
		423 + yo,
		706 + xo,
		440 + yo,
		tocolor(255, 255, 255, 255),
		1,
		fonts.SFUIRegular.caption,
		"left",
		"top",
		false,
		false,
		true,
		false,
		false
	)
	dxDrawText(
		"Oyuncu: " .. exports.mek_global:getPlayerFullAdminTitle(reconTarget),
		517 + xo,
		406 + yo,
		887 + xo,
		423 + yo,
		tocolor(255, 255, 255, 255),
		1,
		fonts.SFUIRegular.caption,
		"left",
		"top",
		false,
		false,
		true,
		false,
		false
	)

	local weapon = getPedWeapon(reconTarget)
	if weapon then
		weapon = getWeaponNameFromID(weapon)
	else
		weapon = "?"
	end

	dxDrawText(
		"Silah: " .. weapon,
		517 + xo,
		440 + yo,
		706 + xo,
		457 + yo,
		tocolor(255, 255, 255, 255),
		1,
		fonts.SFUIRegular.caption,
		"left",
		"top",
		false,
		false,
		true,
		false,
		false
	)
	dxDrawText(
		"Zırh: " .. math.floor(getPedArmor(reconTarget)),
		706 + xo,
		423 + yo,
		887 + xo,
		440 + yo,
		tocolor(255, 255, 255, 255),
		1,
		fonts.SFUIRegular.caption,
		"left",
		"top",
		false,
		false,
		true,
		false,
		false
	)
	dxDrawText(
		"Skin: " .. getElementModel(reconTarget),
		706 + xo,
		440 + yo,
		887 + xo,
		457 + yo,
		tocolor(255, 255, 255, 255),
		1,
		fonts.SFUIRegular.caption,
		"left",
		"top",
		false,
		false,
		true,
		false,
		false
	)
	dxDrawText(
		"Para: ₺" .. exports.mek_global:formatMoney(getElementData(reconTarget, "money") or 0),
		517 + xo,
		457 + yo,
		706 + xo,
		474 + yo,
		tocolor(255, 255, 255, 255),
		1,
		fonts.SFUIRegular.caption,
		"left",
		"top",
		false,
		false,
		true,
		false,
		false
	)

	factionText = ""

	local factions = getElementData(reconTarget, "faction") or {}
	local factionList = {}

	for id, faction in pairs(factions) do
		local rank = faction.rank
		local theFaction = exports.mek_faction:getFactionFromID(id)

		if rank and theFaction then
			local factionName = "#" .. id .. " - " .. exports.mek_faction:getFactionName(id)

			local ranks = getElementData(theFaction, "ranks")
			if ranks and ranks[rank] then
				factionName = factionName .. " (" .. ranks[rank] .. ")"
			end

			table.insert(factionList, factionName)
		end
	end

	if #factionList > 0 then
		factionText = table.concat(factionList, ", ")
	else
		factionText = "Yok"
	end

	local loc = exports.mek_global:getZoneName(getElementPosition(reconTarget))
	local int = getElementInterior(reconTarget)
	local dim = getElementDimension(reconTarget)

	if dim > 0 then
		loc = "Mülk ID #" .. dim
	end

	dxDrawText(
		"Birlik: " .. factionText,
		887 + xo,
		406 + yo,
		1257 + xo,
		423 + yo,
		tocolor(255, 255, 255, 255),
		1,
		fonts.SFUIRegular.caption,
		"left",
		"top",
		false,
		false,
		true,
		false,
		false
	)
	dxDrawText(
		"Bölge: " .. loc,
		887 + xo,
		423 + yo,
		1257 + xo,
		440 + yo,
		tocolor(255, 255, 255, 255),
		1,
		fonts.SFUIRegular.caption,
		"left",
		"top",
		false,
		false,
		true,
		false,
		false
	)
	dxDrawText(
		"Interior: " .. int,
		887 + xo,
		440 + yo,
		1076 + xo,
		457 + yo,
		tocolor(255, 255, 255, 255),
		1,
		fonts.SFUIRegular.caption,
		"left",
		"top",
		false,
		false,
		true,
		false,
		false
	)
	dxDrawText(
		"Dimension: " .. dim,
		1076 + xo,
		440 + yo,
		1257 + xo,
		457 + yo,
		tocolor(255, 255, 255, 255),
		1,
		fonts.SFUIRegular.caption,
		"left",
		"top",
		false,
		false,
		true,
		false,
		false
	)

	local hoursPlayed = tonumber(getElementData(reconTarget, "hours_played")) or "Bilinmiyor"
	dxDrawText(
		"Saat: " .. hoursPlayed,
		887 + xo,
		457 + yo,
		1076 + xo,
		474 + yo,
		tocolor(255, 255, 255, 255),
		1,
		fonts.SFUIRegular.caption,
		"left",
		"top",
		false,
		false,
		true,
		false,
		false
	)
	dxDrawText(
		"Ping: " .. getPlayerPing(reconTarget),
		1076 + xo,
		457 + yo,
		1257 + xo,
		474 + yo,
		tocolor(255, 255, 255, 255),
		1,
		fonts.SFUIRegular.caption,
		"left",
		"top",
		false,
		false,
		true,
		false,
		false
	)
end
