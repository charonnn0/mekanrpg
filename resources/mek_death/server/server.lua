local healingZone = createColSphere(1591.898, 1798.308, 2083.377, 6)
setElementInterior(healingZone, 0)
setElementDimension(healingZone, 65535)

local injuredPlayers = {}
local injuredWeapons = {
	[4] = true,
	[22] = true,
	[23] = true,
	[24] = true,
	[25] = true,
	[26] = true,
	[27] = true,
	[28] = true,
	[29] = true,
	[30] = true,
	[31] = true,
	[32] = true,
	[33] = true,
	[34] = true,
	[35] = true,
	[36] = true,
}

local deathAnimations = {
	{ "WUZI", "CS_Dead_Guy" },
	{ "CRACK", "crckidle1" },
	{ "CRACK", "crckidle2" },
	{ "CRACK", "crckidle3" },
}

local deathAnimationTimers = {}
local rkCooldownTimers = {}

addEventHandler("onPlayerWasted", root, function(_, killer, weapon)
	if not getElementData(source, "logged") then
		return
	end

	if getElementData(source, "admin_jailed") then
		respawnPlayerInJail(source)
	elseif getElementData(source, "pd_jailed") and getResourceState(getResourceFromName("mek_prison")) == "running" then
		exports.mek_prison:checkForRelease(source)
	else
		if injuredWeapons[weapon] then
			setElementData(source, "rk", true)
		else
			setElementData(source, "rk", false)
		end
		respawnPlayerDead(source)
		
		saveDeathStateToDatabase(source)
	end
end)

function respawnPlayerInJail(player)
	local skinID = getElementModel(player)
	local modelID = getElementData(player, "model")
	local team = getPlayerTeam(player)

	spawnPlayer(player, 263.821807, 77.848365, 1001.0390625, 270, 0, 6, 60000 + getElementData(player, "id"), team)

	if modelID and tonumber(modelID) > 0 then
		setElementData(player, "model", 0)
		setElementData(player, "model", modelID)
	else
		setElementModel(player, skinID)
	end

	setElementData(player, "seatbelt", false)
	setElementData(player, "dead", false)
	setElementFrozen(player, false)
	removeElementData(player, "frozen")
	setPedHeadless(player, false)
	setCameraTarget(player, player)
	fadeCamera(player, true)
	exports.mek_sac:allowHealthChange(player, "jail_respawn")
	setElementHealth(player, 100)
end

function respawnPlayerDead(player)
	local x, y, z = getElementPosition(player)
	local rotation = select(3, getElementRotation(player))
	local skinID = getElementModel(player)
	local modelID = getElementData(player, "model")
	local team = getPlayerTeam(player)
	local interior = getElementInterior(player)
	local dimension = getElementDimension(player)
	local animation = deathAnimations[math.random(#deathAnimations)]

	spawnPlayer(player, x, y, z, rotation, 0, interior, dimension, team)

	if modelID and tonumber(modelID) > 0 then
		setElementData(player, "model", 0)
		setElementData(player, "model", modelID)
	else
		setElementModel(player, skinID)
	end

	exports.mek_sac:allowHealthChange(player, "dead_respawn")
	setElementHealth(player, 20)
	setTimer(setPedAnimation, 500, 1, player, animation[1], animation[2], -1, true, false, false)
	setCameraTarget(player, player)
	setCameraInterior(player, interior)
	fadeCamera(player, true)

	setElementData(player, "dead", true)
	setElementData(player, "seatbelt", false)
	setElementFrozen(player, true)
	setElementData(player, "frozen", true)

	toggleControl(player, "fire", false)
	toggleControl(player, "jump", false)

	exports.mek_global:sendLocalDoAction(player, "Şahıs hasarın etkisi ile bayılmıştır.")
	exports.mek_global:sendLocalMeAction(player, "dizlerini kırar ve yavaşça kendini yere bırakır.")

	triggerClientEvent(player, "death.renderUI", player)

	if isTimer(deathAnimationTimers[player]) then
		killTimer(deathAnimationTimers[player])
	end

	deathAnimationTimers[player] = setTimer(function()
		if not isElement(player) or not getElementData(player, "dead") then
			if isTimer(deathAnimationTimers[player]) then
				killTimer(deathAnimationTimers[player])
				deathAnimationTimers[player] = nil
			end
			return
		end

		if not isPedInVehicle(player) then
			setPedAnimation(player, animation[1], animation[2], -1, true, false, false)
		end
	end, 2000, 0)
end

-- Baygınlık durumunu veritabanına kaydet
function saveDeathStateToDatabase(player)
	if not isElement(player) or not getElementData(player, "logged") then
		return
	end
	
	local dbid = getElementData(player, "dbid")
	if not dbid then
		return
	end
	
	local x, y, z = getElementPosition(player)
	local rotation = select(3, getElementRotation(player))
	local interior = getElementInterior(player)
	local dimension = getElementDimension(player)
	
	dbExec(
		exports.mek_mysql:getConnection(),
		"UPDATE characters SET is_dead = 1, death_x = ?, death_y = ?, death_z = ?, death_rotation = ?, death_interior = ?, death_dimension = ?, death_time = NOW() WHERE id = ?",
		x, y, z, rotation, interior, dimension, dbid
	)
end

-- Baygınlık durumunu veritabanından temizle
function clearDeathStateFromDatabase(player)
	if not isElement(player) then
		return
	end
	
	local dbid = getElementData(player, "dbid")
	if not dbid then
		return
	end
	
	dbExec(
		exports.mek_mysql:getConnection(),
		"UPDATE characters SET is_dead = 0, death_x = NULL, death_y = NULL, death_z = NULL, death_rotation = NULL, death_interior = NULL, death_dimension = NULL, death_time = NULL WHERE id = ?",
		dbid
	)
end

function checkAndRestoreDeathState(player)
	if client and client ~= player then
		return
	end

	if not isElement(player) or not getElementData(player, "logged") then
		return
	end
	
	-- Admin jail veya pd jail durumlarında restore etme
	if getElementData(player, "admin_jailed") or getElementData(player, "pd_jailed") then
		return
	end
	
	local dbid = getElementData(player, "dbid")
	if not dbid then
		return
	end
	
	-- Veritabanından baygınlık durumunu kontrol et
	dbQuery(function(qh)
		local result = dbPoll(qh, 0)
		if result and #result > 0 then
			local data = result[1]
			if data.is_dead == 1 and data.death_x then
				-- Oyuncu baygınmış, durumu geri yükle
				if not isElement(player) then
					return
				end
				
				local x = tonumber(data.death_x)
				local y = tonumber(data.death_y)
				local z = tonumber(data.death_z)
				local rotation = tonumber(data.death_rotation) or 0
				local interior = tonumber(data.death_interior) or 0
				local dimension = tonumber(data.death_dimension) or 0
				
				local skinID = getElementModel(player)
				local modelID = getElementData(player, "model")
				local team = getPlayerTeam(player)
				local animation = deathAnimations[math.random(#deathAnimations)]
				
				-- Oyuncuyu baygın pozisyonunda spawn et
				spawnPlayer(player, x, y, z, rotation, 0, interior, dimension, team)
				
				if modelID and tonumber(modelID) > 0 then
					setElementData(player, "model", 0)
					setElementData(player, "model", modelID)
				else
					setElementModel(player, skinID)
				end
				
				exports.mek_sac:allowHealthChange(player, "death_restore")
				setElementHealth(player, 20)
				setTimer(setPedAnimation, 500, 1, player, animation[1], animation[2], -1, true, false, false)
				setCameraTarget(player, player)
				setCameraInterior(player, interior)
				fadeCamera(player, true)
				
				setElementData(player, "dead", true)
				setElementData(player, "seatbelt", false)
				setElementFrozen(player, true)
				setElementData(player, "frozen", true)
				
				toggleControl(player, "fire", false)
				toggleControl(player, "jump", false)
				
				exports.mek_global:sendLocalDoAction(player, "Şahıs hasarın etkisi ile bayılmıştır.")
				
				triggerClientEvent(player, "death.renderUI", player)
				
				-- Animasyon timer'ını başlat
				if isTimer(deathAnimationTimers[player]) then
					killTimer(deathAnimationTimers[player])
				end
				
				deathAnimationTimers[player] = setTimer(function()
					if not isElement(player) or not getElementData(player, "dead") then
						if isTimer(deathAnimationTimers[player]) then
							killTimer(deathAnimationTimers[player])
							deathAnimationTimers[player] = nil
						end
						return
					end
					
					if not isPedInVehicle(player) then
						setPedAnimation(player, animation[1], animation[2], -1, true, false, false)
					end
				end, 2000, 0)
				
				--outputChatBox("[!]#FFFFFF Baygın durumdayken sunucudan çıktınız. Baygınlık durumunuz geri yüklendi.", player, 255, 194, 14, true)
			end
		end
	end, exports.mek_mysql:getConnection(), "SELECT is_dead, death_x, death_y, death_z, death_rotation, death_interior, death_dimension FROM characters WHERE id = ?", dbid)
end
addEvent("death.checkAndRestoreDeathState", true)
addEventHandler("death.checkAndRestoreDeathState", root, checkAndRestoreDeathState)

addEventHandler("onPlayerDamage", root, function(attacker, weapon)
	if
		isElement(attacker)
		and getElementType(attacker) == "player"
		and not injuredPlayers[source]
		and injuredWeapons[weapon]
	then
		setElementData(source, "injury", true)
		startInjuryDrain(source)
	end
end)

function startInjuryDrain(player)
	if not isElement(player) then
		return
	end

	if injuredPlayers[player] then
		cancelInjuryDrain(player)
	end

	injuredPlayers[player] = setTimer(function()
		if not isElement(player) then
			cancelInjuryDrain(player)
			return
		end

		local isInjured = getElementData(player, "injury")
		local isDead = getElementData(player, "death")
		local isCked = getElementData(player, "cked")
		local health = getElementHealth(player)

		if not isInjured then
			cancelInjuryDrain(player)
			return
		end

		if health > MIN_HEALTH_FOR_DRAIN and not isDead and not isCked then
			exports.mek_sac:allowHealthChange(player, "injury_drain")
			setElementHealth(player, math.max(MIN_HEALTH_FOR_DRAIN, health - INJURED_DRAIN_AMOUNT))
			return
		end

		if isDead and not isCked then
			exports.mek_infobox:addBox(player, "warning", "Çok yaralısınız! Tıbbi yardım almanız gerekiyor!")
		end
	end, INJURED_DRAIN_INTERVAL, 0)
end

function cancelInjuryDrain(player)
	if isTimer(injuredPlayers[player]) then
		killTimer(injuredPlayers[player])
	end
	injuredPlayers[player] = nil
end

addEventHandler("onElementDataChange", root, function(key, _, new)
	if key == "injury" and not new then
		cancelInjuryDrain(source)
	end
end)

addEventHandler("onPlayerQuit", root, function()
	cancelInjuryDrain(source)
	
	-- Baygın durumdaysa veritabanına kaydet
	if getElementData(source, "dead") and getElementData(source, "logged") then
		saveDeathStateToDatabase(source)
	end
end)

function acceptDeath(player)
	if client and client ~= player then
		return
	end

	if getElementData(player, "dead") then
		setElementData(player, "dead", false)
		removeElementData(player, "frozen")
		setPedAnimation(player)
		setElementFrozen(player, false)
		exports.mek_sac:allowHealthChange(player, "accept_death")
		setElementHealth(player, 20)
		triggerEvent("updateLocalGuns", player)
		fadeCamera(player, true)

		exports.mek_global:sendLocalDoAction(player, "Şahıs yavaşça ayılmaya başlar.")
		exports.mek_global:sendLocalMeAction(player, "elleri ile yerden destek alarak yavaşça doğrulur.")

		-- Baygınlık durumunu veritabanından temizle
		clearDeathStateFromDatabase(player)

		if getElementData(player, "rk") then
			outputChatBox("[!]#FFFFFF Ayıldınız. 30 saniye boyunca silah çekemezsiniz (RK koruması).", player, 255, 255, 255, true)
			if isTimer(rkCooldownTimers[player]) then
				killTimer(rkCooldownTimers[player])
				rkCooldownTimers[player] = nil
			end
			rkCooldownTimers[player] = setTimer(function(p)
				if isElement(p) then
					setElementData(p, "rk", false)
					outputChatBox("[!]#FFFFFF RK koruması sona erdi, artık silah kullanabilirsiniz.", p, 0, 255, 0, true)
				end
				rkCooldownTimers[p] = nil
			end, 60000, 1, player)
		end

		if isTimer(deathAnimationTimers[player]) then
			killTimer(deathAnimationTimers[player])
			deathAnimationTimers[player] = nil
		end
	end
end
addEvent("death.acceptDeath", true)
addEventHandler("death.acceptDeath", root, acceptDeath)

function fallProtection(x, y, z)
	local interior = getElementInterior(client)
	local dimension = getElementDimension(client)

	if isPedDead(client) or getElementData(client, "dead") then
		local x, y, z = getElementPosition(client)
		local rotation = select(3, getElementRotation(client))
		local skinID = getElementModel(client)
		local modelID = getElementData(client, "model")
		local team = getPlayerTeam(client)

		spawnPlayer(client, x, y, z, rotation, 0, interior, dimension, team)

		if modelID and tonumber(modelID) > 0 then
			setElementData(client, "model", 0)
			setElementData(client, "model", modelID)
		else
			setElementModel(client, skinID)
		end

		acceptDeath(client)
		triggerClientEvent(client, "death.revive", client)
		triggerClientEvent(client, "death.closeUI", client)
		exports.mek_global:sendMessageToAdmins(
			"[BUG] "
				.. getPlayerName(client):gsub("_", " ")
				.. " isimli oyuncudan düşme algılandığı için hayata döndürüldü."
		)
	else
		setElementPosition(client, x, y, z)
	end

	setElementInterior(client, interior)
	setElementDimension(client, dimension)
end
addEvent("fallProtectionRespawn", true)
addEventHandler("fallProtectionRespawn", root, fallProtection)

function revivePlayer(thePlayer, commandName, targetPlayer)
	if not exports.mek_integration:isPlayerAdmin1(thePlayer) then
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
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

	if not getElementData(targetPlayer, "logged") then
		outputChatBox(
			"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
			thePlayer,
			255,
			0,
			0,
			true
		)
		return
	end

	if not getElementData(targetPlayer, "dead") then
		outputChatBox("[!]#FFFFFF Bu oyuncu baygın değil.", thePlayer, 255, 0, 0, true)
		return
	end

	local x, y, z = getElementPosition(targetPlayer)
	local rotation = select(3, getElementRotation(targetPlayer))
	local interior = getElementInterior(targetPlayer)
	local dimension = getElementDimension(targetPlayer)
	local skinID = getElementModel(targetPlayer)
	local modelID = getElementData(targetPlayer, "model")
	local team = getPlayerTeam(targetPlayer)

	spawnPlayer(targetPlayer, x, y, z, rotation, 0, interior, dimension, team)

	if modelID and tonumber(modelID) > 0 then
		setElementData(targetPlayer, "model", 0)
		setElementData(targetPlayer, "model", modelID)
	else
		setElementModel(targetPlayer, skinID)
	end

	acceptDeath(targetPlayer)
	clearDeathStateFromDatabase(targetPlayer)
	triggerClientEvent(targetPlayer, "death.revive", targetPlayer)
	triggerClientEvent(targetPlayer, "death.closeUI", targetPlayer)

	outputChatBox("[!]#FFFFFF " .. targetPlayerName .. " isimli oyuncu canlandırıldı.", thePlayer, 0, 255, 0, true)
	outputChatBox(
		"[!]#FFFFFF "
			.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
			.. " isimli yetkili tarafından canlandırıldınız.",
		targetPlayer,
		0,
		0,
		255,
		true
	)
	exports.mek_global:sendMessageToAdmins(
		"[ADM] "
			.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
			.. " isimli yetkili "
			.. targetPlayerName
			.. " isimli oyuncuyu canlandırdı."
	)
	exports.mek_logs:addLog(
		"revive",
		exports.mek_global:getPlayerFullAdminTitle(thePlayer)
			.. " isimli yetkili "
			.. targetPlayerName
			.. " isimli oyuncuyu canlandırdı."
	)
end
addCommandHandler("revive", revivePlayer, false, false)

-- /rkkaldir [Karakter Adı / ID]
function removeRK(thePlayer, commandName, target)
	if not exports.mek_integration:isPlayerServerManager(thePlayer) then
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
		return
	end

	if not target then
		outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID]", thePlayer, 255, 194, 14)
		return
	end

	local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, target)
	if not targetPlayer then
		return
	end

	if isTimer(rkCooldownTimers[targetPlayer]) then
		killTimer(rkCooldownTimers[targetPlayer])
		rkCooldownTimers[targetPlayer] = nil
	end

	if getElementData(targetPlayer, "rk") then
		setElementData(targetPlayer, "rk", false)
		outputChatBox("[!]#FFFFFF " .. targetPlayerName .. " için RK koruması kaldırıldı.", thePlayer, 0, 255, 0, true)
		outputChatBox("[!]#FFFFFF Bir yetkili tarafından RK korumanız kaldırıldı.", targetPlayer, 255, 255, 255, true)
		exports.mek_logs:addLog("rk_remove", exports.mek_global:getPlayerFullAdminTitle(thePlayer) .. " " .. targetPlayerName .. " için RK korumasını kaldırdı.")
		exports.mek_global:sendMessageToAdmins("[ADM] " .. exports.mek_global:getPlayerFullAdminTitle(thePlayer) .. " " .. targetPlayerName .. " için RK korumasını kaldırdı.")
	else
		outputChatBox("[!]#FFFFFF Bu oyuncuda aktif bir RK koruması yok.", thePlayer, 255, 194, 14, true)
	end
end
addCommandHandler("rkkaldir", removeRK, false, false)

function healSelf(thePlayer)
	if not isElementWithinColShape(thePlayer, healingZone) then
		outputChatBox("[!]#FFFFFF Tedavi bölgesinde değilsiniz.", thePlayer, 255, 0, 0, true)
		return
	end

	if not getElementData(thePlayer, "injury") then
		outputChatBox("[!]#FFFFFF Yaralı değilsiniz.", thePlayer, 255, 0, 0, true)
		return
	end

	local isVIP = (getElementData(thePlayer, "vip") or 0) >= 2
	local cost = isVIP and 0 or 100

	if cost == 0 or exports.mek_global:takeMoney(thePlayer, cost) then
		setElementData(thePlayer, "injury", false)
		exports.mek_sac:allowHealthChange(thePlayer, "tedaviol")
		setElementHealth(thePlayer, 100)

		if cost == 0 then
			outputChatBox("[!]#FFFFFF VIP+ olduğunuz için hiçbir ücret ödemediniz.", thePlayer, 0, 255, 0, true)
		else
			outputChatBox("[!]#FFFFFF Başarıyla tedavi oldunuz.", thePlayer, 0, 255, 0, true)
		end

		triggerClientEvent(thePlayer, "playSuccess", thePlayer)
	else
		outputChatBox("[!]#FFFFFF Yeterli paranız yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("tedaviol", healSelf, false, false)

function healOther(thePlayer, commandName, targetPlayer)
	if not exports.mek_integration:isPlayerAdmin2(thePlayer) then
		outputChatBox("[!]#FFFFFF Bu komutu kullanamazsınız.", thePlayer, 255, 0, 0, true)
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

	if not getElementData(targetPlayer, "logged") then
		outputChatBox(
			"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
			thePlayer,
			255,
			0,
			0,
			true
		)
		return
	end

	local px, py, pz = getElementPosition(thePlayer)
	local tx, ty, tz = getElementPosition(targetPlayer)
	local distance = getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz)

	if distance > 3 and not exports.mek_integration:isPlayerAdmin2(thePlayer) then
		outputChatBox(
			"[!]#FFFFFF " .. targetPlayerName .. " isimli kişiye yeterince yakın değilsiniz.",
			thePlayer,
			255,
			0,
			0,
			true
		)
		return
	end

	if not getElementData(targetPlayer, "injury") then
		outputChatBox("[!]#FFFFFF Bu kişi yaralı değil.", thePlayer, 255, 0, 0, true)
		return
	end

	setElementData(targetPlayer, "injury", false)
	exports.mek_sac:allowHealthChange(targetPlayer, "tedaviet")
	setElementHealth(targetPlayer, 100)

	outputChatBox("[!]#FFFFFF " .. targetPlayerName .. " isimli kişi tedavi edildi.", thePlayer, 0, 255, 0, true)
	outputChatBox(
		"[!]#FFFFFF " .. getPlayerName(thePlayer):gsub("_", " ") .. " isimli kişi tarafından tedavi edildiniz.",
		targetPlayer,
		0,
		255,
		0,
		true
	)
end
addCommandHandler("tedaviet", healOther, false, false)

addEventHandler("onElementDataChange", root, function(key, old, new)
	if client then
		if key == "rk" or key == "injury" or key == "dead" or key == "cked" or key == "frozen" then
			setElementData(source, key, old)
		end
	end
end)
