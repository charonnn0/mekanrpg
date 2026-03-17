function dutyRequest(grantID, itemTable, skinID, factionID)
	local thePlayer = client

	local foundPackage = getGrant(thePlayer, grantID, factionID)
	if foundPackage and canPlayerUseDutyPackage(thePlayer, foundPackage[1], factionID) then
		for itemIndexID, itemTableContent in ipairs(itemTable) do
			local found = false

			for aItemIndexID, aItemTableContent in pairs(foundPackage[5]) do
				if aItemTableContent[1] == itemTableContent[1] then
					found = true
					break
				end
			end

			if not found then
				outputChatBox("Error.", thePlayer)
				return false
			end
		end

		for itemIndexID, itemTableContent in ipairs(itemTable) do
			if itemTableContent[2] > 0 then
				exports.mek_item:giveItem(thePlayer, itemTableContent[2], itemTableContent[3])
			else
				if itemTableContent[2] == -100 then
					exports.mek_sac:allowArmorChange(thePlayer, "duty_on")
					setPedArmor(thePlayer, itemTableContent[3])
				else
					local gtaWeaponID = tonumber(itemTableContent[2])
						- tonumber(itemTableContent[2])
						- tonumber(itemTableContent[2])
					local weaponSerial = exports.mek_global:createWeaponSerial(2, getElementData(thePlayer, "dbid"))
					exports.mek_item:giveItem(
						thePlayer,
						115,
						gtaWeaponID
							.. ":"
							.. weaponSerial
							.. ":"
							.. getWeaponNameFromID(gtaWeaponID)
							.. " (D):"
							.. (tonumber(itemTableContent[3]) + 1)
							.. ":1"
					)
				end
			end
		end

		savedSkin = 0
		savedClothing = 0
		savedModel = 0

		if skinID and type(skinID) == "string" then
			local skinData = split(skinID, ";")
			savedSkin = tonumber(skinData[1])
			savedClothing = tonumber(skinData[2])
			savedModel = tonumber(skinData[3])
			
			setElementModel(thePlayer, savedSkin)
			setElementData(thePlayer, "clothing_id", savedClothing)
			setElementData(thePlayer, "model", savedModel)
		end

		triggerClientEvent(thePlayer, "onPlayerDuty", thePlayer, true)
		triggerEvent("onPlayerDuty", thePlayer, true)
		setElementData(thePlayer, "duty", grantID)
		dbExec(
			exports.mek_mysql:getConnection(),
			"UPDATE characters SET skin = ?, clothing_id = ?, model = ?, duty = ? WHERE id = ?",
			savedSkin,
			savedClothing,
			savedModel,
			getElementData(thePlayer, "duty") or 0,
			getElementData(thePlayer, "dbid")
		)
	end
	return false
end
addEvent("duty.request", true)
addEventHandler("duty.request", root, dutyRequest)

function dutyOff()
	local thePlayer = client or source
	local grantID = getElementData(thePlayer, "duty") or 0

	if tonumber(grantID) > 0 then
		local savedSkin, savedClothing, savedModel = nil, nil, nil

		exports.mek_sac:allowArmorChange(thePlayer, "duty_off")
		setPedArmor(thePlayer, 0)

		local correction = 0
		local items = exports.mek_item:getItems(thePlayer)

		for itemSlot, itemCheck in ipairs(items) do
			if itemCheck[1] == 115 then
				local itemCheckExplode = split(itemCheck[2], ":")
				local serialNumberCheck = exports.mek_global:retrieveWeaponDetails(itemCheckExplode[2])
				if tonumber(serialNumberCheck[2]) == 2 then
					exports.mek_item:takeItemFromSlot(thePlayer, itemSlot - correction, false)
					correction = correction + 1
				end
			elseif itemCheck[1] == 116 then
				local checkString = string.sub(itemCheck[2], -4)
				if checkString == " (D)" then
					exports.mek_item:takeItemFromSlot(thePlayer, itemSlot - correction, false)
					correction = correction + 1
				end
			elseif itemCheck[1] == 16 then
				if not savedSkin then
					local skinData = split(tostring(itemCheck[2]), ";")
					savedSkin = tonumber(skinData[1])
					savedClothing = tonumber(skinData[2])
					savedModel = tonumber(skinData[3])
				end
			end
		end

		local foundPackage = getGrant(thePlayer, grantID, exports.mek_faction:getCurrentFactionDuty(thePlayer))
		if foundPackage then
			for itemIndexID, itemTableContent in pairs(foundPackage[5]) do
				if itemTableContent[2] > 0 then
					exports.mek_item:takeItem(thePlayer, itemTableContent[2], itemTableContent[3])
				end
			end
		end

		if savedSkin then
			setElementModel(thePlayer, savedSkin)
			setElementData(thePlayer, "clothing_id", savedClothing)
			setElementData(thePlayer, "model", savedModel)
			dbExec(
				exports.mek_mysql:getConnection(),
				"UPDATE characters SET skin = ?, clothing_id = ?, model = ?, duty = 0 WHERE id = ?",
				savedSkin or 0,
				savedClothing or 0,
				savedModel or 0,
				getElementData(thePlayer, "dbid")
			)
		else
			exports.mek_item:doItemGiveawayChecks(thePlayer, 16)
			dbExec(
				exports.mek_mysql:getConnection(),
				"UPDATE characters SET duty = 0 WHERE id = ?",
				getElementData(thePlayer, "dbid")
			)
		end

		setElementData(thePlayer, "duty", 0)

		triggerClientEvent(thePlayer, "onPlayerDuty", thePlayer, false)
		triggerEvent("onPlayerDuty", thePlayer, false)
	end
end
addEvent("duty.offDuty", true)
addEventHandler("duty.offDuty", root, dutyOff)
