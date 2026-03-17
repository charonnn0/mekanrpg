local l_cigar = {}
local r_cigar = {}
local deagle = {}
local isLocalPlayerSmokingBool = false

function setSmoking(player, state, hand)
	setElementData(player, "smoking", state)
	if not hand or (hand == 0) then
		setElementData(player, "smoking_hand", 0)
	else
		setElementData(player, "smoking_hand", 1)
	end

	if isElement(player) then
		if state then
			playerExitsVehicle(player)
		else
			playerEntersVehicle(player)
		end
	end
end

function playerExitsVehicle(player)
	if getElementData(player, "smoking") then
		playerEntersVehicle(player)
		if getElementData(player, "smoking_hand") == 1 then
			r_cigar[player] = createCigarModel(player, 3027)
		else
			l_cigar[player] = createCigarModel(player, 3027)
		end
	end
end

function playerEntersVehicle(player)
	if l_cigar[player] then
		if isElement(l_cigar[player]) then
			destroyElement(l_cigar[player])
		end
		l_cigar[player] = nil
	end

	if r_cigar[player] then
		if isElement(r_cigar[player]) then
			destroyElement(r_cigar[player])
		end
		r_cigar[player] = nil
	end
end

function removeSigOnExit()
	playerExitsVehicle(source)
end
addEventHandler("onPlayerQuit", root, removeSigOnExit)

function syncCigarette(state, hand)
	if isElement(source) then
		if state then
			setSmoking(source, true, hand)
		else
			setSmoking(source, false, hand)
		end
	end
end
addEvent("realism.smokingSync", true)
addEventHandler("realism.smokingSync", root, syncCigarette)

addEventHandler("onClientResourceStart", resourceRoot, function(startedRes)
	triggerServerEvent("realism.smoking.request", localPlayer)
end)

function createCigarModel(player, model)
	if l_cigar[player] ~= nil then
		local currobject = l_cigar[player]
		if isElement(currobject) then
			destroyElement(currobject)
			l_cigar[player] = nil
		end
	end

	local object = createObject(model, 0, 0, 0)
	setElementCollisionsEnabled(object, false)

	return object
end

function updateCig()
	isLocalPlayerSmokingBool = false

	for player, object in pairs(l_cigar) do
		if isElement(player) then
			if player == localPlayer then
				isLocalPlayerSmokingBool = true
			end

			local bx, by, bz = getPedBonePosition(player, 36)
			local x, y, z = getElementPosition(player)
			local rotation = getPedRotation(player)
			local interior = getElementInterior(player)
			local dimension = getElementDimension(player)
			rotation = rotation + 300
			if rotation > 360 then
				rotation = rotation - 360
			end

			setElementPosition(object, bx, by, bz)
			setElementRotation(object, 60, 270, rotation)
			setElementInterior(object, interior)
			setElementDimension(object, dimension)
		end
	end

	for player, object in pairs(r_cigar) do
		if isElement(player) then
			if player == localPlayer then
				isLocalPlayerSmokingBool = true
			end
			local bx, by, bz = getPedBonePosition(player, 26)
			local x, y, z = getElementPosition(player)
			local rotation = getPedRotation(player)
			local interior = getElementInterior(player)
			local dimension = getElementDimension(player)
			rotation = rotation + 100
			if rotation > 360 then
				rotation = rotation - 360
			end

			setElementPosition(object, bx, by, bz)
			setElementRotation(object, -60, 50, rotation - 60)
			setElementInterior(object, interior)
			setElementDimension(object, dimension)
		end
	end
end
addEventHandler("onClientPreRender", root, updateCig)

function isLocalPlayerSmoking()
	return isLocalPlayerSmokingBool
end
