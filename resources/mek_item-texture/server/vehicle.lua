local maxFileSize = 2000000
local maxFileSizeTxt = "2000kb"

function addVehicleTexture(theVehicle, texName, texURL)
	if client and source and client ~= source and source ~= resourceRoot then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return false
	end

	local thePlayer = source
	if not theVehicle or not texName or not texURL then return false end
	if not getElementType(theVehicle) == "vehicle" then return false end

	if exports.mek_integration:isPlayerServerManager(thePlayer) then
		local textures = getElementData(theVehicle, "textures") or {}
		table.insert(textures, { texName, texURL })
		local vehID = tonumber(getElementData(theVehicle, "dbid")) or 0
		if vehID > 0 then
			dbExec(exports.mek_mysql:getConnection(), "UPDATE vehicles SET textures = ? WHERE id = ?", toJSON(textures), vehID)
		end
		setElementData(theVehicle, "textures", textures, true) -- Bu tetikleme client.lua'yı çalıştıracak
	end
end
addEvent("item-texture.addTexture", true)
addEventHandler("item-texture.addTexture", root, addVehicleTexture)

function removeVehicleTexture(theVehicle, texName)
	if client and source and client ~= source and source ~= resourceRoot then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return false
	end

	local thePlayer = source
	if not theVehicle or not texName then return false end
	if not getElementType(theVehicle) == "vehicle" then return false end

	if exports.mek_integration:isPlayerServerManager(thePlayer) then
		local textures = getElementData(theVehicle, "textures") or {}
		for k, v in ipairs(textures) do
			if v[1] == texName then
				table.remove(textures, k)
				break
			end
		end

		local vehID = tonumber(getElementData(theVehicle, "dbid")) or 0
		if vehID > 0 then
			dbExec(exports.mek_mysql:getConnection(), "UPDATE vehicles SET textures = ? WHERE id = ?", toJSON(textures), vehID)
		end
		setElementData(theVehicle, "textures", textures, true)
	end
end
addEvent("item-texture.removeTexture", true)
addEventHandler("item-texture.removeTexture", root, removeVehicleTexture)

function validateVehicleTexture(theVehicle, texName, url)
	if client and source and client ~= source and source ~= resourceRoot then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return false
	end

	local player = client
	if not exports.mek_integration:isPlayerServerManager(player) then
		outputDebugString("[ITEM-TEXTURE] Yetkisiz indirme isteği: " .. tostring(getPlayerName(player)), 1)
		exports.mek_sac:banForEventAbuse(player, eventName .. " (Yetkisiz)")
		return false
	end

	outputChatBox("[!] #FFFFFFAraca kaplama indiriliyor, lütfen bekleyin...", player, 200, 200, 0, true)

	local options = { 
		queueName = "vehicle_textures", 
		connectionAttempts = 3, 
		connectionTimeout = 10000 
	}

	local watchdog = setTimer(function()
		if isElement(player) then
			outputChatBox("[!] #FF0000HATA: #FFFFFFİndirme işlemi zaman aşımına uğradı.", player, 255, 0, 0, true)
			triggerClientEvent(player, "item-texture.fileValidationResult", resourceRoot, theVehicle, texName, url, false, "Zaman aşımı.")
		end
	end, 20000, 1)

	fetchRemote(url, options, function(responseData, errorCode)
		if isTimer(watchdog) then killTimer(watchdog) end
		if not isElement(player) then return end

		local isSuccess = (responseData and responseData ~= "ERROR") and ( (type(errorCode) == "number" and errorCode == 0) or (type(errorCode) == "table" and (errorCode.success or errorCode.status == 200)) )
		
		if isSuccess then
			if not isElement(theVehicle) then return end
			local vehID = getElementData(theVehicle, "dbid") or 0
			local path = "cache/temp_" .. md5(url) .. ".tex"
			local file = fileCreate(path)
			if file then
				fileWrite(file, responseData)
				local fileSize = fileGetSize(file)
				fileClose(file)

				if fileSize > maxFileSize then
					outputChatBox("[!] #FF0000HATA: #FFFFFFDosya boyutu çok büyük.", player, 255, 0, 0, true)
					triggerClientEvent(player, "item-texture.fileValidationResult", resourceRoot, theVehicle, texName, url, false, "Boyut hatası.")
					fileDelete(path)
				else
					local finalPath = getPath(url)
					if fileExists(finalPath) then fileDelete(finalPath) end
					fileRename(path, finalPath)
					
					outputChatBox("[!] #00FF00BAŞARILI: #FFFFFFKaplama indirildi ve uygulandı.", player, 0, 255, 0, true)
					exports.mek_global:sendMessageToAdmins("[ADM] " .. exports.mek_global:getPlayerFullAdminTitle(player) .. " araç kaplamasını değiştirdi. (ID: " .. vehID .. ")")
					triggerClientEvent(player, "item-texture.fileValidationResult", resourceRoot, theVehicle, texName, url, true)
				end
			else
				outputChatBox("[!] #FF0000HATA: #FFFFFFDosya sistemi yazma hatası.", player, 255, 0, 0, true)
				triggerClientEvent(player, "item-texture.fileValidationResult", resourceRoot, theVehicle, texName, url, false, "Dosya hatası.")
			end
		else
			local errCode = (type(errorCode) == "table" and errorCode.status) or errorCode
			outputChatBox("[!] #FF0000HATA: #FFFFFFResim indirilemedi. (F8'e bakın)", player, 255, 0, 0, true)
			outputConsole("[ITEM-TEXTURE] HATA: İndirme başarısız. URL: " .. tostring(url) .. " | Hata: " .. tostring(errCode), player)
			triggerClientEvent(player, "item-texture.fileValidationResult", resourceRoot, theVehicle, texName, url, false, "İndirme hatası.")
		end
	end)
end
addEvent("item-texture.validateFile", true)
addEventHandler("item-texture.validateFile", resourceRoot, validateVehicleTexture)
