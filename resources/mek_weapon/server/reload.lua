function reload(dbid)
	triggerEvent("global.playSound3D", client, ":mek_weapon/public/sounds/reloads/1.mp3", false, 20, 100, false, false)

	if not isPedDucked(client) and not isPedInVehicle(client) then
		setPedAnimation(client, "BUDDY", "buddy_reload", -1, true, true, false)
	end

	refreshWeaponsAndAmmoTables(client)

	local weapon, itemSlot = getPlayerWeaponFromDBID(client, dbid)
	if weapon then
		local weaponDetails = split(weapon[2], ":")
		local id = tonumber(weaponDetails[1])
		local slot = getSlotFromWeapon(id)

		weapon[4] = weapon[4] or 0

		local ammo, ammoID = getAmmoForWeapon(id)
		local ammopack = ammo and ammopacks[client][ammoID]

		if ammopack and ammopack.ammo > 0 then
			local remain = 0
			local ammo = weapon[4] + ammopack.ammo

			if ammo > getWeaponProperty(id, "std", "maximum_clip_ammo") then
				remain = ammo - getWeaponProperty(id, "std", "maximum_clip_ammo")
				ammo = getWeaponProperty(id, "std", "maximum_clip_ammo")
			end

			weapons[client][slot][dbid].loadedAmmo = ammo
			local newValue = modifyWeaponValue(weapons[client][slot][dbid].itemValue, 4, ammo)
			exports.mek_item:updateItemValue(client, itemSlot, newValue)

			if remain > 0 then
				newValue = modifyWeaponValue(ammopack.itemValue, 2, remain)
				exports.mek_item:updateItemValue(client, ammopack.itemSlot, newValue)
			else
				exports.mek_item:takeItemFromSlot(client, ammopack.itemSlot, false, true)
			end

			setWeaponAmmo(client, id, 0)
			giveWeapon(client, id, ammo + 1, false)
		end
	end

	setTimer(
		triggerEvent,
		250,
		1,
		"global.playSound3D",
		client,
		":mek_weapon/public/sounds/reloads/2.mp3",
		false,
		20,
		100,
		false,
		false
	)
	setTimer(
		triggerEvent,
		600,
		1,
		"global.playSound3D",
		client,
		":mek_weapon/public/sounds/reloads/3.mp3",
		false,
		20,
		100,
		false,
		false
	)
	setTimer(setPedAnimation, 700, 1, client)

	triggerClientEvent(client, "weapon.reloadCallback", resourceRoot)
end
addEvent("weapon.reload", true)
addEventHandler("weapon.reload", resourceRoot, reload)
