categories = {
	"Genel Ayarlar",
	"Ses Ayarları",
	"Grafik Ayarları",
}

initialSettings = {}
cachedSettings = {}

GLOBAL_SETTINGS = {
	["head_turning"] = {
		name = "Kafa Çevirme",
		category = 1,
		defaultValue = true,
		toggle = function()
			cachedSettings["head_turning"] = not cachedSettings["head_turning"]
		end,
		check = function()
			return cachedSettings["head_turning"] or defaultValue
		end,
	},
	["game_mods"] = {
		name = "Oyun Modları",
		category = 1,
		key = "game_mods",
		defaultValue = true,
		toggle = function()
			cachedSettings["game_mods"] = not cachedSettings["game_mods"]
			if cachedSettings["game_mods"] then
				exports.mek_mods:loadAllModels()
			else
				exports.mek_mods:unloadAllModels()
			end
		end,
		check = function()
			return cachedSettings["game_mods"] or defaultValue
		end,
	},

	["play_hourly_bonus_sound"] = {
		name = "Saatlik Bonus Sesi",
		category = 2,
		defaultValue = true,
		toggle = function()
			cachedSettings["play_hourly_bonus_sound"] = not cachedSettings["play_hourly_bonus_sound"]
		end,
		check = function()
			return cachedSettings["play_hourly_bonus_sound"] or defaultValue
		end,
	},

	["hud_visible"] = {
		name = "Arayüz Görünürlüğü",
		category = 3,
		key = "hud_visible",
		defaultValue = true,
		toggle = function()
			cachedSettings["hud_visible"] = not cachedSettings["hud_visible"]
		end,
		check = function()
			return cachedSettings["hud_visible"] or defaultValue
		end,
	},
	["nametag_visible"] = {
		name = "Oyuncu Adları Görünürlüğü",
		category = 3,
		key = "nametag_visible",
		defaultValue = true,
		toggle = function()
			cachedSettings["nametag_visible"] = not cachedSettings["nametag_visible"]
		end,
		check = function()
			return cachedSettings["nametag_visible"] or defaultValue
		end,
	},
	["voice_channels_visible"] = {
		name = "Ses Kanalları Görünürlüğü",
		category = 3,
		key = "voice_channels_visible",
		defaultValue = true,
		toggle = function()
			cachedSettings["voice_channels_visible"] = not cachedSettings["voice_channels_visible"]
		end,
		check = function()
			return cachedSettings["voice_channels_visible"] or defaultValue
		end,
	},
	["finance_update_visible"] = {
		name = "Finans Güncellemesi Görünürlüğü",
		category = 3,
		key = "finance_update_visible",
		defaultValue = true,
		toggle = function()
			cachedSettings["finance_update_visible"] = not cachedSettings["finance_update_visible"]
		end,
		check = function()
			return cachedSettings["finance_update_visible"] or defaultValue
		end,
	},
	["weapon_interface_visible"] = {
		name = "Silah Arayüzü Görünürlüğü",
		category = 3,
		key = "weapon_interface_visible",
		defaultValue = true,
		toggle = function()
			cachedSettings["weapon_interface_visible"] = not cachedSettings["weapon_interface_visible"]
		end,
		check = function()
			return cachedSettings["weapon_interface_visible"] or defaultValue
		end,
	},
	["vehicle_reflection"] = {
		name = "Araç Yansıması",
		category = 3,
		key = "vehicle_reflection",
		defaultValue = true,
		toggle = function()
			cachedSettings["vehicle_reflection"] = not cachedSettings["vehicle_reflection"]
			if cachedSettings["vehicle_reflection"] then
				exports["mek_vehicle-reflection"]:switchCarPaintRefLite(true)
			else
				exports["mek_vehicle-reflection"]:switchCarPaintRefLite(false)
			end
		end,
		check = function()
			return cachedSettings["vehicle_reflection"] or defaultValue
		end,
	},
}

for key, value in pairs(GLOBAL_SETTINGS) do
	initialSettings[key] = value.defaultValue
end

cachedSettings = initialSettings
