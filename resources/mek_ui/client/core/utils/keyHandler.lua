local lastClick = 0
local pressedKeys = {}

addEventHandler("onClientKey", root, function(key, state)
	if key == "mouse1" then
		return
	end

	pressedKeys[key] = state
end)

function isKeyClicked(key)
	return pressedKeys[key]
end

function isKeyPressed(key)
	if isConsoleActive() or isMainMenuActive() then
		return false
	end
	return pressedKeys[key]
end

setTimer(function()
	if getKeyState("mouse1") and lastClick + 300 <= getTickCount() then
		lastClick = getTickCount()
		pressedKeys.mouse1 = true
	else
		pressedKeys.mouse1 = false
	end
end, 0, 0)
