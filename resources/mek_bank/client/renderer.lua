local activePage = nil

local function renderPage()
	if renderPages[activePage] then
		renderPages[activePage]()
	end
end

function showPage(pageName)
	if renderPages[pageName] then
		if pageName == "atm" then
			initializeATM()
		end

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

addEvent("bank.close", true)
addEventHandler("bank.close", root, function()
	if activePage then
		hidePage()
	end
end)
