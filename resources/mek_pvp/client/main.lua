local disabledWeapons = {
	[0] = true,
	[41] = true,
}

local pvpMode = false
local pvpSettings = {
	timeout = 0,
}

addEventHandler(
	"onClientPlayerWeaponFire",
	root,
	function(weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement, startX, startY, startZ)
		if source ~= localPlayer then
			return
		end

		local weapon = getPedWeapon(localPlayer)
		if not disabledWeapons[weapon] and (isElement(hitElement) and getElementType(hitElement) == "player") then
			local dutyAdmin = getElementData(hitElement, "duty_admin") or false
			local dead = getElementData(hitElement, "dead") or false

			if not dutyAdmin and not dead then
				if not pvpMode then
					switchPVPMode()
				elseif pvpMode and pvpSettings.timeout < 60 then
					pvpSettings.timeout = pvpSettings.timeout + 1
					PointsDrawing.drawBonus("+1")
					PointsDrawing.updatePointsCount(pvpSettings.timeout)
				end
			end
		end
	end
)

switchPVPMode = function()
	if pvpMode then
		pvpSettings.timeout = pvpSettings.timeout + 5
		if pvpSettings.timeout > 60 then
			pvpSettings.timeout = 60
		end
		PointsDrawing.hide()
		removeEventHandler("onClientRender", root, PointsDrawing.draw)
		removeEventHandler("onClientPreRender", root, PointsDrawing.update)

		pvpMode = false
	else
		pvpMode = true
		pvpSettings.timeout = 60
		addEventHandler("onClientRender", root, PointsDrawing.draw)
		addEventHandler("onClientPreRender", root, PointsDrawing.update)
		PointsDrawing.updatePointsCount(pvpSettings.timeout)
		PointsDrawing.show()
	end
end

setTimer(function()
	if pvpMode and pvpSettings.timeout > 0 then
		pvpSettings.timeout = pvpSettings.timeout - 1
		PointsDrawing.updatePointsCount(pvpSettings.timeout)
		PointsDrawing.setShaking(true)
		PointsDrawing.drawBonus("-1")
		if not getElementData(localPlayer, "pvp") then
			setElementData(localPlayer, "pvp", true)
		end
	else
		if pvpMode then
			switchPVPMode()
		end

		if getElementData(localPlayer, "pvp") then
			setElementData(localPlayer, "pvp", false)
		end
	end
end, 1000, 0)
