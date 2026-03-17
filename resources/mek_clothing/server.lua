local savedClothing = {}

function getPath(clothing)
	return "cache/" .. tostring(clothing) .. ".tex"
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

addEventHandler("onResourceStart", resourceRoot, function()
	clearCache()
	local count = 0
	dbQuery(function(queryHandle)
		local result, numRows = dbPoll(queryHandle, 0)
		if result then
			for _, row in ipairs(result) do
				row.id = tonumber(row.id)
				row.skin = tonumber(row.skin)
				row.owner = tonumber(row.owner)

				savedClothing[row.id] = row
				count = count + 1
			end
			outputDebugString("[CLOTHING] " .. count .. " dikim verisi yüklendi.")
		else
			outputDebugString("[CLOTHING] Dikim verileri yüklenemedi.", 1)
		end
	end, exports.mek_mysql:getConnection(), "SELECT * FROM clothing")
end)

function loadFromURL(url, id)
	fetchRemote(url, { queueName = "clothing_q", connectionAttempts = 3, connectionTimeout = 10000 }, function(responseData, errorCode)
		local isSuccess = (responseData and responseData ~= "ERROR") and ( (type(errorCode) == "number" and errorCode == 0) or (type(errorCode) == "table" and (errorCode.success or errorCode.status == 200)) )
		
		if isSuccess then
			local file = fileCreate(getPath(id))
			if file then
				fileWrite(file, responseData)
				fileClose(file)

				local data = savedClothing[id]
				if data and data.pending then
					triggerClientEvent(data.pending, "clothing.file", resourceRoot, id, responseData, #responseData)
					data.pending = nil
				end
			end
		end
	end)
end

function addClothing(id, skin, url, owner)
	id = tonumber(id)
	skin = tonumber(skin)
	owner = tonumber(owner)

	if not id or not skin or not url or not owner then
		return false
	end

	if savedClothing[id] then
		return false
	end

	savedClothing[id] = {
		id = id,
		skin = skin,
		url = url,
		owner = owner,
	}

	dbExec(
		exports.mek_mysql:getConnection(),
		"INSERT INTO clothing (skin, url, owner) VALUES (?, ?, ?)",
		skin,
		url,
		owner
	)

	return true
end

addEvent("clothing.stream", true)
addEventHandler("clothing.stream", resourceRoot, function(id)
	local id = tonumber(id)
	if type(id) == "number" and id ~= 0 then
		local data = savedClothing[id]
		if data then
			local path = getPath(id)
			if fileExists(path) then
				local file = fileOpen(path, true)
				if file then
					local size = fileGetSize(file)
					local content = fileRead(file, size)

					if #content == size then
						triggerLatentClientEvent(client, "clothing.file", resourceRoot, id, content, size)
					end
					fileClose(file)
				end
			else
				if data.pending then
					table.insert(data.pending, client)
				else
					data.pending = { client }
					loadFromURL(data.url, id)
				end
			end
		end
	end
end, false)
