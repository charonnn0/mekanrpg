HAS_EDITOR_VISIBLE = false

addCommandHandler("hud", function()
	if not getElementData(localPlayer, "logged") then
		return false
	end

	HAS_EDITOR_VISIBLE = true
end, false, false)

addEventHandler("onClientResourceStart", resourceRoot, function()
	local initialHudPreferences = {}
	for category, data in pairs(components) do
		initialHudPreferences[category] = data.default
	end

	hudPreferences = exports.mek_json:get("hudPreferences")
	if size(hudPreferences) <= 0 then
		hudPreferences = initialHudPreferences
	end

	for category, default in pairs(hudPreferences) do
		local store = useStore(category .. "_data")
		store.set("component", default)
	end
end)

function saveHudPreferences()
	exports.mek_json:save("hudPreferences", hudPreferences)
end
