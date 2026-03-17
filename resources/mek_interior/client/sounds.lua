addEvent("playerKnock", true)
addEventHandler("playerKnock", root, function(x, y, z)
	outputChatBox("* Kapıdan tıkırtılar geliyor. ((" .. getPlayerName(source):gsub("_", " ") .. "))", 255, 51, 102)
	local sound = playSound3D("public/sounds/knocking.mp3", x, y, z)
	setSoundMaxDistance(sound, 20)
	setElementDimension(sound, getElementDimension(localPlayer))
	setElementInterior(sound, getElementInterior(localPlayer))
end)

addEvent("doorUnlockSound", true)
addEventHandler("doorUnlockSound", root, function(x, y, z)
	local sound = playSound3D("public/sounds/doorUnlockSound.mp3", x, y, z)
	setSoundMaxDistance(sound, 20)
	setElementDimension(sound, getElementDimension(localPlayer))
	setElementInterior(sound, getElementInterior(localPlayer))
end)

addEvent("doorLockSound", true)
addEventHandler("doorLockSound", root, function(x, y, z)
	local sound = playSound3D("public/sounds/doorLockSound.mp3", x, y, z)
	setSoundMaxDistance(sound, 20)
	setElementDimension(sound, getElementDimension(localPlayer))
	setElementInterior(sound, getElementInterior(localPlayer))
end)

addEvent("doorGoThru", true)
addEventHandler("doorGoThru", root, function(x, y, z)
	local sound = playSound3D("public/sounds/doorGoThru.mp3", x, y, z)
	setSoundMaxDistance(sound, 20)
	setElementDimension(sound, getElementDimension(localPlayer))
	setElementInterior(sound, getElementInterior(localPlayer))
	setSoundVolume(sound, 0.5)
end)

-- Interior Music System
local interiorMusic = nil
local currentInteriorMusic = nil

-- Function to extract YouTube video ID
local function extractYouTubeId(url)
	if not url then return nil end
	
	-- Match various YouTube URL formats
	local patterns = {
		"youtube%.com/watch%?v=([^&]+)",
		"youtu%.be/([^?]+)",
		"youtube%.com/embed/([^?]+)",
		"youtube%.com/v/([^?]+)"
	}
	
	for _, pattern in ipairs(patterns) do
		local id = url:match(pattern)
		if id then
			return id
		end
	end
	
	return nil
end

-- Function to convert YouTube URL to direct audio stream
local function convertYouTubeUrl(url)
	local videoId = extractYouTubeId(url)
	if not videoId then
		return nil
	end
	
	-- Use a service to get direct audio URL
	-- Note: This is a placeholder - you may need to use a different service
	-- or implement server-side conversion
	-- For now, we'll try to use a direct stream service
	local audioUrl = "https://www.youtube.com/watch?v=" .. videoId
	
	-- Try to fetch direct stream URL via server
	triggerServerEvent("interior.convertYouTubeUrl", resourceRoot, url, videoId)
	
	return nil -- Will be handled via server response
end

-- Event to play interior music
addEvent("interior.playMusic", true)
addEventHandler("interior.playMusic", root, function(url, volume, x, y, z, dimension, interior)
	if not url or url == "" then
		return
	end
	
	-- Stop current music if playing
	if interiorMusic and isElement(interiorMusic) then
		stopSound(interiorMusic)
		interiorMusic = nil
	end
	
	volume = tonumber(volume) or 50
	volume = math.max(0, math.min(100, volume)) / 100 -- Convert to 0-1 range
	
	local audioUrl = url
	
	-- Check if it's a YouTube URL
	if url:find("youtube%.com") or url:find("youtu%.be") then
		local videoId = extractYouTubeId(url)
		if videoId then
			-- For YouTube, try to use a conversion service
			-- Note: MTA doesn't support YouTube URLs directly
			-- You'll need to use a service that converts YouTube to direct audio streams
			-- For now, we'll try to use a simple approach
			-- Try using a service URL (this is a placeholder - you may need a real service)
			local conversionServiceUrl = "https://www.youtubeinmp3.com/fetch/?format=JSON&video=https://www.youtube.com/watch?v=" .. videoId
			
			-- Try to fetch the direct URL
			-- Note: YouTube conversion services may not always work
			-- For best results, use direct audio URLs (mp3, wav, etc.)
			fetchRemote(conversionServiceUrl, function(data, errno, originalUrl, vol, posX, posY, posZ, dim, int)
				if errno == 0 and data then
					local success, jsonData = pcall(fromJSON, data)
					if success and jsonData and jsonData.link then
						-- Use the converted URL
						playMusicWithUrl(jsonData.link, vol, posX, posY, posZ, dim, int)
					else
						-- Fallback: show error message
						exports.mek_infobox:addBox("error", "YouTube URL dönüştürülemedi. Lütfen doğrudan bir ses URL'si kullanın (örn: .mp3, .wav) veya YouTube URL'sini manuel olarak dönüştürün.")
					end
				else
					exports.mek_infobox:addBox("error", "YouTube URL dönüştürülemedi. Lütfen doğrudan bir ses URL'si kullanın (örn: .mp3, .wav).")
				end
			end, "", false, url, volume, x, y, z, dimension, interior)
			return
		end
	end
	
	playMusicWithUrl(audioUrl, volume, x, y, z, dimension, interior)
end)

-- Helper function to play music with URL
function playMusicWithUrl(audioUrl, volume, x, y, z, dimension, interior)
	
	-- Play the sound
	if x and y and z then
		-- 3D sound at specific position
		interiorMusic = playSound3D(audioUrl, x, y, z, true)
		if interiorMusic and isElement(interiorMusic) then
			setSoundMaxDistance(interiorMusic, 50)
			setSoundVolume(interiorMusic, volume)
			setElementDimension(interiorMusic, dimension or getElementDimension(localPlayer))
			setElementInterior(interiorMusic, interior or getElementInterior(localPlayer))
			setSoundLooped(interiorMusic, true)
		end
	else
		-- 2D sound (background music)
		interiorMusic = playSound(audioUrl, true)
		if interiorMusic and isElement(interiorMusic) then
			setSoundVolume(interiorMusic, volume)
			setSoundLooped(interiorMusic, true)
		end
	end
	
	currentInteriorMusic = {
			url = audioUrl,
		volume = volume,
		element = interiorMusic
	}
end

-- Event to stop interior music
addEvent("interior.stopMusic", true)
addEventHandler("interior.stopMusic", root, function()
	if interiorMusic and isElement(interiorMusic) then
		stopSound(interiorMusic)
		interiorMusic = nil
	end
	currentInteriorMusic = nil
end)

-- Handle YouTube URL conversion response
addEvent("interior.youtubeUrlConverted", true)
addEventHandler("interior.youtubeUrlConverted", root, function(originalUrl, audioUrl, volume, x, y, z, dimension, interior)
	if not audioUrl or audioUrl == "" then
		exports.mek_infobox:addBox("error", "YouTube URL dönüştürülemedi. Lütfen doğrudan bir ses URL'si kullanın.")
		return
	end
	
	-- Play the converted audio
	triggerEvent("interior.playMusic", root, audioUrl, volume, x, y, z, dimension, interior)
end)

-- Check for music when entering interior
addEventHandler("onClientPlayerInteriorChange", localPlayer, function(oldInterior, newInterior)
	-- Stop music when leaving interior
	if oldInterior > 0 and newInterior == 0 then
		if interiorMusic and isElement(interiorMusic) then
			stopSound(interiorMusic)
			interiorMusic = nil
		end
		currentInteriorMusic = nil
	end
end)

addEventHandler("onClientPlayerDimensionChange", localPlayer, function(oldDimension, newDimension)
	-- Stop music when leaving interior dimension
	if oldDimension > 0 and newDimension == 0 then
		if interiorMusic and isElement(interiorMusic) then
			stopSound(interiorMusic)
			interiorMusic = nil
		end
		currentInteriorMusic = nil
	end
end)
