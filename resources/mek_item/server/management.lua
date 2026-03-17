mysql = exports.mek_mysql

Async:setPriority("high")

local drugList = {
	[30] = " gram",
	[31] = " gram",
	[32] = " gram",
	[33] = " gram",
	[34] = " gram",
	[35] = " ml",
	[36] = " tablet",
	[37] = " gram",
	[38] = " gram",
	[39] = " gram",
	[40] = " ml",
	[41] = " hap",
	[42] = " mantar",
	[43] = " tablet",
}

local savedItems = {}
local subscribers = {}
local loadingItems = {}

local function convertItems(items)
	if type(items) ~= "table" then
		return false
	end

	local converted = {}
	for i, item in ipairs(items) do
		converted[i] = {
			item[1],
			tostring(item[2] or ""),
			tostring(item[3] or ""),
			tonumber(item[4]) or 0,
		}
	end

	return toJSON(converted)
end

local function sendItems(element, to, noLoad)
	if not noLoad then
		loadItems(element)
	end

	if savedItems[element] then
		triggerClientEvent(to, "recieveItems", element, convertItems(savedItems[element]))
	end
end

local function notify(element, noLoad)
	if subscribers[element] then
		for subscriber in pairs(subscribers[element]) do
			sendItems(element, subscriber, noLoad)
		end
	end
end

function updateProtection(item, faction, slot, element)
	local success, error = loadItems(element)
	if success then
		if savedItems[element][slot] then
			savedItems[element][slot][4] = faction
			notify(element)
		end
	end
end

local function destroyInventory()
	savedItems[source] = nil
	loadingItems[source] = nil -- Cleanup loading flag
	notify(source, true)

	for _, value in pairs(subscribers) do
		if value[source] then
			value[source] = nil
		end
	end

	subscribers[source] = nil
end
addEventHandler("onElementDestroy", root, destroyInventory)
addEventHandler("onPlayerQuit", root, destroyInventory)

local function subscribeChanges(element)
	if not isElement(element) or not isElement(source) then
		return
	end

	if type(sendItems) == "function" then
		sendItems(element, source)
	end

	subscribers[element] = subscribers[element] or {}
	subscribers[element][source] = true
end
addEvent("subscribeToInventoryChanges", true)
addEventHandler("subscribeToInventoryChanges", root, subscribeChanges)

local function sendCurrentInventory(element)
	sendItems(element, source)
end
addEvent("sendCurrentInventory", true)
addEventHandler("sendCurrentInventory", root, sendCurrentInventory)

local function unsubscribeChanges(element)
	if not isElement(element) or not isElement(source) then
		return
	end

	if subscribers[element] then
		subscribers[element][source] = nil
		if next(subscribers[element]) == nil then
			subscribers[element] = nil
		end
	end

	triggerClientEvent(source, "recieveItems", element)
end
addEvent("unsubscribeFromInventoryChanges", true)
addEventHandler("unsubscribeFromInventoryChanges", root, unsubscribeChanges)

local function getID(element)
	if getElementType(element) == "player" then
		return getElementData(element, "dbid")
	elseif getElementType(element) == "vehicle" then
		return getElementData(element, "dbid")
	elseif
		getElementParent(getElementParent(element)) == getResourceRootElement(getResourceFromName("mek_item-world"))
	then
		return getElementData(element, "id")
	elseif getElementType(element) == "object" then
		return getElementDimension(element)
	elseif getElementType(element) == "ped" then
		return getElementData(element, "dbid")
	else
		return 0
	end
end

function getElementID(element)
	return getID(element)
end

local function getType(element)
	if getElementType(element) == "player" then
		return 1
	elseif getElementType(element) == "vehicle" then
		return 2
	elseif
		getElementParent(getElementParent(element)) == getResourceRootElement(getResourceFromName("mek_item-world"))
	then
		return 3
	elseif getElementType(element) == "object" then
		return 4
	elseif getElementType(element) == "ped" then
		return 5
	else
		return 255
	end
end

function loadItems(element, force)
	if not isElement(element) then
		return false, "Hedef mevcut değil."
	elseif not getID(element) then
		return false, "Geçersiz Hedef ID."
	end
	
	-- Prevent concurrent loads that cause item duplication
	if loadingItems[element] then
		return true, "Yükleme zaten devam ediyor."
	end
	
	if force or not savedItems[element] then
		loadingItems[element] = true

		dbQuery(
			function(queryHandle, element)
				local result = dbPoll(queryHandle, 0)
				
				savedItems[element] = {}
				
				if result then
					for index, row in ipairs(result) do
						savedItems[element][index] = {
							tonumber(row.itemID) or -1,
							(tonumber(row.itemValue) or row.itemValue) or 0,
							tonumber(row.index) or 0,
							tonumber(row.protected) or 0,
						}
						
						if savedItems[element][index][1] == 6 then
							setElementData(element, "radio_frequency", savedItems[element][index][2])
						end
					end
				end

				if not subscribers[element] then
					subscribers[element] = {}
					if getElementType(element) == "player" then
						subscribers[element][element] = true
					end
				end

				loadingItems[element] = nil

				notify(element, true)
				if getElementType(element) == "player" then
					triggerEvent("updateLocalGuns", element)
				end
			end,
			{ element },
			mysql:getConnection(),
			"SELECT * FROM items  WHERE type = ? AND owner = ? ORDER BY `index` ASC",
			getType(element),
			getID(element)
		)

		return true, "Sorgu başlatıldı."
	else
		return true, "Başarılı."
	end
end

function clearItems(element, onlyifnosqlones)
	if not savedItems[element] then
		loadItems(element)
	end

	if savedItems[element] then
		if onlyifnosqlones and #savedItems[element] > 0 then
			return false
		else
			while #savedItems[element] > 0 do
				takeItemFromSlot(element, 1)
			end

			savedItems[element] = nil
			notify(element, true)

			source = element
			destroyInventory()
			if getElementType(element) == "player" then
				triggerEvent("updateLocalGuns", element)
			end
		end
	end

	return true
end

function giveItem(element, itemID, itemValue, itemIndex, isThisFromSplittingOrAdminCmd)
	if not savedItems[element] then
		loadItems(element)
	end

	if savedItems[element] then
		if not hasSpaceForItem(element, itemID, itemValue) then
			return false, "Envanter dolu."
		end

		if isThisFromSplittingOrAdminCmd then
			if drugList[itemID] then
				if not tonumber(itemValue) or tonumber(itemValue) < 1 then
					return false, "Uyuşturucu değeri sayısal olmalı ve gram cinsinden olmalıdır."
				else
					itemValue = tostring(itemValue) .. drugList[itemID]
				end
			end
		end

		if not itemIndex then
			local result = dbExec(
				mysql:getConnection(),
				"INSERT INTO items (type, owner, itemID, itemValue) VALUES (?, ?, ?, ?)",
				getType(element),
				getID(element),
				itemID,
				tostring(itemValue)
			)
			if not result then
				return false, "Eşya veritabanına eklenemedi."
			end

			dbQuery(
				function(queryHandle, thePlayer, itemID, itemValue, isThisFromSplittingOrAdminCmd)
					local res, rows, err = dbPoll(queryHandle, 0)
					if rows > 0 then
						itemIndex = res[1]["index"]
						if itemID == 178 then
							local bInfo = split(tostring(itemValue), ":")
							local bID = bInfo[3]
							if not bID then
								dbExec(
									mysql:getConnection(),
									"INSERT INTO books SET `title` = ?, `author` = 'Unknown', `book` = 'The beginning of something great...'",
									itemValue
								)
								dbQuery(
									function(queryHandle, thePlayer, itemID, itemValue)
										local res, rows, err = dbPoll(queryHandle, 0)
										if rows > 0 then
											local bookIndex = res[1]["index"]
											itemValue = itemValue .. ":Unknown:" .. tostring(bookIndex)
											dbExec(
												mysql:getConnection(),
												"UPDATE `items` SET `itemValue` = ? WHERE `index` = ?",
												itemValue,
												tonumber(itemIndex)
											)
										end
									end,
									{ thePlayer, itemID, itemValue },
									mysql:getConnection(),
									"SELECT `index` FROM `books` WHERE `index` = LAST_INSERT_ID()"
								)
							end
						end

						savedItems[thePlayer] = savedItems[thePlayer] or {}
						table.insert(savedItems[thePlayer], { itemID, itemValue, itemIndex, 0 })
						notify(thePlayer, true)

						if getElementType(thePlayer) == "player" then
							if tonumber(itemID) == 115 or tonumber(itemID) == 116 then
								triggerEvent("updateLocalGuns", thePlayer)
							end
						end
					end
				end,
				{ element, itemID, itemValue, isThisFromSplittingOrAdminCmd },
				mysql:getConnection(),
				"SELECT `index` FROM `items` WHERE `index` = LAST_INSERT_ID()"
			)
		else
			savedItems[element] = savedItems[element] or {}
			table.insert(savedItems[element], { itemID, itemValue, itemIndex, 0 })
			notify(element, true)

			if getElementType(element) == "player" then
				if tonumber(itemID) == 115 or tonumber(itemID) == 116 then
					triggerEvent("updateLocalGuns", element)
				end
			end
		end
	end

	return true
end

function takeItem(element, itemID, itemValue)
	if not savedItems[element] then
		loadItems(element)
	end

	if savedItems[element] then
		local success, slot = hasItem(element, itemID, itemValue)
		if success then
			takeItemFromSlot(element, slot)
			if (tonumber(itemID) == 115 or tonumber(itemID) == 116) and (getElementType(element) == "player") then
				triggerEvent("updateLocalGuns", element)
			end
			return true
		else
			return false, "Hedefte bu eşya yok."
		end
	end

	return false, ""
end

function takeItemFromSlot(element, slot, nosqlupdate)
	if not savedItems[element] then
		loadItems(element)
	end

	if savedItems[element][slot] then
		local itemID = savedItems[element][slot][1]
		local itemValue = savedItems[element][slot][2]
		local index = savedItems[element][slot][3]

		local success = true
		if not nosqlupdate then
			if index then
				result = dbExec(mysql:getConnection(), "DELETE FROM `items` WHERE `index` = ?", index)
			end
			if not result then
				success = false
			end
		end

		if success then
			table.remove(savedItems[element], slot)
			notify(element)
			if (tonumber(itemID) == 115 or tonumber(itemID) == 116) and (getElementType(element) == "player") then
				triggerEvent("updateLocalGuns", element)
			end
			return true
		end
		return false, "Slot mevcut değil."
	end
end

function updateItemValue(element, slot, itemValue)
	-- SECURITY FIX: Block client-side triggering
	if client and source and client == source then
		exports.mek_sac:banForEventAbuse(client, "updateItemValue")
		outputDebugString("[ANTI-CHEAT] Player " .. getPlayerName(client) .. " attempted to trigger updateItemValue from client!", 1)
		return false
	end
	
	if not savedItems[element] then
		loadItems(element)
	end

	if savedItems[element][slot] then
		local itemValue = tonumber(itemValue) or tostring(itemValue)
		if itemValue then
			local itemIndex = savedItems[element][slot][3]
			if itemIndex and itemValue then
				result = dbExec(
					mysql:getConnection(),
					"UPDATE items SET `itemValue` = ? WHERE `index` = ?",
					itemIndex,
					tostring(itemValue)
				)
			end
			if result then
				savedItems[element][slot][2] = itemValue
				notify(element)
				return true
			else
				return false, "Veritabanı hatası."
			end
		else
			return false, "Geçersiz eşya değeri."
		end
	else
		return false, "Slot mevcut değil."
	end
end

-- SECURITY FIX: Event handler REMOVED to prevent client-side triggering
-- This was being exploited to change item IDs and values
-- Only server-side code can now call updateItemValue()
-- addEvent("updateItemValue", true)
-- addEventHandler("updateItemValue", root, updateItemValue)

function moveItem(from, to, slot)
	if not savedItems[from] then
		loadItems(from)
	end

	if not savedItems[to] then
		loadItems(to)
	end

	if savedItems[from] and savedItems[from][slot] then
		if hasSpaceForItem(to, savedItems[from][slot][1], savedItems[from][slot][2]) then
			local itemIndex = savedItems[from][slot][3]
			if itemIndex then
				local itemID = savedItems[from][slot][1]
				if itemID == 48 or itemID == 126 or itemID == 60 or itemID == 103 then
					return false, "Bu eşyayı taşıyamazsınız."
				else
					local query = dbExec(
						mysql:getConnection(),
						"UPDATE items SET type = ?, owner = ? WHERE `index` = ?",
						getType(to),
						getID(to),
						itemIndex
					)
					if query then
						local itemValue = savedItems[from][slot][2]
						if itemID == 115 then
							local target = from
							if getElementType(to) == "player" then
								target = to
							end
						end

						if itemID >= 31 and itemID <= 43 then
							if itemID == 150 then
								if getElementModel(from) == 2942 or getElementModel(to) == 2942 then
									takeItemFromSlot(from, slot, true)
									giveItem(to, itemID, itemValue, itemIndex)
									return true
								end
							end
						end

						if itemID == 134 then
							if takeItemFromSlot(from, slot, true) then
								if exports.mek_global:giveMoney(to, tonumber(itemValue)) then
									return true
								end
							end
						else
							if takeItemFromSlot(from, slot, true) then
								if giveItem(to, itemID, itemValue, itemIndex) then
									return true
								end
							end
						end
					else
						return false, "Veritabanı hatası."
					end
				end
			else
				return false, "Eşya mevcut değil."
			end
		else
			return false, "Hedefte eşya için yeterli alan yok."
		end
	else
		return false, "Slot mevcut değil."
	end
end

function hasItem(element, itemID, itemValue)
	if not savedItems[element] then
		loadItems(element)
	end

	if savedItems[element] then
		for key, value in pairs(savedItems[element]) do
			if value[1] == itemID and (not itemValue or itemValue == value[2]) then
				return true, key, value[2], value[3]
			end
		end
	end

	return false
end

function hasSpaceForItem(element, itemID, itemValue)
	if not savedItems[element] then
		loadItems(element)
	end

	if savedItems[element] then
		local carriedWeight = getCarriedWeight(element) or false
		local itemWeight = getItemWeight(itemID, itemValue or 1) or false
		local maxWeight = getMaxWeight(element) or false

		if carriedWeight and itemWeight and maxWeight then
			return carriedWeight + itemWeight <= maxWeight
		end
	end

	return false, "Hata."
end

function countItems(element, itemID, itemValue)
	if not savedItems[element] then
		loadItems(element)
	end

	if savedItems[element] then
		local count = 0
		for key, value in pairs(savedItems[element]) do
			if value[1] == itemID and (not itemValue or itemValue == value[2]) then
				count = count + 1
			end
		end
		return count
	end

	return 0
end

function getItems(element)
	if not savedItems[element] then
		loadItems(element)
	end

	return savedItems[element]
end

function getCarriedWeight(element)
	if not savedItems[element] then
		loadItems(element)
	end

	local weight = 0

	if savedItems[element] then
		for key, value in ipairs(savedItems[element]) do
			weight = weight + getItemWeight(value[1], value[2])
		end
	end

	return weight
end

local function isTruck(element)
	if getElementType(element) == "Trailer" then
		return true
	end
	local model = getElementModel(element)
	return model == 498
		or model == 609
		or model == 499
		or model == 524
		or model == 455
		or model == 414
		or model == 443
		or model == 456
end

local function isSUV(element)
	local model = getElementModel(element)
	return model == 482
		or model == 440
		or model == 418
		or model == 413
		or model == 400
		or model == 489
		or model == 579
		or model == 459
		or model == 582
end

function getMaxWeight(element)
	if getElementType(element) == "player" then
		return getPlayerMaxCarryWeight(element)
	elseif getElementType(element) == "vehicle" then
		if getID(element) < 0 then
			return -1
		elseif getVehicleType(element) == "BMX" then
			return 1
		elseif getVehicleType(element) == "Bike" then
			return 10
		elseif isSUV(element) then
			return 75
		elseif isTruck(element) then
			return 120
		else
			return 20
		end
	elseif (getElementType(element) == "object") and (getElementModel(element) == 2942) then
		return 0.1
	elseif
		getElementParent(getElementParent(element)) == getResourceRootElement(getResourceFromName("mek_item-world"))
	then
		local itemID = tonumber(getElementData(element, "itemID")) or 0
		if itemID == 166 then
			return 0.1
		end
		return getElementModel(element) == 2147 and 50 or getElementModel(element) == 3761 and 100 or 10
	end
	return 20
end

function deleteAll(itemID, itemValue)
	if not itemID then
		return false
	end

	local itemValueStr = itemValue and tostring(itemValue) or nil

	if itemValueStr then
		dbExec(mysql:getConnection(), "DELETE FROM items WHERE itemID = ? AND itemValue = ?", itemID, itemValueStr)
		dbExec(mysql:getConnection(), "DELETE FROM worlditems WHERE itemid = ? AND itemvalue = ?", itemID, itemValueStr)
	else
		dbExec(mysql:getConnection(), "DELETE FROM items WHERE itemID = ?", itemID)
		dbExec(mysql:getConnection(), "DELETE FROM worlditems WHERE itemid = ?", itemID)
	end

	if savedItems then
		for entity in pairs(savedItems) do
			if isElement(entity) then
				while exports.mek_item:hasItem(entity, itemID, itemValue) do
					exports.mek_item:takeItem(entity, itemID, itemValue)
				end
			end
		end
	end

	local objects = getElementsByType("object", getResourceRootElement(getResourceFromName("mek_item-world")))
	if objects and #objects > 0 then
		Async:foreach(objects, function(obj)
			if not isElement(obj) then
				return
			end
			local match = getElementData(obj, "itemID") == itemID

			if itemValueStr then
				match = match and tostring(getElementData(obj, "itemValue")) == itemValueStr
			end

			if match then
				destroyElement(obj)
			end
		end)
	end

	return true
end

function deleteAllItemsWithinInt(intID, dayOld, CLEANUPINT)
	if not dayOld then
		dayOld = 0
	end

	if intID then
		local row = {}
		local query2 = false
		local success = false
		if CLEANUPINT ~= "CLEANUPINT" then
			dbQuery(
				function(queryHandle)
					local res, rows, err = dbPoll(queryHandle, 0)
					if rows > 0 then
						for index, row in ipairs(res) do
							Async:foreach(
								getElementsByType(
									"object",
									getResourceRootElement(getResourceFromName("mek_item-world"))
								),
								function(value)
									if isElement(value) then
										if tonumber(getElementData(value, "id")) == tonumber(row["id"]) then
											destroyElement(value)
										end
									end
								end
							)
						end
					end
				end,
				mysql:getConnection(),
				"SELECT `id` FROM `worlditems` WHERE `dimension` = ? AND DATEDIFF(NOW(), creationdate) >= ? AND `itemID` != 81 AND `itemID` != 103 AND protected = 0",
				tonumber(intID),
				tonumber(dayOld)
			)
			if
				dbExec(
					mysql:getConnection(),
					"DELETE FROM `worlditems` WHERE `dimension` = ? AND DATEDIFF(NOW(), creationdate) >= ? AND `itemID` != 81 AND `itemID` != 103 AND protected = 0",
					tonumber(intID),
					tonumber(dayOld)
				)
			then
				success = true
			end
		else
			dbQuery(function(queryHandle)
				local res, rows, err = dbPoll(queryHandle, 0)
				if rows > 0 then
					for index, row in ipairs(res) do
						Async:foreach(
							getElementsByType("object", getResourceRootElement(getResourceFromName("mek_item-world"))),
							function(value)
								if isElement(value) then
									if tonumber(getElementData(value, "id")) == tonumber(row["id"]) then
										destroyElement(value)
									end
								end
							end
						)
					end
				end
			end, mysql:getConnection(), "SELECT `id` FROM `worlditems` WHERE `dimension` = ?", tostring(intID))
			if dbExec(mysql:getConnection(), "DELETE FROM `worlditems` WHERE `dimension` = ?", tostring(intID)) then
				success = true
			end
		end

		if success then
			return true
		end
	end
	return false
end

addEventHandler("onResourceStart", resourceRoot, function()
	for _, player in pairs(getElementsByType("player")) do
		if getID(player) then
			loadItems(player)
		end
	end
end)
