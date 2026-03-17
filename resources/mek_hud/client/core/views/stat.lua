local framesPerSecond = 0
local framesDeltaTime = 0
local lastRenderTick = false
local rightSectionText = ""
local leftSectionText = ""
local leftSectionTextColor = theme.GRAY[100]

setTimer(function()
	if not localPlayer:getData("logged") then
		return
	end

	local currentTick = getTickCount()
	lastRenderTick = lastRenderTick or currentTick
	framesDeltaTime = framesDeltaTime + (currentTick - lastRenderTick)
	lastRenderTick = currentTick
	framesPerSecond = framesPerSecond + 1

	local time = getRealTime()
	local hours = time.hour
	local minutes = time.minute
	local seconds = time.second

	local monthday = time.monthday
	local month = time.month
	local year = time.year

	local formattedTime = string.format("%02d/%02d/%04d", monthday, month + 1, year + 1900)
	local formattedHour = string.format("%02d:%02d:%02d", hours, minutes, seconds)

	if framesDeltaTime >= 1000 then
		local ping = localPlayer:getPing()
		local characterID = getElementData(localPlayer, "dbid") or 0

		rightSectionText = "⌈ "
			.. framesPerSecond
			.. " fps "
			.. ping
			.. " ms ⌉  ⌈ "
			.. formattedTime
			.. " "
			.. formattedHour
			.. " ⌉  ⌈ ID: "
			.. characterID
			.. " ⌉"

		leftSectionText = "Oyuncu Sayısı: " .. #getElementsByType("player")
		leftSectionTextColor = theme.GRAY[100]

		if exports.mek_global:isAdminOnDuty(localPlayer) then
			local reportCount = exports.mek_reports:getReportsCount()
			local rpConfirmCount = 0

			for _, player in ipairs(getElementsByType("player")) do
				if getElementData(player, "logged") and not getElementData(player, "rp_confirm") then
					rpConfirmCount = rpConfirmCount + 1
				end
			end

			leftSectionText = leftSectionText
				.. " | Forum Şikayetleri: 0"
				.. " | Rapor: "
				.. reportCount
				.. " - Bekleyen Rol Dersi: "
				.. rpConfirmCount

			if reportCount >= 3 then
				leftSectionTextColor = theme.RED[500]
			else
				leftSectionTextColor = theme.GRAY[100]
			end
		end

		framesDeltaTime = framesDeltaTime - 1000
		framesPerSecond = 0
	end

	dxDrawText(
		rightSectionText,
		0,
		0,
		screenSize.x - 80,
		screenSize.y + 1,
		rgba(theme.GRAY[100], 0.6),
		1,
		fonts.ProximaNovaRegular.body,
		"right",
		"bottom",
		false,
		false,
		false
	)

	if leftSectionText ~= "" then
		dxDrawText(
			leftSectionText,
			1,
			0,
			screenSize.x,
			screenSize.y + 1,
			rgba(leftSectionTextColor, 0.7),
			1,
			fonts.ProximaNovaRegular.body,
			"left",
			"bottom",
			false,
			false,
			false
		)
	end
end, 0, 0)