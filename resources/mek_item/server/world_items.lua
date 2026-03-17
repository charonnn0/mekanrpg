function isProtected(player, item)
	if not isElement(item) then
		if item then
			local team = getPlayerTeam(player)
			if item[4] ~= 0 and (team and getElementData(team, "id") ~= item[4]) then
				return true
			end
			return false
		end
	else
		local protected = getElementData(item, "protected")
		local team = getPlayerTeam(player)
		if not protected or (team and getElementData(team, "id") == protected) then
			return false
		end
		return true
	end
end

function canPickup(player, item)
	if isProtected(player, item) then
		if isElement(item) then
			if
				getElementDimension(item) > 0
				and (hasItem(player, 4, getElementDimension(item)) or hasItem(player, 5, getElementDimension(item)))
			then
				return true
			end
		end
		return false
	else
		if isElement(item) then
			if exports["mek_item-world"]:can(player, "pickup", item) then
				return true
			else
				return false
			end
		end
	end
	return true
end

function canMove(player, item)
	if isProtected(player, item) then
		if isElement(item) then
			if
				getElementDimension(item) > 0
				and (hasItem(player, 4, getElementDimension(item)) or hasItem(player, 5, getElementDimension(item)))
			then
				return true
			end
		end
		return false
	else
		if isElement(item) then
			if exports["mek_item-world"]:can(player, "move", item) then
				return true
			else
				return false
			end
		end
	end
	return true
end

function protectItem(faction, item, slot)
	if getElementData(source, "itemID") then
		local itemID = getElementData(source, "itemID")
		local index = getElementData(source, "id")
		if itemID == 169 then
			return false
		end

		if type(faction) == "number" and exports.mek_global:isAdminOnDuty(client) then
			local protected = getElementData(source, "protected")
			local out = 0
			if protected then
				setElementData(source, "protected", false)
				outputChatBox("Unset", client, 0, 255, 0)
				out = 0
			else
				setElementData(source, "protected", faction)
				outputChatBox(
					"Set to " .. faction .. " - if you want a different faction, /itemprotect [faction id or -100]",
					client,
					255,
					0,
					0
				)
				out = faction
			end
			result = dbExec(
				mysql:getConnection(),
				"UPDATE worlditems SET protected = " .. faction .. " WHERE id = " .. index
			)
		end
	else
		if type(faction) == "number" and exports.mek_global:isAdminOnDuty(client) then
			local protected = item[4]
			if protected ~= 0 and protected ~= nil then
				updateProtection(item, 0, slot, source)
				outputChatBox("Unset", client, 0, 255, 0)
				out = 0
			else
				updateProtection(item, faction, slot, source)
				outputChatBox(
					"Set to " .. faction .. " - if you want a different faction, /itemprotect [faction id or -100]",
					client,
					255,
					0,
					0
				)
				out = faction
			end
			result = dbExec(
				mysql:getConnection(),
				"UPDATE items SET `protected` = " .. out .. " WHERE `index` = " .. tonumber(item[3])
			)
		end
	end
end
addEvent("protectItem", true)
addEventHandler("protectItem", root, protectItem)

local masks = getMasks()

function dropItem(itemID, x, y, z, ammo, keepammo)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if isPedDead(source) then
		triggerClientEvent(source, "finishItemDrop", source)
		return false
	end

	local interior = getElementInterior(source)
	local dimension = getElementDimension(source)

	local rz2 = getPedRotation(source)

	if not ammo then
		local itemSlot = itemID
		local itemID, itemValue = unpack(getItems(source)[itemSlot])

		local weaponBlock = false

		if itemID == 115 then
			local itemCheckExplode = split(itemValue, ":")
			local weaponDetails = exports.mek_global:retrieveWeaponDetails(itemCheckExplode[2])
			if tonumber(weaponDetails[2]) and tonumber(weaponDetails[2]) == 2 then
				outputChatBox("[!]#FFFFFF Bu eşyayı yere koyamazsınız.", source, 255, 0, 0, true)
				weaponBlock = true
			end
		elseif itemID == 116 then
			local ammoDetails = split(itemValue, ":")
			local checkString = string.sub(ammoDetails[3], -4)
			if checkString == " (D)" then
				outputChatBox("[!]#FFFFFF Bu eşyayı yere koyamazsınız.", source, 255, 0, 0, true)
				weaponBlock = true
			end
		end

		if
			itemID == 60
			or itemID == 137
			or itemID == 138
			or itemID == 134
			or itemID == 115
			or itemID == 116
			or itemID == 175 and not exports.mek_integration:isPlayerAdmin1(source)
		then
			outputChatBox("[!]#FFFFFF Bu eşyayı yere koyamazsınız.", source, 255, 0, 0, true)
		elseif (itemID == 81 or itemID == 103) and dimension == 0 then
			outputChatBox("You need to drop this item in an interior.", source)
		elseif weaponBlock then
		elseif itemID == 139 then
			outputChatBox("[!]#FFFFFF Bu eşyayı yere koyamazsınız.", source, 255, 0, 0, true)
		else
			local keypadDoorInterior = nil
			if itemID == 48 and countItems(source, 48) == 1 then
				if getCarriedWeight(source) > 10 - getItemWeight(48, 1) then
					triggerClientEvent(source, "finishItemDrop", source)
					return
				end
			elseif itemID == 134 then
				outputChatBox("[!]#FFFFFF Bu eşyayı yere koyamazsınız.", source, 255, 0, 0, true)
			elseif itemID == 147 then
				local dimension = getElementDimension(source)
				if
					dimension > 0
					or (exports.mek_integration:isPlayerSeniorAdmin(source) and exports.mek_global:isAdminOnDuty(source))
					or exports.mek_integration:isPlayerServerManager(source)
				then
					local splitedItem = split(itemValue, ";")
					local url = splitedItem[1]
					local texture = splitedItem[2]
					if url and texture then
						if exports.mek_texture:newTexture(source, url, texture) then
							takeItem(source, 147, itemValue)
						end
						triggerClientEvent(source, "finishItemDrop", source)
						return
					end
				end
			elseif itemID == 169 then
				local maxRange = 10
				local doorOutside = nil
				local doorInside = nil
				local validInterior = false
				local validDropper = false
				local interiorName = "Bilinmiyor"
				local isIntLocked = true

				for i, interior in ipairs(exports.mek_pool:getPoolElementsByType("interior")) do
					if isElement(interior) and getElementData(interior, "dbid") == tonumber(itemValue) then
						validInterior = true
						interiorName = getElementData(interior, "name")
						local status = getElementData(interior, "status")
						isIntLocked = status.locked
						
						if tonumber(status.owner) == getElementData(source, "dbid") then
							validDropper = true
							doorOutside = getElementData(interior, "entrance")
							doorInside = getElementData(interior, "exit")
							keypadDoorInterior = interior
							break
						end
					end
				end

				if not validInterior then
					triggerClientEvent(source, "finishItemDrop", source)
					return false
				end

				if not validDropper then
					triggerClientEvent(source, "finishItemDrop", source)
					return false
				end

				if isIntLocked then
					triggerClientEvent(source, "finishItemDrop", source)
					return false
				end

				if not doorOutside or not doorInside then
					triggerClientEvent(source, "finishItemDrop", source)
					return false
				end

				if interior == doorOutside.int and dimension == doorOutside.dim then
					if
						getDistanceBetweenPoints3D(x, y, z, doorOutside.x, doorOutside.y, doorOutside.z) > maxRange
					then
						triggerClientEvent(source, "finishItemDrop", source)
						return false
					end
				elseif interior == doorInside.int and dimension == tonumber(itemValue) then
					if getDistanceBetweenPoints3D(x, y, z, doorInside.x, doorInside.y, doorInside.z) > maxRange then
						triggerClientEvent(source, "finishItemDrop", source)
						return false
					end
				else
					triggerClientEvent(source, "finishItemDrop", source)
					return false
				end
			end

			local smallestID = exports.mek_mysql:getSmallestID("worlditems")

			local insert = dbExec(
				mysql:getConnection(),
				"INSERT INTO worlditems SET id = ?, itemid = ?, itemvalue = ?, creationdate = NOW(), x = ?, y = ?, z = ?, dimension = ?, interior = ?, rz = ?, creator = ?",
				tostring(smallestID),
				itemID,
				itemValue,
				x,
				y,
				z,
				dimension,
				interior,
				rz2,
				getElementData(source, "dbid")
			)
			if insert then
				local id = smallestID

				setPedAnimation(source, "CARRY", "putdwn", 500, false, false, true)

				if not getPedOccupiedVehicle(source) then
					toggleAllControls(source, true, true, true)
				end

				local modelid = getItemModel(tonumber(itemID), itemValue)

				if itemID == 80 then
					local text = tostring(itemValue)
					local text2 = tostring(itemValue)
					local pos = text:find(":")
					local pos2 = text:find(":")
					if pos then
						text = text:sub(pos + 1)
						modelid = text
					end
					if pos2 then
						name = text2:sub(1, pos - 1)
					end
				elseif itemID == 178 then
					local yup = split(itemValue, ":")
					name = ("book titled " .. yup[1] .. " by " .. yup[2])
				end

				local rx, ry, rz, zoffset = getItemRotInfo(itemID)
				local obj = exports["mek_item-world"]:createItem(
					id,
					itemID,
					itemValue,
					modelid,
					x,
					y,
					z + zoffset - 0.05,
					rx,
					ry,
					rz + rz2
				)
				exports.mek_pool:allocateElement(obj)

				setElementInterior(obj, interior)
				setElementDimension(obj, dimension)

				if itemID == 76 then
					moveObject(obj, 200, x, y, z + zoffset, 90, 0, 0)
				else
					moveObject(obj, 200, x, y, z + zoffset)
				end

				local objScale = getItemScale(tonumber(itemID))
				if objScale then
					setObjectScale(obj, objScale)
				end

				local objDoubleSided = getItemDoubleSided(tonumber(itemID))
				if objDoubleSided then
					setElementDoubleSided(obj, objDoubleSided)
				end

				local objTexture = getItemTexture(tonumber(itemID), itemValue)
				if objTexture then
					for objTexKey, objTexVal in ipairs(objTexture) do
						exports["mek_item-texture"]:addTexture(obj, objTexVal[2], objTexVal[1])
					end
				end

				setElementData(obj, "creator", getElementData(source, "dbid"))

				local permissions = { use = 1, move = 1, pickup = 1, useData = {}, moveData = {}, pickupData = {} }
				setElementData(obj, "worlditem.permissions", permissions)

				if itemID ~= 134 then
					takeItemFromSlot(source, itemSlot)
				end

				doItemGiveawayChecks(source, itemID, itemValue)

				if itemID == 166 then
					for i, player in ipairs(getElementsByType("player")) do
						if getElementDimension(player) == getElementDimension(obj) then
							triggerEvent("fakevideo:loadDimension", player)
						end
					end
				end

				if itemID == 169 then
					triggerEvent("installKeypad", source, obj, keypadDoorInterior)
				end

				if itemID == 134 then
					exports.mek_global:sendLocalMeAction(
						source,
						"yere ₺" .. exports.mek_global:formatMoney(itemValue) .. " bırakır."
					)
				elseif (itemID == 80 or itemID == 178) and tostring(itemValue):find(":") then
					exports.mek_global:sendLocalMeAction(source, "yere bir " .. name .. " bırakır.")
				else
					exports.mek_global:sendLocalMeAction(
						source,
						"yere bir " .. getItemName(itemID, itemValue) .. " bırakır."
					)
				end
			end
		end
	else
		if getElementData(source, "duty") then
			outputChatBox("You can't drop your weapons while being on duty.", source, 255, 0, 0)
		elseif tonumber(getElementData(source, "job")) == 4 and itemID == 41 then
			outputChatBox("You can't drop this spray can.", source, 255, 0, 0)
		else
			if ammo <= 0 then
				triggerClientEvent(source, "finishItemDrop", source)
				return
			end

			outputChatBox(
				"You dropped a " .. (getWeaponNameFromID(itemID) or "Vücut Zırhı") .. ".",
				source,
				255,
				194,
				14
			)

			setPedAnimation(source, "CARRY", "putdwn", 500, false, false, true)

			if getPedOccupiedVehicle(source) then
				if getElementModel(getPedOccupiedVehicle(source)) == 490 then
				end
			else
				toggleAllControls(source, true, true, true)
			end

			if itemID == 100 then
				z = z + 0.1
				setPedArmor(source, 0)
			end

			local smallestID = exports.mek_mysql:getSmallestID("worlditems")
			local query = dbExec(
				mysql:getConnection(),
				"INSERT INTO worlditems (id, itemid, itemvalue, creationdate, x, y, z, dimension, interior, rz, creator) VALUES (?, ?, ?, NOW(), ?, ?, ?, ?, ?, ?)",
				tostring(smallestID),
				-itemID,
				ammo,
				x,
				y,
				z + 0.1,
				dimension,
				interior,
				rz2,
				getElementData(source, "dbid")
			)

			if query then
				local id = smallestID

				exports.mek_global:takeWeapon(source, itemID)
				if keepammo then
					exports.mek_global:giveWeapon(source, itemID, keepammo)
				end

				local modelid = 2969
				if itemID == 100 then
					modelid = 1242
				elseif itemID == 42 then
					modelid = 2690
				else
					modelid = weaponModels[itemID]
				end

				local obj =
					exports["mek_item-world"]:createItem(id, -itemID, ammo, modelid, x, y, z - 0.4, 75, -10, rz2)
				exports.mek_pool:allocateElement(obj)

				setElementInterior(obj, interior)
				setElementDimension(obj, dimension)

				moveObject(obj, 200, x, y, z + 0.1)

				setElementData(obj, "creator", getElementData(source, "dbid"))

				exports.mek_global:sendLocalMeAction(source, "dropped a " .. getItemName(-itemID) .. ".")

				triggerClientEvent(source, "saveGuns", source, getPlayerName(source))
			end
		end
	end

	triggerClientEvent(source, "finishItemDrop", source)
end
addEvent("dropItem", true)
addEventHandler("dropItem", root, dropItem)

function doItemGiveawayChecks(player, itemID)
	local source = player
	local mask = masks[itemID]

	if mask and getElementData(source, mask[1]) and not hasItem(source, itemID) then
		exports.mek_global:sendLocalMeAction(source, mask[3] .. ".")
		setElementData(source, mask[1], nil)
	end

	local requiredClothesValue = getElementModel(source)
		.. ";"
		.. getElementData(source, "clothing_id")
		.. ";"
		.. getElementData(source, "model")
	if itemID == 16 and not hasItem(source, 16, tonumber(requiredClothesValue) or requiredClothesValue) then
		local gender = getElementData(source, "gender")
		local race = getElementData(source, "race")

		if gender == 0 then
			if race == 0 then
				setElementModel(source, 80)
			elseif race == 1 or race == 2 then
				setElementModel(source, 252)
			end
		elseif gender == 1 then
			if race == 0 then
				setElementModel(source, 139)
			elseif race == 1 then
				setElementModel(source, 138)
			elseif race == 2 then
				setElementModel(source, 140)
			end
		end

		setElementData(source, "clothing_id", 0)
		setElementData(source, "model", 0)
		dbExec(
			mysql:getConnection(),
			"UPDATE characters SET skin = ?, clothing_id = 0, model = 0 WHERE id = ?",
			getElementModel(source),
			getElementData(source, "dbid")
		)
	end

	if itemID == 76 and shields[source] and not hasItem(source, 76) then
		destroyElement(shields[source])
		shields[source] = nil
	end

	if itemID == 90 then
		triggerEvent("artifacts.remove", source, source, "helmet")
	elseif itemID == 26 then
		triggerEvent("artifacts.remove", source, source, "gasmask")
	elseif itemID == 160 then
		triggerEvent("artifacts.remove", source, source, "briefcase")
	elseif itemID == 48 then
		triggerEvent("artifacts.remove", source, source, "backpack")
	elseif itemID == 162 then
		triggerEvent("artifacts.remove", source, source, "kevlar")
	elseif itemID == 163 then
		triggerEvent("artifacts.remove", source, source, "dufflebag")
	elseif itemID == 164 then
		triggerEvent("artifacts.remove", source, source, "medicbag")
	elseif itemID == 171 then
		triggerEvent("artifacts.remove", source, source, "bikerhelmet")
	elseif itemID == 172 then
		triggerEvent("artifacts.remove", source, source, "fullfacehelmet")
	end
	
	if itemID == 6 then
		local hasRadio, _, radioFrequency = exports.mek_item:hasItem(source, 6)
		if hasRadio then
			setElementData(source, "radio_frequency", radioFrequency)
		else
			removeElementData(source, "radio_frequency")
		end
	end
end

local function moveItem(item, x, y, z)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if isPedDead(source) then
		return false
	end

	local itemID = getElementData(item, "itemID")

	if itemID == 169 then
		return false
	end

	if not exports.mek_global:isAdminOnDuty(source) then
		if itemID >= 31 and itemID <= 43 then
			outputChatBox(getItemName(itemID) .. " can't be moved this way.", source, 255, 0, 0)
			return false
		end
	end

	local id = getElementData(item, "id")
	if not z then
		destroyElement(item)
		dbExec(mysql:getConnection(), "DELETE FROM worlditems WHERE id = " .. id)
		return
	end

	if not canMove(source, item) then
		outputChatBox("You can not move this item. Contact an admin via F2.", source, 255, 0, 0)
		return
	end

	if not exports.mek_integration:isPlayerTrialAdmin(source) and (itemID == 81 or itemID == 103) then
		return
	end

	if itemID == 138 then
		if not exports.mek_integration:isPlayerTrialAdmin(source) then
			outputChatBox("Only a Lead+ admin can move this item.", source, 255, 0, 0)
			return
		end
	end

	if itemID == 139 and not exports.mek_integration:isPlayerTrialAdmin(source) then
		outputChatBox("Only a Super+ admin can move this item.", source, 255, 0, 0)
		return
	end

	for i, player in ipairs(getElementsByType("player")) do
		if getPedContactElement(player) == item then
			return
		end
	end

	local result = dbExec(
		mysql:getConnection(),
		"UPDATE worlditems SET x = "
			.. x
			.. ", y = "
			.. y
			.. ", z = "
			.. z
			.. " WHERE id = "
			.. getElementData(item, "id")
	)
	if result then
		if itemID > 0 then
			local rx, ry, rz, zoffset = getItemRotInfo(itemID)
			z = z + zoffset
		elseif itemID == 100 then
			z = z + 0.1
		end
		setElementPosition(item, x, y, z)
	end
end
addEvent("moveItem", true)
addEventHandler("moveItem", root, moveItem)

local function rotateItem(item, rz)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not exports.mek_integration:isPlayerTrialAdmin(source) then
		return
	end

	local id = getElementData(item, "id")
	if not rz then
		destroyElement(item)
		dbExec(mysql:getConnection(), "DELETE FROM worlditems WHERE id = " .. id)
		return
	end

	local rx, ry, rzx = getElementRotation(item)
	rz = rz + rzx
	local result = dbExec(mysql:getConnection(), "UPDATE worlditems SET rz = " .. rz .. " WHERE id = " .. id)
	if result then
		setElementRotation(item, rx, ry, rz)
	end
end
addEvent("rotateItem", true)
addEventHandler("rotateItem", root, rotateItem)

function pickupItem(object, leftammo)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not isElement(object) then
		return false
	end

	local x, y, z = getElementPosition(source)
	local ox, oy, oz = getElementPosition(object)

	if not (getDistanceBetweenPoints3D(x, y, z, ox, oy, oz) < 10) then
		return false
	end

	if getElementData(object, "transfering") then
		return false
	end

	setElementData(object, "transfering", true)

	local id = tonumber(getElementData(object, "id"))
	if not id then
		outputChatBox("[!]#FFFFFF Bir sorun oluştu.", source, 255, 0, 0, true)
		destroyElement(object)
		return false
	end

	local itemID = getElementData(object, "itemID")
	if not canPickup(source, object) then
		outputChatBox("[!]#FFFFFF Bu öğeyi alamazsınız, F2 ile bir yetkiliye başvurun.", source, 255, 0, 0, true)
		removeElementData(object, "transfering")
		return false
	end

	local itemValue = getElementData(object, "itemValue") or 1

	if itemID >= 31 and itemID <= 43 then
		local creator = getElementData(object, "creator") or 0
		local picker = getElementData(source, "dbid")

		if creator ~= picker then
			local accountCreator = exports.mek_cache:getAccountFromCharacterID(creator)
			if tonumber(accountCreator.id) == getElementData(source, "account_id") then
				outputChatBox(
					"[!]#FFFFFF Varlıkların aynı hesaptaki karakterleri veya bir oyuncunun sahip olduğu çoklu hesaplar arasında aktarılması kesinlikle yasaktır.",
					source,
					255,
					0,
					0,
					true
				)
				removeElementData(object, "transfering")
				return false
			end
		end
	end

	if itemID == 115 then
		if isThisGunDuplicated(itemValue, source) then
			destroyElement(object)
			dbExec(mysql:getConnection(), "DELETE FROM worlditems WHERE id = ?", id)
			outputChatBox(
				"[!]#FFFFFF Silah çoğaltılması tespit edilerek silahınız silindi, üzgünüz.",
				source,
				255,
				0,
				0,
				true
			)
			return false
		end
	end

	if (itemID == 138 or itemID == 139) and not exports.mek_integration:isPlayerTrialAdmin(source) then
		outputChatBox("[!]#FFFFFF Bu öğeyi sadece bir yetkili alabilir.", source, 255, 0, 0, true)
		removeElementData(object, "transfering")
		return false
	end

	setPedAnimation(source, "CARRY", "liftup", 600, false, true, true)

	if itemID > 0 then
		dbExec(mysql:getConnection(), "DELETE FROM worlditems WHERE id = ?", id)
		while #getItems(object) > 0 do
			moveItem(object, source, 1)
		end
	else
		if itemID == -100 then
			dbExec(mysql:getConnection(), "DELETE FROM worlditems WHERE id = ?", id)
			exports.mek_sac:allowArmorChange(source, "item_pickup_armor")
			setPedArmor(source, itemValue)
		else
			if leftammo and itemValue > leftammo then
				itemValue = itemValue - leftammo
				setElementData(object, "itemValue", itemValue)
				dbExec(mysql:getConnection(), "UPDATE worlditems SET itemvalue = ? WHERE id = ?", itemValue, id)
				itemValue = leftammo
			else
				dbExec(mysql:getConnection(), "DELETE FROM worlditems WHERE id = ?", id)
			end
			exports.mek_global:giveWeapon(source, -itemID, itemValue, true)
		end
	end

	destroyElement(object)

	if itemID == 134 then
		exports.mek_global:giveMoney(source, itemValue)
		exports.mek_global:sendLocalMeAction(source, "yerden ₺" .. exports.mek_global:formatMoney(itemValue) .. " alır.")
	else
		giveItem(source, itemID, itemValue)
		exports.mek_global:sendLocalMeAction(source, "yerden bir " .. getItemName(itemID, itemValue) .. " alır.")
	end
end
addEvent("pickupItem", true)
addEventHandler("pickupItem", root, pickupItem)

function removeItemTransferingState()
	for _, object in pairs(exports.mek_pool:getPoolElementsByType("object")) do
		removeElementData(object, "transfering")
	end
end
addEventHandler("onResourceStop", resourceRoot, removeItemTransferingState)
