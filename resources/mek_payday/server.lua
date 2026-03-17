local bonusCodeCharacters = {
	"0",
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9",
	"A",
	"B",
	"C",
	"D",
	"E",
	"F",
	"G",
	"H",
	"I",
	"J",
	"K",
	"L",
	"M",
	"N",
	"O",
	"P",
	"Q",
	"R",
	"S",
	"T",
	"U",
	"V",
	"W",
	"X",
	"Y",
	"Z",
}
local playerBonusCodes = {}
local giftBoxZone = createColSphere(1292.623046875, -2352.373046875, 13.153707504272, 5)

setTimer(function()
	for _, player in ipairs(getElementsByType("player")) do
		if getElementData(player, "logged") then
			updatePlayerTime(player)
		end
	end
end, 60000, 0)

function updatePlayerTime(player)
	local minutes = (getElementData(player, "minutes_played") or 0) + 1
	local temporaryMinutes = (getElementData(player, "temporary_minutes_played") or 0) + 1
	local hours = getElementData(player, "hours_played") or 0
	local totalHours = getElementData(player, "total_hours_played") or 0
	local temporaryHours = getElementData(player, "temporary_hours_played") or 0
	local boxHours = getElementData(player, "box_hours") or 0

	setElementData(player, "minutes_played", minutes)
	setElementData(player, "temporary_minutes_played", temporaryMinutes)

	dbExec(
		exports.mek_mysql:getConnection(),
		"UPDATE characters SET minutes_played = ? WHERE id = ?",
		minutes,
		getElementData(player, "dbid")
	)

	if minutes >= 60 then
		local updatedHours = hours + 1
		local updatedTotalHours = totalHours + 1
		local updatedTemporaryHours = temporaryHours + 1
		local updatedBoxHours = boxHours + 1

		setElementData(player, "minutes_played", 0)
		setElementData(player, "temporary_minutes_played", 0)
		setElementData(player, "hours_played", updatedHours)
		setElementData(player, "total_hours_played", updatedTotalHours)
		setElementData(player, "temporary_hours_played", updatedTemporaryHours)
		setElementData(player, "box_hours", updatedBoxHours)

		dbExec(
			exports.mek_mysql:getConnection(),
			"UPDATE accounts SET total_hours_played = ? WHERE id = ?",
			updatedTotalHours,
			getElementData(player, "dbid")
		)

		dbExec(
			exports.mek_mysql:getConnection(),
			"UPDATE characters SET minutes_played = 0, hours_played = ?, box_hours = ? WHERE id = ?",
			updatedHours,
			updatedBoxHours,
			getElementData(player, "dbid")
		)

		local currentLevel = getElementData(player, "level") or 1
		local newLevel = calculateLevelFromHours(updatedHours)

		if newLevel > currentLevel then
			setElementData(player, "level", newLevel)
			dbExec(
				exports.mek_mysql:getConnection(),
				"UPDATE characters SET level = ? WHERE id = ?",
				newLevel,
				getElementData(player, "dbid")
			)
			outputChatBox("[!]#FFFFFF Tebrikler! Yeni seviye: " .. newLevel, player, 0, 255, 0, true)
		end

		assignHourlyBonusCode(player)
		rewardGiftBoxIfEligible(player)
	end
end

function assignHourlyBonusCode(player)
	local code = ""
	for _ = 1, 4 do
		code = code .. bonusCodeCharacters[math.random(#bonusCodeCharacters)]
	end

	playerBonusCodes[player] = {
		code = code,
		timer = setTimer(function()
			if isElement(player) then
				outputChatBox("[!]#FFFFFF Kod girilmediği için saatlik bonus iptal edildi.", player, 255, 0, 0, true)
				playerBonusCodes[player] = nil
			end
		end, 120000, 1),
	}

	outputChatBox(
		"[!]#FFFFFF Saatlik bonusunuzu 2 dakika içinde [/bonus " .. code .. "] yazarak onaylayabilirsiniz.",
		player,
		0,
		255,
		0,
		true
	)

	if exports.mek_settings:getPlayerSetting(player, "play_hourly_bonus_sound") then
		triggerClientEvent(player, "payday.playSound", player)
	end

	setTimer(function()
		if getElementData(player, "vip") >= 2 then
			bonusCommand(player, _, code)
		end
	end, 1000, 1)
end

function rewardGiftBoxIfEligible(player)
	local progress = getElementData(player, "box_hours") or 0
	if progress >= 4 then
		local boxCount = getElementData(player, "box_count") or 0
		setElementData(player, "box_count", boxCount + 1)
		setElementData(player, "box_hours", 0)

		dbExec(
			exports.mek_mysql:getConnection(),
			"UPDATE characters SET box_count = ?, box_hours = 0 WHERE id = ?",
			boxCount + 1,
			getElementData(player, "dbid")
		)

		outputChatBox(
			"[!]#FFFFFF 4 saatlik oynama süresi tamamlandı, bir kutu kazandınız!",
			player,
			0,
			255,
			0,
			true
		)
	end
end

function calculateLevelFromHours(hours)
	local baseHours = 10
	local exponent = 1.5

	local level = 1
	while true do
		local required = math.floor(baseHours * (level ^ exponent))
		if hours < required then
			break
		end
		level = level + 1
	end

	return level
end

function bonusCommand(player, _, inputCode)
	local data = playerBonusCodes[player]
	if not data then
		outputChatBox("[!]#FFFFFF Aktif bir bonus kodunuz yok.", player, 255, 0, 0, true)
		return
	end

	if tostring(inputCode) ~= data.code then
		outputChatBox("[!]#FFFFFF Hatalı kod girdiniz.", player, 255, 0, 0, true)
		return
	end

	local vipLevel = getElementData(player, "vip") or 0
	local rewardAmount = 10000
	exports.mek_global:giveBankMoney(player, rewardAmount)

	outputChatBox(
		"[!]#FFFFFF Saatlik bonus: ₺" .. exports.mek_global:formatMoney(rewardAmount),
		player,
		0,
		255,
		0,
		true
	)
	triggerClientEvent(player, "playSuccess", player)

	triggerClientEvent(player, "payday.stopSound", player)

	if isTimer(data.timer) then
		killTimer(data.timer)
	end
	playerBonusCodes[player] = nil
end
addCommandHandler("bonus", bonusCommand, false, false)

addCommandHandler("kutukalan", function(player)
	local minutes = getElementData(player, "minutes_played") or 0
	local progress = getElementData(player, "box_hours") or 0
	local boxCount = getElementData(player, "box_count") or 0

	outputChatBox(
		"[!]#FFFFFF Kutu için kalan süre: " .. (3 - progress) .. " saat " .. (60 - minutes) .. " dakika",
		player,
		0,
		0,
		255,
		true
	)
	outputChatBox("[!]#FFFFFF Mevcut kutu sayısı: " .. boxCount, player, 0, 0, 255, true)
end, false, false)

addCommandHandler("kutuac", function(player)
	if not isElementWithinColShape(player, giftBoxZone) then
		return
	end

	local boxCount = getElementData(player, "box_count") or 0
	if boxCount <= 0 then
		outputChatBox("[!]#FFFFFF Kutunuz bulunmuyor.", player, 255, 0, 0, true)
		return
	end

	local reward = math.random(50, 2000)
	exports.mek_global:giveMoney(player, reward)

	setElementData(player, "box_count", boxCount - 1)
	dbExec(
		exports.mek_mysql:getConnection(),
		"UPDATE characters SET box_count = ? WHERE id = ?",
		boxCount - 1,
		getElementData(player, "dbid")
	)

	outputChatBox(
		"[!]#FFFFFF Kutudan ₺" .. exports.mek_global:formatMoney(reward) .. " kazandınız!",
		player,
		0,
		255,
		0,
		true
	)
end, false, false)
addCommandHandler("saatver", function(player, cmd, targetID, hoursToAdd)
    local adminLevel = getElementData(player, "admin_level") or 0
    if adminLevel < 6 then
        outputChatBox("[!] #FFFFFFBu komutu kullanma yetkiniz yok.", player, 255, 0, 0, true)
        return
    end
    
    if not targetID or not hoursToAdd or not tonumber(targetID) or not tonumber(hoursToAdd) then
        outputChatBox("[!] #FFFFFFKullanım: /saatver [ID] [Saat]", player, 255, 0, 0, true)
        return
    end
    
    local targetID = tonumber(targetID)
    local hoursToAdd = tonumber(hoursToAdd)
    
    if hoursToAdd <= 0 then
        outputChatBox("[!] #FFFFFFGeçerli bir saat miktarı giriniz (0'dan büyük olmalı).", player, 255, 0, 0, true)
        return
    end
    
    local targetPlayer = nil
    for _, p in ipairs(getElementsByType("player")) do
        if getElementData(p, "logged") and getElementData(p, "id") == targetID then
            targetPlayer = p
            break
        end
    end
    
    if not targetPlayer then
        outputChatBox("[!] #FFFFFFBelirtilen ID'ye sahip oyuncu bulunamadı veya oyunda değil.", player, 255, 0, 0, true)
        return
    end
    
    local characterID = getElementData(targetPlayer, "dbid")
    local characterName = getPlayerName(targetPlayer):gsub("_", " ")
    local accountID = getElementData(targetPlayer, "account_id")
    local currentHours = getElementData(targetPlayer, "hours_played") or 0
    local currentMinutes = getElementData(targetPlayer, "minutes_played") or 0
    local currentTotalHours = getElementData(targetPlayer, "total_hours_played") or 0
    local currentBoxHours = getElementData(targetPlayer, "box_hours") or 0
    
    -- Saati dakikaya çevir ve mevcut dakikaya ekle
    local minutesToAdd = math.floor(hoursToAdd * 60)
    local newMinutes = currentMinutes + minutesToAdd
    
    -- Dakikayı saate çevir (tam saat kısmı)
    local additionalHours = math.floor(newMinutes / 60)
    local remainingMinutes = newMinutes % 60
    
    local newHours = currentHours + additionalHours
    local newTotalHours = currentTotalHours + hoursToAdd
    local newBoxHours = currentBoxHours + additionalHours
    
    -- Element datalarını güncelle
    setElementData(targetPlayer, "minutes_played", remainingMinutes)
    setElementData(targetPlayer, "hours_played", newHours)
    setElementData(targetPlayer, "total_hours_played", newTotalHours)
    setElementData(targetPlayer, "box_hours", newBoxHours)
    
    -- Seviye hesaplama ve güncelleme
    local newLevel = calculateLevelFromHours(newHours)
    local currentLevel = getElementData(targetPlayer, "level") or 1
    
    if newLevel > currentLevel then
        setElementData(targetPlayer, "level", newLevel)
        dbExec(
            exports.mek_mysql:getConnection(),
            "UPDATE characters SET level = ? WHERE id = ?",
            newLevel,
            characterID
        )
        outputChatBox("[!]#FFFFFF Tebrikler! Yeni seviye: " .. newLevel, targetPlayer, 0, 255, 0, true)
    end
    
    -- Veritabanı güncellemeleri
    dbExec(
        exports.mek_mysql:getConnection(),
        "UPDATE characters SET minutes_played = ?, hours_played = ?, box_hours = ? WHERE id = ?",
        remainingMinutes, newHours, newBoxHours, characterID
    )
    
    dbExec(
        exports.mek_mysql:getConnection(),
        "UPDATE accounts SET total_hours_played = ? WHERE id = ?",
        newTotalHours,
        accountID
    )
    
    outputChatBox("[!] #FFFFFF" .. characterName .. " adlı oyuncuya " .. hoursToAdd .. " saat eklendi.", player, 0, 255, 0, true)
    outputChatBox("[!] #FFFFFFBir Yetkili size " .. hoursToAdd .. " saat ekledi. Yeni toplam saat: " .. newHours, targetPlayer, 0, 255, 0, true)
    
    local adminName = exports.mek_global:getPlayerFullAdminTitle(player) or getPlayerName(player):gsub("_", " ")
    local targetAccountName = getElementData(targetPlayer, "account_username") or "Bilinmiyor"
    
    exports.mek_logs:addLog(
        "saat-ver",
        adminName .. " isimli yetkili " ..
        characterName .. " (" .. targetAccountName .. ") isimli oyuncuya " ..
        hoursToAdd .. " saat ekledi. " ..
        "Eski saat: " .. currentHours .. ", Yeni saat: " .. newHours
    )
    
    outputDebugString("[SAATVER] " .. adminName .. " " .. characterName .. " (" .. characterID .. ") adlı oyuncuya " .. hoursToAdd .. " saat ekledi.")
    
    -- Kutu kontrolü
    if newBoxHours >= 4 then
        rewardGiftBoxIfEligible(targetPlayer)
    end
end, false, false)

addCommandHandler("saatal", function(player, cmd, targetID, hoursToRemove)
    local adminLevel = getElementData(player, "admin_level") or 0
    if adminLevel < 8 then
        outputChatBox("[!] #FFFFFFBu komutu kullanma yetkiniz yok.", player, 255, 0, 0, true)
        return
    end
    
    if not targetID or not hoursToRemove or not tonumber(targetID) or not tonumber(hoursToRemove) then
        outputChatBox("[!] #FFFFFFKullanım: /saatal [ID] [Saat]", player, 255, 0, 0, true)
        return
    end
    
    local targetID = tonumber(targetID)
    local hoursToRemove = tonumber(hoursToRemove)
    
    if hoursToRemove <= 0 then
        outputChatBox("[!] #FFFFFFGeçerli bir saat miktarı giriniz (0'dan büyük olmalı).", player, 255, 0, 0, true)
        return
    end
    
    local targetPlayer = nil
    for _, p in ipairs(getElementsByType("player")) do
        if getElementData(p, "logged") and getElementData(p, "id") == targetID then
            targetPlayer = p
            break
        end
    end
    
    if not targetPlayer then
        outputChatBox("[!] #FFFFFFBelirtilen ID'ye sahip oyuncu bulunamadı veya oyunda değil.", player, 255, 0, 0, true)
        return
    end
    
    local characterID = getElementData(targetPlayer, "dbid")
    local characterName = getPlayerName(targetPlayer):gsub("_", " ")
    local accountID = getElementData(targetPlayer, "account_id")
    local currentHours = getElementData(targetPlayer, "hours_played") or 0
    local currentMinutes = getElementData(targetPlayer, "minutes_played") or 0
    local currentTotalHours = getElementData(targetPlayer, "total_hours_played") or 0
    local currentBoxHours = getElementData(targetPlayer, "box_hours") or 0
    local currentLevel = getElementData(targetPlayer, "level") or 1
    
    -- Toplam dakikayı hesapla
    local totalMinutes = (currentHours * 60) + currentMinutes
    local minutesToRemove = math.floor(hoursToRemove * 60)
    
    if totalMinutes < minutesToRemove then
        outputChatBox("[!] #FFFFFFOyuncunun " .. hoursToRemove .. " saatten fazlası yok. Mevcut saat: " .. currentHours, player, 255, 0, 0, true)
        return
    end
    
    -- Yeni dakikayı hesapla
    local newTotalMinutes = totalMinutes - minutesToRemove
    local newHours = math.floor(newTotalMinutes / 60)
    local newMinutes = newTotalMinutes % 60
    local newTotalHours = math.max(0, currentTotalHours - hoursToRemove)
    local newBoxHours = math.max(0, currentBoxHours - math.floor(minutesToRemove / 60))
    
    -- Element datalarını güncelle
    setElementData(targetPlayer, "minutes_played", newMinutes)
    setElementData(targetPlayer, "hours_played", newHours)
    setElementData(targetPlayer, "total_hours_played", newTotalHours)
    setElementData(targetPlayer, "box_hours", newBoxHours)
    
    -- Seviye hesaplama ve güncelleme
    local newLevel = calculateLevelFromHours(newHours)
    
    if newLevel < currentLevel then
        setElementData(targetPlayer, "level", newLevel)
        dbExec(
            exports.mek_mysql:getConnection(),
            "UPDATE characters SET level = ? WHERE id = ?",
            newLevel,
            characterID
        )
        outputChatBox("[!]#FFFFFF Seviyeniz düşürüldü: " .. newLevel, targetPlayer, 255, 0, 0, true)
    end
    
    -- Veritabanı güncellemeleri
    dbExec(
        exports.mek_mysql:getConnection(),
        "UPDATE characters SET minutes_played = ?, hours_played = ?, box_hours = ? WHERE id = ?",
        newMinutes, newHours, newBoxHours, characterID
    )
    
    dbExec(
        exports.mek_mysql:getConnection(),
        "UPDATE accounts SET total_hours_played = ? WHERE id = ?",
        newTotalHours,
        accountID
    )
    
    outputChatBox("[!] #FFFFFF" .. characterName .. " adlı oyuncudan " .. hoursToRemove .. " saat alındı.", player, 0, 255, 0, true)
    outputChatBox("[!] #FFFFFFBir Yetkili sizden " .. hoursToRemove .. " saat aldı. Yeni toplam saat: " .. newHours, targetPlayer, 255, 0, 0, true)
    
    local adminName = exports.mek_global:getPlayerFullAdminTitle(player) or getPlayerName(player):gsub("_", " ")
    local targetAccountName = getElementData(targetPlayer, "account_username") or "Bilinmiyor"
    
    exports.mek_logs:addLog(
        "saat-al",
        adminName .. " isimli yetkili " ..
        characterName .. " (" .. targetAccountName .. ") isimli oyuncudan " ..
        hoursToRemove .. " saat aldı. " ..
        "Eski saat: " .. currentHours .. ", Yeni saat: " .. newHours
    )
    
    outputDebugString("[SAATAL] " .. adminName .. " " .. characterName .. " (" .. characterID .. ") adlı oyuncudan " .. hoursToRemove .. " saat aldı.")
end, false, false)