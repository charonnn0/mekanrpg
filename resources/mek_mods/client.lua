local mods

local vehicleWheelSizes = {
	[458] = 0.85,
	[494] = 0.75,
	[502] = 0.7,
	[503] = 0.7,
	[554] = 1,
	[479] = 0.8,
	[540] = 0.75,
	[411] = 0.75,
	[542] = 0.7,
	[598] = 0.8,
}

local function downloadMods()
	for _, data in ipairs(mods) do
		local file = data.file
		downloadFile(file)
	end
end

function unloadAllModels()
	for _, data in ipairs(mods) do
		engineRestoreModel(data.model)
	end
end

function loadAllModels()
	for _, data in ipairs(mods) do
		local file = data.file
		if file then
			local model = data.model

			if file:find(".txd") then
				local txd = engineLoadTXD(file)
				engineImportTXD(txd, data.model)
			elseif file:find(".dff") then
				local dff = engineLoadDFF(file)
				engineReplaceModel(dff, data.model)
			elseif file:find(".col") then
				local col = engineLoadCOL(file)
				engineReplaceCOL(col, data.model)
			end

			if vehicleWheelSizes[model] then
				setVehicleModelWheelSize(model, "all_wheels", vehicleWheelSizes[model])
			end
		end
	end
end

function table.find(array, index, value)
	for key, _value in pairs(array) do
		if _value[index] == value then
			return key
		end
	end
	return false
end

addEventHandler("onClientResourceStart", resourceRoot, function()
	triggerServerEvent("mods.onLoad", localPlayer)
end)

addEvent("mods.request", true)
addEventHandler("mods.request", root, function(data)
	if data then
		mods = data
		downloadMods()
	end
end)

addEventHandler("onClientFileDownloadComplete", root, function(name, success)
	if source == resourceRoot then
		if success then
			local index = table.find(mods, "file", name)
			if index then
				local model = mods[index].model

				if name:find(".txd") then
					local txd = engineLoadTXD(name)
					engineImportTXD(txd, model)
				elseif name:find(".dff") then
					local dff = engineLoadDFF(name)
					engineReplaceModel(dff, model)
				elseif name:find(".col") then
					local col = engineLoadCOL(name)
					engineReplaceCOL(col, model)
				end

				if vehicleWheelSizes[model] then
					setVehicleModelWheelSize(model, "all_wheels", vehicleWheelSizes[model])
				end

				tick = getTickCount() + 2000
			end
		end
	end
end)
