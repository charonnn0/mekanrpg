addCommandHandler("ss", function()
	if not localPlayer:getData("logged") then
		return
	end

	if not isTimer(renderTimer) then
		renderTimer = setTimer(function()
			dxDrawRectangle(0, 0, screenSize.x, screenSize.y, tocolor(0, 0, 0, 255))
		end, 0, 0)
	else
		killTimer(renderTimer)
	end
end, false, false)
