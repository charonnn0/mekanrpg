addEvent("legal.tazerFired", true)
addEventHandler("legal.tazerFired", root, function(x, y, z, targetPlayer)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	local px, py, pz = getElementPosition(source)
	local distance = getDistanceBetweenPoints3D(x, y, z, px, py, pz)

	if distance < 20 then
		if isElement(targetPlayer) and getElementType(targetPlayer) == "player" then
			for i, player in ipairs(exports.mek_global:getNearbyElements(targetPlayer, "player", 20)) do
				if player ~= source then
					triggerClientEvent(player, "legal.showTazerEffect", player, x, y, z)
				end
			end

			setPedWeaponSlot(targetPlayer, 0)
			setElementData(targetPlayer, "tazed", true)
			toggleAllControls(targetPlayer, false, true, false)

			if isPedInVehicle(targetPlayer) then
				setPedAnimation(targetPlayer, "ped", "CAR_dead_LHS", -1, false, true, true, true)
			else
				setPedAnimation(targetPlayer, "ped", "FLOOR_hit_f", -1, false, true, true, true)
			end
		end
	end
end)

addEvent("legal.setDeagleMode", true)
addEventHandler("legal.setDeagleMode", root, function(mode)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if tonumber(mode) and (tonumber(mode) >= 0 and tonumber(mode) <= 2) then
		setElementData(source, "deagle_mode", mode)
	end
end)
