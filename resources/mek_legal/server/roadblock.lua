local roadblocksarr = {}
local maxroadblocks = 50
local roadblockNames = {}

addEventHandler("onResourceStart", resourceRoot, function()
	for _, value in ipairs(roadblocks) do
		if not roadblockNames[value[2]] then
			roadblockNames[value[2]] = value[1]
		end
	end
end)

function roadblockCreateWorldObject(objectid, tempObjectPosX, tempObjectPosY, tempObjectPosZ, tempObjectPosRot)
	if isRoadblockEditAllowed(client) then
		local slot = 0
		for i = 1, maxroadblocks do
			if roadblocksarr[i] == nil then
				roadblocksarr[i] =
					createObject(objectid, tempObjectPosX, tempObjectPosY, tempObjectPosZ, 0, 0, tempObjectPosRot)
				setElementData(roadblocksarr[i], "roadblock", "1")
				setElementInterior(roadblocksarr[i], getElementInterior(client))
				setElementDimension(roadblocksarr[i], getElementDimension(client))
				slot = i

				if objectid == 1593 then
					local shape = createColCuboid(tempObjectPosX, tempObjectPosY, tempObjectPosZ, 2.0, 2.0, 2.5)
					exports.mek_pool:allocateElement(shape)
					setElementData(shape, "type", "spikes")
					setElementData(roadblocksarr[i], "spike:shape1", shape)
				end

				break
			end
		end
		if not (slot == 0) then
			outputChatBox(
				"[!]#FFFFFF Oluşturdun! #" .. slot .. " kodunda bir yol engeli kurdun.",
				client,
				0,
				255,
				0,
				true
			)
		else
			outputChatBox(
				"[!]#FFFFFF Çok fazla engel koydun! Bazılarını kaldır ve tekrar dene!",
				client,
				0,
				255,
				0,
				true
			)
		end
	end
end
addEvent("roadblockCreateWorldObject", true)
addEventHandler("roadblockCreateWorldObject", root, roadblockCreateWorldObject)

function getNearbyRoadblocks(thePlayer, commandName)
	if isRoadblockEditAllowed(thePlayer) then
		local posX, posY, posZ = getElementPosition(thePlayer)
		outputChatBox("Yakındaki Engeller:", thePlayer, 255, 126, 0)
		local found = false

		for i = 1, maxroadblocks do
			if not (roadblocksarr[i] == nil) then
				local x, y, z = getElementPosition(roadblocksarr[i])
				local distance = getDistanceBetweenPoints3D(posX, posY, posZ, x, y, z)
				if distance <= 10 then
					local name
					local model = tonumber(getElementModel(roadblocksarr[i]))
					for k, v in ipairs(roadblocks) do
						for k2, v2 in ipairs(v) do
							if v2[2] == model then
								name = v2[1]
								break
							end
						end
					end
					if not name then
						name = "Roadblock"
					end
					outputChatBox(i .. ": " .. tostring(name) .. ".", thePlayer, 255, 126, 0)
					found = true
				end
			end
		end
		if not found then
			outputChatBox("Etrafında hiç yok!", thePlayer, 255, 126, 0)
		else
			outputChatBox("Use /delrb [id] to delete.", thePlayer, 255, 126, 0)
		end
	end
end
addCommandHandler("nearbyrb", getNearbyRoadblocks, false, false)
addCommandHandler("nearbyrbs", getNearbyRoadblocks, false, false)

function removeRoadblock(thePlayer, commandName, id)
	if isRoadblockEditAllowed(thePlayer) then
		if not id then
			outputChatBox("Kullanım: /" .. commandName .. " [Roadblock ID]", thePlayer, 255, 194, 15)
		else
			id = tonumber(id)
			if roadblocksarr[id] == nil then
				outputChatBox("[!]#FFFFFF Yol engeli bulunamadı.", thePlayer, 255, 0, 0, true)
			else
				local object = roadblocksarr[id]

				local getPossibleShape = getElementData(object, "spike:shape1")
				if getPossibleShape then
					destroyElement(getPossibleShape)
				end

				local getPossibleShape2 = getElementData(object, "spike:shape2")
				if getPossibleShape2 then
					destroyElement(getPossibleShape2)
				end

				destroyElement(object)
				roadblocksarr[id] = nil
				outputChatBox("[!]#FFFFFF Sildiğin yol engeli ID #" .. id .. ".", thePlayer, 0, 255, 0, true)
			end
		end
	end
end
addCommandHandler("delrb", removeRoadblock, false, false)
addCommandHandler("delroadblock", removeRoadblock, false, false)

function removeAllRoadblocks(thePlayer, commandName)
	if exports.mek_integration:isPlayerAdmin3(thePlayer) then
		for i = 1, maxroadblocks do
			if not (roadblocksarr[i] == nil) then
				local object = roadblocksarr[i]

				local getPossibleShape = getElementData(object, "spike:shape1")
				if getPossibleShape then
					destroyElement(getPossibleShape)
				end

				local getPossibleShape2 = getElementData(object, "spike:shape2")
				if getPossibleShape2 then
					destroyElement(getPossibleShape2)
				end

				destroyElement(object)
			end
		end
		roadblocksarr = {}
		outputChatBox("[!]#FFFFFF Tüm yol engelleri silindi.", thePlayer, 0, 255, 0, true)
	end
end
addCommandHandler("delallrbs", removeAllRoadblocks, false, false)
addCommandHandler("delallroadblocks", removeAllRoadblocks, false, false)

function onRoadblockStart(thePlayer, commandName, parameter)
	if isRoadblockEditAllowed(thePlayer) then
		triggerClientEvent(thePlayer, "enableRoadblockGUI", root, true)
	end
end
addCommandHandler("rbs", onRoadblockStart, false, false)

function isRoadblockEditAllowed(thePlayer)
	if exports.mek_faction:isPlayerInFaction(thePlayer, { 1, 2, 3, 4 }) then
		return true
	end
	return false
end
