TabPanel = {}
TabPanel.alias = "tabPanel"
TabPanel.initialOptions = {
	position = {
		x = 0,
		y = 0,
	},
	size = {
		x = 0,
		y = 0,
	},

	padding = 10,

	name = "",

	placement = "horizontal",
	tabs = {},

	variant = "soft",
	color = "gray",
	radius = DEFAULT_RADIUS,

	activeTab = 1,
	disabled = false,
}

local HEADER_HEIGHT = 40
local VERTICAL_HEIGHT = HEADER_HEIGHT * 5
local TAB_PADDING = 5

function drawTab(options)
	return {
		name = options.name or "",
		icon = options.icon or "",
		disabled = options.disabled or false,
	}
end

TabPanel.render = function(options, store)
	local position = options.position or TabPanel.initialOptions.position
	local size = options.size or TabPanel.initialOptions.size

	local padding = options.padding or TabPanel.initialOptions.padding

	local name = options.name or TabPanel.initialOptions.name

	local placement = options.placement or TabPanel.initialOptions.placement
	local tabs = options.tabs or TabPanel.initialOptions.tabs

	local variant = options.variant or TabPanel.initialOptions.variant
	local color = options.color or TabPanel.initialOptions.color
	local radius = options.radius or TabPanel.initialOptions.radius

	local activeTab = options.activeTab or TabPanel.initialOptions.activeTab
	local disabled = options.disabled or TabPanel.initialOptions.disabled

	local fonts = useFonts()

	local tabPanel = store.get(name)

	if not tabPanel then
		store.set(name, {
			selected = activeTab,
		})
		tabPanel = {
			selected = activeTab,
		}
	end

	local tabWidth = size.x / #tabs
	local tabPanelColor = useTabPanelVariant(variant, color)

	local tabContent = {
		x = position.x + padding,
		y = position.y + HEADER_HEIGHT + padding,
	}

	local tabContentSize = {
		x = size.x - padding * 2,
		y = size.y - HEADER_HEIGHT - padding * 2,
	}

	local tabSize = {
		x = tabWidth,
		y = HEADER_HEIGHT,
	}

	if placement == "vertical" then
		tabContent = {
			x = position.x + VERTICAL_HEIGHT + padding * 2,
			y = position.y + padding,
		}

		tabContentSize = {
			x = size.x - VERTICAL_HEIGHT - padding * 2,
			y = size.y - padding * 2,
		}

		tabSize = {
			x = VERTICAL_HEIGHT,
			y = tabSize.y,
		}

		dxDrawRectangle(position.x, position.y, tabSize.x, size.y, rgba(GRAY[700], 1))
	end

	dxDrawRectangle(position.x, position.y, size.x, size.y, rgba(tabPanelColor.background, 0.5))

	local pressed = false
	for index = 1, #tabs do
		local tab = tabs[index]
		if tab then
			local tabPosition = {
				x = position.x + ((index - 1) * tabWidth),
				y = position.y,
			}

			if placement == "vertical" then
				tabPosition = {
					x = position.x,
					y = position.y + ((index - 1) * tabSize.y),
				}
			end

			local hover = inArea(tabPosition.x, tabPosition.y, tabSize.x, tabSize.y)

			dxDrawRectangle(
				tabPosition.x,
				tabPosition.y,
				tabSize.x,
				tabSize.y,
				rgba(tabPanel.selected == index and tabPanelColor.tab or GRAY[800])
			)

			if tab.icon ~= "" and tab.icon then
				local textWidth = dxGetTextWidth(tab.name, 1, fonts.h6.regular)
				dxDrawText(
					tab.icon,
					tabPosition.x - textWidth / 2 - 15,
					tabPosition.y,
					tabPosition.x + tabSize.x - textWidth / 2 - 15,
					tabPosition.y + tabSize.y,
					rgba(WHITE),
					0.5,
					fonts.icon,
					"center",
					"center",
					false,
					false,
					false,
					true
				)
			end
			dxDrawText(
				tab.name,
				tabPosition.x,
				tabPosition.y,
				tabPosition.x + tabSize.x,
				tabPosition.y + tabSize.y,
				rgba(tabPanel.selected == index and GRAY[200] or GRAY[400]),
				1,
				fonts.BebasNeueRegular.h4,
				"center",
				"center",
				false,
				false,
				false,
				true
			)

			if hover and not disabled and isKeyPressed("mouse1") then
				tabPanel.selected = index
				pressed = true
			end
		end
	end

	return {
		selected = tabPanel.selected,
		pressed = pressed,
		position = tabContent,
		size = tabContentSize,
	}
end

createComponent(TabPanel.alias, TabPanel.initialOptions, TabPanel.render)

function drawTabPanel(options)
	return components[TabPanel.alias].render(options)
end
