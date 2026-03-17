setTimer(function()
	for _, player in pairs(getElementsByType("player", root, true)) do
		if
			(getPedTask(player, "secondary", 0) ~= "TASK_SIMPLE_USE_GUN" and (not isPedDoingGangDriveby(player)))
			and exports.mek_settings:getPlayerSetting(player, "head_turning")
			and not (player == localPlayer and exports.mek_phone:isVisible())
		then
			local x, y, z = getElementPosition(player)
			local rotation = getPedCameraRotation(player)
			local vx = x + math.sin(math.rad(rotation)) * 10
			local vy = y + math.cos(math.rad(rotation)) * 10

			if player ~= localPlayer then
				setPedAimTarget(player, vx, vy, z)
			end

			setPedLookAt(player, vx, vy, z, 150, 0)
		end
	end
end, 100, 0)
