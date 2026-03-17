PRISONER_STATUS = {
	Awaiting = "Bekleniyor",
	Release = "Özgür",
	LifeTime = "Müebbet",
	Sentence = "Hapiste",
	OnlineTime = "Çevrimiçi Zaman",
}

pd_offline_jail = true
pd_update_access = 1
hourLimit = 0
onlineRatio = 0.1
offlineRatio = 0.9

gateDim = 880
gateInt = 3
objectID = 2930

speakerDimensions = {
	[812] = true,
	[851] = true,
	[857] = true,
	[861] = true,
	[862] = true,
	[880] = true,
	[881] = true,
	[882] = true,
}
speakerInt = 3
speakerOutX, speakerOutY, speakerOutZ = -1046.16015625, -723.65625, 32.0078125

bMale = 305
bMaleID = 1109
wMale = 305
wMaleID = 1110
aMale = 305
aMaleID = 1110

bFemale = 69
bFemaleID = 1111
wFemale = 69
wFemaleID = 1112
aFemale = 69
aFemaleID = 1112

cells = {
	-- [codeName] = x, y, z, int, dim, 1 = OnlineTimer - 0 = OfflineTimer, locationCode
	["1A"] = { 1792.890625, -1571.888671875, -3.6852498054504, 0, 0, type = 1, location = "Prison" },
	["2A"] = { 1792.890625, -1571.888671875, -3.6852498054504, 0, 0, type = 1, location = "Prison" },
	["3A"] = { 1792.890625, -1571.888671875, -3.6852498054504, 0, 0, type = 1, location = "Prison" },
	["4A"] = { 1792.890625, -1571.888671875, -3.6852498054504, 0, 0, type = 1, location = "Prison" },
}

arrestCols = {
	-- x, y, z, radius, int, dim
	["Prison"] = { 214.94140625, 114.5361328125, 999.015625, 12, 10, 6 },
	["Prison2 JGK"] = { 322.0966796875, 315.27734375, 999.1484375, 12, 5, 322 }, 
	["Prison3 JGK"] = { 322.1572265625, 315.6796875, 999.1484375, 12, 5, 320 }, 
}

releaseLocations = {
	-- x, y, z, int, dim
	["Prison"] = { 1808.818359375, -1575.9111328125, 13.482364654541, 0, 0 },
}

gates = {
	-- ["cell"] = { openx, openy, openz, openRx, openRy, openRz, closedx, closedy, closedz, closedRx, closedRy, closedRz }
	["1A"] = { 1047.1, 1253.2, 1493, 0, 0, 0, 1047.1, 1254.9, 1493, 0, 0, 0 },
	["2A"] = { 1047.1, 1244.7, 1493, 0, 0, 0, 1047.1, 1246.4, 1493, 0, 0, 0 },
	["3A"] = { 1047.1, 1239.7, 1493, 0, 0, 0, 1047.1, 1241.4, 1493, 0, 0, 0 },
	["4A"] = { 1047.1, 1234.7, 1493, 0, 0, 0, 1047.1, 1236.4, 1493, 0, 0, 0 },
}

local temp = {}
for key, value in pairs(arrestCols) do
	local sphere = createColSphere(value[1], value[2], value[3], value[4])
	setElementDimension(sphere, value[6])
	setElementInterior(sphere, value[5])
	setElementData(sphere, "location", key)
	temp[key] = sphere
end
arrestCols = temp
temp = nil

function isCloseTo(thePlayer, targetPlayer)
	if exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
		return true
	end

	if exports.mek_faction:isPlayerInFaction(thePlayer, pd_update_access) then
		return true
	end

	if targetPlayer then
		local dx, dy, dz = getElementPosition(thePlayer)
		local dx1, dy1, dz1 = getElementPosition(targetPlayer)
		if getDistanceBetweenPoints3D(dx, dy, dz, dx1, dy1, dz1) < 30 then
			if getElementDimension(thePlayer) == getElementDimension(targetPlayer) then
				return true
			end
		end
	end
	return false
end

function isInArrestColshape(thePlayer)
	for key, value in pairs(arrestCols) do
		if
			isElementWithinColShape(thePlayer, value) and (getElementDimension(thePlayer) == getElementDimension(value))
		then
			return key
		end
	end

	return false
end

function getCells(arrestLocation)
	local temp = {}
	for key, value in pairs(cells) do
		if value.location == arrestLocation then
			temp[key] = value
		end
	end
	return temp
end

function cleanMath(number)
	if type(number) == "boolean" then
		return
	end

	local realTime = getRealTime()
	local currentTime = realTime.timestamp
	local remainingTime = tonumber(number) - currentTime
	local hours = (remainingTime / 3600)
	local days = math.floor(hours / 24)
	local remainingHours = hours - days * 24
	local hours = ("%.1f"):format(hours - days * 24)

	if remainingTime < 0 then
		return PRISONER_STATUS.Awaiting, PRISONER_STATUS.Release, tonumber(remainingTime)
	end

	if days > 999 then
		return PRISONER_STATUS.LifeTime, PRISONER_STATUS.Sentence, tonumber(remainingTime)
	end

	return days, hours, tonumber(remainingTime)
end
