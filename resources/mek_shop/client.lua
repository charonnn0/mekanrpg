local shop = new("DXshop")

function shop.prototype.____constructor(self)
	self.screenSize = Vector2(guiGetScreenSize())
	self.sizeX, self.sizeY = 695, 400
	self.screenX, self.screenY = (self.screenSize.x - self.sizeX) / 2, (self.screenSize.y - self.sizeY) / 2

	self.clickTick = 0
	self.maxColumn = 7
	self.maxItem = 21

	self.modalVisible = false
	self.selectedProduct = 0
	self.loading = false
	self.shopSupplies = 0

	self.theme = useTheme()
	self.fonts = useFonts()

	self._function = {
		render = function(...)
			self:render(...)
		end,
		open = function(...)
			self:open(...)
		end,
		up = function(...)
			self:up(...)
		end,
		down = function(...)
			self:down(...)
		end,
		removeLoading = function(...)
			self:removeLoading(...)
		end,
		onClientPedDamage = function(...)
			self:onClientPedDamage(...)
		end,
		updateShopSupplies = function(...)
			self:updateShopSupplies(...)
		end,
	}

	bindKey("mouse_wheel_up", "down", self._function.up)
	bindKey("mouse_wheel_down", "down", self._function.down)

	addEvent("shop.open", true)
	addEventHandler("shop.open", root, self._function.open)

	addEvent("shop.removeLoading", true)
	addEventHandler("shop.removeLoading", root, self._function.removeLoading)

	addEventHandler("onClientPedDamage", root, self._function.onClientPedDamage)

	addEvent("shop.updateShopSupplies", true)
	addEventHandler("shop.updateShopSupplies", root, self._function.updateShopSupplies)
end

function shop.prototype.render(self)
	showCursor(true)
	self.timer = setTimer(function()
		drawRoundedRectangle({
			position = {
				x = self.screenX,
				y = self.screenY,
			},
			size = {
				x = self.sizeX,
				y = self.sizeY,
			},

			color = self.theme.GRAY[900],
			alpha = 0.9,
			radius = 8,

			borderWidth = 1,
			borderColor = self.theme.GRAY[800],
		})

		dxDrawText(
			types[self.shopType],
			self.screenX + 20,
			self.screenY + 20,
			nil,
			nil,
			rgba(self.theme.GRAY[100]),
			1,
			self.fonts.UbuntuBold.h3
		)
		dxDrawText(
			"tıklayarak istediğiniz ürünü satın alın",
			self.screenX + 20,
			self.screenY + 47,
			nil,
			nil,
			rgba(self.theme.GRAY[300], 0.7),
			1,
			self.fonts.UbuntuRegular.h6
		)

		dxDrawText(
			"Mevcut Stok: " .. ((self.shopSupplies == math.huge) and "∞" or self.shopSupplies),
			self.screenX + 20,
			self.screenY + 70,
			nil,
			nil,
			rgba(self.theme.GRAY[200], 0.7),
			1,
			self.fonts.UbuntuRegular.caption
		)

		dxDrawText(
			"",
			self.screenX + self.sizeX - 40,
			self.screenY + 20,
			nil,
			nil,
			inArea(
				self.screenX + self.sizeX - 40,
				self.screenY + 20,
				dxGetTextWidth("", 0.8, self.fonts.icon),
				dxGetFontHeight(0.8, self.fonts.icon)
			)
					and rgba(self.theme.RED[500])
				or rgba(self.theme.GRAY[100]),
			0.8,
			self.fonts.icon
		)

		if
			inArea(
				self.screenX + self.sizeX - 40,
				self.screenY + 20,
				dxGetTextWidth("", 0.8, self.fonts.icon),
				dxGetFontHeight(0.8, self.fonts.icon)
			)
			and isKeyPressed("mouse1")
			and self.clickTick + 300 <= getTickCount()
			and not self.modalVisible
			and not self.loading
		then
			self.clickTick = getTickCount()
			showCursor(false)
			killTimer(self.timer)
			self.timer = nil
		end

		self.newX, self.newY, self.countX, self.countY = 0, 20, 0, 0
		for key, value in pairs(shopItems[self.shopType]) do
			if key > self.scroll and self.countY < self.maxItem then
				local isAvailable = self.shopSupplies > 0
				local itemColor = isAvailable and rgba(self.theme.GRAY[800], 0.9) or rgba(self.theme.GRAY[900], 0.5)

				dxDrawRectangle(
					self.screenX + 20 + self.newX,
					self.screenY + 20 + self.newY + 60,
					85,
					85,
					(
						inArea(self.screenX + 20 + self.newX, self.screenY + 20 + self.newY + 60, 85, 85)
						and not self.modalVisible
						and not self.loading
						and isAvailable
					)
							and rgba(self.theme.GRAY[700], 0.9)
						or itemColor
				)

				if value[1] == 115 then
					dxDrawImage(
						self.screenX + 20 + self.newX + 17.5,
						self.screenY + 15 + self.newY + 60 + 17.5,
						50,
						50,
						(
							fileExists(":mek_item/public/images/items/-" .. value[3] .. ".png")
								and ":mek_item/public/images/items/-" .. value[3] .. ".png"
							or ":mek_item/public/images/items/empty.png"
						),
						0,
						0,
						0,
						tocolor(255, 255, 255, isAvailable and 255 or 100)
					)
				elseif value[1] == 116 then
					dxDrawImage(
						self.screenX + 20 + self.newX + 17.5,
						self.screenY + 15 + self.newY + 60 + 17.5,
						50,
						50,
						(
							fileExists(":mek_item/public/images/items/" .. value[1] .. "_" .. value[3] .. ".png")
								and ":mek_item/public/images/items/" .. value[1] .. "_" .. value[3] .. ".png"
							or ":mek_item/public/images/items/empty.png"
						),
						0,
						0,
						0,
						tocolor(255, 255, 255, isAvailable and 255 or 100)
					)
				else
					dxDrawImage(
						self.screenX + 20 + self.newX + 17.5,
						self.screenY + 15 + self.newY + 60 + 17.5,
						50,
						50,
						(
							fileExists(":mek_item/public/images/items/" .. value[1] .. ".png")
								and ":mek_item/public/images/items/" .. value[1] .. ".png"
							or ":mek_item/public/images/items/empty.png"
						),
						0,
						0,
						0,
						tocolor(255, 255, 255, isAvailable and 255 or 100)
					)
				end

				local textColor = isAvailable and rgba(self.theme.GRAY[200], 0.7) or rgba(self.theme.GRAY[400], 0.5)

				dxDrawText(
					"₺" .. exports.mek_global:formatMoney(value[2]),
					self.screenX + 75 + self.newX,
					self.screenY + self.newY + 145,
					self.screenX + 50 + self.newX,
					nil,
					textColor,
					1,
					self.fonts.UbuntuRegular.caption,
					"center"
				)

				if self.shopType == 5 then
					dxDrawText(
						exports.mek_weapon:getAmmo(value[3]).cartridge .. " (" .. value[4] .. ")",
						self.screenX + 75 + self.newX,
						self.screenY + self.newY + 131,
						self.screenX + 50 + self.newX,
						nil,
						textColor,
						1,
						self.fonts.UbuntuRegular.caption,
						"center"
					)

					if
						inArea(self.screenX + 20 + self.newX, self.screenY + 20 + self.newY + 60, 85, 85)
						and not self.modalVisible
						and isAvailable
					then
						local weaponNames = {}

						for _, weaponID in ipairs(exports.mek_weapon:getAmmo(value[3]).weapons) do
							local weaponName = getWeaponNameFromID(weaponID)
							if weaponName then
								table.insert(weaponNames, weaponName)
							end
						end

						local weaponNameString = table.concat(weaponNames, ", ")
						local textWidth = dxGetTextWidth(weaponNameString, 1, self.fonts.UbuntuLight.body)

						local cursorX, cursorY = getCursorPosition()
						if cursorX and cursorY then
							local screenX, screenY = guiGetScreenSize()
							local mouseX, mouseY = cursorX * screenX, cursorY * screenY

							drawTooltip({
								position = {
									x = mouseX + 10,
									y = mouseY + 10,
								},
								size = {
									x = textWidth + 20,
									y = 30,
								},

								radius = 4,
								text = weaponNameString,

								align = "left",
								alignY = "top",
								hover = true,
							})
						end
					end
				end

				if isAvailable then
					if value[4] then
						if
							inArea(self.screenX + 20 + self.newX, self.screenY + 20 + self.newY + 60, 85, 85)
							and isKeyPressed("mouse1")
							and self.clickTick + 300 <= getTickCount()
							and not self.modalVisible
							and not self.loading
						then
							self.clickTick = getTickCount()
							self.modalVisible = true
							self.selectedProduct = key
						end
					else
						if
							inArea(self.screenX + 20 + self.newX, self.screenY + 20 + self.newY + 60, 85, 85)
							and isKeyPressed("mouse1")
							and self.clickTick + 300 <= getTickCount()
							and not self.modalVisible
							and not self.loading
						then
							self.clickTick = getTickCount()
							self.loading = true
							triggerServerEvent("shop.buy", localPlayer, self.shopID, self.shopType, key)
						end
					end
				end

				self.countX = self.countX + 1
				self.countY = self.countY + 1
				self.newX = self.newX + 95

				if self.countX == self.maxColumn then
					self.newX = 0
					self.countX = 0
					self.newY = self.newY + 95
				end
			end
		end

		if self.modalVisible then
			local pageSizeX, pageSizeY = 300, 150
			local pageScreenX, pageScreenY = (self.screenSize.x - pageSizeX) / 2, (self.screenSize.y - pageSizeY) / 2

			dxDrawRectangle(self.screenX, self.screenY, self.sizeX, self.sizeY, tocolor(0, 0, 0, 200))
			dxDrawRectangle(pageScreenX, pageScreenY, pageSizeX, pageSizeY, rgba(self.theme.GRAY[800]))

			quantityInput = drawInput({
				position = {
					x = pageScreenX + 20,
					y = pageScreenY + 20,
				},
				size = {
					x = pageSizeX - 40,
					y = 30,
				},

				name = "shop_quantity",

				placeholder = shopItems[self.shopType][self.selectedProduct][1] == 169 and "Mülk ID" or "Miktar",
				value = "",

				variant = "solid",
				color = "gray",

				disabled = self.loading,
			})

			local totalPrice = shopItems[self.shopType][self.selectedProduct][1] == 169
					and shopItems[self.shopType][self.selectedProduct][2]
				or (
					tonumber(quantityInput.value)
						and (tonumber(quantityInput.value) * shopItems[self.shopType][self.selectedProduct][2])
					or 0
				)

			local submitButtonDisabled = self.loading or self.shopSupplies <= 0
			submitButton = drawButton({
				position = {
					x = pageScreenX + 20,
					y = pageScreenY + 65,
				},
				size = {
					x = pageSizeX - 40,
					y = 30,
				},
				radius = DEFAULT_RADIUS,

				textProperties = {
					align = "center",
					color = "#FFFFFF",
					font = self.fonts.body.regular,
					scale = 0.9,
				},

				variant = "soft",
				color = "green",
				disabled = submitButtonDisabled,

				text = "Satın Al (₺" .. exports.mek_global:formatMoney(totalPrice) .. ")",
			})

			if submitButton.pressed and self.clickTick + 300 <= getTickCount() and not submitButtonDisabled then
				self.clickTick = getTickCount()

				if quantityInput.value and tonumber(quantityInput.value) then
					local quantity = tonumber(math.floor(tonumber(quantityInput.value)))

					if shopItems[self.shopType][self.selectedProduct][1] == 169 then
						if quantity >= 1 then
							triggerServerEvent(
								"shop.buy",
								localPlayer,
								self.shopID,
								self.shopType,
								self.selectedProduct,
								quantity
							)
							self.loading = true
						else
							exports.mek_infobox:addBox("error", "Geçerli bir mülk ID girin.")
						end
					else
						if quantity >= 1 and quantity <= 10 then
							triggerServerEvent(
								"shop.buy",
								localPlayer,
								self.shopID,
								self.shopType,
								self.selectedProduct,
								quantity
							)
							self.loading = true
						elseif quantity > 10 then
							exports.mek_infobox:addBox("error", "Maksimum 10 adet satın alabilirsiniz.")
						else
							exports.mek_infobox:addBox("error", "Minimum 1 adet satın alabilirsiniz.")
						end
					end
				else
					exports.mek_infobox:addBox("error", "Lütfen geçerli bir değer girin.")
				end
			end

			closeButton = drawButton({
				position = {
					x = pageScreenX + 20,
					y = pageScreenY + 100,
				},
				size = {
					x = pageSizeX - 40,
					y = 30,
				},

				textProperties = {
					align = "center",
					color = "#FFFFFF",
					font = self.fonts.body.regular,
					scale = 0.9,
				},

				variant = "soft",
				color = "red",
				disabled = self.loading,

				text = "Kapat",
			})

			if closeButton.pressed and self.clickTick + 300 <= getTickCount() and not self.loading then
				self.clickTick = getTickCount()
				self.modalVisible = false
			end
		end

		if self.loading then
			drawRoundedRectangle({
				position = {
					x = self.screenX,
					y = self.screenY,
				},
				size = {
					x = self.sizeX,
					y = self.sizeY,
				},

				color = self.theme.GRAY[900],
				alpha = 0.4,
				radius = 8,

				borderWidth = 1,
				borderColor = self.theme.GRAY[800],
			})
			drawSpinner({
				position = {
					x = self.screenX + (self.sizeX - 128) / 2,
					y = self.screenY + (self.sizeY - 128) / 2,
				},
				size = 128,

				speed = 2,

				variant = "soft",
				color = "gray",
			})
		end
	end, 0, 0)
end

function shop.prototype.open(self, element)
	if not isTimer(self.timer) then
		self.scroll = 0
		self.modalVisible = false
		self.selectedProduct = 0
		self.shopID = getElementData(element, "id")
		self.shopType = getElementData(element, "type")
		triggerServerEvent("shop.requestSupplies", localPlayer, self.shopID)
		self.timer = setTimer(self._function.render, 500, 1)
	end
end

function shop.prototype.up(self)
	if isTimer(self.timer) then
		if
			inArea(self.screenX, self.screenY, self.sizeX, self.sizeY)
			and not self.modalVisible
			and not self.loading
		then
			if self.scroll > 0 then
				self.scroll = self.scroll - self.maxColumn
			end
		end
	end
end

function shop.prototype.down(self)
	if isTimer(self.timer) then
		if
			inArea(self.screenX, self.screenY, self.sizeX, self.sizeY)
			and not self.modalVisible
			and not self.loading
		then
			if self.scroll < #shopItems[self.shopType] - self.maxItem then
				self.scroll = self.scroll + self.maxColumn
			end
		end
	end
end

function shop.prototype.removeLoading(self)
	self.loading = false
end

function shop.prototype.onClientPedDamage(self)
	cancelEvent()
end

function shop.prototype.updateShopSupplies(self, supplies)
	self.shopSupplies = supplies
end

load(shop)
