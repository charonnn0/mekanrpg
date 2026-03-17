function saveVehicle(source)
	local dbid = tonumber(getElementData(source, "dbid")) or -1
	if isElement(source) and getElementType(source) == "vehicle" and dbid > 0 then
		local x, y, z = getElementPosition(source)
		local rx, ry, rz = getElementRotation(source)
		local engine = getElementData(source, "engine") and 1 or 0
		local odometer = getElementData(source, "odometer") or 0
		local locked = isVehicleLocked(source) and 1 or 0
		local lights = getVehicleOverrideLights(source)
		local sirens = getVehicleSirensOn(source) and 1 or 0
		local handbrake = getElementData(source, "handbrake") and 1 or 0
		local health = getElementHealth(source)
		local dimension = getElementDimension(source)
		local interior = getElementInterior(source)

		local wheel1, wheel2, wheel3, wheel4 = getVehicleWheelStates(source)
		local wheelState = toJSON({ wheel1, wheel2, wheel3, wheel4 })

		local panel0 = getVehiclePanelState(source, 0)
		local panel1 = getVehiclePanelState(source, 1)
		local panel2 = getVehiclePanelState(source, 2)
		local panel3 = getVehiclePanelState(source, 3)
		local panel4 = getVehiclePanelState(source, 4)
		local panel5 = getVehiclePanelState(source, 5)
		local panel6 = getVehiclePanelState(source, 6)
		local panelState = toJSON({ panel0, panel1, panel2, panel3, panel4, panel5, panel6 })

		local door0 = getVehicleDoorState(source, 0)
		local door1 = getVehicleDoorState(source, 1)
		local door2 = getVehicleDoorState(source, 2)
		local door3 = getVehicleDoorState(source, 3)
		local door4 = getVehicleDoorState(source, 4)
		local door5 = getVehicleDoorState(source, 5)
		local doorState = toJSON({ door0, door1, door2, door3, door4, door5 })

		dbExec(
			exports.mek_mysql:getConnection(),
			"UPDATE vehicles SET engine = ?, locked = ?, lights = ?, hp = ?, sirens = ?, handbrake = ?, currx = ?, curry = ?, currz = ?, currrx = ?, currry = ?, currrz = ?, panelStates = ?, wheelStates = ?, doorStates = ?, odometer = ?, last_used = NOW() WHERE id = ?",
			engine,
			locked,
			lights,
			health,
			sirens,
			handbrake,
			x,
			y,
			z,
			rx,
			ry,
			rz,
			panelState,
			wheelState,
			doorState,
			odometer,
			dbid
		)
	end
end

function saveVehicleMods(source)
	local dbid = tonumber(getElementData(source, "dbid")) or -1
	if isElement(source) and getElementType(source) == "vehicle" and dbid > 0 then
		local col = { getVehicleColor(source, true) }
		local color1 = toJSON({ col[1], col[2], col[3] })
		local color2 = toJSON({ col[4], col[5], col[6] })
		local color3 = toJSON({ col[7], col[8], col[9] })
		local color4 = toJSON({ col[10], col[11], col[12] })

		local hcol1, hcol2, hcol3 = getVehicleHeadLightColor(source)
		local headLightColors = toJSON({ hcol1, hcol2, hcol3 })

		local upgrades = {}
		for i = 0, 16 do
			upgrades[i] = getVehicleUpgradeOnSlot(source, i) or 0
		end
		local upgradesJSON = toJSON(upgrades)

		local upgradeItems = getElementData(source, "upgrade_items") or {}
		local upgradeItemsJSON = toJSON(upgradeItems)

		local paintjob = getVehiclePaintjob(source)
		local variant1, variant2 = getVehicleVariant(source)

		dbExec(
			exports.mek_mysql:getConnection(),
			"UPDATE vehicles SET upgrades = ?, upgrade_items = ?, paintjob = ?, color1 = ?, color2 = ?, color3 = ?, color4 = ?, headlights = ?, variant1 = ?, variant2 = ? WHERE id = ?",
			upgradesJSON,
			upgradeItemsJSON,
			paintjob,
			color1,
			color2,
			color3,
			color4,
			headLightColors,
			variant1,
			variant2,
			dbid
		)
	end
end

addEventHandler("onVehicleExit", root, function()
	saveVehicle(source)
	saveVehicleMods(source)
end)
