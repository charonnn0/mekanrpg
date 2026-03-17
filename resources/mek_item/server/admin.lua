function getNearbyItems(thePlayer, commandName)
	if
		exports.mek_integration:isPlayerTrialAdmin(thePlayer)
		or exports.mek_global:isAdminOnDuty(thePlayer)
		or exports.mek_global:isPlayerServerManager(thePlayer)
	then
		local posX, posY, posZ = getElementPosition(thePlayer)
		outputChatBox("Nearby Items:", thePlayer, 255, 126, 0)
		local count = 0

		for k, theObject in
			ipairs(getElementsByType("object", getResourceRootElement(getResourceFromName("mek_item-world"))))
		do
			local dbid = getElementData(theObject, "id")

			if dbid then
				local x, y, z = getElementPosition(theObject)
				local distance = getDistanceBetweenPoints3D(posX, posY, posZ, x, y, z)

				if
					distance <= 10
					and getElementDimension(theObject) == getElementDimension(thePlayer)
					and getElementInterior(theObject) == getElementInterior(thePlayer)
					and getElementData(theObject, "itemID") ~= 169
				then
					outputChatBox(
						"#"
							.. dbid
							.. (getElementData(theObject, "protected") and ("(" .. getElementData(
								theObject,
								"protected"
							) .. ")") or "")
							.. " by "
							.. (exports.mek_cache:getCharacterName(getElementData(theObject, "creator"), true) or "?")
							.. " - "
							.. (getItemName(getElementData(theObject, "itemID")) or "?")
							.. "("
							.. getElementData(theObject, "itemID")
							.. "): "
							.. tostring(getElementData(theObject, "itemValue") or 1),
						thePlayer,
						255,
						126,
						0
					)
					count = count + 1
				end
			end
		end

		if count == 0 then
			outputChatBox("[!]#FFFFFF Yok.", thePlayer, 255, 0, 0, true)
		end
	end
end
addCommandHandler("nearbyitems", getNearbyItems, false, false)

function delItem(thePlayer, commandName, targetID)
	if exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
		if not targetID then
			outputChatBox("Kullanım: " .. commandName .. " [ID]", thePlayer, 255, 194, 14)
		else
			local object = nil
			targetID = tonumber(targetID)

			for key, value in
				ipairs(getElementsByType("object", getResourceRootElement(getResourceFromName("mek_item-world"))))
			do
				local dbid = getElementData(value, "id")
				if dbid and dbid == targetID then
					object = value
					break
				end
			end

			if object and getElementData(object, "itemID") ~= 169 then
				local id = getElementData(object, "id")
				local result = dbExec(mysql:getConnection(), "DELETE FROM worlditems WHERE id = ?", id)

				outputChatBox("Item #" .. id .. " deleted.", thePlayer)
				destroyElement(object)
			else
				outputChatBox("Invalid item ID.", thePlayer, 255, 0, 0)
			end
		end
	end
end
addCommandHandler("delitem", delItem, false, false)

function delNearbyItems(thePlayer, commandName)
	if exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
		local posX, posY, posZ = getElementPosition(thePlayer)
		outputChatBox("Nearby Items:", thePlayer, 255, 126, 0)
		local count = 0

		for k, theObject in
			ipairs(getElementsByType("object", getResourceRootElement(getResourceFromName("mek_item-world"))))
		do
			local dbid = getElementData(theObject, "id")

			if dbid then
				local x, y, z = getElementPosition(theObject)
				local distance = getDistanceBetweenPoints3D(posX, posY, posZ, x, y, z)

				if
					distance <= 10
					and getElementDimension(theObject) == getElementDimension(thePlayer)
					and getElementInterior(theObject) == getElementInterior(thePlayer)
					and getElementData(theObject, "itemID") ~= 169
				then
					local id = getElementData(theObject, "id")
					dbExec(mysql:getConnection(), "DELETE FROM worlditems WHERE id = ?", id)
					destroyElement(theObject)
					count = count + 1
				end
			end
		end

		outputChatBox(count .. " Items deleted.", thePlayer, 255, 126, 0)
	end
end
addCommandHandler("delnearbyitems", delNearbyItems, false, false)

function setItemForMovement(thePlayer, commandName, targetID)
	if
		exports.mek_integration:isPlayerTrialAdmin(thePlayer)
		or exports.mek_integration:isPlayerServerManager(thePlayer)
	then
		if not targetID then
			outputChatBox("Kullanım: " .. commandName .. " [ID]", thePlayer, 255, 194, 14)
		else
			local object = nil
			targetID = tonumber(targetID)

			for key, value in
				ipairs(getElementsByType("object", getResourceRootElement(getResourceFromName("mek_item-world"))))
			do
				local dbid = getElementData(value, "id")
				if dbid and dbid == targetID then
					object = value
					break
				end
			end

			if object and getElementData(object, "itemID") ~= 169 then
				triggerClientEvent(thePlayer, "item:move", root, object)
			else
				outputChatBox("Invalid item ID.", thePlayer, 255, 0, 0)
			end
		end
	end
end
addCommandHandler("moveitem", setItemForMovement, false, false)

function delAllItemInstances(thePlayer, commandName, itemID, itemValue)
	if exports.mek_integration:isPlayerServerManager(thePlayer) then
		if not tonumber(itemID) or tonumber(itemID) % 1 ~= 0 then
			outputChatBox("Kullanım: /" .. commandName .. " [Item ID] [Item Value]", thePlayer, 255, 194, 14)
			outputChatBox("Deletes all the item instances from everywhere in game.", thePlayer, 150, 150, 50)
		else
			local theResource = getResourceFromName("mek_item-world")
			if theResource and deleteAll(itemID, itemValue) then
				if not itemValue or itemValue == "" then
					itemValue = "<Any value>"
				end

				restartResource(theResource)

				setTimer(function()
					restartResource(getThisResource())
					outputChatBox(
						"All the item instances (Item ID #"
							.. itemID
							.. ", ItemValue: "
							.. itemValue
							.. ") have been deleted.",
						thePlayer,
						0,
						255,
						0
					)
					exports.mek_global:sendMessageToAdmins(
						"[ADM] "
							.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
							.. " has deleted all the item instances (Item ID #"
							.. itemID
							.. ", ItemValue: "
							.. itemValue
							.. ") from everywhere in game."
					)
				end, 5000, 1)
			else
				outputChatBox(
					"Failed to delete all item instances (Item ID #"
						.. itemID
						.. ", Value: "
						.. itemValue
						.. "). 'item-world' resource required.",
					thePlayer,
					255,
					0,
					0
				)
			end
		end
	end
end
addCommandHandler("delallitems", delAllItemInstances, false, false)

function deleteAllItemsFromAnInterior(thePlayer, commandName, intID, dayOld, restartRes)
	if exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
		if
			not tonumber(intID)
			or tonumber(intID) < 0
			or tonumber(intID) % 1 ~= 0
			or not tonumber(dayOld)
			or tonumber(dayOld) < 0
			or tonumber(dayOld) % 1 ~= 0
		then
			outputChatBox("Kullanım: /" .. commandName .. " [Int ID] [Day old of Items]", thePlayer, 255, 194, 14)
			outputChatBox(
				"Deletes all the items within a specified interior that older than an interval of item's day old.",
				thePlayer,
				150,
				150,
				50
			)
			if exports.mek_integration:isPlayerServerManager(thePlayer) then
				outputChatBox("Kullanım: /" .. commandName .. " [Int ID] [Day old of Items]", thePlayer, 255, 194, 14)
				outputChatBox(
					"Deletes all the items within a specified interior or world map that older than an interval of item's day old.",
					thePlayer,
					150,
					150,
					50
				)
			end
		else
			if tonumber(intID) == 0 and not exports.mek_integration:isPlayerServerManager(thePlayer) then
				outputChatBox("Only Head+ Admins can delete all item instances from world map.", thePlayer, 255, 0, 0)
				return false
			end

			if deleteAllItemsWithinInt(intID, dayOld) then
				outputChatBox(
					"All the item instances that is older than "
						.. dayOld
						.. " days wthin interior ID #"
						.. intID
						.. " have been deleted.",
					thePlayer,
					0,
					255,
					0
				)

				if restartRes == 1 and getResourceFromName("mek_item-world") then
					executeCommandHandler("saveall", thePlayer)
					setTimer(function()
						outputChatBox("Server is cleaning up world items, please standby!", root)
						restartResource(getResourceFromName("mek_item-world"))
					end, 10000, 1)
				end

				exports.mek_global:sendMessageToAdmins(
					"[ADM] "
						.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
						.. " has deleted all item instances that is older than "
						.. dayOld
						.. " days within interior ID #"
						.. intID
						.. "."
				)
				return true
			else
				outputChatBox(
					"Failed to delete items within a specified interior ID #" .. intID .. ".",
					thePlayer,
					255,
					0,
					0
				)
				return false
			end
		end
	end
end
addCommandHandler("delitemsfromint", deleteAllItemsFromAnInterior, false, false)
