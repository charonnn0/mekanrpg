local theme = useTheme()
local fonts = useFonts()

local activePursuits = {}

local ICONS = {
	support = "",
	follow = "",
	panic = "",
}

setTimer(function()
	local cx, cy, cz = getCameraMatrix()
	local px, py, pz = getElementPosition(localPlayer)

	for player, info in pairs(activePursuits) do
		if isElement(player) and player.interior == 0 and player.dimension == 0 then
			local x, y, z = getElementPosition(player)
			local distance = getDistanceBetweenPoints3D(px, py, pz, x, y, z)
			local sx, sy = getScreenFromWorldPosition(x, y, z + 0.2)

			if sx and sy then
				local r, g, b = unpack(info.color)
				local distanceText = math.floor(distance) .. " metre"

				local text = getPlayerName(player):gsub("_", " ")
				if info.reason and info.reason ~= "" then
					text = text .. "\n(" .. info.reason .. ")"
				end
				text = text .. "\n" .. distanceText

				local alpha = 255
				if info.type == "panic" then
					local tick = getTickCount() % 1000
					alpha = interpolateBetween(100, 0, 0, 255, 0, 0, tick / 1000, "SineCurve")
				end

				dxDrawText(
					ICONS[info.type] or "",
					sx,
					sy - 40,
					sx,
					sy,
					tocolor(r, g, b, alpha),
					1,
					fonts.icon,
					"center",
					"top",
					false,
					false,
					false,
					true
				)

				dxDrawText(
					text,
					sx,
					sy,
					sx,
					sy,
					rgba(theme.WHITE),
					1,
					fonts.UbuntuRegular.body,
					"center",
					"top",
					false,
					false,
					false,
					true
				)
			end
		end
	end
end, 0, 0)

local function handlePursuit(type)
	return function(state, player, reason, factionID)
		if not isElement(player) then
			return
		end

		if state then
			local color = { 255, 255, 255 }
			if factionID == 1 then
				color = { 65, 65, 255 }
			elseif factionID == 2 then
				color = { 255, 130, 130 }
			elseif factionID == 3 then
				color = { 0, 80, 0 }
			end

			activePursuits[player] = {
				type = type,
				reason = reason or "",
				color = color,
			}

			if type == "panic" then
				local sound = playSound("public/sounds/panic.mp3")
				setSoundVolume(sound, 0.5)
			end
		else
			activePursuits[player] = nil
		end
	end
end

addEvent("legal.pursuit.support", true)
addEventHandler("legal.pursuit.support", root, handlePursuit("support"))

addEvent("legal.pursuit.follow", true)
addEventHandler("legal.pursuit.follow", root, handlePursuit("follow"))

addEvent("legal.pursuit.panic", true)
addEventHandler("legal.pursuit.panic", root, handlePursuit("panic"))
