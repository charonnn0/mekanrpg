local store = useStore("hud")

PADDING = 10
CIRCLE_VALUES = {
	["level"] = {
		icon = "",
		color = theme.BLUE[600],
		iconColor = theme.BLUE[400],
	},
	["hunger"] = {
		icon = "",
		color = theme.ORANGE[500],
		iconColor = theme.ORANGE[300],
	},
	["thirst"] = {
		icon = "",
		color = theme.BLUE[500],
		iconColor = theme.BLUE[300],
	},
	["stamina"] = {
		icon = "",
		color = theme.GRAY[200],
		iconColor = theme.GRAY[100],
	},
}

INFORMATION_CARD_ITEMS = {
	{ icon = "", prefix = "" },
	{ icon = "", prefix = "ID" },
	{ icon = "", prefix = "" },
}

MONEY_INFORMATION_VALUES = {
	{ key = "money", icon = "" },
	{ key = "bank_money", icon = "" },
}

function getHudCardItemValue(index)
	if index == 1 then
		return store.get("time")
	elseif index == 2 then
		return store.get("id") or 0
	elseif index == 3 then
		local players = getElementsByType("player")
		return string.format("%03d", #players)
	end
	return ""
end

function getHudDataValue(store, key)
	if key == "stamina" then
		local stamina = exports.mek_realism:getStamina()
		return stamina, stamina .. "%"
	elseif key == "level" then
		local level = store.get(key)
		return level, level .. "lvl"
	end

	local value = store.get(key)
	return value, math.min(value, 100) .. "%"
end
