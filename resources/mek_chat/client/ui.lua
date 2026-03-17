Chat = {}
Chat.position = {
	x = 10,
	y = 15,
}
Chat.sizes = {
	x = screenSize.x * 0.40,
	y = screenSize.y * 0.60,
}
Chat.history = {}
Chat.currentHistory = 0
Chat.maxHistory = 30
Chat.events = {
	onKeyEnter = encodeBinary("chat.onKeyEnter"),
	onSelectHistory = encodeBinary("chat.onSelectHistory"),
}
Chat.inputVisible = false
Chat.visible = true

Chat.prefixes = {
	IC = "IC",
	OOC = "OOC",
	Faction = "BİRLİK",
	QuickReply = "PM",
}

Chat.settings = {
	fontScale = {
		{
			label = "0.25x",
			value = 12,
		},
		{
			label = "0.5x",
			value = 14,
		},
		{
			label = "1x",
			value = 16,
		},
		{
			label = "2x",
			value = 18,
		},
		{
			label = "3x",
			value = 20,
		},
	},
}
Chat.settingsValues = {
	fontScale = 16,
}

Chat.lastCommandTimestamp = 0

function Chat.getEventHashedValues()
	local hashes = {}

	for eventKey, eventName in pairs(Chat.events) do
		hashes[eventKey] = eventName
	end

	return json.encode(hashes)
end

function Chat.setAutoCompleteCommands()
	local commands = {}

	for _, commandData in ipairs(getCommandHandlers()) do
		if commandData[1] ~= "decodeEvent" then
			table.insert(commands, {
				commandName = "/" .. commandData[1],
				params = {},
			})
		end
	end

	Chat.browser:executeJavascript("setAutoCompleteCommands(" .. json.encode(commands) .. ")")
end

function Chat.rgbToHex(r, g, b)
	return string.format("#%02X%02X%02X", r, g, b)
end

function Chat.render()
	if not localPlayer:getData("logged") then
		return
	end

	if not Chat.visible then
		return
	end

	showChat(false)

	dxDrawImage(Chat.position.x, Chat.position.y, Chat.sizes.x, screenSize.y, Chat.browser)
end

function Chat.showInput(prefix)
	if not Chat.inputVisible then
		Chat.inputVisible = true
		Chat.currentHistory = 0
		Chat.browser:executeJavascript('showInput("' .. prefix .. '")')
		Chat.browser:focus()
		guiSetInputEnabled(true)
	end
end

function Chat.hideInput()
	if Chat.inputVisible then
		Chat.inputVisible = false
		Chat.browser:executeJavascript("hideInput()")
		focusBrowser()
		guiSetInputEnabled(false)
		cancelEvent()
	end
end

function Chat.addMessage(message)
	Chat.browser:executeJavascript([[addMessage("]] .. message .. [[")]])
end

function Chat.setHeight(height)
	Chat.browser:executeJavascript("setChatHeight(" .. height / 2 .. ")")
end

function Chat.isCommand(text)
	if not Chat.canExecuteCommand() then
		return true
	end

	local c1, c2 = string.find(text, "/")

	if not c1 or c1 ~= 1 then
		return false
	end

	local text = text:sub(2, #text)

	if #text:gsub("%s", "") == 0 then
		return true
	end

	local command = split(text, " ")

	local args = ""
	for i = 2, #command do
		args = args .. " " .. command[i]
	end
	executeCommandHandler(command[1], args)
	triggerServerEvent("chat.executeCommand", localPlayer, command[1], args)

	return true
end

function Chat.onClientKey(key, state)
	if not localPlayer:getData("logged") then
		return
	end

	if not Chat.visible then
		return
	end

	if key == "mouse1" then
		if state then
			injectBrowserMouseDown(Chat.browser, "left")
		else
			injectBrowserMouseUp(Chat.browser, "left")
		end
		return
	end

	if not state then
		return
	end

	if isConsoleActive() then
		return
	end

	if key == "t" then
		if guiGetInputEnabled() then
			return
		end
		Chat.showInput(Chat.prefixes.IC)
	elseif key == "b" then
		if guiGetInputEnabled() then
			return
		end
		Chat.showInput(Chat.prefixes.OOC)
	elseif key == "y" then
		if guiGetInputEnabled() then
			return
		end
		Chat.showInput(Chat.prefixes.Faction)
	elseif key == "u" then
		if guiGetInputEnabled() then
			return
		end
		Chat.showInput(Chat.prefixes.QuickReply)
	elseif key == "escape" or key == "esc" then
		if Chat.inputVisible then
			Chat.browser:executeJavascript("saveInputField()")
			Chat.inputVisible = false
			Chat.browser:executeJavascript("hideInput()")
			focusBrowser()
			guiSetInputEnabled(false)
			cancelEvent()
		end
	elseif key == "mouse_wheel_up" or key == "pgup" then
		if not Chat.inputVisible then
			return
		end

		Chat.browser:executeJavascript('startScroll("scrollup")')
		Chat.browser:executeJavascript("stopScroll()")
	elseif key == "mouse_wheel_down" or key == "pgdn" then
		if not Chat.inputVisible then
			return
		end

		Chat.browser:executeJavascript('startScroll("scrolldown")')
		Chat.browser:executeJavascript("stopScroll()")
	elseif Chat.inputVisible then
		if isElement(Chat.sound) then
			destroyElement(Chat.sound)
		end

		Chat.sound = playSound(":mek_ui/public/sounds/key.mp3")
		setSoundVolume(Chat.sound, 0.01)
	end
end

function Chat.onClientCursorMove(_, _, absoluteX, absoluteY)
	if not Chat.inputVisible then
		return
	end

	injectBrowserMouseMove(Chat.browser, absoluteX, absoluteY)
end

function Chat.show()
	Chat.browser:executeJavascript("setEventHashes(" .. Chat.getEventHashedValues() .. ")")
	Chat.browser:executeJavascript("show(true)")

	if not isEventHandlerAdded("onClientRender", root, Chat.render) then
		addEventHandler("onClientRender", root, Chat.render)
	end

	if not isEventHandlerAdded("onClientKey", root, Chat.onClientKey) then
		addEventHandler("onClientKey", root, Chat.onClientKey)
	end

	if not isEventHandlerAdded("onClientCursorMove", root, Chat.onClientCursorMove) then
		addEventHandler("onClientCursorMove", root, Chat.onClientCursorMove)
	end

	local settingsValues, hasJSON = exports.mek_json:get("chatSettings")
	if not hasJSON then
		exports.mek_json:save("chatSettings", Chat.settingsValues)
	else
		Chat.settingsValues = settingsValues
	end
	Chat.applySettings()
end

Chat.saveSettings = function()
	exports.mek_json:save("chatSettings", Chat.settingsValues)
end

Chat.applySettings = function()
	local fontScale = Chat.settingsValues.fontScale
	Chat.browser:executeJavascript("applyChatFontSize(" .. fontScale .. ")")
end

addEventHandler("onClientChatMessage", root, function(text, r, g, b)
	Chat.addMessage(Chat.rgbToHex(r, g, b) .. text)
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
	Chat.browser = createBrowser(Chat.sizes.x, screenSize.y, true, true)
	if not Chat.browser then
		showChat(true)
		outputConsole("[ERROR] Chat browser could not be created.")
		return
	else
		addEventHandler("onClientBrowserCreated", Chat.browser, function()
			loadBrowserURL(Chat.browser, "http://mta/local/public/ui/chat.html")
		end)
		return
	end
end)

addEvent("chat.onSelectHistory", true)
addEventHandler("chat.onSelectHistory", root, function(currentText, order)
	Chat.currentHistory = Chat.currentHistory + order
	if Chat.currentHistory <= 0 then
		Chat.currentHistory = 0
	end

	if Chat.currentHistory > #Chat.history then
		Chat.currentHistory = #Chat.history
	end

	local historyText = Chat.history[Chat.currentHistory]
	if historyText then
		Chat.browser:executeJavascript('setText("' .. historyText .. '")')
	else
		Chat.browser:executeJavascript('setText("' .. currentText .. '")')
	end
end)

addEvent("chat.onLoaded", true)
addEventHandler("chat.onLoaded", root, function()
	Chat.show()
	Chat.setHeight(Chat.sizes.y)
	Chat.setAutoCompleteCommands()
end)

addEvent("chat.onKeyEnter", true)
addEventHandler("chat.onKeyEnter", root, function(prefix, inputValue)
	Chat.hideInput()

	if #inputValue == 0 then
		return
	end

	table.insert(Chat.history, 1, inputValue)

	Chat.browser:executeJavascript("clearInputField()")

	if prefix == Chat.prefixes.IC then
		if Chat.isCommand(inputValue) then
			return
		end

		triggerServerEvent("chat.sendText", localPlayer, inputValue, 0)
	elseif prefix == Chat.prefixes.OOC then
		Chat.isCommand("/b " .. inputValue)
	elseif prefix == Chat.prefixes.Faction then
		Chat.isCommand("/f " .. inputValue)
	elseif prefix == Chat.prefixes.QuickReply then
		Chat.isCommand("/hızlıyanıt " .. inputValue)
	end
end)

function isChatBoxInputVisible()
	return Chat.inputVisible
end

function Chat.canExecuteCommand()
	local currentTimestamp = getTickCount()
	if not Chat.lastCommandTimestamp then
		Chat.lastCommandTimestamp = currentTimestamp
		return true
	end

	if currentTimestamp - Chat.lastCommandTimestamp < 300 then
		Chat.addMessage("#FF0000[!]#FFFFFF Komutları çok sık kullanmayın.")
		return false
	end

	Chat.lastCommandTimestamp = currentTimestamp
	return true
end

function clearChat()
	Chat.browser:executeJavascript("clear()")
end
addCommandHandler("clearchat", clearChat, false, false)
addCommandHandler("cc", clearChat, false, false)

addCommandHandler("chat", function()
	Chat.visible = not Chat.visible
end, false, false)

addCommandHandler("chatfontsize", function(_, scale)
	if not scale or not tonumber(scale) then
		outputChatBox("Kullanım: /" .. commandName .. " [12-20]", thePlayer, 255, 194, 14)
		return
	end

	scale = tonumber(scale)
	if scale < 12 or scale > 20 then
		outputChatBox("[!]#FFFFFF Geçersiz değer. 12 ile 20 arasında bir sayı giriniz.", 255, 0, 0, true)
		return
	end

	Chat.settingsValues.fontScale = scale
	Chat.applySettings()
	Chat.saveSettings()

	outputChatBox("[!]#FFFFFF Sohbet yazı boyutu " .. scale .. " olarak ayarlandı.", 0, 255, 0, true)
end, false, false)
