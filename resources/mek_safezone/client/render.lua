local screenSize = Vector2(guiGetScreenSize())

local theme = useTheme()
local fonts = useFonts()

setTimer(function()
	if getElementData(localPlayer, "logged") and getElementData(localPlayer, "safezone") then
		local containerSize = {
			x = math.floor(resp(350)),
			y = 45,
		}

		local containerPosition = {
			x = 20,
			y = screenSize.y - containerSize.y - 20,
		}

		if exports.mek_radar:isMiniMapVisible() then
			containerPosition.y = (screenSize.y - math.floor(resp(225)) - 20) - containerSize.y - 10
		end

		drawRoundedRectangle({
			position = {
				x = containerPosition.x,
				y = containerPosition.y,
			},
			size = {
				x = containerSize.x,
				y = containerSize.y,
			},

			color = theme.GREEN[600],
			alpha = 0.9,
			radius = 8,

			borderWidth = 1,
			borderColor = theme.GREEN[400],
		})

		dxDrawText(
			"",
			containerPosition.x + 10,
			containerPosition.y,
			containerPosition.x + containerSize.x,
			containerPosition.y + containerSize.y,
			rgba(theme.GREEN[50]),
			0.8,
			fonts.icon,
			"left",
			"center"
		)
		dxDrawText(
			"Güvenli Bölge",
			containerPosition.x,
			containerPosition.y - 2,
			containerPosition.x + containerSize.x,
			containerPosition.y + containerSize.y,
			rgba(theme.GREEN[50]),
			1,
			fonts.BebasNeueBold.h2,
			"center",
			"center"
		)
	end
end, 0, 0)
