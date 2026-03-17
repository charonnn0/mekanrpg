local screenSize = Vector2(guiGetScreenSize())

local theme = useTheme()
local fonts = useFonts()

local containerSize = {
	x = 1000,
	y = 800,
}

local clickTick = 0
local loading = false

local pageSize = 33
local currentPage = 1

local scrollOffset = 0
local maxVisibleTypes = 20

local logs = {}
local logTypes = {}
table.insert(logTypes, 1, "Tümü")

local selectedLogType = "Tümü"

local startDate = ""
local endDate = ""
local searchKeyword = ""

local lineHeight = 10
local maxLogLines = 30

addCommandHandler("logs", function()
	if exports.mek_integration:isPlayerManager(localPlayer) then
		if not isTimer(renderTimer) then
			loading = true
			currentPage = 1
			logs = {}
			logTypes = {}
			triggerServerEvent("logs.fetchLogTypes", localPlayer)
			fetchLogs(currentPage, selectedLogType, startDate, endDate, searchKeyword)
			showCursor(true)

			addEventHandler("onClientKey", root, handleScroll)
			renderTimer = setTimer(function()
				local window = drawWindow({
					position = {
						x = 0,
						y = 0,
					},
					size = containerSize,

					centered = true,

					header = {
						title = "Loglar",
						close = true,
					},

					postGUI = false,
				})

				if window.clickedClose then
					killTimer(renderTimer)
					removeEventHandler("onClientKey", root, handleScroll)
					showCursor(false)
				end

				if loading then
					drawSpinner({
						position = {
							x = (screenSize.x - 128) / 2,
							y = ((screenSize.y - 128) / 2) + 25,
						},
						size = 128,
						speed = 2,
						variant = "solid",
						color = "white",
					})
				else
					drawFilters(window)

					local logTypeButtonY = window.y + 45
					local startIndex = math.max(1, scrollOffset + 1)
					local endIndex = math.min(#logTypes, scrollOffset + maxVisibleTypes)

					for i = startIndex, endIndex do
						local logType = logTypes[i]
						local isSelected = selectedLogType == logType

						local button = drawButton({
							position = {
								x = window.x,
								y = logTypeButtonY,
							},
							size = {
								x = 100,
								y = 30,
							},

							variant = "solid",
							color = isSelected and "green" or "gray",
							disabled = loading,
							gradientless = true,

							text = logType,
						})

						if button.pressed and clickTick + 300 <= getTickCount() then
							clickTick = getTickCount()
							loading = true
							logs = {}
							selectedLogType = logType
							currentPage = 1
							fetchLogs(currentPage, selectedLogType, startDate, endDate, searchKeyword)
						end

						logTypeButtonY = logTypeButtonY + 35
					end

					local scrollBarHeight = containerSize.y - 104
					local scrollThumbHeight = math.max(30, scrollBarHeight * (maxVisibleTypes / #logTypes))
					local scrollThumbY = window.y
						+ (scrollBarHeight - scrollThumbHeight)
							* (scrollOffset / math.max(1, #logTypes - maxVisibleTypes))
					dxDrawRectangle(window.x + 105, window.y + 45, 5, scrollBarHeight, rgba(theme.GRAY[800]))
					dxDrawRectangle(window.x + 105, scrollThumbY + 45, 5, scrollThumbHeight, rgba(theme.GRAY[600]))

					drawLogs(window)

					if currentPage > 1 then
						local button = drawButton({
							position = {
								x = window.x + containerSize.x - 90,
								y = window.y + containerSize.y - 90,
							},
							size = {
								x = 30,
								y = 30,
							},

							textProperties = {
								align = "center",
								color = theme.WHITE,
								font = fonts.icon,
								scale = 0.5,
							},

							variant = "soft",
							color = "gray",
							disabled = loading,

							text = "",
						})

						if button.pressed and clickTick + 300 <= getTickCount() then
							clickTick = getTickCount()
							loading = true
							logs = {}
							currentPage = currentPage - 1
							fetchLogs(currentPage, selectedLogType, startDate, endDate, searchKeyword)
						end
					end

					if #logs == pageSize then
						local button = drawButton({
							position = {
								x = window.x + containerSize.x - 55,
								y = window.y + containerSize.y - 90,
							},
							size = {
								x = 30,
								y = 30,
							},

							textProperties = {
								align = "center",
								color = theme.WHITE,
								font = fonts.icon,
								scale = 0.5,
							},

							variant = "soft",
							color = "gray",
							disabled = loading,

							text = "",
						})

						if button.pressed and clickTick + 300 <= getTickCount() then
							clickTick = getTickCount()
							loading = true
							logs = {}
							currentPage = currentPage + 1
							fetchLogs(currentPage, selectedLogType, startDate, endDate, searchKeyword)
						end
					end
				end
			end, 0, 0)
		else
			killTimer(renderTimer)
			removeEventHandler("onClientKey", root, handleScroll)
			showCursor(false)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", 255, 0, 0, true)
	end
end, false, false)

function handleScroll(key, state)
	if key == "mouse_wheel_up" then
		scrollOffset = math.max(0, scrollOffset - 1)
	elseif key == "mouse_wheel_down" then
		scrollOffset = math.min(#logTypes - maxVisibleTypes, scrollOffset + 1)
	end
end

function fetchLogs(page, logType, startDate, endDate, keyword)
	triggerServerEvent("logs.fetchLogs", localPlayer, page, pageSize, logType, startDate, endDate, keyword)
end

addEvent("logs.receiveLogs", true)
addEventHandler("logs.receiveLogs", root, function(_logs)
	logs = _logs
	loading = false
end)

addEvent("logs.receiveLogTypes", true)
addEventHandler("logs.receiveLogTypes", root, function(_logTypes)
	table.sort(_logTypes)
	logTypes = _logTypes
	table.insert(logTypes, 1, "Tümü")
end)

addEvent("logs.newLog", true)
addEventHandler("logs.newLog", root, function(newLog)
	local logTimestamp = newLog.timestamp
	local isDateValid = true

	if startDate ~= "" and endDate ~= "" then
		isDateValid = logTimestamp >= startDate and logTimestamp <= endDate
	end

	local isKeywordValid = searchKeyword == "" or newLog.message:lower():find(searchKeyword:lower(), 1, true)

	if (selectedLogType == newLog.log_type or selectedLogType == "Tümü") and isDateValid and isKeywordValid then
		table.insert(logs, 1, newLog)
		if #logs > pageSize then
			table.remove(logs, #logs)
		end
	end
end)

function cleanLines(lines)
	local result = {}
	for _, line in ipairs(lines) do
		if line:match("%S") then
			table.insert(result, line)
		end
	end
	return result
end

function drawFilters(window)
	local startDateInput = drawInput({
		position = {
			x = window.x,
			y = window.y,
		},
		size = {
			x = 200,
			y = 30,
		},
		name = "logs_start_date",

		placeholder = "Başlangıç Tarihi (YYYY-AA-GG)",
		value = startDate,

		variant = "solid",
		color = "gray",

		disabled = loading,
	})

	local endDateInput = drawInput({
		position = {
			x = window.x + 210,
			y = window.y,
		},
		size = {
			x = 200,
			y = 30,
		},

		name = "logs_end_date",

		placeholder = "Bitiş Tarihi (YYYY-AA-GG)",
		value = endDate,

		variant = "solid",
		color = "gray",

		disabled = loading,
	})

	local keywordInput = drawInput({
		position = {
			x = window.x + 420,
			y = window.y,
		},
		size = {
			x = 300,
			y = 30,
		},

		name = "logs_keyword",

		placeholder = "Anahtar Kelime Ara",
		value = searchKeyword,

		variant = "solid",
		color = "gray",

		disabled = loading,
	})

	local applyButton = drawButton({
		position = {
			x = window.x + 730,
			y = window.y,
		},
		size = {
			x = 100,
			y = 30,
		},
		variant = "solid",
		color = "blue",
		text = "Filtrele",
	})

	if applyButton.pressed and clickTick + 300 <= getTickCount() then
		clickTick = getTickCount()
		loading = true
		logs = {}
		currentPage = 1
		fetchLogs(currentPage, selectedLogType, startDate, endDate, searchKeyword)
	end

	startDate = startDateInput.value
	endDate = endDateInput.value
	searchKeyword = keywordInput.value
end

function drawLogs(window)
	local startIndex = 1
	local endIndex = math.min(startIndex + pageSize - 1, #logs)

	local logY = window.y + 45
	local lineHeight = 16

	for i = startIndex, endIndex do
		local log = logs[i]
		if log then
			local lines = split(log.message, ";")
			local displayedLines = cleanLines(lines)

			if #lines > maxLogLines then
				table.insert(displayedLines, "...")
			end

			for _, line in ipairs(displayedLines) do
				dxDrawText(
					log.timestamp .. " - " .. line,
					window.x + 120,
					logY,
					window.x + containerSize.x - 20,
					logY + lineHeight,
					tocolor(255, 255, 255, 255),
					1,
					fonts.UbuntuRegular.caption
				)
				logY = logY + lineHeight
			end
		end

		logY = logY + 4
	end
end
