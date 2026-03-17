local bodyPartTitles = {
	[3] = "Göğüs",
	[4] = "Kalça",
	[6] = "Sol Kol",
	[7] = "Sol Bacak",
	[8] = "Sağ Bacak",
	[9] = "Kafa",
}

local disabledWeapons = {
	[37] = true,
	[38] = true,
	[41] = true,
	[42] = true,
	[43] = true,
}

local enabledTypes = {
	["vehicle"] = true,
	["player"] = true,
}

local damages = {
	taken = {},
	given = {},
}

local warningMinutes = 1000 * 60 * 15
local maxDamagesPerCharacter = 150

local function hideDamages()
	if window and isElement(window) then
		destroyElement(window)
		showCursor(false)
		guiSetInputEnabled(false)
	end
end

local function createDamages(player)
	hideDamages()

	local playerDBID = tonumber(player:getData("dbid"))
	local playerDamages = damages.taken[playerDBID]
	local givenDamages = damages.given[playerDBID]

	showCursor(true)
	guiSetInputEnabled(true)

	window = guiCreateWindow(0, 0, 712, 399, "Hasarlar", false)
	guiWindowSetSizable(window, false)
	guiWindowSetMovable(window, false)

	local tabPanel = guiCreateTabPanel(9, 29, 693, 315, false, window)

	local gridlistes = {}
	for index, value in ipairs({
		guiCreateTab("Alınan Hasarlar", tabPanel),
		guiCreateTab("Verilen Hasarlar", tabPanel),
	}) do
		local gridlist = guiCreateGridList(10, 10, 673, 275, false, value)
		guiGridListAddColumn(gridlist, "ID", 0.08)
		guiGridListAddColumn(gridlist, "Hasar Veren", 0.2)
		guiGridListAddColumn(gridlist, "Hasar", 0.1)
		guiGridListAddColumn(gridlist, "Bölge", 0.15)
		guiGridListAddColumn(gridlist, "Silah", 0.16)
		guiGridListAddColumn(gridlist, "Tarih", 0.2)

		gridlistes[index] = gridlist
	end

	if playerDamages then
		table.sort(playerDamages, function(a, b)
			return a.id > b.id
		end)

		for index, value in pairs(playerDamages) do
			guiGridListAddRow(
				gridlistes[1],
				value.id,
				value.attackerTitle,
				value.loss .. " HP",
				value.location,
				value.weaponName,
				value.date
			)
		end
	end

	if givenDamages then
		table.sort(givenDamages, function(a, b)
			return a.id > b.id
		end)

		for index, value in pairs(givenDamages) do
			guiGridListAddRow(
				gridlistes[2],
				value.id,
				value.attackerTitle,
				value.loss .. " HP",
				value.location,
				value.weaponName,
				value.date
			)
		end
	end

	local close = guiCreateButton(9, 353, 693, 36, "Kapat", false, window)
	addEventHandler("onClientGUIClick", close, function(button)
		if button == "left" then
			hideDamages()
		end
	end, false)

	exports.mek_global:centerWindow(window)
end

addCommandHandler("hasarlar", function()
	if not localPlayer:getData("logged") then
		return false
	end

	local playerDBID = tonumber(localPlayer:getData("dbid"))

	if not damages.taken[playerDBID] then
		damages.taken[playerDBID] = {}
	end

	if not damages.given[playerDBID] then
		damages.given[playerDBID] = {}
	end

	createDamages(localPlayer)

	return true
end)

addEventHandler("onClientPlayerDamage", root, function(attacker, weapon, part, loss)
	if not isElement(attacker) then
		return false
	end

	if not enabledTypes[attacker:getType()] then
		return false
	end

	if not source:getData("logged") then
		return false
	end

	if disabledWeapons[tonumber(weapon)] then
		return false
	end

	local time = getRealTime()
	local date = string.format(
		"%02d-%02d-%02d %02d:%02d:%02d",
		time.monthday,
		time.month + 1,
		time.year + 1900,
		time.hour,
		time.minute,
		time.second
	)

	local attackerTitle = ""
	local partTitle = bodyPartTitles[tonumber(part)]
	local playerDBID = tonumber(source:getData("dbid"))
	local attackerDBID = tonumber(attacker:getData("dbid"))
	local location = exports.mek_global:getZoneName(source.position)
	local playerTitle = source:getName():gsub("_", " ")

	if attacker:getType() == "vehicle" then
		local driver = attacker:getController()
		if driver and isElement(driver) then
			attackerTitle = driver:getName():gsub("_", " ") .. " (Araçtan)"
		else
			attackerTitle = exports.mek_global:getVehicleName(attacker)
		end
	else
		attackerTitle = attacker == localPlayer and source:getName():gsub("_", " ") or attacker:getName():gsub("_", " ")
	end

	if not damages.taken[playerDBID] then
		damages.taken[playerDBID] = {}
		damages.given[playerDBID] = {}
	end

	if not damages.taken[attackerDBID] then
		damages.taken[attackerDBID] = {}
		damages.given[attackerDBID] = {}
	end

	if #damages.taken[playerDBID] > maxDamagesPerCharacter then
		table.remove(damages.taken[playerDBID], 1)
	end

	if #damages.given[playerDBID] > maxDamagesPerCharacter then
		table.remove(damages.given[playerDBID], 1)
	end

	if attacker == localPlayer then
		table.insert(damages.given[attackerDBID], {
			id = #damages.given[attackerDBID] + 1,
			attackerTitle = attackerTitle,
			partTitle = partTitle,
			date = date,
			location = location,
			loss = math.ceil(loss),
			weaponName = getWeaponNameFromID(weapon),
			name = playerTitle,
			player = source,
		})
	else
		table.insert(damages.taken[playerDBID], {
			id = #damages.taken[playerDBID] + 1,
			attackerTitle = attackerTitle,
			partTitle = partTitle,
			date = date,
			location = location,
			loss = math.ceil(loss),
			weaponName = getWeaponNameFromID(weapon),
			name = playerTitle,
			player = attacker,
			tickCount = getTickCount(),
		})
	end

	return true
end)
