function givePlayerAmmo(thePlayer, targetPlayer, weaponID, ammoID, rounds)
	if thePlayer and targetPlayer and weaponID and not weaponAmmoless[weaponID] then
		local ammo = ammoID and ammunition[ammoID] or getAmmoForWeapon(weaponID)
		if ammo then
			ammo.rounds = tonumber(rounds) or ammo.rounds
			local serial = exports.mek_global:createWeaponSerial(
				1,
				getElementData(thePlayer, "dbid"),
				getElementData(targetPlayer, "dbid")
			)
			local success, error =
				exports.mek_item:giveItem(targetPlayer, 116, ammo.id .. ":" .. ammo.rounds .. ":" .. serial)
			if success then
				return success, ammo, serial
			else
				return success, ammo, error
			end
		else
			return false, nil, "Bu silaha uygun mühimmat bulunamadı."
		end
	end
end
