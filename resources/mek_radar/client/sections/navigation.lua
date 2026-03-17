local waySays = {
	["left"] = { "Sola dön ", " sonra" },
	["right"] = { "Sağa dön ", " sonra" },
	["forward"] = { "Düz devam et ", "" },
	["finish"] = { "", "" },
	["around"] = { "Geri dönün ", "" },
}

local gpsLineIconSize = 30
local gpsAnimStart

function renderNavigation(x, y, w, h)
	if gpsRoute or (not gpsRoute and waypointEndInterpolation) then
		local centerX, centerY = x + w / 2 - gpsLineIconSize / 2, y
		if waypointEndInterpolation then
			local interpolationProgress = (getTickCount() - waypointEndInterpolation) / 1550
			interpolatePosition, interpolateAlpha =
				interpolateBetween(0, 150, 0, 75, 0, 0, interpolationProgress, "Linear")

			dxDrawImage(
				centerX,
				centerY,
				gpsLineIconSize,
				gpsLineIconSize,
				"public/images/gps/finish.png",
				0,
				0,
				0,
				tocolor(255, 255, 255, interpolateAlpha)
			)

			if interpolationProgress > 1 then
				waypointEndInterpolation = false
			end
		elseif nextWp then
			if currentWaypoint ~= nextWp and not tonumber(reRouting) then
				if nextWp > 1 then
					waypointInterpolation = { getTickCount(), currentWaypoint }
				end

				currentWaypoint = nextWp
			end

			if tonumber(reRouting) then
				currentWaypoint = nextWp

				local reRouteProgress = (getTickCount() - reRouting) / 1250
				local refreshAngle_1, refreshAngle_2 =
					interpolateBetween(360, 0, 0, 0, 360, 0, reRouteProgress, "Linear")

				dxDrawImage(
					centerX,
					centerY,
					gpsLineIconSize,
					gpsLineIconSize,
					"public/images/gps/circleout.png",
					refreshAngle_1,
					0,
					0,
					tocolor(200, 200, 200, firstAlpha)
				)
				dxDrawImage(
					centerX,
					centerY,
					gpsLineIconSize,
					gpsLineIconSize,
					"public/images/gps/circlein.png",
					refreshAngle_2,
					0,
					0,
					tocolor(200, 200, 200, firstAlpha)
				)
				dxDrawText(
					"Hesaplanıyor",
					x,
					y,
					w + x,
					h + y,
					tocolor(200, 200, 200, firstAlpha),
					1,
					1,
					fonts.caption.bold,
					"center",
					"bottom"
				)

				if reRouteProgress > 1 then
					reRouting = getTickCount()
				end
			elseif turnAround then
				currentWaypoint = nextWp
				if not gpsAnimStart then
					gpsAnimStart = getTickCount()
				end
				local startPolation, endPolation = (getTickCount() - gpsAnimStart) / 600, 0
				local firstAlpha = interpolateBetween(0, 0, 0, 255, 0, 0, startPolation, "Linear")

				dxDrawImage(
					centerX,
					centerY,
					gpsLineIconSize,
					gpsLineIconSize,
					"public/images/gps/around.png",
					0,
					0,
					0,
					tocolor(200, 200, 200, firstAlpha)
				)
				dxDrawText(
					"U dönüşü",
					x,
					y,
					w + x,
					h + y,
					tocolor(200, 200, 200, firstAlpha),
					1,
					1,
					fonts.caption.bold,
					"center",
					"bottom"
				)
			else
				dxDrawImage(
					centerX,
					centerY,
					gpsLineIconSize,
					gpsLineIconSize,
					"public/images/gps/" .. gpsWaypoints[nextWp][2] .. ".png",
					0,
					0,
					0,
					tocolor(200, 200, 200, 255)
				)
				if gpsAnimStart then
					gpsAnimStart = nil
				end

				local rootDistance = math.floor((gpsWaypoints[nextWp][3] or 0) / 10) * 10
				local remainingMeters = ""

				if rootDistance >= 1000 then
					rootDistance = math.round((rootDistance / 1000), 1, "floor")
					remainingMeters = rootDistance .. " km"
				else
					remainingMeters = rootDistance .. " mt"
				end

				dxDrawText(
					remainingMeters,
					x,
					y,
					w + x,
					h + y,
					tocolor(200, 200, 200, 255),
					1,
					1,
					fonts.caption.bold,
					"center",
					"bottom"
				)
			end
		end
	end
end
