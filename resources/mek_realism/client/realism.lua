function angle(vehicle)
	local vx, vy, vz = getElementVelocity(vehicle)
	local modV = math.sqrt(vx * vx + vy * vy)

	if not isVehicleOnGround(vehicle) then
		return 0, modV
	end

	local rx, ry, rz = getElementRotation(vehicle)
	local sn, cs = -math.sin(math.rad(rz)), math.cos(math.rad(rz))

	local cosX = (sn * vx + cs * vy) / modV

	return math.deg(math.acos(cosX)) * 0.5, modV
end

local function getDecayMultiplier()
	local isRunning = getPedControlState(localPlayer, "sprint")
	local isInVehicle = isPedInVehicle(localPlayer)
	local multiplier = 1.0

	if isRunning then
		multiplier = multiplier + 0.5
	end
	if isInVehicle then
		multiplier = multiplier + 0.25
	end

	return multiplier
end

addEventHandler("onClientResourceStart", resourceRoot, function()
	setBlurLevel(0)

	for _, player in ipairs(getElementsByType("player")) do
		setPedVoice(player, "PED_TYPE_DISABLED", "nil")
	end
end)

addEventHandler("onClientPlayerJoin", root, function()
	setPedVoice(source, "PED_TYPE_DISABLED", "nil")
end)

setTimer(function()
	if
		not getElementData(localPlayer, "logged")
		or getElementData(localPlayer, "dead")
		or getElementData(localPlayer, "cked")
		or getElementData(localPlayer, "admin_jailed")
		or exports.mek_global:isAdminOnDuty(localPlayer)
	then
		return
	end

	local decayMultiplier = getDecayMultiplier()

	local hunger = tonumber(getElementData(localPlayer, "hunger")) or 100
	local hungerDecay = 0.03 * decayMultiplier
	if hunger > 0 then
		hunger = math.max(0, hunger - hungerDecay)
		setElementData(localPlayer, "hunger", hunger)
	end

	local thirst = tonumber(getElementData(localPlayer, "thirst")) or 100
	local thirstDecay = 0.08 * decayMultiplier
	if thirst > 0 then
		thirst = math.max(0, thirst - thirstDecay)
		setElementData(localPlayer, "thirst", thirst)
	end

	if hunger <= 20 and not isTimer(foodWarningTimer) then
		foodWarningTimer = setTimer(function()
			exports.mek_infobox:addBox("warning", "Karakteriniz aç. Görüşünüz bulanıklaşabilir.")
		end, 15 * 60000, 0)
	elseif hunger > 20 and isTimer(foodWarningTimer) then
		killTimer(foodWarningTimer)
	end

	if thirst <= 20 and not isTimer(drinkWarningTimer) then
		drinkWarningTimer = setTimer(function()
			exports.mek_infobox:addBox("warning", "Karakteriniz susuz. Bayılabilirsiniz.")
		end, 15 * 60000, 0)
	elseif thirst > 20 and isTimer(drinkWarningTimer) then
		killTimer(drinkWarningTimer)
	end

	local health = getElementHealth(localPlayer)
	if (thirst <= 20 or hunger <= 20) and health > 15 then
		setElementHealth(localPlayer, math.max(15, health - 3))
	end
end, 3 * 60 * 1000, 0)
