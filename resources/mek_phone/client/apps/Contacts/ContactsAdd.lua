local actionIconSize = {
	x = 32,
	y = 32,
}

Contacts.addContactLoading = false

Contacts.addPage(Contacts.enums.Pages.AddContact, function(position, size)
	Phone.components.Header(function(position, size)
		dxDrawText(
			"Kişi Ekle",
			position.x + Contacts.listPadding,
			position.y + (Contacts.listPadding * 2),
			0,
			0,
			rgba(theme.GRAY[200]),
			1,
			fonts.BebasNeueBold.h1
		)

		local backButton = drawButton({
			position = {
				x = position.x + size.x - Contacts.listPadding - actionIconSize.x,
				y = position.y + Contacts.listPadding * 2,
			},
			size = actionIconSize,

			textProperties = {
				align = "center",
				color = theme.GREEN[500],
				font = fonts.icon,
				scale = 0.5,
			},

			variant = "plain",
			color = "gray",

			text = "",
		})

		if backButton.pressed then
			Contacts.currentPage = Contacts.enums.Pages.Contacts
		end
	end)

	local nameInput = drawInput({
		position = {
			x = position.x + Contacts.listPadding,
			y = position.y + Contacts.listPadding * 11,
		},
		size = {
			x = size.x - Contacts.listPadding * 2,
			y = 35,
		},
		name = "contacts.add.name",

		label = "İsim",
		placeholder = "örn: charon",

		variant = "outlined",
		color = "gray",
		disabled = Contacts.addContactLoading,
	})

	local numberInput = drawInput({
		position = {
			x = position.x + Contacts.listPadding,
			y = position.y + Contacts.listPadding * 18,
		},
		size = {
			x = size.x - Contacts.listPadding * 2,
			y = 35,
		},
		name = "contacts.add.number",

		label = "Numara",
		placeholder = "örn: 12345",
		regex = "^[0-9#*]+$",

		value = Contacts.addContactNumber or "",

		variant = "outlined",
		color = "gray",
		disabled = Contacts.addContactLoading,
	})

	local confirmButton = drawButton({
		position = {
			x = position.x + Contacts.listPadding,
			y = Contacts.listPosition.y + Contacts.listSize.y - 50,
		},
		size = {
			x = size.x - Contacts.listPadding * 2,
			y = 35,
		},

		variant = "soft",
		color = "green",

		text = "Ekle",
		disabled = Contacts.addContactLoading,
	})

	if confirmButton.pressed then
		local name = nameInput.value
		local number = numberInput.value

		if Contacts.addContactLoading then
			return
		end

		if name and number then
			if #name < 3 or #number < 1 then
				Phone.showNotification("error", "İsim ve numara en az 3 karakter olmalıdır.")
				return
			end

			if #number >= 11 then
				Phone.showNotification("error", "Numara 11 karakterden uzun olamaz.")
				return
			end

			Contacts.addContactLoading = true

			triggerServerEvent("phone.contacts.add", localPlayer, Phone.number, name, number)
		end
	end
end)

addEvent("phone.contacts.onAddContact", true)
addEventHandler("phone.contacts.onAddContact", root, function(response)
	Contacts.addContactLoading = false
	if not response.success then
		Phone.showNotification("error", response.message)
		return
	end
	Contacts.currentPage = Contacts.enums.Pages.Contacts
	Contacts.loadContacts()
end)

addEvent("phone.contacts.openAddContactPage", true)
addEventHandler("phone.contacts.openAddContactPage", root, function(phoneNumber)
	Contacts.currentPage = Contacts.enums.Pages.AddContact
end)
