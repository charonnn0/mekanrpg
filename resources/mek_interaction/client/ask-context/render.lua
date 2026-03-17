local actionButtons = {
	{ label = "Evet", action = "yes", color = "green" },
	{ label = "Hayır", action = "no", color = "red" },
}

local CLOSE_SECONDS = 15

function showAskContext(details)
	local store = useStore("askContext")

	store.set("details", details)
	store.set("visible", true)

	store.set("remainingSeconds", CLOSE_SECONDS)

	setTimer(function()
		local store = useStore("askContext")
		local visible = store.get("visible")

		if visible then
			local remainingSeconds = store.get("remainingSeconds")

			if remainingSeconds > 0 then
				store.set("remainingSeconds", remainingSeconds - 1)
				if remainingSeconds - 1 == 0 then
					triggerServerEvent("interaction.answerContext", localPlayer, "no", details)
					store.set("visible", false)
					store.set("details", nil)
				end
			end
		end
	end, 1000, CLOSE_SECONDS)
end

setTimer(function()
	local store = useStore("askContext")
	local visible = store.get("visible")

	if visible then
		local details = store.get("details")
		local seconds = store.get("remainingSeconds")

		local windowSize = {
			x = 420,
			y = 110,
		}

		local window = drawWindow({
			position = {
				x = screenSize.x / 2 - windowSize.x / 2,
				y = screenSize.y - windowSize.y - 20,
			},
			size = windowSize,

			centered = false,
			radius = 12,
			alpha = 0.93,

			header = {
				title = details.title .. " (" .. seconds .. ")",
				description = details.description,
			},
		})

		local position = {
			x = window.x,
			y = window.y + window.height - 35,
		}

		local buttonWidth = windowSize.x / 2 - 15

		for _, action in ipairs(actionButtons) do
			local button = drawButton({
				position = {
					x = position.x,
					y = position.y,
				},
				size = {
					x = buttonWidth,
					y = 35,
				},

				text = action.label,
				variant = "soft",
				color = action.color,
			})

			if button.pressed then
				triggerServerEvent("interaction.answerContext", localPlayer, action.action, details)
				store.set("visible", false)
				store.set("details", nil)
			end

			position.x = position.x + buttonWidth + 5
		end
	end
end, 0, 0)
