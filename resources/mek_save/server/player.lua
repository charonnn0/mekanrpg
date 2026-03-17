function savePlayer(player)
	if source then
		player = source
	end

	if isElement(player) then
		if getElementData(player, "logged") then
			local vehicle = getPedOccupiedVehicle(player)
			if vehicle then
				local seat = getPedOccupiedVehicleSeat(player)
				triggerEvent("onVehicleExit", vehicle, player, seat)
			end

			local x, y, z = getElementPosition(player)
			local rotation = getPedRotation(player)
			local interior = getElementInterior(player)
			local dimension = getElementDimension(player)
			local health = getElementHealth(player)
			local armor = getPedArmor(player)
			local skin = getElementModel(player)
			local clothingID = getElementData(player, "clothing_id") or 0
			local model = getElementData(player, "model") or 0
			local hunger = getElementData(player, "hunger") or 0
			local thirst = getElementData(player, "thirst") or 0

			local zone = exports.mek_global:getElementZoneName(player)
			if not zone or #zone == 0 then
				zone = "Bilinmiyor"
			end

			if getElementData(player, "duty") then
				triggerEvent("duty.offDuty", player)
			end

			dbExec(
				exports.mek_mysql:getConnection(),
				"UPDATE characters SET x = ?, y = ?, z = ?, rotation = ?, interior = ?, dimension = ?, health = ?, armor = ?, skin = ?, clothing_id = ?, model = ?, last_login = NOW(), last_area = ?, hunger = ?, thirst = ? WHERE id = ?",
				x,
				y,
				z,
				rotation,
				interior,
				dimension,
				health,
				armor,
				skin,
				clothingID,
				model,
				zone,
				hunger,
				thirst,
				getElementData(player, "dbid")
			)
			dbExec(
				exports.mek_mysql:getConnection(),
				"UPDATE accounts SET last_login = NOW() WHERE id = ?",
				getElementData(player, "account_id")
			)
		end
	end
end
addEventHandler("onPlayerQuit", root, savePlayer)
addEvent("savePlayer", true)
addEventHandler("savePlayer", root, savePlayer)

addCommandHandler("saveall", function(thePlayer, commandName)
	if exports.mek_integration:isPlayerServerManager(thePlayer) then
		for _, player in ipairs(getElementsByType("player")) do
			savePlayer(player)
		end
		outputChatBox("[!]#FFFFFF Herkesin bilgileri veritabanına başarıyla kaydedildi.", thePlayer, 0, 255, 0, true)
	end
end)

addEvent("f10karakterdegisbro", true)
addEventHandler("f10karakterdegisbro", root, 
    function(player)
        if client ~= source then
            exports.mek_sac:banForEventAbuse(client, "f10karakterdegisbro")
            return
        end
        

        triggerEvent("savePlayer", player, "Change Character", player)
        
    end
)