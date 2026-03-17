addEvent("interaction.createAskContext", true)
addEventHandler("interaction.createAskContext", root, function(target, details)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not isElement(target) or getElementType(target) ~= "player" then
		return
	end

	local askDetails = {
		title = details.title,
		description = details.description,
		asker = source,
		target = target,
		question = details.question,
		timeout = details.timeout or 30000,
	}

	triggerClientEvent(target, "interaction.showAskContext", target, askDetails)
end)

addEvent("interaction.answerContext", true)
addEventHandler("interaction.answerContext", root, function(action, details)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if action ~= "yes" and action ~= "no" then
		return
	end

	if not details or not isElement(details.target) or getElementType(details.target) ~= "player" then
		return
	end

	triggerClientEvent(details.asker, "interaction.replyAskContext", details.asker, action, details)
end)
