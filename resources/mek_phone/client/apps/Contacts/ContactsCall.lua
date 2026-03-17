Contacts.keypadItems = {
	{ value = "1", icon = "1" },
	{ value = "2", icon = "2" },
	{ value = "3", icon = "3" },
	{ value = "4", icon = "4" },
	{ value = "5", icon = "5" },
	{ value = "6", icon = "6" },
	{ value = "7", icon = "7" },
	{ value = "8", icon = "8" },
	{ value = "9", icon = "9" },
	{ value = "clear", icon = "" },
	{ value = "0", icon = "0" },
	{ value = "#", icon = "#" },
}
Contacts.keypadGridGap = 5
Contacts.keypadGridColumns = 3
Contacts.keypadGridRows = 4
Contacts.keypadGridItemSize = {
	x = 48,
	y = 48,
}
Contacts.keypadGridSize = {
	x = Contacts.keypadGridItemSize.x * Contacts.keypadGridColumns
		+ Contacts.keypadGridGap * (Contacts.keypadGridColumns - 1),
	y = Contacts.keypadGridItemSize.y * Contacts.keypadGridRows
		+ Contacts.keypadGridGap * (Contacts.keypadGridRows - 1),
}
Contacts.maxKeypadLength = 15

Contacts.addPage(Contacts.enums.Pages.Call, function(position, size)
	local keypadInput = drawInput({
		position = {
			x = position.x + (size.x - Contacts.keypadGridSize.x) / 2,
			y = position.y + 135,
		},
		size = {
			x = Contacts.keypadGridSize.x,
			y = 30,
		},
		name = "contacts.keypad",
		regex = "^[0-9#*]+$",
		placeholder = "Numara tuşlayın",
		variant = "outlined",
		color = "gray",
	})

	for i, item in ipairs(Contacts.keypadItems) do
		local x = position.x
			+ (size.x - Contacts.keypadGridSize.x) / 2
			+ (i - 1) % Contacts.keypadGridColumns * (Contacts.keypadGridItemSize.x + Contacts.keypadGridGap)
		local y = position.y
			+ (size.y - Contacts.keypadGridSize.y) / 2
			+ math.floor((i - 1) / Contacts.keypadGridColumns)
				* (Contacts.keypadGridItemSize.y + Contacts.keypadGridGap)

		local isIcon = item.value == "clear"

		local button = drawButton({
			position = { x = x, y = y },
			size = Contacts.keypadGridItemSize,

			textProperties = {
				align = "center",
				color = styles.foreground,
				font = isIcon and fonts.icon or fonts.UbuntuRegular.body,
				scale = isIcon and 0.5 or 1,
			},

			variant = "plain",
			color = "gray",
			disabled = false,

			text = item.icon,
		})

		if button.pressed then
			local value = tonumber(item.value)
			if value then
				if string.len(keypadInput.value) >= Contacts.maxKeypadLength then
					return
				end

				keypadInput.input:setText(keypadInput.value .. value)
			elseif item.value == "clear" then
				keypadInput.input:setText("")
			end
		end
	end

	local callButton = drawButton({
		position = {
			x = position.x + size.x / 2 - Contacts.keypadGridItemSize.x / 2,
			y = position.y + size.y / 2 + Contacts.keypadGridItemSize.y * 2.5,
		},
		size = Contacts.keypadGridItemSize,

		radius = 8,

		textProperties = {
			align = "center",
			color = styles.foreground,
			font = fonts.icon,
			scale = 0.5,
		},

		variant = "soft",
		color = "green",
		disabled = false,

		text = "",
	})

	if callButton.pressed then
		local number = keypadInput.value

		if not number or not tonumber(number) then
			Phone.showNotification("error", "Lütfen geçerli numara girin.")
			return
		end

		if #number >= 11 then
			Phone.showNotification("error", "Numara 11 karakterden uzun olamaz.")
			return
		end

		triggerServerEvent("phone.startCall", localPlayer, Phone.number, keypadInput.value)
	end
end)

addEvent("phone.callRequestError", true)
addEventHandler("phone.callRequestError", root, function(targetNumber, error)
	if error.code == 1 then
		if isElement(Call.sounds.cantReach) then
			destroyElement(Call.sounds.cantReach)
		end

		Call.outgoingNumber = targetNumber

		Phone.goToApp(Phone.enums.Apps.Call)
		Call.currentPage = Call.enums.Pages.Outgoing

		Call.sounds.cantReach = playSound("public/sounds/cant-reach.mp3")
		setSoundVolume(Call.sounds.cantReach, 0.5)

		addEventHandler("onClientSoundStopped", Call.sounds.cantReach, function(reason)
			if reason == "finished" then
				Call.sounds.hangUp = playSound("public/sounds/hangup.wav")
				setSoundVolume(Call.sounds.hangUp, 0.5)
				Call.outgoingNumber = nil
				Call.sounds.cantReach = nil
				Phone.goToApp(Phone.enums.Apps.Home)
			end
		end)
	else
		exports.mek_infobox:addBox("error", error.message)
	end
end)
