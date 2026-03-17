local pending = {}
local added = {}
local addedServerOnly = {}
local addedElement = {}
local isInitializing = false
local clientsWaitingOnInitial = {}

local debugMode = false

function getPath(url)
	return "cache/" .. md5(tostring(url)) .. ".tex"
end

addEventHandler("onResourceStart", resourceRoot, function()
	isInitializing = true

	for k, v in ipairs(exports.mek_pool:getPoolElementsByType("vehicle")) do
		local textures = getElementData(v, "textures")
		if textures then
			if type(textures) == "table" then
				for k2, v2 in ipairs(textures) do
					addTexture(v, v2[1], v2[2], true)
				end
			end
		end
	end

	outputDebugString("[ITEM-TEXTURE] " .. tostring(#clientsWaitingOnInitial) .. " istemci ilk senkronizasyonu bekliyor.")
	isInitializing = false
	if #clientsWaitingOnInitial > 0 then
		outputDebugString("[ITEM-TEXTURE] " .. tostring(#added) .. " dokuya sahip öğe ilk senkronizasyon için eklendi.")
		setTimer(triggerClientEvent, 2000, 1, clientsWaitingOnInitial, "item-texture.initialSync", resourceRoot, added)
	end
	clientsWaitingOnInitial = {}
end)

function loadFromURL(element, texName, url)
	local options = { 
		queueName = "vehicle_textures_q", 
		connectionAttempts = 3, 
		connectionTimeout = 10000 
	}
	
	fetchRemote(url, options, function(responseData, errorCode)
		local isSuccess = (responseData and responseData ~= "ERROR") and ( (type(errorCode) == "number" and errorCode == 0) or (type(errorCode) == "table" and (errorCode.success or errorCode.status == 200)) )
		
		if isSuccess then
			local path = getPath(url)
			local file = fileCreate(path)
			if file then
				fileWrite(file, responseData)
				fileClose(file)

				if pending[url] then
					triggerLatentClientEvent(
						pending[url],
						"item-texture.file",
						resourceRoot,
						element,
						texName,
						url,
						responseData,
						#responseData
					)
					pending[url] = nil
				end
			else
				outputDebugString("[ITEM-TEXTURE] Dosya oluşturulamadı (loadFromURL): " .. tostring(path))
			end
		else
			outputDebugString("[ITEM-TEXTURE] URL'den yükleme başarısız (loadFromURL): " .. tostring(url) .. " (Hata #" .. tostring(type(errorCode) == "table" and errorCode.status or errorCode) .. ")")
			pending[url] = nil
		end
	end)
end

local lastRequests = {}

addEvent("item-texture.stream", true)
addEventHandler("item-texture.stream", resourceRoot, function(element, texName, url)
	local now = getTickCount()
	if lastRequests[client] and (now - lastRequests[client]) < 500 then
		return false
	end
	lastRequests[client] = now

	local path = getPath(url)
	if fileExists(path) then
		local file = fileOpen(path, true)
		if file then
			local size = fileGetSize(file)
			local content = fileRead(file, size)
			if #content == size then
				triggerLatentClientEvent(client, "item-texture.file", resourceRoot, element, texName, url, content, size)
			end
			fileClose(file)
		end
	else
		if pending[url] then
			table.insert(pending[url], client)
		else
			pending[url] = { client }
			loadFromURL(element, texName, url)
		end
	end
end, false)

addEventHandler("onElementDataChange", root, function(name, oldValue)
	if name == "textures" and client then
		local textures = getElementData(source, "textures")
		--outputDebugString("[ITEM-TEXTURE] Hile Denemesi?: " .. getPlayerName(client) .. " element verisini manipüle etmeye çalıştı.", 2)
		setElementData(source, "textures", oldValue)
		exports.mek_sac:banForEventAbuse(client, "ElementData Manipulation (textures)")
	end
end)

function addTexture(element, texName, url)
	local textures = getElementData(element, "textures") or {}
	table.insert(textures, {texName, url})
	setElementData(element, "textures", textures)
	return true
end

function removeTexture(element, texName)
	local textures = getElementData(element, "textures") or {}
	if not texName then
		setElementData(element, "textures", nil)
		return true
	end
	
	for k, v in ipairs(textures) do
		if v[1] == texName then
			table.remove(textures, k)
			setElementData(element, "textures", textures)
			return true
		end
	end
	return false
end
