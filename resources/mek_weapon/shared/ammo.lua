local ammunition = {
	[1] = {
		id = 1,
		cartridge = "9mm",
		rounds = 30,
		weight = 0.008,
		weapons = {
			22,
			23,
			28,
			29,
			32,
		},
	},
	[2] = {
		id = 2,
		cartridge = "5.56mm",
		rounds = 50,
		weight = 0.004,
		weapons = {
			30,
			31,
		},
	},
	[3] = {
		id = 3,
		cartridge = "7.62mm",
		rounds = 20,
		weight = 0.009,
		weapons = {
			33,
			34,
			38,
		},
	},
	[4] = {
		id = 4,
		cartridge = ".45 ACP",
		rounds = 15,
		weight = 0.012,
		weapons = {
			24,
		},
	},
	[5] = {
		id = 5,
		cartridge = "12 Gauge",
		rounds = 10,
		weight = 0.032,
		weapons = {
			25,
			26,
			27,
		},
	},
	[6] = {
		id = 6,
		cartridge = "Explosive",
		rounds = 1,
		weight = 1.5,
		weapons = {
			35,
			36,
		},
	},
}

function getAmmo(id)
	return id and ammunition[id] or ammunition
end

function getAmmoForWeapon(weaponID)
	for ammoID, ammo in pairs(ammunition) do
		for _, _weaponID in pairs(ammo.weapons) do
			if _weaponID == weaponID then
				return ammo, ammoID
			end
		end
	end
end

function formatWeaponNames(weapons)
	local buffer = ""
	for _, weaponID in pairs(weapons) do
		buffer = buffer .. getWeaponNameFromID(weaponID) .. ", "
	end
	return string.sub(buffer, 1, string.len(buffer) - 2)
end
