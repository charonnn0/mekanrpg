function modifyPlayerItemValues(player, dbid, values, skipUpdateLocalGuns)
	local weapon, slot = getPlayerWeaponFromDBID(player, dbid, true)
	if weapon then
		local modifiedWeaponData = nil
		for attribute, value in pairs(modifications) do
			modifiedWeaponData = modifyWeaponValue(modifiedWeaponData, attribute, value)
		end

		if modifiedWeaponData then
			local result = exports.mek_item:updateItemValue(player, slot, modifiedWeaponData)
			if not skipUpdateLocalGuns then
				updateLocalGuns(player)
			end
			return result
		end
	end
end
