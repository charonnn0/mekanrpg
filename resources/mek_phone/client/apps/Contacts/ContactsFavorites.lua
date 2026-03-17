Contacts.addPage(Contacts.enums.Pages.Favorites, function(position, size)
	Phone.components.Header(function(position, size)
		dxDrawText(
			"Favoriler",
			position.x + Contacts.listPadding,
			position.y + (Contacts.listPadding * 2),
			0,
			0,
			rgba(theme.GRAY[200]),
			1,
			fonts.BebasNeueBold.h1
		)
	end)

	drawContacts(position, size, function(contact)
		if not contact then
			return false
		end

		return contact.isFavorite == ContactsIsFavorite.Yes
	end)
end)
