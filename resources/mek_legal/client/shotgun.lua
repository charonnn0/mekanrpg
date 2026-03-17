local SHOTGUN_WEAPON_ID = 25
local COOLDOWN_DURATION = 3000
local BEANBAG_RANGE = 35

local cooldownActive = false
local cooldownTimer = nil
local isUnderFireFromNPC = false
local npcAttackerElement = nil
local npcOriginalRotation = 0

local function getShotgunMode()
	local mode = getElementData(localPlayer, "shotgun_mode")
	if not mode then
		triggerServerEvent("legal.setShotgunMode", localPlayer, 0)
		return 0
	end
	return mode
end

local function setShotgunMode(mode)
	triggerServerEvent("legal.setShotgunMode", localPlayer, mode)
	if mode == 0 then
		outputChatBox("[!]#FFFFFF Çok amaçlı pompalınızda beanbag modunu aktifleştirdiniz.", 0, 0, 255, true)
	elseif mode == 1 then
		outputChatBox("[!]#FFFFFF Çok amaçlı pompalınızda öldürücü modunu aktifleştirdiniz.", 0, 0, 255, true)
	end
end

local function handleModeSwitch()
	if
		not (
			exports.mek_faction:isPlayerInFaction(localPlayer, { 1, 3 })
			and getPedWeapon(localPlayer) == SHOTGUN_WEAPON_ID
			and getPedTotalAmmo(localPlayer) > 0
		)
	then
		return
	end

	local currentMode = getShotgunMode()

	if currentMode == 0 then
		setShotgunMode(1)
	elseif currentMode == 1 then
		setShotgunMode(0)
	end
end

local function enableBeanbagCooldown()
	if cooldownActive then
		return
	end

	cooldownActive = true
	toggleControl("fire", false)
	setElementData(localPlayer, "shotgun_reload", true)

	if cooldownTimer then
		killTimer(cooldownTimer)
	end
	cooldownTimer = setTimer(disableBeanbagCooldown, COOLDOWN_DURATION, 1)
end

function disableBeanbagCooldown()
	cooldownActive = false
	toggleControl("fire", true)
	setElementData(localPlayer, "shotgun_reload", false)

	if cooldownTimer then
		killTimer(cooldownTimer)
		cooldownTimer = nil
	end
end

local function onClientWeaponFire(weaponID, ammo, ammoInClip, hitX, hitY, hitZ, hitElement)
	if weaponID ~= SHOTGUN_WEAPON_ID then
		return
	end

	local currentMode = getShotgunMode()
	if currentMode == 0 then
		enableBeanbagCooldown()

		local playerX, playerY, playerZ = getElementPosition(localPlayer)
		local distance = getDistanceBetweenPoints3D(hitX, hitY, hitZ, playerX, playerY, playerZ)

		if distance < BEANBAG_RANGE then
			fxAddSparks(hitX, hitY, hitZ, 1, 1, 1, 1, 10, 0, 0, 0, true, 3, 1)
		end
		playSoundFrontEnd(38)
		triggerServerEvent("legal.beanbagFired", localPlayer, hitX, hitY, hitZ, hitElement)
	end
end

local function onClientPlayerTarget(targetElement)
	if not isElement(targetElement) then
		return
	end

	if getElementType(targetElement) == "ped" then
		local model = getElementModel(targetElement)
		if
			(model == 282 or model == 280 or model == 285)
			and not isUnderFireFromNPC
			and getPedControlState("aim_weapon")
		then
			isUnderFireFromNPC = true
			npcAttackerElement = targetElement
			npcOriginalRotation = getPedRotation(targetElement)
			addEventHandler("onClientRender", root, makeNPCCopFireOnPlayer)
			addEventHandler("onClientPlayerWasted", localPlayer, onPlayerWastedByNPC)
		end
	end
end

local function onClientPlayerDamage(attacker, weaponID, bodypart, loss)
	if weaponID == SHOTGUN_WEAPON_ID then
		local mode = getElementData(attacker, "shotgun_mode")
		if mode == 0 then
			cancelEvent()
		end
	end
end

local function showBeanbagEffect(x, y, z)
	fxAddSparks(x, y, z, 1, 1, 1, 1, 100, 0, 0, 0, true, 3, 2)
	playSoundFrontEnd(38)
end

local function makeNPCCopFireOnPlayer()
	if isUnderFireFromNPC and isElement(npcAttackerElement) then
		local playerRot = getPedRotation(localPlayer)
		local px, py, pz = getPedBonePosition(localPlayer, 7)

		setPedRotation(npcAttackerElement, playerRot - 180)
		setPedControlState(npcAttackerElement, "aim_weapon", true)
		setPedAimTarget(npcAttackerElement, px, py, pz)
		setPedControlState(npcAttackerElement, "fire", true)
	else
		onPlayerWastedByNPC()
	end
end

local function onPlayerWastedByNPC()
	if isElement(npcAttackerElement) then
		setPedControlState(npcAttackerElement, "aim_weapon", false)
		setPedControlState(npcAttackerElement, "fire", false)
		setPedRotation(npcAttackerElement, npcOriginalRotation)
	end

	npcAttackerElement = nil
	isUnderFireFromNPC = false
	removeEventHandler("onClientRender", root, makeNPCCopFireOnPlayer)
	removeEventHandler("onClientPlayerWasted", localPlayer, onPlayerWastedByNPC)
end

local function onResourceStart()
	bindKey("n", "down", handleModeSwitch)
	addEventHandler("onClientPlayerWeaponFire", localPlayer, onClientWeaponFire)
	addEventHandler("onClientPlayerTarget", root, onClientPlayerTarget)
	addEventHandler("onClientPlayerDamage", localPlayer, onClientPlayerDamage)
	addEventHandler("onClientPlayerWeaponSwitch", root, disableBeanbagCooldown)
	addEvent("legal.showBeanbagEffect", true)
	addEventHandler("legal.showBeanbagEffect", root, showBeanbagEffect)
	getShotgunMode()
end
addEventHandler("onClientResourceStart", resourceRoot, onResourceStart)
