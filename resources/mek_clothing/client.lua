local loaded = {}
local streaming = {}

local players = {}

local accessoires = {
	watchcro = true,
	neckcross = true,
	earing = true,
	glasses = true,
	specsm = true,
}

local function getPrimaryTextureName(model)
	local textureNames = engineGetModelTextureNames(model)
	if not textureNames then return nil end
	
	local priorityNames = { "torso", "body", "skin", "cj_ped_torso", "remap_body" }
	for _, name in ipairs(priorityNames) do
		for _, tex in ipairs(textureNames) do
			if tex == name then return tex end
		end
	end

	for _, name in ipairs(textureNames) do
		local lowerName = string.lower(name)
		if not accessoires[name] and not string.find(lowerName, "teeth") and not string.find(lowerName, "eyes") and not string.find(lowerName, "mouth") and not string.find(lowerName, "spec") then
			return name
		end
	end
	
	return textureNames[1]
end

local function getPath(clothing)
	return "@cl_" .. tostring(clothing) .. ".tex"
end

function clearCache()
	for i = 1, math.huge do
		local filePath = getPath(i)
		if fileExists(filePath) then
			fileDelete(filePath)
			return
		end
		break
	end
end

function addClothing(player, clothing)
	removeClothing(player)

	local texName = getPrimaryTextureName(getElementModel(player))

	local loadedRef = loaded[clothing]
	if loadedRef then
		players[player] = {
			id = clothing,
			texName = texName,
		}
		engineApplyShaderToWorldTexture(loadedRef.shader, texName, player)
	else
		local path = getPath(clothing)
		if fileExists(path) then
			local texture = dxCreateTexture(path)
			if texture then
				local shader, tech = dxCreateShader("public/shaders/tex.fx", 0, 0, true, "ped")
				if shader then
					dxSetShaderValue(shader, "tex", texture)

					local texName = getPrimaryTextureName(getElementModel(player))
					engineApplyShaderToWorldTexture(shader, texName, player)

					loaded[clothing] = {
						texture = texture,
						shader = shader,
					}
					players[player] = {
						id = clothing,
						texName = texName,
					}
				else
					outputDebugString("Failed to create shader for clothing " .. tostring(clothing), 1)
					destroyElement(texture)
				end
			else
				outputDebugString("Failed to create texture for clothing " .. tostring(clothing), 1)
			end
		else
			if streaming[clothing] then
				table.insert(streaming[clothing], player)
			else
				streaming[clothing] = { player }
				outputDebugString("Requesting download for clothing " .. tostring(clothing), 3)
				triggerServerEvent("clothing.stream", resourceRoot, clothing)
			end

			players[player] = {
				id = clothing,
				texName = texName,
				pending = true,
			}
		end
	end
end

function removeClothing(player)
	local clothes = players[player]
	if clothes and loaded[clothes.id] and isElement(loaded[clothes.id].shader) then
		local stillUsed = false
		for p, data in pairs(players) do
			if p ~= player and data.id == clothes.id then
				stillUsed = true
				break
			end
		end

		if stillUsed then
			if not clothes.pending then
				engineRemoveShaderFromWorldTexture(loaded[clothes.id].shader, clothes.texName, player)
			end
		else
			local loadedRef = loaded[clothes.id]
			if loadedRef then
				destroyElement(loadedRef.texture)
				destroyElement(loadedRef.shader)

				loaded[clothes.id] = nil
			end
		end
		players[player] = nil
	end
end

addEvent("clothing.file", true)
addEventHandler("clothing.file", resourceRoot, function(id, content, size)
	local file = fileCreate(getPath(id))
	if not file then
		outputDebugString("Failed to create file for clothing " .. tostring(id), 1)
		return
	end
	local written = fileWrite(file, content)
	fileClose(file)

	if written ~= size then
		fileDelete(getPath(id))
	else
		for _, player in ipairs(streaming[id]) do
			addClothing(player, id)
		end

		streaming[id] = nil
	end
end, false)

addEventHandler("onClientResourceStart", resourceRoot, function()
	clearCache()
	for _, name in ipairs({ "player", "ped" }) do
		for _, player in ipairs(getElementsByType(name)) do
			if isElementStreamedIn(player) then
				local clothing = getElementData(player, "clothing_id")
				if clothing then
					addClothing(player, clothing)
				end
			end
		end
	end
end)

addEventHandler("onClientElementStreamIn", root, function()
	if getElementType(source) == "player" or getElementType(source) == "ped" then
		local clothing = getElementData(source, "clothing_id")
		if clothing then
			addClothing(source, clothing)
		end
	end
end)

addEventHandler("onClientElementStreamOut", root, function()
	if getElementType(source) == "player" or getElementType(source) == "ped" then
		removeClothing(source)
	end
end)

addEventHandler("onClientPlayerQuit", root, function()
	removeClothing(source)
end)

addEventHandler("onClientElementDestroy", root, function()
	if getElementType(source) == "ped" then
		removeClothing(source)
	end
end)

addEventHandler("onClientElementModelChange", root, function(oldModel, newModel)
	if getElementType(source) == "player" or getElementType(source) == "ped" then
		if isElementStreamedIn(source) then
			local clothing = getElementData(source, "clothing_id")
			if clothing then
				removeClothing(source)
				addClothing(source, clothing)
			end
		end
	end
end)

addEventHandler("onClientElementDataChange", root, function(name)
	if
		(getElementType(source) == "player" or getElementType(source) == "ped")
		and isElementStreamedIn(source)
		and name == "clothing_id"
	then
		removeClothing(source)
		if getElementData(source, "clothing_id") then
			addClothing(source, getElementData(source, "clothing_id"))
		end
	end
end)
