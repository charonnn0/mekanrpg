Streamer = {}

Streamer.waitingModels = {}

Streamer.catch = function(dataName, oldValue, newValue)
	if dataName ~= "model" then
		return
	end

	newValue = tonumber(newValue) or tostring(newValue)

	if newValue == 0 then
		return
	end

	if source.type == "ped" or source.type == "player" then
		Loader.loadPedModel(newValue)
		local row = models[ModelType.Ped][newValue]
		if row and row.loaded == ModelStatus.Loaded then
			source:setModel(row.model)
		else
			table.insert(Streamer.waitingModels, { element = source, model = newValue })
			outputConsole(
				"[Model Streamer] Model "
					.. tostring(newValue)
					.. " is not loaded yet for "
					.. tostring(source.type)
					.. " "
					.. tostring(source.name)
					.. "."
			)
		end
	end
end
addEventHandler("onClientElementDataChange", root, Streamer.catch)

Streamer.loadAll = function()
	Async:foreach(getElementsByType("player"), function(player)
		local model = player:getData("model")
		if model then
			Loader.loadPedModel(model)
			local row = models[ModelType.Ped][model]
			if row and row.loaded == ModelStatus.Loaded then
				player:setModel(row.model)
			else
				table.insert(Streamer.waitingModels, { element = player, model = model })
			end
		end
	end)
end

Streamer.loadById = function(id)
	Async:foreach(getElementsByType("player"), function(player)
		local model = player:getData("model")
		if model and model == id then
			Loader.loadPedModel(model)
			local row = models[ModelType.Ped][model]
			if row.loaded == ModelStatus.Loaded then
				player:setModel(row.model)
			end
		end
	end)
end

Streamer.catchOnStreamIn = function()
	local model = source:getData("model")
	if model then
		Loader.loadPedModel(newValue)
		local row = models[ModelType.Ped][model]
		if row and row.loaded == ModelStatus.Loaded then
			source:setModel(row.model)
		end
	end
end
addEventHandler("onClientElementStreamIn", root, Streamer.catchOnStreamIn)

Streamer.loadWaitingModels = function()
	Async:foreach(Streamer.waitingModels, function(data, key)
		local source = data.element
		local model = data.model
		Loader.loadPedModel(model)

		local row = models[ModelType.Ped][model]
		if row and row.loaded == ModelStatus.Loaded then
			source:setModel(row.model)

			Streamer.waitingModels[key] = nil

			outputConsole(
				"[Model Streamer] Missing model "
					.. tostring(newValue)
					.. " loaded for "
					.. tostring(source.type)
					.. " "
					.. tostring(source.name)
					.. "."
			)
		end
	end)
end
setTimer(Streamer.loadWaitingModels, 1000, 0)
