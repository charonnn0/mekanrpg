Radar = {}
Radar.size = {}
Radar.miniMapVisible = true
Radar.bigMapVisible = false
Radar.renderPosition = localPlayer.position
Radar.lastDimensionPosition = localPlayer.position
Radar.customBlipOffset = 1
Radar.customBlipLimit = 15

Radar.zoneFont = dxCreateFont(":mek_ui/public/fonts/SweetSixteen.ttf", resp(20)) or "default"

local DRAW_POST_GUI = false

local blipFocusPosition

local WORLD_SIZE = 3072
local CHUNK_SIZE = 256
local CHUNKS_COUNT = 12
local SCALE_FACTOR = 1.5
local arrowSize = 24
local blipTextureSize = 24

local maskShader
local renderTarget
local maskTexture

local arrowTexture

local SCALE_ENABLED = true
local DEFAULT_SCALE = 2.2
local MAX_SPEED_SCALE = 0.2

local MAX_BLIP_DISTANCE = 300

local GROW_SPACING = 15

local GPS_LINE_WIDTH = 6

local hoveredHood

local scale = DEFAULT_SCALE
local fallbackTo2d = true
local camera
local chunkRenderSize

local customTextures = {}
local customRenderTargets = {}

chunksTextures = {}

local blipAnimations = {}

local lastClick = 0

local RADIO_BANNED_VEHICLE_TYPES = {
	["BMX"] = true,
	["Bike"] = true,
	["Quad"] = true,
}

local function rgbToHex(r, g, b)
	return string.format("#%.2X%.2X%.2X", r, g, b)
end

local function drawRadarChunk(x, y, chunkX, chunkY)
	local chunkID = chunkX + chunkY * CHUNKS_COUNT
	if chunkID < 0 or chunkID > 143 or chunkX >= CHUNKS_COUNT or chunkY >= CHUNKS_COUNT or chunkX < 0 or chunkY < 0 then
		return
	end

	local posX, posY =
		((x - chunkX * CHUNK_SIZE) / CHUNK_SIZE) * chunkRenderSize,
		((y - chunkY * CHUNK_SIZE) / CHUNK_SIZE) * chunkRenderSize
	dxDrawImage(width / 2 - posX, height / 2 - posY, chunkRenderSize, chunkRenderSize, chunksTextures[chunkID])
end

local function drawRadarSection(x, y)
	local chunkX = math.floor(x / CHUNK_SIZE)
	local chunkY = math.floor(y / CHUNK_SIZE)

	local chunkPerX = math.floor(width / CHUNK_SIZE * 4)
	local chunkPerY = math.floor(height / CHUNK_SIZE * 4)

	for i = -chunkPerX, chunkPerX do
		for j = -chunkPerY, chunkPerY do
			drawRadarChunk(x, y, chunkX + i, chunkY + j)
		end
	end
end

local function drawAnimatedBlip(blip, animate, x, y)
	local colors = animate.colors
	local duration = animate.duration

	local animationData = blipAnimations[blip]
	if not animationData then
		animationData = {
			start = getTickCount(),
		}
		blipAnimations[blip] = animationData
	end

	local progress = (getTickCount() - animationData.start) / duration
	if progress > (duration / 1000) then
		animationData.start = getTickCount()
		progress = 0
	end

	if blip.parent and blip.parent.dimension > 0 then
		return
	end

	local alpha = interpolateBetween(1, 0, 0, 0, 0, 0, progress, "InQuad")

	local r, g, b = colors.from[1], colors.from[2], colors.from[3]
	if getTickCount() % 1000 > 200 then
		r, g, b = colors.to[1], colors.to[2], colors.to[3]
	end

	local size = interpolateBetween(0, 0, 0, 42, 0, 0, progress, "Linear")

	size = math.floor(size)

	local imgX, imgY = Radar.getPositionFromRadar(x, y, size, size)
	if imgX and imgY then
		if size > 0 then
			drawRoundedRectangle({
				position = {
					x = imgX,
					y = imgY,
				},
				size = {
					x = size,
					y = size,
				},
				color = rgbToHex(r, g, b),
				alpha = alpha,
				radius = size / 2,
			})
		end

		dxDrawText(
			animate.icon,
			imgX,
			imgY,
			imgX + size,
			imgY + size,
			tocolor(r, g, b),
			0.4,
			fonts.icon,
			"center",
			"center"
		)
	end
end

local function drawWorldBlip(blip, worldText, x, y, z)
	local icon = worldText.icon
	local title = worldText.title
	local colors = worldText.colors
	local hasDistance = worldText.hasDistance

	local spriteX, spriteY = getScreenFromWorldPosition(x, y, z)
	if spriteX and spriteY then
		local r, g, b = colors.from[1], colors.from[2], colors.from[3]
		if getTickCount() % 1000 > 200 then
			r, g, b = colors.to[1], colors.to[2], colors.to[3]
		end

		local distance = getDistanceBetweenPoints3D(x, y, z, px, py, pz)
		local fontScale = WORLD_SIZE / distance * 0.1
		local iconScale = fontScale
		iconScale = math.min(iconScale, 0.7)
		iconScale = math.max(iconScale, 0.6)

		fontScale = math.min(fontScale, 0.6)
		fontScale = math.max(fontScale, 0.5)

		dxDrawText(
			icon,
			spriteX,
			spriteY,
			spriteX,
			spriteY,
			tocolor(r, g, b),
			iconScale,
			fonts.icon,
			"center",
			"center"
		)
		spriteY = spriteY + 35 * iconScale
		dxDrawText(
			title,
			spriteX + 1,
			spriteY + 1,
			spriteX,
			spriteY,
			tocolor(0, 0, 0),
			fontScale,
			fonts.BebasNeueBold.h1,
			"center",
			"center"
		)
		dxDrawText(
			title,
			spriteX,
			spriteY,
			spriteX,
			spriteY,
			tocolor(255, 255, 255),
			fontScale,
			fonts.BebasNeueBold.h1,
			"center",
			"center"
		)
		if hasDistance then
			spriteY = spriteY + 25 * fontScale
			dxDrawText(
				math.floor(distance) .. "mt",
				spriteX + 1,
				spriteY + 1,
				spriteX,
				spriteY,
				tocolor(0, 0, 0),
				fontScale,
				fonts.BebasNeueRegular.h2,
				"center",
				"center"
			)
			dxDrawText(
				math.floor(distance) .. "mt",
				spriteX,
				spriteY,
				spriteX,
				spriteY,
				tocolor(195, 195, 195),
				fontScale,
				fonts.BebasNeueRegular.h2,
				"center",
				"center"
			)
		end
	end
end

local function drawWorldBlips()
	for i, blip in ipairs(getElementsByType("blip")) do
		local parent = getElementAttachedTo(blip)
		if parent ~= localPlayer then
			local worldText = blip:getData("worldText")
			if worldText then
				local x, y, z = getElementPosition(blip)
				drawWorldBlip(blip, worldText, x, y, z)
			end
		end
	end
end

local function inAreaInRenderTarget(positionX, positionY, width, height)
	return inArea(x + positionX, y + positionY, width, height)
end

local function drawBlips(ignoreDistance)
	px, py, pz = getElementPosition(localPlayer)
	local blips = getElementsByType("blip")
	for i = 1, #blips do
		local blip = blips[i]
		local distance = getDistanceBetweenPoints3D(blip.position, px, py, pz)
		local shouldRender = distance < MAX_BLIP_DISTANCE or ignoreDistance
		if shouldRender then
			local animate = blip:getData("animate")
			local icon = blip:getData("icon") or blip.icon
			local color = { 255, 255, 255, 255 }

			if icon == 0 then
				color = { getBlipColor(blip) }
			end

			if animate then
				drawAnimatedBlip(blip, animate, blip.position.x, blip.position.y)
			else
				local imageX, imageY = Radar.drawImageOnMap(
					blip.position.x,
					blip.position.y,
					0,
					"public/images/blips/" .. icon .. ".png",
					blipTextureSize,
					blipTextureSize,
					tocolor(color[1], color[2], color[3], color[4]),
					not ignoreDistance
				)

				if Radar.bigMapVisible then
					local text = blip:getData("text")
					local hover = inAreaInRenderTarget(imageX, imageY, blipTextureSize, blipTextureSize)
					if hover and text then
						local textWidth = dxGetTextWidth(text, 1, fonts.UbuntuLight.body)

						drawTooltip({
							position = {
								x = x + imageX,
								y = y + imageY,
							},
							size = {
								x = textWidth + 20,
								y = 30,
							},

							radius = 4,
							text = text,

							align = "left",
							alignY = "top",
							hover = true,
						})
					end
				end
			end
		end
	end
end

local function drawGPS()
	if not gpsLines then
		return false
	end

	for i = 2, #gpsLines do
		if gpsLines[i - 1] then
			local startX = gpsLines[i][1]
			local startY = gpsLines[i][2]
			local endX = gpsLines[i - 1][1]
			local endY = gpsLines[i - 1][2]

			local lineStartX, lineStartY =
				Radar.getPositionFromRadar(startX, startY, GPS_LINE_WIDTH, GPS_LINE_WIDTH, true)
			local lineEndX, lineEndY = Radar.getPositionFromRadar(endX, endY, GPS_LINE_WIDTH, GPS_LINE_WIDTH, true)

			if lineStartX and lineStartY and lineEndX and lineEndY then
				dxDrawLine(lineStartX, lineStartY, lineEndX, lineEndY, tocolor(140, 122, 230), GPS_LINE_WIDTH)
			end
		end
	end
end

local function drawRadar(ignoreDistance)
	local x = (Radar.renderPosition.x + 3000) / 6000 * WORLD_SIZE
	local y = (-Radar.renderPosition.y + 3000) / 6000 * WORLD_SIZE

	dxDrawRectangle(0, 0, width, height, tocolor(103, 135, 167, 255))

	drawRadarSection(x, y)

	drawBlips(ignoreDistance)
	drawGPS()

	if Radar.bigMapVisible then
		dxDrawImage(0, 0, width, height, ":mek_ui/public/images/vignette.png")
	end

	Radar.drawImageOnMap(
		localPlayer.position.x,
		localPlayer.position.y,
		localPlayer.rotation.z,
		arrowTexture,
		arrowSize,
		arrowSize,
		tocolor(255, 255, 255, 255),
		true
	)
end

function setRadarInteriorPosition(x, y, z)
	Radar.lastDimensionPosition = { x = x, y = y, z = z }
end

function Radar.start()
	if renderTarget then
		return false
	end

	Radar.size = {
		x = math.floor(resp(350)),
		y = math.floor(resp(225)),
	}

	width, height = Radar.size.x, Radar.size.y

	renderTarget = dxCreateRenderTarget(width, height, true)
	maskShader = exports.mek_assets:createShader("mask3d.fx")
	fallbackTo2d = false

	if not (renderTarget and maskShader) then
		fallbackTo2d = true
		outputDebugString("Radar: Failed to create renderTarget or shader")
		return
	end

	for i = 0, 143 do
		chunksTextures[i] = dxCreateTexture("public/images/map/radar" .. i .. ".png", "dxt3", true, "clamp")
	end

	camera = getCamera()
	arrowTexture = DxTexture("public/images/arrow.png")
	Radar.bigSectionText = "Kendi yerinize dönmek için 'SPACE' tuşuna basın."
	Radar.bigSectionTextWidth = dxGetTextWidth(Radar.bigSectionText, 1, fonts.UbuntuLight.body) + 20
end

function getRadarPosition()
	local width, height = Radar.size.x, Radar.size.y
	local x, y = 20, screenSize.y - height - 20
	return x, y, width, height
end

function setVisible(visible)
	Radar.miniMapVisible = visible
end

function isBigMapEnabled()
	return Radar.bigMapVisible
end

function renderSection(name, position, size, enableBigMap, customPosition)
	texture = customTextures[name]
	sectionRenderTarget = customRenderTargets[name]
	if not texture then
		texture = svgCreateRoundedRectangle(size.x, size.y, 0, tocolor(255, 255, 255))
		customTextures[name] = texture
	end

	if customPosition or enableBigMap then
		Radar.renderPosition = customPosition or localPlayer.position

		if blipFocusPosition then
			Radar.renderPosition = {
				x = blipFocusPosition[1],
				y = blipFocusPosition[2],
				z = blipFocusPosition[3],
			}
		end
	else
		Radar.renderPosition = blipFocusPosition or localPlayer.position
		mapMovedPos = nil
	end

	if not Radar.bigMapVisible then
		scale = 1
		SCALE_FACTOR = 1
		chunkRenderSize = CHUNK_SIZE
	end

	Radar.bigMapVisible = enableBigMap

	local containerSize = {
		x = 230,
		y = 30,
	}

	if getKeyState("mouse1") and enableBigMap and not customPosition then
		local cursorX, cursorY = getCursorPosition()
		cursorX = cursorX * screenSize.x
		cursorY = cursorY * screenSize.y

		if inArea(position.x, position.y, size.x - containerSize.x, size.y) then
			if not lastCursorPos then
				lastCursorPos = { cursorX, cursorY }
			end

			if not mapDifferencePos then
				mapDifferencePos = { 0, 0 }
			end

			if not lastDifferencePos then
				if not mapMovedPos then
					lastDifferencePos = { 0, 0 }
				else
					lastDifferencePos = { mapMovedPos[1], mapMovedPos[2] }
				end
			end

			mapDifferencePos =
				{ mapDifferencePos[1] + cursorX - lastCursorPos[1], mapDifferencePos[2] + cursorY - lastCursorPos[2] }

			if not mapMovedPos then
				if math.abs(mapDifferencePos[1]) >= 3 or math.abs(mapDifferencePos[2]) >= 3 then
					mapMovedPos =
						{ lastDifferencePos[1] - mapDifferencePos[1], lastDifferencePos[2] + mapDifferencePos[2] }
				end
			elseif mapDifferencePos[1] ~= 0 or mapDifferencePos[2] ~= 0 then
				mapMovedPos = { lastDifferencePos[1] - mapDifferencePos[1], lastDifferencePos[2] + mapDifferencePos[2] }
			end

			lastCursorPos = { cursorX, cursorY }
		end
	else
		if mapMovedPos then
			lastDifferencePos = { mapMovedPos[1], mapMovedPos[2] }
		end

		lastCursorPos = false
		mapDifferencePos = false
	end

	x, y = position.x, position.y
	if mapMovedPos then
		Radar.renderPosition.x = Radar.renderPosition.x + mapMovedPos[1]
		Radar.renderPosition.y = Radar.renderPosition.y + mapMovedPos[2]
	end

	if mapMovedPos or blipFocusPosition then
		if getKeyState("space") and lastClick + 200 <= getTickCount() then
			lastClick = getTickCount()
			mapMovedPos = nil
			lastDifferencePos = nil
			blipFocusPosition = nil

			scale = 1
			SCALE_FACTOR = 1
			chunkRenderSize = CHUNK_SIZE
		end
	end

	width, height = size.x, size.y

	maskShader:setValue("sMaskTexture", texture)

	if not sectionRenderTarget then
		sectionRenderTarget = dxCreateRenderTarget(width, height, true)
		customRenderTargets[name] = sectionRenderTarget
	end

	dxSetRenderTarget(sectionRenderTarget, true)
	drawRadar(true)
	dxSetRenderTarget()
	drawWorldBlips()

	maskShader:setValue("sPicTexture", sectionRenderTarget)

	dxDrawImage(position.x, position.y, width, height, maskShader, 0, 0, 0, tocolor(255, 255, 255, 255), DRAW_POST_GUI)

	if gpsRoute then
		renderNavigation(position.x, position.y + height - 60, width, 50)
	end

	if Radar.bigMapVisible and isCursorShowing() and inArea(x, y, width, height) then
		local cursorX, cursorY = getCursorPosition()
		cursorX = cursorX * screenSize.x
		cursorY = cursorY * screenSize.y

		if getKeyState("mouse2") and lastClick + 200 <= getTickCount() then
			lastClick = getTickCount()
			local mapX, mapY = cursorX - x, cursorY - y
			local worldPositionX, worldPositionY = Radar.getWorldPositionFromRadar(mapX, mapY)

			if not Radar.ZoneEditor.Enabled then
				occupiedVehicle = localPlayer.vehicle or localPlayer
				if gpsRoute then
					endRoute()
				else
					makeRoute(worldPositionX, worldPositionY)
				end
			else
				table.insert(Radar.ZoneEditor.Positions, worldPositionX)
				table.insert(Radar.ZoneEditor.Positions, worldPositionY)
				table.insert(Radar.ZoneEditor.RealPositions, { worldPositionX, worldPositionY })
			end
		end
	end

	if Radar.bigMapVisible and not customPosition and name ~= "hood_map" then
		local zoneName =
			exports.mek_global:getZoneName(Radar.renderPosition.x, Radar.renderPosition.y, Radar.renderPosition.z)
		dxDrawText(
			zoneName,
			x - 19,
			y - 19,
			x + width - 19,
			y + height - 19,
			rgba(theme.GRAY[900]),
			1,
			Radar.zoneFont,
			"right",
			"bottom"
		)
		dxDrawText(
			zoneName,
			x - 20,
			y - 20,
			x + width - 20,
			y + height - 20,
			rgba(theme.GRAY[50]),
			1,
			Radar.zoneFont,
			"right",
			"bottom"
		)

		hoverBlipList = inArea(x + width - 230, y + 5, 230, height)

		local counter = 0
		for i = Radar.customBlipOffset, Radar.customBlipOffset + Radar.customBlipLimit do
			local row = detailLocations[i]
			if row then
				counter = counter + 1
				local text = row.text
				local icon = row.icon

				local iconSrc = "public/images/blips/" .. icon .. ".png"

				local containerPosition = {
					x = x + width - containerSize.x - 5,
					y = y + 5 + ((counter - 1) * containerSize.y),
				}
				local hover = inArea(containerPosition.x, containerPosition.y, containerSize.x, containerSize.y)

				dxDrawRectangle(
					containerPosition.x,
					containerPosition.y,
					containerSize.x,
					containerSize.y,
					rgba(theme.GRAY[hover and 700 or i % 2 == 0 and 800 or 900]),
					DRAW_POST_GUI
				)
				dxDrawImage(
					containerPosition.x + 6,
					containerPosition.y + 4,
					containerSize.y - 8,
					containerSize.y - 8,
					iconSrc,
					0,
					0,
					0,
					tocolor(255, 255, 255, 255),
					DRAW_POST_GUI
				)

				dxDrawText(
					text,
					containerPosition.x + containerSize.y + 10,
					containerPosition.y,
					containerPosition.x + containerSize.x,
					containerPosition.y + containerSize.y,
					rgba(theme.GRAY[50]),
					1,
					fonts.UbuntuLight.caption,
					"left",
					"center"
				)

				if hover and isKeyPressed("mouse1") then
					local x, y, z = row.position[1], row.position[2], row.position[3]
					occupiedVehicle = localPlayer.vehicle or localPlayer
					endRoute()
					makeRoute(x, y)
					exports.mek_infobox:addBox("info", "Yol tarifi oluşturuldu.")

					mapMovedPos = nil
					lastCursorPos = false
					mapDifferencePos = false
					lastDifferencePos = false

					blipFocusPosition = row.position
				end
			end
		end

		if gpsRoute then
			local resetGPSPosition = {
				x = x + width - containerSize.x - 5,
				y = y + 5 + ((counter - 1) * containerSize.y) + containerSize.y + 5,
			}

			local resetButton = drawButton({
				position = resetGPSPosition,
				size = containerSize,

				variant = "soft",
				color = "gray",
				disabled = false,

				text = "GPS Sıfırla",
			})

			if resetButton.pressed then
				endRoute()
			end
		end

		if mapMovedPos or blipFocusPosition then
			local infoSectionSize = {
				x = Radar.bigSectionTextWidth,
				y = 30,
			}

			local infoSectionPosition = {
				x = position.x + size.x / 2 - infoSectionSize.x / 2,
				y = position.y + size.y - infoSectionSize.y - 10,
			}

			dxDrawRectangle(
				infoSectionPosition.x,
				infoSectionPosition.y,
				infoSectionSize.x,
				infoSectionSize.y,
				rgba(theme.GRAY[900]),
				DRAW_POST_GUI
			)
			dxDrawText(
				Radar.bigSectionText,
				infoSectionPosition.x,
				infoSectionPosition.y,
				infoSectionPosition.x + infoSectionSize.x,
				infoSectionPosition.y + infoSectionSize.y,
				rgba(theme.GRAY[50]),
				1,
				fonts.UbuntuLight.body,
				"center",
				"center"
			)
		end
	end
end

local maskTexturePath = "public/images/radar_texture.png"
local isMaskTextureCreated = false

function Radar.render()
	if
		not exports.mek_settings:getPlayerSetting(localPlayer, "hud_visible") or exports.mek_hud:isNativeRadarVisible()
	then
		Radar.miniMapVisible = false
		return
	end

	local isOutside = localPlayer.interior == 0 and localPlayer.dimension == 0
	if isOutside then
		if Radar.bigMapVisible then
			if Radar.miniMapVisible then
				Radar.miniMapVisible = false
			end
		else
			if not Radar.miniMapVisible then
				Radar.miniMapVisible = true
			end
		end
	else
		if Radar.miniMapVisible then
			Radar.miniMapVisible = false
		end
		if Radar.bigMapVisible then
			Radar.bigMapVisible = false
		end
	end

	if not Radar.miniMapVisible then
		return false
	end

	fonts = fonts or useFonts()
	theme = theme or useTheme()

	width, height = Radar.size.x, Radar.size.y
	local x, y = 20, screenSize.y - height - 20

	if Radar.bigMapVisible then
		SCALE_FACTOR = 1.5
		scale = DEFAULT_SCALE
		Radar.bigMapVisible = false
	end

	Radar.renderPosition = localPlayer.dimension > 0 and Radar.lastDimensionPosition or localPlayer.position

	chunkRenderSize = SCALE_ENABLED and (CHUNK_SIZE * scale / SCALE_FACTOR) or CHUNK_SIZE

	if not isMaskTextureCreated then
		maskTexture = dxCreateTexture(maskTexturePath, "dxt3", true, "clamp")
		maskShader:setValue("gUVRotCenter", 0.5, 0.5)
		maskShader:setValue("gUVPosition", 0, 0)
		maskShader:setValue("gUVScale", 1, 1)
		maskShader:setValue("gUVRotAngle", 0)
		maskShader:setValue("sMaskTexture", maskTexture)

		isMaskTextureCreated = true
	end

	if not fallbackTo2d then
		dxSetRenderTarget(renderTarget, true)
		drawRadar()
		dxSetRenderTarget()
		drawWorldBlips()

		maskShader:setValue("sPicTexture", renderTarget)

		dxDrawImage(x, y, width, height, maskShader, 0, 0, 0, tocolor(255, 255, 255, 255), DRAW_POST_GUI)

		if gpsLines then
			local navigationX = x
			local navigationWidth = width

			if localPlayer.vehicle and isElement(localPlayer.vehicle) then
				if
					localPlayer.vehicle:getData("vehicle_radio") >= 0
					and not RADIO_BANNED_VEHICLE_TYPES[localPlayer.vehicle.vehicleType]
				then
					navigationX = navigationX + exports.mek_radio:getRadioDisplayWidth() + 10
					navigationWidth = 50
				end
			end

			renderNavigation(navigationX, y - 60, navigationWidth, 50)
		end

		local zoneName =
			exports.mek_global:getZoneName(Radar.renderPosition.x, Radar.renderPosition.y, Radar.renderPosition.z)

		local percentSizeX = width / 2
		local percentSizeY = 15
		local percentPositionX = x
		local percentPositionY = y + height - percentSizeY

		local healthFactor = localPlayer.health / 100
		local healthWidth = percentSizeX * healthFactor

		local armorFactor = localPlayer.armor / 100
		local armorWidth = percentSizeX * armorFactor
		local armorX = x + percentSizeX

		local lineColor = rgba(theme.GRAY[900])

		dxDrawImage(
			x,
			y,
			width,
			height,
			":mek_ui/public/images/vignette.png",
			0,
			0,
			0,
			tocolor(255, 255, 255, 255),
			DRAW_POST_GUI
		)

		dxDrawRectangle(percentPositionX, percentPositionY, width, percentSizeY, lineColor, DRAW_POST_GUI)
		dxDrawRectangle(
			percentPositionX,
			percentPositionY,
			percentSizeX,
			percentSizeY,
			rgba("#418e5a", 0.6),
			DRAW_POST_GUI
		)
		dxDrawRectangle(
			percentPositionX,
			percentPositionY,
			healthWidth,
			percentSizeY,
			rgba("#418e5a", 1),
			DRAW_POST_GUI
		)

		dxDrawRectangle(armorX, percentPositionY, percentSizeX, percentSizeY, rgba("#248095", 0.6), DRAW_POST_GUI)
		dxDrawRectangle(armorX, percentPositionY, armorWidth, percentSizeY, rgba("#248095", 1), DRAW_POST_GUI)

		dxDrawRectangle(percentPositionX, percentPositionY, width, 2, lineColor, DRAW_POST_GUI)
		dxDrawRectangle(percentPositionX, percentPositionY + percentSizeY - 2, width, 2, lineColor, DRAW_POST_GUI)
		dxDrawRectangle(percentPositionX, percentPositionY, 2, percentSizeY, lineColor, DRAW_POST_GUI)
		dxDrawRectangle(
			percentPositionX + percentSizeX - 2,
			percentPositionY,
			2,
			percentSizeY,
			lineColor,
			DRAW_POST_GUI
		)
		dxDrawRectangle(
			percentPositionX + percentSizeX * 2 - 2,
			percentPositionY,
			2,
			percentSizeY,
			lineColor,
			DRAW_POST_GUI
		)

		dxDrawText(
			zoneName,
			x - 19,
			y - 19,
			x + width - 19,
			y + height - 19,
			rgba(theme.GRAY[900]),
			1,
			Radar.zoneFont,
			"right",
			"bottom"
		)
		dxDrawText(
			zoneName,
			x - 20,
			y - 20,
			x + width - 20,
			y + height - 20,
			rgba(theme.GRAY[50]),
			1,
			Radar.zoneFont,
			"right",
			"bottom"
		)

		if gpsRoute then
			dxDrawText(
				gpsSoundMuted and "" or "",
				x - 10,
				y + 10,
				x + width - 10,
				y + height + 10,
				rgba(theme.GRAY[50]),
				0.5,
				fonts.icon,
				"right",
				"top"
			)

			if inArea(x - 10, y + 10, x + width - 10, y + height + 10) then
				if getKeyState("mouse1") and lastClick + 500 <= getTickCount() then
					lastClick = getTickCount()
					gpsSoundMuted = not gpsSoundMuted
				end
			end
		end
	end
end

function Radar.setRotation(x, y, z)
	if not x or not y then
		return false
	end
	if not z then
		z = 0
	end
	if not maskShader then
		return false
	end
	dxSetShaderTransform(maskShader, x, y, z)
end

function Radar.setVisible(visible)
	Radar.miniMapVisible = not not visible
end

function isMiniMapVisible()
	return Radar.miniMapVisible
end

function Radar.drawImageOnMap(globalX, globalY, rotationZ, image, imgWidth, imgHeight, color, shouldInBox)
	if not image then
		return
	end
	if not color then
		color = tocolor(255, 255, 255)
	end
	local relativeX, relativeY = Radar.renderPosition.x - globalX, Radar.renderPosition.y - globalY
	local mapX, mapY =
		relativeX / 6000 * WORLD_SIZE * scale / SCALE_FACTOR, relativeY / 6000 * WORLD_SIZE * scale / SCALE_FACTOR

	local distance = mapX * mapX + mapY * mapY
	if distance > chunkRenderSize * chunkRenderSize * 9 and shouldInBox then
		return
	end

	if not shouldInBox then
		x = math.min(x, width - GROW_SPACING)
		x = math.max(x, GROW_SPACING)

		y = math.min(y, height - GROW_SPACING)
		y = math.max(y, GROW_SPACING)
	end

	dxDrawImage(
		(width - imgWidth) / 2 - mapX,
		(height - imgHeight) / 2 + mapY,
		imgWidth,
		imgHeight,
		image,
		-rotationZ,
		0,
		0,
		color
	)

	return (width - imgWidth) / 2 - mapX, (height - imgHeight) / 2 + mapY, imgWidth, imgHeight
end

function Radar.getWorldPositionFromRadar(screenX, screenY)
	local mapX, mapY = screenX - width / 2, screenY - height / 2
	local relativeX, relativeY =
		mapX * 6000 / WORLD_SIZE * SCALE_FACTOR / scale, mapY * 6000 / WORLD_SIZE * SCALE_FACTOR / scale

	local worldX, worldY = Radar.renderPosition.x + relativeX, Radar.renderPosition.y - relativeY

	return worldX, worldY
end

function Radar.getPositionFromRadar(globalX, globalY, imgWidth, imgHeight, shouldInBox)
	local relativeX, relativeY = Radar.renderPosition.x - globalX, Radar.renderPosition.y - globalY

	local mapX, mapY =
		relativeX / 6000 * WORLD_SIZE * scale / SCALE_FACTOR, relativeY / 6000 * WORLD_SIZE * scale / SCALE_FACTOR

	local distance = mapX * mapX + mapY * mapY
	if distance > chunkRenderSize * chunkRenderSize * 9 then
		return
	end

	local x = (width - imgWidth) / 2 - mapX
	local y = (height - imgHeight) / 2 + mapY

	if not shouldInBox then
		X = math.min(x, width - GROW_SPACING)
		x = math.max(X, GROW_SPACING)

		Y = math.min(y, height - GROW_SPACING)
		y = math.max(Y, GROW_SPACING)
	end

	return x, y
end

addEventHandler("onClientResourceStart", resourceRoot, function()
	if localPlayer:getData("logged") then
		Radar.start()
		if not isTimer(renderMiniMapRender) then
			renderMiniMapRender = setTimer(Radar.render, 0, 0)
		end
	end
end)

addEventHandler("onClientElementDataChange", localPlayer, function(dataName, _, value)
	if dataName == "logged" then
		if value then
			Radar.start()
			if not isTimer(renderMiniMapRender) then
				renderMiniMapRender = setTimer(Radar.render, 0, 0)
			end
		else
			if isTimer(renderMiniMapRender) then
				killTimer(renderMiniMapRender)
			end
		end
	end
end)

addEventHandler("onClientKey", root, function(button, state)
	if not state then
		return
	end

	if not Radar.bigMapVisible then
		return
	end

	if button == "mouse_wheel_down" then
		if hoverBlipList then
			Radar.customBlipOffset = Radar.customBlipOffset + 1

			if Radar.customBlipOffset > #detailLocations - Radar.customBlipLimit then
				Radar.customBlipOffset = #detailLocations - Radar.customBlipLimit
			end
		else
			scale = scale - 0.1
			if scale <= 0.5 then
				scale = 0.5
			end

			chunkRenderSize = CHUNK_SIZE * scale / SCALE_FACTOR
		end

		return
	elseif button == "mouse_wheel_up" then
		if hoverBlipList then
			Radar.customBlipOffset = Radar.customBlipOffset - 1

			if Radar.customBlipOffset <= 1 then
				Radar.customBlipOffset = 1
			end
		else
			scale = scale + 0.1
			if scale >= 3 then
				scale = 3
			end

			chunkRenderSize = CHUNK_SIZE * scale / SCALE_FACTOR
		end

		return
	end
end)

function svgCreateRoundedRectangle(width, height, ratio, color1, borderWidth, color2)
	local r, g, b, a =
		bitExtract(color1, 16, 8), bitExtract(color1, 8, 8), bitExtract(color1, 0, 8), bitExtract(color1, 24, 8)
	local _color1 = string.format("#%.2X%.2X%.2X", r, g, b)

	local r2, g2, b2, a2 =
		bitExtract((color2 or color1), 16, 8),
		bitExtract((color2 or color1), 8, 8),
		bitExtract((color2 or color1), 0, 8),
		bitExtract((color2 or color1), 24, 8)
	local _color2 = string.format("#%.2X%.2X%.2X", r2, g2, b2)

	local rawSvgData = [[
	    <svg width="]] .. (width + 0.5) .. [[" height="]] .. (height + 0.5) .. [[">
		  	<rect x="0.5" y="0.5" rx="]] .. ratio .. [[" ry="]] .. ratio .. [[" width="]] .. (width - 0.5) .. [[" height="]] .. (height - 0.5) .. [["
		  	fill="]] .. _color1 .. [[" stroke="]] .. _color2 .. [[" stroke-width="]] .. (borderWidth or 0) .. [[" stroke-opacity="]] .. (a2 / 255) .. [[" opacity="]] .. (a / 255) .. [[" />
		</svg>
	]]

	return svgCreate(width, height, rawSvgData)
end
