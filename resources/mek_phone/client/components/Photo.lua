Photo = {}
Photo.cache = {}
Photo.fileFormat = "@photos/photo_%s.image"

Phone.components.photo = function(position, size, realWidth, realHeight, photoID)
	if not Photo.cache[photoID] then
		Photo.cache[photoID] = {
			exists = fileExists(Photo.fileFormat:format(photoID)),
			requested = exists and true or false,
		}

		if Photo.cache[photoID].exists then
			Photo.cache[photoID].image = Photo.fileFormat:format(photoID)
		end
	end

	local hover = inArea(position.x, position.y, size.x, size.y)
	local ready = Photo.cache[photoID].exists

	if ready then
		local sizeAspectRatio = size.x / size.y
		local realAspectRatio = realWidth / realHeight

		if realAspectRatio > sizeAspectRatio then
			realWidth = realWidth * (size.y / realHeight)
			realHeight = size.y
		else
			realHeight = realHeight * (size.x / realWidth)
			realWidth = size.x
		end

		realWidth = math.clamp(realWidth, 1, size.x)
		realHeight = math.clamp(realHeight, 1, size.y)

		local realPosition = {
			x = position.x + size.x / 2 - realWidth / 2,
			y = position.y + size.y / 2 - realHeight / 2,
		}

		dxDrawImage(realPosition.x, realPosition.y, realWidth, realHeight, Photo.cache[photoID].image)
	else
		if not Photo.cache[photoID].requested then
			Photo.cache[photoID].requested = true
			getImageRaw(photoID, function(raw)
				saveDownloadedPhoto(photoID, raw)
			end)
		end

		dxDrawText(
			"",
			position.x,
			position.y,
			position.x + size.x,
			position.y + size.y,
			rgba(theme.GRAY[500]),
			0.5,
			fonts.icon,
			"center",
			"center"
		)
	end

	return hover, ready
end

function saveDownloadedPhoto(photoID, raw)
	local file = fileCreate(Photo.fileFormat:format(photoID))
	fileWrite(file, raw)
	fileClose(file)

	Photo.cache[photoID] = {
		exists = true,
		image = Photo.fileFormat:format(photoID),
		requested = true,
	}
end
