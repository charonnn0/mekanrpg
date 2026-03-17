VoiceChannel = {
	NEAR = 1,
	SHOUT = 2,
	WHISPER = 3,
	RADIO = 4,
	GLOBAL = 5,
	ADMIN = 6,
}

VoiceStatus = {
	DISABLED = 0,
	ADMIN_ONLY = 1,
	ENABLED = 2,
}

INFINITE = -1

_voiceStatus = VoiceStatus.ENABLED

voiceChannels = {
	[VoiceChannel.NEAR] = {
		name = "Yakın",
		icon = "",
		distance = 20,
		voiceDistance = 14,

		canSwitch = function(player)
			return true
		end,
	},
	[VoiceChannel.SHOUT] = {
		name = "Bağır",
		icon = "",
		distance = 55,
		voiceDistance = 21,

		canSwitch = function(player)
			return _voiceStatus == VoiceStatus.ENABLED
		end,
	},
	[VoiceChannel.WHISPER] = {
		name = "Fısılda",
		icon = "",
		distance = 5,
		voiceDistance = 3,

		canSwitch = function(player)
			return _voiceStatus == VoiceStatus.ENABLED
		end,
	},
	[VoiceChannel.GLOBAL] = {
		name = "Global (Herkes)",
		icon = "",
		distance = INFINITE,
		voiceDistance = INFINITE,

		canSwitch = function(player)
			return exports.mek_integration:isPlayerServerOwner(player)
		end,
		canHear = function(player)
			return player:getData("logged")
		end,
	},
	[VoiceChannel.ADMIN] = {
		name = "Yetkili (Herkes)",
		icon = "",
		distance = INFINITE,
		voiceDistance = INFINITE,

		canSwitch = function(player)
			return exports.mek_integration:isPlayerManager(player)
		end,
		canHear = function(player)
			return exports.mek_integration:isPlayerTrialAdmin(player) or exports.mek_integration:isPlayerManager(player)
		end,
	},
}
