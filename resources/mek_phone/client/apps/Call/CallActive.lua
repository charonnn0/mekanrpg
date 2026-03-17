Call.speakerEnabled = false
Call.muteEnabled = false

Call.addPage(Call.enums.Pages.Active, function(position, size)
	local activeNumber = Call.activeNumber
	local callStartTime = Call.callStartTime

	if not activeNumber or not callStartTime then
		return
	end

	activeNumber = Contacts.getName(activeNumber)

	callStartTime = exports.mek_datetime:formatTimeInDigits(callStartTime)

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
		activeNumber,
		position.x + 20,
		position.y + 38,
		position.x + size.x - 10,
		position.y + size.y - 10,
		rgba(theme.GRAY[100]),
		1,
		fonts.UbuntuBold.body
	)
	dxDrawText(
		callStartTime,
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

	local speakerButtonPosition = {
		x = callButtonPosition.x - callButtonSize.x - 5,
		y = callButtonPosition.y,
	}

	local muteButtonPosition = {
		x = speakerButtonPosition.x - callButtonSize.x - 5,
		y = callButtonPosition.y,
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
		rgba(theme.GRAY[100]),
		0.3,
		fonts.icon,
		"center",
		"center"
	)

	if hover and isKeyPressed("mouse1") then
		triggerServerEvent("phone.endCall", localPlayer, Phone.number, Call.activeNumber)
		Phone.goToApp(Phone.enums.Apps.Home)
	end

	local hover = inArea(speakerButtonPosition.x, speakerButtonPosition.y, callButtonSize.x, callButtonSize.y)

	drawRoundedRectangle({
		position = speakerButtonPosition,
		size = callButtonSize,

		color = Call.speakerEnabled and theme.GRAY[hover and 100 or 200] or theme.GRAY[700],
		alpha = 1,
		radius = callButtonSize.y / 2,
	})

	dxDrawText(
		"",
		speakerButtonPosition.x,
		speakerButtonPosition.y,
		speakerButtonPosition.x + callButtonSize.x,
		speakerButtonPosition.y + callButtonSize.y,
		Call.speakerEnabled and rgba(theme.GRAY[800]) or rgba(theme.GRAY[100]),
		0.3,
		fonts.icon,
		"center",
		"center"
	)

	if hover and isKeyPressed("mouse1") then
		Call.speakerEnabled = not Call.speakerEnabled
		triggerServerEvent("phone.toggleSpeaker", localPlayer, Phone.number, Call.speakerEnabled)
	end

	local hover = inArea(muteButtonPosition.x, muteButtonPosition.y, callButtonSize.x, callButtonSize.y)

	drawRoundedRectangle({
		position = muteButtonPosition,
		size = callButtonSize,

		color = Call.muteEnabled and theme.GRAY[hover and 100 or 200] or theme.GRAY[700],
		alpha = 1,
		radius = callButtonSize.y / 2,
	})

	dxDrawText(
		"",
		muteButtonPosition.x,
		muteButtonPosition.y,
		muteButtonPosition.x + callButtonSize.x,
		muteButtonPosition.y + callButtonSize.y,
		Call.muteEnabled and rgba(theme.GRAY[800]) or rgba(theme.GRAY[100]),
		0.3,
		fonts.icon,
		"center",
		"center"
	)

	if hover and isKeyPressed("mouse1") then
		Call.muteEnabled = not Call.muteEnabled
		triggerServerEvent("phone.toggleMute", localPlayer, Phone.number, Call.muteEnabled)
	end
end)

addEvent("phone.callAnswered", true)
addEventHandler("phone.callAnswered", root, function(targetEntity, targetNumber, startTime)
	Call.activeNumber = targetNumber
	Call.callStartTime = startTime
	Call.speakerEnabled = false
	Call.currentPage = Call.enums.Pages.Active
	Phone.goToApp(Phone.enums.Apps.Call)
	Call.destroyAllSounds()

	local call = targetEntity:getData("call")
	call.contactName = Contacts.getName(targetNumber)
	targetEntity:setData("call", call, false)
end)

addEvent("phone.callEnded", true)
addEventHandler("phone.callEnded", root, function()
	Call.activeNumber = nil
	Call.callStartTime = nil
	Call.speakerEnabled = false
	Call.currentPage = Call.enums.Pages.Home
	Phone.goToApp(Phone.enums.Apps.Home)
	Call.destroyAllSounds()
	Call.sounds.hangUp = playSound("public/sounds/hangup.wav")
	setSoundVolume(Call.sounds.hangUp, 0.5)
end)
