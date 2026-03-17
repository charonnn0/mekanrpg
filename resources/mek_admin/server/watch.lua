local watcher = {}
local watched = {}

function takeScreen()
	for player in pairs(watched) do
		if isElement(player) then
			takePlayerScreenShot(player, 200, 200, getPlayerName(player), 50, 1000000)
		end
	end
end
setTimer(takeScreen, 50, 0)

addEventHandler("onPlayerScreenShot", root, function(_, status, imageData)
	if status ~= "ok" or not watched[source] then
		return
	end

	for _, watcherPlayer in ipairs(watched[source]) do
		if isElement(watcherPlayer) then
			triggerClientEvent(watcherPlayer, "updateScreen", watcherPlayer, imageData, source)
		end
	end
end)

local function removeWatcher(watcherPlayer)
	local targetPlayer = watcher[watcherPlayer]
	if targetPlayer and watched[targetPlayer] then
		for i, v in ipairs(watched[targetPlayer]) do
			if v == watcherPlayer then
				table.remove(watched[targetPlayer], i)
				break
			end
		end
		if #watched[targetPlayer] == 0 then
			watched[targetPlayer] = nil
		end
	end
	watcher[watcherPlayer] = nil
	triggerClientEvent(watcherPlayer, "stopScreen", watcherPlayer)
end

function stopWatch(thePlayer)
	if watcher[thePlayer] then
		removeWatcher(thePlayer)
		outputChatBox("[!]#FFFFFF Artık kimseyi izlemiyorsunuz.", thePlayer, 255, 0, 0, true)
	else
		outputChatBox("[!]#FFFFFF Zaten kimseyi izlemiyorsunuz.", thePlayer, 255, 255, 0, true)
	end
end
addCommandHandler("stopwatch", stopWatch, false, false)

function watchPlayer(thePlayer, _, targetPlayer)
	if not exports.mek_integration:isPlayerGeneralAdmin(thePlayer) then
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
		return
	end

	if not targetPlayer then
		stopWatch(thePlayer)
		return
	end

	local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
	if not targetPlayer then
		return
	end

	if watcher[thePlayer] == targetPlayer then
		outputChatBox("[!]#FFFFFF Bu oyuncuyu zaten izliyorsunuz.", thePlayer, 255, 255, 0, true)
		return
	end

	removeWatcher(thePlayer)

	watcher[thePlayer] = targetPlayer
	watched[targetPlayer] = watched[targetPlayer] or {}
	table.insert(watched[targetPlayer], thePlayer)

	outputChatBox("[!]#FFFFFF " .. targetPlayerName .. " isimli oyuncuyu izliyorsunuz.", thePlayer, 0, 255, 0, true)
	exports.mek_logs:addLog(
		"watch",
		exports.mek_global:getPlayerFullAdminTitle(thePlayer)
			.. " isimli yetkili "
			.. targetPlayerName
			.. " isimli oyuncuyu izlemeye başladı."
	)
end
addCommandHandler("watch", watchPlayer, false, false)

addEventHandler("onPlayerQuit", root, function()
	removeWatcher(source)

	for targetPlayer, list in pairs(watched) do
		for i, v in ipairs(list) do
			if v == source then
				table.remove(watched[targetPlayer], i)
				break
			end
		end
		if #watched[targetPlayer] == 0 then
			watched[targetPlayer] = nil
		end
	end
end)
