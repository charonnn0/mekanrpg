addEventHandler("onClientRender", root, function()
	for i, player in ipairs(getElementsByType("player")) do
		if isElement(player) and isElementStreamedIn(player) then
			local weapon = getPedWeapon(player)
			if weapon == 24 or weapon == 29 or weapon == 31 or weapon == 34 then
				local laser = getElementData(player, "laser")
				local deagleMode = getElementData(player, "deagle_mode")

				if laser and (deagleMode == nil or deagleMode == 0) then
					local sx, sy, sz = getPedWeaponMuzzlePosition(player)
					local ex, ey, ez = getPedTargetEnd(player)
					local task = getPedTask(player, "secondary", 0)

					if task == "TASK_SIMPLE_USE_GUN" then
						local collision, cx, cy, cz, element = processLineOfSight(
							sx,
							sy,
							sz,
							ex,
							ey,
							ez,
							true,
							true,
							true,
							true,
							true,
							false,
							false,
							false
						)

						if not collision then
							cx = ex
							cy = ey
							cz = ez
						end

						dxDrawLine3D(sx, sy, sz - 0.05, cx, cy, cz, tocolor(255, 0, 0, 75), 2, false, 0)
					end
				end
			end
		end
	end
end)
