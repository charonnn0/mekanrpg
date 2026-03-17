screenSize = Vector2(guiGetScreenSize())

theme = useTheme()
fonts = useFonts()

loading = false
passedIntro = false
logoAtFinalPositionInIntro = false

INPUT_SIZES = {
	x = 300,
	y = 45,
}

LOGO_SIZES = {
	x = 128,
	y = 128,
}

logoPosition = {
	x = screenSize.x / 2 - LOGO_SIZES.x / 2,
	y = screenSize.y / 2 - LOGO_SIZES.y / 2,
}

pedPosition = {
	x = 601.6689453125,
	y = -1772.3564453125,
	z = 14.407114982605,
	rotation = 169.73864746094
}

addEventHandler("onClientResourceStart", resourceRoot, function()
	if not getElementData(localPlayer, "logged") then
		loading = true
		addEventHandler("onClientRender", root, renderLoading)

		setPlayerHudComponentVisible("all", false)
		setPlayerHudComponentVisible("crosshair", true)
		setCameraMatrix(
			2063.7211914062,
			1211.7097167969,
			35.617889404297,
			2140.3054199219,
			1147.5036621094,
			32.091197967529
		)
		fadeCamera(true)
		showCursor(true)
		showChat(false)

		triggerServerEvent("account.requestPlayerInfo", localPlayer)
	end
end)

addEventHandler("onClientPlayerChangeNick", root, function(oldNick, newNick)
	if source == localPlayer then
		local legalNameChange = getElementData(localPlayer, "legal_name_change")
		if oldNick ~= newNick and not legalNameChange then
			cancelEvent()
			triggerServerEvent("account.resetPlayerName", localPlayer, oldNick, newNick)
		end
	end
end)

--setElementPosition(client, 263.821807, 77.848365, 1001.0390625)
