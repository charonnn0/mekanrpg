local shop = new("shops")

function shop.prototype.____constructor(self)
	self._function = {
		load = function(...)
			self:load(...)
		end,
		loadAll = function(...)
			self:loadAll(...)
		end,
		create = function(...)
			self:create(...)
		end,
		nearbys = function(...)
			self:nearbys(...)
		end,
		delete = function(...)
			self:delete(...)
		end,
		teleport = function(...)
			self:teleport(...)
		end,
		buy = function(...)
			self:buy(...)
		end,
		requestSupplies = function(...)
			self:requestSupplies(...)
		end,
	}

	self.shops = {}
	self.lastPurchase = {}
	self.shopSuppliesData = {}

	setTimer(self._function.loadAll, 1000, 1)

	addCommandHandler("makeshop", self._function.create, false, false)
	addCommandHandler("nearbyshops", self._function.nearbys, false, false)
	addCommandHandler("delshop", self._function.delete, false, false)
	addCommandHandler("gotoshop", self._function.teleport, false, false)

	addEvent("shop.buy", true)
	addEventHandler("shop.buy", root, self._function.buy)

	addEvent("shop.requestSupplies", true)
	addEventHandler("shop.requestSupplies", root, self._function.requestSupplies)
end

function shop.prototype.requestSupplies(self, shopID)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not shopID or not tonumber(shopID) then
		return
	end

	local ped = self.shops[shopID]
	if not isElement(ped) then
		return
	end

	local shopInterior = ped.dimension
	if shopInterior and shopInterior > 0 then
		dbQuery(
			function(queryHandle, client)
				local result = dbPoll(queryHandle, 0)
				if result and #result > 0 then
					local supplies = result[1].supplies or 0
					self.shopSuppliesData[shopID] = supplies
					triggerClientEvent(client, "shop.updateShopSupplies", client, supplies)
				else
					self.shopSuppliesData[shopID] = math.huge
					triggerClientEvent(client, "shop.updateShopSupplies", client, math.huge)
				end
			end,
			{ client },
			exports.mek_mysql:getConnection(),
			"SELECT supplies FROM interiors WHERE id = ? AND id IN (SELECT intID FROM interior_business WHERE intID = ?)",
			shopInterior,
			shopInterior
		)
	else
		self.shopSuppliesData[shopID] = math.huge
		triggerClientEvent(client, "shop.updateShopSupplies", client, math.huge)
	end
end

function shop.prototype.buy(self, shopID, shopType, itemID, quantity)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	local currentTime = getTickCount()
	if self.lastPurchase[client] and currentTime - self.lastPurchase[client] < 3000 then
		local remainingTime = math.ceil((3000 - (currentTime - self.lastPurchase[client])) / 1000)
		exports.mek_infobox:addBox(
			client,
			"error",
			"Lütfen " .. remainingTime .. " saniye bekleyin ve tekrar deneyin."
		)
		triggerClientEvent(client, "shop.removeLoading", client)
		return
	end

	quantity = math.floor(tonumber(quantity) or 1) or 1

	if shopID and itemID and tonumber(shopID) and tonumber(itemID) and quantity then
		local ped = self.shops[shopID]
		if not isElement(ped) then
			exports.mek_infobox:addBox(client, "error", "Geçersiz mağaza!")
			triggerClientEvent(client, "shop.removeLoading", client)
			return
		end

		local shopType = getElementData(ped, "type")
		local item = shopItems[shopType][itemID]

		if not item then
			exports.mek_infobox:addBox(client, "error", "Geçersiz ürün!")
			triggerClientEvent(client, "shop.removeLoading", client)
			return
		end

		if item[1] and item[2] and item[3] then
			local currentSupplies = self.shopSuppliesData[shopID] or 0
			if currentSupplies ~= math.huge and currentSupplies < quantity then
				exports.mek_infobox:addBox(client, "error", "Mağazanın yeterli stoğu bulunmamaktadır.")
				triggerClientEvent(client, "shop.removeLoading", client)
				return
			end

			local isPropertyKey = (item[1] == 169)
			if not isPropertyKey and (quantity < 1 or quantity > 10) then
				exports.mek_infobox:addBox(client, "error", "Minimum 1, maksimum 10 adet ürün satın alabilirsiniz.")
				triggerClientEvent(client, "shop.removeLoading", client)
				return
			end

			local totalPrice = item[1] == 169 and item[2] or item[2] * quantity

			if exports.mek_global:hasMoney(client, totalPrice) then
				local hasSpace = true
				if not isPropertyKey then
					for i = 1, quantity do
						if not exports.mek_item:hasSpaceForItem(client, item[1], item[3]) then
							hasSpace = false
							exports.mek_infobox:addBox(
								client,
								"error",
								"Bu ürünü taşımak için yeterli alanınız yok."
							)
							break
						end
					end
				end

				if hasSpace then
					exports.mek_global:takeMoney(client, totalPrice)

					local shopPed = self.shops[shopID]
					local shopInterior = ped.dimension

					if shopInterior and currentSupplies ~= math.huge then
						local newSupplies = currentSupplies - quantity
						self.shopSuppliesData[shopID] = newSupplies
						dbExec(
							exports.mek_mysql:getConnection(),
							"UPDATE interiors SET supplies = ? WHERE id = ?",
							newSupplies,
							shopInterior
						)

						local x, y, z = getElementPosition(shopPed)
						local interior, dimension = getElementInterior(shopPed), getElementDimension(shopPed)

						for _, player in ipairs(getElementsByType("player")) do
							local px, py, pz = getElementPosition(player)
							local pInt, pDim = getElementInterior(player), getElementDimension(player)
							if
								pInt == interior
								and pDim == dimension
								and getDistanceBetweenPoints3D(x, y, z, px, py, pz) < 50
							then
								triggerClientEvent(player, "shop.updateShopSupplies", player, newSupplies)
							end
						end
					end

					if client.interior > 0 and client.dimension > 0 then
						local dbid, entrance, exit, interiorType, interiorElement =
							exports.mek_interior:findProperty(client)
						if interiorElement then
							local interiorName = getElementData(interiorElement, "name")
							local interiorStatus = getElementData(interiorElement, "status")
							local intType = interiorStatus.type
							local interiorOwner = interiorStatus.owner

							if intType == 1 and interiorOwner > 0 then
								local taxRate = exports.mek_global:getTaxAmount()
								local taxAmount = math.floor(totalPrice * taxRate)
								local amountAfterTax = totalPrice - taxAmount

								local currentCashbox = getElementData(interiorElement, "cashbox") or 0
								local newCashbox = currentCashbox + amountAfterTax

								setElementData(interiorElement, "cashbox", newCashbox)
								dbExec(
									exports.mek_mysql:getConnection(),
									"UPDATE interior_business SET cashbox = ? WHERE intID = ?",
									newCashbox,
									dbid
								)
								exports.mek_global:giveMoney(
									getTeamFromName("İstanbul Büyükşehir Belediyesi"),
									taxAmount
								)

								local ownerPlayer = exports.mek_pool:getElementByID("player", interiorOwner)
								if ownerPlayer then
									outputChatBox(
										"["
											.. interiorName
											.. "]#FFFFFF "
											.. string.format(
												"İşletmenizden yapılan ₺%s tutarındaki satıştan ₺%s vergi kesildi. Net kazanç ₺%s olarak kasaya yatırıldı.",
												exports.mek_global:formatMoney(totalPrice),
												exports.mek_global:formatMoney(taxAmount),
												exports.mek_global:formatMoney(amountAfterTax)
											),
										ownerPlayer,
										255,
										127,
										0,
										true
									)
								end
							end
						end
					end

					if quantity > 1 then
						self.lastPurchase[client] = currentTime
					end

					if item[1] ~= 2 and item[1] ~= 115 and item[1] ~= 116 and item[1] ~= 169 then
						for i = 1, quantity do
							exports.mek_item:giveItem(client, item[1], item[3])
						end
					end

					if item[1] == 2 then
						local phoneNumber = exports.mek_phone:createPhoneNumberForCharacter(client:getData("dbid"))
						if phoneNumber then
							exports.mek_item:giveItem(client, item[1], phoneNumber)
							exports.mek_infobox:addBox(
								client,
								"success",
								"₺"
									.. exports.mek_global:formatMoney(totalPrice)
									.. " karşılığında "
									.. quantity
									.. " adet "
									.. exports.mek_item:getItemName(item[1])
									.. " aldınız."
							)
							exports.mek_logs:addLog(
								"shop",
								getPlayerName(client):gsub("_", " ")
									.. " isimli oyuncu ₺"
									.. exports.mek_global:formatMoney(totalPrice)
									.. " karşılığında "
									.. quantity
									.. " adet "
									.. exports.mek_item:getItemName(item[1])
									.. " aldı."
							)
						else
							exports.mek_infobox:addBox(
								client,
								"error",
								"Telefon numarası oluşurken bir sorun oluştu."
							)
						end
					elseif item[1] == 115 then
						for i = 1, quantity do
							local weaponSerial = exports.mek_global:createWeaponSerial(
								1,
								tonumber(getElementData(client, "dbid")),
								tonumber(getElementData(client, "dbid"))
							)
							local itemValue = item[3]
								.. ":"
								.. weaponSerial
								.. ":"
								.. getWeaponNameFromID(item[3])
								.. ":0:3"
							exports.mek_item:giveItem(client, item[1], itemValue)
						end
						exports.mek_infobox:addBox(
							client,
							"success",
							"₺"
								.. exports.mek_global:formatMoney(totalPrice)
								.. " karşılığında "
								.. quantity
								.. " adet "
								.. getWeaponNameFromID(item[3])
								.. " aldınız."
						)
						exports.mek_logs:addLog(
							"shop",
							getPlayerName(client):gsub("_", " ")
								.. " isimli oyuncu ₺"
								.. exports.mek_global:formatMoney(totalPrice)
								.. " karşılığında "
								.. quantity
								.. " adet "
								.. getWeaponNameFromID(item[3])
								.. " aldı."
						)
					elseif item[1] == 116 then
						for i = 1, quantity do
							local weaponSerial = exports.mek_global:createWeaponSerial(
								1,
								tonumber(getElementData(client, "dbid")),
								tonumber(getElementData(client, "dbid"))
							)
							local itemValue = item[3] .. ":" .. item[4] .. ":" .. weaponSerial
							exports.mek_item:giveItem(client, item[1], itemValue)
						end
						exports.mek_infobox:addBox(
							client,
							"success",
							"₺"
								.. exports.mek_global:formatMoney(totalPrice)
								.. " karşılığında "
								.. quantity
								.. " adet "
								.. item[4]
								.. " mermili "
								.. exports.mek_weapon:getAmmo(item[3]).cartridge
								.. " cephane paketi aldınız."
						)
						exports.mek_logs:addLog(
							"shop",
							getPlayerName(client):gsub("_", " ")
								.. " isimli oyuncu ₺"
								.. exports.mek_global:formatMoney(totalPrice)
								.. " karşılığında "
								.. quantity
								.. " adet "
								.. item[4]
								.. " mermili "
								.. exports.mek_weapon:getAmmo(item[3]).cartridge
								.. " cephane paketi aldı."
						)
					elseif item[1] == 169 then
						if exports.mek_item:hasSpaceForItem(client, item[1], quantity) then
							exports.mek_item:giveItem(client, item[1], quantity)
							exports.mek_infobox:addBox(
								client,
								"success",
								"₺"
									.. exports.mek_global:formatMoney(totalPrice)
									.. " karşılığında "
									.. quantity
									.. " ID'li mülk için 1 adet "
									.. exports.mek_item:getItemName(item[1])
									.. " aldınız."
							)
							exports.mek_logs:addLog(
								"shop",
								getPlayerName(client):gsub("_", " ")
									.. " isimli oyuncu ₺"
									.. exports.mek_global:formatMoney(totalPrice)
									.. " karşılığında "
									.. quantity
									.. " ID'li mülk için 1 adet "
									.. exports.mek_item:getItemName(item[1])
									.. " aldı."
							)
						else
							exports.mek_infobox:addBox(
								client,
								"error",
								"Bu ürünü taşımak için yeterli alanınız yok."
							)
						end
					else
						exports.mek_infobox:addBox(
							client,
							"success",
							"₺"
								.. exports.mek_global:formatMoney(totalPrice)
								.. " karşılığında "
								.. quantity
								.. " adet "
								.. exports.mek_item:getItemName(item[1])
								.. " aldınız."
						)
						exports.mek_logs:addLog(
							"shop",
							getPlayerName(client):gsub("_", " ")
								.. " isimli oyuncu ₺"
								.. exports.mek_global:formatMoney(totalPrice)
								.. " karşılığında "
								.. quantity
								.. " adet "
								.. exports.mek_item:getItemName(item[1])
								.. " aldı."
						)
					end
				end
			else
				exports.mek_infobox:addBox(
					client,
					"error",
					(item[1] == 115 and getWeaponNameFromID(item[3]) or exports.mek_item:getItemName(item[1]))
						.. " isimli eşyayı satın almak için yeterli paranız yok."
				)
			end
		end
	end

	triggerClientEvent(client, "shop.removeLoading", client)
end

function shop.prototype.create(self, thePlayer, commandName, type, skin, name)
	if exports.mek_integration:isPlayerServerManager(thePlayer) then
		if not tonumber(type) or not tonumber(skin) or not name or tonumber(type) > #types or tonumber(type) < 0 then
			outputChatBox(
				"Kullanım: /" .. commandName .. " [Tür] [Skin | -1 = Random] [Karakter Adı | -1 = Random]",
				thePlayer,
				255,
				194,
				14
			)
		else
			local randomGender = math.random(0, 1)

			if tonumber(skin) == -1 then
				skin = exports.mek_global:getRandomSkin(randomGender)
			end

			if tonumber(name) == -1 then
				name = exports.mek_global:getRandomName("full", randomGender)
				name = string.gsub(name, " ", "_")
			end

			dbQuery(function(queryHandle)
				local result = dbPoll(queryHandle, 0)
				if result and #result > 0 then
					outputChatBox("[!]#FFFFFF Bu isimde bir NPC mağazası zaten mevcut.", thePlayer, 255, 0, 0, true)
				else
					local shopType = math.floor(tonumber(type))
					local x, y, z = getElementPosition(thePlayer)
					local _, _, rotation = getElementRotation(thePlayer)
					local interior, dimension = getElementInterior(thePlayer), getElementDimension(thePlayer)
					local typeName = types[shopType]

					dbQuery(
						function(queryHandle)
							local result, _, id = dbPoll(queryHandle, 0)
							if id then
								self._function.load(id)
								outputChatBox(
									"[!]#FFFFFF Yeni NPC mağazası (ID: "
										.. id
										.. " - "
										.. typeName
										.. ") oluşturdunuz.",
									thePlayer,
									0,
									255,
									0,
									true
								)
							else
								outputChatBox("[!]#FFFFFF Bir sorun oluştu.", thePlayer, 255, 0, 0, true)
							end
						end,
						exports.mek_mysql:getConnection(),
						"INSERT INTO shops SET x = ?, y = ?, z = ?, rotation = ?, interior = ?, dimension = ?, type = ?, skin = ?, name = ?",
						x,
						y,
						z,
						rotation,
						interior,
						dimension,
						shopType,
						skin,
						tostring(name)
					)
				end
			end, exports.mek_mysql:getConnection(), "SELECT * FROM shops WHERE name = ?", name)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end

function shop.prototype.nearbys(self, thePlayer, commandName)
	if exports.mek_integration:isPlayerServerManager(thePlayer) then
		local px, py, pz = getElementPosition(thePlayer)
		local count = 0

		for _, ped in pairs(getElementsByType("ped", resourceRoot, true)) do
			local shopID = getElementData(ped, "id")
			local shopType = getElementData(ped, "type")

			if shopID and shopType then
				local x, y, z = getElementPosition(ped)
				local distance = getDistanceBetweenPoints3D(px, py, pz, x, y, z)

				if distance <= 20 then
					local interiorID = ped.dimension
					local currentSupplies = self.shopSuppliesData[shopID]

					local displaySupplies = (currentSupplies == math.huge) and "Sonsuz" or tostring(currentSupplies)

					outputChatBox(
						"[!]#FFFFFF ID: "
							.. shopID
							.. " - Tür: (#"
							.. shopType
							.. ") - Mesafe: "
							.. math.ceil(distance)
							.. " m. - Stok: "
							.. displaySupplies
							.. " - Interior ID: "
							.. (interiorID or "Yok"),
						thePlayer,
						0,
						0,
						255,
						true
					)
					count = count + 1
				end
			end
		end

		if count == 0 then
			outputChatBox("[!]#FFFFFF Size yakın NPC mağazası yok.", thePlayer, 255, 0, 0, true)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end

function shop.prototype.delete(self, thePlayer, commandName, id)
	if exports.mek_integration:isPlayerServerManager(thePlayer) then
		if not id or not tonumber(id) then
			outputChatBox("Kullanım: /" .. commandName .. " [ID]", thePlayer, 255, 194, 14)
			return
		end

		local id = math.floor(tonumber(id))
		if self.shops[id] then
			local ped = self.shops[id]

			if isElement(ped) then
				destroyElement(ped)
			end

			self.shopSuppliesData[id] = nil
			dbExec(exports.mek_mysql:getConnection(), "DELETE FROM shops WHERE id = ?", id)
			outputChatBox(
				"[!]#FFFFFF Başarıyla [" .. id .. "] ID'li NPC mağazayı sildiniz.",
				thePlayer,
				0,
				255,
				0,
				true
			)
		else
			outputChatBox("[!]#FFFFFF [" .. id .. "] ID'li bir NPC mağazası yok.", thePlayer, 255, 0, 0, true)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end

function shop.prototype.teleport(self, thePlayer, commandName, id)
	if exports.mek_integration:isPlayerServerManager(thePlayer) then
		if not id or not tonumber(id) then
			outputChatBox("Kullanım: /" .. commandName .. " [ID]", thePlayer, 255, 194, 14)
			return
		end

		local id = math.floor(tonumber(id))
		if self.shops[id] then
			local ped = self.shops[id]
			if isElement(ped) then
				local x, y, z = getElementPosition(ped)
				local interior = getElementInterior(ped)
				local dimension = getElementDimension(ped)

				if not isPedInVehicle(thePlayer) then
					setElementPosition(thePlayer, x, y, z)
					setElementInterior(thePlayer, interior)
					setElementDimension(thePlayer, dimension)
					outputChatBox(
						"[!]#FFFFFF Başarıyla [" .. id .. "] ID'li NPC mağazaya ışınlandınız.",
						thePlayer,
						0,
						255,
						0,
						true
					)
				else
					outputChatBox(
						"[!]#FFFFFF Araçtayken bu işlemi gerçekleştiremezsiniz.",
						thePlayer,
						255,
						0,
						0,
						true
					)
				end
			end
		else
			outputChatBox("[!]#FFFFFF [" .. id .. "] ID'li bir NPC mağazası yok.", thePlayer, 255, 0, 0, true)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end

function shop.prototype.load(self, id)
	dbQuery(function(queryHandle)
		local result = dbPoll(queryHandle, 0)
		if #result > 0 then
			for _, data in pairs(result) do
				local ped = createPed(data.skin, data.x, data.y, data.z, data.rotation)
				setElementInterior(ped, data.interior)
				setElementDimension(ped, data.dimension)
				setElementFrozen(ped, true)

				setElementData(ped, "id", data.id)
				setElementData(ped, "type", data.type)
				setElementData(ped, "name", data.name)

				setElementData(ped, "interaction", {
					callbackEvent = "shop.open",
					args = { ped },
					description = data.name:gsub("_", " "),
				})

				setPedWalkingStyle(ped, 118)

				self.shops[data.id] = ped

				if data.interior then
					dbQuery(
						function(supplyQueryHandle)
							local supplyResult = dbPoll(supplyQueryHandle, 0)
							if supplyResult and #supplyResult > 0 then
								self.shopSuppliesData[data.id] = supplyResult[1].supplies or 0
							else
								self.shopSuppliesData[data.id] = 0
							end
						end,
						exports.mek_mysql:getConnection(),
						"SELECT supplies FROM interiors WHERE id = ?",
						data.interior
					)
				else
					self.shopSuppliesData[data.id] = math.huge
				end
			end
		end
	end, exports.mek_mysql:getConnection(), "SELECT * FROM shops WHERE id = ?", id)
end

function shop.prototype.loadAll(self)
	dbQuery(function(queryHandle)
		local result = dbPoll(queryHandle, 0)
		if #result > 0 then
			for _, data in pairs(result) do
				self._function.load(data.id)
			end
		end
	end, exports.mek_mysql:getConnection(), "SELECT id FROM shops")
end

addEvent("shop.storeKeeperSay", true)
addEventHandler("shop.storeKeeperSay", root, function(content, pedName)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	pedName = string.gsub(pedName, "_", " ")
	exports.mek_global:sendLocalText(source, tostring(pedName) .. ": " .. content, 255, 255, 255, 30, {}, true)
end)

load(shop)
