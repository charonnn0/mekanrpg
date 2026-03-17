function menuPlayerCollector(player)
	if player == localPlayer then
		return
	end

	local distance = getDistanceBetweenPoints3D(localPlayer.position, player.position)
	if distance >= 1.2 then
		return
	end

	local dead = player:getData("dead") or false
	local dbid = tonumber(player:getData("dbid") or 0)

	local interactions = {}

	local playerDrag = localPlayer:getData("dragged_player")
	local targetDrag = player:getData("is_dragged")

	if not targetDrag and not playerDrag then
		table.insert(interactions, {
			text = "Sürükle",

			callback = function()
				if not isElement(player) or not player:getData("logged") then
					destroyMenuContext()
					return
				end

				if localPlayer:getData("dead") then
					exports.mek_infobox:addBox("error", "Baygın olduğunuz için kimseyi sürükleyemezsiniz.")
					return
				end

				if isPedInVehicle(localPlayer) then
					exports.mek_infobox:addBox("error", "Araçta olduğunuz için kimseyi sürükleyemezsiniz.")
					return
				end

				if localPlayer:getData("restrained") then
					exports.mek_infobox:addBox("error", "Bağlı olduğunuz için kimseyi sürükleyemezsiniz.")
					return
				end

				local hasPerks = exports.mek_faction:isPlayerInFaction(localPlayer, { 1, 2, 3, 4 })
					or exports.mek_integration:isPlayerManager(localPlayer, true)
				if not hasPerks then
					exports.mek_infobox:addBox(
						"info",
						player.name:gsub("_", " ") .. " isimli oyuncuya sürükleme isteği gönderdiniz."
					)
					createAskContext({
						title = "Sürükle",
						description = localPlayer.name:gsub("_", " ")
							.. " sizi sürüklemek istiyor, kabul ediyor musunuz?",

						asker = localPlayer,
						target = player,
					}, function()
						if localPlayer:getData("dead") then
							exports.mek_infobox:addBox("error", "Baygın olduğunuz için kimseyi sürükleyemezsiniz.")
							return
						end

						if isPedInVehicle(localPlayer) then
							exports.mek_infobox:addBox("error", "Araçta olduğunuz için kimseyi sürükleyemezsiniz.")
							return
						end

						if localPlayer:getData("restrained") then
							exports.mek_infobox:addBox("error", "Bağlı olduğunuz için kimseyi sürükleyemezsiniz.")
							return
						end

						triggerServerEvent("legal.drag", localPlayer, player)
					end, function()
						exports.mek_infobox:addBox(
							"error",
							player.name:gsub("_", " ")
								.. " isimli oyuncuya gönderdiğiniz sürükleme isteği reddedildi."
						)
					end)
					return
				end

				triggerServerEvent("legal.drag", localPlayer, player)
				destroyMenuContext()
			end,
		})
	elseif playerDrag and playerDrag == player and playerDrag then
		table.insert(interactions, {
			text = "Sürüklemeyi Bırak",

			callback = function()
				if not isElement(player) or not player:getData("logged") then
					destroyMenuContext()
					return
				end

				triggerServerEvent("legal.stopDrag", localPlayer, player)
				destroyMenuContext()
			end,
		})
	end

	table.insert(interactions, {
		text = "Üstünü Ara",

		callback = function()
			if not isElement(player) or not player:getData("logged") then
				destroyMenuContext()
				return
			end

			if not player:getData("restrained") then
				exports.mek_infobox:addBox("error", "Kişinin üstünü arayabilmek için kelepçelemeniz gerekiyor.")
				return
			end

			triggerServerEvent("items.searchPlayer", localPlayer, player)
			destroyMenuContext()
		end,
	})

	local restrained = player:getData("restrained") or false
	local restrainedItem = tonumber(player:getData("restrained_item") or 0)

	local hasHandcuffItem = exports.mek_item:hasItem(localPlayer, 45)
	local hasRopeItem = exports.mek_item:hasItem(localPlayer, 46)

	if not restrained then
		if hasHandcuffItem or hasRopeItem then
			local actionName = hasRopeItem and "Ellerini bağla" or (hasHandcuffItem and "Kelepçele" or "")

			table.insert(interactions, {
				text = actionName,

				callback = function()
					if not isElement(player) or not player:getData("logged") then
						destroyMenuContext()
						return
					end

					if restrained then
						exports.mek_infobox:addBox("error", "Bu oyuncu zaten bağlı, tekrardan bağlayamazsınız.")
						return
					end

					local restrainTypeID = hasRopeItem and 46 or 45
					triggerServerEvent("restrain.server", localPlayer, player, restrainTypeID)
					destroyMenuContext()
				end,
			})
		end
	else
		local actionName = restrainedItem == 46 and "İpi Çöz" or "Kelepçeyi Çıkar"

		table.insert(interactions, {
			text = actionName,

			callback = function()
				if not isElement(player) or not player:getData("logged") then
					destroyMenuContext()
					return
				end

				if exports.mek_item:hasItem(localPlayer, 47, dbid) or restrainedItem == 46 then
					triggerServerEvent("restrain.server", localPlayer, player, restrainedItem)
				else
					exports.mek_infobox:addBox(
						"error",
						"Bu kişinin kelepçesini açmak için gerekli anahtarı taşımıyorsunuz."
					)
				end
				destroyMenuContext()
			end,
		})
	end

	createMenuContext(player, interactions)
end
