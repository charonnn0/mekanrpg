Call.outgoingTimeoutDuration = 1000 * 15

Call.addPage(Call.enums.Pages.Outgoing, function(position, size)
	local callingNumber = Call.outgoingNumber
	if not callingNumber then
		return
	end

	callingNumber = Contacts.getName(tonumber(callingNumber))

	drawRoundedRectangle({
		position = position,
		size = {
			x = size.x,
			y = 80,
		},

		color = theme.GRAY[800],
		alpha = 1,
		radius = 24,
	})

	dxDrawText(
		callingNumber,
		position.x + 20,
		position.y + 38,
		position.x + size.x - 10,
		position.y + size.y - 10,
		rgba(theme.GRAY[100]),
		1,
		fonts.UbuntuBold.body
	)
	dxDrawText(
		"aranıyor...",
		position.x + 20,
		position.y + 53,
		position.x + size.x - 10,
		position.y + size.y - 10,
		rgba(theme.GRAY[300]),
		1,
		fonts.UbuntuRegular.caption
	)

	local callButtonSize = {
		x = 32,
		y = 32,
	}

	local callButtonPosition = {
		x = position.x + size.x - 20 - callButtonSize.x,
		y = position.y + 38,
	}

	local hover = inArea(callButtonPosition.x, callButtonPosition.y, callButtonSize.x, callButtonSize.y)

	drawRoundedRectangle({
		position = callButtonPosition,
		size = callButtonSize,

		color = theme.RED[hover and 600 or 500],
		alpha = 1,
		radius = callButtonSize.y / 2,
	})

	dxDrawText(
		"",
		callButtonPosition.x,
		callButtonPosition.y,
		callButtonPosition.x + callButtonSize.x,
		callButtonPosition.y + callButtonSize.y,
		tocolor(255, 255, 255, 255),
		0.3,
		fonts.icon,
		"center",
		"center"
	)

	if hover and isKeyPressed("mouse1") then
		Call.destroyAllSounds()
		Phone.goToApp(Phone.enums.Apps.Home)
		triggerServerEvent("phone.answerCall", localPlayer, Phone.number, Call.outgoingNumber, false)
	end
end)

addEvent("phone.callRequestComplete", true)
addEventHandler("phone.callRequestComplete", root, function(targetEntity, number)
	Call.outgoingNumber = number
	Call.currentPage = Call.enums.Pages.Outgoing
	Phone.goToApp(Phone.enums.Apps.Call)

	if isElement(Call.sounds.dialing) then
		stopSound(Call.sounds.dialing)
	end

	Call.sounds.dialing = playSound("public/sounds/dialing.mp3", true)
	setSoundVolume(Call.sounds.dialing, 0.5)

	Call.outgoingTimeout = setTimer(function()
		if Call.outgoingNumber and Call.currentPage == Call.enums.Pages.Outgoing then
			Call.destroyAllSounds()
			Phone.goToApp(Phone.enums.Apps.Home)
			triggerServerEvent("phone.answerCall", localPlayer, Phone.number, Call.outgoingNumber, false)
		end
	end, Call.outgoingTimeoutDuration, 1)
end)

addEvent("phone.callRejected", true)
addEventHandler("phone.callRejected", root, function(targetNumber)
	Phone.goToApp(Phone.enums.Apps.Home)
	if Call.outgoingNumber == targetNumber then
		playSound("public/sounds/busy.mp3")
	end

	Call.outgoingNumber = nil
	Call.incomingNumber = nil

	Call.destroyAllSounds()
end)
