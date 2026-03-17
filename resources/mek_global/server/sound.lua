addEvent("global.playSound3D", true)
addEventHandler("global.playSound3D", root, function(soundPath, looped, distance, volume, throttled)
	for _, player in pairs(getNearbyElements(source, "player", distance)) do
		triggerClientEvent(
			player,
			"global.playSound3D",
			source,
			soundPath,
			looped or false,
			distance or 10,
			volume or 100,
			throttled or false
		)
	end
end)