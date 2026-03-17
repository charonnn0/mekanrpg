local tacklers = {}

local function performTackle(thePlayer, targetPlayer)
    if not isElement(thePlayer) or not isElement(targetPlayer) then return false end
    
	local px, py, pz = getElementPosition(thePlayer)
	local tx, ty, tz = getElementPosition(targetPlayer)
	local distance = getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz)

	if distance > 3 then
		outputChatBox(
			"[!]#FFFFFF " .. getPlayerName(targetPlayer):gsub("_", " ") .. " isimli kişiye yeterince yakın değilsiniz.",
			thePlayer,
			255,
			0,
			0,
			true
		)
		return false
	end

	if not getElementData(targetPlayer, "proned") then
		detachElements(targetPlayer)
		toggleAllControls(targetPlayer, false, true, false)
		setElementFrozen(targetPlayer, true)
		setElementData(targetPlayer, "frozen", true)
		setPedWeaponSlot(targetPlayer, 0)
		setElementData(targetPlayer, "proned", true)
		setPedAnimation(targetPlayer, "CRACK", "crckidle2", -1, false, false, false)
		exports.mek_global:sendLocalMeAction(thePlayer, getPlayerName(targetPlayer):gsub("_", " ") .. " adlı şahısın üstüne doğru atlar.")
        return true
	else
		outputChatBox("[!]#FFFFFF " .. getPlayerName(targetPlayer):gsub("_", " ") .. " isimli kişi zaten yerde.", thePlayer, 255, 0, 0, true)
        return false
	end
end

function putPlayerOnGroundCommand(thePlayer, commandName, targetPlayer)
	if not exports.mek_faction:isPlayerInFaction(thePlayer, { 1, 3 }) then
		outputChatBox("[!]#FFFFFF Bu işlemi yalnızca legal birlik üyeleri yapabilir.", thePlayer, 255, 0, 0, true)
		return
	end

	if not targetPlayer then
        if tacklers[thePlayer] then
            tacklers[thePlayer] = nil
            outputChatBox("[!]#FFFFFF Yere yatırma modu kapatıldı.", thePlayer, 255, 194, 14, true)
        else
            tacklers[thePlayer] = true
            outputChatBox("[!]#FFFFFF Yere yatırma modu açıldı. Yumruk attığınız kişi yere yatırılacak. /" .. commandName .. " yazarak kapatabilirsiniz.", thePlayer, 255, 194, 14, true)
        end
		return
	end

	local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
	if not targetPlayer then
		return
	end

	if targetPlayer == thePlayer then
		outputChatBox("[!]#FFFFFF Kendini yere yatıramazsın.", thePlayer, 255, 0, 0, true)
		return
	end

    if performTackle(thePlayer, targetPlayer) then
        tacklers[thePlayer] = nil
    end
end
addCommandHandler("yereyatir", putPlayerOnGroundCommand, false, false)

addEventHandler("onPlayerDamage", root, function(attacker, weapon, bodypart, loss)
    if attacker and getElementType(attacker) == "player" and tacklers[attacker] then
        if weapon == 0 then 
            if source == attacker then return end
            
            if not exports.mek_faction:isPlayerInFaction(attacker, { 1, 3 }) then
                tacklers[attacker] = nil
                return
            end

            if performTackle(attacker, source) then
                tacklers[attacker] = nil
                outputChatBox("[!]#FFFFFF Yere yatırma işlemi başarılı, mod kapatıldı.", attacker, 0, 255, 0, true)
            end
        end
    end
end)

function liftPlayerFromGroundCommand(thePlayer, commandName, targetPlayer)
	if not exports.mek_faction:isPlayerInFaction(thePlayer, { 1, 3 }) then
		outputChatBox("[!]#FFFFFF Bu işlemi yalnızca legal birlik üyeleri yapabilir.", thePlayer, 255, 0, 0, true)
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

	if targetPlayer == thePlayer then
		outputChatBox("[!]#FFFFFF Kendini yerden kaldıramazsın.", thePlayer, 255, 0, 0, true)
		return
	end

	local px, py, pz = getElementPosition(thePlayer)
	local tx, ty, tz = getElementPosition(targetPlayer)
	local distance = getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz)

	if distance > 3 then
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

	if getElementData(targetPlayer, "proned") then
		removeElementData(targetPlayer, "proned")
		setPedAnimation(targetPlayer, false)
		setElementFrozen(targetPlayer, false)
		removeElementData(targetPlayer, "frozen")
		exports.mek_global:sendLocalMeAction(thePlayer, targetPlayerName .. " adlı şahısı yerden kaldırır.")
	else
		outputChatBox("[!]#FFFFFF " .. targetPlayerName .. " isimli kişi yerde değil.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("yerdenkaldir", liftPlayerFromGroundCommand, false, false)

addEventHandler("onPlayerQuit", root, function()
    if tacklers[source] then
        tacklers[source] = nil
    end
end)