function addUpgrade(source, vehicle, itemSlot, itemID, itemValue)
	local old_upgrades = getVehicleUpgrades(vehicle)
	local old_upgrade = nil
	for key, value in ipairs(old_upgrades) do
		if value == itemValue then
			outputChatBox("[!]#FFFFFF Bu modifiye parçası zaten eklenmiş.", source, 255, 0, 0, true)
			return
		elseif getVehicleUpgradeSlotName(value) == getVehicleUpgradeSlotName(itemValue) then
			old_upgrade = value
		end
	end

	if getElementData(vehicle, "job") ~= 0 or getElementData(vehicle, "owner") == -2 then
		outputChatBox("[!]#FFFFFF Sivil araçlara modifiye parçası ekleyemezsiniz.", source, 255, 0, 0, true)
		return
	end

	if takeItemFromSlot(source, itemSlot) then
		if addVehicleUpgrade(vehicle, itemValue) then
			local data = getElementData(source, "upgrade_items") or {}

			if old_upgrade then
				giveItem(source, itemID, old_upgrade)
				if data[vehicle] then
					data[vehicle][old_upgrade] = nil
				end
			end
			exports.mek_global:sendLocalMeAction(
				source,
				"elindeki "
					.. getItemDescription(itemID, itemValue)
					.. " modifiye parçasını "
					.. exports.mek_global:getVehicleName(vehicle)
					.. " araca ekler."
			)
			exports.mek_save:saveVehicleMods(vehicle)

			if not data[vehicle] then
				data[vehicle] = {}
			end
			data[vehicle][itemValue] = getRealTime().timestamp
			if isElement(source) then
				setElementData(source, "upgrade_items", data)
			end
		else
			outputChatBox(
				"[!]#FFFFFF Bu modifiye parçası bu "
					.. exports.mek_global:getVehicleName(vehicle)
					.. " araca uygun değil.",
				source,
				255,
				194,
				14,
				true
			)
			giveItem(source, itemID, itemValue)
		end
	else
		outputChatBox("[!]#FFFFFF Eşyayı alma işlemi başarısız oldu.", source, 255, 0, 0, true)
	end
end

function moveUpgradeFromElement(upgrade)
	if isVehicleLocked(source) and getPedOccupiedVehicle(client) ~= source then
		triggerClientEvent(client, "finishItemMove", client)
		return
	end

	local data = getElementData(client, "upgrade_items")
	local admin = false
	if not data or not data[source] or not data[source][upgrade] then
		if not exports.mek_integration:isPlayerTrialAdmin(client) then
			triggerClientEvent(client, "finishItemMove", client)
			return
		else
			admin = true
		end
	end

	if hasSpaceForItem(client, 114, upgrade) then
		if removeVehicleUpgrade(source, upgrade) then
			if not admin then
				data[source][upgrade] = nil
				if isElement(source) then
					setElementData(source, "upgrade_items", data)
				end
			end

			giveItem(client, 114, upgrade)
			x_output_wrapper(source, client, 114, upgrade)
			triggerClientEvent(client, "forceElementMoveUpdate", client)

			exports.mek_save:saveVehicleMods(source)
		else
			outputChatBox("[!]#FFFFFF Modifiye parçası mevcut değil.", client, 255, 0, 0, true)
		end
	else
		outputChatBox("[!]#FFFFFF Envanteriniz dolu.", client, 255, 0, 0, true)
	end
	triggerClientEvent(client, "finishItemMove", client)
end
addEvent("item:vehicle:removeUpgrade", true)
addEventHandler("item:vehicle:removeUpgrade", root, moveUpgradeFromElement)

setTimer(function()
	for _, player in ipairs(getElementsByType("player")) do
		local data = getElementData(player, "upgrade_items")
		if data then
			local anyAtAll = false
			local changed = false
			for vehicle, mods in pairs(data) do
				local anyForVehicle = false

				for km, vm in pairs(mods) do
					if getRealTime().timestamp - vm < 5 * 60000 then
						data[vehicle][km] = nil
						changed = true
					else
						anyForVehicle = true
						anyAtAll = true
					end
				end

				if not anyForVehicle then
					data[vehicle] = nil
					changed = true
				end
			end

			if not anyAtAll then
				if isElement(player) then
					setElementData(player, "upgrade_items", data)
				end
			elseif changed then
				if isElement(player) then
					setElementData(player, "upgrade_items", data)
				end
			end
		end
	end
end, 5 * 60000, 0)
