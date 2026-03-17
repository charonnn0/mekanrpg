Loader = {}
Loader.config = {
	lodDistance = 75,
	baseId = 20000,
}
Loader.loaded = false
Loader.downloadQueue = {}
Loader.apiUrl = "https://Mekanroleplay.com/api/game/uploads/"
Loader.downloadFileStatus = {
	Pending = 0,
	Downloaded = 2,
	Failed = 3,
}

screenSize = Vector2(guiGetScreenSize())

function Loader.getRowFromID(id)
	return models[ModelType.Ped][id]
end

function Loader.startDownload(id)
	if Loader.downloadQueue[id] then
		return
	end

	Loader.downloadQueue[id] = {
		txd = Loader.downloadFileStatus.Pending,
		dff = Loader.downloadFileStatus.Pending,
	}

	fetchRemote(Loader.apiUrl .. id .. ".txd", { method = "GET", connectionAttempts = 3 }, function(response, info)
		if info.success then
			local path = "public/skins/" .. id .. ".txd"

			if fileExists(path) then
				fileDelete(path)
			end

			local file = fileCreate(path)
			fileWrite(file, response)
			fileClose(file)

			Loader.downloadQueue[id].txd = Loader.downloadFileStatus.Downloaded
		else
			outputConsole("[ModelStreamer] " .. tostring(id) .. " numaralı kıyafetin TXD dosyası indirilemedi.")
			Loader.downloadQueue[id] = nil
		end
	end)

	fetchRemote(Loader.apiUrl .. id .. ".dff", { method = "GET", connectionAttempts = 3 }, function(response, info)
		if info.success then
			local path = "public/skins/" .. id .. ".dff"

			if fileExists(path) then
				fileDelete(path)
			end

			local file = fileCreate(path)
			fileWrite(file, response)
			fileClose(file)

			Loader.downloadQueue[id].dff = Loader.downloadFileStatus.Downloaded
		else
			outputConsole("[ModelStreamer] " .. tostring(id) .. " numaralı kıyafetin DFF dosyası indirilemedi.")
			Loader.downloadQueue[id] = nil
		end
	end)
end

function Loader.downloadModel(id)
	if Loader.downloadQueue[id] then
		return
	end

	local isBlocked = isBrowserDomainBlocked("imgur.com")

	if not isBlocked then
		Loader.startDownload(id)
		return
	end

	requestBrowserDomains({ "https://imgur.com/", "imgur.com", Loader.apiUrl }, true, function(accepted)
		if not accepted then
			outputConsole(
				"[ModelStreamer] Sunucudaki insanların kıyafetlerini görebilmek için gösterilen ekranı onaylamanız gerekiyor."
			)
			return
		end

		Loader.startDownload(id)
	end)
end

addCommandHandler("skinfix", function(commandName)
	if not localPlayer:getData("logged") then
		return
	end

	requestBrowserDomains({ "https://imgur.com/", "imgur.com", Loader.apiUrl }, true)
	Streamer.loadAll()
end, false, false)

setTimer(function()
	local queueSize = size(Loader.downloadQueue)
	local isBlocked = isBrowserDomainBlocked("imgur.com")

	if isBlocked then
		if not localPlayer:getData("logged") then
			return
		end

		dxDrawText(
			"Modlu skinler, sunucuya izin vermediğiniz için gözükmeyecek. Düzeltmek için /skinfix yazınız.",
			0,
			0,
			screenSize.x,
			screenSize.y - 20,
			tocolor(255, 0, 0),
			1,
			"default-bold",
			"center",
			"bottom"
		)
		return
	end

	if queueSize > 0 then
		for id, data in pairs(Loader.downloadQueue) do
			local isTXDLoaded = data.txd == Loader.downloadFileStatus.Downloaded
			local isDFFLoaded = data.dff == Loader.downloadFileStatus.Downloaded

			if isTXDLoaded and isDFFLoaded then
				Loader.downloadQueue[id] = nil
				models[ModelType.Ped][id].loaded = ModelStatus.Unloaded

				Streamer.loadById(id)
			end
		end

		dxDrawText(
			"Modlu kıyafetler indiriliyor. (" .. queueSize .. " kaldı)",
			0,
			0,
			screenSize.x,
			screenSize.y - 20,
			tocolor(255, 255, 255),
			2,
			"default-bold",
			"center",
			"bottom"
		)
	end
end, 0, 0)

function Loader.loadPedModel(id)
	local row = Loader.getRowFromID(id)
	if not row then
		local idToStr = tostring(id)

		if #idToStr >= 5 then
			if fileExists("public/skins/" .. id .. ".txd") then
				models[ModelType.Ped][id] = {
					loaded = ModelStatus.Unloaded,
					model = 0,
				}
			else
				models[ModelType.Ped][id] = {
					loaded = ModelStatus.Downloading,
					model = 0,
				}
				Loader.downloadModel(id)
			end

			row = Loader.getRowFromID(id)
		else
			return
		end
	end

	if
		row.loaded == ModelStatus.Loaded
		or row.loaded == ModelStatus.Failed
		or row.loaded == ModelStatus.Downloading
	then
		return
	end

	local isCustomModel = tostring(id):len() >= 5
	local model = engineRequestModel("ped", not isCustomModel and Loader.config.baseId + id)

	if model then
		models[ModelType.Ped][id].model = model

		local txd = engineLoadTXD("public/skins/" .. id .. ".txd")
		local dff = engineLoadDFF("public/skins/" .. id .. ".dff")

		if not txd or not dff then
			models[ModelType.Ped][id].loaded = ModelStatus.Failed
			return
		end

		engineImportTXD(txd, model)
		engineReplaceModel(dff, model)

		models[ModelType.Ped][id].loaded = ModelStatus.Loaded

		engineSetModelLODDistance(model, Loader.config.lodDistance)
	else
		models[ModelType.Ped][id].loaded = ModelStatus.Failed
	end
end

function Loader.unloadPedModel(id)
	local row = models[ModelType.Ped][id]
	if not row then
		return
	end

	if row.loaded == ModelStatus.Loaded then
		engineFreeModel(row.model)
		models[ModelType.Ped][id].loaded = ModelStatus.Unloaded
	end
end

function Loader.load()
	if Loader.loaded then
		return false
	end

	Loader.loaded = true

	Streamer.loadAll()

	return true
end
addEventHandler("onClientResourceStart", resourceRoot, Loader.load)

function Loader.unload()
	if not Loader.loaded then
		return false
	end

	Loader.loaded = false

	for _, regularName in pairs(ModelType) do
		Async:foreach_pairs(models[regularName], function(row)
			if row.loaded == ModelStatus.Loaded then
				engineFreeModel(row.model)
			end
		end)
	end

	return true
end
addEventHandler("onClientResourceStop", resourceRoot, Loader.unload)

function getEntityModel(id)
	id = tonumber(id)
	local row = models[ModelType.Ped][id]
	if not row then
		return localPlayer.model
	end

	if row.loaded == nil then
		Loader.loadPedModel(id)
	end

	if row.loaded == ModelStatus.Loaded then
		return row.model
	end

	return 0
end
