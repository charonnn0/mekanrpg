local isSpeaker = false
speakerBox = {}

addCommandHandler("ses", function(thePlayer, commandName)
	if isElement(speakerBox[thePlayer]) then
		isSpeaker = true
	end

	if thePlayer:getData("level") < 2 then
		exports.mek_infobox:addBox(thePlayer, "error", "2 seviyeden az olan oyuncular bu sistemi kullanamaz.")
		return
	end

	triggerClientEvent(thePlayer, "onPlayerViewSpeakerManagment", thePlayer, isSpeaker)
end)

addEvent("onPlayerPlaceSpeakerBox", true)
addEventHandler("onPlayerPlaceSpeakerBox", root, function(url, inVehicle)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end
	
	if client:getData("level") < 2 then
		exports.mek_infobox:addBox(client, "error", "2 seviyeden az olan oyuncular bu sistemi kullanamaz.")
		return
	end

	if url then
		if isElement(speakerBox[client]) then
			local x, y, z = getElementPosition(speakerBox[client])
			exports.mek_infobox:addBox(client, "error", "Ses başarıyla silindi.")
			destroyElement(speakerBox[client])
			removeEventHandler("onPlayerQuit", client, destroySpeakersOnPlayerQuit)
		end

		local x, y, z = getElementPosition(client)
		local rx, ry, rz = getElementRotation(client)
		local interior = getElementInterior(client)
		local dimension = getElementDimension(client)

		speakerBox[client] = createObject(2226, x - 0.5, y + 0.5, z - 1, 0, 0, rx)
		setElementInterior(speakerBox[client], interior)
		setElementDimension(speakerBox[client], dimension)
		exports.mek_infobox:addBox(client, "success", "Ses başarıyla oluşturuldu.")
		addEventHandler("onPlayerQuit", client, destroySpeakersOnPlayerQuit)
		triggerClientEvent(root, "onPlayerStartSpeakerBoxSound", root, client, url, inVehicle)

		if inVehicle then
			local vehicle = getPedOccupiedVehicle(client)
			attachElements(speakerBox[client], vehicle, -0.7, -1.5, -0.5, 0, 90, 0)
		end
	end
end)

addEvent("onPlayerDestroySpeakerBox", true)
addEventHandler("onPlayerDestroySpeakerBox", root, function()
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end
	
	if client:getData("level") < 2 then
		exports.mek_infobox:addBox(client, "error", "2 seviyeden az olan oyuncular bu sistemi kullanamaz.")
		return
	end

	if isElement(speakerBox[client]) then
		destroyElement(speakerBox[client])
		triggerClientEvent(root, "onPlayerDestroySpeakerBox", root, client)
		removeEventHandler("onPlayerQuit", client, destroySpeakersOnPlayerQuit)
		exports.mek_infobox:addBox(client, "success", "Ses başarıyla silindi.")
	else
		exports.mek_infobox:addBox(client, "error", "Şu anda eklediğiniz ses yok.")
	end
end)

addEvent("onPlayerChangeSpeakerBoxVolume", true)
addEventHandler("onPlayerChangeSpeakerBoxVolume", root, function(to)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end
	
	if client:getData("level") < 2 then
		exports.mek_infobox:addBox(client, "error", "2 seviyeden az olan oyuncular bu sistemi kullanamaz.")
		return
	end

	triggerClientEvent(root, "onPlayerChangeSpeakerBoxVolumeC", root, client, to)
end)

function destroySpeakersOnPlayerQuit()
	if isElement(speakerBox[source]) then
		destroyElement(speakerBox[source])
		triggerClientEvent(root, "onPlayerDestroySpeakerBox", root, source)
	end
end
