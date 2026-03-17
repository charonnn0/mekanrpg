function isGun(id)
	return getSlotFromWeapon(id) >= 2 and getSlotFromWeapon(id) <= 7
end

function clientWeaponAndAmmoCheck(player, dbid, id)
	local hasAmmo, loadedAmmo
	for _, item in ipairs(exports.mek_item:getItems(player)) do
		if item[1] == 115 and item[3] == dbid then
			local weaponDetails = split(item[2], ":")
			loadedAmmo = tonumber(weaponDetails[4] or 0) or 0
		elseif item[1] == 116 and not hasAmmo then
			local weaponDetails = split(item[2], ":")
			local ammo, ammoID = getAmmoForWeapon(id)
			if ammo and tonumber(weaponDetails[1]) == ammoID then
				if tonumber(weaponDetails[2]) > 0 then
					hasAmmo = true
				end
			end
		end
		if hasAmmo and loadedAmmo then
			break
		end
	end
	return hasAmmo, loadedAmmo
end
