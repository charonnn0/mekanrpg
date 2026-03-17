local storedKeys = {
	["hunger"] = { floor = true },
	["thirst"] = { floor = true },
	["level"] = {},
	["money"] = { format = true, floor = true },
	["bank_money"] = { format = true, floor = true },
	["id"] = {},
	["injury"] = {},
}

local function combinedValues(key, value)
	local storedKey = storedKeys[key]
	local combinedValue = value

	if storedKey.floor then
		combinedValue = math.floor(value)
	end

	if not store then
		store = useStore("hud")
	end

	if storedKey.format then
		store.set(key .. "_no-format", "₺" .. combinedValue)
		combinedValue = "₺" .. exports.mek_global:formatMoney(combinedValue)
	end

	return combinedValue
end

local function updateStore()
	if not store then
		store = useStore("hud")
	end

	for key in pairs(storedKeys) do
		store.set(key, combinedValues(key, localPlayer:getData(key)))
	end
end

local function calculateAmmos(playerWeapon)
	ammoPerInventory = 0

	if tonumber(playerWeapon) > 0 then
		items = exports.mek_item:getItems(localPlayer)
		if items and #items > 0 then
			for index, value in ipairs(items) do
				if value[1] == 116 then
					local itemValue = value[2]
					if itemValue then
						local splittedData = split(itemValue, ":")
						if splittedData then
							local weaponId, ammo = splittedData[1], splittedData[2]
							if tonumber(playerWeapon) == tonumber(weaponId) then
								ammoPerInventory = ammoPerInventory + ammo
							end
						end
					end
				end
			end
		end
	end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
	if localPlayer:getData("logged") then
		updateStore()
	end
end)

addEventHandler("onClientElementDataChange", localPlayer, function(dataName, oldValue, newValue)
	if dataName == "logged" then
		if newValue then
			updateStore()
		end
	end

	if not storedKeys[dataName] then
		return
	end

	if dataName == "money" then
		setPlayerMoney(newValue, true)
	end

	if not store then
		store = useStore("hud")
	end

	store.set(dataName, combinedValues(dataName, newValue))
end)

setTimer(function()
	if not localPlayer:getData("logged") then
		return
	end

	if not store then
		store = useStore("hud")
	end

	local clip = localPlayer:getAmmoInClip()
	local time = getRealTime()

	calculateAmmos(localPlayer:getWeapon())

	store.set("health", localPlayer:getHealth())
	store.set("armor", localPlayer:getArmor())
	store.set("weapon", localPlayer:getWeapon())
	store.set("stamina", exports.mek_realism:getStamina())

	store.set("time", string.format("%02d:%02d", time.hour, time.minute))
	store.set("date", string.format("%02d/%02d/%04d", time.monthday, time.month + 1, time.year + 1900))

	store.set("ammo", clip .. "/" .. ammoPerInventory)
end, 500, 0)
