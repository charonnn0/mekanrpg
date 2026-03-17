screenSize = Vector2(guiGetScreenSize())

Infobox = {}
Infobox.maxBoxes = 5
Infobox.items = {}
Infobox.types = {
	Error = "error",
	Warning = "warning",
	Info = "info",
	Success = "success",
	Announcement = "announcement",
	Discord = "discord",
	Instagram = "instagram",
	YouTube = "youtube",
	TikTok = "tiktok",
}
Infobox.padding = 10
Infobox.lastClick = 0
Infobox.placement = {
	TopLeft = "top-left",
	TopCenter = "top-center",
	TopRight = "top-right",
	CenterLeft = "center-left",
	Center = "center",
	CenterRight = "center-right",
	BottomLeft = "bottom-left",
	BottomCenter = "bottom-center",
	BottomRight = "bottom-right",
}
Infobox.linesSize = {
	x = 136,
	y = 104 / 2,
}

Infobox.colorScheme = {
	[Infobox.types.Error] = {
		__themeColor = "red",
		__icon = "",
		__sound = "public/sounds/error.wav",
		__colors = {
			background = 900,
			hover = 800,
			lines = 700,
			text = 100,
			icon = 200,
		},
	},
	[Infobox.types.Warning] = {
		__themeColor = "yellow",
		__icon = "",
		__sound = "public/sounds/warning.wav",
		__colors = {
			background = 900,
			hover = 800,
			lines = 700,
			text = 100,
			icon = 200,
		},
	},
	[Infobox.types.Info] = {
		__themeColor = "blue",
		__icon = "",
		__sound = "public/sounds/info.wav",
		__colors = {
			background = 900,
			hover = 800,
			lines = 700,
			text = 100,
			icon = 200,
		},
	},
	[Infobox.types.Success] = {
		__themeColor = "green",
		__icon = "",
		__sound = "public/sounds/success.wav",
		__colors = {
			background = 900,
			hover = 800,
			lines = 700,
			text = 100,
			icon = 200,
		},
	},
	[Infobox.types.Announcement] = {
		__themeColor = "blue",
		__icon = "",
		__sound = "public/sounds/announcement.mp3",
		__colors = {
			background = 900,
			hover = 800,
			lines = 700,
			text = 100,
			icon = 200,
		},
	},
	[Infobox.types.Discord] = {
		__themeColor = "discord",
		__icon = "",
		__sound = "public/sounds/discord.mp3",
		__iconFont = "FontAwesomeBrand",
		__colors = {
			background = 900,
			hover = 800,
			lines = 700,
			text = 100,
			icon = 200,
		},
	},
	[Infobox.types.Instagram] = {
		__themeColor = "instagram",
		__icon = "",
		__sound = "public/sounds/discord.mp3",
		__iconFont = "FontAwesomeBrand",
		__colors = {
			background = 900,
			hover = 800,
			lines = 700,
			text = 100,
			icon = 200,
		},
	},
	[Infobox.types.YouTube] = {
		__themeColor = "youtube",
		__icon = "",
		__sound = "public/sounds/discord.mp3",
		__iconFont = "FontAwesomeBrand",
		__colors = {
			background = 900,
			hover = 800,
			lines = 700,
			text = 100,
			icon = 200,
		},
	},
	[Infobox.types.TikTok] = {
		__themeColor = "tiktok",
		__icon = "",
		__sound = "public/sounds/discord.mp3",
		__iconFont = "FontAwesomeBrand",
		__colors = {
			background = 900,
			hover = 800,
			lines = 700,
			text = 100,
			icon = 200,
		},
	},
}

function Infobox.getPositionWithPlacement(placement, width, height)
	if placement == Infobox.placement.TopLeft then
		return Infobox.padding, Infobox.padding
	elseif placement == Infobox.placement.TopCenter then
		return screenSize.x / 2 - width / 2, Infobox.padding
	elseif placement == Infobox.placement.TopRight then
		return screenSize.x - width - Infobox.padding, Infobox.padding
	elseif placement == Infobox.placement.CenterLeft then
		return Infobox.padding, screenSize.y / 2 - height / 2
	elseif placement == Infobox.placement.Center then
		return screenSize.x / 2 - width / 2, screenSize.y / 2 - height / 2
	elseif placement == Infobox.placement.CenterRight then
		return screenSize.x - width - Infobox.padding, screenSize.y / 2 - height / 2
	elseif placement == Infobox.placement.BottomLeft then
		return Infobox.padding, screenSize.y - height - Infobox.padding
	elseif placement == Infobox.placement.BottomCenter then
		return screenSize.x / 2 - width / 2, screenSize.y - height - Infobox.padding
	elseif placement == Infobox.placement.BottomRight then
		return screenSize.x - width - Infobox.padding, screenSize.y - height - Infobox.padding
	end
end

function Infobox.overrideTheme(theme)
	theme.DISCORD = {
		[900] = "#7289da",
		[800] = "#677bc4",
		[700] = "#5b6eae",
		[600] = "#4e608f",
		[500] = "#424b66",
		[400] = "#363e4d",
		[300] = "#F2F2F2",
		[200] = "#F2F2F2",
		[100] = "#F2F2F2",
		[50] = "#060607",
	}
	theme.INSTAGRAM = {
		[900] = "#E1306C",
		[800] = "#D91E5D",
		[700] = "#C81F66",
		[600] = "#B22E5B",
		[500] = "#A22C5B",
		[400] = "#8F2A5B",
		[300] = "#F2F2F2",
		[200] = "#F2F2F2",
		[100] = "#F2F2F2",
		[50] = "#45225B",
	}
	theme.YOUTUBE = {
		[900] = "#fE0000",
		[800] = "#FF3434",
		[700] = "#C81F66",
		[600] = "#B22E5B",
		[500] = "#A22C5B",
		[400] = "#8F2A5B",
		[300] = "#F2F2F2",
		[200] = "#F2F2F2",
		[100] = "#F2F2F2",
		[50] = "#45225B",
	}
	theme.TIKTOK = theme.GRAY
	return theme
end

function Infobox.generateColorScheme(boxType)
	local theme = useTheme()
	theme = Infobox.overrideTheme(theme)
	local colorScheme = Infobox.colorScheme[boxType]
	local themeColor = theme[colorScheme.__themeColor:upper()]
	local colors = colorScheme.__colors
	local color = {}
	color.background = themeColor[colors.background]
	color.hover = themeColor[colors.hover]
	color.lines = themeColor[colors.lines]
	color.text = themeColor[colors.text]
	color.icon = themeColor[colors.icon]
	return color
end

setTimer(function()
	if #Infobox.items == 0 then
		return
	end

	local newItems = {}
	local currentTime = getTickCount()

	local placementOffsetY = {}

	for i = 1, #Infobox.items do
		local box = Infobox.items[i]

		if not box.startTime then
			box.startTime = currentTime
		end

		local elapsedTime = currentTime - box.startTime

		if elapsedTime < box.duration then
			local fadeDuration = math.min(500, box.duration * 0.2)
			local remainingTime = box.duration - elapsedTime
			if elapsedTime < fadeDuration then
				box.alpha = math.floor((elapsedTime / fadeDuration) * 255)
			elseif remainingTime <= fadeDuration then
				box.alpha = math.floor((remainingTime / fadeDuration) * 255)
			else
				box.alpha = 255
			end
			box.alpha = math.max(0, math.min(255, box.alpha))

			local placement = box.placement

			if not placementOffsetY[placement] then
				placementOffsetY[placement] = 0
			end

			local baseX, baseY = Infobox.getPositionWithPlacement(placement, box.size.x, box.size.y)

			local x, y
			local isBottomAligned = string.find(placement, "bottom")
			if isBottomAligned then
				y = baseY - placementOffsetY[placement]
			else
				y = baseY + placementOffsetY[placement]
			end
			x = baseX

			placementOffsetY[placement] = placementOffsetY[placement] + box.size.y + 5

			local color = box.color
			local width, height = box.size.x, box.size.y
			local hover = inArea(x, y, width, height)

			if hover and box.clipboardText then
				if isKeyPressed("mouse1") and Infobox.lastClick + 300 <= currentTime then
					Infobox.lastClick = currentTime
					setClipboard(box.clipboardText)
					addBox(
						"success",
						"Başarıyla kopyaladınız, tarayıcınıza girip doğrudan CTRL+V yaparak yapıştırın."
					)
				end
			end

			drawRoundedRectangle({
				position = {
					x = x,
					y = y,
				},
				size = {
					x = width,
					y = height,
				},

				color = color[hover and "hover" or "background"],
				alpha = box.alpha / 255,
				radius = 16,
				
				borderWidth = 1,
				borderColor = color["lines"],

				section = false,
				postGUI = true,
			})

			dxDrawText(
				box.icon,
				x + Infobox.padding,
				y + Infobox.padding - 3,
				0,
				0,
				rgba(color.icon, box.alpha / 255),
				0.7,
				box.font.icon,
				"left",
				"top",
				false,
				false,
				true
			)

			local textX = x + Infobox.padding * 4.4
			local textY = y + Infobox.padding

			dxDrawText(
				box.message,
				textX - 3,
				textY + 1,
				0,
				0,
				rgba(color.text, box.alpha / 255),
				1,
				box.font.message,
				"left",
				"top",
				false,
				false,
				true
			)

			table.insert(newItems, box)
		end
	end

	Infobox.items = newItems
end, 0, 0)

function addBox(boxType, message, duration, placement, clipboardText)
	if #Infobox.items >= Infobox.maxBoxes then
		table.remove(Infobox.items, 1)
	end

	local fonts = useFonts()

	if type(message) == "table" then
		message = message.message
	end

	if not duration or not tonumber(duration) then
		duration = 5000
	end

	if Infobox.colorScheme[boxType].__sound then
		playSound(Infobox.colorScheme[boxType].__sound)
	end

	local iconFont = Infobox.colorScheme[boxType].__iconFont
	if iconFont then
		iconFont = dxCreateFont(":mek_ui/public/fonts/" .. iconFont .. ".ttf", 20) or "default"
	end

	local messageLines = split(message, "\n")
	local messageLinesCount = #messageLines
	local messageHeight = dxGetFontHeight(1, fonts.UbuntuRegular.body) * messageLinesCount

	local maxWidth = 0
	for _, line in ipairs(messageLines) do
		local lineWidth = dxGetTextWidth(line, 1, fonts.UbuntuRegular.body)
		if lineWidth > maxWidth then
			maxWidth = lineWidth
		end
	end

	local box = {}
	box.type = boxType
	box.message = message
	box.duration = duration
	box.clipboardText = clipboardText
	box.placement = placement or Infobox.placement.TopCenter
	box.font = {
		message = fonts.UbuntuRegular.body,
		icon = iconFont or fonts.icon,
	}

	box.icon = Infobox.colorScheme[boxType].__icon
	box.size = {
		x = math.max(maxWidth + Infobox.padding * 4.4 + 10, Infobox.linesSize.x),
		y = messageHeight + Infobox.padding * 2,
	}

	box.color = Infobox.generateColorScheme(boxType)
	box.position = {
		x = 0,
		y = 0,
	}

	table.insert(Infobox.items, box)
end
addEvent("infobox.addBox", true)
addEventHandler("infobox.addBox", root, addBox)

function isRenderInfobox()
	if #Infobox.items > 0 then
		return true
	end
	return false
end
