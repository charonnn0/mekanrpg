_getPlayerName = getPlayerName

local allowedImageHosts = {
	["i.imgur.com"] = true,
}

local imageExtensions = {
	[".jpg"] = true,
	[".jpeg"] = true,
	[".png"] = true,
}

function generateSalt(length)
	local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	local salt = ""
	for i = 1, length do
		local rand = math.random(#chars)
		salt = salt .. chars:sub(rand, rand)
	end
	return salt
end

function isImageURL(url)
	if string.find(url, "http://", 1, true) or string.find(url, "https://", 1, true) then
		local domain = url:match("[%w%.]*%.[%w%.]*%.(%w+%.%w+)") or url:match("^%w+://([^/]+)")
		if allowedImageHosts[domain] then
			local _extensions = ""
			for extension, _ in pairs(imageExtensions) do
				if _extensions ~= "" then
					_extensions = _extensions .. ", " .. extension
				else
					_extensions = extension
				end
				if string.find(url, extension, 1, true) then
					return true
				end
			end
		end
	end
	return false
end

function round(val, decimal)
	if decimal then
		return math.floor((val * 10 ^ decimal) + 0.5) / (10 ^ decimal)
	end
	return math.floor(val + 0.5)
end

function getPlayerName(thePlayer)
	local playerName = _getPlayerName(thePlayer):gsub("_", " ")
	if getElementData(thePlayer, "mask") then
		playerName = "Gizli [>" .. getElementData(thePlayer, "dbid") .. "]"
	end
	return playerName
end

function generateIdentityNumber()
    local digits = {}

    digits[1] = math.random(1, 9)

    for i = 2, 9 do
        digits[i] = math.random(0, 9)
    end

    local oddSum = digits[1] + digits[3] + digits[5] + digits[7] + digits[9]
    local evenSum = digits[2] + digits[4] + digits[6] + digits[8]

    digits[10] = ((7 * oddSum) - evenSum) % 10

    local totalSum = 0
    for i = 1, 10 do
        totalSum = totalSum + digits[i]
    end

    digits[11] = totalSum % 10

    local identityNumber = ""
    for i = 1, 11 do
        identityNumber = identityNumber .. digits[i]
    end

    return identityNumber
end

function formatWeight(kg)
	kg = tonumber(kg)
	if kg < 1000 then
		return round(kg, 2) .. " kg"
	else
		return round(kg / 1000, 2) .. " ton"
	end
end

function formatLength(meters)
	meters = tonumber(meters) or 0
	if meters >= 1000 then
		return round(meters / 1000, 2) .. " km"
	else
		return round(meters, 2) .. " metre"
	end
end
