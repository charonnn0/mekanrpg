function now()
	local delta = getRealTime().timestamp - lastTime
	return serverCurrentTimeSec + math.floor(delta)
end

local function formatUnit(value, unit)
	if value <= 0 then
		return ""
	end
	return value .. " " .. unit
end

function formatTimeInDigits(timeInSeconds)
	if type(timeInSeconds) ~= "number" then
		return timeInSeconds, 0
	end

	local diff = now() - timeInSeconds
	if diff < 1 then
		return "Şimdi", 0
	end

	local s = diff % 60
	local m = math.floor(diff / 60) % 60
	local h = math.floor(diff / 3600) % 24
	local d = math.floor(diff / 86400)

	if d > 0 then
		return string.format("%02d:%02d:%02d:%02d", d, h, m, s), diff
	elseif h > 0 then
		return string.format("%02d:%02d:%02d", h, m, s), diff
	elseif m > 0 then
		return string.format("%02d:%02d", m, s), diff
	else
		return "00:" .. string.format("%02d", s), diff
	end
end

function formatTimeShortInterval(timeInSeconds)
	if type(timeInSeconds) ~= "number" then
		return timeInSeconds, 0
	end

	local diff = now() - timeInSeconds
	if diff < 1 then
		return "Şimdi", 0
	end

	if diff < 60 then
		return diff .. " sn", diff .. "sn"
	end
	local m = math.floor(diff / 60)
	if m < 60 then
		return m .. " dk", m .. "dk"
	end
	local h = math.floor(m / 60)
	if h < 48 then
		return h .. " saat", h .. "sa"
	end
	local d = math.floor(h / 24)
	return d .. " gün", d .. "gün"
end

function formatTimeInterval(timeInSeconds)
	if type(timeInSeconds) ~= "number" then
		return timeInSeconds, 0
	end

	local diff = now() - timeInSeconds
	if diff < 1 then
		return "Şimdi", 0
	end

	local s = diff % 60
	local m = math.floor(diff / 60) % 60
	local h = math.floor(diff / 3600) % 24
	local d = math.floor(diff / 86400)

	local parts = {}
	if d > 0 then
		table.insert(parts, formatUnit(d, "gün"))
	end
	if h > 0 then
		table.insert(parts, formatUnit(h, "saat"))
	end
	if m > 0 then
		table.insert(parts, formatUnit(m, "dakika"))
	end
	if s > 0 and #parts == 0 then
		table.insert(parts, formatUnit(s, "saniye"))
	end

	return table.concat(parts, " ") .. " önce", diff
end

function formatFutureTimeInterval(timeInSeconds)
	if type(timeInSeconds) ~= "number" then
		return timeInSeconds, 0
	end

	local diff = timeInSeconds - now()
	if diff < 0 then
		return "0s", 0
	end

	local s = diff % 60
	local m = math.floor(diff / 60) % 60
	local h = math.floor(diff / 3600) % 24
	local d = math.floor(diff / 86400)

	local parts = {}
	if d > 0 then
		table.insert(parts, formatUnit(d, "gün"))
	end
	if h > 0 then
		table.insert(parts, formatUnit(h, "saat"))
	end
	if m > 0 then
		table.insert(parts, formatUnit(m, "dakika"))
	end
	if s > 0 and #parts == 0 then
		table.insert(parts, formatUnit(s, "saniye"))
	end

	return table.concat(parts, " "), diff
end

function formatGiveDays(timeInSeconds)
	if type(timeInSeconds) ~= "number" then
		return false
	end

	local diff = now() - timeInSeconds
	if diff < 172800 then
		return false
	end

	return math.floor(diff / 86400)
end

function formatSeconds(seconds)
	if type(seconds) ~= "number" then
		return seconds
	end

	if seconds <= 0 then
		return "Şimdi"
	end

	local s = seconds % 60
	local m = math.floor(seconds / 60) % 60
	local h = math.floor(seconds / 3600) % 24
	local d = math.floor(seconds / 86400)

	local parts = {}
	if d > 0 then
		table.insert(parts, formatUnit(d, "gün"))
	end
	if h > 0 then
		table.insert(parts, formatUnit(h, "saat"))
	end
	if m > 0 then
		table.insert(parts, formatUnit(m, "dakika"))
	end
	if s > 0 then
		table.insert(parts, formatUnit(s, "saniye"))
	end

	return table.concat(parts, " ")
end

function secondsToTimeDesc(seconds)
	if not seconds or seconds <= 0 then
		return ""
	end

	local s = seconds % 60
	local m = math.floor((seconds % 3600) / 60)
	local h = math.floor((seconds % 86400) / 3600)
	local d = math.floor(seconds / 86400)

	local parts = {}
	if d > 0 then
		table.insert(parts, d .. " gün")
	end
	if h > 0 then
		table.insert(parts, h .. " saat")
	end
	if m > 0 then
		table.insert(parts, m .. " dakika")
	end
	if s > 0 then
		table.insert(parts, s .. " saniye")
	end

	return table.concat(parts, ", ")
end
