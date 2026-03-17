addEvent("createWeaponModel", true)
addEventHandler("createWeaponModel", root, function(weapon, bone, x, y, z, rx, ry, rz)
	local slot = getSlotFromWeapon(weapon)

	if slot == 0 then
		return
	end

	triggerEvent("destroyWeaponModel", source, weapon)

	local object = createObject(models[weapon], x, y, z)
	setElementCollisionsEnabled(object, false)
	setElementInterior(object, getElementInterior(source))
	setElementDimension(object, getElementDimension(source))
	exports.mek_bones:attachElementToBone(object, source, bone, x, y, z, rx, ry, rz)

	if getPedOccupiedVehicle(source) then
		setElementAlpha(object, 0)
	end

	setElementData(object, "weaponID", weapon)
	setElementData(source, "attachedSlot" .. slot, object)
end)

addEvent("destroyWeaponModel", true)
addEventHandler("destroyWeaponModel", root, function(weapon)
	local slot = getSlotFromWeapon(weapon)
	local object = getElementData(source, "attachedSlot" .. slot)

	if isElement(object) then
		local id = getElementData(object, "weaponID")
		if id == weapon then
			destroyElement(object)
			setElementData(source, "attachedSlot" .. slot, false)
		end
	end
end)

function destroyAllWeaponModels()
	for i = 1, 12 do
		local object = getElementData(source, "attachedSlot" .. i)
		if isElement(object) then
			destroyElement(object)
			setElementData(source, "attachedSlot" .. i, false)
		end
	end
end
addEventHandler("onPlayerQuit", root, destroyAllWeaponModels)
addEventHandler("onPlayerVehicleEnter", root, destroyAllWeaponModels)

addEvent("alphaWeaponModel", true)
addEventHandler("alphaWeaponModel", root, function(weapon, hide)
	local object = getElementData(source, "attachedSlot" .. getSlotFromWeapon(weapon))
	if isElement(object) then
		destroyElement(object)
	end
end)

addEventHandler("updateLocalGuns", root, function()
	for i = 1, 12 do
		local object = getElementData(source, "attachedSlot" .. i)
		if isElement(object) then
			local id = getElementData(object, "weaponID")
			if getPedWeapon(source, i) ~= id then
				destroyElement(object)
				setElementData(source, "attachedSlot" .. i, false)
			end
		end
	end
end)
