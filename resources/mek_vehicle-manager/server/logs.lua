local mysql = exports.mek_mysql

function addVehicleLogs(vehID, action, actor, clearPreviousLogs)
	if vehID and action then
		if clearPreviousLogs then
			local success = dbExec(mysql:getConnection(), "DELETE FROM `vehicle_logs` WHERE `vehID` = ?", vehID)
			if not success then
				return false
			end
		end

		local adminID = nil
		if actor and isElement(actor) and getElementType(actor) == "player" then
			adminID = getElementData(actor, "account_id")
		end

		local query = "INSERT INTO `vehicle_logs` (`vehID`, `action`"
			.. (adminID and ", `actor`" or "")
			.. ") VALUES (?, ?"
			.. (adminID and ", ?" or "")
			.. ")"
		local addLog = dbExec(mysql:getConnection(), query, adminID and { vehID, action, adminID } or { vehID, action })

		if not addLog then
			return false
		else
			return true
		end
	else
		return false
	end
end

function getVehicleOwner(vehicle)
	local faction = tonumber(getElementData(vehicle, "faction")) or 0
	if faction > 0 then
		return getTeamName(exports.mek_pool:getElementByID("team", faction))
	else
		return exports.mek_cache:getCharacterName(getElementData(vehicle, "owner")) or "?"
	end
end
