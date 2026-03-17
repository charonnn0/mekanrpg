local badges = getBadges()
local masks = getMasks()

local fixInventoryTimer = {}

function givePlayerBadge(thePlayer, commandName, targetPlayer, ...)
	local badgeNumber = table.concat({ ... }, " ")
	badgeNumber = #badgeNumber > 0 and badgeNumber

	local teamID = exports.mek_faction:getCurrentFactionDuty(thePlayer) or -1
	if teamID < 0 then
		outputChatBox(
			"[!]#FFFFFF Rozetleri verebilmek için bir birlik görevinde olmanız gerekir.",
			thePlayer,
			255,
			0,
			0,
			true
		)
		return
	end

	local badge = nil
	local itemID = nil
	local prefix = ""

	for k, v in pairs(badges) do
		for ka, va in pairs(v[3]) do
			if ka == teamID then
				badge = v
				itemID = k
				prefix = type(va) == "string" and (va .. " ") or ""
			end
		end
	end

	if not badge then
		return
	end

	if not exports.mek_faction:hasMemberPermissionTo(thePlayer, teamID, "set_member_duty") then
		outputChatBox("[!]#FFFFFF Rozet vermek için bir birlik lideri olmanız gerekiyor.", thePlayer, 255, 0, 0, true)
	else
		if not targetPlayer or not badgeNumber then
			outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID] [Rozet]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
			if targetPlayer then
				local logged = getElementData(targetPlayer, "logged")
				if not logged then
					outputChatBox(
						"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
						thePlayer,
						255,
						0,
						0,
						true
					)
				else
					local x, y, z = getElementPosition(thePlayer)
					local tx, ty, tz = getElementPosition(targetPlayer)
					if getDistanceBetweenPoints3D(x, y, z, tx, ty, tz) > 4 then
						outputChatBox(
							"[!]#FFFFFF Bu oyuncuya rozet verebilmek için çok uzaktasınız.",
							thePlayer,
							255,
							0,
							0,
							true
						)
					else
						exports.mek_item:giveItem(targetPlayer, itemID, prefix .. badgeNumber)
						exports.mek_global:sendLocalMeAction(
							thePlayer,
							targetPlayerName
								.. " şahısa "
								.. badge[2]
								.. "verir ve üzerinde '"
								.. badgeNumber
								.. "' yazılı olduğunu söyler."
						)
					end
				end
			end
		end
	end
end
addCommandHandler("issuebadge", givePlayerBadge, false, false)

function fixInventory(thePlayer, commandName)
	if not isTimer(fixInventoryTimer[thePlayer]) then
		if (not getElementData(thePlayer, "dead")) and (not getElementData(thePlayer, "admin_jailed")) then
			triggerEvent("updateLocalGuns", thePlayer)
			outputChatBox("[!]#FFFFFF Envanter başarıyla düzeltildi.", thePlayer, 0, 255, 0, true)
			triggerClientEvent(thePlayer, "playSuccess", thePlayer)
			fixInventoryTimer[thePlayer] = setTimer(function() end, 1000 * 10, 1)
		else
			outputChatBox("[!]#FFFFFF Bu durumda iken bu komutu kullanamazsınız.", thePlayer, 255, 0, 0, true)
		end
	else
		local timer = getTimerDetails(fixInventoryTimer[thePlayer])
		outputChatBox(
			"[!]#FFFFFF Envanterinizi düzeltmek için " .. math.floor(timer / 1000) .. " saniye beklemeniz gerekiyor.",
			thePlayer,
			255,
			0,
			0,
			true
		)
	end
end
addCommandHandler("fixinventory", fixInventory, false, false)
addCommandHandler("fixinv", fixInventory, false, false)

function writeNote(thePlayer, commandName, ...)
	local tick = getTickCount()
	if not (...) then
		outputChatBox("Kullanım: /" .. commandName .. " [Yazı]", thePlayer, 255, 194, 14)
	elseif not hasSpaceForItem(thePlayer, 72, table.concat({ ... }, " ")) then
		outputChatBox("[!]#FFFFFF Daha fazla not yazamazsınız.", thePlayer, 255, 0, 0, true)
	elseif
		getElementData(thePlayer, "note_timeout")
		and math.abs(getElementData(thePlayer, "note_timeout") - tick) < 5000
	then
		outputChatBox("[!]#FFFFFF Bir sonraki işlem için 5 saniye beklemeniz gerek.", thePlayer, 255, 0, 0, true)
	else
		giveItem(thePlayer, 72, table.concat({ ... }, " "))
		exports.mek_global:sendLocalMeAction(
			thePlayer,
			"sağ cebinden bir not kağıdı çıkartır ve birşeyler yazar."
		)
		setElementData(thePlayer, "note_timeout", tick)
	end
end
addCommandHandler("writenote", writeNote, false, false)
addCommandHandler("notyaz", writeNote, false, false)

function saveTextureURL(slot, url)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	updateItemValue(source, slot, url)
	outputChatBox("[!]#FFFFFF Doku URL'si kaydedildi.", source, 0, 255, 0, true)
end
addEvent("items:saveTextureURL", true)
addEventHandler("items:saveTextureURL", root, saveTextureURL)

function saveTextureReplacement(slot, url, texture)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if texture then
		updateItemValue(source, slot, tostring(url) .. ";" .. tostring(texture))
	else
		updateItemValue(source, slot, tostring(url))
	end

	outputChatBox("[!]#FFFFFF Yedek doku kaydedildi.", source, 0, 255, 0, true)
end
addEvent("items:saveTextureReplacement", true)
addEventHandler("items:saveTextureReplacement", root, saveTextureReplacement)

addEvent("items.searchPlayer", true)
addEventHandler("items.searchPlayer", root, function(player)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	triggerEvent("subscribeToInventoryChanges", source, player)
	triggerClientEvent(source, "showInventory", source, player)
end)

-- Test command for repair kit (for development/testing purposes)
addCommandHandler("giverepairkit", function(thePlayer)
	if exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
		local success = giveItem(thePlayer, 350, 1)
		if success then
			outputChatBox("[!]#FFFFFF Tamir Kiti verildi.", thePlayer, 0, 255, 0, true)
		else
			outputChatBox("[!]#FFFFFF Envanter dolu veya hata oluştu.", thePlayer, 255, 0, 0, true)
		end
	else
		outputChatBox("[!]#FFFFFF Bu komutu kullanmak için admin yetkisi gerekir.", thePlayer, 255, 0, 0, true)
	end
end)
