
local resourceName = getResourceName(getThisResource())
local settingPrefix = ("*%s."):format(resourceName)
local prefixLength = settingPrefix:len()

g_Settings = {
	["SaveHighCPUResources"] = "true",
	["SaveHighCPUResourcesAmount"] = "10",
	["NotifyIPBUsersOfHighUsage"] = "50"
}

local function onResourceSettingChange(name, old, new)
	g_Settings[name] = new

	if #getElementsByType("player") > 0 then
		triggerClientEvent("ipb.updateSetting", resourceRoot, name, new)
	end
end

addEventHandler("onSettingChange", root,
	function (settingName, old, new)
		if not settingName:find(settingPrefix, 1, true) then
			return
		end

		local shortSettingName = settingName:sub(prefixLength + 1)

		if g_Settings[shortSettingName] ~= new then
			onResourceSettingChange(shortSettingName, old and fromJSON(old) or old, new and fromJSON(new) or new)
		end
	end
)

addEventHandler("onPlayerResourceStart", root,
	function (startedResource)
		local matchingResource = (startedResource == getThisResource())

		if not matchingResource then
			return false
		end

		triggerClientEvent(source, "ipb.syncSettings", source, g_Settings)
	end
)
