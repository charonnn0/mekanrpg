BigMap = {}
BigMap.minSize = {
    x = 900,
    y = 600
}
BigMap.size = {
    x = math.max(BigMap.minSize.x, screenSize.x * 0.7),
    y = math.max(BigMap.minSize.y, screenSize.y * 0.6)
}
BigMap.position = {
    x = screenSize.x / 2 - BigMap.size.x / 2,
    y = screenSize.y / 2 - BigMap.size.y / 2
}

function BigMap.render()
	if not Radar.bigMapVisible then
		return false
	end

	dxDrawRectangle(BigMap.position.x, BigMap.position.y, BigMap.size.x, BigMap.size.y, rgba(theme.GRAY[900]))
	renderSection("bigMap", BigMap.position, BigMap.size, true)
end

addEventHandler("onClientKey", root, function(key, state)
	if state and key == "F11" then
		cancelEvent()

		if not localPlayer:getData("logged") then
			return
		end

		if localPlayer.interior ~= 0 or localPlayer.dimension ~= 0 then
			return
		end

		Radar.start()
		
		if Radar.bigMapVisible then
			Radar.miniMapVisible = true
			Radar.bigMapVisible = false
			
			if isTimer(renderBigMapRender) then
				killTimer(renderBigMapRender)
			end
			
			if not isTimer(renderMiniMapRender) then
				renderMiniMapRender = setTimer(Radar.render, 0, 0)
			end
		else
			Radar.miniMapVisible = false
			Radar.bigMapVisible = true
			
			if isTimer(renderMiniMapRender) then
				killTimer(renderMiniMapRender)
			end

			if not isTimer(renderBigMapRender) then
				renderBigMapRender = setTimer(BigMap.render, 0, 0)
			end
		end
	end
end)
