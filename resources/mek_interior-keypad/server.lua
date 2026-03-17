local function ownsInterior(player, interior)
	local status = getElementData(interior, "status")
	return status.owner == getElementData(player, "dbid")
end

function openKeypadInterface(pad)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	local intID = getElementData(pad, "itemValue")
	if not intID then
		exports.mek_infobox:addBox(source, "error", "Sistem aşırı yüklendi, daha sonra tekrar deneyin.")
		return false
	end

	for i, interior in pairs(getElementsByType("interior")) do
		if getElementData(interior, "dbid") == intID then
			if isSomeoneElseUsingAnyKeypadOfThis(interior) then
				exports.mek_infobox:addBox(source, "error", "Sistem aşırı yüklendi, daha sonra tekrar deneyin.")
			else
				setElementData(source, "padUsing", getElementData(pad, "id"))
				setElementData(pad, "playerUsing", getElementData(source, "dbid"))
				triggerClientEvent(source, "openKeypadInterface", source, pad)
			end
			break
		end
	end
end
addEvent("openKeypadInterface", true)
addEventHandler("openKeypadInterface", root, openKeypadInterface)

function installKeypad(pad, interior)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not ownsInterior(source, interior) then
		return
	end

	if setElementData(interior, "keypad_lock", getElementData(pad, "id"), true) then
		dbExec(
			exports.mek_mysql:getConnection(),
			"UPDATE `interiors` SET `keypad_lock` = ? WHERE `id` = ?",
			getElementData(pad, "id"),
			getElementData(interior, "dbid")
		)
	end
end
addEvent("installKeypad", true)
addEventHandler("installKeypad", root, installKeypad)

function uninstallKeypad(pad, interior)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not ownsInterior(client, interior) then
		return
	end

	if getElementData(interior, "status").locked then
		triggerClientEvent(source, "keypadRecieveResponseFromServer", source, "uninstallKeypad - failed")
		return false
	end

	if not exports.mek_item:hasSpaceForItem(source, 169, 1) then
		triggerClientEvent(source, "keypadRecieveResponseFromServer", source, "uninstallKeypad - failed 2")
		return false
	end

	if interior and isElement(interior) and getElementData(interior, "keypad_lock") then
		local count = -1
		for i, pad2 in pairs(getElementsByType("object", getResourceRootElement(getResourceFromName("mek_item-world")))) do
			if
				getElementData(pad2, "itemID") == 169
				and getElementData(pad2, "itemValue") == getElementData(interior, "dbid")
			then
				count = count + 1
			end
		end

		if count <= 0 then
			removeElementData(interior, "keypad_lock")
			removeElementData(interior, "keypad_lock_pw")
			removeElementData(interior, "keypad_lock_auto")
			dbExec(
				exports.mek_mysql:getConnection(),
				"UPDATE `interiors` SET `keypad_lock` = NULL, `keypad_lock_pw` = NULL, `keypad_lock_auto` = NULL WHERE `id` = ?",
				getElementData(interior, "dbid")
			)
		end
	end

	triggerEvent("pickupItem", source, pad)
	triggerClientEvent(source, "closeKeypadInterface", source)
end
addEvent("uninstallKeypad", true)
addEventHandler("uninstallKeypad", root, uninstallKeypad)

function registerNewPasscode(interior, passcode)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not ownsInterior(client, interior) then
		return
	end

	dbExec(
		exports.mek_mysql:getConnection(),
		"UPDATE interiors SET keypad_lock_pw = ? WHERE id = ?",
		passcode,
		getElementData(interior, "dbid")
	)

	triggerClientEvent(source, "keypadRecieveResponseFromServer", source, "registerNewPasscode - ok")
end
addEvent("registerNewPasscode", true)
addEventHandler("registerNewPasscode", root, registerNewPasscode)

function togKeypadAutoLock(theInt)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not ownsInterior(client, theInt) then
		return
	end

	local currentState = getElementData(theInt, "keypad_lock_auto") or false
	local intID = getElementData(theInt, "dbid")
	local allDone = true

	if currentState then
		if
			removeElementData(theInt, "keypad_lock_auto")
			and dbExec(
				exports.mek_mysql:getConnection(),
				"UPDATE `interiors` SET `keypad_lock_auto` = NULL WHERE `id` = ?",
				intID
			)
		then
			triggerClientEvent(source, "keypadRecieveResponseFromServer", source, "togKeypadAutoLock - off")
		else
			allDone = false
		end
	else
		if
			setElementData(theInt, "keypad_lock_auto", not currentState)
			and dbExec(
				exports.mek_mysql:getConnection(),
				"UPDATE `interiors` SET `keypad_lock_auto` = '1' WHERE `id` = ?",
				intID
			)
		then
			triggerClientEvent(source, "keypadRecieveResponseFromServer", source, "togKeypadAutoLock - on")
		else
			allDone = false
		end
	end

	if not allDone then
		triggerClientEvent(source, "keypadRecieveResponseFromServer", source, false)
	end
end
addEvent("togKeypadAutoLock", true)
addEventHandler("togKeypadAutoLock", root, togKeypadAutoLock)

function resourceStop()
	if getResourceFromName(tostring("item-world")) then
		for i, pad in pairs(getElementsByType("object", getResourceRootElement(getResourceFromName("mek_item-world")))) do
			if getElementData(pad, "itemID") == 169 and getElementData(pad, "playerUsing") then
				removeElementData(pad, "playerUsing")
			end
		end
	end

	for i, player in pairs(getElementsByType("player")) do
		if getElementData(player, "padUsing") then
			removeElementData(player, "padUsing")
		end
	end
end
addEventHandler("onResourceStop", resourceRoot, resourceStop)

addEventHandler("onPlayerQuit", root, function()
	local padID = getElementData(source, "padUsing")
	if padID then
		for i, pad in pairs(getElementsByType("object", getResourceRootElement(getResourceFromName("mek_item-world")))) do
			if getElementData(pad, "id") == padID then
				removeElementData(pad, "playerUsing")
				break
			end
		end
	end
end)

function isSomeoneElseUsingAnyKeypadOfThis(interior)
	if not interior or not isElement(interior) then
		return false
	end

	local intID = getElementData(interior, "dbid")

	if not intID then
		return false
	end

	for i, pad in pairs(getElementsByType("object", getResourceRootElement(getResourceFromName("mek_item-world")))) do
		if
			getElementData(pad, "itemID") == 169
			and getElementData(pad, "itemValue") == intID
			and getElementData(pad, "playerUsing")
		then
			for i, player in pairs(getElementsByType("player")) do
				if getElementData(player, "dbid") == getElementData(pad, "playerUsing") then
					return true
				end
			end
		end
	end
	return false
end

function keypadFreeUsingSlots(pad)
	if getElementData(pad, "playerUsing") then
		removeElementData(pad, "playerUsing")
	end

	if getElementData(source, "padUsing") then
		removeElementData(source, "padUsing")
	end
end
addEvent("keypadFreeUsingSlots", true)
addEventHandler("keypadFreeUsingSlots", root, keypadFreeUsingSlots)

function playSyncedSound(code, pad)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	triggerClientEvent(root, "playSyncedSound", source, code, pad)
end
addEvent("playSyncedSound", true)
addEventHandler("playSyncedSound", root, playSyncedSound)
