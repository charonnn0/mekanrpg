screenSize = Vector2(guiGetScreenSize())

fonts = useFonts()
theme = useTheme()

streamingQueue = nil

voiceChannels[VoiceChannel.RADIO] = {
    name = "Telsiz",
    icon = "",
    distance = INFINITE,
    voiceDistance = INFINITE,

    canSwitch = function(player)
        return true
    end,
    canHear = function(player)
        return player:getData("radio_active")
    end,
}

local function checkAndStartTimers()
    if _voiceStatus ~= VoiceStatus.DISABLED then
        if not isTimer(renderStreamTimer) then
            renderStreamTimer = setTimer(renderStreams, 0, 0)
        end

        if not isTimer(renderStreamUITimer) then
            renderStreamUITimer = setTimer(renderStreamUI, 0, 0)
        end
    end
end

local function setAllPlayersVolume(volume)
    local allPlayers = getElementsByType("player")
    for _, player in ipairs(allPlayers) do
        setSoundVolume(player, volume)
    end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    _voiceStatus = VoiceStatus.ENABLED
    checkAndStartTimers()
    setAllPlayersVolume(0)
    setEntityChannel(VoiceChannel.NEAR)
	triggerServerEvent("voice.radio.initState", localPlayer)
end)
