local activePlayerLines = {}
local lineModeState = {}

function getNextAvailableLineID(playerElement)
	if not activePlayerLines[playerElement] then
		activePlayerLines[playerElement] = {}
	end
	local id = 1
	while activePlayerLines[playerElement][id] do
		id = id + 1
		if id > 100000 then
			return nil
		end
	end
	return id
end

function broadcastLineData()
	triggerClientEvent(root, "legal.loadAllLines", root, activePlayerLines)
end

function receiveLineDataFromClient(lineID, lineSegments)
	if not isElement(source) or getElementType(source) ~= "player" then
		return
	end

	if not activePlayerLines[source] then
		activePlayerLines[source] = {}
	end

	activePlayerLines[source][lineID] = lineSegments
	broadcastLineData()
end
addEvent("legal.sendLineDataToServer", true)
addEventHandler("legal.sendLineDataToServer", root, receiveLineDataFromClient)

function toggleLineDrawingMode(playerElement)
	if not exports.mek_faction:isPlayerInFaction(playerElement, { 1, 3 }) then
		outputChatBox(
			"[!]#FFFFFF Bu işlemi yalnızca legal birlik üyeleri yapabilir.",
			playerElement,
			255,
			0,
			0,
			true
		)
		return
	end

	if lineModeState[playerElement] then
		local currentLineID = lineModeState[playerElement]
		triggerClientEvent(playerElement, "legal.toggleLineModeClient", playerElement, false, currentLineID)
		outputChatBox("[!]#FFFFFF Başarıyla şerit ekledin. ID: " .. currentLineID, playerElement, 0, 255, 0, true)
		outputChatBox("[!]#FFFFFF Silmek için /seritsil [ID]", playerElement, 0, 0, 255, true)
		lineModeState[playerElement] = false
	else
		local newLineID = getNextAvailableLineID(playerElement)
		if not newLineID then
			outputChatBox(
				"[!]#FFFFFF Yeni şerit ID'si oluşturulurken bir hata oluştu. Lütfen tekrar deneyin.",
				playerElement,
				255,
				0,
				0,
				true
			)
			return
		end
		outputChatBox(
			"[!]#FFFFFF Şerit çekme modu açıldı. Bitirmek için tekrardan /serit yaz.",
			playerElement,
			0,
			255,
			0,
			true
		)
		lineModeState[playerElement] = newLineID
		triggerClientEvent(playerElement, "legal.toggleLineModeClient", playerElement, true, newLineID)
	end
end
addCommandHandler("serit", toggleLineDrawingMode, false, false)

function deleteLine(playerElement, command, lineIDString)
	if not exports.mek_faction:isPlayerInFaction(playerElement, { 1, 3 }) then
		outputChatBox(
			"[!]#FFFFFF Bu işlemi yalnızca legal birlik üyeleri yapabilir.",
			playerElement,
			255,
			0,
			0,
			true
		)
		return
	end

	local lineIDToDelete = tonumber(lineIDString)
	if not lineIDToDelete or lineIDToDelete < 1 then
		outputChatBox("[!]#FFFFFF Geçersiz şerit ID'si. Örn: /seritsil 1", playerElement, 255, 0, 0, true)
		return
	end

	if activePlayerLines[playerElement] and activePlayerLines[playerElement][lineIDToDelete] then
		activePlayerLines[playerElement][lineIDToDelete] = nil
		outputChatBox(
			"[!]#FFFFFF Şerit ID " .. lineIDToDelete .. " başarıyla silindi.",
			playerElement,
			255,
			0,
			0,
			true
		)
		broadcastLineData()
	else
		outputChatBox(
			"[!]#FFFFFF Belirtilen ID'ye sahip bir şerit bulunamadı veya size ait değil.",
			playerElement,
			255,
			0,
			0,
			true
		)
	end
end
addCommandHandler("seritsil", deleteLine, false, false)

function onPlayerQuitHandler(quitType)
	if activePlayerLines[source] then
		activePlayerLines[source] = nil
	end
	if lineModeState[source] then
		lineModeState[source] = nil
	end
	broadcastLineData()
end
addEventHandler("onPlayerQuit", root, onPlayerQuitHandler)

function onPlayerJoinHandler()
	broadcastLineData()
end
addEventHandler("onPlayerJoin", root, onPlayerJoinHandler)

function table.contains(tbl, val)
	for _, value in pairs(tbl) do
		if value == val then
			return true
		end
	end
	return false
end
