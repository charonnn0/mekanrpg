weapons = {}
ammopacks = {}

local function getItems(player)
	return exports.mek_item:getItems(player)
end

local function takeAllWeapons(player)
	for _, weapon in pairs(exports.mek_global:getPedWeapons(player, 0, 12)) do
		takeWeapon(player, weapon)
		if weapon == 1 then
			giveWeapon(player, 0, 0, true)
		end
	end
end

function refreshWeaponsAndAmmoTables(player)
	weapons[player] = {
		[0] = {
			[0] = {
				id = 0,
				slot = 0,
				name = "Fist",
			},
		},
	}
	ammopacks[player] = {}

	for itemSlot, itemCheck in ipairs(getItems(player)) do
		if itemCheck[1] == 115 then
			local dbid = tonumber(itemCheck[3])
			local weaponDetails = split(itemCheck[2], ":")
			local id = tonumber(weaponDetails[1])
			local slot = getSlotFromWeapon(id)
			local loadedAmmo = tonumber(weaponDetails[4] and weaponDetails[4] or 0) or 0
			local serial = weaponDetails[2]

			if not weapons[player][slot] then
				weapons[player][slot] = {}
			end

			weapons[player][slot][dbid] = {
				dbid = dbid,
				id = id,
				slot = slot,
				name = weaponDetails[3],
				serial = serial,
				loadedAmmo = loadedAmmo,
				itemSlot = itemSlot,
				itemValue = itemCheck[2],
			}
		elseif itemCheck[1] == 116 then
			if itemCheck[2] and type(itemCheck[2]) == "string" then
				local weaponDetails = split(itemCheck[2], ":")
				local ammo = weaponDetails and tonumber(weaponDetails[2]) or 0
				local id = weaponDetails and tonumber(weaponDetails[1]) or 0
				if id and id > 0 and ammo and ammo > 0 and not ammopacks[player][id] then
					ammopacks[player][id] = {
						ammo = ammo,
						itemSlot = itemSlot,
						id = id,
						itemValue = itemCheck[2],
					}
				end
			end
		end
	end
end

function updateLocalGuns(player, delay)
	player = player or source
	if not player or not getElementData(player, "logged") then
		return
	end

	refreshWeaponsAndAmmoTables(player)
	takeAllWeapons(player)

	local given = {}
	for slot, weapon in pairs(weapons[player]) do
		for dbid, _ in pairs(weapon) do
			if weapons[player][slot][dbid] then
				if weaponInfiniteAmmo[weapons[player][slot][dbid].id] then
					weapons[player][slot][dbid].loadedAmmo = 9998
				end

				weapons[player][slot][dbid].loadedAmmo = weapons[player][slot][dbid].loadedAmmo or 0
				setWeaponAmmo(player, weapons[player][slot][dbid].id, 0)
				giveWeapon(player, weapons[player][slot][dbid].id, weapons[player][slot][dbid].loadedAmmo + 1, false)
				given[slot] = dbid
				break
			end
		end
	end

	if delay and tonumber(delay) then
		setTimer(triggerClientEvent, delay, 1, player, "weapon.updateUsingGun", resourceRoot, given)
	else
		triggerClientEvent(player, "weapon.updateUsingGun", resourceRoot, given)
	end
end
addEvent("updateLocalGuns", true)
addEventHandler("updateLocalGuns", root, updateLocalGuns)

addEventHandler("onResourceStart", resourceRoot, function()
	for _, player in pairs(getElementsByType("player")) do
		updateLocalGuns(player, 3000)
	end
end)

addEvent("weapon.switchWeaponInSameSlot", true)
addEventHandler("weapon.switchWeaponInSameSlot", root, function(dbid, slot)
	local result = nil
	refreshWeaponsAndAmmoTables(source)
	local weapon = getPlayerWeaponFromDBID(source, dbid)

	slot = slot - 1

	if weapon then
		for _, _weapon in pairs(weapons[source][slot]) do
			if _weapon.slot == slot then
				setWeaponAmmo(source, _weapon.id, 0)
			end
		end

		local weaponDetails = split(weapon[2], ":")
		local weaponID = weaponDetails[1]

		local loadedAmmo = weapons[source][slot][dbid].loadedAmmo or 0
		giveWeapon(source, weaponID, loadedAmmo + 1, false)
		result = {
			slot = slot,
			dbid = dbid,
		}
	end

	triggerClientEvent(source, "weapon.weaponSwitchCallback", source, result)
end)

function syncAmmo(queue)
	for dbid, ammo in pairs(queue) do
		local weapon = getPlayerWeaponFromDBID(client, dbid)
		if weapon then
			local weaponDetails = split(weapon[2], ":")
			local id = tonumber(weaponDetails[1])
			local slot = getSlotFromWeapon(id)

			if weapons[client][slot] then
				local dbid = weaponSlot
				if weapons[client][slot][dbid] then
					weapons[client][slot][dbid].loadedAmmo = ammo >= 0 and ammo or 0
					for itemSlot, item in ipairs(getItems(client)) do
						if item[1] == 115 and item[3] == dbid then
							local id = weapon[1]
							if weaponAmmoless[id] then
								exports.mek_item:takeItemFromSlot(client, itemSlot)
							else
								local newValue = modifyWeaponValue(item[2], 4, weapons[client][slot][dbid].loadedAmmo)
								if not newValue or not exports.mek_item:updateItemValue(client, itemSlot, newValue) then
									outputServerLog(
										"[WEAPON] Server / syncAmmo / Could not sync ammo for player "
											.. getPlayerName(client)
									)
								end
							end
							break
						end
					end
				end
			end
		end
	end
end
addEvent("weapon.syncAmmo", true)
addEventHandler("weapon.syncAmmo", resourceRoot, syncAmmo)
