Contacts.searchQuery = ""

local actionIconSize = {
	x = 32,
	y = 32,
}

function drawContacts(position, size, visibleCondition)
	local counter = 0
	for i = Contacts.offset, Contacts.limit do
		local contact = Contacts.list[i]
		local isSearch = Contacts.searchQuery == ""
			or (contact and contact.name:lower():find(Contacts.searchQuery:lower()))
		local listItemPosition = {
			x = Contacts.listPosition.x,
			y = Contacts.listPosition.y + (Contacts.listItemSize.y * counter),
		}

		local backgroundColor = rgba(theme.GRAY[counter % 2 == 0 and 800 or 900])
		local hover = inArea(
			listItemPosition.x,
			listItemPosition.y,
			Contacts.listItemSize.x - (actionIconSize.x * 3),
			Contacts.listItemSize.y
		)

		if hover then
			backgroundColor = rgba(theme.GRAY[700])
			if isKeyPressed("mouse1") then
				Contacts.editContactID = i
				Contacts.currentPage = Contacts.enums.Pages.EditContact
			end
		end

		dxDrawRectangle(
			listItemPosition.x,
			listItemPosition.y,
			Contacts.listItemSize.x,
			Contacts.listItemSize.y,
			backgroundColor
		)

		local isVisible = visibleCondition and visibleCondition(contact) or (visibleCondition == nil)

		if contact and isSearch and isVisible then
			dxDrawText(
				contact.name .. theme.GRAY[600] .. " (" .. contact.targetNumber .. ")",
				listItemPosition.x + Contacts.listPadding,
				listItemPosition.y,
				0,
				Contacts.listItemSize.y + listItemPosition.y,
				rgba(theme.GRAY[200]),
				1,
				fonts.BebasNeueRegular.h6,
				"left",
				"center",
				false,
				false,
				false,
				true
			)

			local callButton = drawButton({
				position = {
					x = listItemPosition.x + Contacts.listItemSize.x - actionIconSize.x - Contacts.listPadding,
					y = listItemPosition.y + Contacts.listItemSize.y / 2 - actionIconSize.y / 2,
				},
				size = actionIconSize,

				textProperties = {
					align = "center",
					color = theme.GREEN[400],
					font = fonts.icon,
					scale = 0.4,
				},

				variant = "plain",
				color = "gray",

				text = "",
			})

			local favoriteButton = drawButton({
				position = {
					x = listItemPosition.x + Contacts.listItemSize.x - actionIconSize.x * 2 - 10,
					y = listItemPosition.y + Contacts.listItemSize.y / 2 - actionIconSize.y / 2,
				},
				size = actionIconSize,

				textProperties = {
					align = "center",
					color = contact.isFavorite == ContactsIsFavorite.Yes and theme.YELLOW[400] or theme.GRAY[500],
					font = fonts.icon,
					scale = 0.4,
				},

				variant = "plain",
				color = "gray",

				text = "",
			})

			if favoriteButton.pressed then
				Contacts.list[i].isFavorite = Contacts.list[i].isFavorite == ContactsIsFavorite.Yes
						and ContactsIsFavorite.No
					or ContactsIsFavorite.Yes
				triggerServerEvent(
					"phone.contacts.updateFavorite",
					localPlayer,
					contact.id,
					Contacts.list[i].isFavorite
				)
			end

			if callButton.pressed then
				triggerServerEvent("phone.startCall", localPlayer, Phone.number, contact.targetNumber)
			end
		elseif Contacts.listIsLoading then
			dxDrawText(
				"Yükleniyor...",
				listItemPosition.x + Contacts.listPadding,
				listItemPosition.y,
				0,
				Contacts.listItemSize.y + listItemPosition.y,
				rgba(theme.GREEN[300]),
				1,
				fonts.BebasNeueRegular.h6,
				"left",
				"center",
				false,
				false,
				false,
				true
			)
		else
			dxDrawText(
				"Boş Slot",
				listItemPosition.x + Contacts.listPadding,
				listItemPosition.y,
				0,
				Contacts.listItemSize.y + listItemPosition.y,
				rgba(theme.GRAY[700]),
				1,
				fonts.BebasNeueRegular.h6,
				"left",
				"center",
				false,
				false,
				false,
				true
			)
		end

		counter = counter + 1
	end
end

Contacts.getName = function(number)
	local contact = find(Contacts.list, function(_, row)
		return row.targetNumber == number
	end)

	return contact and contact.name or number
end

addEventHandler("onClientKey", root, function(button, state)
	if Phone.currentApp ~= Phone.enums.Apps.Contacts then
		return
	end

	if
		Contacts.currentPage ~= Contacts.enums.Pages.Contacts
		and Contacts.currentPage ~= Contacts.enums.Pages.Favorites
	then
		return
	end

	if Contacts.totalCount <= Contacts.listItemLimit then
		return
	end

	local scrollSpeed = 1

	if button == "mouse_wheel_up" then
		Contacts.offset = math.max(0, Contacts.offset - scrollSpeed)
		Contacts.limit = Contacts.offset + Contacts.listItemLimit
		Contacts.loadContacts()
	elseif button == "mouse_wheel_down" then
		Contacts.offset = math.min(Contacts.totalCount - Contacts.listItemLimit, Contacts.offset + scrollSpeed)
		Contacts.limit = Contacts.offset + Contacts.listItemLimit
		Contacts.loadContacts()
	end
end)

Contacts.addPage(Contacts.enums.Pages.Contacts, function(position, size)
	Phone.components.Header(function(position, size)
		dxDrawText(
			"Kişiler",
			position.x + Contacts.listPadding,
			position.y + (Contacts.listPadding * 2),
			0,
			0,
			rgba(theme.GRAY[200]),
			1,
			fonts.BebasNeueBold.h1
		)

		local searchInput = drawInput({
			position = {
				x = position.x + size.x / 2 - 90 / 2,
				y = position.y + Contacts.listPadding * 2 + 3,
			},
			size = {
				x = 90,
				y = 30,
			},
			name = "contacts.list.search",

			placeholder = "Ara",

			variant = "outlined",
			color = "gray",
		})
		Contacts.searchQuery = searchInput.value

		local addContactButton = drawButton({
			position = {
				x = position.x + size.x - Contacts.listPadding - actionIconSize.x,
				y = position.y + Contacts.listPadding * 2,
			},
			size = actionIconSize,
			radius = DEFAULT_RADIUS,

			textProperties = {
				align = "center",
				color = theme.GRAY[400],
				font = fonts.icon,
				scale = 0.5,
			},

			variant = "plain",
			color = "green",

			text = "",
		})

		if addContactButton.pressed then
			Contacts.currentPage = Contacts.enums.Pages.AddContact
		end
	end)

	drawContacts(position, size)
end)
