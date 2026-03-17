addEvent("realism.startSmoking", true)
addEventHandler("realism.startSmoking", root, function(hand)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not hand then
		hand = 0
	else
		hand = tonumber(hand)
	end

	triggerClientEvent(root, "realism.smokingSync", source, true, hand)
	setElementData(source, "realism_smoking", true)
	setElementData(source, "realism_smoking_hand", hand)
	setTimer(stopSmoking, 300000, 1, source)
end)

function stopSmoking(thePlayer)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not thePlayer then
		thePlayer = source
	end

	if isElement(thePlayer) then
		local isSmoking = getElementData(thePlayer, "realism_smoking")
		local smokingJoint = getElementData(thePlayer, "realism_smoking_joint")

		if smokingJoint then
			triggerClientEvent(root, "realism.smokingSync", thePlayer, false, 0)
			setElementData(thePlayer, "realism_smoking_joint", false)
			setElementData(thePlayer, "realism_smoking", false)
			return
		end

		if isSmoking then
			triggerClientEvent(root, "realism.smokingSync", thePlayer, false, 0)
			setElementData(thePlayer, "realism_smoking", false)
		end
	end
end
addEvent("realism.stopSmoking", true)
addEventHandler("realism.stopSmoking", root, stopSmoking)

function stopSmokingCMD(thePlayer)
	local isSmoking = getElementData(thePlayer, "realism_smoking")
	local smokingJoint = getElementData(thePlayer, "realism_smoking_joint")

	if smokingJoint then
		stopSmoking(thePlayer)
		exports.mek_global:sendLocalMeAction(thePlayer, "jointini yere atar.")
		return
	end

	if isSmoking then
		stopSmoking(thePlayer)
		exports.mek_global:sendLocalMeAction(thePlayer, "sigarasını yere atar.")
	end
end
addCommandHandler("sigaraat", stopSmokingCMD, false, false)

function changeSmokehand(thePlayer)
	local isSmoking = getElementData(thePlayer, "realism_smoking")
	if isSmoking then
		local smokingHand = getElementData(thePlayer, "realism_smoking_hand")
		triggerClientEvent(root, "realism.smokingSync", thePlayer, true, 1 - smokingHand)
		setElementData(thePlayer, "realism_smoking_hand", 1 - smokingHand)
	end
end
addCommandHandler("sigaraeldegis", changeSmokehand, false, false)

function passJointCMD(thePlayer, commandName, target)
	if not target then
		outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID]", thePlayer, 255, 194, 14)
		return
	end

	local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, target)
	if not targetPlayer then
		return
	end

	if thePlayer == targetPlayer then
		outputChatBox("[!]#FFFFFF Kendinize joint veremezsiniz.", thePlayer, 255, 0, 0, true)
		return
	end

	local x, y, z = getElementPosition(thePlayer)
	local tx, ty, tz = getElementPosition(targetPlayer)

	if getDistanceBetweenPoints3D(x, y, z, tx, ty, tz) <= 3 then
		local smokingJoint = getElementData(thePlayer, "realism_smoking_joint")
		if smokingJoint then
			stopSmoking(thePlayer)
			setElementData(thePlayer, "realism_smoking_joint", false)
			setElementData(thePlayer, "realism_smoking", false)
			exports.mek_global:sendLocalMeAction(thePlayer, targetPlayerName .. "'e bir joint uzatır.")
			outputChatBox(
				"[!]#FFFFFF /sigaraat ile sigarayı atabilir, /sigaraeldegis ile el değiştirebilirsiniz, /sigarajointver ile jointi verebilirsin.",
				targetPlayer,
				0,
				0,
				255,
				true
			)
			setElementData(targetPlayer, "realism_smoking_joint", true)
			triggerEvent("realism.startSmoking", targetPlayer, 0)
		end
	else
		outputChatBox(
			"[!]#FFFFFF " .. targetPlayerName .. " isimli kişiye yeterince yakın değilsin.",
			thePlayer,
			255,
			0,
			0,
			true
		)
	end
end
addCommandHandler("sigarajointver", passJointCMD, false, false)

addEvent("realism.smoking.request", true)
addEventHandler("realism.smoking.request", root, function()
	for i, player in ipairs(getElementsByType("player")) do
		local isSmoking = getElementData(player, "realism_smoking")
		if isSmoking then
			local smokingHand = getElementData(player, "realism_smoking_hand")
			triggerClientEvent(source, "realism.smokingSync", player, isSmoking, smokingHand)
		end
	end
end)
