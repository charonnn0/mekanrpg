local timer = {}
local tuned = {}

local function updateWorldItemValue(item, station, volume)
	if station < 0 then
		return
	end

	local newValue = tostring(station)
	if volume and volume ~= 100 then
		newValue = newValue .. ":" .. volume
	end

	setElementData(item, "itemValue", newValue)
	dbExec(
		exports.mek_mysql:getConnection(),
		"UPDATE worlditems SET itemvalue = ? WHERE id = ?",
		newValue,
		getElementData(item, "id")
	)
	triggerClientEvent(root, "toggleSound", item)
end

function changeTrack(item, step)
	local splitValue = split(tostring(getElementData(item, "itemValue")), ":")

	local current = tonumber(splitValue[1]) or 1
	current = current + step
	if current > 0 then
		current = 0
	elseif current < 0 then
		current = 0
	end

	updateWorldItemValue(item, current, tonumber(splitValue[2]))

	if not tuned[item] then
		exports.mek_global:sendLocalMeAction(source, "Ghettoblaster'ı yeniden ayarlar.")
		tuned[item] = true
	else
		if timer[item] and isTimer(timer[item]) then
			killTimer(timer[item])
		end
		timer[item] = setTimer(function()
			tuned[item] = false
		end, 10 * 1000, 1)
	end
end
addEvent("changeGhettoblasterTrack", true)
addEventHandler("changeGhettoblasterTrack", root, changeTrack)

addEvent("changeGhettoblasterVolume", true)
addEventHandler("changeGhettoblasterVolume", root, function(newValue)
	newValue = math.floor(newValue)
	if newValue < 0 or newValue > 100 then
		return
	end

	local splitValue = split(tostring(getElementData(source, "itemValue")), ":")

	updateWorldItemValue(source, tonumber(splitValue[1]) or 1, newValue)
end)