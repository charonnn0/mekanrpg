
GUI = {}

local screenWidth, screenHeight = guiGetScreenSize()

local comboCategories = {
    server = {"Server info", "Lua timing", "Lua time recordings", "Lua memory", "Packet usage", "Sqlite timing", "Bandwidth reduction", "Bandwidth usage", "Server timing", "Function stats", "Debug info", "Debug table", "Lib memory", "Help"},
    client = {"Lua timing", "Lua time recordings", "Lua memory", "Lib memory", "Packet usage", "Help"},
}

function GUI:exists()
    return self.window and isElement(self.window)
end

function GUI:create()
    if self.window then
        return
    end

    local width = math.min((screenWidth - 40), 1280)
    local height = math.min((screenHeight - 40), 720)
    local panelWidth = 170
    local contentWidth = width - panelWidth
    
    self.window = guiCreateWindow((screenWidth - width) / 2, (screenHeight - height) / 2, width, height, "Ingame Performance Browser", false)
    guiSetAlpha(self.window, 1.0)
    guiWindowSetSizable(self.window, false)
    guiSetVisible(self.window, false)

    local targetLabel = guiCreateLabel(10, 30, panelWidth - 20, 15, "Target:", false, self.window)
    guiSetFont(targetLabel, "default-bold-small")
    guiLabelSetHorizontalAlign(targetLabel, "center")

    self.target = guiCreateComboBox(10, 50, panelWidth - 20, 200, "", false, self.window)
    guiComboBoxAddItem(self.target, "Client")
    guiComboBoxAddItem(self.target, "Server")
    guiComboBoxSetSelected(self.target, 0)
    self:autoHeight(self.target)
    self.targetItem = guiComboBoxGetItemText(self.target, guiComboBoxGetSelected(self.target))

    addEventHandler("onClientGUIComboBoxAccepted", self.target, function () self:onTargetUpdate() end, false)

    local categoryLabel = guiCreateLabel(10, 80, panelWidth - 20, 15, "Category:", false, self.window)
    guiSetFont(categoryLabel, "default-bold-small")
    guiLabelSetHorizontalAlign(categoryLabel, "center")

    self.category = guiCreateComboBox(10, 100, panelWidth - 20, 200, "", false, self.window)

    for index, categoryName in ipairs(comboCategories.client) do
        guiComboBoxAddItem(self.category, categoryName)
    end

    guiComboBoxSetSelected(self.category, 0)
    self:autoHeight(self.category)
    self.categoryItem = guiComboBoxGetItemText(self.category, guiComboBoxGetSelected(self.category))

    addEventHandler("onClientGUIComboBoxAccepted", self.category, function () self:onCategoryUpdate() end, false)

    local optionsLabel = guiCreateLabel(10, 130, panelWidth - 20, 15, "Options:", false, self.window)
    guiSetFont(optionsLabel, "default-bold-small")
    guiLabelSetHorizontalAlign(optionsLabel, "center")

    self.options = guiCreateEdit(10, 150, panelWidth - 20, 22, "", false, self.window)
    addEventHandler("onClientGUIChanged", self.options, function () self:onOptionsUpdate() end, false)

    local filterLabel = guiCreateLabel(10, 180, panelWidth - 20, 15, "Filter:", false, self.window)
    guiSetFont(filterLabel, "default-bold-small")
    guiLabelSetHorizontalAlign(filterLabel, "center")

    self.filter = guiCreateEdit(10, 200, panelWidth - 20, 22, "", false, self.window)
    addEventHandler("onClientGUIChanged", self.filter, function () self:onFilterUpdate() end, false)

    local closeButton = guiCreateButton(10, height - 30, panelWidth - 20, 20, "Close", false, self.window)
    addEventHandler("onClientGUIClick", closeButton, function () self:onCloseClick() end, false)

    self.statistics = guiCreateGridList(panelWidth, 30, contentWidth, height - 40, false, self.window)
    guiGridListSetSelectionMode(self.statistics, 0)
    guiGridListSetSortingEnabled(self.statistics, false)

    self:updateStatistics(STATS_MODE_NEW_LISTENER)
end

function GUI:destroy()
    if not self.window then
        return
    end

    destroyElement(self.window)
    self.window = nil

    for key, value in pairs(self) do
        if type(value) ~= "function" then
            if isElement(value) then
                destroyElement(value)
            elseif isTimer(value) then
                killTimer(value)
            end

            self[key] = nil
        end
    end
end

function GUI:setVisible(visible)
    if not self.window then
        return
    end

    visible = visible and true
    guiSetVisible(self.window, visible)
    showCursor(visible)

    if self.targetItem == "Server" then
        if self.optionsTimer and isTimer(self.optionsTimer) then
            killTimer(self.optionsTimer)
        end

        if self.filterTimer and isTimer(self.filterTimer) then
            killTimer(self.filterTimer)
        end

        self.optionsTimer = nil
        self.filterTimer = nil

        triggerServerEvent("ipb.toggle", localPlayer, visible, self.categoryItem)
    else
        if visible then
            if not self.updateTimer then
                self.updateTimer = setTimer(function () self:updateStatistics(STATS_MODE_REFRESH) end, UPDATE_FREQUENCY, 0)
            end
        else
            if self.updateTimer and isTimer(self.updateTimer) then
                killTimer(self.updateTimer)
            end

            self.updateTimer = nil
        end
    end

    if visible then
        if self.autoDestroyTimer and isTimer(self.autoDestroyTimer) then
            killTimer(self.autoDestroyTimer)
        end

        self.autoDestroyTimer = nil
    else
        if not self.autoDestroyTimer then
            self.autoDestroyTimer = setTimer(function () self:destroy() end, 60000, 1)
        end
    end
end

function GUI:onTargetUpdate()
    local itemID = guiComboBoxGetSelected(self.target)

    if not itemID or itemID == -1 then
        guiComboBoxSetSelected(self.target, 0)
        self.targetItem = guiComboBoxGetItemText(self.target, guiComboBoxGetSelected(self.target))
        return
    end

    local text = guiComboBoxGetItemText(self.target, itemID)
    local supported = comboCategories[text:lower()]

    if self.targetItem == text or not supported then
        return
    end

    guiSetText(self.options, "")
    guiSetText(self.filter, "")

    if self.optionsTimer and isTimer(self.optionsTimer) then
        killTimer(self.optionsTimer)
    end

    if self.filterTimer and isTimer(self.filterTimer) then
        killTimer(self.filterTimer)
    end

    self.targetItem = text

    guiComboBoxClear(self.category)

    for index, categoryName in ipairs(supported) do
        guiComboBoxAddItem(self.category, categoryName)
    end

    guiComboBoxSetSelected(self.category, 0)
    self:autoHeight(self.category)
    self.categoryItem = guiComboBoxGetItemText(self.category, guiComboBoxGetSelected(self.category))

    guiGridListClear(self.statistics)
    -- remove all columns
    for column = guiGridListGetColumnCount(self.statistics), 0, -1 do
        guiGridListRemoveColumn(self.statistics, column)
    end

    triggerServerEvent("ipb.toggle", localPlayer, text == "Server", false)

    if text == "Client" then
        if not self.updateTimer then
            self.updateTimer = setTimer(function () self:updateStatistics(STATS_MODE_REFRESH) end, UPDATE_FREQUENCY, 0)
        end

        self:updateStatistics(STATS_MODE_NEW_LISTENER)
    else
        if self.updateTimer and isTimer(self.updateTimer) then
            killTimer(self.updateTimer)
        end

        self.updateTimer = nil
    end
end

function GUI:onCategoryUpdate()
    local itemID = guiComboBoxGetSelected(self.category)

    if not itemID or itemID == -1 then
        guiComboBoxSetSelected(self.category, 0)
        self.categoryItem = guiComboBoxGetItemText(self.category, guiComboBoxGetSelected(self.category))
        return
    end

    local text = guiComboBoxGetItemText(self.category, itemID)

    if self.categoryItem == text then
        return
    end

    self.categoryItem = text
    guiSetText(self.options, "")
    guiSetText(self.filter, "")

    if self.targetItem == "Server" then
        triggerServerEvent("ipb.updateCategory", localPlayer, text)
    else
        return self:updateStatistics(STATS_MODE_CATEGORY_CHANGE)
    end
end

function GUI:onOptionsUpdate()
    if self.targetItem ~= "Server" then
        return self:updateStatistics(STATS_MODE_OPTIONS_CHANGE)
    end

    if self.optionsTimer and isTimer(self.optionsTimer) then
        killTimer(self.optionsTimer)
    end

    self.optionsTimer = setTimer(function() self:applyOptionsUpdate() end, 1000, 1)
end

function GUI:applyOptionsUpdate()
    self.optionsTimer = nil
    triggerServerEvent("ipb.updateOptions", localPlayer, guiGetText(self.options))
end

function GUI:onFilterUpdate()
    if self.targetItem ~= "Server" then
        return self:updateStatistics(STATS_MODE_FILTER_CHANGE)
    end

    if self.filterTimer and isTimer(self.filterTimer) then
        killTimer(self.filterTimer)
    end

    self.filterTimer = setTimer(function() self:applyFilterUpdate() end, 1000, 1)
end

function GUI:applyFilterUpdate()
    self.filterTimer = nil
    triggerServerEvent("ipb.updateFilter", localPlayer, guiGetText(self.filter))
end

function GUI:onCloseClick()
    GUI:setVisible(false)
end

function GUI:updateStatistics(mode)
    if self.targetItem ~= "Client" then
        return
    end

    self:fill(mode, getPerformanceStats(self.categoryItem, guiGetText(self.options), guiGetText(self.filter)))
end

function GUI:fill(mode, columns, rows)
    if not self.window then
        return
    end

    if mode == STATS_MODE_NEW_LISTENER or mode == STATS_MODE_CATEGORY_CHANGE or mode == STATS_MODE_OPTIONS_CHANGE or mode == STATS_MODE_FILTER_CHANGE then
        guiGridListClear(self.statistics)
        for column = guiGridListGetColumnCount(self.statistics), 0, -1 do
            guiGridListRemoveColumn(self.statistics, column)
        end

        for index, columnName in pairs(columns) do
            guiGridListAddColumn(self.statistics, columnName, 0.2)
        end
    end

    if mode == STATS_MODE_REFRESH or mode == STATS_MODE_OPTIONS_CHANGE or mode == STATS_MODE_FILTER_CHANGE then
        local availableRows = guiGridListGetRowCount(self.statistics)
        local requiredRows = #rows

        if availableRows > requiredRows then
            for index = availableRows, requiredRows, -1 do
                guiGridListRemoveRow(self.statistics, index)
            end
        elseif availableRows < requiredRows then
            for index = availableRows, requiredRows - 1, 1 do
                guiGridListAddRow(self.statistics)
            end
        end
    end

    for i, row in pairs(rows) do
        for j, value in pairs(row) do
            guiGridListSetItemText(self.statistics, i - 1, j, tostring(value), false, false)
        end
    end

    self:resizeColumns()
end

function GUI:autoHeight(combo)
    local itemID = guiComboBoxAddItem(combo, "")
    guiComboBoxRemoveItem(combo, itemID)

    local width, _ = guiGetSize(combo, false)
    return guiSetSize(combo, width, itemID * 14 + 40, false)
end

function GUI:resizeColumns()
    local label = guiCreateLabel(0, 0, 0, 0, "", false, nil)

    local rowCount = guiGridListGetRowCount(self.statistics)
    local columCount = guiGridListGetColumnCount(self.statistics)

    for column = 1, columCount do
        guiSetText(label, guiGridListGetColumnTitle(self.statistics, column) or "")
        guiSetFont(label, "default-small")
        local width = guiLabelGetTextExtent(label) + 20

        guiSetFont(label, "default-normal")

        for row = 0, rowCount - 1 do
            guiSetText(label, guiGridListGetItemText(self.statistics, row, column) or "")
            local itemWidth = guiLabelGetTextExtent(label) + 20
            width = math.max(width, itemWidth)
        end

        guiGridListSetColumnWidth(self.statistics, column, width, false)
    end

    destroyElement(label)
end
