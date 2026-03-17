local RECT_SIZE = 32
local PRESS_KEY = "e"

local nearestInteractionElement = nil

local percentages = {}
local outlines = {}

local callbacks = {}

function setEntityCallback(entity, callback)
	callbacks[entity] = callback
end

setTimer(function()
	nearestInteractionElement = nil
	if #interactedElements == 0 then
		return
	end

	local playerPosition = localPlayer.position

	for i = 1, #interactedElements do
		local row = interactedElements[i]
		if row then
			local element = row.element
			local store = row.store

			if element and isElement(element) and not store.disabled then
				local position, worldPosition =
					calculateElementPosition(element, playerPosition, store.nearestComponent)
				local callbackEvent = store.callbackEvent
				local callbackExport = store.callbackExport
				local args = store.args
				local icon = store.icon
				local description = store.description
				local key = store.key or PRESS_KEY

				local isNativeKey = key == PRESS_KEY

				if element:isOnScreen() and position.x and position.y and not store.text then
					local distance = getDistanceBetweenPoints3D(playerPosition, worldPosition)
					local percent = percentages[element] or 0
					local buttonPosition = {
						x = position.x - RECT_SIZE / 2,
						y = position.y - RECT_SIZE / 2,
					}

					drawButton({
						position = buttonPosition,
						size = {
							x = RECT_SIZE,
							y = RECT_SIZE,
						},
						radius = 8,

						textProperties = {
							align = "center",
							color = theme.WHITE,
							font = icon and fonts.icon or fonts.body.thin,
							scale = icon and 0.5 or 1,
						},

						variant = percent == (RECT_SIZE + 1) and "solid" or "soft",
						color = icon and "gray" or "blue",
						disabled = false,

						text = icon or key,
						icon = "",
					})

					if description then
						dxDrawText(
							description,
							position.x + 1,
							position.y + 1 + RECT_SIZE,
							position.x + 1,
							position.y + 1 + RECT_SIZE,
							tocolor(0, 0, 0),
							1,
							fonts.body.regular,
							"center",
							"center"
						)
						dxDrawText(
							description,
							position.x,
							position.y + RECT_SIZE,
							position.x,
							position.y + RECT_SIZE,
							tocolor(255, 255, 255),
							1,
							fonts.body.regular,
							"center",
							"center"
						)
					end

					if percent > 0 and percent ~= (RECT_SIZE + 1) then
						dxDrawLine(
							buttonPosition.x,
							buttonPosition.y + RECT_SIZE - 1,
							buttonPosition.x + percent,
							buttonPosition.y + RECT_SIZE - 1,
							rgba(theme.BLUE[300], 1),
							2
						)
					end

					local distanceProtocol = key == PRESS_KEY and distance <= 13 or true
					if distanceProtocol then
						if isKeyPressed(key) then
							if not outlines[element] then
								outlines[element] = true
								createOutline(element, { r = 60, g = 64, b = 198 }, 0.5)
							end

							if percent < RECT_SIZE then
								percent = percent + 1
								percentages[element] = math.min(percent, RECT_SIZE)
							elseif percent == RECT_SIZE then
								if percentages[element] then
									percentages[element] = RECT_SIZE + 1
								end

								if callbacks[element] then
									if outlines[element] then
										outlines[element] = nil
										destroyOutline(element)
									end
									callbacks[element](element)
								else
									if callbackExport then
										local resource = exports[callbackExport.resource]
										local callback = resource and resource[callbackExport.callback]

										if callback then
											callback(element, unpack(args))
										end
									end
									triggerEvent(callbackEvent, localPlayer, element, unpack(args))
								end
							end
						else
							if percent > 0 then
								percent = percent - 2
								percentages[element] = math.max(percent, 0)
							end

							if outlines[element] then
								outlines[element] = nil
								destroyOutline(element)
							end
						end

						if isNativeKey then
							nearestInteractionElement = element
						end
					end
				end
			end
		end
	end
end, 0, 0)

function isInteracting()
	return nearestInteractionElement ~= nil
end

addEventHandler("onClientPlayerWeaponSwitch", localPlayer, function()
	if nearestInteractionElement then
		cancelEvent()
	end
end)
