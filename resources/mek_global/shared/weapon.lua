local b = "cfFvbCKeg2zN0mOEhnou5X7lDLS31jdJQipHWaUIyGTs4PkrVZt8BMwqYR6x9A"

function getPedWeapons(ped, startSlot, endSlot)
	startSlot = tonumber(startSlot) or 2
	endSlot = tonumber(endSlot) or 9
	local weaponsList = {}

	if ped and isElement(ped) and (getElementType(ped) == "ped" or getElementType(ped) == "player") then
		for slot = startSlot, endSlot do
			local weapon = getPedWeapon(ped, slot)
			if weapon and weapon ~= 0 then
				table.insert(weaponsList, weapon)
			end
		end
	else
		return false
	end

	return weaponsList
end

function retrieveWeaponDetails(serialNumber)
	local decodedStr = weapondec(serialNumber)
	return split(string.reverse(decodedStr), "/")
end

function weaponenc(data)
	return (data:gsub(".", function(x)
		local r, b = "", x:byte()
		for i = 8, 1, -1 do
			r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and "1" or "0")
		end
		return r
	end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
		if #x < 6 then
			return ""
		end
		local c = 0
		for i = 1, 6 do
			c = c + (x:sub(i, i) == "1" and 2 ^ (6 - i) or 0)
		end
		return b:sub(c + 1, c + 1)
	end)
end

function weapondec(data)
	return (
		data:gsub(".", function(x)
			if x == "=" then
				return ""
			end
			local r, f = "", (b:find(x) - 1)
			for i = 6, 1, -1 do
				r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and "1" or "0")
			end
			return r
		end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(x)
			if #x ~= 8 then
				return ""
			end
			local c = 0
			for i = 1, 8 do
				c = c + (x:sub(i, i) == "1" and 2 ^ (8 - i) or 0)
			end
			return string.char(c)
		end)
	)
end
