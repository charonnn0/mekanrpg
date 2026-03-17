local function canAccessElement(player, element)
	if getElementData(player, "dead") then
		return false
	end

	if getElementType(element) == "vehicle" then
		if not isVehicleLocked(element) then
			return true
		end

		local vehicleDBID = getElementData(element, "dbid")
		local playerDBID = getElementData(player, "dbid")
		local hasKey = exports.mek_item:hasItem(player, 3, vehicleDBID)
		local isOwner = getElementData(element, "owner") == playerDBID

		if getPedOccupiedVehicle(player) == element then
			return true
		end

		if hasKey or isOwner or exports.mek_integration:isPlayerManager(player) then
			return true
		end

		return false
	end

	return true
end

local function openInventory(element, ax, ay)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if canAccessElement(client, element) then
		triggerEvent("subscribeToInventoryChanges", client, element)
		triggerClientEvent(client, "openElementInventory", element, ax, ay)
	end
end
addEvent("openFreakinInventory", true)
addEventHandler("openFreakinInventory", root, openInventory)

local function closeInventory(element)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	triggerEvent("unsubscribeFromInventoryChanges", client, element)
end
addEvent("closeFreakinInventory", true)
addEventHandler("closeFreakinInventory", root, closeInventory)

local function output(from, to, itemID, itemValue, evenIfSamePlayer)
	if from == to and not evenIfSamePlayer then
		return false
	end

	local function sanitize(str)
		if not str then return "" end
		str = tostring(str):gsub(";", " | ")
		return str:gsub("%c+", " | ")
	end

	local function getIDString(element)
		local dbid = getElementData(element, "dbid")
		if dbid then
			return " (ID: " .. tostring(dbid) .. ")"
		end
		return ""
	end

	local itemValueStr = ""
	if itemValue then
		itemValueStr = " (Değer: " .. sanitize(itemValue) .. ")"
	end

	if getElementType(from) == "player" and getElementType(to) == "player" then
		local name = getName(to)
		if itemID == 115 or itemID == 116 then
			exports.mek_global:sendLocalText(
				from,
				"* "
					.. getPlayerName(from):gsub("_", " ")
					.. " "
					.. getPlayerName(to):gsub("_", " ")
					.. " kişisine #0cc6f5"
					.. getItemName(itemID, itemValue)
					.. " #dfaeffverir.",
				223,
				174,
				255,
				30
			)
			exports.mek_logs:addLog(
				"item",
				getPlayerName(from):gsub("_", " ")
					.. getIDString(from)
					.. " isimli oyuncu "
					.. getPlayerName(to):gsub("_", " ")
					.. getIDString(to)
					.. " isimli oyuncuya ("
					.. sanitize(getItemName(itemID, itemValue))
					.. itemValueStr
					.. ") verdi."
			)
			triggerEvent("updateLocalGuns", from)
			triggerEvent("updateLocalGuns", to)
		else
			exports.mek_global:sendLocalMeAction(
				from,
				"elinde bulunan "
					.. getItemName(itemID, itemValue)
					.. " isimli öğeyi "
					.. getPlayerName(to):gsub("_", " ")
					.. " kişisine verir."
			)
			exports.mek_logs:addLog(
				"item",
				getPlayerName(from):gsub("_", " ")
					.. getIDString(from)
					.. " isimli oyuncu "
					.. getPlayerName(to):gsub("_", " ")
					.. getIDString(to)
					.. " isimli oyuncuya ("
					.. sanitize(getItemName(itemID, itemValue))
					.. itemValueStr
					.. ") verdi."
			)
			triggerEvent("updateLocalGuns", from)
			triggerEvent("updateLocalGuns", to)
		end
	elseif getElementType(from) == "player" then
		local name = getName(to)
		if itemID == 115 or itemID == 116 then
			exports.mek_global:sendLocalText(
				from,
				"* "
					.. getPlayerName(from):gsub("_", " ")
					.. " "
					.. name
					.. " içine #0cc6f5"
					.. getItemName(itemID, itemValue)
					.. " #dfaeffkoyar.",
				223,
				174,
				255,
				30
			)
			exports.mek_logs:addLog(
				"item",
				getPlayerName(from):gsub("_", " ")
					.. getIDString(from)
					.. " isimli oyuncu "
					.. name
					.. getIDString(to)
					.. " içerisine ("
					.. sanitize(getItemName(itemID, itemValue))
					.. itemValueStr
					.. ") koydu."
			)
			triggerEvent("updateLocalGuns", from)
		else
			exports.mek_global:sendLocalMeAction(
				from,
				name .. " içine " .. getItemName(itemID, itemValue) .. " koyar."
			)
			exports.mek_logs:addLog(
				"item",
				getPlayerName(from):gsub("_", " ")
					.. getIDString(from)
					.. " isimli oyuncu "
					.. name
					.. getIDString(to)
					.. " içerisine ("
					.. sanitize(getItemName(itemID, itemValue))
					.. itemValueStr
					.. ") koydu."
			)
			triggerEvent("updateLocalGuns", from)
		end
	elseif getElementType(to) == "player" then
		local name = getName(from)
		if itemID == 115 or itemID == 116 then
			exports.mek_global:sendLocalText(
				to,
				"* "
					.. getPlayerName(to):gsub("_", " ")
					.. " "
					.. name
					.. " içinden #0cc6f5"
					.. getItemName(itemID, itemValue)
					.. " #dfaeffalır.",
				223,
				174,
				255,
				30
			)
			exports.mek_logs:addLog(
				"item",
				getPlayerName(to):gsub("_", " ")
					.. getIDString(to)
					.. " isimli oyuncu "
					.. name
					.. getIDString(from)
					.. " içerisinden ("
					.. sanitize(getItemName(itemID, itemValue))
					.. itemValueStr
					.. ") aldı."
			)
		else
			exports.mek_global:sendLocalMeAction(
				to,
				name .. " içinden " .. getItemName(itemID, itemValue) .. " alır."
			)
			exports.mek_logs:addLog(
				"item",
				getPlayerName(to):gsub("_", " ")
					.. getIDString(to)
					.. " isimli oyuncu "
					.. name
					.. getIDString(from)
					.. " içerisinden ("
					.. sanitize(getItemName(itemID, itemValue))
					.. itemValueStr
					.. ") aldı."
			)
		end
	end
	return true
end

function x_output_wrapper(...)
	return output(...)
end

local function moveToElement(element, slot, ammo, event)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not canAccessElement(source, element) then
		outputChatBox("[!]#FFFFFF Bunu yapmaya yetkili değilsiniz.", source, 255, 0, 0, true)
		triggerClientEvent(source, event or "finishItemMove", source)
		return
	end

	local name = getName(element)
	if not ammo then
		local item = getItems(source)[slot]
		if item then
			if (getElementType(element) == "ped") and getElementData(element, "shopkeeper") then
				if getElementData(element, "customshop") then
					if item[1] == 134 then
						triggerClientEvent(source, event or "finishItemMove", source)
						return false
					end
					triggerEvent("shop:addItemToCustomShop", source, element, slot, event)
					return true
				end
				triggerClientEvent(source, event or "finishItemMove", source)
				return false
			end

			if not (getElementModel(element) == 2942) and not hasSpaceForItem(element, item[1], item[2]) then
				outputChatBox("[!]#FFFFFF Envanter dolu.", source, 255, 0, 0, true)
			else
				if item[1] == 115 then
					local itemCheckExplode = split(item[2], ":")
					local checkString = string.sub(itemCheckExplode[3], -4)

					if checkString == " (D)" then
						outputChatBox(
							"[!]#FFFFFF Sunucumuzun politikaları gereğince bu işlem yasaklıdır.",
							source,
							255,
							0,
							0,
							true
						)
						triggerClientEvent(source, event or "finishItemMove", source)
						return
					end
				elseif item[1] == 116 then
					local ammoDetails = split(item[2], ":")
					local checkString = string.sub(ammoDetails[3], -4)

					if checkString == " (D)" then
						outputChatBox(
							"[!]#FFFFFF Sunucumuzun politikaları gereğince bu işlem yasaklıdır.",
							source,
							255,
							0,
							0,
							true
						)
						triggerClientEvent(source, event or "finishItemMove", source)
						return
					end
				elseif item[1] == 179 and getElementType(element) == "vehicle" then
					local vehID = getElementData(element, "dbid")
					local veh = element

					if
						exports.mek_global:isAdminOnDuty(source)
						or exports.mek_integration:isPlayerServerOwner(source)
						or exports.mek_item:hasItem(source, 3, tonumber(vehID))
						or (
							getElementData(veh, "faction") > 0
							and exports.mek_faction:isPlayerInFaction(source, getElementData(veh, "faction"))
						)
					then
						local itemExploded = split(item[2], ";")
						local url = itemExploded[1]
						local texName = itemExploded[2]
						if url and texName then
							local res = exports["mek_item-texture"]:addVehicleTexture(source, veh, texName, url)
							if res then
								takeItemFromSlot(source, slot)
								outputChatBox("success", source)
							end
							triggerClientEvent(source, event or "finishItemMove", source)
							return
						end
					end
				elseif item[1] == 112 then
					outputChatBox(
						"[!]#FFFFFF Sunucumuzun politikaları gereğince bu işlem yasaklıdır.",
						source,
						255,
						0,
						0,
						true
					)
					triggerClientEvent(source, event or "finishItemMove", source)
					return
				end

				if item[1] == 137 then
					outputChatBox("You cannot move this item.", source, 255, 0, 0)
					triggerClientEvent(source, event or "finishItemMove", source)
					return
				elseif item[1] == 138 then
					if not exports.mek_integration:isPlayerAdmin1(source) then
						outputChatBox("It requires an admin to move this item.", source, 255, 0, 0)
						triggerClientEvent(source, event or "finishItemMove", source)
						return
					end
				elseif item[1] == 139 then
					if not exports.mek_integration:isPlayerTrialAdmin(source) then
						outputChatBox("It requires a trial administrator to move this item.", source, 255, 0, 0)
						triggerClientEvent(source, event or "finishItemMove", source)
						return
					end
				end

				if item[1] == 134 then
					if exports.mek_global:takeMoney(source, tonumber(item[2])) then
						if getElementType(element) == "player" then
							if exports.mek_global:giveMoney(element, tonumber(item[2])) then
								exports.mek_global:sendLocalMeAction(
									source,
									"gives ₺"
										.. exports.mek_global:formatMoney(item[2])
										.. " to "
										.. exports.mek_global:getPlayerName(element)
										.. "."
								)
							end
						else
							if exports.mek_item:giveItem(element, 134, tonumber(item[2])) then
								exports.mek_global:sendLocalMeAction(
									source,
									"puts ₺"
										.. exports.mek_global:formatMoney(item[2])
										.. " inside the "
										.. name
										.. "."
								)
							end
						end
					end
				else
					if getElementType(element) == "object" then
						local elementModel = getElementModel(element)
						local elementItemID = getElementData(element, "itemID")
						if elementItemID then
							if elementItemID == 166 then
								if item[1] ~= 165 then
									triggerClientEvent(source, event or "finishItemMove", source)
									return
								end
							end
						end
						if
							(
								getElementDimension(element) < 19000
								and (item[1] == 4 or item[1] == 5)
								and getElementDimension(element) == item[2]
							)
							or (
								getElementDimension(element) >= 20000
								and item[1] == 3
								and getElementDimension(element) - 20000 == item[2]
							)
						then
							if countItems(source, item[1], item[2]) < 2 then
								outputChatBox(
									"You can't place your only key to that safe in the safe.",
									source,
									255,
									0,
									0
								)
								triggerClientEvent(source, event or "finishItemMove", source)
								return
							end
						end
					end

					local success, reason = moveItem(source, element, slot)
					if success then
						if item[1] == 165 then
							if exports.mek_clubtec:isVideoPlayer(element) then
								for key, value in ipairs(getElementsByType("player")) do
									if getElementDimension(value) == getElementDimension(element) then
										triggerEvent("fakevideo:loadDimension", value)
									end
								end
							end
						end

						doItemGiveawayChecks(source, item[1])
						output(source, element, item[1], item[2])
					end
				end
			end
		end
	else
		if
			not ((slot == -100 and hasSpaceForItem(element, slot)) or (slot > 0 and hasSpaceForItem(element, -slot)))
		then
			outputChatBox("[!]#FFFFFF Envanter dolu.", source, 255, 0, 0, true)
		else
			if tonumber(getElementData(source, "duty")) > 0 then
				outputChatBox("You can't put your weapons in a " .. name .. " while being on duty.", source, 255, 0, 0)
			elseif tonumber(getElementData(source, "job")) == 4 and slot == 41 then
				outputChatBox("You can't put this spray can into a " .. name .. ".", source, 255, 0, 0)
			else
				if slot == -100 then
					local ammo = math.ceil(getPedArmor(source))
					if ammo > 0 then
						setPedArmor(source, 0)
						giveItem(element, slot, ammo)
						output(source, element, -100)
					end
				else
					local getCurrentMaxAmmo = exports.mek_global:getWeaponCount(source, slot)
					if ammo > getCurrentMaxAmmo then
						exports.mek_global:sendMessageToAdmins(
							"[itemsmoveToElement] Possible duplication of gun from '"
								.. getPlayerName(source)
								.. "' // "
								.. getItemName(-slot)
						)
						triggerClientEvent(source, event or "finishItemMove", source)
						return
					end

					exports.mek_global:takeWeapon(source, slot)

					if ammo > 0 then
						giveItem(element, -slot, ammo)
						output(source, element, -slot)
					end
				end
			end
		end
	end
	triggerClientEvent(source, event or "finishItemMove", source)
end
addEvent("moveToElement", true)
addEventHandler("moveToElement", root, moveToElement)

local function moveWorldItemToElement(item, element)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not isElement(item) or not isElement(element) or not canAccessElement(source, element) then
		return
	end

	local id = tonumber(getElementData(item, "id"))
	if not id then
		outputChatBox("Error: No world item ID. Notify a scripter. (s_move_items)", source, 255, 0, 0)
		destroyElement(element)
		return
	end

	local itemID = getElementData(item, "itemID")
	local itemValue = getElementData(item, "itemValue") or 1
	local name = getName(element)

	if itemID >= 31 and itemID <= 43 then
		outputChatBox(
			getItemName(itemID) .. " can only moved directly from your inventory to this " .. name .. ".",
			source,
			255,
			0,
			0
		)
		return false
	end

	if (getElementType(element) == "ped") and getElementData(element, "shopkeeper") then
		return false
	end

	if not canPickup(source, item) then
		outputChatBox("You can not move this item. Contact an admin via F2.", source, 255, 0, 0)
		return
	end

	if itemID == 138 then
		if not exports.mek_integration:isPlayerTrialAdmin(source) then
			outputChatBox("Only a full admin can move this item.", source, 255, 0, 0)
			return
		end
	end

	if itemID == 169 then
		return
	end

	if giveItem(element, itemID, itemValue) then
		output(source, element, itemID, itemValue, true)
		dbExec(mysql:getConnection(), "DELETE FROM worlditems WHERE id = ?", id)

		while #getItems(item) > 0 do
			moveItem(item, element, 1)
		end
		destroyElement(item)
	else
		outputChatBox("[!]#FFFFFF Envanter dolu.", source, 255, 0, 0, true)
	end
end
addEvent("moveWorldItemToElement", true)
addEventHandler("moveWorldItemToElement", root, moveWorldItemToElement)

local function moveFromElement(element, slot, ammo, index)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not canAccessElement(source, element) then
		return false
	end

	local item = getItems(element)[slot]
	if not canPickup(source, item) then
		outputChatBox("You can not move this item. Contact an admin via F2.", source, 255, 0, 0)
		return
	end

	local name = getName(element)

	if item and item[3] == index then
		if not hasSpaceForItem(source, item[1], item[2]) then
			outputChatBox("[!]#FFFFFF Envanter dolu.", source, 255, 0, 0, true)
		else
			if
				not exports.mek_integration:isPlayerTrialAdmin(source)
				and getElementType(element) == "vehicle"
				and (item[1] == 61 or item[1] == 85 or item[1] == 117 or item[1] == 140)
			then
				outputChatBox("Please contact an admin via F2 to move this item.", source, 255, 0, 0)
			elseif not exports.mek_integration:isPlayerTrialAdmin(source) and (item[1] == 138) then
				outputChatBox("This item requires a regular admin to be moved.", source, 255, 0, 0)
			elseif not exports.mek_integration:isPlayerTrialAdmin(source) and (item[1] == 139) then
				outputChatBox("This item requires an admin to be moved.", source, 255, 0, 0)
			elseif item[1] > 0 then
				if moveItem(element, source, slot) then
					output(element, source, item[1], item[2])
				end
			elseif item[1] == -100 then
				local faction = getElementData(source, "faction")
				local armor = math.max(
					0,
					(
						(
								faction[1]
								or (
									faction[3]
									and (
										(faction[1].rank == 4 or faction[3].rank == 4)
										or (faction[1].rank == 5 or faction[3].rank == 5)
										or (faction[1].rank == 13 or faction[3].rank == 13)
									)
								)
							)
							and 100
						or 50
					) - math.ceil(getPedArmor(source))
				)

				if armor == 0 then
					outputChatBox("You can't wear any more armor.", source, 255, 0, 0)
				else
					output(element, source, item[1], nil, nil, item[5])
					takeItemFromSlot(element, slot)

					local leftOver = math.max(0, item[2] - armor)
					if leftOver > 0 then
						giveItem(element, item[1], leftOver)
					end

					exports.mek_sac:allowArmorChange(source, "item_wear_armor")
					setPedArmor(source, math.ceil(getPedArmor(source) + math.min(item[2], armor)))
				end
				triggerClientEvent(source, "forceElementMoveUpdate", source)
			else
				takeItemFromSlot(element, slot)
				output(element, source, item[1])
				if ammo < item[2] then
					exports.mek_global:giveWeapon(source, -item[1], ammo)
					giveItem(element, item[1], item[2] - ammo)
				else
					exports.mek_global:giveWeapon(source, -item[1], item[2])
				end
				triggerClientEvent(source, "forceElementMoveUpdate", source)
			end
		end
	end

	triggerClientEvent(source, "finishItemMove", source)
end
addEvent("moveFromElement", true)
addEventHandler("moveFromElement", root, moveFromElement)

function getName(element)
	if getElementModel(element) == 2942 then
		return "ATM Makinesi"
	elseif getElementModel(element) == 2147 then
		return "buzdolabı"
	elseif getElementModel(source) == 3761 then
		return "raf"
	end

	if getElementParent(getElementParent(element)) == getResourceRootElement(getResourceFromName("mek_item-world")) then
		local itemID = tonumber(getElementData(element, "itemID")) or 0
		if itemID == 166 then
			return "video oynatıcı"
		end
	end

	if getElementType(element) == "vehicle" then
		return exports.mek_global:getVehicleName(element)
	end

	if getElementType(element) == "interior" then
		return getElementData(element, "name") .. "'in posta kutusu"
	end

	if getElementType(element) == "player" then
		return "kişi"
	end

	return "kasa"
end
