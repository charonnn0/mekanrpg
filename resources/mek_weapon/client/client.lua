syncedAmmo = nil
local ammoSyncCooldown = 5000
ammoSyncQueue = {}
local hasAmmo = true
ammos = {}

function syncAmmo()
	if #ammoSyncQueue ~= 0 then
		if triggerServerEvent("weapon.syncAmmo", resourceRoot, ammoSyncQueue) then
			syncedAmmo = nil
			ammoSyncQueue = {}
		end
	end
end

addEventHandler("onClientRender", root, function()
	if isControlEnabled("fire") and not canPlayerShoot() then
		toggleControl("fire", false)
		toggleControl("action", false)
	elseif not isControlEnabled("fire") and canPlayerShoot() then
		toggleControl("fire", true)
		toggleControl("action", true)
	end

	if syncedAmmo and getTickCount() - syncedAmmo > ammoSyncCooldown then
		syncAmmo()
	end
end)

function canPlayerShoot()
	if
		localPlayer:getData("dead")
		or localPlayer:getData("dragged_player")
		or localPlayer:getData("is_dragged")
		or localPlayer:getData("proned")
		or localPlayer:getData("tazed")
		or localPlayer:getData("restrained")
		or localPlayer:getData("frozen")
	then
		return false, "Kısıtlı."
	end

	if switching then
		return false, "Değiştiriliyor..."
	end

	if reloading then
		return false, "Dolduruluyor..."
	end

	if weaponFireDisabled[getPedWeapon(localPlayer)] then
		return false, ""
	end

	if weaponAmmoless[getPedWeapon(localPlayer)] then
		return true
	end

	local ammo = getPedTotalAmmo(localPlayer) - 1
	if ammo <= 0 then
		return false, "Mermi kalmadı!"
	else
		return true, ammo .. " mermi yüklendi."
	end
end

function traceBullet(weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement)
	if not (weapon == 39 or weapon == 40) then
		if source == localPlayer and not weaponInfiniteAmmo[weapon] then
			local slot = getPedWeaponSlot(source)
			local dbid = usingWeapon[slot]
			ammoSyncQueue[dbid] = ammo - 1
			syncedAmmo = getTickCount()
			local success, error = canPlayerShoot()
			if not success then
				if error == "Mermi kalmadı!" then
					triggerServerEvent(
						"global.playSound3D",
						localPlayer,
						":mek_weapon/public/sounds/no_ammo.mp3",
						false,
						20,
						100,
						false,
						true
					)
					doReload()
				else
					outputChatBox("[!]#FFFFFF " .. error, 255, 0, 0, true)
				end
			end
		end
	end
end
addEventHandler("onClientPlayerWeaponFire", root, traceBullet)

function removeWeapon(weapon)
	ammoSyncQueue[weapon] = 0
	syncAmmo()
end

addEventHandler("onClientKey", root, function(btn, press)
	if
		btn == "mouse1"
		and press
		and not isCursorShowing()
		and getPedWeapon(localPlayer) > 0
		and not weaponAmmoless[getPedWeapon(localPlayer)]
		and not canPlayerShoot()
	then
		triggerServerEvent(
			"global.playSound3D",
			localPlayer,
			":mek_weapon/public/sounds/no_ammo.mp3",
			false,
			20,
			100,
			false,
			true
		)
		doReload()
		if not pressed then
			addEventHandler("onClientRender", root, renderWeaponSelector)
		end
		pressed = getTickCount()
	end
end)
