function webviewImageWrapper(path)
	return "imgsrc:http://mta/local/" .. path
end

local function radialWheelInitializer()
	local store = useStore("radialWheel")

	local browser = createBrowser(screenSize.x, screenSize.y, true, true)
	addEventHandler("onClientBrowserCreated", browser, function()
		loadBrowserURL(browser, "http://mta/local/client/wheel/webview/index.html")
		store.set("wheelBrowser", browser)
	end)
end
addEventHandler("onClientResourceStart", resourceRoot, radialWheelInitializer)
