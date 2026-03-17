local function findHouse(house, source)
	if house then
		if getElementType(house) == "interior" then
			local entrance = getElementData(house, "entrance")
			local interiorExit = getElementData(house, "exit")

			return { entrance, interiorExit }
		elseif getElementType(house) == "elevator" then
			local elevatorEntrance = getElementData(house, "entrance")
			local elevatorExit = getElementData(house, "exit")

			if elevatorEntrance and elevatorExit then
				return {
					{
						x = elevatorEntrance[1],
						y = elevatorEntrance[2],
						z = elevatorEntrance[3],
						dim = elevatorEntrance[5],
					},
					{ x = elevatorExit[1], y = elevatorExit[2], z = elevatorExit[3], dim = elevatorExit[5] },
				}
			else
				return findHouse(nil, source)
			end
		else
			local found
			local minDistance = 20
			local pPosX, pPosY, pPosZ = getElementPosition(source)
			local dimension = getElementDimension(source)

			local possibleInteriors = exports.mek_pool:getPoolElementsByType("interior")
			for _, interior in ipairs(possibleInteriors) do
				local entrance = getElementData(interior, "entrance")
				local interiorExit = getElementData(interior, "exit")
				for _, point in ipairs({ entrance, interiorExit }) do
					if point.dim == dimension then
						local distance = getDistanceBetweenPoints3D(pPosX, pPosY, pPosZ, point.x, point.y, point.z)
							or 20
						if distance < minDistance then
							found = interior
							minDistance = distance
						end
					end
				end
			end

			if found then
				local entrance = getElementData(found, "entrance")
				local interiorExit = getElementData(found, "exit")

				return { entrance, interiorExit }
			end
		end
	end
	return nil
end

function playInteriorSound(eventName, house, source)
	local sentTo = {}
	for _, interiorElement in ipairs(findHouse(house, source) or {}) do
		for _, nearbyPlayer in ipairs(getElementsByType("player")) do
			if
				isElement(nearbyPlayer)
				and getElementData(nearbyPlayer, "logged")
				and not sentTo[nearbyPlayer]
			then
				if
					getDistanceBetweenPoints3D(
							interiorElement.x,
							interiorElement.y,
							interiorElement.z,
							getElementPosition(nearbyPlayer)
						)
						< 20
					and getElementDimension(nearbyPlayer) == interiorElement.dim
				then
					sentTo[nearbyPlayer] = true
					triggerClientEvent(
						nearbyPlayer,
						eventName,
						source,
						interiorElement.x,
						interiorElement.y,
						interiorElement.z
					)
				end
			end
		end
	end
end

function doorUnlockSound(house, source)
	playInteriorSound("doorUnlockSound", house, source)
end

function doorLockSound(house, source)
	playInteriorSound("doorLockSound", house, source)
end

function doorGoThru(house, source)
	playInteriorSound("doorGoThru", house, source)
end

function playerKnocking(house, source)
	playInteriorSound("playerKnock", house, source)
end
addEvent("onKnocking", true)
addEventHandler("onKnocking", root, function(house)
	playerKnocking(house, source)
end)

-- Interior Music System
function extractYouTubeId(url)
	if not url then return nil end
	
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

-- Handle play music event from client
addEvent("interior.playMusic", true)
addEventHandler("interior.playMusic", resourceRoot, function(interiorElement, interiorID, url, volume)
	if not interiorElement or not url or url == "" then
		return
	end
	
	local settings = getElementData(interiorElement, "settings") or {}
	local exit = getElementData(interiorElement, "exit")
	
	if not exit then
		return
	end
	
	volume = tonumber(volume) or 50
	volume = math.max(0, math.min(100, volume))
	
	-- Check if it's a YouTube URL
	if url:find("youtube%.com") or url:find("youtu%.be") then
		local videoId = extractYouTubeId(url)
		if videoId then
			-- Try to convert YouTube URL to direct audio stream
			-- Note: This requires a service or API to convert YouTube to audio
			-- For now, we'll use a placeholder approach
			-- You may need to implement a proper YouTube-to-audio conversion service
			
			-- Try using a service (this is a placeholder - you'll need a real service)
			local conversionUrl = "https://www.youtubeinmp3.com/fetch/?video=https://www.youtube.com/watch?v=" .. videoId
			
			-- For now, we'll just pass the YouTube URL and let the client handle it
			-- In a production environment, you'd want to use a proper API/service
			triggerClientEvent(
				client,
				"interior.playMusic",
				resourceRoot,
				url, -- Original YouTube URL
				volume,
				exit.x or exit[1],
				exit.y or exit[2],
				exit.z or exit[3],
				exit.dim or exit[5],
				exit.int or exit[4]
			)
			return
		end
	end
	
	-- For direct audio URLs, play immediately
	triggerClientEvent(
		client,
		"interior.playMusic",
		resourceRoot,
		url,
		volume,
		exit.x or exit[1],
		exit.y or exit[2],
		exit.z or exit[3],
		exit.dim or exit[5],
		exit.int or exit[4]
	)
end)

-- Handle YouTube URL conversion request
addEvent("interior.convertYouTubeUrl", true)
addEventHandler("interior.convertYouTubeUrl", resourceRoot, function(url, videoId)
	if not url or not videoId then
		return
	end
	
	-- This is a placeholder - in production, you'd use a proper YouTube-to-audio API
	-- For now, we'll return an error or use a service
	
	-- Example: You could use a service like:
	-- local conversionUrl = "https://api.example.com/convert?url=" .. url
	
	-- For now, we'll just return the original URL and let the client handle it
	-- In a real implementation, you'd fetch the direct audio URL from a service
	triggerClientEvent(
		client,
		"interior.youtubeUrlConverted",
		resourceRoot,
		url,
		nil, -- No converted URL available
		50,
		nil, nil, nil, nil, nil
	)
end)

-- Function to play music for players in interior
function playInteriorMusic(interiorElement, player)
	if not interiorElement then
		return
	end
	
	local settings = getElementData(interiorElement, "settings") or {}
	local musicUrl = settings.musicUrl
	local musicVolume = settings.musicVolume or 50
	
	if not musicUrl or musicUrl == "" then
		return
	end
	
	local exit = getElementData(interiorElement, "exit")
	if not exit then
		return
	end
	
	-- Trigger music for the player
	triggerClientEvent(
		player,
		"interior.playMusic",
		resourceRoot,
		musicUrl,
		musicVolume,
		exit.x or exit[1],
		exit.y or exit[2],
		exit.z or exit[3],
		exit.dim or exit[5],
		exit.int or exit[4]
	)
end

-- Function to stop music for players leaving interior
function stopInteriorMusic(player)
	if player and isElement(player) then
		triggerClientEvent(player, "interior.stopMusic", resourceRoot)
	end
end
