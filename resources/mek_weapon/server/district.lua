local weaponCooldowns = {}

addEventHandler("onPlayerWeaponFire", root, function(weapon)
	if weaponCooldowns[source] then
		return
	end

	weaponCooldowns[source] = true

	local x, y, z = getElementPosition(source)
	local nearbyPlayers = getElementsWithinRange(x, y, z, 30)

	for _, player in ipairs(nearbyPlayers) do
		if player:getData("logged") then
			outputChatBox(
				"Bölge IC: Çevreden silah sesleri duyabilirsiniz. ((" .. getPlayerName(source):gsub("_", " ") .. "))",
				player,
				255,
				255,
				255
			)
		end
	end

	for _, player in ipairs(getElementsByType("player")) do
		if
			player:getData("logged")
			and exports.mek_faction:isPlayerInFaction(player, { 1, 2, 3 })
			and not exports.mek_global:isAdminOnDuty(source)
		then
			local message
			if source.dimension > 0 then
				local theInterior = exports.mek_pool:getElementByID("interior", source.dimension)
				if theInterior then
					message = "** [İhbar] " .. source.dimension .. " kapı numarasında ateş sesleri duyuldu."
				end
			end

			if not message then
				local zoneName = exports.mek_global:getZoneName(x, y, z)
				message = "** [İhbar] '" .. zoneName .. "' konumunda ateş sesleri duyuldu."
			end

			outputChatBox(message, player, 65, 65, 255)

			local blip = createBlip(x, y, z, 0, 2, 255, 0, 0, 255, 0, 300, player)
			if isElement(blip) then
				blip:setData("icon", 53)
				blip:setData("text", "Ateş Sesi İhbarı")

				setTimer(function()
					if isElement(blip) then
						destroyElement(blip)
					end
				end, 300000, 1)
			end
		end
	end

	setTimer(function(player)
		weaponCooldowns[player] = nil
	end, 25000, 1, source)
end)
