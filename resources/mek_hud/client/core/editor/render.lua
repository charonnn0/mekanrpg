local CONTAINER_SIZES = {
	x = 600,
	y = 400,
}

local function drawCategories()
	local tabs = {}
	for category, items in pairs(components) do
		table.insert(
			tabs,
			drawTab({
				name = items.alias,
				icon = "",
				disabled = false,
			})
		)
	end
	return tabs
end

local function combineRadioGroupOptions(key)
	local options = components[key]
	local radioOptions = {}
	if options then
		for key, value in pairs(options) do
			if value.options then
				table.insert(
					radioOptions,
					drawRadio({
						name = key,
						text = value.options.name,
					})
				)
			end
		end
	end
	return radioOptions
end

function renderEditor()
	local window = drawWindow({
		position = CONTAINER_SIZES,
		size = CONTAINER_SIZES,
		centered = true,
		radius = 8,
		padding = 20,

		header = {
			title = "Görünüşü Ayarla",
			description = "Herkesin tarzı farklıdır, seninki nasıl olsun?",
			icon = "",
			close = true,
		},
	})

	if window.clickedClose then
		HAS_EDITOR_VISIBLE = false
		return
	end

	local tabPanel = drawTabPanel({
		position = {
			x = window.x,
			y = window.y + 10,
		},
		size = {
			x = CONTAINER_SIZES.x - 25,
			y = CONTAINER_SIZES.y - 70,
		},
		padding = 10,

		name = "",

		placement = "horizontal",
		tabs = drawCategories(),

		variant = "soft",
		color = "gray",
		radius = DEFAULT_RADIUS,

		activeTab = 1,
		disabled = false,
	})

	local currentKey = "hud"
	if tabPanel.selected == 2 then
		currentKey = "carhud"
	elseif tabPanel.selected == 3 then
		currentKey = "minimap"
	end

	local store = useStore(currentKey .. "_data")
	local currentComponent = store.get("component") or components[currentKey].default
	local currentComponentStore = useStore(currentComponent)

	drawTypography({
		position = {
			x = tabPanel.position.x,
			y = tabPanel.position.y,
		},

		text = "Tercih",
		alignX = "left",
		alignY = "top",
		color = "#FFFFFF",
		scale = "h6",
		wrap = false,

		fontWeight = "regular",
	})

	local radioGroup = drawRadioGroup({
		position = {
			x = tabPanel.position.x,
			y = tabPanel.position.y + 30,
		},

		name = currentKey .. "-radiogroup",
		options = combineRadioGroupOptions(currentKey),
		defaultSelected = currentComponent,
		placement = "horizontal",

		variant = "soft",
		color = "gray",
	})

	if radioGroup.current ~= currentComponent then
		store.set("component", radioGroup.current)
		hudPreferences[currentKey] = radioGroup.current
		saveHudPreferences()
	end

	tabPanel.position.x = tabPanel.position.x + CONTAINER_SIZES.x / 2

	local componentOptions = components[currentKey]
		and components[currentKey][currentComponent]
		and components[currentKey][currentComponent].options

	if componentOptions and componentOptions.options then
		drawTypography({
			position = {
				x = tabPanel.position.x,
				y = tabPanel.position.y,
			},

			text = "Seçenekler",
			alignX = "left",
			alignY = "top",
			color = "#FFFFFF",
			scale = "h6",
			wrap = false,

			fontWeight = "regular",
		})

		for index, value in ipairs(componentOptions.options) do
			local settingOptions = {}
			for i = 1, #value.options do
				local option = value.options[i]
				if option then
					table.insert(
						settingOptions,
						drawRadio({
							name = option.value,
							text = option.text,
						})
					)
				end
			end

			drawTypography({
				position = {
					x = tabPanel.position.x,
					y = tabPanel.position.y + 30,
				},

				text = value.text,
				alignX = "left",
				alignY = "top",
				color = "#FFFFFF",
				scale = "h6",
				wrap = false,

				fontWeight = "thin",
			})

			local radioGroup = drawRadioGroup({
				position = {
					x = tabPanel.position.x,
					y = tabPanel.position.y + 60,
				},

				name = value.key .. "-radiogroup",
				options = settingOptions,
				defaultSelected = currentComponent,
				placement = "vertical",

				variant = "soft",
				color = "gray",
			})

			if radioGroup and radioGroup.current ~= currentComponentStore.get(value.key) then
				currentComponentStore.set(value.key, radioGroup.current)
			end

			tabPanel.position.y = tabPanel.position.y + 65
		end
	end
end
