local rbWindow, rbList, bUse, bClose, tempObject, tempObjectID, tempObjectRot = nil
local tempObjectPosX, tempObjectPosY, tempObjectPosZ, tempObjectPosRot, tempObjectZfix = nil

local roadblockID = {
	"978",
	"981",
	"3578",
	"1228",
	"1282",
	"1422",
	"1424",
	"1425",
	"1459",
	"3091",
	"1593",
	"1238",
	"1237",
}
local roadblockTypes = {
	"Küçük engel",
	"Büyük engel",
	"Sarı çit",
	"Küçük uyarı çiti",
	"Küçük ışıklı uyarı çiti",
	"Çirkin uyarı çiti",
	"Yürüyüş engeli",
	"Burdan girme ->",
	"Uyarı Çiti",
	"Araçlar bu taraftan ->",
	"Küçük dikenli şerit",
	"Trafik konisi",
	"Kutup",
	"İp",
}
local roadblockRot = { "180", "0", "0", "90", "90", "0", "0", "0", "0", "0", "90", "0", "0" }
local roadblockZ = { "0", "0", "0", "0", "0", "0", "0", "0", "0", "0", "-0.4", "-0.18", "-0.45" }

function enableRoadblockGUI(parameter)
	if not rbWindow then
		local width, height = 300, 400
		local scrWidth, scrHeight = guiGetScreenSize()

		local x = scrWidth * 0.8 - (width / 2)
		local y = scrHeight * 0.75 - (height / 2)

		rbWindow = guiCreateWindow(x, y, width, height, "Yol Engel Oluşturucu", false)
		rbList = guiCreateGridList(0.05, 0.05, 0.9, 0.85, true, rbWindow)
		addEventHandler("onClientGUIDoubleClick", rbList, selectRoadblockGUI, false)
		local column = guiGridListAddColumn(rbList, "ID", 0.2)
		local column2 = guiGridListAddColumn(rbList, "Tip", 0.5)
		local column3 = guiGridListAddColumn(rbList, "Rot", 0.1)
		local column4 = guiGridListAddColumn(rbList, "Z", 0.1)

		local allowedObjects = {}
		local alreadyAdded = {}

		if exports.mek_faction:isPlayerInFaction(localPlayer, { 1, 2, 3, 4 }) then
			for _, value in ipairs(roadblocks) do
				if not alreadyAdded[value[2]] then
					table.insert(allowedObjects, value)
					alreadyAdded[value[2]] = true
				end
			end
		end

		for _, value in ipairs(allowedObjects) do
			local newRow = guiGridListAddRow(rbList)
			guiGridListSetItemText(rbList, newRow, column, value[2], true, false)
			guiGridListSetItemText(rbList, newRow, column2, value[1], false, false)
			guiGridListSetItemText(rbList, newRow, column3, value[3], false, false)
			guiGridListSetItemText(rbList, newRow, column4, value[4], false, false)
		end

		bUse = guiCreateButton(0.05, 0.90, 0.45, 0.1, "Kullan", true, rbWindow)
		addEventHandler("onClientGUIClick", bUse, selectRoadblockGUI, false)

		bClose = guiCreateButton(0.5, 0.90, 0.45, 0.1, "Kapat", true, rbWindow)
		addEventHandler("onClientGUIClick", bClose, cancelRoadblockGUI, false)

		outputChatBox(
			"[!]#FFFFFF Merhaba, eğerki bu listeden birini seçtiysen, [SPACE]'e basarak yerleştirebilirsin.",
			0,
			255,
			0,
			true
		)

		if not isCursorShowing() then
			showCursor(true)
		end
	else
		cleanupRoadblockGUI()
	end
end

function cleanupRoadblockGUI()
	cleanupRoadblock()
	destroyElement(rbWindow)
	rbWindow = nil
	if isCursorShowing() then
		showCursor(false)
	end
end

function cleanupRoadblock()
	if isElement(tempObject) then
		destroyElement(tempObject)
		tempObjectPosX, tempObjectPosY, tempObjectPosZ, tempObjectPosRot = nil
		tempObjectID, tempObjectRot = nil
		unbindKey("space", "down", convertTempToRealObject)
	end
	removeEventHandler("onClientPreRender", root, updateRoadblockObject)
end

function selectRoadblockGUI(button, state)
	if (source == bUse) and (button == "left") or (source == rbList) and (button == "left") then
		local row, col = guiGridListGetSelectedItem(rbList)

		if (row == -1) or (col == -1) then
			outputChatBox("[!]#FFFFFF Lütfen önce bir tür seçin.", 255, 0, 0, true)
		else
			if isElement(tempObject) then
				destroyElement(tempObject)
			end

			local objectid = tonumber(guiGridListGetItemText(rbList, guiGridListGetSelectedItem(rbList), 1))
			local objectrot = tonumber(guiGridListGetItemText(rbList, guiGridListGetSelectedItem(rbList), 3))
			local objectz = tonumber(guiGridListGetItemText(rbList, guiGridListGetSelectedItem(rbList), 4))
			spawnTempObject(objectid, objectrot, objectz)
			if isCursorShowing() then
				showCursor(false)
			end
		end
	end
end

function spawnTempObject(objectid, objectrot, objectz)
	tempObjectID = objectid
	tempObjectRot = objectrot
	tempObjectZfix = objectz
	tempObject = createObject(objectid, 0, 0, 0, 0, 0, 0)
	setElementAlpha(tempObject, 150)
	setElementInterior(tempObject, getElementInterior(localPlayer))
	setElementDimension(tempObject, getElementDimension(localPlayer))

	bindKey("space", "down", convertTempToRealObject)
	updateRoadblockObject()
	addEventHandler("onClientPreRender", root, updateRoadblockObject)
end

function convertTempToRealObject(key, keyState)
	if isElement(tempObject) then
		triggerServerEvent(
			"roadblockCreateWorldObject",
			localPlayer,
			tempObjectID,
			tempObjectPosX,
			tempObjectPosY,
			tempObjectPosZ,
			tempObjectPosRot
		)
		cleanupRoadblock()
		if not isCursorShowing() then
			showCursor(true)
		end
	end
end

function updateRoadblockObject(key, keyState)
	if isElement(tempObject) then
		local distance = 6
		local px, py, pz = getElementPosition(localPlayer)
		local rz = getPedRotation(localPlayer)

		local x = distance * math.cos((rz + 90) * math.pi / 180)
		local y = distance * math.sin((rz + 90) * math.pi / 180)
		local b2 = 15 / math.cos(math.pi / 180)
		local nx = px + x
		local ny = py + y
		local nz = pz - 0.5

		local objrot = rz + tempObjectRot
		if objrot > 360 then
			objrot = objrot - 360
		end

		nz = nz + tempObjectZfix

		setElementRotation(tempObject, 0, 0, objrot)
		moveObject(tempObject, 10, nx, ny, nz)

		tempObjectPosX = nx
		tempObjectPosY = ny
		tempObjectPosZ = nz
		tempObjectPosRot = objrot
	end
end

function cancelRoadblockGUI(button, state)
	if (source == bClose) and (button == "left") then
		cleanupRoadblockGUI()
	end
end

addEvent("enableRoadblockGUI", true)
addEventHandler("enableRoadblockGUI", root, enableRoadblockGUI)
