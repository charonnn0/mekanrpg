local screenSize = Vector2(guiGetScreenSize())
local sizeX, sizeY = 715, 645
local screenX, screenY = (screenSize.x - sizeX) / 2, (screenSize.y - sizeY) / 2
local clickTick = 0

local theme = useTheme()
local fonts = {
	awesome1 = dxCreateFont(":mek_ui/public/fonts/FontAwesome.ttf", 24) or "default",
	awesome2 = dxCreateFont(":mek_ui/public/fonts/FontAwesome.ttf", 16) or "default",
	font1 = dxCreateFont(":mek_ui/public/fonts/SFUIBold.ttf", 16) or "default",
	font2 = dxCreateFont(":mek_ui/public/fonts/SFUIRegular.ttf", 11) or "default",
	font3 = dxCreateFont(":mek_ui/public/fonts/SFUIRegular.ttf", 10) or "default",
	font4 = dxCreateFont(":mek_ui/public/fonts/SFUIMedium.ttf", 11) or "default",
	font5 = dxCreateFont(":mek_ui/public/fonts/SFUIBold.ttf", 10) or "default",
}

local function drawButton(text, x, y, width, height, isActive, font, callback)
	dxDrawRectangle(
		x,
		y,
		width,
		height,
		(isActive or inArea(x, y, width, height)) and rgba(theme.GRAY[600]) or rgba(theme.GRAY[800])
	)
	dxDrawText(text, x + 13, y + 6, width, height, tocolor(255, 255, 255, 235), 1, font)
	if inArea(x, y, width, height) and isKeyPressed("mouse1") and clickTick + 300 <= getTickCount() then
		clickTick = getTickCount()
		callback()
	end
end

local function handleSettingsUpdate(field, value)
	local settings = getElementData(localPlayer, "nametag_settings")
	settings[field] = value
	setElementData(localPlayer, "nametag_settings", settings, false)
	exports.mek_json:save("nametagSettings", settings)
	triggerEvent("playSuccess", localPlayer)
end

addCommandHandler("nametag", function()
	if getElementData(localPlayer, "logged") then
		if not isTimer(renderTimer) then
			showCursor(true)
			renderTimer = setTimer(function()
				dxDrawRectangle(screenX, screenY, sizeX, sizeY, rgba(theme.GRAY[900]))

				dxDrawText("", screenX + 25, screenY + 22, 30, 30, tocolor(255, 255, 255, 250), 1, fonts.awesome1)
				dxDrawText(
					"nametagını belirle",
					screenX + 83,
					screenY + 16,
					sizeX,
					sizeY,
					tocolor(255, 255, 255, 250),
					1,
					fonts.font1
				)
				dxDrawText(
					"hepimizin bakış açıları farklı olabilir",
					screenX + 83,
					screenY + 43,
					sizeX,
					sizeY,
					tocolor(255, 255, 255, 150),
					1,
					fonts.font2
				)

				dxDrawText(
					"",
					screenX + sizeX - 40,
					screenY + 20,
					nil,
					nil,
					inArea(
						screenX + sizeX - 40,
						screenY + 20,
						dxGetTextWidth("", 1, fonts.awesome2),
						dxGetFontHeight(1, fonts.awesome2)
					)
							and rgba(theme.RED[500])
						or tocolor(255, 255, 255, 255),
					1,
					fonts.awesome2
				)
				if
					inArea(
						screenX + sizeX - 40,
						screenY + 20,
						dxGetTextWidth("", 1, fonts.awesome2),
						dxGetFontHeight(1, fonts.awesome2)
					)
					and isKeyPressed("mouse1")
					and clickTick + 300 <= getTickCount()
				then
					clickTick = getTickCount()
					killTimer(renderTimer)
					showCursor(false)
				end

				local newX, newY = 0, 0

				dxDrawText(
					"Yazı tipi",
					screenX + 30,
					screenY + 80 + newY,
					sizeX,
					sizeY,
					tocolor(255, 255, 255, 255),
					1,
					fonts.font4
				)
				local fontsOptions = {
					{ "Klasik (default-bold)", "default-bold", 1 },
					{ "Modern (sf-regular)", fonts.font3, 2 },
					{ "Modern Kalın (sf-bold)", fonts.font5, 3 },
					{ "Klasik İnce (default)", "default", 4 },
				}

				for _, option in ipairs(fontsOptions) do
					local text, font, value = option[1], option[2], option[3]
					local textWidth = dxGetTextWidth(text, 1, font)

					drawButton(
						text,
						screenX + 30 + newX,
						screenY + 108 + newY,
						textWidth + 25,
						30,
						getElementData(localPlayer, "nametag_settings").font == value,
						font,
						function()
							handleSettingsUpdate("font", value)
						end
					)

					newX = newX + textWidth + 35
				end

				newX, newY = 0, newY + 80

				dxDrawText(
					"Can ve Zırh gösterimi",
					screenX + 30,
					screenY + 80 + newY,
					sizeX,
					sizeY,
					tocolor(255, 255, 255, 255),
					1,
					fonts.font4
				)
				local typeOptions = {
					{ "Bar ile", 1 },
					{ "Yazı ile", 2 },
					{ "Gizle", 3 },
				}

				for _, option in ipairs(typeOptions) do
					local text, value = option[1], option[2]
					local textWidth = dxGetTextWidth(text, 1, fonts.font3)

					drawButton(
						text,
						screenX + 30 + newX,
						screenY + 108 + newY,
						textWidth + 25,
						30,
						getElementData(localPlayer, "nametag_settings").type == value,
						fonts.font3,
						function()
							handleSettingsUpdate("type", value)
						end
					)

					newX = newX + textWidth + 35
				end

				newX, newY = 0, newY + 80

				dxDrawText(
					"ID gösterimi",
					screenX + 30,
					screenY + 80 + newY,
					sizeX,
					sizeY,
					tocolor(255, 255, 255, 255),
					1,
					fonts.font4
				)
				local idOptions = {
					{ "Göster", 1 },
					{ "Gizle", 2 },
				}

				for _, option in ipairs(idOptions) do
					local text, value = option[1], option[2]
					local textWidth = dxGetTextWidth(text, 1, fonts.font3)

					drawButton(
						text,
						screenX + 30 + newX,
						screenY + 108 + newY,
						textWidth + 25,
						30,
						getElementData(localPlayer, "nametag_settings").id == value,
						fonts.font3,
						function()
							handleSettingsUpdate("id", value)
						end
					)

					newX = newX + textWidth + 35
				end

				newX, newY = 0, newY + 80

				dxDrawText(
					"Yazı kalınlığı",
					screenX + 30,
					screenY + 80 + newY,
					sizeX,
					sizeY,
					tocolor(255, 255, 255, 255),
					1,
					fonts.font4
				)
				local borderOptions = {
					{ "Kalın Kenarlık", 1 },
					{ "İnce Kenarlık", 2 },
					{ "Gizle", 3 },
				}

				for _, option in ipairs(borderOptions) do
					local text, value = option[1], option[2]
					local textWidth = dxGetTextWidth(text, 1, fonts.font3)

					drawButton(
						text,
						screenX + 30 + newX,
						screenY + 108 + newY,
						textWidth + 25,
						30,
						getElementData(localPlayer, "nametag_settings").border == value,
						fonts.font3,
						function()
							handleSettingsUpdate("border", value)
						end
					)

					newX = newX + textWidth + 35
				end

				newX, newY = 0, newY + 80

				dxDrawText(
					"Etiket gösterimi",
					screenX + 30,
					screenY + 80 + newY,
					sizeX,
					sizeY,
					tocolor(255, 255, 255, 255),
					1,
					fonts.font4
				)
				local tagOptions = {
					{ "Göster", 1 },
					{ "Gizle", 2 },
				}

				for _, option in ipairs(tagOptions) do
					local text, value = option[1], option[2]
					local textWidth = dxGetTextWidth(text, 1, fonts.font3)

					drawButton(
						text,
						screenX + 30 + newX,
						screenY + 108 + newY,
						textWidth + 25,
						30,
						getElementData(localPlayer, "nametag_settings").tag == value,
						fonts.font3,
						function()
							handleSettingsUpdate("tag", value)
						end
					)

					newX = newX + textWidth + 35
				end

				newX, newY = 0, newY + 80

				dxDrawText(
					"Yerleştirme",
					screenX + 30,
					screenY + 80 + newY,
					sizeX,
					sizeY,
					tocolor(255, 255, 255, 255),
					1,
					fonts.font4
				)
				local placementOptions = {
					{ "Dinamik", 1 },
					{ "Statik", 2 },
				}

				for _, option in ipairs(placementOptions) do
					local text, value = option[1], option[2]
					local textWidth = dxGetTextWidth(text, 1, fonts.font3)

					drawButton(
						text,
						screenX + 30 + newX,
						screenY + 108 + newY,
						textWidth + 25,
						30,
						getElementData(localPlayer, "nametag_settings").placement == value,
						fonts.font3,
						function()
							handleSettingsUpdate("placement", value)
						end
					)

					newX = newX + textWidth + 35
				end

				newX, newY = 0, newY + 80

				dxDrawText(
					"Renk",
					screenX + 30,
					screenY + 80 + newY,
					sizeX,
					sizeY,
					tocolor(255, 255, 255, 255),
					1,
					fonts.font4
				)
				local colorOptions = {
					{ "Klasik", nil, 1 },
					{ "Mavi", theme.BLUE[500], 2 },
					{ "Yeşil", theme.GREEN[500], 3 },
					{ "Turuncu", theme.ORANGE[500], 4 },
					{ "Kırmızı", theme.RED[500], 5 },
					{ "Mor", theme.PURPLE[500], 6 },
					{ "Sarı", theme.YELLOW[700], 7 },
				}

				for _, option in ipairs(colorOptions) do
					local text, color, value = option[1], option[2], option[3]
					local textWidth = dxGetTextWidth(text, 1, fonts.font3)

					drawButton(
						text,
						screenX + 30 + newX,
						screenY + 108 + newY,
						textWidth + 25,
						30,
						getElementData(localPlayer, "nametag_settings").color == value,
						fonts.font3,
						function()
							handleSettingsUpdate("color", value)
						end
					)

					if color then
						local boxColorR, boxColorG, boxColorB, boxColorA = rgbaUnpack(color)
						dxDrawGradient(
							screenX + 30 + newX,
							screenY + 108 + newY,
							textWidth + 25,
							30,
							boxColorR,
							boxColorG,
							boxColorB,
							boxColorA,
							true,
							false
						)
					end

					newX = newX + textWidth + 35
				end
			end, 0, 0)
		else
			killTimer(renderTimer)
			showCursor(false)
		end
	end
end)

function loadSettings()
	local data, status = exports.mek_json:get("nametagSettings")
	setElementData(localPlayer, "nametag_settings", {
		font = data.font or 1,
		type = data.type or 1,
		id = data.id or 1,
		border = data.border or 1,
		tag = data.tag or 1,
		placement = data.placement or 1,
		color = data.color or 1,
	}, false)
	return true
end
addEvent("nametag.loadSettings", true)
addEventHandler("nametag.loadSettings", root, loadSettings)
