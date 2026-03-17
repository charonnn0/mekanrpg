itemBannedByAltAltChecker = {
	[2] = true,
	[3] = true,
	[4] = true,
	[5] = true,
	[68] = true,
	[73] = true,
	[74] = true,
	[75] = true,
	[98] = true,
	[114] = true,
	[115] = true,
	[116] = true,
	[134] = true,
	[150] = true,
}

local allowedVideoHosts = {
	["youtube.com"] = true,
}

function getItemRotInfo(id)
	if not itemsPackages[id] then
		return 0, 0, 0, 0
	else
		return itemsPackages[id][5], itemsPackages[id][6], itemsPackages[id][7], itemsPackages[id][8]
	end
end

local _vehicleCache = {}
local function findVehicleName(value)
	if _vehicleCache[value] then
		return _vehicleCache[value]
	end

	for _, theVehicle in pairs(getElementsByType("vehicle")) do
		if getElementData(theVehicle, "dbid") == value then
			_vehicleCache[value] = exports.mek_global:getVehicleName(theVehicle)
			return _vehicleCache[value]
		end
	end

	return "?"
end

function getItemName(id, value)
	if not id or not tonumber(id) then
		return "Yükleniyor..."
	end
	if id == -100 then
		return "Vücut Zırhı"
	elseif id == -46 then
		return "Parachute"
	elseif id < 0 then
		return getWeaponNameFromID(-id)
	elseif not itemsPackages[id] then
		return "?"
	elseif id == 3 and value then
		return itemsPackages[id][1] .. " (" .. findVehicleName(value) .. ")", findVehicleName(value)
	elseif (id == 4 or id == 5) and value then
		local pickup = exports.mek_interior:findParent(nil, value)
		local name = isElement(pickup) and getElementData(pickup, "name")
		return itemsPackages[id][1] .. (name and (" (" .. name .. ")") or ""), name
	elseif (id == 80) and value then
		return value
	elseif (id == 214) and value then
		return value
	elseif (id == 90 or id == 171 or id == 172) and value then
		local itemValue = split(value, ";")
		if itemValue[1] and itemValue[2] then
			local customName = tostring(itemValue[1]) .. " helmet"
			return customName
		else
			return itemsPackages[id][1]
		end
	elseif (id == 96) and value and value ~= 1 then
		return value
	elseif (id == 89 or id == 95 or id == 109 or id == 110) and value and value:find(";") ~= nil then
		return value:sub(1, value:find(";") - 1)
	elseif id == 115 and value then
		local itemExploded = split(value, ":")
		return itemExploded[3]
	elseif id == 116 and value then
		local parts = split(value, ":")
		local ammoID = tonumber(parts[1])
		local rounds = tonumber(parts[2])
		if ammoID and rounds then
			local ammo = exports.mek_weapon:getAmmo(ammoID)
			if ammo and ammo.cartridge then
				return ammo.cartridge .. " " .. itemsPackages[id][1]
			end
		end
	elseif (id == 150) and value then
		local itemExploded = split(value, ";")
		local text = "ATM card"
		if itemExploded and itemExploded[3] then
			if tonumber(itemExploded[3]) == 1 then
				text = text .. " - Basic"
			elseif tonumber(itemExploded[3]) == 2 then
				text = text .. " - Premium"
			elseif tonumber(itemExploded[3]) == 3 then
				text = text .. " - Ultimate"
			end
		end
		return text
	elseif id == 165 then
		local disc = tonumber(value) or 0
		if disc > 1 then
			local discData = exports.mek_fakevideo:getFakevideoData(disc)
			if discData then
				return 'DVD "' .. tostring(discData.name) .. '"'
			end
		else
			return "Empty DVD"
		end
		return "DVD"
	elseif id == 175 then
		if value and not tonumber(value) then
			local itemExploded = split(value, ";")
			local name = tostring(itemExploded[1] .. " Poster")
			return name
		else
			return itemsPackages[id][1]
		end
	elseif id == 226 then
		if value and not tonumber(value) then
			local itemExploded = split(value, ";")
			local name = tostring(itemExploded[1])
			return name
		else
			return itemsPackages[id][1]
		end
	elseif id == 273 and value then
		local fish = split(value, ":")
		return fish[1]
	else
		return itemsPackages[id][1]
	end
end

function getItemValue(id, value)
	if id == 80 or id == 89 or id == 95 then
		return ""
	elseif id == 214 then
		return ""
	elseif id == 223 then
		return "Capacity: " .. tostring(split(value, ":")[3]) .. " kg"
	elseif id == 10 and tostring(value) == "1" then
		return 6
	elseif (id == 89 or id == 95 or id == 109 or id == 110) and value and value:find(";") ~= nil then
		return value:sub(value:find(";") + 1)
	else
		return value
	end
end

function getItemDescription(id, value)
	local i = itemsPackages[id]
	if i then
		local desc = i[2]
		if id == 90 or id == 171 or id == 172 then
			local itemValue = split(value, ";")
			if itemValue[3] then
				local helmetDesc = tostring(itemValue[3])
				return helmetDesc
			else
				return desc:gsub("#v", value)
			end
		elseif id == 96 and value ~= 1 then
			return desc:gsub("PDA", "Laptop")
		elseif id == 114 then
			if tonumber(value) == nil then
				return nil
			end
			local v = tonumber(value) - 999
			return desc:gsub("#v", vehicleUpgrades[v] or "?")
		elseif id == 115 then
			local values = split(value, ":")
			local textParts = {}

			if not exports.mek_weapon:isWeaponAmmoless(tonumber(values[1])) then
				local ammoCount = tonumber(values[4]) or 0
				local rightsCount = tonumber(values[5]) or 0

				if ammoCount > 0 then
					table.insert(textParts, ammoCount .. " mermi yüklendi.")
				else
					table.insert(textParts, "0 mermi yüklendi.")
				end

				table.insert(textParts, "\n")

				if rightsCount > 0 then
					table.insert(textParts, rightsCount .. " hakkı mevcut.")
				else
					table.insert(textParts, "0 hakkı mevcut.")
				end
			end

			return table.concat(textParts, " ")
		elseif id == 116 then
			local values = split(value, ":")
			local bullets = values[2] and tonumber(values[2]) or 0
			return desc:gsub("#v", bullets)
		elseif id == 150 then
			local itemExploded = split(value, ";")
			if tonumber(itemExploded[2]) > 0 then
				return "Card Number: '"
					.. itemExploded[1]
					.. "', Owner: '"
					.. tostring(exports.mek_cache:getCharacterNameFromID(itemExploded[2])):gsub("_", " ")
					.. "'"
			else
				return "Card Number: '"
					.. itemExploded[1]
					.. "', Owner: '"
					.. tostring(exports.mek_cache:getBusinessNameFromID(math.abs(itemExploded[2])))
					.. "'"
			end
		elseif id == 178 then
			local yup = split(value, ":")
			return yup[1] .. " by " .. yup[2]
		else
			return desc:gsub("#v", value)
		end
	end
end

function getItemType(id)
	return (itemsPackages[id] or { nil, nil, 4 })[3]
end

function getItemModel(id, value)
	if id == 115 and value then
		local itemExploded = split(value, ":")
		return weaponModels[tonumber(itemExploded[1])] or 1271
	else
		return (itemsPackages[id] or { nil, nil, nil, 1271 })[4]
	end
end

function getItemTab(id)
	if getItemType(id) == 2 then
		return 3
	elseif getItemType(id) == 8 or getItemType(id) == 9 then
		return 4
	elseif getItemType(id) == 10 then
		return 1
	else
		return 2
	end
end

function getItemWeight(itemID, itemValue)
	local weight = itemsPackages[itemID] and itemsPackages[itemID].weight
	if type(weight) == "function" then
		return weight(tonumber(itemValue) or itemValue) or 0
	end
	return weight or 0
end

function getItemScale(itemID)
	local scale = itemsPackages[itemID] and itemsPackages[itemID].scale
	return scale
end

function getItemDoubleSided(itemID)
	local dblsided = itemsPackages[itemID] and itemsPackages[itemID].doubleSided
	return dblsided
end

function getItemTexture(itemID, itemValue)
	if itemID == 90 or itemID == 171 or itemID == 172 then
		if itemValue then
			local texname = {
				[90] = "helmet",
				[171] = "helmet_b",
				[172] = "helmet_f",
			}
			itemValue = split(itemValue, ";")
			if itemValue[2] then
				local texture = { { tostring(itemValue[2]), texname[itemID] } }
				return texture
			end
		end
	elseif itemID == 167 and itemValue then
		itemValue = split(itemValue, ";")
		if itemValue[2] then
			local texture = { { tostring(itemValue[2]), "cj_painting34" } }
			return texture
		end
	elseif itemID == 175 and itemValue then
		itemValue = split(itemValue, ";")
		if itemValue[2] then
			local texture = { { tostring(itemValue[2]), "cj_don_post_2" } }
			return texture
		end
	elseif itemID == 226 and itemValue then
		itemValue = split(itemValue, ";")
		if itemValue[2] then
			local texture = { { tostring(itemValue[2]), "goflag" } }
			return texture
		end
	end
	local texture = itemsPackages[itemID] and itemsPackages[itemID].texture
	return texture
end

function getItemPreventSpawn(itemID, itemValue)
	local preventSpawn = itemsPackages[itemID] and itemsPackages[itemID].preventSpawn
	return preventSpawn
end

function getItemUseNewPickupMethod(itemID)
	local use = itemsPackages[itemID] and itemsPackages[itemID].newPickupMethod
	return use
end

function getItemHideItemValue(itemID)
	local use = itemsPackages[itemID] and itemsPackages[itemID].hideItemValue
	return use
end

function isItem(id)
	return itemsPackages[tonumber(id)]
end

function getPlayerMaxCarryWeight(element)
	local weightCount = 35

	if hasItem(element, 48) then
		weightCount = weightCount + 10
	end

	if hasItem(element, 126) then
		weightCount = weightCount + 7.5
	end

	if hasItem(element, 160) then
		weightCount = weightCount + 2
	end

	if hasItem(element, 163) then
		weightCount = weightCount + 15
	end

	if hasItem(element, 164) then
		weightCount = weightCount + 15
	end

	if hasItem(element, 348) then
		weightCount = math.huge
	end

	return weightCount
end

function isYoutubeURL(link)
	if not notEmpty then
		if not url or url == "" then
			return true
		end
	end

	if string.find(url, "http://", 1, true) or string.find(url, "https://", 1, true) then
		local domain = url:match("[%w%.]*%.(%w+%.%w+)") or url:match("^%w+://([^/]+)")
		if allowedVideoHosts[domain] then
			local _extensions = ""
			return true
		end
	end

	return false
end
