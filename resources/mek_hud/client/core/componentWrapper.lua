components = {
	hud = {
		alias = "Hud",
		default = "modern",
	},
	carhud = {
		alias = "Araç Göstergesi",
		default = "circular",
	},
	minimap = {
		alias = "Harita",
		default = "modern",
	},
}

function getCurrentRenderingHud(category)
	local store = useStore(category .. "_data")
	local currentComponent = store.get("component")

	return currentComponent
end

function createHudComponent(componentName, renderFunction, options, initialize)
	local category, name = string.match(componentName, "(.+)/(.+)")
	local store = useStore(category .. "_data")

	local function renderMiddleware()
		local store = useStore(category)
		return renderFunction(store)
	end

	store.set("component", name)

	components[category][name] = {
		render = renderMiddleware,
		initialize = initialize or function() end,
		options = options,
	}
end
