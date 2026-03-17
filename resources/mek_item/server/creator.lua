function spawnItem(targetPlayer, itemID, itemValue)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	executeCommandHandler("giveitem", source, targetPlayer .. " " .. itemID .. " " .. itemValue)
end
addEvent("itemCreator.spawnItem", true)
addEventHandler("itemCreator.spawnItem", root, spawnItem)
