addEventHandler("onClientResourceStart", resourceRoot, function()
	screenSource = dxCreateScreenSource(screenSize.x, screenSize.y)
end)

function clearScreen()
	if screenSource and localPlayer:getData("logged") then
		dxUpdateScreenSource(screenSource)
		dxDrawImage(
			screenSize.x - screenSize.x,
			screenSize.y - screenSize.y,
			screenSize.x,
			screenSize.y,
			screenSource,
			0,
			0,
			0,
			tocolor(255, 255, 255, 255),
			true
		)
	end
end

bindKey("F9", "down", function()
	if not localPlayer:getData("logged") then
		return
	end

	if not isEventHandlerAdded("onClientRender", root, clearScreen) then
		addEventHandler("onClientRender", root, clearScreen)
	else
		removeEventHandler("onClientRender", root, clearScreen)
	end
end)
