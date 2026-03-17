weaponFireDisabled = {
	[14] = "Flowers",
}

weaponAmmoless = {
	[0] = "Fist",
	[1] = "Brass Knuckles",
	[2] = "Golf Club",
	[3] = "Nightstick",
	[4] = "Knife",
	[5] = "Baseball Bat",
	[6] = "Shovel",
	[7] = "Pool Cue",
	[8] = "Katana",
	[9] = "Chainsaw",
	[43] = "Camera",
	[10] = "Long Purple Dildo",
	[11] = "Short tan Dildo",
	[12] = "Vibrator",
	[15] = "Cane",
	[14] = "Flowers",
	[44] = "Night-Vision Goggles",
	[45] = "Infrared Goggles",
	[46] = "Parachute",
	[16] = "Grenade",
	[17] = "Tear Gas",
	[18] = "Molotov Cocktails",
	[37] = "Flamethrower",
	[39] = "Satchel",
	[40] = "Satchel Remote",
	[41] = "Spraycan",
	[42] = "Fire Extinguisher",
}

weaponInfiniteAmmo = {
	[37] = "Flamethrower",
	[43] = "Camera",
	[46] = "Parachute",
	[41] = "Spraycan",
	[42] = "Fire Extinguisher",
}

function isWeaponAmmoless(weaponID)
	return weaponAmmoless[weaponID]
end

function getPlayerWeaponFromDBID(player, dbid, checkItem)
	if triggerServerEvent then
		checkItem = true
	end

	if checkItem then
		for itemSlot, itemCheck in ipairs(exports.mek_item:getItems(player)) do
			if (itemCheck[1] == 115 or itemCheck[1] == 116) and tonumber(itemCheck[3]) == dbid then
				return itemCheck, itemSlot
			end
		end
	else
		if weapons[player] then
			for slot, weapon in pairs(weapons[player]) do
				for _dbid, _weapon in pairs(weapon) do
					if _dbid == dbid then
						return _weapon
					end
				end
			end
		end
	end
end

function modifyWeaponValue(itemValue, index, value)
	local values = split(itemValue, ":")
	for i = 1, index do
		if values[i] == nil then
			values[i] = ""
		end
	end
	values[index] = value
	return table.concat(values, ":")
end
