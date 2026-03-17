local sounds = {}

local function createSirenSound(vehicle)
	if not isElement(vehicle) or not getElementData(vehicle, "legal_siren") then
		return
	end

	local sirenName = getElementData(vehicle, "legal_siren")
	if not sirenName or sirenName == false then
		return
	end

	if sounds[vehicle] and isElement(sounds[vehicle]) then
		destroyElement(sounds[vehicle])
		sounds[vehicle] = nil
	end

	local sound = playSound3D("public/sounds/sirens/" .. sirenName .. ".wav", 0, 0, 0, true)
	setElementInterior(sound, getElementInterior(vehicle))
	setElementDimension(sound, getElementDimension(vehicle))
	attachElements(sound, vehicle)
	setSoundVolume(sound, 0.4)
	setSoundMaxDistance(sound, 200)
	setSoundEffectEnabled(sound, "parameq", true)

	sounds[vehicle] = sound
end

local function destroySirenSound(vehicle)
	if sounds[vehicle] and isElement(sounds[vehicle]) then
		destroyElement(sounds[vehicle])
	end
	sounds[vehicle] = nil
end

addEventHandler("onClientResourceStart", resourceRoot, function()
	for i = 1, 8 do
		bindKey("num_" .. i, "down", cycleSirens)
	end
	bindKey("n", "down", cycleSirens)

	for _, vehicle in ipairs(getElementsByType("vehicle")) do
		if isElementStreamedIn(vehicle) and getElementData(vehicle, "legal_siren") then
			createSirenSound(vehicle)
		end
	end
end)

addEventHandler("onClientElementStreamIn", root, function()
	if getElementType(source) == "vehicle" then
		if getElementData(source, "legal_siren") then
			createSirenSound(source)
		else
			destroySirenSound(source)
		end
	end
end)

addEventHandler("onClientElementStreamOut", root, function()
	if getElementType(source) == "vehicle" then
		destroySirenSound(source)
	end
end)

function cycleSirens(_, _)
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if not vehicle then
		return
	end
	if getVehicleOccupant(vehicle) ~= localPlayer then
		return
	end

	local sirenID = nil
	if getKeyState("n") then
		sirenID = 1
	else
		for i = 1, 8 do
			if getKeyState("num_" .. i) then
				sirenID = i
				break
			end
		end
	end

	if sirenID then
		triggerServerEvent("legal.setSirenState", localPlayer, vehicle, sirenID)
	end
end

addEventHandler("onClientElementDataChange", root, function(dataName)
	if dataName == "legal_siren" and getElementType(source) == "vehicle" then
		if getElementData(source, "legal_siren") then
			createSirenSound(source)
		else
			destroySirenSound(source)
		end
	end
end)

addEventHandler("onClientPlayerVehicleExit", root, function(vehicle)
	if sounds[vehicle] then
		local occupants = getVehicleOccupants(vehicle)
		if not occupants or next(occupants) == nil then
			setElementData(vehicle, "legal_siren", false)
		end
	end
end)
