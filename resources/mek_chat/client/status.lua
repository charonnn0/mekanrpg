local bubbles = {}
local fontHeight = 22
local characteraddition = 50
local maxbubbles = 5
local selfVisible = true
local timeVisible = 5000
local distanceVisible = 7

function addText(source, text, color, font, sticky, type)
	if not bubbles[source] then
		bubbles[source] = {}
	end

	local tick = getTickCount()
	local info = {
		text = text,
		player = source,
		color = color or { 255, 255, 255 },
		tick = tick,
		expires = tick + (timeVisible + #text * characteraddition),
		alpha = 0,
		sticky = sticky,
		type = type,
		elementType = getElementType(source),
	}

	if sticky then
		table.insert(bubbles[source], 1, info)
	else
		table.insert(bubbles[source], info)
	end

	if #bubbles[source] > maxbubbles then
		for k, v in ipairs(bubbles[source]) do
			if not v.sticky then
				table.remove(bubbles[source], k)
				break
			end
		end
	end
end

addEvent("addChatBubble", true)
addEventHandler("addChatBubble", root, function(message, command)
	if source ~= localPlayer or selfVisible then
		if command == "ado" or command == "ame" then
			addText(
				source,
				message,
				command == "ame" and { 140, 122, 230 } or { 126, 199, 170 },
				"default-bold",
				false,
				command
			)
		else
			addText(source, message)
		end
	end
end)

addEvent("addPedChatBubble", true)
addEventHandler("addPedChatBubble", root, function(ped, message, command)
	if command == "ado" or command == "ame" then
		addText(ped, message, { 255, 51, 102 }, "default-bold", false, command)
	else
		addText(ped, message)
	end
end)

function removeTexts(player, type)
	local t = bubbles[player] or {}
	for i = #t, 1, -1 do
		if t[i].type == type then
			table.remove(t, i)
		end
	end

	if #t == 0 then
		bubbles[player] = nil
	end
end

addEventHandler("onClientElementDataChange", root, function(dataName)
	if dataName == "chat_status" and getElementType(source) == "player" then
		updateStatus(source, "status")
	end
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
	for _, player in ipairs(getElementsByType("player")) do
		if getElementData(player, "chat_status") then
			updateStatus(player, "status")
		end
	end
end)

function updateStatus(source, n)
	removeTexts(source, n)
	if getElementData(source, "chat_status") then
		addText(source, getElementData(source, "chat_status"), { 140, 122, 230 }, "default-bold", true, n)
	end
end

local pi = math.pi
function outElastic(t, b, c, d, a, p)
	if t == 0 then
		return b
	end

	t = t / d

	if t == 1 then
		return b + c
	end

	if not p then
		p = d * 0.3
	end

	local s

	if not a or a < math.abs(c) then
		a = c
		s = p / 4
	else
		s = p / (2 * pi) * math.asin(c / a)
	end

	return a * math.pow(2, -10 * t) * math.sin((t * d - s) * (2 * pi) / p) + c + b
end

local function fillStrToWidth(str, font, maxWidth)
	local strWidth = dxGetTextWidth(str, 1, font)
	maxWidth = maxWidth or 0

	if strWidth < maxWidth then
		return str
	end

	local strLen = #str

	local maxCharactersPerLine = math.floor(maxWidth / (strWidth / strLen)) - 2
	local newStr = ""
	local linesCount = 1

	for i = 1, strLen do
		newStr = newStr .. str:sub(i, i)

		if i % maxCharactersPerLine == 0 then
			newStr = newStr .. "\n"
			linesCount = linesCount + 1
		end
	end

	return newStr, linesCount
end

setTimer(function()
	if not localPlayer:getData("logged") then
		return
	end

	local tick = getTickCount()
	local x, y, z = getElementPosition(localPlayer)
	local cameraX, cameraY, cameraZ = getCameraMatrix()
	local fontRegular = "default-bold"

	for player, texts in pairs(bubbles) do
		if isElement(player) then
			for i, v in ipairs(texts) do
				if tick < v.expires or v.sticky then
					local elementType = v.elementType
					local px, py, pz = getElementPosition(player)
					local dim, pdim = getElementDimension(player), getElementDimension(localPlayer)
					local int, pint = getElementInterior(player), getElementInterior(localPlayer)
					local distance = getDistanceBetweenPoints3D(x, y, z, px, py, pz)
					local isClear =
						isLineOfSightClear(cameraX, cameraY, cameraZ, px, py, pz, true, true, true, true, true)

					if distance < distanceVisible and not isClear and pdim == dim and pint == int then
						v.alpha = v.alpha < 200 and v.alpha + 5 or v.alpha
						local bx, by, bz = getPedBonePosition(player, 0)
						local sx, sy = getScreenFromWorldPosition(bx, by, bz)

						if sx and sy then
							local textPosition = {
								x = sx,
								y = sy - (i * fontHeight),
							}

							local scale = 1.05 - (distance / 17)

							local str = fillStrToWidth(v.text, fontRegular, 200)

							dxDrawText(
								str,
								textPosition.x + 2,
								textPosition.y + 2,
								textPosition.x,
								textPosition.y,
								tocolor(0, 0, 0),
								scale,
								fontRegular,
								"center",
								"center",
								false,
								false,
								false
							)
							dxDrawText(
								str,
								textPosition.x,
								textPosition.y,
								textPosition.x,
								textPosition.y,
								tocolor(unpack(v.color)),
								scale,
								fontRegular,
								"center",
								"center",
								false,
								false,
								false
							)
						end
					end
				else
					table.remove(bubbles[player], i)
				end
			end

			if #texts == 0 then
				bubbles[player] = nil
			end
		else
			bubbles[player] = nil
		end
	end
end, 0, 0)

addEventHandler("onClientPlayerQuit", root, function()
	bubbles[source] = nil
end)
