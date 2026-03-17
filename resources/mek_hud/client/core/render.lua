local renderComponentInterval = nil
local calledInitialize = {}

local function renderComponents()
	renderSkull()

	if isElementInWater(localPlayer) and not isPedInVehicle(localPlayer) then
		local oxygen = screenSize.x * getPedOxygenLevel(localPlayer) / 1000
		dxDrawRectangle(0, 0, screenSize.x, 2, tocolor(155, 155, 155, 155))
		dxDrawRectangle(0, 0, oxygen, 2, tocolor(245, 245, 245))
	end

	if not exports.mek_settings:getPlayerSetting(localPlayer, "hud_visible") then
		setPlayerHudComponentVisible("all", false)
		setPlayerHudComponentVisible("crosshair", true)
		return false
	end

	setPlayerHudComponentVisible("all", false)
	setPlayerHudComponentVisible("crosshair", true)

	for category, list in pairs(components) do
		local data = useStore(category .. "_data")
		if data then
			local componentName = data.get("component")
			local component = list[componentName]

			if component then
				local status, result = pcall(component.render)

				if not calledInitialize[componentName] then
					component.initialize()
					calledInitialize[componentName] = true
				end

				if not status then
					dxDrawText(
						"Error rendering component " .. category .. "/" .. componentName .. ": \n" .. result,
						0,
						0,
						screenSize.x,
						screenSize.y,
						tocolor(255, 0, 0),
						2,
						"default",
						"center",
						"center",
						true,
						true
					)
				end
			end
		end
	end

	if HAS_EDITOR_VISIBLE then
		renderEditor()
	end

	return true
end

local function startRenderComponents()
	if renderComponentInterval then
		return
	end

	renderComponentInterval = setTimer(renderComponents, 0, 0)
end

local function stopRenderComponents()
	if not renderComponentInterval then
		return
	end

	killTimer(renderComponentInterval)
	renderComponentInterval = nil
end

addEventHandler("onClientResourceStart", resourceRoot, function()
	if localPlayer:getData("logged") then
		startRenderComponents()
	end
end)

addEventHandler("onClientElementDataChange", localPlayer, function(dataName, oldValue, newValue)
	if dataName ~= "logged" then
		return
	end

	if not newValue then
		stopRenderComponents()
		return
	end

	startRenderComponents()
end)
