_streams = {}

local isTalkingRadio = false

local beepOnSound, beepOffSound

local function destroyEntityStream(player)
	if isElement(player) then
		setSoundVolume(player, 0)
	end
	_streams[player] = nil
end

local function playRadioBeep(type)
	if type == "on" then
		if isElement(beepOnSound) then
			destroyElement(beepOnSound)
		end

		beepOnSound = playSound("public/sounds/beep_on.wav", false)
		setSoundVolume(beepOnSound, 0.2)
	elseif type == "off" then
		if isElement(beepOffSound) then
			destroyElement(beepOffSound)
		end

		beepOffSound = playSound("public/sounds/beep_off.wav", false)
		setSoundVolume(beepOffSound, 0.2)
	end
end

function renderStreams()
	if _voiceStatus == VoiceStatus.DISABLED or _voiceStatus == VoiceStatus.ADMIN_ONLY then
		return false
	end

	local localPosition = localPlayer.position

	talkingPlayers = {}

	local hasRadio, localRadioFrequency =
		exports.mek_item:hasItem(localPlayer, 6), localPlayer:getData("radio_frequency")

	each(_streams, function(player)
		if not isElement(player) or not player:getData("logged") then
			destroyEntityStream(player)
			return
		end

		local channel = player:getData("voice_channel") or VoiceChannel.NEAR
		local distance = getDistanceBetweenPoints3D(localPosition, player.position)

		local callingPlayer = player:getData("call") and player:getData("call").player
		local amICallWithTarget = callingPlayer and callingPlayer == localPlayer

		if amICallWithTarget then
			distance = 1
		end

		local isRadioConnected = false
		local isLocalRadioActive = localPlayer:getData("radio_active")

		if hasRadio and localRadioFrequency and isLocalRadioActive then
			local playerRadioFrequency = player:getData("radio_frequency")
			local isPlayerRadioActive = player:getData("radio_active")

			if playerRadioFrequency and isPlayerRadioActive and localRadioFrequency == playerRadioFrequency then
				isRadioConnected = true
				distance = 1
			end
		end

		local contactName = player:getData("call") and player:getData("call").contactName or "Bilinmeyen Numara"

		if voiceChannels[channel].distance == INFINITE or distance <= voiceChannels[channel].voiceDistance then
			local text = exports.mek_global:getPlayerName(player)
				.. " ("
				.. player:getData("id")
				.. ") ("
				.. math.floor(distance)
				.. "m)"

			if channel == VoiceChannel.ADMIN then
				if exports.mek_integration:isPlayerTrialAdmin(player) then
					text = player:getData("account_username") .. " tüm yetkililere konuşuyor."
				end
			elseif channel == VoiceChannel.GLOBAL then
				text = player:getData("account_username") .. " tüm oyunculara konuşuyor."
			elseif player == localPlayer then
				text = "Sen"
			elseif amICallWithTarget then
				text = contactName .. " seninle telefonda konuşuyor."
			elseif isRadioConnected then
				text = "Birisi telsizden konuşuyor."
			end

			table.insert(talkingPlayers, {
				player = player,
				distance = voiceChannels[channel].distance == INFINITE and 0 or distance,
				text = text,
			})
		end

		if voiceChannels[channel].distance == INFINITE then
			local canHear = voiceChannels[channel].canHear(localPlayer)
			if not canHear then
				destroyEntityStream(player)
				return
			end

			setSoundVolume(player, 8)
			return
		end

		local maxDistance = voiceChannels[channel].distance or 10
		local distanceDiff = maxDistance - distance
		local volume = math.exp(-distance * (4 / distanceDiff)) * 8

		if distance > maxDistance and not amICallWithTarget and not isRadioConnected then
			volume = 0
		end

		if getSoundVolume(player) ~= volume then
			setSoundVolume(player, volume)
		end

		if getSoundPan(player) ~= 0 then
			setSoundPan(player, 0)
		end
	end)

	table.sort(talkingPlayers, function(a, b)
		return a.distance < b.distance
	end)
end

function renderStreamUI()
	if _voiceStatus == VoiceStatus.DISABLED then
		return false
	end

	if not localPlayer:getData("logged") then
		return false
	end

	each(talkingPlayers, function(key, data)
		local text = data.text
		local distance = data.distance
		local font = fonts.ProximaNovaBold.h6
		local textWidth = dxGetTextWidth(text, 1, font) + 20

		local color = theme.GRAY[100]
		if distance > 3 and distance < 5 then
			color = theme.GRAY[200]
		elseif distance > 5 and distance < 11 then
			color = theme.GRAY[300]
		elseif distance > 11 and distance < 14 then
			color = theme.GRAY[400]
		elseif distance > 14 and distance < 17 then
			color = theme.GRAY[500]
		elseif distance > 17 and distance < 21 then
			color = theme.GRAY[600]
		elseif distance > 21 and distance < 24 then
			color = theme.GRAY[700]
		elseif distance > 24 then
			color = theme.GRAY[800]
		end

		local paddingY = localPlayer:getData("call") and 60 or 0
		paddingY = paddingY + (localPlayer.vehicle and 10 or 0)

		local textPosition = {
			x = screenSize.x - textWidth - 20,
			y = screenSize.y - (50 + paddingY) - (key * 25),
		}

		dxDrawFramedText(
			text,
			textPosition.x,
			textPosition.y,
			textPosition.x + textWidth,
			textPosition.y + 25,
			rgba(color, 1),
			1,
			font,
			"right",
			"top"
		)
	end)
end

addEvent("voice.radio.beep", true)
addEventHandler("voice.radio.beep", root, function(type)
	playRadioBeep(type)
end)

addEventHandler("onClientPlayerVoiceStart", root, function()
	if _streams[source] then
		return false
	end

	if not source:getData("logged") then
		cancelEvent()
		return false
	end

	if _voiceStatus == VoiceStatus.DISABLED then
		cancelEvent()
		return false
	end

	local channel = source:getData("voice_channel") or VoiceChannel.NEAR

	local hasLocalRadio, localRadioFrequency =
		exports.mek_item:hasItem(localPlayer, 6), localPlayer:getData("radio_frequency")
	local isLocalRadioActive = localPlayer:getData("radio_active")

	if source == localPlayer and isLocalRadioActive and localRadioFrequency then
		if not isTalkingRadio then
			isTalkingRadio = true
			triggerServerEvent("voice.radio.beep", localPlayer, "on", localRadioFrequency)
		end
	end

	_streams[source] = true
end, true, "low-5555")

addEventHandler("onClientPlayerVoiceStop", root, function()
	local localRadioFrequency = localPlayer:getData("radio_frequency")

	if source == localPlayer and localPlayer:getData("radio_active") and localRadioFrequency then
		if isTalkingRadio then
			isTalkingRadio = false
			triggerServerEvent("voice.radio.beep", localPlayer, "off", localRadioFrequency)
		end
	end

	_streams[source] = nil
	destroyEntityStream(source)
end, true, "low-5555")

function isEntityTalking(player)
	return _streams[player]
end
