reloading = false

function doReload()
	local id = getPedWeapon(localPlayer)
	if isGun(id) and not weaponAmmoless[id] then
		local slot = getPedWeaponSlot(localPlayer)
		if not usingWeapon or not usingWeapon[slot] then return end
		local dbid = usingWeapon[slot]
		local hasAmmo, loadedAmmo = clientWeaponAndAmmoCheck(localPlayer, dbid, id)

		if hasAmmo then
			if reloading then
				outputChatBox("[!]#FFFFFF Lütfen bekleyin.", 255, 0, 0, true)
			else
				local totalAmmo = getPedTotalAmmo(localPlayer, slot) - 1
				local onePack = getWeaponProperty(id, "std", "maximum_clip_ammo")

				if onePack ~= 0 and totalAmmo < onePack then
					reloading = true
					syncAmmo()
					triggerServerEvent("weapon.reload", resourceRoot, dbid)
				end
			end
		else
			outputChatBox("[!]#FFFFFF Bu silah için ekstra cephaneniz yok.", 255, 0, 0, true)
		end
	end
end

local reloadTimer

function callbackReload()
	if reloadTimer and isTimer(reloadTimer) then
		killTimer(reloadTimer)
	end

	reloadTimer = setTimer(function()
		reloading = false
	end, 800, 1)
end
addEvent("weapon.reloadCallback", true)
addEventHandler("weapon.reloadCallback", resourceRoot, callbackReload)

addEventHandler("onClientResourceStart", resourceRoot, function()
	bindKey("r", "down", doReload)
end)
