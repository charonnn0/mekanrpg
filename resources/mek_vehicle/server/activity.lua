local loadingPlayers = {}

-- Otopark alanı kontrolü yerine her yerde kullanılabilir
addEvent("vehicle.getVehicleData", true)
addEventHandler("vehicle.getVehicleData", root, function(playerDBID, playerFaction, playerName)
    local clientPlayer = client
    if clientPlayer and clientPlayer ~= source then
        exports.mek_sac:banForEventAbuse(clientPlayer, eventName)
        return
    end

    if loadingPlayers[clientPlayer] then
        outputChatBox("[!]#FFFFFF Araç verileri zaten yükleniyor, lütfen bekleyin.", clientPlayer, 0, 0, 255, true)
        return
    end

    loadingPlayers[clientPlayer] = true

    local isAdminQuery = playerDBID ~= false

    if isAdminQuery then
        if not exports.mek_integration:isPlayerManager(clientPlayer) then
            exports.mek_sac:banForEventAbuse(clientPlayer, eventName)
            loadingPlayers[clientPlayer] = nil
            return
        end
    else
        playerDBID = getElementData(clientPlayer, "dbid")
        playerFaction = getElementData(clientPlayer, "faction")
        playerName = getPlayerName(clientPlayer)
    end

    local whereClauses = { "owner = ?" }
    local queryArgs = { playerDBID }

    if type(playerFaction) == "table" and next(playerFaction) then
        local factionIDs = {}
        for factionID in pairs(playerFaction) do
            table.insert(factionIDs, tonumber(factionID))
        end

        if #factionIDs > 0 then
            local placeholders = table.concat({
                unpack((function()
                    local t = {}
                    for _ = 1, #factionIDs do
                        table.insert(t, "?")
                    end
                    return t
                end)()),
            }, ", ")

            table.insert(whereClauses, "faction IN (" .. placeholders .. ")")
            for _, id in ipairs(factionIDs) do
                table.insert(queryArgs, id)
            end
        end
    end

    local finalQuery = "SELECT id, faction, activity, deleted, vehicle_shop_id FROM vehicles WHERE "
        .. table.concat(whereClauses, " OR ")

    dbQuery(function(queryHandle)
        local results = dbPoll(queryHandle, 0)
        if not results or #results == 0 then
            triggerClientEvent(clientPlayer, "vehicle.showVehicleData", clientPlayer, {}, playerName)
            loadingPlayers[clientPlayer] = nil
            return
        end

        local vehiclesData, pending = {}, #results
        for _, data in ipairs(results) do
            local vehicleID, faction, activity, deleted, shopID =
                data.id, data.faction, data.activity, data.deleted, data.vehicle_shop_id

            dbQuery(
                function(shopQueryHandle)
                    local shopRes = dbPoll(shopQueryHandle, 0)
                    if shopRes and shopRes[1] then
                        local shop = shopRes[1]
                        local name = ("%s %s %s"):format(shop.vehyear, shop.vehbrand, shop.vehmodel)

                        table.insert(vehiclesData, {
                            vehicleID,
                            name,
                            activity ~= 1 and "İnaktif" or "Aktif",
                            faction,
                            deleted,
                        })
                    end

                    pending = pending - 1

                    if pending == 0 then
                        triggerClientEvent(
                            clientPlayer,
                            "vehicle.showVehicleData",
                            clientPlayer,
                            vehiclesData,
                            playerName
                        )
                        loadingPlayers[clientPlayer] = nil
                    end
                end,
                exports.mek_mysql:getConnection(),
                "SELECT vehyear, vehbrand, vehmodel FROM vehicles_shop WHERE id = ?",
                shopID
            )
        end
    end, exports.mek_mysql:getConnection(), finalQuery, unpack(queryArgs))
end)

addEvent("vehicle.activeVehicle", true)
addEventHandler("vehicle.activeVehicle", root, function(vehicleID)
    local clientPlayer = client
    if clientPlayer and clientPlayer ~= source then
        exports.mek_sac:banForEventAbuse(clientPlayer, eventName)
        return
    end

    -- Otopark alanı kontrolü kaldırıldı, her yerde kullanılabilir

    if isPedInVehicle(clientPlayer) then
        outputChatBox("[!]#FFFFFF Bu işlemi araç içerisindeyken kullanamazsınız.", clientPlayer, 255, 0, 0, true)
        return
    end

    local result = dbPoll(
        dbQuery(
            exports.mek_mysql:getConnection(),
            "SELECT owner, faction, deleted, activity, x, y, z, rotx, roty, rotz, interior, dimension FROM vehicles WHERE id = ? LIMIT 1",
            vehicleID
        ),
        -1
    )
    if result and #result > 0 then
        local vehicleOwner = tonumber(result[1].owner)
        local vehicleFaction = tonumber(result[1].faction)
        local vehicleActivity = tonumber(result[1].activity)
        local playerDBID = getElementData(clientPlayer, "dbid")

        if vehicleOwner ~= playerDBID and not exports.mek_faction:isPlayerInFaction(clientPlayer, vehicleFaction) then
            outputChatBox("[!]#FFFFFF Bu araç size ait değil.", clientPlayer, 255, 0, 0, true)
            return
        end

        if vehicleActivity == 1 then
            outputChatBox("[!]#FFFFFF Bu araç zaten aktif.", clientPlayer, 255, 0, 0, true)
            return
        end

        if tonumber(result[1].deleted) > 0 then
            outputChatBox("[!]#FFFFFF Bu araç silinmiş, aktif edilemez.", clientPlayer, 255, 0, 0, true)
            return
        end

        -- Aracı aktif et
        if dbExec(exports.mek_mysql:getConnection(), "UPDATE vehicles SET activity = 1 WHERE id = ?", vehicleID) then
            loadOneVehicle(vehicleID)

            local checksLeft = 20
            local checkInterval = 100
            local vehicleLoadTimer

            local function checkVehicleLoaded()
                local theVehicle = exports.mek_pool:getElementByID("vehicle", vehicleID)

                if theVehicle then
                    -- MySQL'de kayıtlı konumda spawn et
                    local x, y, z = result[1].x, result[1].y, result[1].z
                    local rx, ry, rz = result[1].rotx, result[1].roty, result[1].rotz
                    local interior = result[1].interior or 0
                    local dimension = result[1].dimension or 0
                    
                    setElementPosition(theVehicle, x, y, z)
                    setElementRotation(theVehicle, rx, ry, rz)
                    setElementInterior(theVehicle, interior)
                    setElementDimension(theVehicle, dimension)

                    outputChatBox(
                        "[!]#FFFFFF Başarıyla [" .. vehicleID .. "] ID'li aracınız aktif edildi.",
                        clientPlayer,
                        0,
                        255,
                        0,
                        true
                    )
                    
                    if isTimer(vehicleLoadTimer) then
                        killTimer(vehicleLoadTimer)
                    end
                    return true
                else
                    checksLeft = checksLeft - 1
                    if checksLeft <= 0 then
                        outputChatBox(
                            "[!]#FFFFFF Araç yüklenemedi veya geçersiz araç.",
                            clientPlayer,
                            255,
                            0,
                            0,
                            true
                        )
                        if isTimer(vehicleLoadTimer) then
                            killTimer(vehicleLoadTimer)
                        end
                        return true
                    end
                    return false
                end
            end

            vehicleLoadTimer = setTimer(function()
                checkVehicleLoaded()
            end, checkInterval, 0)
        else
            outputChatBox("[!]#FFFFFF Araç veritabanı güncelleme hatası.", clientPlayer, 255, 0, 0, true)
        end
    else
        outputChatBox("[!]#FFFFFF Araç veritabanında bulunamadı.", clientPlayer, 255, 0, 0, true)
    end
end)

addEvent("vehicle.inactiveVehicle", true)
addEventHandler("vehicle.inactiveVehicle", root, function(vehicleID)
    local clientPlayer = client
    if clientPlayer and clientPlayer ~= source then
        exports.mek_sac:banForEventAbuse(clientPlayer, eventName)
        return
    end

    -- Otopark alanı kontrolü kaldırıldı, her yerde kullanılabilir

    local theVehicle = exports.mek_pool:getElementByID("vehicle", vehicleID)
    if theVehicle then
        local vehicleOwner = getElementData(theVehicle, "owner")
        local vehicleFaction = getElementData(theVehicle, "faction")
        local playerDBID = getElementData(clientPlayer, "dbid")

        if vehicleOwner ~= playerDBID and not exports.mek_faction:isPlayerInFaction(clientPlayer, vehicleFaction) then
            outputChatBox("[!]#FFFFFF Bu araç size ait değil.", clientPlayer, 255, 0, 0, true)
            return
        end

        if vehicleOwner ~= playerDBID then
            for seat = 0, getVehicleMaxPassengers(theVehicle) do
                local occupant = getVehicleOccupant(theVehicle, seat)
                if occupant then
                    outputChatBox("[!]#FFFFFF Araçta biri bulunduğu için, sahibi olmadığınız aracı inaktif yapamazsınız.", clientPlayer, 255, 0, 0, true)
                    return
                end
            end
        end

        -- Aracın son konumunu kaydet
        local x, y, z = getElementPosition(theVehicle)
        local rx, ry, rz = getElementRotation(theVehicle)
        local interior = getElementInterior(theVehicle)
        local dimension = getElementDimension(theVehicle)
        
        if dbExec(exports.mek_mysql:getConnection(), 
            "UPDATE vehicles SET activity = 0, x = ?, y = ?, z = ?, rotx = ?, roty = ?, rotz = ?, currx = ?, curry = ?, currz = ?, interior = ?, dimension = ? WHERE id = ?", 
            x, y, z, rx, ry, rz, x, y, z, interior, dimension, vehicleID) then
            
            destroyElement(theVehicle)
            outputChatBox(
                "[!]#FFFFFF Başarıyla [" .. vehicleID .. "] ID'li aracınız inaktif edildi.",
                clientPlayer,
                0,
                255,
                0,
                true
            )
        else
            outputChatBox("[!]#FFFFFF Araç veritabanı güncelleme hatası.", clientPlayer, 255, 0, 0, true)
        end
    else
        local result = dbPoll(
            dbQuery(
                exports.mek_mysql:getConnection(),
                "SELECT owner, faction, activity FROM vehicles WHERE id = ? LIMIT 1",
                vehicleID
            ),
            -1
        )
        if result and #result > 0 then
            local vehicleOwner = tonumber(result[1].owner)
            local vehicleFaction = tonumber(result[1].faction)
            local vehicleActivity = tonumber(result[1].activity)

            if vehicleOwner ~= playerDBID and not exports.mek_faction:isPlayerInFaction(clientPlayer, vehicleFaction) then
                outputChatBox("[!]#FFFFFF Bu araç size ait değil.", clientPlayer, 255, 0, 0, true)
                return
            end

            if vehicleActivity == 0 then
                outputChatBox("[!]#FFFFFF Bu araç zaten inaktif.", clientPlayer, 255, 0, 0, true)
                return
            end

            if dbExec(exports.mek_mysql:getConnection(), "UPDATE vehicles SET activity = 0 WHERE id = ?", vehicleID) then
                outputChatBox(
                    "[!]#FFFFFF Başarıyla [" .. vehicleID .. "] ID'li aracınız inaktif edildi.",
                    clientPlayer,
                    0,
                    255,
                    0,
                    true
                )
            else
                outputChatBox("[!]#FFFFFF Araç veritabanı güncelleme hatası.", clientPlayer, 255, 0, 0, true)
            end
        else
            outputChatBox("[!]#FFFFFF Geçersiz araç ID veya aracınız /aracpanel ile aktifleştiriniz.", clientPlayer, 255, 0, 0, true)
        end
    end
end)

addEventHandler("onPlayerQuit", root, function()
    if loadingPlayers[source] then
        loadingPlayers[source] = nil
    end
end)

-- Yeni komut: aracpanel
addCommandHandler("aracpanel", function(player, _, targetPlayer)
    if loadingPlayers[player] then
        outputChatBox("[!]#FFFFFF Araç verileri zaten yükleniyor, lütfen bekleyin.", player, 0, 0, 255, true)
        return
    end

    loadingPlayers[player] = true

    if targetPlayer and exports.mek_integration:isPlayerManager(player) then
        local target = exports.mek_global:findPlayerByPartialNick(player, targetPlayer)
        if target then
            local dbid = getElementData(target, "dbid") or 0
            local faction = getElementData(target, "faction") or 0
            triggerEvent("vehicle.getVehicleData", player, dbid, faction, target:getName())
        else
            outputChatBox("[!]#FFFFFF Belirtilen oyuncu bulunamadı.", player, 255, 0, 0, true)
            loadingPlayers[player] = nil
        end
    else
        triggerEvent("vehicle.getVehicleData", player, false, getElementData(player, "faction"), getPlayerName(player))
    end
end)