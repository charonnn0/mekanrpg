local positions = {
	{ x = 513.517578125, y = -1330.0185546875, width = 65, depth = 75, name = "Zengin Galeri" },
	{ x = 2111.4921875, y = -1163.078125, width = 50, depth = 50, name = "Orta Galeri" },
	{ x = 2102.7392578125, y = -2173.4248046875, width = 60, depth = 55, name = "Fakir Galeri" },
	{ x = 666.115234375, y =  -1922.3242187, width = 1755, depth = 900, name = "Hastane" },
	{ x = 1555.7275390625, y = 1772.435546875, width = 110, depth = 105, name = "Hastane İci" },
	{ x = 1904.0537109375, y = -1796.6904296875, width = 110, depth = 105, name = "Hastane İci" },
	{ x = 1862.263671875, y = -1270.1494140625, width = 110, depth = 105, name = "Cicek Toplama" },
    { x = 1862.263671875, y = -1270.1494140625, width = 110, depth = 105, name = "Cicek Toplama" },
}
local safezones = {}

addEventHandler("onResourceStart", resourceRoot, function()
	if positions and #positions ~= 0 then
		for _, value in ipairs(positions) do
			if value then
				if value.x and value.y and value.width and value.depth then
					local colCuboid = createColCuboid(value.x, value.y, -50, value.width, value.depth, 10000)
					local radarArea = createRadarArea(value.x, value.y, value.width, value.depth, 0, 255, 0, 150)
					setElementParent(radarArea, colCuboid)
					if colCuboid then
						safezones[colCuboid] = true

						for _, player in ipairs(getElementsWithinColShape(colCuboid, "player")) do
							setElementData(player, "safezone", true)
						end

						addEventHandler("onElementDestroy", colCuboid, function()
							if safezones[source] then
								safezones[source] = nil
							end
						end)

						addEventHandler("onColShapeHit", colCuboid, function(element, dimension)
							if element and dimension and isElement(element) and getElementType(element) == "player" then
								setElementData(element, "safezone", true)
							end
						end)

						addEventHandler("onColShapeLeave", colCuboid, function(element, dimension)
							if element and dimension and isElement(element) and getElementType(element) == "player" then
								removeElementData(element, "safezone")
							end
						end)
					end
				end
			end
		end
	end
end)

addEventHandler("onResourceStop", resourceRoot, function()
	for _, player in ipairs(getElementsByType("player")) do
		if isElement(player) then
			removeElementData(player, "safezone")
		end
	end
end)

function interiorAndDimensionChange()
	if getElementType(source) == "player" then
		removeElementData(source, "safezone")

		for colCuboid, _ in pairs(safezones) do
			for _, player in ipairs(getElementsWithinColShape(colCuboid, "player")) do
				setElementData(player, "safezone", true)
			end
		end
	end
end
addEventHandler("onElementInteriorChange", root, interiorAndDimensionChange)
addEventHandler("onElementDimensionChange", root, interiorAndDimensionChange)



local legalFactions = { [1] = true, [3] = true }

function isLegalFaction(player)
    local faction = getElementData(player, "faction")
    if type(faction) == "table" then
        if faction[1] or faction[3] then
            return true
        end
        for k, v in pairs(faction) do
            if tonumber(k) == 1 or tonumber(k) == 3 then
                return true
            end
        end
    elseif type(faction) == "number" or type(faction) == "string" then
        return legalFactions[tonumber(faction)]
    end
    return false
end

addEventHandler("onPlayerDamage", root, function(attacker, weapon, bodypart, loss)
    if getElementData(source, "safezone") then
        if attacker and isElement(attacker) and getElementType(attacker) == "player" then
            if not isLegalFaction(attacker) then
                cancelEvent()
            end
        else
            cancelEvent()
        end
    end

    if attacker and isElement(attacker) and getElementType(attacker) == "player" then
        if getElementData(attacker, "safezone") then
             local isLegal = isLegalFaction(attacker)
             local victimInSafe = getElementData(source, "safezone")
             
            if not isLegal then
                cancelEvent()
            elseif not victimInSafe then
                cancelEvent()
            end
        end
    end
end)
