local injectionBlocks = {
	"client/core/hooks/useStore.lua",
}
local injectBlocks = ""

addEventHandler("onClientResourceStart", resourceRoot, function()
	for _, block in ipairs(injectionBlocks) do
		local file = fileOpen(block)
		if file then
			local content = fileRead(file, fileGetSize(file))
			fileClose(file)
			injectBlocks = injectBlocks .. content .. "\n"
		end
	end
end)

function injectHooks()
	return injectBlocks
end
