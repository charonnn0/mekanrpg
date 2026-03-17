INJURED_DRAIN_INTERVAL = 1000 * 60
INJURED_DRAIN_AMOUNT = 5
MIN_HEALTH_FOR_DRAIN = 20

DeathReason = {
	Killed_With_Weapon = "Killed_With_Weapon",
	Killed_With_Melee = "Killed_With_Melee",
	Car_Crash = "Car_Crash",
	Suicide = "Suicide",
	Drug = "Drug",
	Other = "Other",
}

DeathReasons = {
	[DeathReason.Killed_With_Weapon] = "Silahlı Saldırı",
	[DeathReason.Killed_With_Melee] = "Darp",
	[DeathReason.Car_Crash] = "Trafik Kazası",
	[DeathReason.Suicide] = "İntihar",
	[DeathReason.Drug] = "Uyuşturucu",
	[DeathReason.Other] = "Diğer",
}

local BASE_DEATH_TIME = 100

function getPlayerDeathTime(player)
	local time = BASE_DEATH_TIME

	local weaponCount = exports.mek_item:countItems(player, 115) or 1
	local ammoCount = exports.mek_item:countItems(player, 116) or 1
	local hasWeapon = exports.mek_item:hasItem(player, 115)
	local hasAmmo = exports.mek_item:hasItem(player, 116)

	if hasWeapon then
		time = time + (BASE_DEATH_TIME * weaponCount)
	end

	if hasAmmo then
		time = time + ((BASE_DEATH_TIME / 3) * ammoCount)
	end

	if time > 100 then
		time = 100
	end

	return time
end
