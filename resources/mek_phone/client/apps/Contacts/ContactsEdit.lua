local actionIconSize = {
	x = 32,
	y = 32,
}

Contacts.editContactLoading = false
Contacts.editContactID = nil

Contacts.addPage(Contacts.enums.Pages.EditContact, function(position, size)
	local contact = Contacts.list[Contacts.editContactID]

	if not contact then
		Contacts.currentPage = Contacts.enums.Pages.Contacts
		return
	end

	local isBlocked = contact.isBlocked == ContactsIsBlocked.Yes

	Phone.components.Header(function(position, size)
		dxDrawText(
			"Kişiyi Düzenle",
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
		name = "contacts.edit.name" .. contact.name,

		label = "İsim",
		placeholder = "örn: Chris",
		value = contact.name,

		variant = "outlined",
		color = "gray",
		disabled = isBlocked or Contacts.editContactLoading,
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
		name = "contacts.edit.number" .. contact.name,

		label = "Numara",
		placeholder = "örn: 12345",
		value = contact.targetNumber,

		variant = "outlined",
		color = "gray",
		disabled = isBlocked or Contacts.editContactLoading,
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

		icon = "",
		text = "Kaydet",
		disabled = isBlocked or Contacts.editContactLoading,
	})

	local deleteButton = drawButton({
		position = {
			x = position.x + Contacts.listPadding,
			y = Contacts.listPosition.y + Contacts.listSize.y - 90,
		},
		size = {
			x = (size.x - Contacts.listPadding * 2) / 2,
			y = 35,
		},

		variant = "soft",
		color = "red",

		text = "Kişiyi Sil",

		icon = "",
		disabled = Contacts.editContactLoading,
	})

	local blockButton = drawButton({
		position = {
			x = position.x + Contacts.listPadding + ((size.x - Contacts.listPadding * 2) / 2),
			y = Contacts.listPosition.y + Contacts.listSize.y - 90,
		},
		size = {
			x = (size.x - Contacts.listPadding * 2) / 2,
			y = 35,
		},

		variant = "soft",
		color = "red",

		icon = "",

		text = isBlocked and "Kaldır" or "Engelle",
		disabled = Contacts.editContactLoading,
	})

	if confirmButton.pressed then
		local name = nameInput.value
		local number = numberInput.value

		if Contacts.editContactLoading then
			return
		end

		if name and number then
			if #name < 3 or #number < 1 then
				Phone.showNotification("error", "İsim ve numara en az 3 karakter olmalıdır.")
				return
			end

			Contacts.editContactLoading = true
			Contacts.list[Contacts.editContactID].name = name
			Contacts.list[Contacts.editContactID].number = number

			triggerServerEvent("phone.contacts.edit", localPlayer, Phone.number, contact.id, name, number)
		end
	end

	if deleteButton.pressed then
		if Contacts.editContactLoading then
			return
		end

		Contacts.editContactLoading = true
		triggerServerEvent("phone.contacts.delete", localPlayer, Phone.number, contact.id)
	end

	if blockButton.pressed then
		if Contacts.editContactLoading then
			return
		end

		isBlocked = isBlocked and ContactsIsBlocked.No or ContactsIsBlocked.Yes
		Contacts.list[Contacts.editContactID].isBlocked = isBlocked

		Contacts.editContactLoading = true
		triggerServerEvent("phone.contacts.updateBlock", localPlayer, contact.id, isBlocked)
	end
end)

addEvent("phone.contacts.onEditContact", true)
addEventHandler("phone.contacts.onEditContact", root, function(response)
	Contacts.editContactLoading = false
	if not response.success then
		Phone.showNotification("error", response.message)
		return
	end
	Contacts.currentPage = Contacts.enums.Pages.Contacts
	Contacts.loadContacts()
end)

addEvent("phone.contacts.onDeleteContact", true)
addEventHandler("phone.contacts.onDeleteContact", root, function(response)
	Contacts.editContactLoading = false
	if not response.success then
		Phone.showNotification("error", response.message)
		return
	end
	Contacts.currentPage = Contacts.enums.Pages.Contacts
	Contacts.loadContacts()
end)
