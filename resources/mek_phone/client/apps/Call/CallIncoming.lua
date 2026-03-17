Call.addPage(Call.enums.Pages.Incoming, function(position, size)
	local incomingNumber = Call.incomingNumber
	if not incomingNumber then
		return
	end

	incomingNumber = Contacts.getName(tonumber(incomingNumber))

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
		incomingNumber,
		position.x + 20,
		position.y + 38,
		position.x + size.x - 10,
		position.y + size.y - 10,
		rgba(theme.GRAY[100]),
		1,
		fonts.UbuntuBold.body
	)
	dxDrawText(
		"gelen çağrı",
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

	local acceptButtonPosition = {
		x = position.x + size.x - 20 - callButtonSize.x - 5 - callButtonSize.x,
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
		"",
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
		if isElement(Call.sounds.incoming) then
			destroyElement(Call.sounds.incoming)
		end

		triggerServerEvent("phone.answerCall", localPlayer, Phone.number, Call.incomingNumber, false)
		Phone.goToApp(Phone.enums.Apps.Home)
	end

	local hover = inArea(acceptButtonPosition.x, acceptButtonPosition.y, callButtonSize.x, callButtonSize.y)

	drawRoundedRectangle({
		position = acceptButtonPosition,
		size = callButtonSize,

		color = theme.GREEN[hover and 600 or 500],
		alpha = 1,
		radius = callButtonSize.y / 2,
	})

	dxDrawText(
		"",
		acceptButtonPosition.x,
		acceptButtonPosition.y,
		acceptButtonPosition.x + callButtonSize.x,
		acceptButtonPosition.y + callButtonSize.y,
		tocolor(255, 255, 255, 255),
		0.3,
		fonts.icon,
		"center",
		"center"
	)

	if hover and isKeyPressed("mouse1") then
		Call.destroyAllSounds()
		triggerServerEvent("phone.answerCall", localPlayer, Phone.number, Call.incomingNumber, true)
	end
end)

addEvent("phone.call", true)
addEventHandler("phone.call", root, function(targetEntity, targetNumber, number)
	local isBlocked = find(Contacts.list, function(_, contact)
		return contact.targetNumber == targetNumber and contact.isBlocked == ContactsIsBlocked.Yes
	end)

	if isBlocked then
		triggerServerEvent("phone.answerCall", localPlayer, Phone.number, targetNumber, false)
		return
	end

	if not Phone.visible then
		Phone.show(number)
	end

	Call.incomingNumber = targetNumber
	Call.currentPage = Call.enums.Pages.Incoming
	Phone.goToApp(Phone.enums.Apps.Call)

	local musicPath = "public/ringtones/default.mp3"

	Call.destroyAllSounds()

	if isElement(Call.sounds.incoming) then
		destroyElement(Call.sounds.incoming)
	end

	Call.sounds.incoming = CallSoundStreamer.play(musicPath, true)
end)
