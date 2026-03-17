local INDICATOR_SIZE = 0.32
local INDICATOR_COLOR = { 255, 100, 10, 255 }
local INDICATOR_FADE_MS = 150
local INDICATOR_SWITCH_TIMES = { 300, 400 }
local INDICATOR_AUTOSWITCH_OFF_THRESHOLD = 62

local root = getRootElement()
local localPlayer = getLocalPlayer()
local vehiclesWithIndicator = {}

INDICATOR_AUTOSWITCH_OFF_THRESHOLD = INDICATOR_AUTOSWITCH_OFF_THRESHOLD / 90

local function vectorLength(vector)
	return math.sqrt(vector[1] * vector[1] + vector[2] * vector[2] + vector[3] * vector[3])
end

local function normalizeVector(vector)
	local length = vectorLength(vector)
	if length > 0 then
		local normalizedVector = {}
		normalizedVector[1] = vector[1] / length
		normalizedVector[2] = vector[2] / length
		normalizedVector[3] = vector[3] / length
		return normalizedVector, length
	else
		return nil, length
	end
end

local function crossProduct(v, w)
	local result = {}
	result[1] = v[2] * w[3] - v[3] * w[2]
	result[2] = w[1] * v[3] - w[3] * v[1]
	result[3] = v[1] * w[2] - v[2] * w[1]
	return result
end

local function getFakeVelocity(vehicle)
	local _, _, angle = getElementRotation(vehicle)
	local velocity = { 0, 0, 0 }
	velocity[1] = -math.sin(angle)
	velocity[2] = math.cos(angle)
	return velocity
end

local function createIndicator()
	local x, y, z = getElementPosition(localPlayer)
	local indicator = createMarker(
		x,
		y,
		z + 4,
		"corona",
		INDICATOR_SIZE,
		INDICATOR_COLOR[1],
		INDICATOR_COLOR[2],
		INDICATOR_COLOR[3],
		0
	)
	setElementStreamable(indicator, false)
	return indicator
end

local function createIndicatorState(vehicle, indicatorLeft, indicatorRight)
	local t = {
		vehicle = vehicle,
		left = indicatorLeft,
		right = indicatorRight,
		coronaLeft = nil,
		coronaRight = nil,
		nextChange = 0,
		timeElapsed = 0,
		currentState = false,
		activationDir = nil,
	}
	return t
end

local function updateIndicatorState(state)
	if not state then
		return
	end

	local numberOfIndicators = 0

	local xmin, ymin, zmin, xmax, ymax, zmax = getElementBoundingBox(state.vehicle)

	xmin = xmin + 0.2
	xmax = xmax - 0.2
	ymin = ymin + 0.2
	ymax = ymax - 0.2
	zmin = zmin + 0.6

	if state.left then
		if not state.coronaLeft then
			state.coronaLeft = { createIndicator(), createIndicator() }
			attachElements(state.coronaLeft[1], state.vehicle, xmin, ymax, zmin)
			attachElements(state.coronaLeft[2], state.vehicle, xmin, -ymax, zmin)
		end
		numberOfIndicators = numberOfIndicators + 1
	elseif state.coronaLeft then
		destroyElement(state.coronaLeft[1])
		destroyElement(state.coronaLeft[2])
		state.coronaLeft = nil
	end

	if state.right then
		if not state.coronaRight then
			state.coronaRight = { createIndicator(), createIndicator() }
			attachElements(state.coronaRight[1], state.vehicle, -xmin, ymax, zmin)
			attachElements(state.coronaRight[2], state.vehicle, -xmin, -ymax, zmin)
		end
		numberOfIndicators = numberOfIndicators + 1
	elseif state.coronaRight then
		destroyElement(state.coronaRight[1])
		destroyElement(state.coronaRight[2])
		state.coronaRight = nil
	end

	if numberOfIndicators == 1 and getVehicleOccupant(state.vehicle, 0) == localPlayer then
		state.activationDir = normalizeVector({ getElementVelocity(state.vehicle) })
		if not state.activationDir then
			state.activationDir = getFakeVelocity(state.vehicle)
		end
	else
		state.activationDir = nil
	end
end

local function destroyIndicatorState(state)
	if not state then
		return
	end

	if state.coronaLeft then
		destroyElement(state.coronaLeft[1])
		destroyElement(state.coronaLeft[2])
		state.coronaLeft = nil
	end

	if state.coronaRight then
		destroyElement(state.coronaRight[1])
		destroyElement(state.coronaRight[2])
		state.coronaRight = nil
	end

	if getVehicleOccupant(state.vehicle) == localPlayer then
		setElementData(state.vehicle, "i:left", false, true)
		setElementData(state.vehicle, "i:right", false, true)
	end
end

local function performIndicatorChecks(vehicle)
	local indicatorLeft = getElementData(vehicle, "i:left")
	local indicatorRight = getElementData(vehicle, "i:right")

	local anyIndicator = indicatorLeft or indicatorRight
	local currentState = vehiclesWithIndicator[vehicle]

	if anyIndicator then
		if currentState then
			currentState.left = indicatorLeft
			currentState.right = indicatorRight
		else
			currentState = createIndicatorState(vehicle, indicatorLeft, indicatorRight)
			vehiclesWithIndicator[vehicle] = currentState
		end
		updateIndicatorState(currentState)
	elseif currentState then
		destroyIndicatorState(currentState)
		vehiclesWithIndicator[vehicle] = nil
	end
end

local function setIndicatorsAlpha(state, alpha)
	if state.coronaLeft then
		setMarkerColor(state.coronaLeft[1], INDICATOR_COLOR[1], INDICATOR_COLOR[2], INDICATOR_COLOR[3], alpha)
		setMarkerColor(state.coronaLeft[2], INDICATOR_COLOR[1], INDICATOR_COLOR[2], INDICATOR_COLOR[3], alpha)
	end
	if state.coronaRight then
		setMarkerColor(state.coronaRight[1], INDICATOR_COLOR[1], INDICATOR_COLOR[2], INDICATOR_COLOR[3], alpha)
		setMarkerColor(state.coronaRight[2], INDICATOR_COLOR[1], INDICATOR_COLOR[2], INDICATOR_COLOR[3], alpha)
	end
end

local function processIndicators(state)
	if getElementHealth(state.vehicle) == 0 then
		destroyIndicatorState(state)
		vehiclesWithIndicator[state.vehicle] = nil
		return
	end

	if state.activationDir then
		local currentVelocity = normalizeVector({ getElementVelocity(state.vehicle) })
		if not currentVelocity then
			currentVelocity = getFakeVelocity(state.vehicle)
		end

		local cross = crossProduct(state.activationDir, currentVelocity)
		local length = vectorLength(cross)

		if length > INDICATOR_AUTOSWITCH_OFF_THRESHOLD then
			destroyIndicatorState(state)
			vehiclesWithIndicator[state.vehicle] = nil
			return
		end
	end

	if state.nextChange <= state.timeElapsed then
		setIndicatorsAlpha(state, INDICATOR_COLOR[4])

		state.currentState = not state.currentState

		local playerVehicle = getPedOccupiedVehicle(localPlayer)

		state.timeElapsed = 0
		if state.currentState then
			state.nextChange = INDICATOR_SWITCH_TIMES[1]
		else
			state.nextChange = INDICATOR_SWITCH_TIMES[2]
		end
	elseif state.currentState == false then
		if state.timeElapsed >= INDICATOR_FADE_MS then
			setIndicatorsAlpha(state, 0)
		else
			setIndicatorsAlpha(state, (1 - (state.timeElapsed / INDICATOR_FADE_MS)) * INDICATOR_COLOR[4])
		end
	end
end

addEventHandler("onClientElementDataChange", root, function(dataName, oldValue)
	if getElementType(source) == "vehicle" and (dataName == "i:left" or dataName == "i:right") then
		if isElementStreamedIn(source) then
			performIndicatorChecks(source)
		end
	end
end)

addEventHandler("onClientElementStreamIn", root, function()
	if getElementType(source) == "vehicle" then
		performIndicatorChecks(source)
	end
end)

addEventHandler("onClientElementStreamOut", root, function()
	if getElementType(source) == "vehicle" then
		local currentState = vehiclesWithIndicator[source]
		if currentState then
			destroyIndicatorState(currentState)
			vehiclesWithIndicator[source] = nil
		end
	end
end)

local function switchIndicatorState(indicator)
	local v = getPedOccupiedVehicle(localPlayer)
	if v then
		if getVehicleType(v) == "Automobile" or getVehicleType(v) == "Bike" or getVehicleType(v) == "Quad" then
			if getVehicleOccupant(v, 0) == localPlayer then
				local dataName = "i:" .. indicator
				local currentValue = getElementData(v, dataName) or false

				setElementData(v, dataName, not currentValue, true)
			end
		end
	end
end

addCommandHandler("indicator_left", function()
	switchIndicatorState("left")
end, false)

addCommandHandler("indicator_right", function()
	switchIndicatorState("right")
end, false)

addEventHandler("onClientPreRender", root, function(timeSlice)
	for vehicle, state in pairs(vehiclesWithIndicator) do
		state.timeElapsed = state.timeElapsed + timeSlice
		processIndicators(state, state.lastChange)
	end
end)

function handleKeyBind(keyPressed, keyState)
	if keyPressed == "[" then
		switchIndicatorState("left")
	elseif keyPressed == "]" then
		switchIndicatorState("right")
	end
end

addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), function()
	local vehicles = getElementsByType("vehicle")
	for k, vehicle in ipairs(vehicles) do
		if isElementStreamedIn(vehicle) then
			local indicatorLeft = getElementData(vehicle, "i:left")
			local indicatorRight = getElementData(vehicle, "i:right")
			if indicatorLeft or indicatorRight then
				performIndicatorChecks(vehicle)
			end
		end
	end

	bindKey("[", "down", handleKeyBind)
	bindKey("]", "down", handleKeyBind)
end, false)

addEventHandler("onClientVehicleRespawn", root, function()
	if isElementStreamedIn(source) then
		performIndicatorChecks(source)
	end
end)

addEventHandler("onClientElementDestroy", root, function()
	if getElementType(source) == "vehicle" then
		local currentState = vehiclesWithIndicator[source]
		if currentState then
			destroyIndicatorState(currentState)
			vehiclesWithIndicator[source] = nil
		end
	end
end)
