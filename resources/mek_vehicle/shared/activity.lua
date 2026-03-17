PARKING_ZONES = {
	{
		commandZone = { x = 1643.2939453125, y = -1523.0244140625, z = 13.559455871582, radius = 5 },
		spawnZone = { x = 1643.1396484375, y = -1526.55859375, z = 13.559831619263, rotation = 180 },
	},
	{
		commandZone = { x = 1636.2939453125, y = -1523.0244140625, z = 13.559455871582, radius = 5 },
		spawnZone = { x = 1636.1396484375, y = -1526.55859375, z = 13.559831619263, rotation = 180 },
	},
	{
		commandZone = { x = 1580.6689453125, y = -1414.3896484375, z = 13.566501617432, radius = 5 },
		spawnZone = { x = 1585.580078125, y = -1414.3896484375, z = 13.620475769043, rotation = 270 },
	},
	{
		commandZone = { x = 417.9228515625, y = -1729.3291015625, z = 9.3722705841064, radius = 5 },
		spawnZone = { x = 418.154296875, y = -1722.470703125, z = 9.197208404541, rotation = 0 },
	},
	{
		commandZone = { x = 853.1767578125, y = -1662.4384765625, z = 13.5546875, radius = 5 },
		spawnZone = { x = 860.73046875, y = -1662.271484375, z = 13.546875, rotation = 270 },
	},
	{
		commandZone = { x = 1048.4033203125, y = -1550.0908203125, z = 13.5546875, radius = 5 },
		spawnZone = { x = 1043.8125, y = -1549.373046875, z = 13.547772407532, rotation = 80 },
	},
}

function getElementParkingZone(element)
	local elementX, elementY, elementZ = getElementPosition(element)
	for _, parkingArea in ipairs(PARKING_ZONES) do
		local commandZoneData = parkingArea.commandZone
		if
			commandZoneData
			and commandZoneData.x
			and commandZoneData.y
			and commandZoneData.z
			and commandZoneData.radius
		then
			local dist = getDistanceBetweenPoints3D(
				elementX,
				elementY,
				elementZ,
				commandZoneData.x,
				commandZoneData.y,
				commandZoneData.z
			)
			if dist <= commandZoneData.radius then
				return true, parkingArea
			end
		end
	end
	return false, false
end

function isActive(vehicle)
	local job = getElementData(vehicle, "job") or 0
	local owner = getElementData(vehicle, "owner") or -1
	local faction = getElementData(vehicle, "faction") or -1

	if job ~= 0 or owner <= 0 or faction ~= -1 then
		return true
	end

	if getVehicleType(vehicle) == "Trailer" then
		return true
	end

	local oneDay = 60 * 60 * 24
	local ownerLastLogin = getElementData(vehicle, "owner_last_login")
	if ownerLastLogin and tonumber(ownerLastLogin) then
		local ownerLastLoginText, ownerLastLoginSec = exports.mek_datetime:formatTimeInterval(ownerLastLogin)
		if ownerLastLoginSec > oneDay * 30 then
			return false,
				"Aktif olmayan araç | Sahibi " .. ownerLastLoginText .. " boyunca oyuna girmemiş.",
				ownerLastLoginSec
		end
	end

	local interior = getElementInterior(vehicle)
	local dimension = getElementDimension(vehicle)

	if interior == 0 and dimension == 0 then
		local lastUsed = getElementData(vehicle, "last_used")
		if lastUsed and tonumber(lastUsed) then
			local lastUsedText, lastUsedSec = exports.mek_datetime:formatTimeInterval(lastUsed)
			if lastUsedSec > oneDay * 14 then
				return false, "Aktif olmayan araç | " .. lastUsedText .. " önce mülkde bırakılmış.", lastUsedSec
			end
		end
	end

	return true
end
