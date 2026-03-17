local AVAILABLE_INTERACTION_TYPES = { "pickup", "object", "ped", "vehicle", "player" }

local cacheCollectorFactory = {
	vehicle = {
		garbage = vehicleCacheGarbage,
		collector = vehicleCacheCollector,
	},
}

interactedElements = {}

MAX_DISTANCE = 4

setTimer(function()
	local playerPosition = localPlayer.position
	interactedElements = {}
	occupiedVehicle = localPlayer:getOccupiedVehicle()

	for _, interactionType in ipairs(AVAILABLE_INTERACTION_TYPES) do
		local interactionElements = getElementsWithinRange(
			playerPosition,
			MAX_DISTANCE,
			interactionType,
			localPlayer.interior,
			localPlayer.dimension
		)
	
		local specialFactory = cacheCollectorFactory[interactionType]
		if specialFactory then
			pcall(specialFactory.garbage)
		end
	
		for _, element in ipairs(interactionElements) do
			if specialFactory then
				pcall(specialFactory.collector, element)
			else
				local distance = getDistanceBetweenPoints3D(playerPosition, element.position)
				local interaction = getElementData(element, "interaction")

				if interaction and distance <= 3 then
					table.insert(interactedElements, {
						element = element,
						store = interaction,
					})
					break
				end
			end
		end
	end
end, 0, 0)
