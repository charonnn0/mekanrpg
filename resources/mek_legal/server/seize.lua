local function parseWeaponData(itemData)
	local parts = split(itemData, ":")
	return {
		id = tonumber(parts[1]),
		serial = parts[2],
		model = parts[3],
		ammo = tonumber(parts[4]),
		rights = tonumber(parts[5]) or 3,
	}
end

function takeWeapon(targetPlayer, weaponSerial)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not targetPlayer or not isElement(targetPlayer) then
		outputChatBox("[!]#FFFFFF Karşı kişi bulunamadı.", client, 255, 0, 0, true)
		return
	end

	local foundWeapon = false
	for _, item in ipairs(exports.mek_item:getItems(targetPlayer)) do
		local itemData = item[2]
		local weaponDetails = parseWeaponData(itemData)

		if weaponDetails.serial == weaponSerial then
			foundWeapon = true

			exports.mek_item:takeItem(targetPlayer, item[1], itemData)

			local weaponName = exports.mek_item:getItemName(item[1], itemData)
			local adminName = getPlayerName(client):gsub("_", " ")
			local targetName = getPlayerName(targetPlayer):gsub("_", " ")

			if weaponDetails.rights > 1 then
				local newWeaponRights = weaponDetails.rights - 1
				local updatedItemData = string.format(
					"%d:%s:%s:%d:%d",
					weaponDetails.id,
					weaponDetails.serial,
					weaponDetails.model,
					weaponDetails.ammo,
					newWeaponRights
				)
				exports.mek_item:giveItem(targetPlayer, item[1], updatedItemData)

				local logMessage = string.format(
					"[ELKOY] %s, %s adlı kişinin %s silahından 1 hak aldı. Kalan hak: %d",
					adminName,
					targetName,
					weaponName,
					newWeaponRights
				)

				exports.mek_global:sendMessageToAdmins(logMessage)
				exports.mek_logs:addLog("elkoy", logMessage)

				outputChatBox(
					"[!]#FFFFFF "
						.. targetName
						.. " isimli kişinin "
						.. weaponName
						.. " silahına el koydunuz. Kalan hak: "
						.. newWeaponRights,
					client,
					0,
					255,
					0,
					true
				)

				outputChatBox(
					"[!]#FFFFFF "
						.. adminName
						.. " isimli kişi "
						.. weaponName
						.. " silahınıza el koydu. Kalan hak: "
						.. newWeaponRights,
					targetPlayer,
					255,
					0,
					0,
					true
				)
			else
				local logMessage = string.format(
					"[ELKOY] %s, %s adlı kişinin %s silahının son hakkını aldı. (Silah silindi)",
					adminName,
					targetName,
					weaponName
				)

				exports.mek_global:sendMessageToAdmins(logMessage)
				exports.mek_logs:addLog("elkoy", logMessage)

				outputChatBox(
					"[!]#FFFFFF "
						.. targetName
						.. " isimli kişinin "
						.. weaponName
						.. " silahına el koydunuz ve silah silindi.",
					client,
					0,
					255,
					0,
					true
				)

				outputChatBox(
					"[!]#FFFFFF "
						.. adminName
						.. " isimli kişi "
						.. weaponName
						.. " silahınıza el koydu ve silah silindi.",
					targetPlayer,
					255,
					0,
					0,
					true
				)
			end
			break
		end
	end

	if not foundWeapon then
		outputChatBox("[!]#FFFFFF Belirtilen seriye sahip silah bulunamadı.", client, 255, 0, 0, true)
	end
end
addEvent("legal.seize.takeWeapon", true)
addEventHandler("legal.seize.takeWeapon", root, takeWeapon)

function seizeCommand(thePlayer, commandName, targetPlayer)
    local adminLevel = getElementData(thePlayer, "admin_level") or 0
    
    if adminLevel < 6 and not exports.mek_faction:isPlayerInFaction(thePlayer, { 1, 3 }) then
        outputChatBox("[!]#FFFFFF Yalnızca legal birlikler veya yetkili adminler bu komutu kullanabilir.", thePlayer, 255, 0, 0, true)
        return
    end

    if not targetPlayer then
        outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID]", thePlayer, 255, 194, 14)
        return
    end

    local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
    if not targetPlayer then
        return
    end

    if adminLevel < 6 and getDistanceBetweenPoints3D(thePlayer.position, targetPlayer.position) > 10 then
        outputChatBox(
            "[!]#FFFFFF " .. targetPlayerName .. " isimli kişiye yeterince yakın değilsiniz.",
            thePlayer,
            255,
            0,
            0,
            true
        )
        return
    end

    triggerClientEvent(thePlayer, "legal.seize.ui", thePlayer, targetPlayer, exports.mek_item:getItems(targetPlayer))
end
addCommandHandler("elkoy", seizeCommand, false, false)
