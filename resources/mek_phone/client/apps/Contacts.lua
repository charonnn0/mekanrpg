Contacts = {
	enums = {
		Pages = {
			Call = "Call",
			History = "History",
			Contacts = "Contacts",
			AddContact = "AddContact",
			EditContact = "EditContact",
			Favorites = "Favorites",
		},
	},
}

Contacts.historyList = {}
Contacts.list = {}
Contacts.components = {}
Contacts.currentPage = Contacts.enums.Pages.Call
Contacts.menuItems = {
	{ value = Contacts.enums.Pages.History, icon = "" },
	{ value = Contacts.enums.Pages.Call, icon = "" },
	{ value = Contacts.enums.Pages.Contacts, icon = "" },
	{ value = Contacts.enums.Pages.Favorites, icon = "" },
}

Contacts.listPadding = 10
Contacts.listSize = {
	x = Phone.innerSize.x,
	y = Phone.innerSize.y - Phone.headerPadding - Phone.bottomMenuPadding - Contacts.listPadding,
}

Contacts.listPosition = {
	x = Phone.innerPosition.x,
	y = Phone.innerPosition.y + Phone.headerPadding + Contacts.listPadding,
}

Contacts.listItemSize = {
	x = Contacts.listSize.x,
	y = 35,
}

Contacts.totalCount = 0
Contacts.listItemOffset = 0
Contacts.listItemLimit = math.floor(Contacts.listSize.y / Contacts.listItemSize.y)

Contacts.offset = Contacts.listItemOffset
Contacts.limit = Contacts.listItemLimit

Contacts.addPage = function(page, callback)
	Contacts.components[page] = callback
end

Contacts.listIsLoading = false

Contacts.loadContacts = function(offset, limit)
	offset = offset or Contacts.offset
	limit = limit or Contacts.limit

	Contacts.listIsLoading = true

	triggerServerEvent("phone.contacts.get", localPlayer, Phone.number, {
		offset = offset,
		limit = limit,
	})
end

Contacts.loadHistory = function(offset, limit)
	offset = offset or Contacts.historyOffset
	limit = limit or Contacts.historyLimit

	Contacts.listIsLoading = true

	triggerServerEvent("phone.contacts.getHistory", localPlayer, Phone.number, {
		offset = offset,
		limit = limit,
	})
end

Contacts.getContactID = function(targetNumber)
	local contactID = false
	for i = 0, #Contacts.list do
		local contact = Contacts.list[i]
		if contact and contact.targetNumber == targetNumber then
			contactID = i
			break
		end
	end

	return contactID
end

Phone.addApp(
	Phone.enums.Apps.Contacts,
	function(position, size)
		local currentPage = Contacts.components[Contacts.currentPage]
		if currentPage then
			currentPage(position, size)
		end

		Phone.components.BottomMenu(Contacts.menuItems, function(app)
			Contacts.currentPage = app
		end, Contacts.currentPage)
	end,
	"public/apps/phone.png",
	"Ara",
	nil,
	function()
		Contacts.loadContacts()
		Contacts.loadHistory()
	end
)

addEvent("phone.contacts.onGetContacts", true)
addEventHandler("phone.contacts.onGetContacts", root, function(offset, limit, contacts, totalContacts)
	Contacts.listIsLoading = false

	local counter = 1
	for i = offset, limit do
		local contact = contacts[counter]
		if contact then
			Contacts.list[i] = {
				id = tonumber(contact.id),
				phoneNumber = tonumber(contact.phone_number),
				name = contact.name,
				targetNumber = tonumber(contact.target_number),
				isFavorite = tonumber(contact.is_favorite) == 1 and ContactsIsFavorite.Yes or ContactsIsFavorite.No,
				isBlocked = tonumber(contact.is_blocked) == 1 and ContactsIsBlocked.Yes or ContactsIsBlocked.No,
			}
		else
			Contacts.list[i] = nil
		end

		counter = counter + 1
	end

	Contacts.offset = offset
	Contacts.limit = limit
	Contacts.totalCount = totalContacts
end)
