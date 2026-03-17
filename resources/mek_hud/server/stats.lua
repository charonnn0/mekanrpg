function groupItems(list, groupSize)
	local grouped = {}
	for i = 1, #list, groupSize do
		local group = {}
		for j = i, math.min(i + groupSize - 1, #list) do
			local item = list[j]
			table.insert(group, item)
		end
		table.insert(grouped, table.concat(group, ", "))
	end
	return grouped
end

local function isResourceRunning(resourceName)
	local res = getResourceFromName(resourceName)
	return res and getResourceState(res) == "running"
end

function getPlayerVehiclesFromDB(playerDBID)
	local vehicles = {}
    local vehicleCount = 0

	if not isResourceRunning("mek_mysql") then
        table.insert(vehicles, "#ccccccYok")
		return vehicles, 0
	end

	local okQuery, query = pcall(dbQuery, exports.mek_mysql:getConnection(),
		"SELECT id, activity FROM vehicles WHERE owner = ? AND deleted = 0",
		playerDBID)
	if not okQuery or not query then
        table.insert(vehicles, "#ccccccYok")
		return vehicles, 0
	end

	local result, numRows = dbPoll(query, -1)

	if numRows > 0 then
		for _, row in ipairs(result) do
            -- Image shows RED IDs. #c0392b (dark red).
			table.insert(vehicles, "#c0392b" .. row.id)
            vehicleCount = vehicleCount + 1
		end
	end
    
    if #vehicles == 0 then
        table.insert(vehicles, "#ccccccYok")
    end

	return vehicles, vehicleCount
end

function getPlayerPropertiesFromDB(playerDBID)
	local properties = {}
    local propertyCount = 0

	if not isResourceRunning("mek_mysql") then
        table.insert(properties, "#ccccccYok")
		return properties, 0
	end

	local okQuery, query = pcall(dbQuery, exports.mek_mysql:getConnection(),
		"SELECT id FROM interiors WHERE owner = ? AND deleted = '0'",
		playerDBID)
	if not okQuery or not query then
        table.insert(properties, "#ccccccYok")
		return properties, 0
	end

	local result, numRows = dbPoll(query, -1)

	if numRows > 0 then
		for _, row in ipairs(result) do
			table.insert(properties, "#cccccc" .. row.id)
            propertyCount = propertyCount + 1
		end
	end
    
    if #properties == 0 then
        table.insert(properties, "#ccccccYok")
    end

	return properties, propertyCount
end

function showStats(thePlayer, commandName, targetPlayerName)
	local targetPlayer = thePlayer

	if exports.mek_integration:isPlayerTrialAdmin(thePlayer) and targetPlayerName then
		local foundPlayer = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayerName)
		if foundPlayer then
			if getElementData(foundPlayer, "logged") then
				targetPlayer = foundPlayer
			else
				outputChatBox(
					"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
					thePlayer,
					255,
					0,
					0,
					true
				)
				return
			end
		else
			return
		end
	end

    -- COLORS
    local COLOR_GREEN = "#1abc9c" -- Teal/Green from image
    local COLOR_RED = "#c0392b" -- Red from image/old logic
    
	local carLicense = getElementData(targetPlayer, "car_license")
	local bikeLicense = getElementData(targetPlayer, "bike_license")

	if carLicense == 1 then
		carLicense = COLOR_GREEN .. "Var"
	elseif carLicense == 3 then
		carLicense = COLOR_RED .. "Direksiyon sınavını geçmedi"
	else
		carLicense = COLOR_RED .. "Yok"
	end

	if bikeLicense == 1 then
		bikeLicense = COLOR_GREEN .. "Var"
	elseif bikeLicense == 3 then
		bikeLicense = COLOR_RED .. "Direksiyon sınavını geçmedi"
	else
		bikeLicense = COLOR_RED .. "Yok"
	end

	local playerDBID = tonumber(getElementData(targetPlayer, "dbid"))
	if not playerDBID then
		outputChatBox("[!]#FFFFFF Oyuncu verileri yüklenmedi (dbid yok).", thePlayer, 255, 0, 0, true)
		return
	end

	local vehicleList, vehicleCount = getPlayerVehiclesFromDB(playerDBID)
	local groupedVehicles = groupItems(vehicleList, 3)

	local propertyList, propertyCount = getPlayerPropertiesFromDB(playerDBID)
	local groupedProperties = groupItems(propertyList, 3)

	local hoursPlayed = getElementData(targetPlayer, "hours_played") or 0
	local minutesPlayed = getElementData(targetPlayer, "minutes_played") or 0

	local money = getElementData(targetPlayer, "money") or 0
	local bankMoney = getElementData(targetPlayer, "bank_money") or 0
	local balance = getElementData(targetPlayer, "balance") or 0

	local carriedWeight, maxWeight = 0, 0
	if isResourceRunning("mek_item") then
		local okCW, cw = pcall(function() return exports.mek_item:getCarriedWeight(targetPlayer) end)
		local okMW, mw = pcall(function() return exports.mek_item:getMaxWeight(targetPlayer) end)
		carriedWeight = (okCW and cw) or 0
		maxWeight = (okMW and mw) or 0
	end

	local weightDisplay = ""
	if maxWeight == math.huge then
		weightDisplay = string.format("%s%.2f/∞ kg(s)", COLOR_GREEN, carriedWeight)
	else
		weightDisplay = string.format("%s%.2f/%.2f kg(s)", COLOR_GREEN, carriedWeight, maxWeight)
	end
    
    local playerName = getPlayerName(targetPlayer):gsub("_", " ")

	local info = {
		{ playerName, true }, -- Title is simple bold white usually
		{ "" },
		{ "Araba Ehliyeti: " .. carLicense },
		{ "Motor Ehliyeti: " .. bikeLicense },
		{ "" },
		{ "Araçlar (" .. vehicleCount .. "/" .. (getElementData(targetPlayer, "max_vehicles") or 5) .. "):" },
		{ table.concat(groupedVehicles, ", ") },
		{ "" },
		{ "Mülkler (" .. propertyCount .. "/" .. (getElementData(targetPlayer, "max_interiors") or 10) .. "):" },
		{ table.concat(groupedProperties, ", ") },
		{ "" },
		{ "Bu karakterinizde " .. hoursPlayed .. " saat " .. minutesPlayed .. " dakika geçirdiniz." },
		{ "" },
		{ "Cüzdan: " .. COLOR_GREEN .. (isResourceRunning("mek_global") and exports.mek_global:formatMoney(money) or tostring(money)) .. "$" },
		{ "Bankadaki Para: " .. COLOR_GREEN .. (isResourceRunning("mek_global") and exports.mek_global:formatMoney(bankMoney) or tostring(bankMoney)) .. "$" },
		{ "" },
		{ "Bakiye: " .. COLOR_GREEN .. (isResourceRunning("mek_global") and exports.mek_global:formatMoney(balance) or tostring(balance)) .. "TL" },
		{ "" },
		{ "Taşınan Ağırlık: " .. weightDisplay },
	}

	if isResourceRunning("mek_vip") and exports.mek_vip:isPlayerVip(playerDBID) then
		local vip = getElementData(targetPlayer, "vip") or 0
		local vipName = exports.mek_vip:getVipName(vip) or "?"
		local vipExpireTime = exports.mek_vip:getVipExpireTime(playerDBID) or "?"

		table.insert(info, { "" })
		table.insert(info, { "VIP Seviyeniz: " .. COLOR_GREEN .. vipName })
		table.insert(info, { "Kalan Süre: " .. COLOR_GREEN .. vipExpireTime })
	end

	table.insert(info, { "" })

	triggerClientEvent(thePlayer, "hud.drawOverlay", thePlayer, info)
end
addCommandHandler("stats", showStats, false, false)
addCommandHandler("durum", showStats, false, false)
