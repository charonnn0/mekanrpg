local screenWidth, screenHeight = guiGetScreenSize()

local jailTimer = nil
local jailTimeLeftInSeconds = 0
local lastJailTimeData = nil

local theme = useTheme()
local fonts = useFonts()

setTimer(function()
	local jailTimeData = getElementData(localPlayer, "admin_jail_time")

	if (tonumber(jailTimeData) and tonumber(jailTimeData) > 0) or jailTimeData == "Sınırsız" then
		if lastJailTimeData ~= jailTimeData then
			jailTimeLeftInSeconds = tonumber(jailTimeData) and jailTimeData * 60 or jailTimeData
			lastJailTimeData = jailTimeData

			if jailTimer and isTimer(jailTimer) then
				killTimer(jailTimer)
			end

			if tonumber(jailTimeLeftInSeconds) then
				jailTimer = setTimer(function()
					if tonumber(jailTimeLeftInSeconds) and jailTimeLeftInSeconds > 0 then
						jailTimeLeftInSeconds = jailTimeLeftInSeconds - 1
					end
				end, 1000, 0)
			end
		end

		local jailBy = getElementData(localPlayer, "admin_jail_by") or "Bilinmiyor"
		local jailReason = getElementData(localPlayer, "admin_jail_reason") or "Belirtilmedi"

		local remainingText = tonumber(jailTimeLeftInSeconds)
				and exports.mek_datetime:formatSeconds(jailTimeLeftInSeconds)
			or jailTimeData

		local message = ("%s%s #FFFFFFtarafından cezalandırıldınız.\nSebep: %s%s"):format(
			getServerColor(2),
			jailBy,
			getServerColor(2),
			jailReason
		)

		local boxWidth, boxHeight =
			dxGetTextWidth(message:gsub("#%x%x%x%x%x%x", ""), 1, fonts.UbuntuRegular.h6) + 40, 75
		local boxX, boxY = screenWidth / 2 - boxWidth / 2, 100

		drawRoundedRectangle({
			position = {
				x = boxX,
				y = boxY,
			},
			size = {
				x = boxWidth,
				y = boxHeight,
			},

			color = theme.GRAY[900],
			alpha = 0.9,
			radius = 8,
			
			borderWidth = 1,
			borderColor = theme.GRAY[800],
		})
		dxDrawText(
			message,
			boxX,
			boxY,
			boxX + boxWidth,
			boxY + boxHeight,
			rgba(theme.GRAY[100]),
			1,
			fonts.UbuntuRegular.h6,
			"center",
			"center",
			false,
			false,
			false,
			true
		)

		local timeBoxWidth, timeBoxHeight = dxGetTextWidth(remainingText, 1, fonts.UbuntuBold.h2) + 25, 60
		local timeBoxX, timeBoxY = screenWidth / 2 - timeBoxWidth / 2, screenHeight - (timeBoxHeight * 2)

		drawRoundedRectangle({
			position = {
				x = timeBoxX,
				y = timeBoxY,
			},
			size = {
				x = timeBoxWidth,
				y = timeBoxHeight,
			},

			color = theme.GRAY[900],
			alpha = 0.9,
			radius = 8,
			
			borderWidth = 1,
			borderColor = theme.GRAY[800],
		})
		dxDrawText(
			remainingText,
			timeBoxX,
			timeBoxY,
			timeBoxX + timeBoxWidth,
			timeBoxY + timeBoxHeight,
			rgba(theme.GRAY[100]),
			0.8,
			fonts.UbuntuBold.h2,
			"center",
			"center"
		)
	else
		jailTimeLeftInSeconds = 0
		lastJailTimeData = nil
	end
end, 0, 0)