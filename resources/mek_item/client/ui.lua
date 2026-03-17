local screenSize = Vector2(guiGetScreenSize())

local fonts = useFonts()
local theme = useTheme()

local backgroundColor = theme.GRAY[900]
local backgroundErrorColor = theme.RED[500]
local backgroundMoveToElementColor = theme.GREEN[500]
local fullColor = theme.WHITE[100]
local activeTabColor = getServerColor(2)

local tooltipTextColor = theme.WHITE[100]
local tooltipBackgroundColor = {
	default = theme.GRAY[900],
	delete = theme.RED[500],
	drop = theme.GRAY[900],
	split = theme.GRAY[900],
}

local rows = 5

local box = 75
local spacer = 1
local spacerBox = spacer + box

local inventory = false
local render = false

local clickDown = false
waitingForItemDrop = false
local hoverElement = false

local hoverItemSlot = false
local clickItemSlot = false

local hoverWorldItem = false
local clickWorldItem = false

local TAB_WALLET, TAB_ITEMS, TAB_KEYS, TAB_WEAPONS = 1, 2, 3, 4
local ACTION_DROP, ACTION_SHOW, ACTION_DESTROY, ACTION_SPLIT = 5, 6, 7, 8

local isCursorOverInventory = false
local activeTab = TAB_WALLET
local activeTabItem = nil
local hoverAction = false
local actionIcons = {
	[TAB_WALLET] = { "", "Cüzdan" },
	[TAB_ITEMS] = { "", "Eşyalar" },
	[TAB_KEYS] = { "", "Anahtarlar" },
	[TAB_WEAPONS] = { "", "Silahlar" },

	[ACTION_DROP] = {
		"",
		"Eşyayı Bırak",
		"Otomatik olarak bırakmak için öğeyi seçerken CTRL tuşuna basın.",
	},
	[ACTION_SHOW] = { "", "Eşyayı Göster" },
	[ACTION_DESTROY] = {
		"",
		"Eşyayı Sil",
		"Otomatik olarak silmek için bir öğeyi seçerken DELETE tuşuna basın.",
	},
}

local savedArmor = false
local rotate = false

local tooltipYet = false

local function getHoverElement(force)
	if not force then
		return
	end

	local cursorX, cursorY, absX, absY, absZ = getCursorPosition()
	local cameraX, cameraY, cameraZ = getWorldFromScreenPosition(cursorX, cursorY, 0.1)

	for _, acceptProtected in ipairs({ false, true }) do
		local a, b, c, d, element = processLineOfSight(cameraX, cameraY, cameraZ, absX, absY, absZ)
		if element and not acceptProtected and getElementData(element, "protected") then
			element = nil
		end

		if
			element
			and getElementParent(getElementParent(element))
				== getResourceRootElement(getResourceFromName("mek_item-world"))
		then
			return element
		elseif b and c and d then
			element = nil
			local x, y, z = nil
			local maxDistance = 0.34

			for key, value in
				ipairs(getElementsByType("object", getResourceRootElement(getResourceFromName("mek_item-world")), true))
			do
				if isElementStreamedIn(value) and isElementOnScreen(value) then
					x, y, z = getElementPosition(value)
					local distance = getDistanceBetweenPoints3D(x, y, z, b, c, d)

					if distance < maxDistance then
						element = value
						maxDistance = distance
					end
				end
			end

			if element then
				local px, py, pz = getElementPosition(localPlayer)
				return getDistanceBetweenPoints3D(px, py, pz, getElementPosition(element)) < 10 and element
			end
		end
	end
end

local function getTooltipPrefix(text, action, item)
	if action == "delete" then
		text = "SİL: " .. text
	elseif action == "drop" then
		text = "BIRAK: " .. text
	elseif action == "split" then
		if splittableItems[item[1]] then
			if item[1] == 147 then
				text = "SIFIRLA: " .. text
			else
				text = "AYIR: " .. text
			end
		end
	end
	return text
end

local function drawTooltip(x, y, text, text2, action, item)
	tooltipYet = true

	text = tostring(text)
	if text2 then
		text2 = tostring(text2)
	end

	if text == text2 then
		text2 = nil
	end

	text = getTooltipPrefix(text, action, item)

	local width = dxGetTextWidth(text, 1, fonts.UbuntuRegular.caption) + 20
	if text2 then
		width = math.max(width, dxGetTextWidth(text2, 1, fonts.UbuntuRegular.caption) + 20)
		text = text .. "\n" .. text2
	end

	local height = 10 * (text2 and 5 or 3)
	x = math.max(10, math.min(x, screenSize.x - width - 10))
	y = math.max(10, math.min(y, screenSize.y - height - 10))

	drawRoundedRectangle({
		position = {
			x = x,
			y = y,
		},
		size = {
			x = width,
			y = height,
		},

		color = tooltipBackgroundColor[action or "default"],
		alpha = 1,
		radius = 8,

		borderWidth = 1,
		borderColor = theme.GRAY[800],
		
		postGUI = true,
	})
	dxDrawText(
		text,
		x,
		y,
		x + width,
		y + height,
		rgba(theme.WHITE),
		1,
		fonts.UbuntuRegular.caption,
		"center",
		"center",
		false,
		false,
		true
	)
end

local function isInBox(x, y, xmin, xmax, ymin, ymax)
	if x >= xmin and x <= xmax and y >= ymin and y <= ymax then
		exports.mek_cursor:setCursor("all", "pointinghand")
		return (x >= xmin and x <= xmax and y >= ymin and y <= ymax)
	end
	return false
end

function getImage(itemID, itemValue)
	if not itemID or not tonumber(itemID) then
		return "public/images/items/nil.png"
	end

	if itemID > 0 and not itemsPackages[itemID] then
		return "public/images/items/80.png"
	elseif itemID == 16 then
		local skinID, clothingID, modelID = unpack(split(tostring(itemValue), ";"))
		skinID = tonumber(skinID)
		clothingID = tonumber(clothingID) or 0
		modelID = tonumber(modelID) or 0

		if tonumber(modelID) and tonumber(modelID) > 0 then
			return "public/images/items/16.png"
		else
			skinID = ("%03d"):format(tonumber(tostring(skinID):gsub(":(.*)$", ""), 10) or 999)
			if not skinID or not tonumber(skinID) or tonumber(skinID) == 999 then
				return "public/images/items/nil.png"
			else
				return "public/images/skins/" .. skinID .. ".png"
			end
		end
	else
		if itemID == 55 or itemID == 128 or itemID == 159 or itemID == 161 or itemID == 180 or itemID == 222 then
			return "public/images/items/55.png"
		elseif itemID == 115 then
			local itemValueExploded = split(itemValue, ":")
			return "public/images/items/-" .. itemValueExploded[1] .. ".png"
		elseif itemID == 116 then
			local itemValueExploded = split(itemValue, ":")
			return "public/images/items/" .. itemID .. "_" .. itemValueExploded[1] .. ".png"
		elseif itemID == 147 then
			if itemValue and itemValue ~= 1 then
				return "public/images/items/147b.png"
			else
				return "public/images/items/147.png"
			end
		elseif itemID == 152 or itemID == 133 or itemID == 153 or itemID == 154 or itemID == 155 then
			return "public/images/items/149.png"
		elseif itemID == 162 or itemID == 219 or itemID == 220 or itemID == 221 then
			return "public/images/items/162.png"
		elseif itemID == 165 then
			if itemValue and itemValue ~= 1 then
				return "public/images/items/165b.png"
			else
				return "public/images/items/165.png"
			end
		elseif itemID == 184 or itemID == 185 then
			return "public/images/items/184.png"
		elseif (itemID >= 194 and itemID <= 200) or itemID == 201 or itemID == 202 then
			return "public/images/items/194.png"
		elseif itemID >= 206 and itemID <= 208 then
			return "public/images/items/206.png"
		elseif itemID == 215 or itemID == 216 then
			return "public/images/items/215.png"
		elseif itemID == 229 or itemID == 230 or itemID == 233 or itemID == 235 then
			return "public/images/items/229.png"
		else
			local image = itemsPackages[itemID] and itemsPackages[itemID].image
			if image then
				return "public/images/items/" .. image .. ".png"
			else
				return "public/images/items/" .. itemID .. ".png"
			end
		end
	end
end

local function counterIDHelper(itemID, itemValue)
	if itemID == 16 then
		return -100 - (tonumber(tostring(itemValue):gsub(":(.*)$", ""), 10) or 0)
	elseif itemID == 115 then
		return -(tonumber(split(itemValue, ":")[1]) or 0)
	elseif itemID == 116 then
		return -50 - (tonumber(split(itemValue, ":")[1]) or 0)
	else
		return itemID
	end
end

local function getOverlayText(itemID, itemValue, isGrouped)
	local text = ""

	if itemID == 115 then
		text = getItemName(itemID, tostring(itemValue))
	elseif itemID == 116 then
		local name = getItemName(itemID, tostring(itemValue or ""))
		local ammoCount = 0
		if itemValue and type(itemValue) == "string" then
			local splitResult = split(itemValue, ":")
			ammoCount = splitResult and splitResult[2] or 0
		end
		text = isGrouped and string.gsub(name or "", " " .. itemsPackages[itemID][1], "")
			or (
				string.gsub(name or "", " " .. itemsPackages[itemID][1], "")
				.. "\n"
				.. ammoCount
				.. " mermi"
			)
	elseif itemID == 134 then
		text = "₺" .. exports.mek_global:formatMoney(itemValue)
	end

	if isGrouped then
		text = isGrouped .. "x\n" .. (text or "")
	elseif itemID == 72 or itemID == 80 or itemID == 214 then
		text = tostring(itemValue):sub(1, 35) .. (#tostring(itemValue) > 35 and "..." or "")
	elseif itemID == 71 then
		text = tostring(itemValue)
	elseif itemID == 10 and itemValue ~= 1 and itemValue ~= 6 then
		text = "d" .. tostring(itemValue)
	end

	return text or ""
end

local function getTooltipFor(itemID, itemValue, isGrouped, isProtected)
	local name, x = getItemName(itemID, itemValue)
	local desc = getItemDescription(itemID, getItemValue(itemID, itemValue))
	if x then
		name = itemsPackages[itemID][1]
		desc = x
	end

	if itemID == 80 then
		if isGrouped then
			return isGrouped .. " Jenerik Eşyalar", ""
		else
			name = getItemName(itemID, itemValue)
		end
	end

	if itemID == 214 and isGrouped then
		return isGrouped .. " Uyuştucular", ""
	end

	if itemID == 223 and isGrouped then
		return isGrouped .. " Depolama Eşyaları"
	end

	if itemID == 178 then
		return desc
	end

	if isGrouped then
		return isGrouped .. "x " .. name, "Tüm öğeleri görmek için tıklayın."
	end

	if isProtected then
		name = name .. " ◊"
	end

	if itemID == 134 then
		if
			itemValue
			and itemValue ~= 1
			and #tostring(itemValue) > 0
			and not itemsPackages[itemID][2]:find("#v")
			and itemValue ~= itemName
		then
			name = name .. " (₺" .. exports.mek_global:formatMoney(itemValue) .. ")"
		end
	elseif itemID == 150 or itemID == 152 then
		name = name
	else
		if not getItemHideItemValue(itemID) then
			if
				itemValue
				and itemValue ~= 1
				and #tostring(itemValue) > 0
				and not itemsPackages[itemID][2]:find("#v")
				and itemValue ~= itemName
			then
				if itemsPackages[itemID].ooc_item_value then
					name = name .. " ((" .. itemValue .. "))"
				else
					name = name .. " (" .. itemValue .. ")"
				end
			end
		end
	end

	return name, desc
end

setTimer(function()
	hoverItemSlot = false
	hoverWorldItem = false
	hoverAction = false
	isCursorOverInventory = false
	hoverElement = false
	tooltipYet = false

	if not isCursorShowing() and clickWorldItem then
		hideNewInventory()
	elseif not guiGetInputEnabled() and not isMTAWindowActive() and isCursorShowing() and not isPlayerMapVisible() then
		local cursorX, cursorY, cwX, cwY, cwZ = getCursorPosition()
		local cursorX, cursorY = cursorX * screenSize.x, cursorY * screenSize.y

		if not inventory then
			local items = getItems(localPlayer)
			if items then
				inventory = {}
				local counters = {}

				local retry = false
				repeat
					if activeTabItem then
						retry = true
					else
						retry = false
					end

					for k, v in ipairs(items) do
						if activeTabItem then
							if counterIDHelper(v[1], v[2]) == activeTabItem then
								inventory[#inventory + 1] = { v[1], v[2], v[3], k, false, v[5], k }
							end
						elseif getItemTab(v[1]) == activeTab then
							inventory[#inventory + 1] = { v[1], v[2], v[3], k, false, v[5], k }
							counters[counterIDHelper(v[1], v[2])] = 1 + (counters[counterIDHelper(v[1], v[2])] or 0)
							retry = false
						end
					end

					if activeTabItem then
						if #inventory == 0 then
							activeTabItem = nil
						else
							retry = false
						end
					end
				until not retry

				if not activeTabItem and activeTab ~= 3 then
					for id, occurs in pairs(counters) do
						if occurs >= 3 then
							local first = { -1, -1 }
							for i = #inventory, 1, -1 do
								if counterIDHelper(inventory[i][1], inventory[i][2]) == id then
									first = { inventory[i][1], inventory[i][2] }
									table.remove(inventory, i)
								end
							end
							inventory[#inventory + 1] = { first[1], first[2], nil, nil, occurs, nil, nil }
						end
					end
				end
			else
				return
			end
		end

		local isMove = clickDown and clickItemSlot and not clickItemSlot.group and (getTickCount() - clickDown >= 200)
		local columns = math.ceil((#inventory == 0 and 1) or (#inventory / 5))
		local x = screenSize.x - columns * spacerBox - spacer
		local y = (screenSize.y - rows * spacerBox - spacer) / 2 + spacerBox + spacer

		if render then
			local x2 = x - spacerBox - 5
			local irows = isMove and ACTION_DROP or TAB_WALLET
			local jrows = isMove and ACTION_DESTROY or TAB_WEAPONS
			local y2 = y + spacerBox

			drawRoundedRectangle({
				position = {
					x = x2,
					y = y2 - spacerBox,
				},
				size = {
					x = spacerBox,
					y = (jrows - irows + 2) * spacerBox + spacer,
				},

				color = theme.GRAY[900],
				alpha = 1,
				radius = 8,

				borderWidth = 1,
				borderColor = theme.GRAY[800],
			})

			dxDrawImage(x2 + 15, y + 18, 48, 48, ":mek_ui/public/images/logo.png")

			for i = irows, jrows do
				local icon = actionIcons[i]
				local boxx = x2 + spacer
				local boxy = y2 + spacer + spacerBox * (i - irows)

				dxDrawText(
					icon[1],
					boxx,
					boxy,
					boxx + box,
					boxy + box,
					i == activeTab and rgba(theme.GRAY[100]) or rgba(theme.GRAY[500]),
					1,
					fonts.icon,
					"center",
					"center"
				)

				if not clickWorldItem and isInBox(cursorX, cursorY, boxx, boxx + box, boxy, boxy + box) then
					if i <= 4 then
						if not isMove then
							drawTooltip(cursorX, cursorY, icon[2], icon[3])
							hoverAction = i
						end
					elseif isMove then
						drawTooltip(cursorX, cursorY, icon[2], icon[3])
						hoverAction = i
					end
				end
			end

			isCursorOverInventory = isInBox(cursorX, cursorY, x, screenSize.x, y, y + rows * spacerBox + spacer)
				or isInBox(cursorX, cursorY, x2, x2 + spacerBox, y2, y2 + (jrows - irows + 1) * spacerBox + spacer)

			drawRoundedRectangle({
				position = {
					x = x,
					y = y,
				},
				size = {
					x = columns * spacerBox + spacer + 20,
					y = rows * spacerBox + spacer,
				},

				color = theme.GRAY[900],
				alpha = 1,
				radius = 8,

				borderWidth = 1,
				borderColor = theme.GRAY[800],
			})

			for i = 1, columns * 5 do
				local col = math.floor((i - 1) / 5)
				local row = (i - 1) % 5

				local boxx = x + col * spacerBox + spacer
				local boxy = y + row * spacerBox + spacer

				if i ~= 1 and i ~= 5 then
					color = i % 2 == 1 and rgba(theme.GRAY[900], 0.8) or rgba(theme.GRAY[800], 0.8)
					dxDrawRectangle(boxx, boxy, box, box, color)
				end

				local item = inventory[i]
				if item then
					if not isMove or item[4] ~= clickItemSlot.id then
						dxDrawImage(boxx + 12.5, boxy + 12.5, box - 25, box - 25, getImage(item[1], item[2]))

						local text = getOverlayText(item[1], item[2], item[5])
						if #text > 0 then
							dxDrawText(
								text,
								boxx + 2,
								boxy + 2,
								boxx + box - 2,
								boxy + box - 2,
								tooltipTextColor,
								1,
								fonts.UbuntuRegular.caption,
								"right",
								"bottom"
							)
						end

						if
							not isMove
							and not clickWorldItem
							and isInBox(cursorX, cursorY, boxx, boxx + box, boxy, boxy + box)
						then
							local t = { getTooltipFor(item[1], item[2], item[5], nil, item[6] or {}) }

							local action
							if not item[5] then
								if getKeyState("delete") then
									action = "delete"
								elseif getKeyState("lctrl") or getKeyState("rctrl") then
									action = "drop"
								elseif getKeyState("lshift") or getKeyState("rshift") then
									action = "split"
								end
							end

							drawTooltip(cursorX, cursorY, t[1], t[2], action, item)
							hoverItemSlot = { invslot = i, id = item[4], x = boxx, y = boxy, group = item[5] }
						end
					end
				else
					dxDrawText(
						"BOŞ",
						boxx,
						boxy,
						boxx + box,
						boxy + box,
						rgba(theme.GRAY[600]),
						1,
						fonts.UbuntuRegular.h6,
						"center",
						"center"
					)
				end
			end
		end

		if
			clickDown
			and (getTickCount() - clickDown >= 200)
			and (
				(clickItemSlot and not clickItemSlot.group)
				or (clickWorldItem and isElement(clickWorldItem) and not getElementData(clickWorldItem, "protected"))
			)
		then
			local boxx, boxy, item
			local color = fullColor
			local col, x, y, z

			if clickWorldItem then
				item = {
					getElementData(clickWorldItem, "itemID"),
					getElementData(clickWorldItem, "itemValue") or 1,
					false,
					false,
				}
				boxx = cursorX - spacer - box / 2
				boxy = cursorY - spacer - box / 2
				
				if isCursorOverInventory then
					if item[1] == 81 or item[1] == 103 then
						color = backgroundErrorColor
					elseif not hasSpaceForItem(localPlayer, item[1], item[2]) then
						color = backgroundErrorColor
					end
				else
					local cameraX, cameraY, cameraZ = getWorldFromScreenPosition(cursorX, cursorY, 0.1)
					col, x, y, z, hoverElement = processLineOfSight(cameraX, cameraY, cameraZ, cwX, cwY, cwZ)

					if not col or getDistanceBetweenPoints3D(x, y, z, getElementPosition(localPlayer)) >= 10 then
						color = backgroundErrorColor
					elseif hoverElement then
						local elementType = getElementType(hoverElement)
						if item[1] == 81 or item[1] == 103 then
							color = hoverElement == clickWorldItem and fullColor or backgroundErrorColor
						elseif elementType == "vehicle" then
							color = backgroundMoveToElementColor
						elseif elementType == "player" then
							color = item[1] < 0 and backgroundErrorColor or backgroundMoveToElementColor
						elseif getElementModel(hoverElement) == 2942 and item[1] == 150 then
							color = backgroundMoveToElementColor
						elseif getElementModel(hoverElement) == 2934 then
							color = backgroundMoveToElementColor
						elseif elementType == "object" then
							if
								getElementParent(getElementParent(hoverElement))
								== getResourceRootElement(getResourceFromName("mek_item-world"))
							then
								local targetItemID = getElementData(hoverElement, "itemID")
								local targetItemValue = getElementData(hoverElement, "itemValue") or 1

								if isStorageItem(targetItemID, targetItemValue) then
									color = backgroundMoveToElementColor or backgroundErrorColor
								elseif targetItemID == 166 and item[1] == 165 then
									color = backgroundMoveToElementColor
								else
									color = fullColor
								end
							else
								color = fullColor
							end
						else
							color = fullColor
						end
					end
				end
			else
				item = inventory[clickItemSlot.invslot]
				boxx = clickItemSlot.rx + cursorX
				boxy = clickItemSlot.ry + cursorY

				if not isCursorOverInventory then
					local cameraX, cameraY, cameraZ = getWorldFromScreenPosition(cursorX, cursorY, 0.1)
					col, x, y, z, hoverElement = processLineOfSight(cameraX, cameraY, cameraZ, cwX, cwY, cwZ)
					if not col or getDistanceBetweenPoints3D(x, y, z, getElementPosition(localPlayer)) >= 10 then
						color = backgroundErrorColor
					elseif hoverElement then
						local elementType = getElementType(hoverElement)
						if elementType == "vehicle" then
							color = backgroundMoveToElementColor
						elseif elementType == "player" then
							color = item[1] < 0 and backgroundErrorColor or backgroundMoveToElementColor
						elseif getElementModel(hoverElement) == 2942 and item[1] == 150 then
							color = backgroundMoveToElementColor
						elseif elementType == "ped" and getElementData(hoverElement, "customshop") then
							color = backgroundMoveToElementColor
						elseif elementType == "object" then
							if
								getElementParent(getElementParent(hoverElement))
								== getResourceRootElement(getResourceFromName("mek_item-world"))
							then
								local targetItemID = getElementData(hoverElement, "itemID")
								local targetItemValue = getElementData(hoverElement, "itemValue") or 1
								if isStorageItem(targetItemID, targetItemValue) then
									color = backgroundMoveToElementColor
								elseif targetItemID == 166 and item[1] == 165 then
									color = backgroundMoveToElementColor
								else
									color = fullColor
								end
							else
								color = fullColor
							end
						elseif hoverElement == getHoverElement() then
							color = fullColor
						else
							color = backgroundErrorColor
						end
					end
				end
			end

			dxDrawRectangle(boxx - spacer, boxy - spacer, box + 2 * spacer, box + 2 * spacer, rgba(backgroundColor))
			dxDrawRectangle(boxx, boxy, box, box, rgba(color or theme.GRAY[800]))
			dxDrawImage(boxx + 12.5, boxy + 12.5, box - 25, box - 25, getImage(item[1], item[2]))

			if hoverElement then
				if color == backgroundMoveToElementColor then
					local name = ""
					local elementType = getElementType(hoverElement)
					if elementType == "player" then
						name = getPlayerName(hoverElement):gsub("_", " ")
					elseif elementType == "ped" and getElementData(hoverElement, "shopkeeper") then
						name = "store"
					elseif elementType == "ped" then
						local pedName = tostring(getElementData(hoverElement, "name"))
						if pedName then
							name = pedName
						else
							name = "person"
						end
					elseif elementType == "vehicle" then
						name = getVehicleName(hoverElement) .. " (#" .. getElementData(hoverElement, "dbid") .. ")"
					elseif getElementModel(hoverElement) == 2942 then
						name = "ATM"
					elseif elementType == "object" then
						name = "storage"
						if
							getElementParent(getElementParent(hoverElement))
							== getResourceRootElement(getResourceFromName("mek_item-world"))
						then
							local targetItemID = getElementData(hoverElement, "itemID")
							if targetItemID == 166 then
								name = "video player"
							else
								local targetItemValue = getElementData(hoverElement, "itemValue") or 1
								name = getItemName(targetItemID, targetItemValue) or "storage"
							end
						end
					end
					drawTooltip(
						boxx + spacerBox,
						boxy + (box - 50) / 2,
						getItemName(item[1], item[2], item[6]),
						"TAŞI: " .. name
					)
				elseif color == fullColor then
					hoverElement = nil
				else
					hoverElement = false
				end
			else
				hoverElement = nil
			end
		end

		if render then
			if isCursorOverInventory or clickWorldItem then
				return
			end
		end

		local element = getHoverElement(true)
		if element then
			local itemID = getElementData(element, "itemID")
			local itemValue = getElementData(element, "itemValue") or 1

			if itemID ~= 81 and itemID ~= 103 then
				local tooltipText1, tooltipText2 =
					getTooltipFor(itemID, itemValue, false, getElementData(element, "protected"))
				drawTooltip(
					cursorX,
					cursorY,
					tooltipText1,
					getElementData(element, "transfering") and "Yükleniyor..." or tooltipText2
				)
			end
			hoverWorldItem = getHoverElement(true)
		end
	end
end, 0, 0)

addEventHandler("recieveItems", root, function()
	inventory = false
end)

addEventHandler("onClientClick", root, function(button, state, cursorX, cursorY, worldX, worldY, worldZ)
	if not waitingForItemDrop then
		if button == "left" or (button == "middle" and exports.mek_integration:isPlayerTrialAdmin(localPlayer)) then
			if button == "left" and (hoverItemSlot or clickItemSlot) then
				if state == "down" then
					clickDown = getTickCount()
					clickItemSlot = hoverItemSlot
					clickItemSlot.rx = clickItemSlot.x - cursorX
					clickItemSlot.ry = clickItemSlot.y - cursorY
				end

				if state == "down" and getKeyState("delete") then
					state = "up"
					clickDown = 0
					hoverAction = ACTION_DESTROY
				elseif state == "down" and (getKeyState("lctrl") or getKeyState("rctrl")) then
					state = "up"
					clickDown = 0
					hoverAction = ACTION_DROP
				elseif state == "down" and (getKeyState("lshift") or getKeyState("rshift")) then
					state = "up"
					clickDown = 0
					hoverAction = ACTION_SPLIT
				end

				if state == "up" and clickItemSlot then
					if getTickCount() - clickDown < 200 then
						if isCursorOverInventory then
							if clickItemSlot.group then
								activeTabItem = counterIDHelper(
									inventory[clickItemSlot.invslot][1],
									inventory[clickItemSlot.invslot][2]
								)
								inventory = false
							else
								useItem(
									inventory[clickItemSlot.invslot][1] < 0 and inventory[clickItemSlot.invslot][3]
										or clickItemSlot.id
								)
							end
						end
					elseif not clickItemSlot.group then
						if not isCursorOverInventory then
							if
								getDistanceBetweenPoints3D(worldX, worldY, worldZ, getElementPosition(localPlayer))
								< 10
							then
								local item = inventory[clickItemSlot.invslot]
								local itemID = item[1]
								local itemValue = item[2]
								if hoverElement == nil then
									if itemID > 0 then
										if
											itemID == 48
											and countItems(localPlayer, 48) == 1
											and getCarriedWeight(localPlayer) - getItemWeight(48, 1) > 10
										then
											outputChatBox(
												"[!]#FFFFFF Envanterinizde çok fazla eşya var.",
												255,
												0,
												0,
												true
											)
										else
											waitingForItemDrop = true
											triggerServerEvent(
												"dropItem",
												localPlayer,
												clickItemSlot.id,
												worldX,
												worldY,
												worldZ
											)
										end
									elseif itemID == -100 then
										waitingForItemDrop = true
										triggerServerEvent(
											"dropItem",
											localPlayer,
											100,
											worldX,
											worldY,
											worldZ,
											savedArmor
										)
									end
								elseif hoverElement then
									local elementType = getElementType(hoverElement)
									if itemID > 0 then
										waitingForItemDrop = true
										triggerServerEvent(
											"moveToElement",
											localPlayer,
											hoverElement,
											clickItemSlot.id,
											nil,
											"finishItemDrop"
										)
									elseif itemID == -100 then
										triggerServerEvent(
											"moveToElement",
											localPlayer,
											hoverElement,
											clickItemSlot.id,
											true,
											"finishItemDrop"
										)
									end
								end
							end
						elseif hoverAction == ACTION_DROP then
							local item = inventory[clickItemSlot.invslot]
							local itemID = item[1]
							local itemValue = item[2]

							local matrix = getElementMatrix(localPlayer)
							local oldX = 0
							local oldY = 1
							local oldZ = 0
							local x = oldX * matrix[1][1] + oldY * matrix[2][1] + oldZ * matrix[3][1] + matrix[4][1]
							local y = oldX * matrix[1][2] + oldY * matrix[2][2] + oldZ * matrix[3][2] + matrix[4][2]
							local z = oldX * matrix[1][3] + oldY * matrix[2][3] + oldZ * matrix[3][3] + matrix[4][3]

							local z = getGroundPosition(x, y, z + 2)

							if itemID > 0 then
								waitingForItemDrop = true
								triggerServerEvent("dropItem", localPlayer, clickItemSlot.id, x, y, z)
							elseif itemID == -100 then
								waitingForItemDrop = true
								triggerServerEvent("dropItem", localPlayer, 100, x, y, z, savedArmor)
							else
								local slot = -item[3]
								if slot >= 2 and slot <= 9 then
									openWeaponDropGUI(-itemID, itemValue, x, y, z)
								else
									waitingForItemDrop = true
									triggerServerEvent("dropItem", localPlayer, -itemID, x, y, z, itemValue)
								end
							end
						elseif hoverAction == ACTION_SHOW then
							local item = inventory[clickItemSlot.invslot]
							local itemName, itemValue =
								getItemName(item[1], item[2], item[6]), getItemValue(item[1], item[2], item[6])
							if item[1] == 72 then
								itemName = itemName .. ", reading " .. itemValue
							elseif item[1] == 79 then
								itemName = itemName .. ", " .. itemValue
							elseif
								item[1] == 64
								or item[1] == 65
								or item[1] == 86
								or item[1] == 87
								or item[1] == 82
								or item[1] == 112
								or item[1] == 127
							then
								itemName = itemName .. ", reading " .. itemValue
							elseif
								item[1] == 133
								or item[1] == 153
								or item[1] == 154
								or item[1] == 155
								or item[1] == 78
							then
								itemName = itemName .. ", issued for " .. itemValue
							elseif item[1] == 150 then
								if itemValue and type(itemValue) == "string" then
									local itemExploded = split(itemValue, ";")
									if itemExploded and itemExploded[2] then
										local owner = exports.mek_cache:getCharacterNameFromID(itemExploded[2])
										if owner then
											owner = string.gsub(owner, "_", " ")
											itemName = itemName .. ", issued for " .. owner
										end
									end
								end
							elseif item[1] == 152 then
								if itemValue and type(itemValue) == "string" then
									local itemExploded = split(itemValue, ";")
									if itemExploded and itemExploded[1] then
										local owner = itemExploded[1]
										owner = string.gsub(owner, "_", " ")
										itemName = itemName .. ", issued for " .. owner
									end
								end
							end
							triggerServerEvent("showItem", localPlayer, itemName)
						elseif hoverAction == ACTION_DESTROY then
							local item = inventory[clickItemSlot.invslot]
							local itemID = item[1]
							local itemSlot = itemID < 0 and itemID or clickItemSlot.id
							if itemID == 48 and countItems(localPlayer, 48) == 1 then
								if getCarriedWeight(localPlayer) - getItemWeight(48, 1) > 10 then
									outputChatBox("[!]#FFFFFF Envanterinizde çok fazla eşya var.", 255, 0, 0, true)
								else
									triggerServerEvent("destroyItem", localPlayer, itemSlot)
								end
							elseif itemID == 134 then
								outputChatBox("[!]#FFFFFF Parayı silemezsiniz.", 255, 0, 0, true)
							else
								triggerServerEvent("destroyItem", localPlayer, itemSlot)
							end
						elseif hoverAction == ACTION_SPLIT then
							local item = inventory[clickItemSlot.invslot]
							local itemName, itemValue = getItemName(item[1], item[2]), getItemValue(item[1], item[2])
							local itemID = item[1]
							if splittableItems[itemID] then
								splitItem(itemID, itemName, itemValue, item)
							else
								outputChatBox(
									"[!]#FFFFFF "
										.. itemName
										.. " bölünebilir bir yapıda değildir, bölünebilir öğelerin listesini görmek için /splits yazın.",
									255,
									0,
									0,
									true
								)
							end
						end
					end
					hoverItemSlot = false
					clickItemSlot = false
					clickDown = false
				end
			elseif hoverWorldItem or clickWorldItem and isElement(clickWorldItem) then
				if state == "down" and button == "left" then
					local x, y, z = getElementPosition(localPlayer)
					local eX, eY, eZ = getElementPosition(hoverWorldItem)
					local minX, minY, minZ, maxX, maxY, maxZ = getElementBoundingBox(hoverWorldItem)
					local addDistance = 0
					if minX then
						local boundingBoxBiggestDist = 0
						if minX > boundingBoxBiggestDist then
							boundingBoxBiggestDist = minX
						end
						if minY > boundingBoxBiggestDist then
							boundingBoxBiggestDist = minY
						end
						if maxX > boundingBoxBiggestDist then
							boundingBoxBiggestDist = maxX
						end
						if maxY > boundingBoxBiggestDist then
							boundingBoxBiggestDist = maxY
						end
						addDistance = boundingBoxBiggestDist
					end
					local maxDistance = 3 + addDistance
					if getDistanceBetweenPoints3D(x, y, z, eX, eY, eZ) <= maxDistance then
						local itemID = getElementData(hoverWorldItem, "itemID")
						if itemID == 169 then
							triggerServerEvent("openKeypadInterface", localPlayer, hoverWorldItem)
						else
							for _, value in ipairs(getElementsByType("player")) do
								if
									getPedContactElement(value) == hoverWorldItem
									or isLikelyStandingOn(value, hoverWorldItem)
								then
									return
								end
							end

							clickDown = getTickCount()
							clickWorldItem = hoverWorldItem

							if not getElementData(clickWorldItem, "protected") then
								if
									exports["mek_item-world"]:can(localPlayer, "pickup", clickWorldItem)
									or exports["mek_item-world"]:can(localPlayer, "move", clickWorldItem)
									or getKeyState("p")
									or getKeyState("n")
								then
									setElementAlpha(clickWorldItem, 150)
									setElementCollisionsEnabled(clickWorldItem, false)
								end
							end
						end
					end
				elseif state == "up" and clickWorldItem and isElement(clickWorldItem) then
					local x, y, z = getElementPosition(localPlayer)
					local eX, eY, eZ = getElementPosition(clickWorldItem)
					local minX, minY, minZ, maxX, maxY, maxZ = getElementBoundingBox(clickWorldItem)
					local addDistance = 0
					if minX then
						local boundingBoxBiggestDist = 0
						if minX > boundingBoxBiggestDist then
							boundingBoxBiggestDist = minX
						end
						if minY > boundingBoxBiggestDist then
							boundingBoxBiggestDist = minY
						end
						if maxX > boundingBoxBiggestDist then
							boundingBoxBiggestDist = maxX
						end
						if maxY > boundingBoxBiggestDist then
							boundingBoxBiggestDist = maxY
						end
						addDistance = boundingBoxBiggestDist
					end
					local maxDistance = 3 + addDistance
					if getDistanceBetweenPoints3D(x, y, z, eX, eY, eZ) <= maxDistance then
						setElementAlpha(clickWorldItem, 255)
						setElementCollisionsEnabled(clickWorldItem, true)

						local itemID = tonumber(getElementData(clickWorldItem, "itemID")) or 0
						local canBePickedUp = not (itemID == 81 or itemID == 103 or itemID == 169 or itemID == 223)
							and not getElementData(clickWorldItem, "transfering")
						if canBePickedUp then
							if getItemUseNewPickupMethod(itemID) then
								canBePickedUp = false
							end
						end

						if getKeyState("p") then
							if exports.mek_global:isAdminOnDuty(localPlayer) then
								triggerServerEvent("protectItem", clickWorldItem, fp)
							end
						elseif getKeyState("n") then
							if
								exports.mek_global:isAdminOnDuty(localPlayer)
								or (
									getElementDimension(localPlayer) ~= 0
										and hasItem(localPlayer, 4, getElementDimension(localPlayer))
									or hasItem(localPlayer, 5, getElementDimension(localPlayer))
								)
							then
								if exports["mek_item-world"]:can(localPlayer, "move", clickWorldItem) then
									triggerEvent("item:move", root, clickWorldItem)
								end
							end
						else
							if getTickCount() - clickDown < 200 then
								if canBePickedUp then
									if itemID == 169 then
										triggerServerEvent("openKeypadInterface", localPlayer, clickWorldItem)
									else
										pickupItem("left", "down", clickWorldItem)
									end
								end
							else
								if isCursorOverInventory then
									if canBePickedUp then
										if itemID == 169 then
											triggerServerEvent("openKeypadInterface", localPlayer, clickWorldItem)
										else
											pickupItem("left", "down", clickWorldItem)
										end
									end
								elseif rotate then
									local rx, ry, rz = getElementRotation(clickWorldItem)
									setElementRotation(clickWorldItem, rx, ry, rz - rotate)
									triggerServerEvent("rotateItem", localPlayer, clickWorldItem, rotate)
								else
									if
										getDistanceBetweenPoints3D(
											worldX,
											worldY,
											worldZ,
											getElementPosition(localPlayer)
										) < 10
									then
										if hoverElement == nil then
											for _, value in ipairs(getElementsByType("player")) do
												if
													getPedContactElement(value) == clickWorldItem
													or isLikelyStandingOn(value, clickWorldItem)
												then
													return
												end
											end
											if exports["mek_item-world"]:can(localPlayer, "move", clickWorldItem) then
												triggerServerEvent(
													"moveItem",
													localPlayer,
													clickWorldItem,
													worldX,
													worldY,
													worldZ
												)
											end
										else
											if button == "left" then
												local hoverElementX, hoverElementY, hoverElementZ =
													getElementPosition(hoverElement)
												local hoverMinX, hoverMinY, hoverMinZ, hoverMaxX, hoverMaxY, hoverMaxZ =
													getElementBoundingBox(hoverElement)
												local hoverAddDistance = 0
												if hoverMinX then
													local hoverBoundingBoxBiggestDist = 0
													if hoverMinX > hoverBoundingBoxBiggestDist then
														hoverBoundingBoxBiggestDist = hoverMinX
													end
													if hoverMinY > hoverBoundingBoxBiggestDist then
														hoverBoundingBoxBiggestDist = hoverMinY
													end
													if hoverMaxX > hoverBoundingBoxBiggestDist then
														hoverBoundingBoxBiggestDist = hoverMaxX
													end
													if hoverMaxY > hoverBoundingBoxBiggestDist then
														hoverBoundingBoxBiggestDist = hoverMaxY
													end
													hoverAddDistance = hoverBoundingBoxBiggestDist
												end

												local hoverMaxDistance = 3 + hoverAddDistance + addDistance

												if
													getDistanceBetweenPoints3D(
														hoverElementX,
														hoverElementY,
														hoverElementZ,
														eX,
														eY,
														eZ
													) < hoverMaxDistance
												then
													if
														exports["mek_item-world"]:can(
															localPlayer,
															"pickup",
															clickWorldItem
														)
													then
														if hoverElement == localPlayer then
															pickupItem("left", "down", clickWorldItem)
														else
															triggerServerEvent(
																"moveWorldItemToElement",
																localPlayer,
																clickWorldItem,
																hoverElement
															)
														end
													end
												end
											end
										end
									end
								end
							end
						end

						clickWorldItem = false
						cursorDown = false
						rotate = false
					end
				end
			elseif button == "left" and isCursorOverInventory and hoverAction and state == "down" then
				if render then
					if activeTabItem then
						activeTabItem = nil
						activeTab = hoverAction
					else
						activeTab = hoverAction
					end
				else
					activeTab = hoverAction
					render = true
				end
				inventory = false
			end
		elseif button == "right" then
			if clickItemSlot then
				clickItemSlot = false
				clickDown = false
			end

			if clickWorldItem then
				setElementAlpha(clickWorldItem, 255)
				setElementCollisionsEnabled(clickWorldItem, true)
				clickWorldItem = false
				clickDown = false
			end

			if state == "up" and hoverWorldItem then
				local x, y, z = getElementPosition(localPlayer)
				local eX, eY, eZ = getElementPosition(hoverWorldItem)
				local minX, minY, minZ, maxX, maxY, maxZ = getElementBoundingBox(hoverWorldItem)
				local addDistance = 0
				
				if minX then
					local boundingBoxBiggestDist = 0
					if minX > boundingBoxBiggestDist then
						boundingBoxBiggestDist = minX
					end
					if minY > boundingBoxBiggestDist then
						boundingBoxBiggestDist = minY
					end
					if maxX > boundingBoxBiggestDist then
						boundingBoxBiggestDist = maxX
					end
					if maxY > boundingBoxBiggestDist then
						boundingBoxBiggestDist = maxY
					end
					addDistance = boundingBoxBiggestDist
				end

				local maxDistance = 3 + addDistance
				if getDistanceBetweenPoints3D(x, y, z, eX, eY, eZ) <= maxDistance then
					if
						getElementData(hoverWorldItem, "itemID") == 54
						or getElementData(hoverWorldItem, "itemID") == 176
					then
						item = hoverWorldItem
						ax, ay = cursorX, cursorY
						showItemMenu()
					end
				end
			end
		end
	end
end)

bindKey("i", "down", function()
	if not getElementData(localPlayer, "logged") then return end

	if render then
		hideNewInventory()
		return
	end

	local adminJailed = getElementData(localPlayer, "admin_jailed") == true
	local isTrialAdmin = exports.mek_integration:isPlayerTrialAdmin(localPlayer)

	if not adminJailed or isTrialAdmin then
		render = true
		activeTabItem = nil
		inventory = false
		showCursor(true)
	else
		outputChatBox(
			"[!]#FFFFFF Hapishanede envanterinize erişemezsiniz.",
			255, 0, 0, true
		)
	end
end)

addEvent("finishItemDrop", true)
addEventHandler("finishItemDrop", localPlayer, function()
	waitingForItemDrop = false
	inventory = false
end)

function hideNewInventory()
	clickDown = false
	clickItemSlot = false
	rotate = false
	if clickWorldItem then
		if isElement(clickWorldItem) then
			setElementAlpha(clickWorldItem, 255)
			setElementCollisionsEnabled(clickWorldItem, true)
		end
		clickWorldItem = false
	end

	if render then
		render = false
		showCursor(false)
	end
end

function splitItem(itemID, itemName, itemValue, item)
	local width, height = 226, 78
	local scrWidth, scrHeight = guiGetScreenSize()
	local x = scrWidth / 2 - (width / 2)
	local y = scrHeight / 2 - (height / 2)

	showCursor(true)
	guiSetInputEnabled(true)

	local wSplitting = guiCreateWindow(x, y, width, height, itemName .. " - " .. itemValue, false)
	guiWindowSetSizable(wSplitting, false)

	local GUIEditor_Label = guiCreateLabel(12, 20, 54, 24, "Miktar:", false, wSplitting)
	guiLabelSetVerticalAlign(GUIEditor_Label, "center")
	guiSetFont(GUIEditor_Label, "default-bold-small")

	local eAmount = guiCreateEdit(66, 20, 146, 24, "bir tam sayı", false, wSplitting)
	local bOK = guiCreateButton(12, 48, 100, 21, "Onayla", false, wSplitting)
	local bCancel = guiCreateButton(112, 48, 100, 21, "İptal", false, wSplitting)

	addEventHandler("onClientGUIClick", eAmount, function()
		guiSetText(eAmount, "")
	end, false)

	addEventHandler("onClientGUIClick", bCancel, function()
		destroyElement(wSplitting)
		wSplitting = nil
		guiSetInputEnabled(false)
	end, false)

	addEventHandler("onClientGUIClick", bOK, function()
		local amount = tonumber(guiGetText(eAmount))
		if not amount then
			guiSetText(wSplitting, "Miktar mutlaka sayı olmalıdır.")
			return false
		end
		if amount % 1 ~= 0 then
			guiSetText(wSplitting, "Tutar tam sayı olmalıdır, örneğin 1, 2, 3...")
			return false
		else
			if amount <= 0 then
				guiSetText(wSplitting, "Tutar 0'dan büyük olmalıdır.")
				return false
			end
		end

		triggerServerEvent("splitItem", localPlayer, localPlayer, "split", itemID, amount)

		destroyElement(wSplitting)
		wSplitting = nil
		guiSetInputEnabled(false)
	end, false)
end

function isLikelyStandingOn(player, object)
	if replacedModelsWithWrongCollisionCheck[getElementModel(object)] then
		return false
	end

	local minX, minY, minZ, maxX, maxY, maxZ = getElementBoundingBox(object)
	local oX, oY, oZ = getElementPosition(object)
	local pX, pY, pZ = getElementPosition(player)
	if isPedOnGround(player) then
		pZ = getGroundPosition(pX, pY, pZ)
	else
		pZ = pZ - 1
	end

	return not (
		pX < oX + minX
		or pX > oX + maxX
		or pY < oY + minY
		or pY > oY + maxY
		or pZ < oZ + minZ
		or pZ > oZ + maxZ
	)
end

function isInventoryVisible()
	return render
end
