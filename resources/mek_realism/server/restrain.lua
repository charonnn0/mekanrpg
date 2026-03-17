local colSphere = createColSphere(1425.119140625, -1292.7041015625, 13.55660533905, 3)

local controls = {
	"fire",
	"next_weapon",
	"previous_weapon",
	"jump",
	"action",
	"aim_weapon",
	"vehicle_fire",
	"vehicle_secondary_fire",
	"vehicle_left",
	"vehicle_right",
	"steer_forward",
	"steer_back",
	"accelerate",
	"brake_reverse",
	"sprint",
}

local activeRestrainControlTimers = {}

function toggleRestrainedControls(player, enable)
	for _, control in ipairs(controls) do
		toggleControl(player, control, enable)
	end
end

function isElementInRange(element, x, y, z, range)
	if
		isElement(element)
		and type(x) == "number"
		and type(y) == "number"
		and type(z) == "number"
		and type(range) == "number"
	then
		return getDistanceBetweenPoints3D(x, y, z, getElementPosition(element)) <= range
	end
	return false
end

addEvent("restrain.server", true)
addEventHandler("restrain.server", root, function(targetPlayer, restrainedItem)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end
	
	local targetPlayerName = targetPlayer:getName()

	if restrainedItem == 45 and not targetPlayer:getData("restrained") then
		cuffPlayer(client, "", targetPlayerName)
	elseif restrainedItem == 45 and targetPlayer:getData("restrained") and targetPlayer:getData("restrained_item") == 45 then
		uncuffPlayer(client, "", targetPlayerName)
	end
end)

function cuffPlayer(thePlayer, commandName, targetPlayer)
	if not exports.mek_faction:isPlayerInFaction(thePlayer, { 1, 2, 3, 4 }) then
		outputChatBox(
			"[!]#FFFFFF Bu işlemi yalnızca legal birlik üyeleri gerçekleştirebilir.",
			thePlayer,
			255,
			0,
			0,
			true
		)
		return
	end

	if thePlayer:getData("dead") then
		outputChatBox("[!]#FFFFFF Baygınken birisini sürükleyemezsiniz.", thePlayer, 255, 0, 0, true)
		return
	end

	if thePlayer:getData("restrained") then
		outputChatBox("[!]#FFFFFF Bağlıyken birisini sürükleyemezsiniz.", thePlayer, 255, 0, 0, true)
		return
	end

	if not targetPlayer then
		outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID]", thePlayer, 255, 194, 14)
		return
	end

	local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
	if not targetPlayer then
		return
	end
	
	if thePlayer == targetPlayer then
		outputChatBox("[!]#FFFFFF Bu işlemi kendinize uygulayamazsınız.", thePlayer, 255, 0, 0, true)
		return
	end

	if not exports.mek_item:hasItem(thePlayer, 45) then
		outputChatBox("[!]#FFFFFF Kelepçelemek için kelepçe gerekir.", thePlayer, 255, 0, 0, true)
		return
	end

	local x, y, z = getElementPosition(thePlayer)
	if not isElementInRange(targetPlayer, x, y, z, 5) then
		outputChatBox("[!]#FFFFFF Kelepçelemek için oyuncuya yakın olmanız gerekir.", thePlayer, 255, 0, 0, true)
		return
	end

	if targetPlayer:getData("restrained") then
		outputChatBox("[!]#FFFFFF Bu oyuncu zaten kelepçeli.", thePlayer, 255, 0, 0, true)
		return
	end

	exports.mek_item:takeItem(thePlayer, 45)
	thePlayer:setAnimation("BD_FIRE", "wamek_up", 1000, false, true, false, false)

	targetPlayer:setData("restrained", true)
	targetPlayer:setData("restrained_item", 45)
	dbExec(
		exports.mek_mysql:getConnection(),
		"UPDATE characters SET restrained = 1, restrained_item = 45 WHERE id = ?",
		getElementData(targetPlayer, "dbid")
	)

	toggleRestrainedControls(targetPlayer, false)

	exports.mek_global:sendLocalMeAction(
		thePlayer,
		"teçhizat kemerine uzanıp kelepçeyi kavrar ve elleri baş aşağı olacak şekilde şahısın kollarını arkadan kelepçeler.",
		false,
		true
	)
	outputChatBox("[!]#FFFFFF " .. targetPlayerName .. " isimli oyuncu kelepçelendi.", thePlayer, 0, 255, 0, true)
	outputChatBox(
		"[!]#FFFFFF " .. thePlayer:getName():gsub("_", " ") .. " isimli oyuncu sizi kelepçeledi.",
		targetPlayer,
		0,
		0,
		255,
		true
	)

	exports.mek_item:giveItem(thePlayer, 47, getElementData(targetPlayer, "dbid"))

	local restrainControlTimer = setTimer(function(restrainedPlayerElement)
		if isElement(restrainedPlayerElement) and restrainedPlayerElement:getData("restrained") then
			toggleRestrainedControls(restrainedPlayerElement, false)
		else
			local timerID = activeRestrainControlTimers[restrainedPlayerElement]
			if timerID and isTimer(timerID) then
				killTimer(timerID)
				activeRestrainControlTimers[restrainedPlayerElement] = nil
			end
		end
	end, 1000, 0, targetPlayer)

	activeRestrainControlTimers[targetPlayer] = restrainControlTimer
end
addCommandHandler("kelepcele", cuffPlayer, false, false)

function uncuffPlayer(thePlayer, commandName, targetPlayer)
	if not targetPlayer then
		outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID]", thePlayer, 255, 194, 14)
		return
	end

	local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
	if not targetPlayer then
		return
	end
	
	if thePlayer == targetPlayer then
		outputChatBox("[!]#FFFFFF Bu işlemi kendinize uygulayamazsınız.", thePlayer, 255, 0, 0, true)
		return
	end

	if not targetPlayer:getData("restrained") then
		outputChatBox("[!]#FFFFFF Bu oyuncu kelepçeli değil.", thePlayer, 255, 0, 0, true)
		return
	end

	if not exports.mek_item:hasItem(thePlayer, 47, targetPlayer:getData("dbid")) then
		outputChatBox(
			"[!]#FFFFFF Bu kişinin kelepçesini açmak için gerekli anahtarı taşımıyorsunuz.",
			thePlayer,
			255,
			0,
			0,
			true
		)
		return
	end

	local x, y, z = getElementPosition(thePlayer)
	if not isElementInRange(targetPlayer, x, y, z, 5) then
		outputChatBox(
			"[!]#FFFFFF Kelepçeleri çıkarmak için oyuncuya yakın olmanız gereklidir.",
			thePlayer,
			255,
			0,
			0,
			true
		)
		return
	end

	targetPlayer:setData("restrained", false)
	targetPlayer:setData("restrained_item", 0)
	dbExec(
		exports.mek_mysql:getConnection(),
		"UPDATE characters SET restrained = 0, restrained_item = 0 WHERE id = ?",
		getElementData(targetPlayer, "dbid")
	)

	toggleRestrainedControls(targetPlayer, true)

	exports.mek_global:sendLocalMeAction(
		thePlayer,
		"teçhizat kemerine uzanıp kelepçenin anahtarını kavrar ve şahısın kelepçesini çözer.",
		false,
		true
	)
	outputChatBox(
		"[!]#FFFFFF " .. targetPlayerName .. " isimli oyuncunun kelepçesini çıkardınız.",
		thePlayer,
		0,
		0,
		255,
		true
	)
	outputChatBox(
		"[!]#FFFFFF " .. thePlayer:getName():gsub("_", " ") .. " isimli oyuncu kelepçeni çıkardı.",
		targetPlayer,
		0,
		0,
		255,
		true
	)

	exports.mek_item:takeItem(thePlayer, 47, 1)
	exports.mek_item:giveItem(thePlayer, 45, 1)

	local timerID = activeRestrainControlTimers[targetPlayer]
	if timerID and isTimer(timerID) then
		killTimer(timerID)
		activeRestrainControlTimers[targetPlayer] = nil
	end
end
addCommandHandler("kelepcecikar", uncuffPlayer, false, false)

function breakCuff(thePlayer, commandName)
	if not isElementWithinColShape(thePlayer, colSphere) then
		outputChatBox("[!]#FFFFFF Kelepçeleri kırmak için uygun bir alanda değilsiniz.", thePlayer, 255, 0, 0, true)
		return
	end

	if not thePlayer:getData("restrained") then
		outputChatBox("[!]#FFFFFF Kelepçeli değilsiniz.", thePlayer, 255, 0, 0, true)
		return
	end

	thePlayer:setData("restrained", false)
	thePlayer:setData("restrained_item", 0)
	dbExec(
		exports.mek_mysql:getConnection(),
		"UPDATE characters SET restrained = 0, restrained_item = 0 WHERE id = ?",
		getElementData(thePlayer, "dbid")
	)

	toggleRestrainedControls(thePlayer, true)

	exports.mek_global:sendLocalMeAction(
		thePlayer,
		"çöp kutusunun ucuna vurarak sağ ve sol elindeki kelepçeleri kırmaya çalışar.",
		false,
		true
	)
	exports.mek_global:sendLocalDoAction(thePlayer, "Kelepçe kırıldı.")

	local timerID = activeRestrainControlTimers[thePlayer]
	if timerID and isTimer(timerID) then
		killTimer(timerID)
		activeRestrainControlTimers[thePlayer] = nil
	end
end
addCommandHandler("kelepcekir", breakCuff, false, false)

function checkPlayerRestrain(player)
	if not isElement(player) then
		return
	end

	if player:getData("restrained") then
		toggleRestrainedControls(player, false)

		local timerID = activeRestrainControlTimers[player]
		if not timerID or not isTimer(timerID) then
			local restrainControlTimer = setTimer(function(restrainedPlayerElement)
				if isElement(restrainedPlayerElement) and restrainedPlayerElement:getData("restrained") then
					toggleRestrainedControls(restrainedPlayerElement, false)
				else
					local currentTimerID = activeRestrainControlTimers[restrainedPlayerElement]
					if currentTimerID and isTimer(currentTimerID) then
						killTimer(currentTimerID)
						activeRestrainControlTimers[restrainedPlayerElement] = nil
					end
				end
			end, 1000, 0, player)

			activeRestrainControlTimers[player] = restrainControlTimer
		end
	else
		toggleRestrainedControls(player, true)

		local timerID = activeRestrainControlTimers[player]
		if timerID and isTimer(timerID) then
			killTimer(timerID)
			activeRestrainControlTimers[player] = nil
		end
	end
end

addEventHandler("onPlayerQuit", root, function()
	local player = source
	if player:getData("restrained") then
		local timerID = activeRestrainControlTimers[player]
		if timerID and isTimer(timerID) then
			killTimer(timerID)
			activeRestrainControlTimers[player] = nil
		end
	end
end)
