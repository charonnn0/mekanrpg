local DRAG_REQUEST_TIMEOUT = 15000

local activeDragRequests = {}
local activeDrags = {}

function canPlayerDrag(thePlayer, targetPlayer, ignorePerks)
	if getElementData(thePlayer, "dead") then
		return false, "Baygın olduğunuz için kimseyi sürükleyemezsiniz."
	end
	if isPedInVehicle(thePlayer) then
		return false, "Araçta olduğunuz için kimseyi sürükleyemezsiniz."
	end
	if getElementData(thePlayer, "restrained") then
		return false, "Bağlı olduğunuz için kimseyi sürükleyemezsiniz."
	end
	if getElementData(thePlayer, "dragged_player") then
		return false, "Aynı anda birden fazla kişiyi sürükleyemezsiniz!"
	end
	if activeDrags[thePlayer] then
		return false, "Şu anda sürüklenmekteyken başka birini sürükleyemezsiniz!"
	end

	if targetPlayer then
		if targetPlayer == thePlayer then
			return false, "Kendini sürükleyemezsin."
		end
		if getElementData(targetPlayer, "is_dragged") then
			return false, (getPlayerName(targetPlayer):gsub("_", " ")) .. " isimli kişi zaten sürükleniyor."
		end

		local px, py, pz = getElementPosition(thePlayer)
		local tx, ty, tz = getElementPosition(targetPlayer)
		if getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz) > 10 then
			return false, (getPlayerName(targetPlayer):gsub("_", " ")) .. " isimli kişiye yeterince yakın değilsiniz."
		end
	end

	if not ignorePerks then
		local hasPerks = exports.mek_faction:isPlayerInFaction(thePlayer, { 1, 2, 3, 4 })
			or exports.mek_integration:isPlayerManager(thePlayer, true)
		return hasPerks
	end

	return true
end

function syncDraggedElement(player, draggedPlayer)
	if not player or not draggedPlayer or not isElement(player) or not isElement(draggedPlayer) then
		return
	end

	local interior = getElementInterior(player)
	local dimension = getElementDimension(player)
	local x, y, z = getElementPosition(player)

	setElementInterior(draggedPlayer, interior)
	setElementDimension(draggedPlayer, dimension)
	setElementPosition(draggedPlayer, x, y, z)

	if isElementAttached(draggedPlayer) then
		detachElements(draggedPlayer)
	end
	attachElements(draggedPlayer, player, 0, 1, 0)
end

function initiateDrag(thePlayer, targetPlayer)
	if isElementAttached(targetPlayer) then
		detachElements(targetPlayer)
	end

	attachElements(targetPlayer, thePlayer, 0, 1, 0)

	setElementData(thePlayer, "dragged_player", targetPlayer)
	setElementData(targetPlayer, "is_dragged", true)

	activeDrags[targetPlayer] = thePlayer

	setElementFrozen(targetPlayer, false)

	exports.mek_global:sendLocalMeAction(
		thePlayer,
		"sağ ve sol elleriyle şahsın gövdesinden tutarak çekiştirir.",
		false,
		true
	)

	local targetName = getPlayerName(targetPlayer):gsub("_", " ")
	local playerName = getPlayerName(thePlayer):gsub("_", " ")

	outputChatBox("[!]#FFFFFF " .. targetName .. " isimli kişiyi sürüklemektesiniz. Sürüklemeyi bırakmak için /suruklemeyibirak", thePlayer, 0, 255, 0, true)
	outputChatBox("[!]#FFFFFF " .. playerName .. " isimli kişi sizi sürüklemekte.", targetPlayer, 0, 255, 0, true)
end

function stopDrag(initiator, draggedPlayer, draggerPlayer)
	if not isElement(draggedPlayer) or not isElement(draggerPlayer) then
		return
	end

	if activeDrags[draggedPlayer] == draggerPlayer or getElementData(draggerPlayer, "dragged_player") == draggedPlayer then
		detachElements(draggedPlayer)
		removePedFromVehicle(draggedPlayer)

		removeElementData(draggerPlayer, "dragged_player")
		removeElementData(draggedPlayer, "is_dragged")

		activeDrags[draggedPlayer] = nil

		if getElementData(draggedPlayer, "frozen") then
			setElementFrozen(draggedPlayer, true)
		end

		local draggedName = getPlayerName(draggedPlayer):gsub("_", " ")
		local draggerName = getPlayerName(draggerPlayer):gsub("_", " ")

		if initiator == draggerPlayer then
			exports.mek_global:sendLocalMeAction(draggerPlayer, "sağ ve sol ellerini şahsın gövdesinden çeker.", false, true)
			outputChatBox("[!]#FFFFFF " .. draggedName .. " isimli kişiyi sürüklemeyi bıraktınız.", draggerPlayer, 0, 255, 0, true)
			outputChatBox("[!]#FFFFFF " .. draggerName .. " isimli kişi sizi sürüklemeyi bıraktı.", draggedPlayer, 0, 255, 0, true)
		else
			outputChatBox("[!]#FFFFFF " .. draggedName .. " isimli kişi sizi sürüklemeyi bıraktı.", draggerPlayer, 255, 0, 0, true)
			outputChatBox("[!]#FFFFFF " .. draggerName .. " isimli kişi sizi sürüklemeyi bıraktı.", draggedPlayer, 255, 0, 0, true)
		end
	end
end

addCommandHandler("surukle", function(thePlayer, commandName, targetID)
	if not targetID then
		outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID]", thePlayer, 255, 194, 14)
		return
	end

	local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetID)
	if not targetPlayer then
		return
	end

	local allowed, reason = canPlayerDrag(thePlayer, targetPlayer, false)
	if not allowed then
		if reason then
			outputChatBox("[!]#FFFFFF " .. reason, thePlayer, 255, 0, 0, true)
		end
		return
	end

	local hasPerks = exports.mek_faction:isPlayerInFaction(thePlayer, { 1, 2, 3, 4 })
		or exports.mek_integration:isPlayerManager(thePlayer, true)

	if hasPerks then
		initiateDrag(thePlayer, targetPlayer)
	else
		if activeDragRequests[targetPlayer] then
			outputChatBox("[!]#FFFFFF " .. targetPlayerName .. " isimli kişiye zaten bir sürükleme isteği gönderilmiş.", thePlayer, 255, 0, 0, true)
			return
		end

		outputChatBox("[!]#FFFFFF " .. targetPlayerName .. " isimli kişiye sürükleme isteği gönderildi. Cevap bekleniyor...", thePlayer, 0, 255, 0, true)
		outputChatBox("[!]#FFFFFF " .. getPlayerName(thePlayer):gsub("_", " ") .. " isimli kişi sizi sürüklemek istiyor. Kabul etmek için /suruklekabul, reddetmek için /suruklereddet yazın.", targetPlayer, 0, 0, 255, true)

		activeDragRequests[targetPlayer] = thePlayer
		local timer = setTimer(function(requester, requestedPlayer)
			if activeDragRequests[requestedPlayer] == requester then
				outputChatBox("[!]#FFFFFF Sürükleme isteği zaman aşımına uğradı.", requester, 255, 0, 0, true)
				outputChatBox("[!]#FFFFFF Sürükleme isteği zaman aşımına uğradı.", requestedPlayer, 255, 0, 0, true)
				activeDragRequests[requestedPlayer] = nil
				removeElementData(requestedPlayer, "drag_request_timer_" .. getElementID(requester))
			end
		end, DRAG_REQUEST_TIMEOUT, 1, thePlayer, targetPlayer)

		setElementData(targetPlayer, "drag_request_timer_" .. getElementID(thePlayer), timer)
	end
end, false, false)

addEvent("legal.drag", true)
addEventHandler("legal.drag", root, function(targetPlayer)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	local allowed, reason = canPlayerDrag(source, targetPlayer, false)
	if not allowed then
		return
	end

	initiateDrag(source, targetPlayer)
end)

addCommandHandler("suruklekabul", function(thePlayer)
	local requester = activeDragRequests[thePlayer]
	if not requester or not isElement(requester) then
		outputChatBox("[!]#FFFFFF Kabul edebileceğin aktif bir sürükleme isteği bulunmamakta.", thePlayer, 255, 0, 0, true)
		return
	end

	local allowed, reason = canPlayerDrag(requester, thePlayer, true)
	if not allowed then
		outputChatBox("[!]#FFFFFF İstek gönderen şu anda sürükleme yapamaz durumda (" .. (reason or "Bilinmiyor") .. "), istek iptal edildi.", thePlayer, 255, 0, 0, true)
		outputChatBox("[!]#FFFFFF " .. getPlayerName(thePlayer):gsub("_", " ") .. " isimli kişinin sürükleme isteği geçersiz hale geldiği için iptal edildi.", requester, 255, 0, 0, true)
		activeDragRequests[thePlayer] = nil
		removeElementData(thePlayer, "drag_request_timer_" .. getElementID(requester))
		return
	end

	outputChatBox("[!]#FFFFFF Sürükleme isteğini kabul ettiniz.", thePlayer, 0, 255, 0, true)
	outputChatBox("[!]#FFFFFF " .. getPlayerName(thePlayer):gsub("_", " ") .. " isimli kişi sürükleme isteğinizi kabul etti.", requester, 0, 255, 0, true)

	initiateDrag(requester, thePlayer)
	activeDragRequests[thePlayer] = nil

	local timer = getElementData(thePlayer, "drag_request_timer_" .. getElementID(requester))
	if isTimer(timer) then
		killTimer(timer)
	end
	removeElementData(thePlayer, "drag_request_timer_" .. getElementID(requester))
end, false, false)

addCommandHandler("suruklereddet", function(thePlayer)
	local requester = activeDragRequests[thePlayer]
	if requester and isElement(requester) then
		outputChatBox("[!]#FFFFFF Sürükleme isteğini reddettiniz.", thePlayer, 255, 0, 0, true)
		outputChatBox("[!]#FFFFFF " .. getPlayerName(thePlayer):gsub("_", " ") .. " isimli kişi sürükleme isteğinizi reddetti.", requester, 255, 0, 0, true)
		activeDragRequests[thePlayer] = nil
		local timer = getElementData(thePlayer, "drag_request_timer_" .. getElementID(requester))
		if isTimer(timer) then
			killTimer(timer)
		end
		removeElementData(thePlayer, "drag_request_timer_" .. getElementID(requester))
	else
		outputChatBox("[!]#FFFFFF Reddedebileceğin aktif bir sürükleme isteği bulunmamakta.", thePlayer, 255, 0, 0, true)
	end
end, false, false)

addCommandHandler("suruklemeyibirak", function(thePlayer)
	local draggedPlayer = getElementData(thePlayer, "dragged_player")
	if draggedPlayer and isElement(draggedPlayer) then
		stopDrag(thePlayer, draggedPlayer, thePlayer)
	else
		outputChatBox("[!]#FFFFFF Şu anda hiçkimseyi sürüklememektesiniz.", thePlayer, 255, 0, 0, true)
	end
end, false, false)

addEvent("legal.stopDrag", true)
addEventHandler("legal.stopDrag", root, function(targetPlayer)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if getElementData(source, "dragged_player") == targetPlayer then
		stopDrag(source, targetPlayer, source)
	end
end)

local function handleSync(player)
	local draggedPlayer = getElementData(player, "dragged_player")
	if draggedPlayer and isElement(draggedPlayer) then
		setTimer(syncDraggedElement, 300, 1, player, draggedPlayer)
	end
end
addEventHandler("onElementInteriorChange", root, function()
	if getElementType(source) == "player" then
		handleSync(source)
	end
end)
addEventHandler("onElementDimensionChange", root, function()
	if getElementType(source) == "player" then
		handleSync(source)
	end
end)

local function handlePlayerExit(player, isWasted)
	local draggedPlayer = getElementData(player, "dragged_player")
	if draggedPlayer and isElement(draggedPlayer) then
		stopDrag(player, draggedPlayer, player)
		local reason = isWasted and "bayıldı" or "sunucudan ayrıldı"
		outputChatBox("[!]#FFFFFF Sizi sürükleyen kişi " .. reason .. ", sürükleme durduruldu.", draggedPlayer, 255, 0, 0, true)
	end

	local draggerPlayer = activeDrags[player]
	if draggerPlayer and isElement(draggerPlayer) then
		stopDrag(player, player, draggerPlayer)
		local reason = isWasted and "bayıldı" or "sunucudan ayrıldı"
		outputChatBox("[!]#FFFFFF " .. getPlayerName(player):gsub("_", " ") .. " isimli kişi " .. reason .. ", sürükleme durduruldu.", draggerPlayer, 255, 0, 0, true)
	end

	for requested, requester in pairs(activeDragRequests) do
		if requested == player or requester == player then
			local notificationTarget = (requested == player) and requester or requested
			if isElement(notificationTarget) then
				local role = (requested == player) and "İstek yapılan kişi" or "İstek gönderen"
				local reason = isWasted and "bayıldı" or "sunucudan ayrıldı"
				outputChatBox("[!]#FFFFFF Sürükleme isteği iptal edildi: " .. role .. " (" .. getPlayerName(player):gsub("_", " ") .. ") " .. reason .. ".", notificationTarget, 255, 0, 0, true)
			end
			activeDragRequests[requested] = nil
			removeElementData(requested, "drag_request_timer_" .. getElementID(requester))
		end
	end
end

addEventHandler("onPlayerQuit", root, function()
	handlePlayerExit(source, false)
end)

addEventHandler("onPlayerWasted", root, function()
	handlePlayerExit(source, true)
end)

addEventHandler("onResourceStop", resourceRoot, function()
	for draggedP, draggerP in pairs(activeDrags) do
		if isElement(draggerP) and isElement(draggedP) then
			stopDrag(draggerP, draggedP, draggerP)
		end
	end
	activeDrags = {}

	for requestedPlayer, requester in pairs(activeDragRequests) do
		local timer = getElementData(requestedPlayer, "drag_request_timer_" .. getElementID(requester))
		if isTimer(timer) then
			killTimer(timer)
		end
		if isElement(requestedPlayer) then
			removeElementData(requestedPlayer, "drag_request_timer_" .. getElementID(requester))
		end
	end
	activeDragRequests = {}
end)