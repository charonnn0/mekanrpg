function getAllGates(thePlayer, commandName, ...)
	if exports.mek_integration:isPlayerAdmin1(thePlayer) then
		dbQuery(function(queryHandle)
			local gatesList = {}
			local results = dbPoll(queryHandle, 0)
			if results then
				for _, row in ipairs(results) do
					table.insert(gatesList, {
						row["id"],
						tostring(row["objectID"]),
						row["gateType"],
						row["gateSecurityParameters"],
						row["creator"],
						row["createdDate"],
						row["adminNote"],
						row["autocloseTime"],
						row["movementTime"],
						row["objectInterior"],
						row["objectDimension"],
						row["startX"],
						row["startY"],
						row["startZ"],
						row["startRX"],
						row["startRY"],
						row["startRZ"],
						row["endX"],
						row["endY"],
						row["endZ"],
						row["endRX"],
						row["endRY"],
						row["endRZ"],
					})
				end
			end
			triggerClientEvent(
				thePlayer,
				"createGateManagerWindow",
				thePlayer,
				gatesList,
				getElementData(thePlayer, "account_username")
			)
		end, mysql:getConnection(), "SELECT * FROM `gates` ORDER BY `createdDate` DESC")
	end
end
addCommandHandler("gates", getAllGates, false, false)

function addGate(
	thePlayer,
	a1,
	a2,
	a3,
	a4,
	a5,
	a6,
	a7,
	a8,
	a9,
	a10,
	a11,
	a12,
	a13,
	a14,
	a15,
	a16,
	a17,
	a18,
	a19,
	a20,
	a21,
	a22,
	a23,
	a24
)
	local mQuery1 = nil
	local smallestID = exports.mek_mysql:getSmallestID("gates")

	if not a22 then
		a22 = false
	else
		a22 = tostring(a22)
		if #a22 < 2 then
			a22 = false
		elseif a22 == "none" then
			a22 = false
		else
			a22 = a22
		end
	end
	if not tonumber(a23) then
		a23 = false
	else
		a23 = (tostring(a23))
	end
	if not tonumber(a24) then
		a24 = false
	else
		a24 = (tostring(a24))
	end

	local query = [[
	INSERT INTO `gates`
	(`id`, `objectID`, `startX`, `startY`, `startZ`, `startRX`, `startRY`, `startRZ`, 
	 `endX`, `endY`, `endZ`, `endRX`, `endRY`, `endRZ`, `gateType`, `gateSecurityParameters`, 
	 `autocloseTime`, `movementTime`, `objectInterior`, `objectDimension`, 
	 `creator`, `adminNote`, `sound`, `triggerDistance`, `triggerDistanceVehicle`)
	VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
	]]

	local mQuery1 = dbExec(
		mysql:getConnection(),
		query,
		smallestID,
		a1,
		a2,
		a3,
		a4,
		a5,
		a6,
		a7,
		a8,
		a9,
		a10,
		a11,
		a12,
		a13,
		a14,
		a15,
		a16,
		a17,
		a18,
		a19,
		a20,
		a21,
		a22 or dbNull,
		a23 or dbNull,
		a24 or dbNull
	)

	if mQuery1 then
		outputChatBox("[ADM] Sucessfully added gate!", thePlayer, 0, 255, 0)
		loadOneGate(smallestID)
		getAllGates(thePlayer, "gates")
	else
		outputChatBox("[ADM] Failed to add gate. Please check the inputs again.", thePlayer, 255, 0, 0)
	end
end
addEvent("addGate", true)
addEventHandler("addGate", root, addGate)

function saveGate(
	thePlayer,
	a1,
	a2,
	a3,
	a4,
	a5,
	a6,
	a7,
	a8,
	a9,
	a10,
	a11,
	a12,
	a13,
	a14,
	a15,
	a16,
	a17,
	a18,
	a19,
	a20,
	a21,
	a22,
	a23,
	a24,
	a25
)
	local mQuery1 = nil

	if not a23 then
		a23 = false
	else
		a23 = tostring(a23)
		if #a23 < 2 then
			a23 = false
		elseif a23 == "none" then
			a23 = false
		else
			a23 = a23
		end
	end
	if not tonumber(a24) then
		a24 = false
	else
		a24 = (tostring(a24))
	end
	if not tonumber(a25) then
		a25 = false
	else
		a25 = (tostring(a25))
	end

	mQuery1 = dbExec(
		mysql:getConnection(),
		"UPDATE `gates` SET `objectID` = ?, `startX` = ?, `startY` = ?, `startZ` = ?, `startRX` = ?, `startRY` = ?, `startRZ` = ?, `endX` = ?, `endY` = ?, `endZ` = ?, `endRX` = ?, `endRY` = ?, `endRZ` = ?, `gateType` = ?, `gateSecurityParameters` = ?, `autocloseTime` = ?, `movementTime` = ?, `objectInterior` = ?, `objectDimension` = ?, `creator` = ?, `adminNote` = ?, `sound` = ?, `triggerDistance` = ?, `triggerDistanceVehicle` = ? WHERE `id` = ?",
		a1,
		a2,
		a3,
		a4,
		a5,
		a6,
		a7,
		a8,
		a9,
		a10,
		a11,
		a12,
		a13,
		a14,
		a15,
		a16,
		a17,
		a18,
		a19,
		a20,
		a21,
		a23,
		a24,
		a25,
		a22
	)

	if mQuery1 then
		outputChatBox("[ADM] Sucessfully saved gate!", thePlayer, 0, 255, 0)
		resetGateSound(theGate)
		delOneGate(tonumber(a22))
		loadOneGate(tonumber(a22))
		getAllGates(thePlayer, "gates")
	else
		outputChatBox("[ADM] Failed to modify gate. Please check the inputs again.", thePlayer, 255, 0, 0)
	end
end
addEvent("saveGate", true)
addEventHandler("saveGate", root, saveGate)

function delGate(thePlayer, commandName, gateID)
	if exports.mek_integration:isPlayerAdmin1(thePlayer) then
		if not tonumber(gateID) then
			outputChatBox("Kullanım: /" .. commandName .. " [Gate ID]", thePlayer, 255, 194, 14)
		else
			dbQuery(function(queryHandle)
				local result, rows = dbPoll(queryHandle, 0)
				if result and rows > 0 then
					outputChatBox("[ADM] Sucessfully deleted gate!", thePlayer, 0, 255, 0)
					delOneGate(tonumber(gateID))
					if string.lower(commandName) ~= "delgate" then
						getAllGates(thePlayer, "gates")
					end
				else
					outputChatBox("[ADM] Gate doesn't exist.", thePlayer, 255, 0, 0)
				end
			end, mysql:getConnection(), "DELETE FROM `gates` WHERE `id` = ?", gateID)
		end
	end
end
addEvent("delGate", true)
addEventHandler("delGate", root, delGate)
addCommandHandler("delgate", delGate)

function reloadGates(thePlayer)
	if restartResource(getThisResource()) then
		outputChatBox("[ADM] All gates have been reloaded successfully!", thePlayer, 0, 255, 0)
		exports.mek_global:sendMessageToAdmins(
			"[ADM] "
				.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
				.. " "
				.. getPlayerName(thePlayer):gsub("_", " ")
				.. " has reloaded all gates."
		)
	else
		outputChatBox("[ADM] Error! Failed to restart resource. Please notify scripters!", thePlayer, 255, 0, 0)
	end
end
addEvent("reloadGates", true)
addEventHandler("reloadGates", root, reloadGates)

function gotoGate(thePlayer, commandName, gateID, x, y, z, rot, int, dim)
	if exports.mek_integration:isPlayerAdmin1(thePlayer) then
		if not tonumber(gateID) then
			outputChatBox("Kullanım: /" .. commandName .. " [Gate ID]", thePlayer, 255, 194, 14)
		else
			if not tonumber(dim) then
				dbQuery(
					function(queryHandle)
						local result = dbPoll(queryHandle, 0)
						if result and #result > 0 then
							local row = result[1]
							local x1, y1, z1, rot1, int1, dim1 =
								row["startX"],
								row["startY"],
								row["startZ"],
								row["startRX"],
								row["objectInterior"],
								row["objectDimension"]
							startGoingToGate(thePlayer, x1, y1, z1, rot1, int1, dim1, gateID)
						else
							outputChatBox("[ADM] Gate doesn't exist.", thePlayer, 255, 0, 0)
						end
					end,
					mysql:getConnection(),
					"SELECT `startX`, `startY`, `startZ`, `startRX`, `objectInterior`, `objectDimension` FROM `gates` WHERE `id` = ?",
					gateID
				)
			end
		end
	end
end
--addEvent("gotoGate", true)
--addEventHandler("gotoGate", root, gotoGate)
addCommandHandler("gotogate", gotoGate)

function startGoingToGate(thePlayer, x, y, z, r, interior, dimension, gateID)
	-- Maths calculations to stop the player being stuck in the target
	x = x + ((math.cos(math.rad(r))) * 2)
	y = y + ((math.sin(math.rad(r))) * 2)

	setCameraInterior(thePlayer, interior)

	if isPedInVehicle(thePlayer) then
		local veh = getPedOccupiedVehicle(thePlayer)
		setElementAngularVelocity(veh, 0, 0, 0)
		setElementInterior(thePlayer, interior)
		setElementDimension(thePlayer, dimension)
		setElementInterior(veh, interior)
		setElementDimension(veh, dimension)
		setElementPosition(veh, x, y, z + 1)
		warpPedIntoVehicle(thePlayer, veh)
		setTimer(setElementAngularVelocity, 50, 20, veh, 0, 0, 0)
	else
		setElementPosition(thePlayer, x, y, z)
		setElementInterior(thePlayer, interior)
		setElementDimension(thePlayer, dimension)
	end
	outputChatBox("You have teleported to gate ID#" .. gateID, thePlayer)
end

function getNearByGates(thePlayer, commandName)
	if not (exports.mek_integration:isPlayerAdmin1(thePlayer)) then
		outputChatBox("Only Super Admin and above can access /" .. commandName .. ".", thePlayer, 255, 0, 0)
		return false
	end

	local posX, posY, posZ = getElementPosition(thePlayer)
	outputChatBox("Nearby Gates:", thePlayer, 255, 126, 0)
	local count = 0

	local dimension = getElementDimension(thePlayer)
	for k, theGate in ipairs(getElementsByType("object", resourceRoot)) do
		local x, y = getElementPosition(theGate)
		local distance = getDistanceBetweenPoints2D(posX, posY, x, y)
		local cdimension = getElementDimension(theGate)
		if (distance <= 10) and (dimension == cdimension) then
			local dbid = tonumber(getElementData(theGate, "gate:id"))
			local desc = getElementData(theGate, "gate:desc") or "No Description"
			outputChatBox("Gate ID #" .. dbid .. " - " .. desc, thePlayer, 255, 126, 0)
			count = count + 1
		end
	end

	if count == 0 then
		outputChatBox("[!]#FFFFFF Yok.", thePlayer, 255, 0, 0, true)
	end

	--[[
	if not tonumber(gateID) then 
		outputChatBox("Kullanım: /" .. commandName .. " [Gate ID]", thePlayer, 255, 194, 14)
	end
	
	gateID = math.floor(tonumber(gateID))
	
	local targetGate = nil
	for key, value in ipairs(getElementsByType("object", resourceRoot)) do
		if tonumber(getElementData(value, "gate:id")) == gateID then
			targetGate = value
			break
		end
	end
	
	if targetGate then
		destroyElement(targetGate)
	end]]
end
addCommandHandler("nearbygates", getNearByGates)

function delOneGate(gateID)
	local theGate = getGateElementFromID(gateID)
	if theGate then
		resetGateSound(theGate)
		destroyElement(theGate)
	end
end

function getGateElementFromID(id)
	id = tonumber(id)
	if not id then
		return false
	end
	for k, theGate in ipairs(getElementsByType("object", resourceRoot)) do
		local dbid = tonumber(getElementData(theGate, "gate:id"))
		if dbid == id then
			return theGate
		end
	end
	return false
end
