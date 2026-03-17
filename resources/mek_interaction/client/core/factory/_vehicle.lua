local interactedVehicles = {}
local hittedElement = nil

function vehicleCacheGarbage()
	interactedVehicles = {}
end

function vehicleCacheCollector(player)
	if occupiedVehicle then
		return false
	end

	local distance = getDistanceBetweenPoints3D(localPlayer.position, player.position)
	local hasEntityKey = exports.mek_item:hasItem(localPlayer, 3, player:getData("dbid"))
		or exports.mek_global:isPlayerTrialAdmin(localPlayer)

	local elementFaction = tonumber(player:getData("faction") or 0)
	local isSameFaction = exports.mek_faction:isPlayerInFaction(localPlayer, elementFaction)
		or exports.mek_global:isPlayerTrialAdmin(localPlayer)

	table.insert(interactedVehicles, player)

	if distance < 3 and hasEntityKey or isSameFaction then
		local nearestVehicleComponent = getNearestVehicleComponent(player, localPlayer.position)
		if nearestVehicleComponent then
			table.insert(interactedElements, {
				element = player,
				store = {
					callbackEvent = "vehicle.interactionDoor",
					args = {},
					icon = "",
					key = "mouse3",

					nearestComponent = nearestVehicleComponent,
				},
			})
		end
	end

	if hittedElement and hittedElement == player and hasEntityKey then
		table.insert(interactedElements, {
			element = player,
			store = {
				callbackEvent = "vehicle.interactControls",
				args = {},
				icon = "",
				key = "mouse3",
			},
		})
	end
end

function vehicleInteractionBuilder(vehicle, interactType)
	local elementDBID = tonumber(localPlayer:getData("dbid"))

	local vehicleID = tonumber(vehicle:getData("dbid"))
	local vehicleOwner = tonumber(vehicle:getData("owner"))

	local carshop = vehicle:getData("carshop")

	local interactions = {}

	if carshop then
		local salePrice = tonumber(vehicle:getData("carshop:cost") or 0)
		table.insert(interactions, {
			text = ("Satın Al (₺%s)"):format(exports.mek_global:formatMoney(salePrice)),
			callback = function()
				triggerServerEvent("carshop:buyCar", vehicle, "cash")
			end,
		})
	else
		local hasAccess = (vehicleOwner == elementDBID)
			or exports.mek_item:hasItem(localPlayer, 3, vehicleID)
			or exports.mek_integration:isPlayerManager(localPlayer)
		local isEntityInInteractedVehicle = localPlayer.vehicle == vehicle

		if hasAccess then
			if vehicle.type == "Trailer" then
				table.insert(interactions, {
					text = "Park Et",
					callback = function()
						triggerServerEvent("parkVehicle", localPlayer, vehicle)
					end,
				})
			end

			if exports.mek_vehicle:isCabriolet(vehicle) then
				table.insert(interactions, {
					text = "Üstünü Aç",
					callback = function()
						triggerServerEvent("vehicle:toggleRoof", localPlayer, vehicle)
					end,
				})
			end

			table.insert(interactions, {
				text = "Envanteri Aç",
				callback = function()
					local vehicleLocked = isVehicleLocked(vehicle)
					local vehicleDBID = getElementData(vehicle, "dbid")
					local hasKey = exports.mek_item:hasItem(localPlayer, 3, vehicleDBID)
					local isOwner = getElementData(vehicle, "owner") == getElementData(localPlayer, "dbid")

					if vehicleLocked and not isEntityInInteractedVehicle then
						exports.mek_infobox:addBox("error", "Bu araç kilitli.")
						return
					end

					if not (hasKey or isOwner or exports.mek_integration:isPlayerManager(localPlayer)) then
						exports.mek_infobox:addBox("error", "Bu aracın anahtarına sahip değilsin.")
						return
					end

					triggerServerEvent("openFreakinInventory", localPlayer, vehicle, screenSize.x / 2, screenSize.y / 2)
				end,
			})
		end

		table.insert(interactions, {
			text = "Kapı Kontrolü",
			callback = function()
				exports.mek_vehicle:openVehicleDoorGUI(vehicle)
			end,
		})

		if
			(vehicle.model == 592
			or vehicle.model == 519
			or vehicle.model == 577
			or vehicle.model == 416
			or vehicle.model == 427
			or vehicle.model == 508)
			and (localPlayer:getOccupiedVehicle() ~= vehicle)
		then
			table.insert(interactions, {
				text = "İçeri Gir",
				callback = function()
					if isVehicleLocked(vehicle) then
						exports.mek_infobox:addBox("error", "Araç kilitliyken içine girilemez.")
						return
					end
					
					if localPlayer:getOccupiedVehicle() == vehicle then
						exports.mek_infobox:addBox("error", "Bunu yapamazsınız.")
						return
					end

					triggerServerEvent("enterVehicleInterior", localPlayer, vehicle)
				end,
			})
		end
		
		if getElementData(localPlayer, "mechanic") or exports.mek_integration:isPlayerTrialAdmin(localPlayer, true) then
			table.insert(interactions, {
				text = "Mekanik",
				callback = function()
					triggerEvent("openMechanicFixWindow", localPlayer, vehicle)
				end,
			})
		end
		
		local hasFuelItem, _, itemValue = exports.mek_item:hasItem(localPlayer, 57)
		if hasFuelItem then
			table.insert(interactions, {
				text = "Benzin Doldur",
				callback = function()
					triggerServerEvent("fillFuelTankVehicle", localPlayer, vehicle, itemValue)
				end,
			})
		end

		if exports.mek_integration:isPlayerTrialAdmin(localPlayer) then
			table.insert(interactions, {
				text = "ADM: Yenile",
				callback = function()
					triggerServerEvent("vehicleManager.respawn", localPlayer, vehicle)
				end,
			})
		end

		if exports.mek_integration:isPlayerServerManager(localPlayer) then
			table.insert(interactions, {
				text = "ADM: Kaplama",
				callback = function()
					triggerEvent("item-texture.vehicleTexture", localPlayer, vehicle)
				end,
			})
		end
	end

	if interactType == "wheel" then
		createWheel(interactions, vehicle, localPlayer.position, 1)
	else
		createMenuContext(vehicle, interactions)
	end
end

addEvent("vehicle.interactControls", true)
addEventHandler("vehicle.interactControls", localPlayer, function(vehicle)
	if isWheelRendering() then
		return
	end

	vehicleInteractionBuilder(vehicle, "wheel")
	hittedElement = nil
end)

addEvent("vehicle.interactionDoor", true)
addEventHandler("vehicle.interactionDoor", localPlayer, function(vehicle)
	local nearestComponent, componentPosition = getNearestVehicleComponent(vehicle, localPlayer.position)
	local details = componentDetails[nearestComponent]

	if details then
		local interactions = {}

		table.insert(interactions, {
			text = details[2] .. " Kapat",
			callback = function()
				if isTimer(spamTimer) then
					exports.mek_infobox:addBox("error", "Bu işlemi tekrarlamak için biraz beklemelisiniz.")
					return
				end

				spamTimer = setTimer(function()
					killTimer(spamTimer)
				end, 1000, 1)

				triggerServerEvent(
					"vehicle.utils.interactionDoor",
					getResourceRootElement(getResourceFromName("mek_vehicle")),
					vehicle,
					details[1],
					vehicleTrunkState.CLOSED
				)
			end,
		})

		table.insert(interactions, {
			text = details[2] .. " Aç",
			callback = function()
				if isTimer(spamTimer) then
					exports.mek_infobox:addBox(
						"error",
						"Araç kapılarına çok hızlı bir şekilde müdahale edemezsiniz."
					)
					return
				end

				spamTimer = setTimer(function()
					killTimer(spamTimer)
				end, 1000, 1)

				triggerServerEvent(
					"vehicle.utils.interactionDoor",
					getResourceRootElement(getResourceFromName("mek_vehicle")),
					vehicle,
					details[1],
					vehicleTrunkState.OPEN
				)
			end,
		})

		createWheel(interactions, vehicle, componentPosition, 3.15)
	end
end)
