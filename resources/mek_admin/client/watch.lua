local screenSize = Vector2(guiGetScreenSize())
local image, label, name = nil, nil, ""

local function cleanupImage()
	if image then
		destroyElement(image)
	end
	if label then
		destroyElement(label)
	end
	image, label = nil, nil
end

addEvent("updateScreen", true)
addEventHandler("updateScreen", root, function(imageData, player)
	local tempFile = "temp.jpg"
	if fileExists(tempFile) then
		fileDelete(tempFile)
	end

	local file = fileCreate(tempFile)
	if file then
		fileWrite(file, imageData)
		fileClose(file)
	end

	name = getPlayerName(player):gsub("_", " ") .. " (" .. getElementData(player, "id") .. ")"

	if not image then
		image = guiCreateStaticImage(screenSize.x - 360, screenSize.y - 370, 350, 350, tempFile, false)
		label = guiCreateLabel(screenSize.x - 360, screenSize.y - 390, 350, 30, name, false)
	end
end)

addEvent("stopScreen", true)
addEventHandler("stopScreen", root, cleanupImage)

setTimer(function()
	if image then
		guiStaticImageLoadImage(image, "temp.jpg")
		guiSetText(label, name)
	end
end, 0, 0)
