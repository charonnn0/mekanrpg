local function sortTable(a, b)
    if b[2] < a[2] then
        return true
    end
    return false
end

function showStaff(thePlayer, commandName)
    if getElementData(thePlayer, "logged") then
        local info = {}

        local managers = {}
        local managersCount = 0

        local admins = {}
        local adminsCount = 0

        for _, player in ipairs(getElementsByType("player")) do
            if not getElementData(player, "hidden") then -- Gizli olmayanları ekle
                if exports.mek_integration:isPlayerManager(player) then
                    managers[#managers + 1] = {
                        player,
                        getElementData(player, "admin_level"),
                    }
                end
            end
        end
        table.sort(managers, sortTable)

        for _, player in ipairs(getElementsByType("player")) do
            if not getElementData(player, "hidden") then -- Gizli olmayanları ekle
                if
                    exports.mek_integration:isPlayerTrialAdmin(player)
                    and not exports.mek_integration:isPlayerManager(player)
                then
                    admins[#admins + 1] = {
                        player,
                        getElementData(player, "admin_level"),
                    }
                end
            end
        end
        table.sort(admins, sortTable)

        table.insert(info, { "Yönetim Ekibi", true })
        table.insert(info, { "" })

        for _, value in ipairs(managers) do
            local player = value[1]
            if player then
                if getElementData(player, "duty_admin") then
                    table.insert(info, {
                        "#57ff6f"
                            .. exports.mek_global:getPlayerAdminTitle(player)
                            .. " "
                            .. getPlayerName(player):gsub("_", " ")
                            .. " ("
                            .. getElementData(player, "account_username")
                            .. ")",
                    })
                else
                    table.insert(info, {
                        "#585858"
                            .. exports.mek_global:getPlayerAdminTitle(player)
                            .. " "
                            .. getPlayerName(player):gsub("_", " ")
                            .. " ("
                            .. getElementData(player, "account_username")
                            .. ")",
                    })
                end
                managersCount = managersCount + 1
            end
        end

        if managersCount == 0 then
            table.insert(info, { "Aktif yönetim yok." })
        end

        table.insert(info, { "" })
        table.insert(info, { "Yetkili Ekibi", true })
        table.insert(info, { "" })

        for _, value in ipairs(admins) do
            local player = value[1]
            if player then
                if getElementData(player, "duty_admin") then
                    table.insert(info, {
                        "#57ff6f"
                            .. exports.mek_global:getPlayerAdminTitle(player)
                            .. " "
                            .. getPlayerName(player):gsub("_", " ")
                            .. " ("
                            .. getElementData(player, "account_username")
                            .. ")",
                    })
                else
                    table.insert(info, {
                        "#585858"
                            .. exports.mek_global:getPlayerAdminTitle(player)
                            .. " "
                            .. getPlayerName(player):gsub("_", " ")
                            .. " ("
                            .. getElementData(player, "account_username")
                            .. ")",
                    })
                end
                adminsCount = adminsCount + 1
            end
        end

        if adminsCount == 0 then
            table.insert(info, { "Aktif yetkili yok." })
        end

        table.insert(info, { "" })

        sendNotification(thePlayer, info)
    end
end
addCommandHandler("admin", showStaff, false, false)
addCommandHandler("admins", showStaff, false, false)