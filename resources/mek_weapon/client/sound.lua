setWorldSoundEnabled(42, false)
setWorldSoundEnabled(5, false)
setWorldSoundEnabled(5, 87, true)
setWorldSoundEnabled(5, 58, true)
setWorldSoundEnabled(5, 37, true)

addEventHandler("onClientPlayerWeaponFire", root, function(weaponID)
	local muzzleX, muzzleY, muzzleZ = getPedWeaponMuzzlePosition(source)
	local dimension = getElementDimension(source)

	local weaponSoundData = {
		[22] = { distance = 95, volume = 0.3 },
		[23] = { distance = 15, volume = 0.3 },
		[24] = { distance = 120, volume = 0.3 },
		[25] = { distance = 120, volume = 0.3 },
		[26] = { distance = 95, volume = 0.3 },
		[27] = { distance = 100, volume = 0.3 },
		[28] = { distance = 105, volume = 0.3 },
		[29] = { distance = 120, volume = 0.3 },
		[30] = { distance = 180, volume = 0.3 },
		[31] = { distance = 170, volume = 0.4 },
		[32] = { distance = 105, volume = 0.3 },
		[33] = { distance = 175, volume = 0.3 },
		[34] = { distance = 325, volume = 0.3 },
	}

	local data = weaponSoundData[weaponID]
	if data then
		local path = "public/sounds/weapons/" .. weaponID .. ".wav"

		if weaponID == 24 and getElementData(source, "deagle_mode") == 0 then
			path = "public/sounds/tazer.wav"
		elseif weaponID == 25 and getElementData(source, "shotgun_mode") == 0 then
			path = "public/sounds/beanbag.wav"
		end

		local sound = playSound3D(path, muzzleX, muzzleY, muzzleZ, false)

		setSoundMaxDistance(sound, data.distance)
		setElementDimension(sound, dimension)
		setSoundVolume(sound, data.volume)
	end
end)
