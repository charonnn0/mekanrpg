local primaryResources = {
	"mek_mysql",
	"mek_global",
	"mek_data",
	"mek_pool",
	"mek_integration",
	"mek_vehicle",
	"mek_ui",
	"mek_item",
	"mek_tag",
}

addEventHandler("onResourceStart", resourceRoot, function()
	for _, resource in ipairs(primaryResources) do
		startResource(getResourceFromName(resource))
	end

	for _, resource in ipairs(getResources()) do
		startResource(resource)
	end
end)
