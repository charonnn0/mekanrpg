function splitItem(player, cmd, itemID, amount)
	local itemID = tonumber(itemID)
	local amount = tonumber(amount)

	if not itemID or not amount then
		outputChatBox("Kullanım: /" .. cmd .. " [Eşya ID] [Miktar]", player, 255, 194, 14)
		outputChatBox("[!]#FFFFFF Bölünebilir öğelerin listesi için '/splits' yazın.", player, 0, 0, 255, true)
		return false
	end

	if (itemID % 1 ~= 0) or (amount % 1 ~= 0) then
		outputChatBox("[!]#FFFFFF Eşya ID ve Miktar tam sayı olmalıdır.", player, 255, 0, 0, true)
		return false
	end

	if itemID <= 0 or not splittableItems[itemID] then
		outputChatBox("[!]#FFFFFF ID '" .. tostring(itemID) .. "' ayrılabilir bir item değil.", player, 255, 0, 0, true)
		return false
	end

	local isPlayerHasItem, itemSlot, itemValue, itemIndex = exports.mek_item:hasItem(player, itemID)
	if not isPlayerHasItem then
		outputChatBox("[!]#FFFFFF Envanterinizde böyle bir item yok.", player, 255, 0, 0, true)
		return false
	end

	local originalValue = tostring(itemValue)
	local prefix = ""
	local itemValue2 = nil
	
	if itemID == 116 then
		local parts = split(originalValue, ":")
		if parts and parts[1] and parts[2] then
			prefix = parts[1] .. ":"
			itemValue2 = tonumber(parts[2])
		else
			outputChatBox("[!]#FFFFFF Mermi formatı geçersiz.", player, 255, 0, 0, true)
			return false
		end
	else
		itemValue2 = tonumber((originalValue:match("%d+")))
	end
	
	if not itemValue2 then
		outputChatBox("[!]#FFFFFF Bir sorun oluştu (geçersiz değer).", player, 255, 0, 0, true)
		return false
	end

	if amount <= 0 then
		outputChatBox("[!]#FFFFFF Tutar sıfırın üzerinde olmalıdır.", player, 255, 0, 0, true)
		return false
	end

	if amount > itemValue2 then
		outputChatBox("[!]#FFFFFF Tutar, envanterinizde bulunandan daha yüksek olamaz.", player, 255, 0, 0, true)
		return false
	end

	if amount == itemValue2 then
		outputChatBox("[!]#FFFFFF Tüm miktarı ayıramazsınız.", player, 255, 0, 0, true)
		return false
	end

	local itemRemaining = itemValue2 - amount
	
	local newValue1 = prefix .. tostring(amount)
	local newValue2 = prefix .. tostring(itemRemaining)

	local takeSuccess = exports.mek_item:takeItemFromSlot(player, itemSlot)
	if not takeSuccess then
		outputChatBox("[!]#FFFFFF Eşya alınamadı.", player, 255, 0, 0, true)
		return false
	end

	local giveSuccess1 = giveItem(player, itemID, newValue1, false, false)
	local giveSuccess2 = giveItem(player, itemID, newValue2, false, false)

	if giveSuccess1 and giveSuccess2 then
		outputChatBox("[!]#FFFFFF Eşya başarıyla " .. amount .. " ve " .. itemRemaining .. " olarak ayrıldı.", player, 0, 255, 0, true)
		return true
	else
		giveItem(player, itemID, originalValue, false, false)
		outputChatBox("[!]#FFFFFF Bir sorun oluştu, eşya geri yüklendi.", player, 255, 0, 0, true)
		return false
	end
end
addEvent("splitItem", true)
addEventHandler("splitItem", root, splitItem)
addCommandHandler("split", splitItem, false, false)

function listSplittable(thePlayer, commandName)
	outputChatBox("[!]#FFFFFF Ayrılabilir itemler:", thePlayer, 0, 0, 255, true)
	for itemID = 1, 150 do
		local itemName = false
		itemName = getItemName(itemID)
		if itemName and splittableItems[itemID] then
			outputChatBox(">>#FFFFFF ID " .. tostring(itemID) .. " - " .. itemName .. ".", thePlayer, 0, 255, 0, true)
		end
	end
end
addCommandHandler("splits", listSplittable, false, false)
