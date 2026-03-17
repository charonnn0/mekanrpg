local activePage = nil

local function renderPage()
	if renderPages[activePage] then
		renderPages[activePage]()
	end
end

function showPage(pageName)
	if renderPages[pageName] then
		activePage = pageName
		showCursor(true)
		guiSetInputEnabled(true)
		addEventHandler("onClientRender", root, renderPage)
	end
end

function hidePage()
	activePage = nil
	removeEventHandler("onClientRender", root, renderPage)
	guiSetInputEnabled(false)
	showCursor(false)
end

addEvent("interior.settings.close", true)
addEventHandler("interior.settings.close", root, function()
	if activePage then
		hidePage()
	end
end)

