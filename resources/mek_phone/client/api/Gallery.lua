local apiURL = "https://api.imgur.com/3/image"

local apiSettings = {
	clientID = "b7644e5b70abb1d",
	clientSecret = "453bf2bbc87efafc69851d833d1369f28938a800",
}

local imageProperties = {
	MAX_WIDTH = 1920,
	MAX_HEIGHT = 1280,
	MAX_SIZE = 1024 * 1024 * 2,
}

local imagesInMemoryCache = {}

local function generateFileName()
	return tostring(getRealTime()) .. ".png"
end

function getImagePath(id)
	return "https://i.imgur.com/" .. id .. ".png"
end

function deleteImageFromAPI(id)
	local options = {
		method = "DELETE",
		queueName = "phoneGallery/imgur/delete",
		connectionAttempts = 3,
		headers = {
			Authorization = "Client-ID " .. apiSettings.clientID,
		},
	}
	fetchRemote(apiURL .. "/" .. id, options, function() end)
end

function getImageRaw(photoID, callback)
	if imagesInMemoryCache[photoID] then
		callback(imagesInMemoryCache[photoID])
		return
	end

	fetchRemote(getImagePath(photoID), { method = "GET", connectionAttempts = 3 }, function(raw, response)
		local isSuccess = response.success
		local statusCode = response.statusCode

		if not isSuccess then
			return callback(false)
		end

		imagesInMemoryCache[photoID] = raw
		callback(raw)
	end)
end

function uploadImageToAPI(photoBinary, callback)
	fetchRemote(apiURL, {
		method = "POST",
		connectionAttempts = 3,
		connectTimeout = 15000,
		requestTimeout = 45000,
		headers = {
			Authorization = "Client-ID " .. apiSettings.clientID,
		},
		formFields = {
			image = photoBinary,
			type = "base64",
			name = generateFileName(),
		},
	}, function(data, response)
		if not response.success then
			return callback(false)
		end

		local row = fromJSON(data)
		if row and row.success and row.data then
			local width, height = row.data.width, row.data.height


			if width > imageProperties.MAX_WIDTH or height > imageProperties.MAX_HEIGHT then
				return callback(false)
			end

			fetchRemote(row.data.link, {
				method = "GET",
				connectionAttempts = 3,
			}, function(raw, response)
				if not response.success then
					return callback(false)
				end

				imagesInMemoryCache[row.data.id] = raw
				callback(row.data, raw)
			end)


		else
			callback(false)
		end
	end)
end
