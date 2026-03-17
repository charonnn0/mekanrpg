local gameType = {
	current = 1,
	messages = {
		"█ Gerçekçi Oyun Deneyimi!",
		"█ Hikâyeni Kur, Karakterini Yaşat!",
		"█ Topluluk Odaklı Oyun!",
		"█ Kendi Hikâyeni Yaz, Efsane Ol!",
		"█ Mekan Game",
		"█ Yeniliklerle Dolu Bir Dünya Seni Bekliyor!",
	},
	displayInterval = 1000 * 5,
}

local function updateGameTypeMessage()
	gameType.current = (gameType.current % #gameType.messages) + 1
	setGameType(gameType.messages[gameType.current])
end

setTimer(updateGameTypeMessage, gameType.displayInterval, 0)
updateGameTypeMessage()
