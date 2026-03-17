local VALID_TYPES = {
	"player",
	"interior",
	"elevator",
	"vehicle",
	"colshape",
	"ped",
	"marker",
	"object",
	"pickup",
	"team",
	"blip",
}

local ID_BASED_TYPES = {
	player = true,
	interior = true,
	elevator = true,
	vehicle = true,
	team = true,
	ped = true,
}

local ID_ELEMENT_KEYS = {
	player = "id",
	interior = "id",
	elevator = "id",
	vehicle = "id",
	team = "id",
	ped = "id",
}

local poolTable = {}
local indexedPools = {}

for _, type in ipairs(VALID_TYPES) do
	poolTable[type] = {}
	if ID_BASED_TYPES[type] then
		indexedPools[type] = {}
	end
end

local function isValidType(elementType)
	return poolTable[elementType] ~= nil
end

function showPoolSize(player)
	if not exports.mek_integration:isPlayerServerManager(player) then
		return
	end

	outputChatBox("------ POOLED ELEMENTS ------", player)
	for _, type in ipairs(VALID_TYPES) do
		local pooledCount = #poolTable[type]
		local totalCount = type == "pickup" and #getElementsByType("pickup")
			or getPoolElementsByType(type)
			or #getElementsByType(type)
		outputChatBox(type:upper() .. ": " .. pooledCount .. "/" .. totalCount, player)
	end
	outputChatBox("-----------------------------", player)
end
addCommandHandler("poolsize", showPoolSize, false, false)

function deallocateElement(element)
	local elementType = getElementType(element)
	if not isValidType(elementType) then
		return
	end

	local pool = poolTable[elementType]
	for i = #pool, 1, -1 do
		if pool[i] == element then
			table.remove(pool, i)
		end
	end

	if indexedPools[elementType] then
		local idKey = ID_ELEMENT_KEYS[elementType]
		local id = tonumber(getElementData(element, idKey))
		if id and indexedPools[elementType][id] == element then
			indexedPools[elementType][id] = nil
		else
			for key, value in pairs(indexedPools[elementType]) do
				if value == element then
					indexedPools[elementType][key] = nil
					break
				end
			end
		end
	end
end

function allocateElement(element, id, skipChildren)
	if not isElement(element) then
		return
	end

	local elementType = getElementType(element)
	if not isValidType(elementType) then
		return
	end

	deallocateElement(element)
	table.insert(poolTable[elementType], element)

	if indexedPools[elementType] then
		id = id or tonumber(getElementData(element, ID_ELEMENT_KEYS[elementType]))
		if id then
			indexedPools[elementType][id] = element
		end
	end

	if not skipChildren then
		for _, child in ipairs(getElementChildren(element)) do
			allocateElement(child)
		end
	end
end

function getPoolElementsByType(elementType)
	return isValidType(elementType) and poolTable[elementType] or false
end

function getElementByID(elementType, id)
	return indexedPools[elementType] and indexedPools[elementType][tonumber(id)]
end

addEventHandler("onResourceStop", resourceRoot, function()
	exports.mek_data:save(poolTable, "poolTable")
	exports.mek_data:save(indexedPools, "indexedPools")
end)

addEventHandler("onResourceStart", resourceRoot, function()
	local loadedPool = exports.mek_data:get("poolTable")
	if loadedPool then
		poolTable = loadedPool
	end

	local loadedIndexed = exports.mek_data:get("indexedPools")
	if loadedIndexed then
		indexedPools = loadedIndexed
	end

	if not indexedPools.ped then
		indexedPools.ped = {}
		outputDebugString("[POOL] Added missing indexed pool for peds.")
	end
end)

addEventHandler("onPlayerJoin", root, function()
	allocateElement(source)
end)

addEventHandler("onPlayerQuit", root, function()
	deallocateElement(source)
end)

addEventHandler("onElementDestroy", root, function()
	deallocateElement(source)
end)
