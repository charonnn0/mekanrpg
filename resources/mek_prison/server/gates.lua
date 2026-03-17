function spawnTheGates()
	local count = 0
	for k, v in pairs(gates) do
		local gate = createObject(objectID, v[7], v[8], v[9], v[10], v[11], v[12])
		setElementInterior(gate, gateInt)
		setElementDimension(gate, gateDim)
		gates[k][13] = gate
		gates[k][14] = 0
		count = count + 1

		setElementData(gate, "prison:isGateMoving", false)
	end
	setElementData(resourceRoot, "gates", gates)
end
addEventHandler("onResourceStart", resourceRoot, spawnTheGates)

function triggerAGate(gateID, allgates)
	if gateID and gates[gateID] then
		local gateElement = gates[gateID][13]
		local gateStatus = gates[gateID][14]
		if not getElementData(gateElement, "prison:isGateMoving") then
			if gateStatus == 1 then
				gates[gateID][14] = 0
				moveObject(
					gateElement,
					3500,
					gates[gateID][7],
					gates[gateID][8],
					gates[gateID][9],
					gates[gateID][10],
					gates[gateID][11],
					gates[gateID][12]
				)

				setElementData(gateElement, "prison:isGateMoving", true)
				setTimer(function()
					setElementData(gateElement, "prison:isGateMoving", false)
				end, 3500, 1)

				for _, v in ipairs(getElementsByType("player")) do
					local pdim = getElementDimension(v)
					local pint = getElementInterior(v)

					if pdim == gateDim and pint == gateInt and not allgates then
						triggerClientEvent(
							v,
							"singleGateSound",
							v,
							gates[gateID][7],
							gates[gateID][8],
							gates[gateID][9]
						)
					end
				end
			elseif gateStatus == 0 then
				gates[gateID][14] = 1
				moveObject(
					gateElement,
					3500,
					gates[gateID][1],
					gates[gateID][2],
					gates[gateID][3],
					gates[gateID][4],
					gates[gateID][5],
					gates[gateID][6]
				)

				setElementData(gateElement, "prison:isGateMoving", true)
				setTimer(function()
					setElementData(gateElement, "prison:isGateMoving", false)
				end, 3500, 1)

				for _, v in ipairs(getElementsByType("player")) do
					local pdim = getElementDimension(v)
					local pint = getElementInterior(v)

					if pdim == gateDim and pint == gateInt and not allgates then
						triggerClientEvent(
							v,
							"singleGateSound",
							v,
							gates[gateID][1],
							gates[gateID][2],
							gates[gateID][3]
						)
					end
				end
			end
			setElementData(resourceRoot, "gates", gates)
		end
	end
end
addEvent("triggerAGate", true)
addEventHandler("triggerAGate", resourceRoot, function(gateID, allgates)
	if not client then return end
	if not (exports.mek_faction:isPlayerInFaction(client, { 1, 3 }) or exports.mek_integration:isPlayerManager(client)) then
		exports.mek_sac:banForEventAbuse(client, "triggerAGate")
		return
	end
	triggerAGate(gateID, allgates)
end)

function triggerAllGates()
	setTimer(function()
		for k, v in pairs(gates) do
			triggerAGate(k, "allgates")
		end
	end, 1400, 1)

	for _, player in ipairs(getElementsByType("player")) do
		if getElementDimension(player) == gateDim and getElementInterior(player) == gateInt then
			triggerClientEvent(player, "allGatesSound", player)
		end
	end
end
addEvent("triggerAllGates", true)
addEventHandler("triggerAllGates", resourceRoot, function()
	if not client then return end
	if not (exports.mek_faction:isPlayerInFaction(client, { 1, 3 }) or exports.mek_integration:isPlayerManager(client)) then
		exports.mek_sac:banForEventAbuse(client, "triggerAllGates")
		return
	end
	triggerAllGates()
end)
