local function renderWebview()
	local store = useStore("radialWheel")
	local browser = store.get("wheelBrowser")

	local currentInteraction = store.get("currentInteraction")
	local interactions = store.get("interactions")
	local interactedElement = store.get("interactedElement")
	local partPosition = store.get("partPosition")

	local distanceRange = store.get("distanceRange")

	if interactedElement then
		local x, y, z = interactedElement.position.x, interactedElement.position.y, interactedElement.position.z
		if partPosition then
			x, y, z = partPosition.x, partPosition.y, partPosition.z
		end

		local distance = getDistanceBetweenPoints3D(localPlayer.position, x, y, z)
		if distance >= distanceRange then
			destroyWheel()
		end
	else
		destroyWheel()
		return
	end

	local interaction = interactions[currentInteraction + 1]

	if browser then
		dxDrawImage(0, 0, screenSize.x, screenSize.y, browser)

		if interaction then
			local fonts = useFonts()

			drawTypography({
				position = {
					x = 0,
					y = 0,
				},
				size = screenSize,

				text = interaction.text .. "\n(SPACE)",
				alignX = "center",
				alignY = "center",
				color = WHITE,
				scale = "h5",
				wrap = false,

				fontWeight = "regular",
				fillBackground = true,
			})
		end
	end
end

local function wheelKeyHandlers(button, state)
	if state then
		local store = useStore("radialWheel")
		local interactions = store.get("interactions")
		local currentInteraction = store.get("currentInteraction")

		if button == "mouse_wheel_up" then
			currentInteraction = currentInteraction - 1
			if currentInteraction < 0 then
				currentInteraction = #store.get("interactions") - 1
			end
			store.set("currentInteraction", currentInteraction)
			setWheelSelectedItem(currentInteraction)
		elseif button == "mouse_wheel_down" then
			currentInteraction = currentInteraction + 1
			if currentInteraction > #store.get("interactions") - 1 then
				currentInteraction = 0
			end
			store.set("currentInteraction", currentInteraction)
			setWheelSelectedItem(currentInteraction)
		elseif button == "space" or button == "enter" then
			local interaction = interactions[currentInteraction + 1]
			if interaction and interaction.callback then
				interaction.callback()
				destroyWheel()
			end
		end
	end
end

function destroyWheelRender()
	local store = useStore("radialWheel")
	local renderingIntervalRef = store.get("renderingIntervalRef")

	if renderingIntervalRef then
		killTimer(renderingIntervalRef)
		store.set("renderingIntervalRef", nil)
		removeEventHandler("onClientKey", root, wheelKeyHandlers)
	end
end

function createWheelRender()
	local store = useStore("radialWheel")
	local renderingIntervalRef = store.get("renderingIntervalRef")

	if renderingIntervalRef then
		destroyWheelRender()
	end

	store.set("renderingIntervalRef", setTimer(renderWebview, 0, 0))
	addEventHandler("onClientKey", root, wheelKeyHandlers)
end

function isWheelRendering()
	local store = useStore("radialWheel")
	local isRendering = store.get("isRendering")

	return isRendering
end

function createWheel(interactions, element, partPosition, distance)
	local store = useStore("radialWheel")
	local isRendering = store.get("isRendering")

	if isRendering then
		return
	end

	local browser = store.get("wheelBrowser")

	local items = {}
	for _, interaction in ipairs(interactions) do
		table.insert(items, interaction.icon)
	end

	items = json.encode(items)

	browser:executeJavascript(string.format("createWheel('%s')", items))

	store.set("isRendering", true)
	store.set("interactions", interactions)
	store.set("currentInteraction", 0)
	store.set("interactedElement", element)
	store.set("partPosition", partPosition)
	store.set("distanceRange", distance or 3)

	createWheelRender()
	createOutline(element)
end

function destroyWheel()
	local store = useStore("radialWheel")
	local isRendering = store.get("isRendering")
	local browser = store.get("wheelBrowser")
	local interactedElement = store.get("interactedElement")

	assert(isRendering, "Wheel is not rendering.")

	destroyOutline(interactedElement)

	browser:executeJavascript("destroyWheel()")

	store.set("isRendering", false)
	store.set("interactions", {})
	store.set("currentInteraction", 0)
	store.set("interactedElement", nil)

	destroyWheelRender()
end

function setWheelSelectedItem(index)
	local store = useStore("radialWheel")
	local isRendering = store.get("isRendering")
	local browser = store.get("wheelBrowser")

	assert(isRendering, "Wheel is not rendering.")

	browser:executeJavascript(("setWheelSelectedItem(%d)"):format(index))
end
