local screenSize = Vector2(guiGetScreenSize())

local theme = useTheme()
local fonts = useFonts()

local requestedWord = nil

addEvent("hotwire.drawText", true)
addEventHandler("hotwire.drawText", root, function(word)
	requestedWord = word
end)

addEvent("hotwire.removeText", true)
addEventHandler("hotwire.removeText", root, function()
	requestedWord = nil
end)

setTimer(function()
	if not localPlayer:getData("logged") then
		return
	end

	if not requestedWord then
		return
	end

	dxDrawRectangle(0, 0, screenSize.x, screenSize.y, rgba(theme.GRAY[900], 0.7))

	local textX = screenSize.x / 2
	local textY = screenSize.y / 2

	dxDrawText(
		requestedWord,
		textX + 1,
		textY + 1,
		textX + 1,
		textY + 1,
		rgba(theme.BLACK),
		1,
		fonts.ProximaNovaBold.h0,
		"center",
		"center"
	)
	dxDrawText(
		requestedWord,
		textX,
		textY,
		textX,
		textY,
		rgba(theme.WHITE),
		1,
		fonts.ProximaNovaBold.h0,
		"center",
		"center"
	)
end, 0, 0)
