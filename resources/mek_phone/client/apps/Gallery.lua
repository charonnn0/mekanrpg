Gallery = {}
Gallery.showingPhoto = false
Gallery.isExifDetailsShowing = false
Gallery.padding = 15
Gallery.gridGap = 4
Gallery.gridContainerGap = Gallery.padding
Gallery.gridColumns = 4
Gallery.photoPreviewSize = math.floor(
	(Phone.innerSize.x - Gallery.gridContainerGap * 2 - Gallery.gridGap * (Gallery.gridColumns - 1))
		/ Gallery.gridColumns
)
Gallery.gridRows =
	math.floor((Phone.innerSize.y - Gallery.photoPreviewSize * 2) / (Gallery.photoPreviewSize + Gallery.gridGap))
Gallery.offset = 0
Gallery.limit = math.floor(Gallery.gridColumns * Gallery.gridRows)
Gallery.photosLimit = Gallery.limit
Gallery.photos = {}
Gallery.totalCount = 0
Gallery.loading = false

Gallery.deletePhoto = function(photoID)
	Gallery.showingPhoto = false
	triggerServerEvent("phone.gallery.deletePhoto", localPlayer, Phone.number, photoID)
end

local function drawPhotoPreview(position, size, imageID)
	if Gallery.loading then
		dxDrawImage(position.x, position.y, size, size, "public/app_details/prev.png")
	end
end

Phone.addApp(
	Phone.enums.Apps.Gallery,
	function(position, size, onClick, header, rightSection)
		Phone.components.Header(function(headerPosition, headerSize)
			dxDrawText(
				header or "Fotoğraflar",
				headerPosition.x + Gallery.padding,
				headerPosition.y + 10,
				0,
				0,
				rgba(theme.GRAY[100]),
				1,
				fonts.BebasNeueBold.h1
			)

			if rightSection then
				rightSection()
			else
				dxDrawText(
					("%s görsel"):format(Gallery.totalCount or 0),
					headerPosition.x - Gallery.padding,
					headerPosition.y + 22,
					headerPosition.x + headerSize.x - Gallery.padding,
					0,
					rgba(theme.GRAY[600]),
					1,
					fonts.UbuntuRegular.caption,
					"right"
				)
			end
		end, onClick)

		if Gallery.showingPhoto then
			Gallery.drawPhotoDetails(position, size)
			return
		end

		local position = {
			x = position.x,
			y = position.y + Gallery.padding + 70,
		}

		local counter = 0
		for i = Gallery.offset, Gallery.offset + Gallery.photosLimit - 1 do
			local photo = Gallery.photos[i]
			local photoPreviewPosition = {
				x = position.x
					+ (counter % Gallery.gridColumns) * (Gallery.photoPreviewSize + Gallery.gridGap)
					+ Gallery.gridContainerGap,
				y = position.y
					+ math.floor(counter / Gallery.gridColumns) * (Gallery.photoPreviewSize + Gallery.gridGap),
			}
			if photo and not Gallery.loading then
				local realWidth, realHeight = photo.sizeWidth, photo.sizeHeight

				local hover = Phone.components.photo(
					photoPreviewPosition,
					{ x = Gallery.photoPreviewSize, y = Gallery.photoPreviewSize },
					realWidth,
					realHeight,
					photo.photoID
				)

				if hover then
					dxDrawRectangle(
						photoPreviewPosition.x,
						photoPreviewPosition.y,
						Gallery.photoPreviewSize,
						Gallery.photoPreviewSize,
						rgba(theme.GRAY[800], 0.5)
					)
					if isKeyPressed("mouse1") then
						if onClick then
							onClick(photo)
						else
							Gallery.showingPhoto = photo
						end
					end
				end
			else
				drawPhotoPreview(photoPreviewPosition, Gallery.photoPreviewSize, i)
			end

			counter = counter + 1
		end
	end,
	"public/apps/gallery.png",
	"Fotoğraflar",
	false,
	function()
		Gallery.showingPhoto = false
		Gallery.isExifDetailsShowing = false
		Gallery.offset = 0
		Gallery.limit = Gallery.photosLimit
		Gallery.loadPhotos()
	end
)

Gallery.loadPhotos = function()
	Gallery.loading = true
	triggerServerEvent("phone.gallery.getPhotos", localPlayer, Phone.number, {
		offset = Gallery.offset,
		limit = Gallery.limit,
	})
end

addEventHandler("onClientKey", root, function(button, state)
	if Phone.currentApp == Phone.enums.Apps.Gallery then
		if button == "mouse_wheel_up" then
			if Gallery.offset == 0 then
				return
			end

			Gallery.offset = Gallery.offset - Gallery.photosLimit
			if Gallery.offset < 0 then
				Gallery.offset = 0
			end

			Gallery.limit = Gallery.offset + Gallery.photosLimit

			Gallery.loadPhotos()
		elseif button == "mouse_wheel_down" then
			if Gallery.totalCount <= Gallery.limit then
				return
			end

			Gallery.offset = Gallery.offset + Gallery.photosLimit
			if Gallery.offset > Gallery.totalCount then
				Gallery.offset = Gallery.listItemLimit
			end

			Gallery.limit = Gallery.offset + Gallery.photosLimit
			Gallery.loadPhotos()
		end
	end
end)

addEvent("phone.gallery.onGetPhotos", true)
addEventHandler("phone.gallery.onGetPhotos", root, function(offset, limit, photos, totalPhotos)
	local counter = 1
	for i = offset, limit do
		local photo = photos[counter]
		if photo then
			Gallery.photos[i] = photo
		else
			Gallery.photos[i] = nil
		end

		counter = counter + 1
	end

	Gallery.offset = offset
	Gallery.limit = limit
	Gallery.totalCount = totalPhotos
	Gallery.loading = false
end)

addEvent("phone.gallery.onDeletePhoto", true)
addEventHandler("phone.gallery.onDeletePhoto", root, function()
	Gallery.loadPhotos()
end)
