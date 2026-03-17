local playerAnimations = {}

addEventHandler("onPlayerJoin", root, function()
	playerAnimations[source] = {}
end)

addEventHandler("onResourceStart", resourceRoot, function()
	for _, player in pairs(getElementsByType("player")) do
		playerAnimations[player] = {}
		if getElementData(player, "logged") and getElementData(player, "custom_animation") then
			triggerClientEvent(
				root,
				"setPlayerCustomAnimation",
				root,
				player,
				getElementData(player, "custom_animation")
			)
		end
	end
end)

addEvent("onCustomAnimationStop", true)
addEventHandler("onCustomAnimationStop", root, function(player)
	setAnimation(player, false)
end)

addEvent("onCustomAnimationSyncRequest", true)
addEventHandler("onCustomAnimationSyncRequest", root, function(player)
	triggerLatentClientEvent(player, "onClientCustomAnimationSyncRequest", 50000, false, player, playerAnimations)
end)

addEvent("onClientCustomAnimationUpdate", true)
addEventHandler("onClientCustomAnimationUpdate", root, function(index)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	dbExec(
		exports.mek_mysql:getConnection(),
		"UPDATE characters SET custom_animation = ? WHERE id = ?",
		index,
		getElementData(source, "dbid")
	)
end)

function setPlayerCustomAnimations(player, index)
	triggerClientEvent(root, "setPlayerCustomAnimation", root, player, index)
end

addEventHandler("onPlayerQuit", root, function()
	playerAnimations[source] = nil
end)

addEvent("onCustomAnimationSet", true)
addEventHandler("onCustomAnimationSet", root, function(player, blockName, animationName)
	setAnimation(player, blockName, animationName)
	triggerClientEvent(root, "onClientCustomAnimationSet", player, blockName, animationName)
end)

addEvent("onCustomAnimationReplace", true)
addEventHandler("onCustomAnimationReplace", root, function(player, ifpIndex)
	playerAnimations[player].replacedPedBlock = ifpIndex
	triggerClientEvent(root, "onClientCustomAnimationReplace", player, ifpIndex)
end)

addEvent("onCustomAnimationRestore", true)
addEventHandler("onCustomAnimationRestore", root, function(player, blockName)
	playerAnimations[player].replacedPedBlock = nil
	triggerClientEvent(root, "onClientCustomAnimationRestore", player, blockName)
end)

function setAnimation(player, blockName, animationName)
	if not playerAnimations[player] then
		playerAnimations[player] = {}
	end

	if blockName == false then
		playerAnimations[player].current = nil
	else
		playerAnimations[player].current = { blockName, animationName }
	end
end
