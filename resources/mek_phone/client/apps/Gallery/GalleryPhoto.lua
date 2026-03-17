Gallery.drawPhotoDetails = function(position, size)
	local photo = Gallery.showingPhoto

	local photoInnerSize = {
		x = Phone.innerSize.x,
		y = Phone.innerSize.y - Gallery.padding * 12,
	}

	if photo.sizeWidth > photo.sizeHeight then
		photoInnerSize.y = photoInnerSize.y * (photo.sizeHeight / photo.sizeWidth)
	else
		photoInnerSize.x = photoInnerSize.x * (photo.sizeWidth / photo.sizeHeight)
	end

	local photoPosition = {
		x = position.x + Phone.innerSize.x / 2 - photoInnerSize.x / 2,
		y = position.y + size.y / 2 - photoInnerSize.y / 2,
	}

	Phone.components.photo(photoPosition, photoInnerSize, photo.sizeWidth, photo.sizeHeight, photo.photoID)

	photoPosition.y = position.y + size.y - 50

	local buttonSize = 32
	local backButton = drawButton({
		position = {
			x = photoPosition.x,
			y = photoPosition.y,
		},
		size = {
			x = buttonSize,
			y = buttonSize,
		},

		textProperties = {
			align = "center",
			color = theme.WHITE,
			font = fonts.icon,
			scale = 0.5,
		},

		variant = "plain",
		color = "gray",
		disabled = Gallery.isExifDetailsShowing,

		text = "",
	})

	dxDrawText(
		photo.photoID .. ".png",
		photoPosition.x + 32 + Gallery.padding,
		photoPosition.y + 8,
		0,
		0,
		rgba(theme.GRAY[300]),
		1,
		fonts.UbuntuRegular.body
	)

	local exifDetailsButton = drawButton({
		position = {
			x = photoPosition.x + photoInnerSize.x - buttonSize,
			y = photoPosition.y,
		},
		size = {
			x = buttonSize,
			y = buttonSize,
		},

		textProperties = {
			align = "center",
			color = theme.WHITE,
			font = fonts.icon,
			scale = 0.5,
		},

		variant = "plain",
		color = "gray",

		text = "",
	})

	local deletePhotoButton = drawButton({
		position = {
			x = photoPosition.x + photoInnerSize.x - buttonSize * 2,
			y = photoPosition.y,
		},
		size = {
			x = buttonSize,
			y = buttonSize,
		},

		textProperties = {
			align = "center",
			color = theme.WHITE,
			font = fonts.icon,
			scale = 0.5,
		},

		variant = "plain",
		color = "gray",

		text = "",
	})

	if deletePhotoButton.pressed then
		Gallery.deletePhoto(photo.id)
	end

	if backButton.pressed then
		Gallery.showingPhoto = false
	end

	if exifDetailsButton.pressed then
		Gallery.isExifDetailsShowing = true
	end

	if Gallery.isExifDetailsShowing then
		local exifDetailsSize = {
			x = size.x - Gallery.padding * 2,
			y = Phone.innerSize.y / 2.2,
		}

		local exifDetailsPosition = {
			x = position.x + Gallery.padding,
			y = position.y + size.y - exifDetailsSize.y - Gallery.padding,
		}

		drawRoundedRectangle({
			position = exifDetailsPosition,
			size = exifDetailsSize,

			color = theme.GRAY[900],
			alpha = 0.8,
			radius = 1,
		})

		dxDrawText(
			"Fotoğraf Detayları",
			exifDetailsPosition.x + Gallery.padding,
			exifDetailsPosition.y + 10,
			0,
			0,
			rgba(theme.GRAY[100]),
			1,
			fonts.BebasNeueRegular.h3
		)

		local closeExifButton = drawButton({
			position = {
				x = exifDetailsPosition.x + exifDetailsSize.x - buttonSize - Gallery.padding,
				y = exifDetailsPosition.y + Gallery.padding / 2,
			},
			size = {
				x = buttonSize,
				y = buttonSize,
			},

			textProperties = {
				align = "center",
				color = theme.WHITE,
				font = fonts.icon,
				scale = 0.5,
			},

			variant = "plain",
			color = "gray",

			text = "",
		})

		if closeExifButton.pressed then
			Gallery.isExifDetailsShowing = false
		end

		local radarSize = {
			x = exifDetailsSize.x / 1.5,
			y = 120,
		}

		local radarPosition = {
			x = exifDetailsPosition.x + exifDetailsSize.x / 2 - radarSize.x / 2,
			y = exifDetailsPosition.y + exifDetailsSize.y - radarSize.y - Gallery.padding * 3,
		}

		local exifPosition = fromJSON(photo.exifLocation)

		dxDrawText(
			"Tarih: " .. photo.exifDate,
			radarPosition.x,
			radarPosition.y - 35,
			0,
			0,
			rgba(theme.GRAY[300]),
			1,
			fonts.BebasNeueRegular.body
		)
		dxDrawText(
			"Konum: " .. exports.mek_global:getZoneName(exifPosition.x, exifPosition.y, exifPosition.z),
			radarPosition.x,
			radarPosition.y - 20,
			0,
			0,
			rgba(theme.GRAY[300]),
			1,
			fonts.BebasNeueRegular.body
		)
		exports.mek_radar:renderSection("exif-preview", radarPosition, radarSize, false, exifPosition)

		drawRoundedRectangle({
			position = {
				x = radarPosition.x + radarSize.x / 2 - 24 / 2,
				y = radarPosition.y + radarSize.y / 2 - 24 / 2,
			},
			size = {
				x = 24,
				y = 24,
			},

			color = theme.GRAY[400],
			alpha = 1,
			radius = 12,
		})
	end
end
