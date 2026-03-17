local currentlyDrawingLines = {}
local loadedServerLines = {}
local isDrawingModeActive = false
local startSegmentX, startSegmentY, startSegmentZ = 0, 0, 0
local currentDrawingLineID = nil
local lineTexture = dxCreateTexture("public/images/line.png", "argb", true, "clamp")
local LINE_THICKNESS = 0.15
local LINE_COLOR = tocolor(255, 255, 255)
local MIN_SEGMENT_LENGTH = 1.7

function drawAllLines()
	if isDrawingModeActive then
		local currentX, currentY, currentZ = getElementPosition(localPlayer)
		local distanceToLastPoint =
			getDistanceBetweenPoints3D(startSegmentX, startSegmentY, startSegmentZ, currentX, currentY, currentZ)

		if distanceToLastPoint >= MIN_SEGMENT_LENGTH then
			table.insert(currentlyDrawingLines, {
				x1 = startSegmentX,
				y1 = startSegmentY,
				z1 = startSegmentZ,
				x2 = currentX,
				y2 = currentY,
				z2 = currentZ,
			})
			startSegmentX, startSegmentY, startSegmentZ = currentX, currentY, currentZ
		end

		for _, segment in ipairs(currentlyDrawingLines) do
			dxDrawMaterialLine3D(
				segment.x1,
				segment.y1,
				segment.z1,
				segment.x2,
				segment.y2,
				segment.z2,
				lineTexture,
				LINE_THICKNESS,
				LINE_COLOR
			)
		end
	end

	for playerElement, playerLines in pairs(loadedServerLines) do
		for lineID, segments in pairs(playerLines) do
			for _, segment in ipairs(segments) do
				dxDrawMaterialLine3D(
					segment.x1,
					segment.y1,
					segment.z1,
					segment.x2,
					segment.y2,
					segment.z2,
					lineTexture,
					LINE_THICKNESS,
					LINE_COLOR
				)
			end
		end
	end
end
addEventHandler("onClientRender", root, drawAllLines)

function getDistanceBetweenPoints3D(x1, y1, z1, x2, y2, z2)
	return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2 + (z2 - z1) ^ 2)
end

function toggleLineModeClient(enable, id)
	isDrawingModeActive = enable
	currentDrawingLineID = id

	if not enable then
		if currentDrawingLineID and #currentlyDrawingLines > 0 then
			triggerServerEvent(
				"legal.sendLineDataToServer",
				localPlayer,
				currentDrawingLineID,
				currentlyDrawingLines
			)
		end
		currentlyDrawingLines = {}
	else
		startSegmentX, startSegmentY, startSegmentZ = getElementPosition(localPlayer)
	end
end
addEvent("legal.toggleLineModeClient", true)
addEventHandler("legal.toggleLineModeClient", root, toggleLineModeClient)

function loadAllLines(data)
	loadedServerLines = data
end
addEvent("legal.loadAllLines", true)
addEventHandler("legal.loadAllLines", root, loadAllLines)
