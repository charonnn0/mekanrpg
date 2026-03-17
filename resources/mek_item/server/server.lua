Async:setPriority("low")

local badges = getBadges()
local masks = getMasks()

local playerLastDamageTick = {}

addEventHandler("onPlayerDamage", root, function()
    playerLastDamageTick[source] = getTickCount()
end)

addEventHandler("onPlayerQuit", root, function()
    playerLastDamageTick[source] = nil
end)

function giveHealth(player, amount)
	if not isElement(player) or getElementType(player) ~= "player" then
		return
	end

	local currentHealth = getElementHealth(player) or 0
	amount = tonumber(amount) or 100

	local newHealth = math.min(currentHealth + amount, 100)
	exports.mek_sac:allowHealthChange(player, "item_health")
	setElementHealth(player, newHealth)
end

function giveArmor(player, amount)
	if not isElement(player) or getElementType(player) ~= "player" then
		return
	end

	local currentArmor = getPedArmor(player) or 0
	amount = tonumber(amount) or 100

	local newArmor = math.min(currentArmor + amount, 100)
	exports.mek_sac:allowArmorChange(player, "item_armor")
	setPedArmor(player, newArmor)
end

function removeOOC(text)
	if not text then
		return ""
	end
	return text:gsub("%s*%(%(([^)]+)%)%)%s*", "")
end

local shields = {}
local presents = { 1, 7, 8, 15, 11, 12, 19, 26, 59, 71 }
local glowstickColor = 1

function fixShield()
	for i, s in pairs(shields) do
		if isElement(s) then
			local plr = getElementAttachedTo(s)
			if isElement(plr) and getElementType(plr) == "player" then
				local interior = getElementInterior(plr)
				local dimension = getElementDimension(plr)
				setElementInterior(s, interior)
				setElementDimension(s, dimension)
			end
		end
	end
end
setTimer(fixShield, 50, 0)

function useItem(itemSlot, additional)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not itemSlot then
		return
	end

	local items = getItems(source)
	if not type(items) == "table" then
		return
	end

	if not items[itemSlot] then
		return
	end

	local itemID = items[itemSlot][1]
	local itemValue = items[itemSlot][2]
	local itemName = getItemName(itemID, itemValue)

	if isPedDead(source) then
		return
	end

	local hasItemProtect = hasItem(source, tonumber(itemID), tostring(itemValue))
		or hasItem(source, tonumber(itemID), tonumber(itemValue))
	if not hasItemProtect then
		return
	end

	if itemID then
		local FOOD_CATEGORY = 1
		local isFoodOrDrink = (getItemType and getItemType(itemID) == FOOD_CATEGORY)
		if isFoodOrDrink then
			local lastHit = playerLastDamageTick[source] or 0
			local threeMinutes = 180000 -- ms
			if getTickCount() - lastHit < threeMinutes then
				outputChatBox("[!]#FFFFFF Son 3 dakika içinde hasar aldınız, şu an yiyemezsiniz.", source, 255, 0, 0, true)
				return
			end
		end

		if itemID == 1 then
			takeItemFromSlot(source, itemSlot)
			exports.mek_global:sendLocalMeAction(source, "elindeki sosisliyi yemeye başlar.")
			giveHealth(source, 20)

			if getElementData(source, "hunger") <= 100 then
				if getElementData(source, "hunger") >= 75 then
					setElementData(source, "hunger", 100)
				else
					setElementData(source, "hunger", getElementData(source, "hunger") + 25)
				end
			end
		elseif itemID == 3 then
			local veh = getPedOccupiedVehicle(source)
			if veh and getElementData(veh, "dbid") == itemValue then
				triggerEvent("lockUnlockInsideVehicle", source, veh)
			else
				local value = exports.mek_pool:getElementByID("vehicle", itemValue)
				if value then
					local vx, vy, vz = getElementPosition(value)
					local x, y, z = getElementPosition(source)

					if getDistanceBetweenPoints3D(x, y, z, vx, vy, vz) <= 30 then
						triggerEvent("lockUnlockOutsideVehicle", source, value)
					else
						outputChatBox("You are too far from the vehicle.", source, 255, 194, 14)
					end
				else
					outputChatBox("Invalid Vehicle.", source, 255, 194, 14)
				end
			end
		elseif (itemID == 4) or (itemID == 5) then
			local itemValue = tonumber(itemValue)
			local found = false

			local posX, posY, posZ = getElementPosition(source)
			local dimension = getElementDimension(source)
			local possibleInteriors = getElementsByType("interior")
			for _, interior in ipairs(possibleInteriors) do
				local interiorEntrance = getElementData(interior, "entrance")
				local interiorExit = getElementData(interior, "exit")
				local interiorID = getElementData(interior, "dbid")
				if interiorID == itemValue then
					for _, point in ipairs({ interiorEntrance, interiorExit }) do
						if point[5] == dimension then
							local distance = getDistanceBetweenPoints3D(posX, posY, posZ, point[1], point[2], point[3])
							if distance <= 6 then
								found = interiorID
								break
							end
						end
					end
				end
			end

			if not found then
				local possibleElevators = getElementsByType("elevator")
				for _, elevator in ipairs(possibleElevators) do
					local elevatorEntrance = getElementData(elevator, "entrance")
					local elevatorExit = getElementData(elevator, "exit")

					for _, point in ipairs({ elevatorEntrance, elevatorExit }) do
						if point[5] == dimension then
							local distance = getDistanceBetweenPoints3D(posX, posY, posZ, point[1], point[2], point[3])
							if distance < 6 then
								if elevatorEntrance[5] == itemValue then
									found = elevatorEntrance[5]
									break
								elseif elevatorExit[5] == itemValue then
									found = elevatorExit[5]
									break
								end
							end
						end
					end
				end
			end

			if found then
				local dbid, entrance, exit, interiorType, interiorElement =
					exports.mek_interior:findProperty(source, found)
				local interiorStatus = getElementData(interiorElement, "status")
				local locked = interiorStatus.locked and 1 or 0

				locked = 1 - locked

				local newRealLockedValue = false
				dbExec(mysql:getConnection(), "UPDATE interiors SET locked = ? WHERE id = ? LIMIT 1", locked, found)
				if locked == 0 then
					exports.mek_global:sendLocalMeAction(source, "puts the key in the door to unlock it.")
				else
					newRealLockedValue = true
					exports.mek_global:sendLocalMeAction(source, "puts the key in the door to lock it.")
				end

				interiorStatus.locked = newRealLockedValue
				setElementData(interiorElement, "status", interiorStatus, true)
			else
				outputChatBox("[!]#FFFFFF Kapıdan çok uzaktasınız.", source, 255, 0, 0, true)
			end
		elseif itemID == 73 then
			local itemValue = tonumber(itemValue)
			local found = nil

			local dimension = getElementDimension(source)
			local posX, posY, posZ = getElementPosition(source)
			local possibleElevators = getElementsByType("elevator")
			for _, elevator in ipairs(possibleElevators) do
				local elevatorEntrance = getElementData(elevator, "entrance")
				local elevatorExit = getElementData(elevator, "exit")
				local elevatorID = getElementData(elevator, "dbid")
				if elevatorID == itemValue then
					for _, point in ipairs({ elevatorEntrance, elevatorExit }) do
						if point[5] == dimension then
							local distance = getDistanceBetweenPoints3D(posX, posY, posZ, point[1], point[2], point[3])
							if distance < 6 then
								found = elevator
								break
							end
						end
					end
				end
			end

			if not found then
				outputChatBox("[!]#FFFFFF Kapıdan çok uzaktasınız.", source, 255, 0, 0, true)
			else
				triggerEvent("toggleCarTeleportMode", found, source)
			end
		elseif itemID == 8 then
			takeItemFromSlot(source, itemSlot)
			exports.mek_global:sendLocalMeAction(source, "bir sandviç yer.")
			giveHealth(source, 50)

			if getElementData(source, "hunger") <= 100 then
				if getElementData(source, "hunger") >= 75 then
					setElementData(source, "hunger", 100)
				else
					setElementData(source, "hunger", getElementData(source, "hunger") + 25)
				end
			end
		elseif itemID == 9 then
			takeItemFromSlot(source, itemSlot)
			exports.mek_global:sendLocalMeAction(source, "elindeki sprunku içmeye başlar.")
			giveHealth(source, 30)

			if getElementData(source, "thirst") <= 100 then
				if getElementData(source, "thirst") >= 75 then
					setElementData(source, "thirst", 100)
				else
					setElementData(source, "thirst", getElementData(source, "thirst") + 25)
				end
			end
		elseif itemID == 10 then
			exports.mek_global:sendLocalText(
				source,
				"✪ " .. getPlayerName(source):gsub("_", " ") .. " zar attı ((" .. math.random(1, 6) .. "))",
				102,
				255,
				255
			)
		elseif itemID == 217 then
			exports.mek_global:sendLocalText(
				source,
				"✪ "
					.. getPlayerName(source):gsub("_", " ")
					.. " zar attı (("
					.. math.random(1, 6)
					.. ", "
					.. math.random(1, 6)
					.. "))",
				102,
				255,
				255
			)
		elseif itemID == 11 then
			takeItemFromSlot(source, itemSlot)
			exports.mek_global:sendLocalMeAction(source, "elindeki tacoyu yemeye başlar.")
			giveHealth(source, 10)

			if getElementData(source, "hunger") <= 100 then
				if getElementData(source, "hunger") >= 75 then
					setElementData(source, "hunger", 100)
				else
					setElementData(source, "hunger", getElementData(source, "hunger") + 25)
				end
			end
		elseif itemID == 12 then
			takeItemFromSlot(source, itemSlot)
			exports.mek_global:sendLocalMeAction(source, "elindeki çizburgeri yemeye başlar.")
			giveHealth(source, 10)

			if getElementData(source, "hunger") <= 100 then
				if getElementData(source, "hunger") >= 75 then
					setElementData(source, "hunger", 100)
				else
					setElementData(source, "hunger", getElementData(source, "hunger") + 25)
				end
			end
		elseif itemID == 13 then
			takeItemFromSlot(source, itemSlot)
			exports.mek_global:sendLocalMeAction(source, "elindeki donutu yemeye başlar.")
			giveHealth(source, 25)

			if getElementData(source, "hunger") <= 100 then
				if getElementData(source, "hunger") >= 75 then
					setElementData(source, "hunger", 100)
				else
					setElementData(source, "hunger", getElementData(source, "hunger") + 25)
				end
			end
		elseif itemID == 14 then
			takeItemFromSlot(source, itemSlot)
			exports.mek_global:sendLocalMeAction(source, "elindeki kurabiyeyi yemeye başlar.")
			giveHealth(source, 25)

			if getElementData(source, "hunger") <= 100 then
				if getElementData(source, "hunger") >= 75 then
					setElementData(source, "hunger", 100)
				else
					setElementData(source, "hunger", getElementData(source, "hunger") + 25)
				end
			end
		elseif itemID == 15 then
			takeItemFromSlot(source, itemSlot)
			exports.mek_global:sendLocalMeAction(source, "elindeki su şişesini içmeye başlar.")
			giveHealth(source, 30)

			if getElementData(source, "thirst") <= 100 then
				if getElementData(source, "thirst") >= 75 then
					setElementData(source, "thirst", 100)
				else
					setElementData(source, "thirst", getElementData(source, "thirst") + 25)
				end
			end
		elseif itemID == 16 then
			local skinID, clothingID, modelID = unpack(split(tostring(itemValue), ";"))
			skinID = tonumber(skinID)
			clothingID = tonumber(clothingID) or 0
			modelID = tonumber(modelID) or 0

			setElementModel(source, skinID)
			setElementData(source, "clothing_id", clothingID)
			setElementData(source, "model", modelID)
			dbExec(
				mysql:getConnection(),
				"UPDATE characters SET skin = ?, clothing_id = ?, model = ? WHERE id = ?",
				skinID,
				clothingID,
				modelID,
				dbid
			)
			exports.mek_global:sendLocalMeAction(source, "adım-adım kıyafetlerini değiştirir.")
		elseif itemID == 17 then
			exports.mek_global:sendLocalMeAction(source, "gözlerini saatine çevirir.")
			outputChatBox("[!]#FFFFFF Saat: " .. string.format("%02d:%02d", getTime()), source, 0, 55, 255, true)
			setPedAnimation(source, "COP_AMBIENT", "Coplook_watch", 4000, false, true, true)
		elseif itemID == 20 then
			setPedFightingStyle(source, 4)
			outputChatBox(
				"[!]#FFFFFF Bir kitap okudunuz ve Standart Dövüş Stili öğrendiniz.",
				source,
				0,
				255,
				0,
				true
			)
			dbExec(
				mysql:getConnection(),
				"UPDATE characters SET fighting_style = 4 WHERE id = ?",
				getElementData(source, "dbid")
			)
		elseif itemID == 21 then
			setPedFightingStyle(source, 5)
			outputChatBox("[!]#FFFFFF Bir kitap okudunuz ve Boks Dövüş Stili öğrendiniz.", source, 0, 255, 0, true)
			dbExec(
				mysql:getConnection(),
				"UPDATE characters SET fighting_style = 5 WHERE id = ?",
				getElementData(source, "dbid")
			)
		elseif itemID == 22 then
			setPedFightingStyle(source, 6)
			outputChatBox(
				"[!]#FFFFFF Bir kitap okudunuz ve Kung Fu Dövüş Stili öğrendiniz.",
				source,
				0,
				255,
				0,
				true
			)
			dbExec(
				mysql:getConnection(),
				"UPDATE characters SET fighting_style = 6 WHERE id = ?",
				getElementData(source, "dbid")
			)
		elseif itemID == 23 then
			setPedFightingStyle(source, 7)
			outputChatBox(
				"[!]#FFFFFF Kitabı açtınız ve kitabın eski Yunanca yazıldığını fark ettiniz.",
				source,
				0,
				255,
				0,
				true
			)
			dbExec(
				mysql:getConnection(),
				"UPDATE characters SET fighting_style = 7 WHERE id = ?",
				getElementData(source, "dbid")
			)
		elseif itemID == 24 then
			setPedFightingStyle(source, 15)
			outputChatBox(
				"[!]#FFFFFF Bir kitap okudunuz ve Tutup Tekme Dövüş Stili öğrendiniz.",
				source,
				0,
				255,
				0,
				true
			)
			dbExec(
				mysql:getConnection(),
				"UPDATE characters SET fighting_style = 15 WHERE id = ?",
				getElementData(source, "dbid")
			)
		elseif itemID == 25 then
			setPedFightingStyle(source, 16)
			outputChatBox(
				"[!]#FFFFFF Bir kitap okudunuz ve Dirsek Dövüş Stili öğrendiniz.",
				source,
				0,
				255,
				0,
				true
			)
			dbExec(
				mysql:getConnection(),
				"UPDATE characters SET fighting_style = 16 WHERE id = ?",
				getElementData(source, "dbid")
			)
		elseif itemID == 27 then
			takeItemFromSlot(source, itemSlot)

			local obj = createObject(343, unpack(additional))
			exports.mek_pool:allocateElement(obj)
			setTimer(explodeFlash, math.random(400, 800), 1, obj)
			exports.mek_global:sendLocalMeAction(source, "flaş bombası atar.")
			setElementInterior(obj, getElementInterior(source))
			setElementDimension(obj, getElementDimension(source))
		elseif itemID == 28 then
			takeItemFromSlot(source, itemSlot)

			local x, y, groundz = unpack(additional)
			local marker = nil
			if tostring(itemValue) == "2" then
				marker = createMarker(x, y, groundz, "corona", 1, 255, 0, 0, 150)
			elseif tostring(itemValue) == "3" then
				marker = createMarker(x, y, groundz, "corona", 1, 0, 255, 0, 150)
			elseif tostring(itemValue) == "4" then
				marker = createMarker(x, y, groundz, "corona", 1, 255, 255, 0, 150)
			elseif tostring(itemValue) == "5" then
				marker = createMarker(x, y, groundz, "corona", 1, 255, 0, 255, 150)
			elseif tostring(itemValue) == "6" then
				marker = createMarker(x, y, groundz, "corona", 1, 0, 255, 255, 150)
			elseif tostring(itemValue) == "7" then
				marker = createMarker(x, y, groundz, "corona", 1, 255, 255, 255, 150)
			else
				marker = createMarker(x, y, groundz, "corona", 1, 0, 0, 255, 150)
			end
			exports.mek_pool:allocateElement(marker)
			exports.mek_global:sendLocalMeAction(source, "yere glowstick bırakır.")
			setTimer(destroyElement, 600000, 1, marker)
		elseif itemID == 29 then
			local found = false
			local lastDistance = 5
			local posX, posY, posZ = getElementPosition(source)
			local dimension = getElementDimension(source)
			local possibleInteriors = getElementsByType("interior")
			for _, interior in ipairs(possibleInteriors) do
				local interiorEntrance = getElementData(interior, "entrance")
				local interiorExit = getElementData(interior, "exit")

				for _, point in ipairs({ interiorEntrance, interiorExit }) do
					if point[5] == dimension then
						local distance = getDistanceBetweenPoints3D(posX, posY, posZ, point[1], point[2], point[3])
						if distance < lastDistance then
							found = interior
							lastDistance = distance
						end
					end
				end
			end

			if not found then
				outputChatBox("[!]#FFFFFF Kapıdan çok uzaktasınız.", source, 255, 0, 0, true)
			else
				local dbid = getElementData(found, "dbid")
				local interiorStatus = getElementData(found, "status")

				if
					(interiorStatus.type ~= 2)
					and (interiorStatus.owner < 0)
					and interiorStatus.locked
					and not interiorStatus.disabled
				then
					outputChatBox("[!]#FFFFFF Bu kapı oyuncuya ait değil.", source, 255, 0, 0, true)
				elseif interiorStatus.disabled then
					outputChatBox("[!]#FFFFFF Bu kapı kapalı.", source, 255, 0, 0, true)
				elseif interiorStatus.locked then
					interiorStatus.locked = false
					setElementData(found, "status", interiorStatus, true)
					dbExec(mysql:getConnection(), "UPDATE interiors SET locked = 0 WHERE id = ? LIMIT 1", dbid)
					exports.mek_global:sendLocalMeAction(source, "kapı ram-ı kapıya yerleştirir ve kapını açar.")
				else
					outputChatBox("[!]#FFFFFF Bu kapı kapalı.", source, 255, 0, 0, true)
				end
			end
		elseif itemID == 34 then
			takeItemFromSlot(source, itemSlot)
			exports.mek_global:sendLocalMeAction(source, "biraz Kokain koklar.")
			giveArmor(source, 30)
		elseif itemID == 35 then
			takeItemFromSlot(source, itemSlot)
			exports.mek_global:sendLocalMeAction(source, "bir Morfin hapını yutar.")
			giveArmor(source, 30)
		elseif itemID == 36 then
			takeItemFromSlot(source, itemSlot)
			exports.mek_global:sendLocalMeAction(source, "bir Ecstasy hapını yutar.")
			giveArmor(source, 30)
		elseif itemID == 37 then
			takeItemFromSlot(source, itemSlot)
			exports.mek_global:sendLocalMeAction(source, "bir Heroin injekte eder.")
			giveArmor(source, 30)
		elseif itemID == 38 then
			local sucess, key, paperValue = hasItem(source, 181)
			local itemVal = {}
			local i = 0

			for token in string.gmatch(tostring(paperValue), "[^%s]+") do
				i = i + 1
				itemVal[i] = token
			end

			if tonumber(itemValue) <= 0 then
				outputChatBox("[!]#FFFFFF Bu marijuana bitmiş.", source, 255, 0, 0, true)
				return
			end

			if tonumber(itemVal[1]) > 0 then
				if sucess then
					if tonumber(paperValue) >= 1 then
						if hasSpaceForItem(source, 182, 1) then
							takeItemFromSlot(source, itemSlot)
							giveItem(source, 182, "Marijuana")
							takeItem(source, 181, paperValue)
							exports.mek_global:sendLocalMeAction(source, "bir esrar tomurcuğu alıp sigaraya sarar.")
							giveItem(source, 181, paperValue - 1)
						else
							outputChatBox("[!]#FFFFFF Envanteriniz dolu.", source, 255, 0, 0, true)
						end
					else
						outputChatBox("[!]#FFFFFF Sarma paketi boş.", source, 255, 0, 0, true)
					end
				else
					outputChatBox(
						"[!]#FFFFFF Bunu yapmak için bir sarma paketiniz olmalıdır.",
						source,
						255,
						0,
						0,
						true
					)
				end
			else
				outputChatBox("[!]#FFFFFF Sarma paketi boş.", source, 255, 0, 0, true)
			end
		elseif itemID == 39 then
			takeItemFromSlot(source, itemSlot)
			exports.mek_global:sendLocalMeAction(source, "biraz Methamphetamine koklar.")
			giveArmor(source, 60)
		elseif itemID == 40 then
			takeItemFromSlot(source, itemSlot)
			exports.mek_global:sendLocalMeAction(source, "bir Epinephrine kalemi injekte eder.")
			giveArmor(source, 30)
		elseif itemID == 41 then
			takeItemFromSlot(source, itemSlot)
			exports.mek_global:sendLocalMeAction(source, "ağzına bir damla LSD döker.")
			giveArmor(source, 40)
		elseif itemID == 42 then
			takeItemFromSlot(source, itemSlot)
			exports.mek_global:sendLocalMeAction(source, "bir kuru mantar yer.")
			giveArmor(source, 25)
		elseif itemID == 43 then
			takeItemFromSlot(source, itemSlot)
			exports.mek_global:sendLocalMeAction(source, "bir PCP hapı yutar.")
			giveArmor(source, 35)
		elseif itemID == 50 then
			local bookTitle = "The İstanbul Highway Code"
			local bookName = "SFHighwayCode"
			exports.mek_global:sendLocalMeAction(source, bookTitle .. " okur.")
			triggerClientEvent(source, "showBook", source, bookName, bookTitle)
		elseif itemID == 51 then
			local bookTitle = "Chemistry 101"
			local bookName = "Chemistry101"
			exports.mek_global:sendLocalMeAction(source, bookTitle .. " okur.")
			triggerClientEvent(source, "showBook", source, bookName, bookTitle)
		elseif itemID == 52 then
			local bookTitle = "The Police Officer's Manual"
			local bookName = "PDmanual"
			exports.mek_global:sendLocalMeAction(source, bookTitle .. " okur.")
			triggerClientEvent(source, "showBook", source, bookName, bookTitle)
		elseif itemID == 54 then
			local x, y, z = unpack(additional)
			triggerEvent("dropItem", source, itemSlot, x, y, z + 0.3)
			exports.mek_global:sendLocalMeAction(source, "ghettoblaster'ı yere yerleştirir.")
		elseif itemID == 55 then
			exports.mek_global:sendLocalMeAction(source, "looks at a piece of paper.")
			outputChatBox("The card reads: 'Steven Paralman - L.V. Freight Depot, Tel: 12555'", source, 255, 51, 102)
		elseif itemID == 58 then
			takeItemFromSlot(source, itemSlot)
			exports.mek_global:sendLocalMeAction(source, "biraz iyi Ziebrand birasını içer.")
			setElementHealth(source, getElementHealth(source) - 5)
		elseif itemID == 59 then
			takeItemFromSlot(source, itemSlot)
			exports.mek_global:sendLocalMeAction(source, "çamur yer.")
		elseif itemID == 60 then
			local dimension = getElementDimension(source)
			local interior = getElementInterior(source)
			local position = { getElementPosition(source) }
			local rotation = getElementRotation(source, "ZXY")

			if dimension == 0 then
				exports.mek_infobox:addBox(source, "error", "Bu kasa sadece mülke yerleştirilebilir.")
			elseif dimension >= 20000 then
				local vid = dimension - 20000
				if exports.mek_vehicle:getSafe(vid) then
					exports.mek_infobox:addBox(
						source,
						"error",
						"Bu mülkte zaten bir kasa var. Kasayı bulunduğunuz yere taşımak için /movesafe yazın."
					)
				elseif hasItem(source, 3, vid) then
					position[3] = position[3] - 0.5
					rotation = rotation + 180

					if exports.mek_vehicle:addSafe(vid, unpack(position), rotation, interior) then
						dbExec(
							exports.mek_mysql:getConnection(),
							"UPDATE vehicles SET safepositionX = ?, safepositionY = ?, safepositionZ = ?, safepositionRZ = ? WHERE id = ?",
							unpack(position),
							rotation,
							vid
						)
						exports.mek_infobox:addBox(source, "success", "Kasa başarıyla yerleştirildi.")
					end
				end
			elseif dimension >= 19000 then
				exports.mek_infobox:addBox(source, "error", "Geçici araç mülküne kasa yerleştiremezsiniz.")
			elseif hasItem(source, 5, dimension) or hasItem(source, 4, dimension) then
				if exports.mek_interior:getSafe(dimension) then
					exports.mek_infobox:addBox(
						source,
						"error",
						"Bu mülkte zaten bir kasa var. Kasayı bulunduğunuz yere taşımak için /movesafe yazın."
					)
				else
					if exports.mek_interior:addSafe(dimension, nil, position, interior, rotation, true, false) then
						exports.mek_infobox:addBox(source, "success", "Kasa başarıyla yerleştirildi.")
						takeItemFromSlot(source, itemSlot)
					end
				end
			end
		elseif itemID == 62 then
			takeItemFromSlot(source, itemSlot)
			exports.mek_global:sendLocalMeAction(source, "Bastradov vodka'yı içer.")
			setElementHealth(source, getElementHealth(source) - 10)
		elseif itemID == 63 then
			takeItemFromSlot(source, itemSlot)
			exports.mek_global:sendLocalMeAction(source, "Scottish Whiskey'yı içer.")
			setElementHealth(source, getElementHealth(source) - 10)
		elseif itemID == 72 then
			exports.mek_global:sendLocalMeAction(source, "notu okur.")
		elseif itemID == 76 then
			if shields[source] then
				destroyElement(shields[source])
				shields[source] = nil
			else
				local x, y, z = getElementPosition(source)
				local rotation = getPedRotation(source)

				x = x + math.sin(math.rad(rotation)) * 1.5
				y = y + math.cos(math.rad(rotation)) * 1.5

				local object = createObject(1631, x, y, z)
				attachElements(object, source, 0, 0.65, 0)
				shields[source] = object
			end
		elseif itemID == 77 then
			local cards = {
				"As",
				"İki",
				"Üç",
				"Dört",
				"Beş",
				"Altı",
				"Yedi",
				"Sekiz",
				"Dokuz",
				"On",
				"Vale",
				"Kız",
				"Papaz",
			}
			local sign = { "Maça", "Sinek", "Kupa", "Karo" }
			local number = math.random(1, #cards)
			local snumber = math.random(1, #sign)
			exports.mek_global:sendLocalText(
				source,
				"✪ "
					.. getPlayerName(source):gsub("_", " ")
					.. " bir kart çekti ve "
					.. cards[number]
					.. " "
					.. sign[snumber]
					.. " elde etti.",
				0,
				255,
				0
			)
		elseif itemID == 79 then
			setPedAnimation(source, "PAULNMAC", "wank_loop", -1, true, false, false)
		elseif itemID == 80 then
			showItem(removeOOC(itemName))
		elseif itemID == 83 then
			takeItemFromSlot(source, itemSlot)
			exports.mek_global:sendLocalMeAction(source, "elindeki kahveyi içmeye başlar.")
			giveHealth(source, 25)

			if getElementData(source, "thirst") <= 100 then
				if getElementData(source, "thirst") >= 75 then
					setElementData(source, "thirst", 100)
				else
					setElementData(source, "thirst", getElementData(source, "thirst") + 25)
				end
			end
		elseif itemID == 89 then
			takeItemFromSlot(source, itemSlot)
			exports.mek_global:sendLocalMeAction(source, "elindeki " .. itemName .. " yemeye başlar.")
			giveHealth(source, tonumber(getItemValue(itemID, itemValue)))

			if getElementData(source, "hunger") <= 100 then
				if getElementData(source, "hunger") >= 75 then
					setElementData(source, "hunger", 100)
				else
					setElementData(source, "hunger", getElementData(source, "hunger") + 17)
				end
			end
		elseif itemID == 91 then
			takeItemFromSlot(source, itemSlot)
			exports.mek_global:sendLocalMeAction(source, "elindeki eggnogu içmeye başlar.")
			giveHealth(source, 15)

			if getElementData(source, "thirst") <= 100 then
				if getElementData(source, "thirst") >= 75 then
					setElementData(source, "thirst", 100)
				else
					setElementData(source, "thirst", getElementData(source, "thirst") + 19)
				end
			end
		elseif itemID == 92 then
			takeItemFromSlot(source, itemSlot)
			exports.mek_global:sendLocalMeAction(source, "elindeki hindiyi yemeye başlar.")
			giveHealth(source, 25)

			if getElementData(source, "hunger") <= 100 then
				if getElementData(source, "hunger") >= 75 then
					setElementData(source, "hunger", 100)
				else
					setElementData(source, "hunger", getElementData(source, "hunger") + 17)
				end
			end
		elseif itemID == 93 then
			takeItemFromSlot(source, itemSlot)
			exports.mek_global:sendLocalMeAction(source, "elindeki yeni yıl pudingi yemeye başlar.")
			giveHealth(source, 20)

			if getElementData(source, "hunger") <= 100 then
				if getElementData(source, "hunger") >= 75 then
					setElementData(source, "hunger", 100)
				else
					setElementData(source, "hunger", getElementData(source, "hunger") + 20)
				end
			end
		elseif itemID == 95 then
			takeItemFromSlot(source, itemSlot)
			exports.mek_global:sendLocalMeAction(source, "elindeki " .. itemName .. " içmeye başlar.")
			giveHealth(source, tonumber(getItemValue(itemID, itemValue)))

			if getElementData(source, "thirst") <= 100 then
				if getElementData(source, "thirst") >= 75 then
					setElementData(source, "thirst", 100)
				else
					setElementData(source, "thirst", getElementData(source, "thirst") + 17)
				end
			end
		elseif itemID == 96 then
			exports.mek_global:sendLocalMeAction(
				source,
				"turns their " .. (itemValue == 1 and "PDA" or itemValue) .. " on."
			)
			triggerClientEvent(source, "useCompItem", source)
		elseif itemID == 97 then
			local bookTitle = "SFES Procedure Manual"
			local bookName = "SFESProcedureManual"
			exports.mek_global:sendLocalMeAction(source, bookTitle .. " okur.")
			triggerClientEvent(source, "showBook", source, bookName, bookTitle)
		elseif itemID == 99 then
			takeItemFromSlot(source, itemSlot)
		elseif itemID == 100 then
			giveHealth(source, 30)
			setPedAnimation(source, "VENDING", "VEND_Drink_P", 4000, false, true, true)
			toggleAllControls(source, true, true, true)
			exports.mek_global:sendLocalMeAction(source, "küçük süt kartonunu içmeye başlar.")
			takeItemFromSlot(source, itemSlot)
		elseif itemID == 101 then
			takeItemFromSlot(source, itemSlot)
		elseif itemID == 102 then
			takeItemFromSlot(source, itemSlot)
		elseif itemID == 104 then
			triggerEvent("useTV", source, source)
			local isTvUsed = getElementData(source, "isTvUsed")
			if isTvUsed == nil or isTvUsed == false then
				exports.mek_global:sendLocalMeAction(source, "küçük taşınabilir televizyonu açar.")
				setElementData(source, "isTvUsed", true, false)
			else
				setElementData(source, "isTvUsed", false, false)
			end
		elseif itemID == 105 then
			if itemValue > 0 then
				if hasSpaceForItem(source, 106, 1) then
					takeItemFromSlot(source, itemSlot)
					giveItem(source, itemID, itemValue - 1)
					giveItem(source, 106, 1)
					exports.mek_global:sendLocalMeAction(
						source,
						"sigara paketinin içine bakar ve bir tane çıkarır."
					)
				else
					outputChatBox("[!]#FFFFFF Envanteriniz dolu.", source, 255, 0, 0, true)
				end
			else
				exports.mek_global:sendLocalMeAction(source, "sigara paketinin içine bakar ve boş olduğunu görür.")
			end
		elseif itemID == 106 then
			if hasItem(source, 107) then
				exports.mek_global:sendLocalMeAction(source, "bir sigara yakar.")
				outputChatBox(
					"[!]#FFFFFF /sigaraat ile sigarayı atabilir, /sigaraeldegis ile el değiştirebilirsiniz, /sigarajointver ile jointi verebilirsin.",
					source,
					0,
					0,
					255,
					true
				)
				triggerEvent("realism.startSmoking", source, 1)
				setPedAnimation(source, "SMOKING", "M_smk_in", 6000, false, true, true)
				takeItemFromSlot(source, itemSlot)
			else
				exports.mek_global:sendLocalMeAction(source, "herkese bir sigara gösterir.")
				outputChatBox(
					"[!]#FFFFFF Sigarayı yakmak için bir çakmağa ihtiyacınız var.",
					source,
					255,
					0,
					0,
					true
				)
			end
		elseif itemID == 108 then
			takeItemFromSlot(source, itemSlot)
		elseif (itemID == 109) or (itemID == 110) then
			takeItemFromSlot(source, itemSlot)
		elseif itemID == 113 then
			if itemValue > 0 then
				if hasSpaceForItem(source, 28, 1) then
					glowStickColour = 1 + ((glowStickColour or 0) + 1) % 7
					takeItemFromSlot(source, itemSlot)
					giveItem(source, itemID, itemValue - 1)
					giveItem(source, 28, glowStickColour)
					exports.mek_global:sendLocalMeAction(
						source,
						"ışıklı çubuk paketinin içine bakar ve birini çıkarır."
					)
				else
					outputChatBox("[!]#FFFFFF Envanteriniz dolu.", source, 255, 0, 0, true)
				end
			else
				exports.mek_global:sendLocalMeAction(
					source,
					"ışıklı çubuk paketinin içine bakar ve boş olduğunu görür."
				)
			end
		elseif itemID == 114 then
			local vehicle = getPedOccupiedVehicle(source)
			local noUpgrades = { Boat = true, Helicopter = true, Plane = true, Train = true, BMX = true }

			if vehicle and not noUpgrades[getVehicleType(vehicle)] and getItemDescription(itemID, itemValue) ~= "?" then
				addUpgrade(source, vehicle, itemSlot, itemID, itemValue)
			else
				outputChatBox("Use this in a vehicle to add it as permanent upgrade.", source, 255, 194, 14)
			end
		elseif itemID == 130 then
			outputChatBox("Place this alarm system in a vehicle inventory to install it.", source, 0, 255, 0)
		elseif itemID == 132 then
			takeItemFromSlot(source, itemSlot)
			outputChatBox("You took your " .. itemValue .. " prescription.", source)
			exports.mek_global:sendLocalMeAction(source, "takes some prescription medicine.")
			setPedAnimation(source, "VENDING", "VEND_Drink_P", 4000, false, true, true)
		elseif itemID == 134 then
			outputChatBox("₺" .. exports.mek_global:formatMoney(itemValue) .. " of currency.", source)
		elseif itemID == 137 then
			triggerEvent("snakecam:toggleSnakeCam", root, source)
		elseif itemID == 138 then
			outputChatBox("Place this device in a vehicle inventory to install it.", source, 0, 255, 0)
		elseif itemID == 286 then
			takeItemFromSlot(source, itemSlot)
			exports.mek_global:sendLocalMeAction(source, "pizza dilimini yemeye başlar.")
			giveHealth(source, 25)

			if getElementData(source, "hunger") <= 100 then
				if getElementData(source, "hunger") >= 75 then
					setElementData(source, "hunger", 100)
				else
					setElementData(source, "hunger", getElementData(source, "hunger") + 25)
				end
			end
		elseif itemID == 306 then
			takeItemFromSlot(source, itemSlot)
		elseif badges[itemID] then
			toggleBadge(source, itemID, itemValue)
		elseif masks[itemID] then
			toggleMask(source, masks[itemID], itemID, itemName)
		elseif itemID == 151 then
			local px, py, pz = getElementPosition(source)

			for i, v in ipairs(getElementsByType("object")) do
				local x, y, z = getElementPosition(v)
				local distance = getDistanceBetweenPoints3D(px, py, pz, x, y, z)

				if
					distance < 30
					and getElementData(v, "dbid") == tonumber(itemValue)
					and not getElementData(v, "lift.moving")
				then
					local lift = getElementData(v, "lift")
					local lx, ly, lz = getElementPosition(lift)

					setElementData(v, "lift.moving", true)

					if not getElementData(v, "lift.up") then
						setElementData(v, "lift.up", true)
						moveObject(lift, 4000, lx, ly, lz + 2.33)
						dbExec(
							mysql:getConnection(),
							"UPDATE ramps SET state = 1 WHERE id = ?",
							getElementData(v, "dbid")
						)
					else
						setElementData(v, "lift.up", false)
						moveObject(lift, 4000, lx, ly, lz - 2.33)
						dbExec(
							mysql:getConnection(),
							"UPDATE ramps SET state = 0 WHERE id = ?",
							getElementData(v, "dbid")
						)
					end

					exports.mek_global:sendLocalMeAction(
						source,
						"sağ elini sağ cebine koyar, bir anahtar çıkarır ve düğmeye basar, rampanın hareket etmesini sağlar."
					)

					setTimer(setElementData, 4000, 1, v, "lift.moving", false)
				end
			end
		elseif itemID == 182 then
			if hasItem(source, 107) then
				exports.mek_global:sendLocalMeAction(source, "bir sarma sigara yakar.")
				outputChatBox(
					"[!]#FFFFFF /sigaraat ile sigarayı atabilir, /sigaraeldegis ile el değiştirebilirsiniz, /sigarajointver ile jointi verebilirsin.",
					source,
					0,
					0,
					255,
					true
				)
				triggerEvent("realism.startSmoking", source, 1)
				setPedAnimation(source, "SMOKING", "M_smk_in", 6000, false, true, true)
				takeItemFromSlot(source, itemSlot)
				giveArmor(source, 30)
			else
				exports.mek_global:sendLocalMeAction(source, "herkese bir sarma sigara gösterir.")
				outputChatBox(
					"[!]#FFFFFF Sarma sigarayı yakmak için bir çakmağa ihtiyacınız var.",
					source,
					255,
					0,
					0,
					true
				)
			end
		elseif itemID == 209 then
			triggerEvent("gunlicense:weaponlicenses", root, source)
		elseif itemID == 214 then
			exports.mek_global:sendLocalMeAction(source, "takes a " .. itemName .. ".")
			takeItemFromSlot(source, itemSlot)
		elseif itemID == 233 then
			triggerEvent("camera_showPhoto", source, itemValue)
		elseif itemID == 285 then
			if itemValue > 0 then
				if hasSpaceForItem(source, 286, 1) then
					takeItemFromSlot(source, itemSlot)
					giveItem(source, itemID, itemValue - 1)
					giveItem(source, 286, 1)
					exports.mek_global:sendLocalMeAction(source, "pizza kutusunu açar ve içinden bir dilim alır.")
				else
					outputChatBox("[!]#FFFFFF Envanterinizde boş alan yok.", source, 255, 0, 0, true)
				end
			else
				exports.mek_global:sendLocalDoAction(source, "pizza kutusu boş görünüyor.")
			end
		elseif itemID == 350 then
			local vehicle = getPedOccupiedVehicle(source)
			if not vehicle then
				outputChatBox("[!]#FFFFFF Tamir kitini kullanmak için bir aracın içinde olmalısınız.", source, 255, 0, 0, true)
				return
			end
			
			local vehicleHealth = getElementHealth(vehicle)
			if vehicleHealth >= 1000 then
				outputChatBox("[!]#FFFFFF Araç zaten tam sağlıklı durumda.", source, 255, 194, 14, true)
				return
			end
			
			local repairingVehicle = getElementData(source, "repairing_vehicle")
			if repairingVehicle then
				if not isElement(repairingVehicle) or getPedOccupiedVehicle(source) ~= repairingVehicle then
					setElementData(source, "repairing_vehicle", false)
				else
					outputChatBox("[!]#FFFFFF Zaten bir araç tamir ediyorsunuz.", source, 255, 0, 0, true)
					return
				end
			end
			
			takeItemFromSlot(source, itemSlot)
			setElementData(source, "repairing_vehicle", vehicle)
			
			local player = source
			local playerName = getPlayerName(player)
			
			if exports.mek_global and exports.mek_global.sendLocalMeAction then
				pcall(function() exports.mek_global:sendLocalMeAction(player, "elindeki tamir kitini kullanarak aracı tamir etmeye başlar.") end)
			end
			outputChatBox("[!]#FFFFFF Aracı tamir etmeye başladınız... 5 saniye sürecek.", player, 0, 255, 0, true)
			
			setTimer(function()
				if isElement(player) and isElement(vehicle) and getPedOccupiedVehicle(player) == vehicle then
					fixVehicle(vehicle)
					
					setElementData(vehicle, "engine_broke", false)
					
					setElementHealth(vehicle, 1000)
					
					if exports.mek_vehicle and exports.mek_vehicle.getArmoredCars then
						local armoredCars = exports.mek_vehicle:getArmoredCars()
						if armoredCars and armoredCars[getElementModel(vehicle)] then
							setVehicleDamageProof(vehicle, true)
						else
							setVehicleDamageProof(vehicle, false)
						end
					end
					
					for i = 0, 5 do
						setVehicleDoorState(vehicle, i, 0)
					end
					
					if exports.mek_global and exports.mek_global.sendLocalMeAction then
						pcall(function() exports.mek_global:sendLocalMeAction(player, "aracı başarıyla tamir etti.") end)
					end
					outputChatBox("[!]#FFFFFF Araç başarıyla tamir edildi!", player, 0, 255, 0, true)
					setElementData(player, "repairing_vehicle", false)
				else
					if isElement(player) then
						if exports.mek_global and exports.mek_global.sendLocalMeAction then
							pcall(function() exports.mek_global:sendLocalMeAction(player, "tamir işlemini yarıda bıraktı.") end)
						end
						outputChatBox("[!]#FFFFFF Tamir işlemi iptal edildi.", player, 255, 194, 14, true)
						setElementData(player, "repairing_vehicle", false)
					end
				end
			end, 5000, 1)
		end
	end
end
addEvent("useItem", true)
addEventHandler("useItem", root, useItem)

addEventHandler("onPlayerQuit", root, function()
	if getElementData(source, "repairing_vehicle") then
		setElementData(source, "repairing_vehicle", false)
	end
end)

-- Clean up repair data when player exits vehicle
addEventHandler("onPlayerVehicleExit", root, function(vehicle, seat)
	if getElementData(source, "repairing_vehicle") == vehicle then
		setElementData(source, "repairing_vehicle", false)
		outputChatBox("[!]#FFFFFF Tamir işlemi iptal edildi - araçtan çıktınız.", source, 255, 194, 14, true)
	end
end)

addCommandHandler("useitem", function(thePlayer, commandName, itemID, ...)
	if tonumber(itemID) then
		local args = { ... }
		local itemValue
		if #args > 0 then
			itemValue = table.concat(args, " ")
			itemValue = tonumber(itemValue) or itemValue
		end

		local has, slot = hasItem(thePlayer, tonumber(itemID), itemValue)
		if has then
			triggerEvent("useItem", thePlayer, slot)
		end
	end
end)

function isBadge(item)
	if badges[item] then
		return true
	end
	return false
end

function explodeFlash(obj)
	destroyElement(obj)

	for _, player in ipairs(exports.mek_global:getNearbyElements(obj, "player")) do
		local gasmask = getElementData(player, "gasmask")
		if not gasmask then
			fadeCamera(player, false, 0.5, 255, 255, 255)
			setTimer(cancelEffect, 5000, 1, player)
		end
	end
end

function cancelEffect(thePlayer)
	fadeCamera(thePlayer, true, 6.0)
end

function destroyGlowStick(marker)
	destroyElement(marker)
end

function destroyItem(itemID)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if isPedDead(source) then
		return
	end

	local itemName = ""
	if itemID and itemID > 0 then
		local itemSlot = itemID
		if itemID == 134 then
			return
		end

		local item = getItems(source)[itemSlot]
		if item then
			local itemID = item[1]
			local itemValue = item[2]

			if itemID == 48 and countItems(source, 48) == 1 then
				if getCarriedWeight(source) - getItemWeight(48, 1) > 10 then
					return
				end
			end

			if itemID == 126 and countItems(source, 126) == 1 then
				if getCarriedWeight(source) - getItemWeight(126, 1) > 10 then
					return
				end
			end

			itemName = getItemName(itemID, itemValue)
			takeItemFromSlot(source, itemSlot)

			doItemGiveawayChecks(source, itemID)
		else
			return
		end
	else
		if itemID == -100 then
			setPedArmor(source, 0)
			itemName = "Vücut Zırhı"
		else
			exports.mek_global:takeWeapon(source, tonumber(-itemID))
			itemName = getWeaponNameFromID(-itemID)
		end
	end

	if itemName and itemName ~= "" then
		exports.mek_global:sendLocalMeAction(source, "bir " .. itemName .. " siler.")
	end
end
addEvent("destroyItem", true)
addEventHandler("destroyItem", root, destroyItem)

function showItem(itemName)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if isPedDead(source) then
		return
	end

	exports.mek_global:sendLocalMeAction(source, "etrafındaki herkese bir " .. removeOOC(itemName) .. " gösterir.")
end
addEvent("showItem", true)
addEventHandler("showItem", root, showItem)

function showInventoryRemote(thePlayer, commandName, targetPlayer)
	if exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
		if not targetPlayer then
			outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID]", thePlayer, 255, 194, 14)
		else
			local targetPlayer = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
			if targetPlayer then
				triggerEvent("subscribeToInventoryChanges", thePlayer, targetPlayer)
				triggerClientEvent(thePlayer, "showInventory", thePlayer, targetPlayer)
			end
		end
	end
end
addCommandHandler("showinv", showInventoryRemote, false, false)

function toggleBadge(source, itemID, itemValue)
	if getElementData(source, "badge") then
		removeElementData(source, "badge")
	else
		local badge = {
			itemID = itemID,
			itemValue = itemValue,
			itemName = badges[itemID][1],
			factionIDs = badges[itemID][3],
			color = badges[itemID][4],
		}
		setElementData(source, "badge", badge)
	end
	exports.mek_global:updateNametagColor(source)
end

function toggleMask(source, maskData, itemID, itemName)
	local hasMask = getElementData(source, "mask")
	if hasMask then
		exports.mek_global:sendLocalMeAction(source, maskData[3]:gsub("#name", itemName) .. ".")
		removeElementData(source, "mask")
		triggerEvent("artifacts.remove", source, source, maskData[1])
	else
		if getElementData(source, "vip") > 0 then
			local customTexture = getItemTexture(itemID, itemValue)
			exports.mek_global:sendLocalMeAction(source, maskData[2]:gsub("#name", itemName) .. ".")
			setElementData(source, "mask", true)
			triggerEvent("artifacts.add", source, source, maskData[1], false, customTexture)
		else
			outputChatBox("[!]#FFFFFF Bunu takmak için VIP üyelik gerekmektedir.", source, 255, 0, 0, true)
		end
	end
	exports.mek_global:updateNametagColor(source)
end
