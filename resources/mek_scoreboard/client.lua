screenSize = Vector2(guiGetScreenSize())

theme = useTheme()
fonts = useFonts()

brandIconFont = dxCreateFont(":mek_ui/public/fonts/FontAwesomeBrand.ttf", 10) or "default"

Scoreboard = {}
Scoreboard.containerSize = { x = 500, y = 600 }
Scoreboard.containerPosition = {
	x = screenSize.x / 2 - Scoreboard.containerSize.x / 2,
	y = screenSize.y / 2 - Scoreboard.containerSize.y / 2,
}
Scoreboard.headerSize = {
	x = Scoreboard.containerSize.x - 20,
	y = 50,
}
Scoreboard.headerPosition = {
	x = Scoreboard.containerPosition.x + 10,
	y = Scoreboard.containerPosition.y + 10,
}
Scoreboard.columnSize = {
	x = Scoreboard.containerSize.x - 20,
	y = 25,
}
Scoreboard.columnPosition = {
	x = Scoreboard.containerPosition.x + 10,
	y = Scoreboard.headerPosition.y + Scoreboard.headerSize.y + 5,
}
Scoreboard.listSize = {
	x = Scoreboard.containerSize.x - 20,
	y = Scoreboard.containerSize.y - Scoreboard.headerSize.y - Scoreboard.columnSize.y - 20,
}
Scoreboard.listPosition = {
	x = Scoreboard.containerPosition.x + 10,
	y = Scoreboard.columnPosition.y + Scoreboard.columnSize.y + 5,
}
Scoreboard.currentScroll = 1
Scoreboard.maxScroll = math.floor(Scoreboard.listSize.y / Scoreboard.columnSize.y)
Scoreboard.scrollSpeed = math.floor(Scoreboard.maxScroll / 2)
Scoreboard.isVisible = false
Scoreboard.pingIntervalRef = nil
Scoreboard.openDuration = 200
Scoreboard.columns = {
	{
		label = "ID",
		width = 0.1,
		key = "id",
	},
	{
		label = "İsim",
		width = 0.57,
		key = "name",
	},
	{
		label = "Seviye",
		width = 0.2,
		key = "level",
	},
	{
		label = "Ping",
		width = 0.2,
		key = "ping",
	},
}

Scoreboard.renderHeader = function()
	local logoSize = Scoreboard.headerSize.y * 2
	local logoPosition = {
		x = Scoreboard.headerPosition.x + (Scoreboard.headerSize.x / 2) - (logoSize / 2),
		y = Scoreboard.headerPosition.y - (logoSize / 2),
	}

	dxDrawImage(
		logoPosition.x,
		logoPosition.y,
		logoSize,
		logoSize,
		":mek_ui/public/images/logo.png",
		0,
		0,
		0,
		rgba(theme.WHITE, Scoreboard.alpha)
	)

	dxDrawText(
		Scoreboard.serverName[1],
		Scoreboard.headerPosition.x + 1,
		Scoreboard.headerPosition.y + 10,
		0,
		Scoreboard.headerPosition.y + Scoreboard.headerSize.y,
		rgba(theme.GRAY[600], Scoreboard.alpha),
		0.9,
		fonts.ProximaNovaBold.h6,
		"left",
		"top"
	)
	dxDrawText(
		Scoreboard.serverName[1],
		Scoreboard.headerPosition.x,
		Scoreboard.headerPosition.y + 10,
		0,
		Scoreboard.headerPosition.y + Scoreboard.headerSize.y,
		rgba(theme.GRAY[50], Scoreboard.alpha),
		0.9,
		fonts.ProximaNovaBold.h6,
		"left",
		"top"
	)
	dxDrawText(
		Scoreboard.serverName[2],
		Scoreboard.headerPosition.x + 1,
		Scoreboard.headerPosition.y - 10,
		0,
		Scoreboard.headerPosition.y + Scoreboard.headerSize.y - 10,
		rgba(theme.GRAY[600], Scoreboard.alpha),
		0.9,
		fonts.ProximaNovaLight.body,
		"left",
		"bottom"
	)
	dxDrawText(
		Scoreboard.serverName[2],
		Scoreboard.headerPosition.x,
		Scoreboard.headerPosition.y - 10,
		0,
		Scoreboard.headerPosition.y + Scoreboard.headerSize.y - 10,
		rgba(theme.GRAY[200], Scoreboard.alpha),
		0.9,
		fonts.ProximaNovaLight.body,
		"left",
		"bottom"
	)
	dxDrawText(
		Scoreboard.playersCount .. " çevrimiçi",
		Scoreboard.headerPosition.x - 11,
		Scoreboard.headerPosition.y,
		Scoreboard.headerPosition.x + Scoreboard.headerSize.x - 11,
		Scoreboard.headerPosition.y + Scoreboard.headerSize.y,
		rgba(theme.GREEN[700], Scoreboard.alpha),
		1,
		fonts.ProximaNovaBold.body,
		"right",
		"center",
		false,
		false,
		false,
		true
	)
	dxDrawText(
		Scoreboard.playersCount .. " çevrimiçi",
		Scoreboard.headerPosition.x - 10,
		Scoreboard.headerPosition.y,
		Scoreboard.headerPosition.x + Scoreboard.headerSize.x - 10,
		Scoreboard.headerPosition.y + Scoreboard.headerSize.y,
		rgba(theme.GREEN[400], Scoreboard.alpha),
		1,
		fonts.ProximaNovaBold.body,
		"right",
		"center",
		false,
		false,
		false,
		true
	)
end

Scoreboard.renderColumns = function()
	local columnX = Scoreboard.columnPosition.x
	local columnY = Scoreboard.columnPosition.y

	for player = 1, #Scoreboard.columns do
		local columnWidth = Scoreboard.columnSize.x * Scoreboard.columns[player].width
		local columnLabel = Scoreboard.columns[player].label

		dxDrawText(
			columnLabel,
			columnX + 11,
			columnY,
			columnX + columnWidth - 5,
			columnY + Scoreboard.columnSize.y,
			rgba(theme.GRAY[600], Scoreboard.alpha),
			0.8,
			fonts.ProximaNovaBold.h6,
			"left",
			"center"
		)

		dxDrawText(
			columnLabel,
			columnX + 10,
			columnY,
			columnX + columnWidth - 5,
			columnY + Scoreboard.columnSize.y,
			rgba(theme.GRAY[200], Scoreboard.alpha),
			0.8,
			fonts.ProximaNovaBold.h6,
			"left",
			"center"
		)

		columnX = columnX + columnWidth
	end
end

Scoreboard.renderList = function()
	local listX = Scoreboard.listPosition.x
	local listY = Scoreboard.listPosition.y + 5
	local scrollbarWidth = 1
	local scrollbarHeight = Scoreboard.listSize.y - 10

	if #Scoreboard.players > Scoreboard.maxScroll then
		local scrollbarX = listX + Scoreboard.listSize.x - scrollbarWidth - 5
		dxDrawRectangle(scrollbarX, listY, scrollbarWidth, scrollbarHeight, rgba(theme.GRAY[200], 0.1))

		local scrollbarPosY = listY + (scrollbarHeight / #Scoreboard.players) * (Scoreboard.currentScroll - 1)
		local scrollbarPosHeight = (scrollbarHeight / #Scoreboard.players) * Scoreboard.maxScroll
		dxDrawRectangle(
			scrollbarX,
			scrollbarPosY,
			scrollbarWidth,
			scrollbarPosHeight,
			tocolor(255, 255, 255, Scoreboard.alpha * 255)
		)
	end

	for playerIndex = Scoreboard.currentScroll, Scoreboard.currentScroll + Scoreboard.maxScroll - 1 do
		if Scoreboard.players[playerIndex] then
			local playerData = Scoreboard.players[playerIndex]

			for colIndex = 1, #Scoreboard.columns do
				local column = Scoreboard.columns[colIndex]
				local columnWidth = Scoreboard.columnSize.x * column.width
				local isInDuty = playerData.isInDuty and playerData.adminLevel > 0
				local xOffset = listX + 11
				local yOffset = listY

				if column.key == "name" and isInDuty then
					local iconPath = ":mek_nametag/public/images/admins/" .. playerData.adminLevel .. ".png"
					dxDrawImage(
						xOffset - 1,
						yOffset + 1,
						20,
						20,
						iconPath,
						0,
						0,
						0,
						tocolor(255, 255, 255, Scoreboard.alpha * 255),
						false
					)
					xOffset = xOffset + 25
				end

				local text = tostring(playerData[column.key])
				dxDrawText(
					text,
					xOffset + 1,
					yOffset,
					xOffset + columnWidth - 5,
					yOffset + Scoreboard.columnSize.y,
					tocolor(25, 25, 25, Scoreboard.alpha * 255),
					0.9,
					fonts.ProximaNovaLight.h6,
					"left",
					"center"
				)
				dxDrawText(
					text,
					xOffset,
					yOffset,
					xOffset + columnWidth - 5,
					yOffset + Scoreboard.columnSize.y,
					tocolor(
						playerData.nametagColor.r,
						playerData.nametagColor.g,
						playerData.nametagColor.b,
						Scoreboard.alpha * 255
					),
					0.9,
					fonts.ProximaNovaLight.h6,
					"left",
					"center"
				)

				listX = listX + columnWidth
			end

			listX = Scoreboard.listPosition.x
			listY = listY + Scoreboard.columnSize.y
		end
	end
end

Scoreboard.renderSocials = function()
	local containerX = Scoreboard.containerPosition.x
	local containerY = Scoreboard.containerPosition.y + Scoreboard.containerSize.y + 20
	local segmentWidth = Scoreboard.containerSize.x / #Scoreboard.socialURLs

	for i = 1, #Scoreboard.socialURLs do
		local posX = containerX + segmentWidth * (i - 1)

		dxDrawText(
			Scoreboard.socialURLs[i].icon,
			posX,
			containerY,
			posX + segmentWidth,
			containerY + 40,
			rgba(theme.GRAY[100], Scoreboard.alpha),
			0.8,
			brandIconFont,
			"center",
			"top"
		)

		dxDrawText(
			Scoreboard.socialURLs[i].url,
			posX,
			containerY,
			posX + segmentWidth,
			containerY + 40,
			rgba(theme.GRAY[200], Scoreboard.alpha),
			0.8,
			fonts.ProximaNovaLight.h6,
			"center",
			"bottom"
		)
	end
end

Scoreboard.render = function()
	Scoreboard.alpha = math.min(1, (getTickCount() - Scoreboard.openTickCount) / Scoreboard.openDuration)
	if Scoreboard.closeTickCount then
		Scoreboard.alpha = math.max(0, 1 - (getTickCount() - Scoreboard.closeTickCount) / Scoreboard.openDuration)
		if Scoreboard.alpha == 0 then
			Scoreboard.hide()
			return
		end
	end
	dxDrawImage(
		0,
		0,
		screenSize.x,
		screenSize.y,
		"public/images/background.png",
		0,
		0,
		0,
		tocolor(255, 255, 255, Scoreboard.alpha * 255)
	)
	Scoreboard.renderHeader()
	Scoreboard.renderColumns()
	Scoreboard.renderList()
	Scoreboard.renderSocials()
end

Scoreboard.cachePlayers = function()
	Scoreboard.localID = localPlayer:getData("id")
	Scoreboard.players = {}
	Scoreboard.playersByElement = {}
	Scoreboard.isInDutyLocal = localPlayer:getData("duty_admin")
	Scoreboard.playersCount = #Element.getAllByType("player")

	local players = Element.getAllByType("player")
	for i = 1, #players do
		local player = players[i]
		if player then
			local name = player:getName():gsub("_", " ")
			if Scoreboard.isInDutyLocal then
				local username = player:getData("account_username") or "?"
				name = name .. " (" .. username .. ")"
			end

			local r, g, b = getPlayerNametagColor(player)
			if not (r and g and b) then
				r, g, b = 255, 255, 255
			end

			local scoreboardEntry = {
				id = player:getData("id"),
				player = player,
				name = name,
				level = player:getData("level") or 0,
				isLoggedIn = player:getData("logged"),
				isInDuty = player:getData("duty_admin"),
				adminLevel = player:getData("admin_level") or 0,
				ping = player.ping,
				nametagColor = {
					r = r,
					g = g,
					b = b,
				},
			}

			table.insert(Scoreboard.players, scoreboardEntry)
			Scoreboard.playersByElement[player] = #Scoreboard.players
		end
	end

	table.sort(Scoreboard.players, function(a, b)
		if a.id == Scoreboard.localID then
			return true
		elseif b.id == Scoreboard.localID then
			return false
		else
			return a.id < b.id
		end
	end)
end

Scoreboard.cachePlayersPing = function()
	for player = 1, #Scoreboard.players do
		if Scoreboard.players[player].isLoggedIn and Scoreboard.players[player].player:getPing() then
			Scoreboard.players[player].ping = Scoreboard.players[player].player:getPing()
		end
	end
	Scoreboard.playersCount = #Element.getAllByType("player")
end

Scoreboard.onJoin = function()
	Scoreboard.cachePlayers()
end

Scoreboard.onChangeName = function(oldNick, newNick)
	if not Scoreboard.players[Scoreboard.playersByElement[source]] then
		return
	end
	Scoreboard.players[Scoreboard.playersByElement[source]].name = newNick
end

Scoreboard.onDataChange = function()
	if source.type ~= "player" then
		return
	end
	Scoreboard.cachePlayers()
end

Scoreboard.onQuit = function()
	if not Scoreboard.players[Scoreboard.playersByElement[source]] then
		return
	end
	table.remove(Scoreboard.players, Scoreboard.playersByElement[source])
	Scoreboard.playersByElement[source] = nil
end

Scoreboard.onKey = function(button, press)
	if not press then
		return
	end
	if button == "mouse_wheel_up" then
		Scoreboard.currentScroll = math.max(Scoreboard.currentScroll - Scoreboard.scrollSpeed, 1)
	elseif button == "mouse_wheel_down" then
		Scoreboard.currentScroll =
			math.min(Scoreboard.currentScroll + Scoreboard.scrollSpeed, #Scoreboard.players - Scoreboard.maxScroll + 1)
	end
end

Scoreboard.hide = function()
	removeEventHandler("onClientPlayerJoin", root, Scoreboard.onJoin)
	removeEventHandler("onClientPlayerChangeNick", root, Scoreboard.onChangeName)
	removeEventHandler("onClientPlayerQuit", root, Scoreboard.onQuit)
	removeEventHandler("onClientElementDataChange", root, Scoreboard.onDataChange)
	removeEventHandler("onClientRender", root, Scoreboard.render)
	removeEventHandler("onClientKey", root, Scoreboard.onKey)
	if isTimer(Scoreboard.pingIntervalRef) then
		killTimer(Scoreboard.pingIntervalRef)
		Scoreboard.pingIntervalRef = nil
	end
	Scoreboard.closeTickCount = nil
	Scoreboard.isVisible = false
end

Scoreboard.show = function()
	Scoreboard.currentScroll = 1
	Scoreboard.maxScroll = math.floor(Scoreboard.listSize.y / Scoreboard.columnSize.y)
	Scoreboard.scrollSpeed = math.floor(Scoreboard.maxScroll / 2)
	Scoreboard.openTickCount = getTickCount()
	Scoreboard.cachePlayers()
	Scoreboard.serverName = {
		"Mekan",
		"Game",
	}
	addEventHandler("onClientPlayerJoin", root, Scoreboard.onJoin)
	addEventHandler("onClientPlayerChangeNick", root, Scoreboard.onChangeName)
	addEventHandler("onClientPlayerQuit", root, Scoreboard.onQuit)
	addEventHandler("onClientElementDataChange", root, Scoreboard.onDataChange)
	addEventHandler("onClientRender", root, Scoreboard.render)
	addEventHandler("onClientKey", root, Scoreboard.onKey)
	if not isTimer(Scoreboard.pingIntervalRef) then
		Scoreboard.pingIntervalRef = Timer(Scoreboard.cachePlayersPing, 1000, 0)
	end
	Scoreboard.socialURLs = {
		{
			icon = "",
			url = "mekanrp",
			title = "Discord",
		},
		{
			icon = "",
			url = "mekangames",
			title = "Instagram",
		},
		{
			icon = "",
			url = "mekangames",
			title = "YouTube",
		},
		{
			icon = "",
			url = "mekangames",
			title = "TikTok",
		},
	}
	Scoreboard.isVisible = true
end

function isVisible()
	return Scoreboard.isVisible
end

bindKey("tab", "down", function()
	if not localPlayer:getData("logged") then
		return
	end
	if Scoreboard.isVisible then
		Scoreboard.hide()
	end
	Scoreboard.show()
end)

bindKey("tab", "up", function()
	if not localPlayer:getData("logged") then
		return
	end
	Scoreboard.closeTickCount = getTickCount()
end)
