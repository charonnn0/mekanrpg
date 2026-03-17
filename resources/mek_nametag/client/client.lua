local cache = {}

local theme = useTheme()
local fonts = useFonts()

local font = "default-bold"

local maxTagsPerLine = 6
local tagsThisLine = 0
local tagSize = 32

local postGUI = false

local settings = {
	font = 1,
	type = 1,
	id = 1,
	border = 1,
	tag = 1,
	placement = 1,
	color = 1,
}

local function updateFont()
	if settings.font == 1 then
		font = "default-bold"
	elseif settings.font == 2 then
		font = fonts.SFUIRegular.body
	elseif settings.font == 3 then
		font = fonts.SFUIBold.body
	elseif settings.font == 4 then
		font = "default"
	end
end
updateFont()

setTimer(function()
	if
		getElementData(localPlayer, "logged")
		and not minimizeAFK
		and exports.mek_settings:getPlayerSetting(localPlayer, "nametag_visible")
	then
		local cameraX, cameraY, cameraZ = getElementPosition(localPlayer)
		for player, data in pairs(cache) do
			if isElement(player) then
				local boneX, boneY, boneZ = 0, 0, 0

				if settings.placement == 1 then
					boneX, boneY, boneZ = getPedBonePosition(player, 6)
					boneZ = boneZ + 0.14
				else
					boneX, boneY, boneZ = getElementPosition(player)
					boneZ = boneZ + 0.94
				end

				local distance = math.sqrt((cameraX - boneX) ^ 2 + (cameraY - boneY) ^ 2 + (cameraZ - boneZ) ^ 2)
				local alpha = distance >= 20 and math.max(0, 255 - (distance * 7)) or 255

				if
					(
						isElementOnScreen(player)
						and getElementAlpha(player) >= 200
						and (aimsAt(player) or distance <= 30)
						and isLineOfSightClear(
							cameraX,
							cameraY,
							cameraZ,
							boneX,
							boneY,
							boneZ,
							true,
							false,
							false,
							true,
							false,
							false,
							false,
							localPlayer
						)
					) or (exports.mek_freecam:isEnabled(localPlayer) and distance <= 500)
				then
					local screenX, screenY = getScreenFromWorldPosition(boneX, boneY, boneZ)
					if screenX and screenY then
						local text = ""
						local lineY = 0
						local sectionY = 0

						local name = (data.name):gsub("_", " ") .. " (" .. data.id .. ")"
						local displayName = name
						if data.tinted or data.mask or settings.id == 2 then
							name = (data.name):gsub("_", " ")
							displayName = name
						end

						-- displayName remains plain; we'll prefix [RK] with red and then reset color at draw time

						local r, g, b = data.nametagColor.r, data.nametagColor.g, data.nametagColor.b

						if aimsAt(player) or exports.mek_freecam:isEnabled(localPlayer) then
							alpha = 255
						end

						if settings.tag == 1 then
							local tags = data.tags
							local totalTags = #tags
							local expectedTags = math.min(totalTags, maxTagsPerLine)
							local tagW, tagH = 38, 38
							local xPos, yPos = 2, -10
							local tagsThisLine = 0
							local tagOffset = tagW * expectedTags

							local totalLines = math.ceil(totalTags / maxTagsPerLine)

							if totalLines > 1 then
								local lineOffset = 0
								if (settings.font == 1) or (settings.font == 4) then
									lineOffset = 26
								elseif (settings.font == 2) or (settings.font == 3) then
									lineOffset = 27
								end

								lineY = lineY + (lineOffset * (totalLines - 1))
								sectionY = sectionY + (lineOffset * (totalLines - 1))
							end

							for index, value in ipairs(tags) do
								local fixY = 0
								if settings.type == 1 then
									fixY = 1
								elseif settings.type == 2 then
									fixY = 3
									if (settings.font == 2) or (settings.font == 3) then
										fixY = fixY + 1
									end
								end

								dxDrawImage(
									screenX + xPos - tagW - tagOffset / 2 + 37,
									screenY + yPos + fixY - sectionY - 23,
									tagW - 2,
									tagH - 2,
									"public/images/" .. value .. ".png",
									0,
									0,
									0,
									tocolor(255, 255, 255, alpha),
									postGUI
								)

								tagsThisLine = tagsThisLine + 1
								if tagsThisLine == expectedTags then
									expectedTags = math.min(#tags - index, maxTagsPerLine)
									tagOffset = tagW * expectedTags
									tagsThisLine = 0
									xPos = 0
									yPos = yPos + tagH
								else
									xPos = xPos + tagW
								end
							end

							if totalTags > 0 then
								lineY = lineY + 33
								if (settings.font == 1) or (settings.font == 4) then
									sectionY = sectionY + 33
								elseif (settings.font == 2) or (settings.font == 3) then
									sectionY = sectionY + 34
								end
							end
						end

						if data.afk then
							text = text .. "\n#f0801d[AFK]"
						end

						if data.dead then
							text = text .. "\n#cd403b[Baygın]"
						end

						-- if data.injury then
							-- text = text .. "\n#cd403b[Yaralı]"
						-- end

						if data.cked then
							text = text .. "\n#cd403b[Ölü]"
						end

						if data.adminJailed then
							text = text .. "\n#434343[OOC Hapisde]"
						end

						if data.dragged then
							text = text .. "\n#9c27b0[Sürüklüyor]"
						end

						if data.isDragged then
							text = text .. "\n#9c27b0[Sürükleniyor]"
						end

						if data.badge then
							text = text .. "\n" .. RGBToHex(r, g, b) .. data.badge
						end

						local nameColor = RGBToHex(r, g, b)
						local nameLine = nameColor .. displayName
						if data.rk then
							nameLine = "#cd403b[RK] " .. nameColor .. displayName
						end
						text = text .. "\n" .. nameLine

						if settings.type == 1 and not data.tinted then
							local padding = 16
							local width, height = 50, 8
							local screenY = screenY - padding + 3

							local armor = getPedArmor(player)
							if armor > 0 then
								dxDrawRectangle(
									screenX - width / 2,
									screenY - lineY,
									width,
									height,
									tocolor(0, 0, 0, alpha),
									postGUI
								)
								dxDrawRectangle(
									screenX - width / 2 + 1,
									screenY - lineY + 1,
									(width - 2),
									height - 2,
									tocolor(200, 200, 200, math.min(50, alpha)),
									postGUI
								)
								dxDrawRectangle(
									screenX - width / 2 + 1,
									screenY - lineY + 1,
									(width - 2) * armor / 100,
									height - 2,
									tocolor(200, 200, 200, alpha),
									postGUI
								)
								lineY = lineY + (height + 1)

								if (settings.font == 1) or (settings.font == 4) then
									sectionY = sectionY + 9
								elseif (settings.font == 2) or (settings.font == 3) then
									sectionY = sectionY + 10
								end
							end

							local color = getHealthColor(2, player)
							local colorR, colorG, colorB, colorA = rgbaUnpack(color)

							dxDrawRectangle(
								screenX - width / 2,
								screenY - lineY,
								width,
								height,
								tocolor(0, 0, 0, math.min(230, alpha)),
								postGUI
							)
							dxDrawRectangle(
								screenX - width / 2 + 1,
								screenY - lineY + 1,
								(width - 2),
								height - 2,
								tocolor(colorR, colorG, colorB, math.min(100, alpha)),
								postGUI
							)
							dxDrawRectangle(
								screenX - width / 2 + 1,
								screenY - lineY + 1,
								(width - 2) * getElementHealth(player) / 100,
								height - 2,
								tocolor(colorR, colorG, colorB, alpha),
								postGUI
							)

							if (settings.font == 1) or (settings.font == 4) then
								lineY = lineY + 16
							elseif (settings.font == 2) or (settings.font == 3) then
								lineY = lineY + 17
							end
						elseif settings.type == 2 and not data.tinted then
							text = text
								.. "\n#FFFFFFHP: "
								.. getHealthColor(1, player)
								.. math.floor(getElementHealth(player))
								.. "%"

							if getPedArmor(player) > 0 then
								text = text .. "\n#FFFFFFZırh:#999999 " .. math.floor(getPedArmor(player)) .. "%"

								if (settings.font == 1) or (settings.font == 4) then
									sectionY = sectionY + 15
								elseif (settings.font == 2) or (settings.font == 3) then
									sectionY = sectionY + 16
								end
							end
						elseif settings.type == 3 or data.tinted then
							if (settings.font == 1) or (settings.font == 4) then
								lineY = lineY + 5
								sectionY = sectionY - 10
							elseif (settings.font == 2) or (settings.font == 3) then
								lineY = lineY + 6
								sectionY = sectionY - 11
							end
						end

						if settings.border == 1 then
							dxDrawBorderText(
								text,
								screenX,
								0,
								screenX,
								screenY - lineY,
								tocolor(255, 255, 255, alpha),
								1,
								font,
								"center",
								"bottom",
								false,
								true,
								postGUI,
								true
							)
						elseif settings.border == 2 then
							dxDrawText(
								text:gsub("#%x%x%x%x%x%x", ""),
								screenX + 1,
								1,
								screenX + 1,
								screenY - lineY + 1,
								tocolor(0, 0, 0, alpha),
								1,
								font,
								"center",
								"bottom",
								false,
								true,
								postGUI,
								true
							)
							dxDrawText(
								text,
								screenX,
								0,
								screenX,
								screenY - lineY,
								tocolor(255, 255, 255, alpha),
								1,
								font,
								"center",
								"bottom",
								false,
								true,
								postGUI,
								true
							)
						elseif settings.border == 3 then
							dxDrawText(
								text,
								screenX,
								0,
								screenX,
								screenY - lineY,
								tocolor(255, 255, 255, alpha),
								1,
								font,
								"center",
								"bottom",
								false,
								true,
								postGUI,
								true
							)
						end

						if (settings.font == 2) or (settings.font == 3) then
							sectionY = sectionY + 1
						end

						local textW = dxGetTextWidth(text:gsub("#%x%x%x%x%x%x", ""), scale, font) / 2
						local leftSectionX = 0

						if data.donater > 0 then
							dxDrawImage(
								screenX - textW - 31 - leftSectionX,
								screenY - sectionY - 37,
								23,
								23,
								"public/images/donaters/" .. data.donater .. ".png",
								0,
								0,
								0,
								tocolor(255, 255, 255, alpha),
								postGUI
							)
							leftSectionX = leftSectionX + 26
						end

						if data.talking then
							dxDrawImage(
								screenX - textW - 35 - leftSectionX,
								screenY - sectionY - 36,
								24,
								24,
								"public/images/microphone.png",
								0,
								0,
								0,
								tocolor(255, 255, 255, alpha),
								postGUI
							)
						end

						if data.writing then
							dxDrawImage(
								screenX + textW + 10,
								screenY - sectionY - 36,
								24,
								24,
								"public/images/writing.png",
								0,
								0,
								0,
								tocolor(255, 255, 255, alpha),
								postGUI
							)
						end
					end
				end
			end
		end
	end
end, 0, 0)

function createCache(player)
	if not isElement(player) then
		return
	end

	if not localPlayer:getData("logged") then
		return
	end

	if not player:getData("logged") then
		return
	end

	local tags = {}
	local tinted = false
	local badge = nil
	local name = player:getName()
	local r, g, b = player:getNametagColor()

	if player:getData("duty_admin") and player:getData("admin_level") > 0 then
		table.insert(tags, "admins/" .. player:getData("admin_level"))

		if player:getData("manager_level") > 0 then
			--table.insert(tags, "admins/manager")
		end
	end

	local vehicle = getPedOccupiedVehicle(player)
	local windows = vehicle and vehicle:getData("windows")

	if vehicle and not windows and vehicle ~= getPedOccupiedVehicle(localPlayer) and vehicle:getData("tinted") then
		name = "Gizli (Cam Filmi) [>" .. (player:getData("dbid")) .. "]"
		tinted = true
	end

	if not tinted then
		local duty = player:getData("duty") or 0

		if player:getData("mask") then
			name = "Gizli [>" .. (player:getData("dbid")) .. "]"
		end

		if player:getData("badge") then
			badge = player:getData("badge").itemValue
		end

		if duty > 0 then
			table.insert(tags, "duty")
		end

		if player:getData("restrained") and player:getData("restrained_item") == 45 then
			table.insert(tags, "handcuff")
		end

		if player:getData("restrained") and player:getData("restrained_item") == 46 then
			table.insert(tags, "rope")
		end

		-- if player:getData("smoking") then
			-- table.insert(tags, "cigarette")
		-- end

		-- if player:getData("phone.callSound") then
			-- table.insert(tags, "phone")
		-- end

		if player:getData("seatbelt") and vehicle then
			table.insert(tags, "seatbelt")
		end

		nametagColor = {
			r = 255,
			g = 255,
			b = 255,
		}
	end

	if windows then
		table.insert(tags, "window")
	end

	if player:getData("vip") > 0 then
		table.insert(tags, "vips/" .. player:getData("vip"))
	end

	if player:getData("tags") then
		for _, tag in pairs(player:getData("tags")) do
			table.insert(tags, "tags/" .. tag.id)
		end
	end

	if player:getData("youtuber") then
		table.insert(tags, "youtuber")
	end

	if player:getData("rp_plus") then
		table.insert(tags, "rp_plus")
	end

	cache[player] = {
		player = player,
		name = name,
		nametagColor = {
			r = r,
			g = g,
			b = b,
		},
		tags = tags,
		tinted = tinted,
		badge = badge,
		mask = player:getData("mask"),
		id = player:getData("id"),
		afk = player:getData("afk"),
		dead = player:getData("dead"),
		rk = player:getData("rk"),
		injury = player:getData("injury"),
		cked = player:getData("cked"),
		adminJailed = player:getData("admin_jailed"),
		donater = player:getData("donater"),
		writing = player:getData("writing"),
		talking = exports.mek_voice:isEntityTalking(player),
		dragged = player:getData("dragged_player"),
		isDragged = player:getData("is_dragged"),
	}
end

function deleteCache(player)
	if cache[player] then
		cache[player] = nil
	end
end

addEventHandler("onClientElementDataChange", localPlayer, function(theKey, newValue, oldValue)
	if theKey == "nametag_settings" then
		settings = {
			font = (getElementData(localPlayer, "nametag_settings").font or 1),
			type = (getElementData(localPlayer, "nametag_settings").type or 1),
			id = (getElementData(localPlayer, "nametag_settings").id or 1),
			border = (getElementData(localPlayer, "nametag_settings").border or 1),
			tag = (getElementData(localPlayer, "nametag_settings").tag or 1),
			placement = (getElementData(localPlayer, "nametag_settings").placement or 1),
			color = (getElementData(localPlayer, "nametag_settings").color or 1),
		}

		createCache(localPlayer)
		updateFont()
	end
end)

loadTimer = setTimer(function()
	if getElementData(localPlayer, "logged") then
		settings = {
			font = (getElementData(localPlayer, "nametag_settings").font or 1),
			type = (getElementData(localPlayer, "nametag_settings").type or 1),
			id = (getElementData(localPlayer, "nametag_settings").id or 1),
			border = (getElementData(localPlayer, "nametag_settings").border or 1),
			tag = (getElementData(localPlayer, "nametag_settings").tag or 1),
			placement = (getElementData(localPlayer, "nametag_settings").placement or 1),
			color = (getElementData(localPlayer, "nametag_settings").color or 1),
		}

		updateFont()
		createCache(localPlayer)
		killTimer(loadTimer)
	end
end, 1000, 0)

setTimer(function()
	for _, player in ipairs(getElementsByType("player")) do
		setPlayerNametagShowing(player, false)
		if isElementStreamedIn(player) then
			if getElementType(player) == "player" then
				createCache(player)
			end
		end
	end
end, 250, 0)

addEventHandler("onClientElementStreamIn", root, function()
	if getElementType(source) == "player" then
		createCache(source)
	end
end)

addEventHandler("onClientElementStreamOut", root, function()
	if getElementType(source) == "player" then
		deleteCache(source)
	end
end)

addEventHandler("onClientPlayerQuit", root, function()
	if getElementType(source) == "player" then
		deleteCache(source)
	end
end)

addEventHandler("onClientElementDestroy", root, function()
	if getElementType(source) == "player" then
		deleteCache(source)
	end
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
	for _, player in ipairs(getElementsByType("player")) do
		setPlayerNametagShowing(player, false)
		if isElementStreamedIn(player) then
			createCache(player)
		end
	end
end)

addEventHandler("onClientMinimize", root, function()
	setElementData(localPlayer, "afk", true)
	minimizeAFK = true
end)

addEventHandler("onClientRestore", root, function()
	setElementData(localPlayer, "afk", false)
	minimizeAFK = false
end)

function aimsAt(player)
	return getPedTarget(localPlayer) == player and getPedControlState(localPlayer, "aim_weapon")
end

function getHealthColor(type, player)
	local color = "#FFFFFF"
	if type == 1 then
		if settings.color == 1 then
			if getElementHealth(player) <= 30 then
				color = "#FF0000"
			elseif getElementHealth(player) <= 70 then
				color = "#FFD11A"
			else
				color = "#009432"
			end
		elseif settings.color == 2 then
			color = theme.BLUE[500]
		elseif settings.color == 3 then
			color = theme.GREEN[500]
		elseif settings.color == 4 then
			color = theme.ORANGE[500]
		elseif settings.color == 5 then
			color = theme.RED[500]
		elseif settings.color == 6 then
			color = theme.PURPLE[500]
		elseif settings.color == 7 then
			color = theme.YELLOW[700]
		end
	elseif type == 2 then
		if settings.color == 1 then
			color = "#c80f0f"
		elseif settings.color == 2 then
			color = theme.BLUE[500]
		elseif settings.color == 3 then
			color = theme.GREEN[500]
		elseif settings.color == 4 then
			color = theme.ORANGE[500]
		elseif settings.color == 5 then
			color = theme.RED[500]
		elseif settings.color == 6 then
			color = theme.PURPLE[500]
		elseif settings.color == 7 then
			color = theme.YELLOW[700]
		end
	end
	return color
end

function getAlphaFromColor(color)
	return math.floor(color / 0x1000000)
end

function dxDrawBorderText(
	message,
	left,
	top,
	width,
	height,
	color,
	size,
	font,
	alignX,
	alignY,
	clip,
	wordBreak,
	postGUI
)
	color = color or tocolor(255, 255, 255)
	local alpha = getAlphaFromColor(color)
	size = size or 1
	font = font or "default"
	alignX = alignX or "left"
	alignY = alignY or "top"
	clip = clip or false
	wordBreak = wordBreak or false
	postGUI = postGUI or false

	local borderColor = tocolor(0, 0, 0, alpha)
	local cleanMessage = message:gsub("#%x%x%x%x%x%x", "")

	dxDrawText(
		cleanMessage,
		left + 1,
		top + 1,
		width + 1,
		height + 1,
		borderColor,
		size,
		font,
		alignX,
		alignY,
		clip,
		wordBreak,
		postGUI
	)
	dxDrawText(
		cleanMessage,
		left + 1,
		top - 1,
		width + 1,
		height - 1,
		borderColor,
		size,
		font,
		alignX,
		alignY,
		clip,
		wordBreak,
		postGUI
	)
	dxDrawText(
		cleanMessage,
		left - 1,
		top + 1,
		width - 1,
		height + 1,
		borderColor,
		size,
		font,
		alignX,
		alignY,
		clip,
		wordBreak,
		postGUI
	)
	dxDrawText(
		cleanMessage,
		left - 1,
		top - 1,
		width - 1,
		height - 1,
		borderColor,
		size,
		font,
		alignX,
		alignY,
		clip,
		wordBreak,
		postGUI
	)
	dxDrawText(message, left, top, width, height, color, size, font, alignX, alignY, clip, wordBreak, postGUI, true)
end
