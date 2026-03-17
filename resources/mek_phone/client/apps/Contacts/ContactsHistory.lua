Contacts.historyOffset = Contacts.listItemOffset
Contacts.historyLimit = Contacts.listItemLimit

Contacts.historyVisibleColors = {
	[ContactsCallHistory.InCall] = "GREEN",
	[ContactsCallHistory.Missed] = "RED",
	[ContactsCallHistory.Outgoing] = "GRAY",
	[ContactsCallHistory.Incoming] = "GRAY",
}

local actionIconSize = {
	x = 32,
	y = 32,
}

function drawHistory(position, size, visibleCondition)
	local counter = 0
	for i = Contacts.historyOffset, Contacts.historyLimit do
		local contact = Contacts.historyList[i]
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
			if isKeyPressed("mouse1") and contact then
				local targetNumber = tonumber(contact.number) == Phone.number and contact.targetNumber or contact.number
				Contacts.editContactID = Contacts.getContactID(targetNumber)
				Contacts.addContactNumber = targetNumber

				Contacts.currentPage = Contacts.isContact(targetNumber) and Contacts.enums.Pages.EditContact
					or Contacts.enums.Pages.AddContact
			end
		end

		dxDrawRectangle(
			listItemPosition.x,
			listItemPosition.y,
			Contacts.listItemSize.x,
			Contacts.listItemSize.y,
			backgroundColor
		)

		local isVisible = visibleCondition and visibleCondition(contact) or visibleCondition == nil

		if contact and isVisible then
			local isTargetMe = tonumber(contact.number) == Phone.number
			local additionalText = ""
			local targetNumber = tonumber(contact.number) == Phone.number and contact.targetNumber or contact.number

			if isTargetMe then
				additionalText = " (Giden Arama)"
			else
				additionalText = " (Gelen Arama)"
			end

			if contact.callType == ContactsCallHistory.InCall then
				local endTs = tonumber(contact.inCallTime) or 0
				local startTs = tonumber(contact.createdAt) or 0

				local duration
				if endTs > 0 and startTs > 0 and endTs >= startTs then
					duration = endTs - startTs
				elseif startTs > 0 and (endTs == 0 or endTs < startTs) then
					duration = math.max(0, getRealTime().timestamp - startTs)
				else
					duration = 0
				end

				additionalText = " (" .. exports.mek_datetime:formatSeconds(duration) .. ")"
			end

			local _, time = exports.mek_datetime:formatTimeShortInterval(contact.createdAt)

			dxDrawText(
				Contacts.getName(targetNumber) .. additionalText,
				listItemPosition.x + Contacts.listPadding,
				listItemPosition.y,
				0,
				Contacts.listItemSize.y + listItemPosition.y,
				rgba(theme[Contacts.historyVisibleColors[contact.callType]][500]),
				1,
				fonts.BebasNeueRegular.h6,
				"left",
				"center",
				false,
				false,
				false,
				true
			)

			dxDrawText(
				time,
				listItemPosition.x - Contacts.listPadding * 4,
				listItemPosition.y,
				Contacts.listItemSize.x + listItemPosition.x - Contacts.listPadding * 4,
				Contacts.listItemSize.y + listItemPosition.y,
				rgba(theme.GRAY[400]),
				1,
				fonts.BebasNeueRegular.caption,
				"right",
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

			if callButton.pressed then
				triggerServerEvent("phone.startCall", localPlayer, Phone.number, targetNumber)
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

Contacts.isContact = function(number)
	local contact = find(Contacts.list, function(_, row)
		return row.targetNumber == number
	end)

	return contact and true or false
end

addEventHandler("onClientKey", root, function(button, state)
	if Phone.currentApp ~= Phone.enums.Apps.Contacts then
		return
	end

	if Contacts.currentPage ~= Contacts.enums.Pages.History then
		return
	end

	if button == "mouse_wheel_up" then
		if Contacts.historyOffset == 0 then
			return
		end

		Contacts.historyOffset = Contacts.historyOffset - Contacts.listItemLimit
		if Contacts.historyOffset < 0 then
			Contacts.historyOffset = 0
		end

		Contacts.historyLimit = Contacts.historyOffset + Contacts.listItemLimit

		Contacts.loadHistory()
	elseif button == "mouse_wheel_down" then
		if Contacts.totalCount <= Contacts.historyLimit then
			return
		end

		Contacts.historyOffset = Contacts.historyOffset + Contacts.listItemLimit
		if Contacts.historyOffset > Contacts.totalCount then
			Contacts.historyOffset = Contacts.listItemLimit
		end

		Contacts.historyLimit = Contacts.historyOffset + Contacts.listItemLimit

		Contacts.loadHistory()
	end
end)

Contacts.addPage(Contacts.enums.Pages.History, function(position, size)
	Phone.components.Header(function(position, size)
		dxDrawText(
			"Arama Geçmişi",
			position.x + Contacts.listPadding,
			position.y + (Contacts.listPadding * 2),
			0,
			0,
			rgba(theme.GRAY[200]),
			1,
			fonts.BebasNeueBold.h1
		)
	end)

	drawHistory(position, size)
end)

addEvent("phone.contacts.onGetHistory", true)
addEventHandler("phone.contacts.onGetHistory", root, function(offset, limit, contacts)
	Contacts.listIsLoading = false
	local counter = 1
	for i = offset, limit do
		local contact = contacts[counter]
		if contact then
			Contacts.historyList[i] = {
				number = tonumber(contact.caller_number),
				targetNumber = tonumber(contact.receiver_number),
				callType = contact.call_type,
				inCallTime = tonumber(contact.in_call_time),
				createdAt = tonumber(contact.created_at),
			}
		else
			Contacts.historyList[i] = nil
		end
		counter = counter + 1
	end

	Contacts.historyOffset = offset
	Contacts.historyLimit = limit
end)
