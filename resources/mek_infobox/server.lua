function addBox(element, type, message)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end
	triggerClientEvent(element, "infobox.addBox", element, type, message, 10000)
end
