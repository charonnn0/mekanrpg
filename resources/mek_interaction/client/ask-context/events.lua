local askContextInCache = {}

function createAskContext(details, resolve, reject)
	triggerServerEvent("interaction.createAskContext", localPlayer, details.target, details)

	askContextInCache[details.asker] = {
		resolve = resolve,
		reject = reject,
	}
end

addEvent("interaction.showAskContext", true)
addEventHandler("interaction.showAskContext", root, function(details)
	if not isElement(details.asker) then
		return
	end

	showAskContext(details)
end)

addEvent("interaction.replyAskContext", true)
addEventHandler("interaction.replyAskContext", root, function(action, details)
	local contextInCache = askContextInCache[details.asker]
	if not contextInCache then
		return
	end

	if action == "yes" then
		if type(contextInCache.resolve) == "function" then
			contextInCache.resolve(details.target)
		else
			triggerEvent(contextInCache.resolve, localPlayer, details)
		end
	else
		if type(contextInCache.reject) == "function" then
			contextInCache.reject(details.target)
		else
			triggerEvent(contextInCache.reject, localPlayer, details)
		end
	end
end)
