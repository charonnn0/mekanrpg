addEvent("voice.stream.update", true)
addEventHandler("voice.stream.update", root, function(newStreams)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	setPlayerVoiceIgnoreFrom(client, nil)
	setPlayerVoiceBroadcastTo(client, newStreams)
end)

addEvent("voice.setChannel", true)
addEventHandler("voice.setChannel", root, function(channel)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not channel then
		return
	end

	if not voiceChannels[channel].canSwitch(client) then
		return
	end

	setElementData(client, "voice_channel", channel)
end)

addEvent("voice.radio.initState", true)
addEventHandler("voice.radio.initState", root, function()
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	source:setData("radio_active", false)
end)

addEvent("voice.radio.toggleState", true)
addEventHandler("voice.radio.toggleState", root, function()
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	local current = source:getData("radio_active") or false
	source:setData("radio_active", not current)
end)

addEvent("voice.radio.beep", true)
addEventHandler("voice.radio.beep", root, function(beepType, frequency)
	if not client or not beepType or not frequency then
		return
	end

	for _, player in ipairs(getElementsByType("player")) do
		if player:getData("radio_active") and player:getData("radio_frequency") == frequency then
			triggerClientEvent(player, "voice.radio.beep", resourceRoot, beepType)
		end
	end
end)

if isVoiceEnabled() then
	local playerChannels = {}
	local channels = {}

	addEventHandler("onPlayerJoin", root, function()
		setPlayerVoiceBroadcastTo(source, getElementsByType("player"))
		setPlayerInternalChannel(source, root)
	end)

	addEventHandler("onResourceStart", resourceRoot, function()
		refreshPlayers()
		setTimer(refreshPlayers, 1000 * 60, 0)
	end)

	function refreshPlayers()
		for _, player in ipairs(getElementsByType("player")) do
			setPlayerInternalChannel(player, root)
		end
	end

	function setPlayerInternalChannel(player, element)
		if playerChannels[player] == element then
			return false
		end
		playerChannels[player] = element
		channels[element] = player
		setPlayerVoiceBroadcastTo(player, element)
		return true
	end
end

function setVoice(thePlayer, commandName, targetPlayer, channel)
	if exports.mek_integration:isPlayerManager(thePlayer) then
		if targetPlayer and channel and tonumber(channel) then
			channel = tonumber(math.floor(channel))
			if channel > 0 and channel <= #voiceChannels then
				if targetPlayer == "all" then
					for _, player in ipairs(getElementsByType("player")) do
						if getElementData(player, "logged") then
							setElementData(player, "voice_channel", channel)
						end
					end
					outputChatBox(
						"[!]#FFFFFF Başarıyla tüm oyuncuların konuşma kanalı ["
							.. channel
							.. "] olarak ayarlandı.",
						thePlayer,
						0,
						255,
						0,
						true
					)
				else
					local targetPlayer, targetPlayerName =
						exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
					if targetPlayer then
						if getElementData(targetPlayer, "logged") then
							setElementData(targetPlayer, "voice_channel", channel)
							outputChatBox(
								"[!]#FFFFFF Başarıyla "
									.. targetPlayerName
									.. " isimli oyuncunun konuşma kanalı ["
									.. channel
									.. "] olarak ayarlandı.",
								thePlayer,
								0,
								255,
								0,
								true
							)
							outputChatBox(
								"[!]#FFFFFF "
									.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
									.. " isimli yetkili konuşma kanalınızı ["
									.. channel
									.. "] olarak ayarladı.",
								targetPlayer,
								0,
								0,
								255,
								true
							)
						else
							outputChatBox(
								"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
								thePlayer,
								255,
								0,
								0,
								true
							)
						end
					end
				end
			else
				outputChatBox("[!]#FFFFFF Bu sayıya ait bir konuşma kanalı bulunmuyor.", thePlayer, 255, 0, 0, true)
			end
		else
			outputChatBox(
				"Kullanım: /" .. commandName .. " [Karakter Adı / ID] [1-" .. #voiceChannels .. "]",
				thePlayer,
				255,
				194,
				14
			)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("setvoice", setVoice, false, false)
