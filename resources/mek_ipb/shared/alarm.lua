g_HighUsageResources = {}

function saveHighCPUResources()
    if g_Settings["SaveHighCPUResources"] ~= "true" then
        return
    end

    local columns, rows = getPerformanceStats("Lua timing", "d")
    local saveHighCPUResourcesAmount = tonumber(g_Settings["SaveHighCPUResourcesAmount"]) or 10

    for index, row in ipairs(rows) do
        if not row[1]:find("^.@") then
            local usageText = row[2]:gsub("[^0-9%.]", "")
            local usage = math.floor(tonumber(usageText) or 0)

            if (usage > saveHighCPUResourcesAmount) then
                if usage > (tonumber(g_Settings["NotifyIPBUsersOfHighUsage"]) or 30) then
                    if triggerClientEvent then
                        local details = ""
                        local j = index + 1
                        while rows[j] and rows[j][1]:find("^.@") do
                            details = details .. "\n> " .. rows[j][1]:sub(2) .. " [" .. rows[j][2] .. "]"
                            j = j + 1
                            if j > index + 3 then break end
                        end

                        local msg = ("[IPB WARNING] Resource %q is using %s CPU%s"):format(row[1], row[2], details)
                        
                        if triggerClientEvent then
                            exports.mek_logs:addLog("ipb-log", msg)
                            
                            for _, player in ipairs(Element.getAllByType("player")) do
                                if hasIPBAccess(player) then
                                    outputChatBox(msg, player, 255, 100, 100, true)
                                end
                            end
                        end
                    end
                end

                table.insert(g_HighUsageResources, 1, {row[1], row[2], getDateTimeString()})
                table.remove(g_HighUsageResources, 1000)
            end
        end
    end
end
Timer(saveHighCPUResources, 5000, 0)

function getDateTimeString()
    local time = getRealTime()
    local weekday = ({"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"})[time.weekday + 1]
    -- Weekday, DD.MM.YYYY, hh:mm:ss
    return ("%s, %02d.%02d.%d, %02d:%02d:%02d"):format(weekday, time.monthday, time.month + 1, time.year + 1900, time.hour, time.minute, time.second)
end
