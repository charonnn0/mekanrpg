local containerSize = {
	x = 150,
	y = 30,
}

local containerPosition = {
	x = screenSize.x / 2 - containerSize.x / 2,
	y = screenSize.y - containerSize.y - 10,
}

addEvent("death.renderUI", true)
addEventHandler("death.renderUI", localPlayer, function()
	if isTimer(lowerTime) then
		killTimer(lowerTime)
	end

	deathTimer = getPlayerDeathTime(localPlayer)
	lowerTime = setTimer(lowerTimer, 1000, deathTimer)

	toggleAllControls(false, false, false)
	outputChatBox(
		"[!]#FFFFFF Bayıldınız, " .. deathTimer .. " saniye sonra tekrar ayılacaksınız.",
		0,
		0,
		255,
		true
	)
	addEventHandler("onClientRender", root, drawUI)
end)

function lowerTimer()
	deathTimer = deathTimer - 1
	if deathTimer <= 0 then
		triggerServerEvent("death.acceptDeath", localPlayer, localPlayer, victimDropItem)
		revivePlayer()
		removeEventHandler("onClientRender", root, drawUI)
	end
end

function drawUI()
	if not localPlayer:getData("logged") then
		return
	end

	local text = ""
	if deathTimer > 5 then
		text = "Ayılmana " .. deathTimer .. " saniye kaldı."
	else
		text = "Kendine geliyorsun..."
	end

	dxDrawText(
		text,
		containerPosition.x + 2,
		containerPosition.y + 2,
		containerPosition.x + containerSize.x,
		containerPosition.y + containerSize.y,
		rgba(theme.GRAY[900], 1),
		1,
		fonts.BebasNeueBold.h3,
		"center",
		"center"
	)
	dxDrawText(
		text,
		containerPosition.x,
		containerPosition.y,
		containerPosition.x + containerSize.x,
		containerPosition.y + containerSize.y,
		rgba(theme.GRAY[100], 1),
		1,
		fonts.BebasNeueBold.h3,
		"center",
		"center"
	)
end

function revivePlayer()
	removeEventHandler("onClientRender", root, drawUI)
	if isTimer(lowerTimer) then
		killTimer(lowerTimer)
		toggleAllControls(true, true, true)
	end
end
addEvent("death.revive", true)
addEventHandler("death.revive", root, revivePlayer)

addEvent("death.closeUI", true)
addEventHandler("death.closeUI", localPlayer, function()
	removeEventHandler("onClientRender", root, drawUI)
	if isTimer(lowerTimer) then
		killTimer(lowerTimer)
		toggleAllControls(true, true, true)
	end
end)

addEventHandler("onClientPlayerWasted", localPlayer, function(attacker, weapon, bodypart)
	if getElementData(source, "dead") or getElementData(source, "cked") then
		cancelEvent()
	end
end)

addEventHandler("onClientPlayerStealthKill", localPlayer, function(attacker, weapon, bodypart)
	cancelEvent()
end)

addEventHandler("onClientPlayerDamage", localPlayer, function()
	if getElementData(source, "dead") or getElementData(source, "cked") then
		cancelEvent()
	end
end)

addEventHandler("onClientPlayerWeaponSwitch", localPlayer, function()
	if getElementData(source, "dead") or getElementData(source, "cked") or getElementData(source, "rk") then
		setPedWeaponSlot(localPlayer, 0)
	end
end)

addEventHandler("onClientPlayerWeaponFire", localPlayer, function()
	if getElementData(source, "dead") or getElementData(source, "cked") or getElementData(source, "rk") then
		setPedWeaponSlot(localPlayer, 0)
	end
end)

addEventHandler("onClientPlayerVehicleEnter", localPlayer, function()
	if getElementData(source, "dead") or getElementData(source, "cked") then
		cancelEvent()
	end
end)

addEventHandler("onClientPlayerVehicleExit", localPlayer, function()
	if getElementData(source, "dead") or getElementData(source, "cked") then
		cancelEvent()
	end
end)

-- Oyuncu login olduğunda baygınlık durumunu kontrol et
addEventHandler("onClientElementDataChange", localPlayer, function(key, old, new)
	if key == "logged" and new == true and old ~= true then
		-- Login olduktan sonra kısa bir süre bekle ve baygınlık durumunu kontrol et
		setTimer(function()
			if isElement(localPlayer) and getElementData(localPlayer, "logged") then
				triggerServerEvent("death.checkAndRestoreDeathState", localPlayer, localPlayer)
			end
		end, 1000, 1)
	end
end)
