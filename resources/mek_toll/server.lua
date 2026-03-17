local tollElements = {}
local tollElementsName = {}
local tollElementsLocked = {}
local gateSpeed = 950
local timerCloseToll = {}
local timerEarlyOpen = {}

function startSystem()
	for key, group in ipairs(tollPorts) do
		tollElements[key] = {}
		tollElementsName[key] = group.name
		tollElementsLocked[key] = false
		for dataKey, dataGroup in ipairs(group.data) do
			local pedName = "John Doe"
			local skinID = math.random(1, 2)

			if #pedMaleNames == 0 then
				skinID = 1
			elseif #pedFemaleNames == 0 then
				skinID = 2
			end

			local array = skinID == 1 and pedFemaleNames or pedMaleNames
			local k = math.random(1, #array)
			pedName = array[k]
			table.remove(array, k)

			if skinID == 1 then
				skinID = 211
			else
				skinID = 71
			end

			tollElements[key][dataKey] = {}

			tollElements[key][dataKey]["object"] = createObject(
				968,
				dataGroup.barrierClosed[1],
				dataGroup.barrierClosed[2],
				dataGroup.barrierClosed[3],
				dataGroup.barrierClosed[4],
				dataGroup.barrierClosed[5],
				dataGroup.barrierClosed[6]
			)

			tollElements[key][dataKey]["ped"] = createPed(skinID, dataGroup.ped[1], dataGroup.ped[2], dataGroup.ped[3])
			setPedRotation(tollElements[key][dataKey]["ped"], dataGroup.ped[4])
			setElementFrozen(tollElements[key][dataKey]["ped"], true)
			setElementData(tollElements[key][dataKey]["ped"], "name", pedName:gsub("_", " "), "broadcast")
			setElementData(tollElements[key][dataKey]["ped"], "interaction", {
				callbackEvent = "toll.startConvo",
				args = { tollElements[key][dataKey]["ped"] },
				description = pedName:gsub("_", " "),
			})

			setElementData(tollElements[key][dataKey]["ped"], "toll.object", tollElements[key][dataKey]["object"])
			setElementData(tollElements[key][dataKey]["ped"], "toll.data", dataGroup)
			setElementData(tollElements[key][dataKey]["ped"], "toll.busy", false)
			setElementData(tollElements[key][dataKey]["ped"], "toll.state", false)
			setElementData(tollElements[key][dataKey]["ped"], "toll.name", group.name)
			setElementData(tollElements[key][dataKey]["ped"], "toll.key", key)

			local x, y, z = dataGroup.ped[1], dataGroup.ped[2], dataGroup.ped[3]
			local r = dataGroup.ped[4]
			x = x - math.sin(math.rad(r)) * 2.5
			z = z + math.cos(math.rad(r)) * 2.5

			local col = createColSphere(x, y, z, 16)
			setElementData(col, "toll.ped", tollElements[key][dataKey]["ped"])
			addEventHandler("onColShapeHit", col, function(thePlayer, match)
				if
					match
					and getElementType(thePlayer) == "player"
					and getPedOccupiedVehicle(thePlayer)
					and getPedOccupiedVehicleSeat(thePlayer) == 0
				then
					local thePed = getElementData(source, "toll.ped")
					if getElementData(thePed, "earlyOpened") then
						return false
					end
					local tollKey = getElementData(thePed, "toll.key")
					processOpenTolls(tollKey, thePed, thePlayer, true)
				end
			end)

			addEventHandler("onColShapeLeave", col, function(thePlayer, match)
				if
					match
					and getElementType(thePlayer) == "player"
					and getPedOccupiedVehicle(thePlayer)
					and getPedOccupiedVehicleSeat(thePlayer) == 0
				then
					local thePed = getElementData(source, "toll.ped")
					if getElementData(thePed, "earlyOpened") then
						return false
					end
					local tollKey = getElementData(thePed, "toll.key")
					if
						timerCloseToll[thePed]
						and isElement(timerCloseToll[thePed])
						and isTimer(timerCloseToll[thePed])
					then
						killTimer(timerCloseToll[thePed])
						timerCloseToll[thePed] = nil
					end
					timerCloseToll[thePed] = setTimer(processCloseTolls, gateSpeed, 1, tollKey, thePed, thePlayer)
				end
			end)

			local col2 = createColSphere(x, y, z, 40)
			setElementData(col2, "toll.ped", tollElements[key][dataKey]["ped"])
			addEventHandler("onColShapeHit", col2, function(thePlayer, match)
				if
					match
					and getElementType(thePlayer) == "player"
					and getPedOccupiedVehicleSeat(thePlayer) == 0
					and canAccessEarlyZone(getPedOccupiedVehicle(thePlayer), thePlayer)
				then
					local thePed = getElementData(source, "toll.ped")
					local tollKey = getElementData(thePed, "toll.key")
					triggerGate(thePed, true)
				end
			end)
		end
	end
end
addEventHandler("onResourceStart", resourceRoot, startSystem)

function triggerGate(gateKeeperPed, earlyOpenZone)
	local isGateBusy = getElementData(gateKeeperPed, "toll.busy")
	local isGateOpened = getElementData(gateKeeperPed, "toll.opened")
	if isGateBusy or isGateOpened then
		return false
	end

	local tollData = getElementData(gateKeeperPed, "toll.data")
	local tollObject = getElementData(gateKeeperPed, "toll.object")

	setElementData(gateKeeperPed, "toll.busy", true)
	local newX, newY, newZ, offsetRX, offsetRY, offsetRZ

	newX = tollData.barrierOpen[1]
	newY = tollData.barrierOpen[2]
	newZ = tollData.barrierOpen[3]
	offsetRX = tollData.barrierClosed[4] - tollData.barrierOpen[4]
	offsetRY = tollData.barrierClosed[5] - tollData.barrierOpen[5]
	offsetRZ = tollData.barrierClosed[6] - tollData.barrierOpen[6]

	offsetRX = fixRotation(offsetRX)
	offsetRY = fixRotation(offsetRY)
	offsetRZ = fixRotation(offsetRZ)

	setElementData(gateKeeperPed, "toll.opened", true)
	moveObject(tollObject, gateSpeed, newX, newY, newZ, offsetRX, offsetRY, offsetRZ)

	setElementData(gateKeeperPed, "toll.busy", true)
	setTimer(resetBusyState, gateSpeed + 200, 1, gateKeeperPed)

	if
		timerCloseToll[gateKeeperPed]
		and isElement(timerCloseToll[gateKeeperPed])
		and isTimer(timerCloseToll[gateKeeperPed])
	then
		killTimer(timerCloseToll[gateKeeperPed])
		timerCloseToll[gateKeeperPed] = nil
	end
	timerCloseToll[gateKeeperPed] = setTimer(processCloseTolls, 30 * 1000, 1, nil, gateKeeperPed)

	if earlyOpenZone then
		if
			timerEarlyOpen[gateKeeperPed]
			and isElement(timerEarlyOpen[gateKeeperPed])
			and isTimer(timerEarlyOpen[gateKeeperPed])
		then
			killTimer(timerEarlyOpen[gateKeeperPed])
			timerEarlyOpen[gateKeeperPed] = nil
		end
		setElementData(gateKeeperPed, "earlyOpened", true)
		timerEarlyOpen[gateKeeperPed] = setTimer(function()
			setElementData(gateKeeperPed, "earlyOpened", false)
		end, 30 * 1000, 1, nil, gateKeeperPed)
	end
end

function processCloseTolls(tollKey, thePed, thePlayer, payByBank)
	local isGateBusy = getElementData(thePed, "toll.busy")
	local isGateOpened = getElementData(thePed, "toll.opened")
	if isGateOpened then
		if isGateBusy then
			setTimer(function()
				processCloseTolls(tollKey, thePed, thePlayer, payByBank)
			end, gateSpeed, 1)
			return false
		end
	else
		return false
	end

	local tollData = getElementData(thePed, "toll.data")
	local tollObject = getElementData(thePed, "toll.object")

	local newX, newY, newZ, offsetRX, offsetRY, offsetRZ

	newX = tollData.barrierClosed[1]
	newY = tollData.barrierClosed[2]
	newZ = tollData.barrierClosed[3]
	offsetRX = tollData.barrierOpen[4] - tollData.barrierClosed[4]
	offsetRY = tollData.barrierOpen[5] - tollData.barrierClosed[5]
	offsetRZ = tollData.barrierOpen[6] - tollData.barrierClosed[6]
	gateState = false

	offsetRX = fixRotation(offsetRX)
	offsetRY = fixRotation(offsetRY)
	offsetRZ = fixRotation(offsetRZ)

	moveObject(tollObject, gateSpeed, newX, newY, newZ, offsetRX, offsetRY, offsetRZ)
	setElementData(thePed, "toll.opened", false)
	setElementData(thePed, "toll.busy", true)
	setTimer(resetBusyState, gateSpeed + 200, 1, thePed)
end

function startTalkToPed(thePed)
	thePlayer = client

	local posX, posY, posZ = getElementPosition(thePlayer)
	local pedX, pedY, pedZ = getElementPosition(thePed)
	if not (getDistanceBetweenPoints3D(posX, posY, posZ, pedX, pedY, pedZ) <= 7) then
		return
	end

	if isPedInVehicle(thePlayer) then
		local theVehicle = getPedOccupiedVehicle(thePlayer)
		if exports.mek_vehicle:isVehicleWindowUp(theVehicle) then
			outputChatBox(
				"[!]#FFFFFF Dışarıdan biriyle konuşmadan önce arabanızın camını açmalısınız.",
				thePlayer,
				255,
				0,
				0,
				true
			)
			return
		end
	end

	local isGateBusy = getElementData(thePed, "toll.busy")
	if isGateBusy then
		processMessage(thePed, "Mh...")
		return
	end

	processMessage(thePed, "Hey, geçmek ister misin ₺5 mal olacak.")
	setConvoState(thePlayer, 1)
	triggerClientEvent(thePlayer, "toll.interact", thePed, { "Evet, zahmet olmazsa.", "Hayır, teşekkürler." })
end
addEvent("toll.startConvo", true)
addEventHandler("toll.startConvo", root, startTalkToPed)

function processOpenTolls(tollKey, thePed, thePlayer, payByBank)
	if
		not tollElementsLocked[tollKey]
		or exports.mek_item:hasItem(thePlayer, 64)
		or exports.mek_item:hasItem(thePlayer, 65)
		or exports.mek_item:hasItem(thePlayer, 112)
	then
		if payByBank then
			if not getElementData(thePlayer, "kamyonSoforlugu") or getElementData(thePlayer, "tirSoforlugu") then
				if not exports.mek_item:hasItem(getPedOccupiedVehicle(thePlayer), 118) then
					return
				end
			end

			if not getElementData(thePlayer, "kamyonSoforlugu") or getElementData(thePlayer, "tirSoforlugu") then
				local money = getElementData(thePlayer, "bank_money") - 5
				if money >= 0 then
					setElementData(thePlayer, "bank_money", money)
				else
					return "Banka hesabınızda yeterli paranız yok."
				end
			end
		else
			if not exports.mek_global:takeMoney(thePlayer, 5) then
				return "Üzgünüm ama eğer ödeyemezsen seni geçemem."
			end
		end

		triggerGate(thePed)
		exports.mek_global:giveMoney(getTeamFromName("İstanbul Büyükşehir Belediyesi"), 5)
		return "Teşekkür ederim, gidebilirsin."
	else
		return "Üzgünüm, kimsenin içeri girmemesi yönünde emir aldık."
	end
end

function talkToPed(answer, answerStr)
	thePed = source
	thePlayer = client

	local posX, posY, posZ = getElementPosition(thePlayer)
	local pedX, pedY, pedZ = getElementPosition(thePed)
	if not (getDistanceBetweenPoints3D(posX, posY, posZ, pedX, pedY, pedZ) <= 12) then
		return
	end

	local convState = getConvoState(thePlayer)
	exports.mek_global:sendLocalText(
		source,
		getPlayerName(thePlayer):gsub("_", " ") .. ": " .. answerStr,
		255,
		255,
		255
	)

	if answer == 1 then
		local placeName = getElementData(thePed, "toll.name")
		local isBusy = getElementData(thePed, "toll.busy")
		if not isBusy then
			local tollKey = getElementData(thePed, "toll.key")
			processMessage(thePed, processOpenTolls(tollKey, thePed, thePlayer, false))
		end
		setConvoState(thePlayer, 0)
	elseif answer == 2 then
		processMessage(thePed, "Tamamdır, iyi günler...")
		setConvoState(thePlayer, 0)
	end
end
addEvent("toll.interact", true)
addEventHandler("toll.interact", root, talkToPed)

function getConvoState(thePlayer)
	return getElementData(thePlayer, "toll.convoState", state) or 0
end

function setConvoState(thePlayer, state)
	setElementData(thePlayer, "toll.convoState", state)
end

function processMessage(thePed, message)
	local name = getElementData(thePed, "name") or "John Doe"
	exports.mek_global:sendLocalText(source, name .. ": " .. message, 255, 255, 255)
end

function fixRotation(value)
	local invert = false
	if value < 0 then
		while value < -360 do
			value = value + 360
		end
		if value < -180 then
			value = value + 180
			value = value - value - value
		end
	else
		while value > 360 do
			value = value - 360
		end
		if value > 180 then
			value = value - 180
			value = value - value - value
		end
	end

	return value
end

function resetBusyState(theGate)
	local isGateBusy = getElementData(theGate, "toll.busy")
	if isGateBusy then
		setElementData(theGate, "toll.busy", false)
	end
end
