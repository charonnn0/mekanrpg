mysql = exports.mek_mysql
items = exports.mek_item
global = exports.mek_global
integration = exports.mek_integration

permissionTypes = {
	-- name, id, hasData
	{ "No-one", 0, false },
	{ "Everyone", 1, false },
	{ "Interior key holders", 2, false },
	{ "Admin only", 3, false },
	{ "Interior owner", 6, false },
	{ "Item placer", 7, false },
}

function canEditItemProperties(thePlayer, object)
	if not object then
		return false
	end
	local interiorID = getElementDimension(object)
	if
		exports.mek_item:hasItem(localPlayer, 4, interiorID)
		or exports.mek_item:hasItem(localPlayer, 5, interiorID)
		or (exports.mek_integration:isPlayerTrialAdmin(thePlayer) and exports.mek_global:isAdminOnDuty(thePlayer))
		or exports.mek_integration:isPlayerServerManager(thePlayer)
	then
		return true
	end
	return false
end

function getPermissionTypeIDFromName(name)
	for k, v in ipairs(permissionTypes) do
		if name == v[1] then
			return v[2]
		end
	end
	return false
end

function can(player, action, element)
	global = exports.mek_global
	integration = exports.mek_integration
	if not action or not element or not player then
		return false
	end
	local perm = getPermissions(element)
	if not perm then
		return false
	end
	local usePerm, useData
	if action == "use" then
		usePerm = perm.use
		useData = perm.useData
	elseif action == "move" then
		usePerm = perm.move
		useData = perm.moveData
	elseif action == "pickup" then
		usePerm = perm.pickup
		useData = perm.pickupData
	else
		return false
	end
	if usePerm == 0 then
		return false
	elseif usePerm == 1 then
		return true
	elseif usePerm == 2 then
		local dimension = getElementDimension(element)
		if global:hasItem(player, 4, dimension) or global:hasItem(player, 5, dimension) then
			return true
		end
	elseif usePerm == 3 then
		if integration:isPlayerTrialAdmin(player) and global:isAdminOnDuty(player) then
			return true
		end
	elseif usePerm == 4 then
		local playerFaction = tonumber(getElementData(player, "faction")) or 0
		for k, v in ipairs(useData) do
			if v == playerFaction then
				return true
			end
		end
	elseif usePerm == 5 then
		local playerFaction = tonumber(getElementData(player, "faction")) or 0
		for k, v in ipairs(useData) do
			if v == playerFaction then
				return true
			end
		end
	elseif usePerm == 6 then
		local thisInterior = getElementDimension(element)
		local interiorElement = getElementByID("int" .. tostring(thisInterior))
		if interiorElement and isElement(interiorElement) then
			local interiorData = getElementData(interiorElement, "status")
			local interiorOwner = tonumber(interiorData[4])
			if interiorOwner and interiorOwner > 0 then
				local thisCharacterID = tonumber(getElementData(player, "dbid"))
				if thisCharacterID then
					if thisCharacterID == interiorOwner then
						return true
					end
				end
			end
		end
	elseif usePerm == 7 then
		local creator = tonumber(getElementData(element, "creator"))
		if creator then
			local charid = tonumber(getElementData(player, "dbid"))
			if charid then
				if charid == creator then
					return true
				end
			end
		end
	elseif usePerm == 8 then
		local querystring = useData[1]
		if not querystring then
			return false
		end
		querystring = tostring(querystring)
		local thePlayer = player
		local tempAccess = split(querystring, " AND ")

		local count = 0
		for _, itemID in ipairs(tempAccess) do
			local orString = split(itemID, " OR ")
			if #orString > 1 then
				local countOr = 0
				for k, v in ipairs(orString) do
					local theItem = split(orString[k], "=")
					if isNumeric(theItem[1]) then
						local hasItem, key, value2, value3 = exports.mek_item:hasItem(thePlayer, tonumber(theItem[1]))
						if hasItem then
							if theItem[2] then
								if isNumeric(theItem[2]) then
									theItem[2] = tonumber(theItem[2])
								else
									theItem[2] = tostring(theItem[2])
								end

								if
									tonumber(exports.mek_item:countItems(thePlayer, tonumber(theItem[1]), theItem[2]))
									> 0
								then
									countOr = countOr + 1
								end
							else
								countOr = countOr + 1
							end
						end
					else
						local textFunction = tostring(theItem[1])
						if textFunction == "PILOT" then
							local pilotlicenses = exports.mek_mdc:getPlayerPilotLicenses(thePlayer) or {}
							if theItem[2] then
								local requireLicense = split(theItem[2], "-")
								if isNumeric(requireLicense[1]) then
									for licenseKey, licenseValue in ipairs(pilotlicenses) do
										if licenseValue[1] == tonumber(requireLicense[1]) then
											if
												licenseValue[1] == 7
												and requireLicense[2]
												and tonumber(requireLicense[2])
											then
												if tonumber(requireLicense[2]) == licenseValue[2] then
													countOr = countOr + 1
												end
											else
												countOr = countOr + 1
											end
										end
									end
								else
									for licenseKey, licenseValue in ipairs(pilotlicenses) do
										if tostring(licenseValue[3]) == tostring(requireLicense[1]) then
											if
												licenseValue[1] == 7
												and requireLicense[2]
												and tonumber(requireLicense[2])
											then
												if tonumber(requireLicense[2]) == licenseValue[2] then
													countOr = countOr + 1
												end
											else
												countOr = countOr + 1
											end
										end
									end
								end
							else
								if #pilotlicenses > 0 then
									for licenseKey, licenseValue in ipairs(pilotlicenses) do
										if licenseValue[1] == 3 or licenseValue[1] == 4 then
											countOr = countOr + 1
											break
										end
									end
								end
							end
						elseif textFunction == "F" or textFunction == "FACTION" then
							if theItem[2] then
								local checkFaction = split(theItem[2], "-")
								if isNumeric(checkFaction[1]) then
									if isNumeric(checkFaction[2]) then
										if
											exports.mek_faction:isPlayerInFaction(
												thePlayer,
												tonumber(checkFaction[1]),
												tonumber(checkFaction[2])
											)
										then
											countOr = countOr + 1
										end
									else
										if
											exports.mek_faction:isPlayerInFaction(thePlayer, tonumber(checkFaction[1]))
										then
											countOr = countOr + 1
										end
									end
								else
									local checkFactionName = tostring(theItem[2])
									local factionID = exports.mek_faction:getFactionIDFromName(checkFactionName)
									if factionID then
										if exports.mek_faction:isPlayerInFaction(thePlayer, factionID) then
											countOr = countOr + 1
										end
									end
								end
							end
						elseif textFunction == "FL" or textFunction == "faction_leader" then
							if theItem[2] then
								local checkFaction = split(theItem[2], "-")
								if isNumeric(checkFaction[1]) then
									if isNumeric(checkFaction[2]) then
										local isMember, rank, isLeader = exports.mek_faction:isPlayerInFaction(
											thePlayer,
											tonumber(checkFaction[1]),
											tonumber(checkFaction[2])
										)
										if isMember and isLeader then
											countOr = countOr + 1
										end
									else
										local isMember, rank, isLeader =
											exports.mek_faction:isPlayerInFaction(thePlayer, tonumber(checkFaction[1]))
										if isMember and isLeader then
											countOr = countOr + 1
										end
									end
								else
									local checkFactionName = tostring(theItem[2])
									local factionID = exports.mek_faction:getFactionIDFromName(checkFactionName)
									if factionID then
										local isMember, rank, isLeader =
											exports.mek_faction:isPlayerInFaction(thePlayer, factionID)
										if isMember and isLeader then
											countOr = countOr + 1
										end
									end
								end
							end
						end
					end
				end
				if countOr > 0 then
					count = count + 1
				end
			else
				local theItem = split(orString[1], "=")
				if isNumeric(theItem[1]) then
					local hasItem, key, value2, value3 = exports.mek_item:hasItem(thePlayer, tonumber(theItem[1]))
					if hasItem then
						if theItem[2] then
							if isNumeric(theItem[2]) then
								theItem[2] = tonumber(theItem[2])
							else
								theItem[2] = tostring(theItem[2])
							end

							if
								tonumber(exports.mek_item:countItems(thePlayer, tonumber(theItem[1]), theItem[2])) > 0
							then
								count = count + 1
							end
						else
							count = count + 1
						end
					end
				else
					local textFunction = tostring(theItem[1])
					if textFunction == "PILOT" then
						local pilotlicenses = exports.mek_mdc:getPlayerPilotLicenses(thePlayer) or {}
						if theItem[2] then
							local requireLicense = split(theItem[2], "-")
							if isNumeric(requireLicense[1]) then
								for licenseKey, licenseValue in ipairs(pilotlicenses) do
									if licenseValue[1] == tonumber(requireLicense[1]) then
										if
											licenseValue[1] == 7
											and requireLicense[2]
											and tonumber(requireLicense[2])
										then
											if tonumber(requireLicense[2]) == licenseValue[2] then
												count = count + 1
											end
										else
											count = count + 1
										end
									end
								end
							else
								for licenseKey, licenseValue in ipairs(pilotlicenses) do
									if tostring(licenseValue[3]) == tostring(requireLicense[1]) then
										if
											licenseValue[1] == 7
											and requireLicense[2]
											and tonumber(requireLicense[2])
										then
											if tonumber(requireLicense[2]) == licenseValue[2] then
												count = count + 1
											end
										else
											count = count + 1
										end
									end
								end
							end
						else
							if #pilotlicenses > 0 then
								for licenseKey, licenseValue in ipairs(pilotlicenses) do
									if licenseValue[1] == 3 or licenseValue[1] == 4 then
										count = count + 1
										break
									end
								end
							end
						end
					elseif textFunction == "F" or textFunction == "FACTION" then
						if theItem[2] then
							local checkFaction = split(theItem[2], "-")
							if isNumeric(checkFaction[1]) then
								if isNumeric(checkFaction[2]) then
									if
										exports.mek_faction:isPlayerInFaction(
											thePlayer,
											tonumber(checkFaction[1]),
											tonumber(checkFaction[2])
										)
									then
										count = count + 1
									end
								else
									if exports.mek_faction:isPlayerInFaction(thePlayer, tonumber(checkFaction[1])) then
										count = count + 1
									end
								end
							else
								local checkFactionName = tostring(theItem[2])
								local factionID = exports.mek_faction:getFactionIDFromName(checkFactionName)
								if factionID then
									if exports.mek_faction:isPlayerInFaction(thePlayer, factionID) then
										count = count + 1
									end
								end
							end
						end
					elseif textFunction == "FL" or textFunction == "faction_leader" then
						if theItem[2] then
							local checkFaction = split(theItem[2], "-")
							if isNumeric(checkFaction[1]) then
								if isNumeric(checkFaction[2]) then
									local isMember, rank, isLeader = exports.mek_faction:isPlayerInFaction(
										thePlayer,
										tonumber(checkFaction[1]),
										tonumber(checkFaction[2])
									)
									if isMember and isLeader then
										count = count + 1
									end
								else
									local isMember, rank, isLeader =
										exports.mek_faction:isPlayerInFaction(thePlayer, tonumber(checkFaction[1]))
									if isMember and isLeader then
										count = count + 1
									end
								end
							else
								local checkFactionName = tostring(theItem[2])
								local factionID = exports.mek_faction:getFactionIDFromName(checkFactionName)
								if factionID then
									local isMember, rank, isLeader =
										exports.mek_faction:isPlayerInFaction(thePlayer, factionID)
									if isMember and isLeader then
										count = count + 1
									end
								end
							end
						end
					end
				end
			end
		end

		if #tempAccess == count then
			return true
		end

		return false
	end
	return false
end

function isNumeric(a)
	if tonumber(a) ~= nil then
		return true
	else
		return false
	end
end
