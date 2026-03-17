addEvent("hizTabelaGoster", true)
addEvent("hizTabelaGizle", true)

-- TÜM HIZ ALANLARI
local hizAlanlari = {
    -- 1. Alan
    {
        x1 = 1331.4462890625, y1 = -2227.9375, z1 = 12,
        x2 = 1371.9541015625, y2 = -2171.60546875, z2 = 20
    },

    -- 2. Alan (YENİ)
    {
        x1 = 1805.232421875, y1 = -1487.26171875, z1 = 3,
        x2 = 2250.0302734375, y2 = -1602.162109375, z2 = 10
    },

	{
        x1 = 2015, y1 = -1785, z1 = 12,
        x2 = 2060, y2 = -1735, z2 = 20
    },
	{
        x1 = 2187.3173828125, y1 = -1746.9443359375, z1 = 12,
        x2 = 1830.046875, y2 = -1756.49609375, z2 = 20
    }
  
}


-- Colshape oluşturma
for _, alan in ipairs(hizAlanlari) do
    local minX = math.min(alan.x1, alan.x2)
    local minY = math.min(alan.y1, alan.y2)
    local minZ = math.min(alan.z1, alan.z2)

    local sizeX = math.abs(alan.x1 - alan.x2)
    local sizeY = math.abs(alan.y1 - alan.y2)
    local sizeZ = math.abs(alan.z1 - alan.z2)

    local col = createColCuboid(minX, minY, minZ, sizeX, sizeY, sizeZ)

    -- Girince
    addEventHandler("onColShapeHit", col, function(player, dim)
        if getElementType(player) == "player" and dim then
            triggerClientEvent(player, "hizTabelaGoster", player)
        end
    end)

    -- Çıkınca
    addEventHandler("onColShapeLeave", col, function(player, dim)
        if getElementType(player) == "player" and dim then
            triggerClientEvent(player, "hizTabelaGizle", player)
        end
    end)
end
