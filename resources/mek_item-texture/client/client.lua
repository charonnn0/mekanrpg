local loaded = {}
local streaming = {}

function getPath(url)
	return "cache/" .. md5(tostring(url)) .. ".tex"
end

function applyTexture(element, texName, url)
	if not isElement(element) then return end
	if not isElementStreamedIn(element) then return end

	local path = getPath(url)
	if fileExists(path) then
		if not loaded[element] then loaded[element] = {} end
		
		if loaded[element][texName] then
			engineRemoveShaderFromWorldTexture(loaded[element][texName].shader, texName, element)
			if isElement(loaded[element][texName].texture) then destroyElement(loaded[element][texName].texture) end
			if isElement(loaded[element][texName].shader) then destroyElement(loaded[element][texName].shader) end
			loaded[element][texName] = nil
		end

		local texture = dxCreateTexture(path, "argb", true, "clamp", "2d", 1)
		if texture then
			local shader, tech = dxCreateShader("public/shaders/replacement.fx", 0, 0, true, "world,object,vehicle")
			if shader then
				dxSetShaderValue(shader, "Tex0", texture)
				engineApplyShaderToWorldTexture(shader, texName, element)
				loaded[element][texName] = { shader = shader, texture = texture, url = url }
			else
				destroyElement(texture)
			end
		end
	else
		if not streaming[url] then
			streaming[url] = { {element, texName} }
			triggerServerEvent("item-texture.stream", resourceRoot, element, texName, url)
		else
			table.insert(streaming[url], {element, texName})
		end
	end
end

function removeTexture(element, texName)
	if loaded[element] then
		if texName then
			if loaded[element][texName] then
				engineRemoveShaderFromWorldTexture(loaded[element][texName].shader, texName, element)
				if isElement(loaded[element][texName].texture) then destroyElement(loaded[element][texName].texture) end
				if isElement(loaded[element][texName].shader) then destroyElement(loaded[element][texName].shader) end
				loaded[element][texName] = nil
			end
		else
			for name, data in pairs(loaded[element]) do
				engineRemoveShaderFromWorldTexture(data.shader, name, element)
				if isElement(data.texture) then destroyElement(data.texture) end
				if isElement(data.shader) then destroyElement(data.shader) end
			end
			loaded[element] = nil
		end
	end
end

addEvent("item-texture.file", true)
addEventHandler("item-texture.file", resourceRoot, function(element, texName, url, content, size)
	local path = getPath(url)
	local file = fileCreate(path)
	if file then
		fileWrite(file, content)
		fileClose(file)
		
		if streaming[url] then
			for _, data in ipairs(streaming[url]) do
				applyTexture(data[1], data[2], url)
			end
			streaming[url] = nil
		else
			applyTexture(element, texName, url)
		end
	end
end)

addEventHandler("onClientElementDataChange", root, function(name)
	if name == "textures" then
		local textures = getElementData(source, "textures")
		removeTexture(source) -- Öncekileri temizle
		if textures and type(textures) == "table" then
			for _, v in ipairs(textures) do
				applyTexture(source, v[1], v[2])
			end
		end
	end
end)

addEventHandler("onClientElementStreamIn", root, function()
	local textures = getElementData(source, "textures")
	if textures and type(textures) == "table" then
		for _, v in ipairs(textures) do
			applyTexture(source, v[1], v[2])
		end
	end
end)

addEventHandler("onClientElementStreamOut", root, function()
	removeTexture(source)
end)

addEventHandler("onClientElementDestroy", root, function()
	removeTexture(source)
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
	for _, element in ipairs(getElementsByType("vehicle")) do
		if isElementStreamedIn(element) then
			local textures = getElementData(element, "textures")
			if textures and type(textures) == "table" then
				for _, v in ipairs(textures) do
					applyTexture(element, v[1], v[2])
				end
			end
		end
	end
	for _, element in ipairs(getElementsByType("object")) do
		if isElementStreamedIn(element) then
			local textures = getElementData(element, "textures")
			if textures and type(textures) == "table" then
				for _, v in ipairs(textures) do
					applyTexture(element, v[1], v[2])
				end
			end
		end
	end
end)
