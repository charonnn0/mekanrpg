function sendNotification(thePlayer, contentArray, widthNew, posXOffset, posYOffset, cooldown)
	triggerClientEvent(
		thePlayer,
		"hud.drawOverlay",
		thePlayer,
		contentArray,
		widthNew,
		posXOffset,
		posYOffset,
		cooldown
	)
end

addEventHandler("onElementDataChange", root, function(dataName, oldValue, newValue)
	if getElementType(source) == "player" and dataName == "money" then
		local money = tonumber(newValue) or 0
		setPlayerMoney(source, money, true)
	end
end)
