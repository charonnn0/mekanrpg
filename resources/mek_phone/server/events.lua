local activeCalls = {}

addEvent("phone.startCall", true)
addEventHandler("phone.startCall", root, function(playerPhoneNumber, targetPhoneNumber)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	targetPhoneNumber = tonumber(targetPhoneNumber)
	if not targetPhoneNumber then
		triggerClientEvent(
			source,
			"phone.callRequestError",
			source,
			nil,
			{ code = 0, message = "Geçersiz hedef numara." }
		)
		return
	end

	if activeCalls[playerPhoneNumber] or activeCalls[targetPhoneNumber] then
		triggerClientEvent(
			source,
			"phone.callRequestError",
			source,
			targetPhoneNumber,
			{ code = 2, message = "Numara meşgul." }
		)
		return
	end

	local targetPlayer = getPlayerByPhoneNumber(targetPhoneNumber)
	if not targetPlayer or targetPlayer == source then
		triggerClientEvent(
			source,
			"phone.callRequestError",
			source,
			targetPhoneNumber,
			{ code = 1, message = "Aranan numaraya ulaşılamıyor." }
		)
		if targetPlayer ~= source then
			dbExec(
				exports.mek_mysql:getConnection(),
				"INSERT INTO phone_call_history (caller_number, receiver_number, call_type, created_at) VALUES (?, ?, ?, ?)",
				playerPhoneNumber,
				targetPhoneNumber,
				ContactsCallHistory.Missed,
				getRealTime().timestamp
			)
		end
		return
	end

	local queryHandle = dbQuery(
		exports.mek_mysql:getConnection(),
		"SELECT 1 FROM phone_contacts WHERE phone_number = ? AND target_number = ? AND is_blocked = 1 LIMIT 1",
		targetPhoneNumber,
		playerPhoneNumber
	)
	local result = dbPoll(queryHandle, -1)
	dbFree(queryHandle)

	if result and #result > 0 then
		triggerClientEvent(
			source,
			"phone.callRequestError",
			source,
			targetPhoneNumber,
			{ code = 3, message = "Bu numara sizi engelledi." }
		)
		dbExec(
			exports.mek_mysql:getConnection(),
			"INSERT INTO phone_call_history (caller_number, receiver_number, call_type, created_at) VALUES (?, ?, ?, ?)",
			playerPhoneNumber,
			targetPhoneNumber,
			ContactsCallHistory.Outgoing,
			getRealTime().timestamp
		)
		return
	end

	triggerClientEvent(targetPlayer, "phone.call", targetPlayer, source, playerPhoneNumber, targetPhoneNumber)
	triggerClientEvent(source, "phone.callRequestComplete", source, targetPlayer, targetPhoneNumber)

	dbExec(
		exports.mek_mysql:getConnection(),
		"INSERT INTO phone_call_history (caller_number, receiver_number, call_type, created_at) VALUES (?, ?, ?, ?)",
		playerPhoneNumber,
		targetPhoneNumber,
		ContactsCallHistory.Outgoing,
		getRealTime().timestamp
	)

	if activeCalls[playerPhoneNumber] and isTimer(activeCalls[playerPhoneNumber].timer) then
		killTimer(activeCalls[playerPhoneNumber].timer)
	end

	if activeCalls[targetPhoneNumber] and isTimer(activeCalls[targetPhoneNumber].timer) then
		killTimer(activeCalls[targetPhoneNumber].timer)
	end

	local callTimer = setTimer(function()
		local caller = getPlayerByPhoneNumber(playerPhoneNumber)
		local receiver = getPlayerByPhoneNumber(targetPhoneNumber)

		if caller and receiver then
			triggerClientEvent(caller, "phone.callEnded", caller)
			triggerClientEvent(receiver, "phone.callEnded", receiver)

			caller:removeData("call")
			receiver:removeData("call")
		end

		activeCalls[playerPhoneNumber] = nil
		activeCalls[targetPhoneNumber] = nil
	end, 15000, 1)

	activeCalls[playerPhoneNumber] = {
		targetNumber = targetPhoneNumber,
		timer = callTimer,
	}

	activeCalls[targetPhoneNumber] = {
		targetNumber = playerPhoneNumber,
		timer = callTimer,
	}
end)

addEvent("phone.answerCall", true)
addEventHandler("phone.answerCall", root, function(playerPhoneNumber, targetPhoneNumber, accepted)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	playerPhoneNumber = tonumber(playerPhoneNumber)
	targetPhoneNumber = tonumber(targetPhoneNumber)

	if not playerPhoneNumber or not targetPhoneNumber then
		return
	end

	local targetPlayer = getPlayerByPhoneNumber(targetPhoneNumber)
	if not targetPlayer then
		if accepted then
			triggerClientEvent(source, "phone.showNotification", source, "error", "Çağrı sona erdi.")
		end
		return
	end

	if accepted then
		local callStartTime = getRealTime().timestamp

		source:setData("call", {
			player = targetPlayer,
			number = playerPhoneNumber,
			targetNumber = targetPhoneNumber,
			contactName = nil,
			isSpeakerOn = false,
			isMuted = false,
			callStartTime = callStartTime,
		})
		targetPlayer:setData("call", {
			player = source,
			number = targetPhoneNumber,
			targetNumber = playerPhoneNumber,
			contactName = nil,
			isSpeakerOn = false,
			isMuted = false,
			callStartTime = callStartTime,
		})

		triggerClientEvent(source, "phone.callAnswered", source, targetPlayer, targetPhoneNumber, callStartTime)
		triggerClientEvent(targetPlayer, "phone.callAnswered", targetPlayer, source, playerPhoneNumber, callStartTime)

		dbExec(
			exports.mek_mysql:getConnection(),
			[[
                UPDATE phone_call_history 
                SET call_type = ?, in_call_time = ?
                WHERE (caller_number = ? AND receiver_number = ?) OR (receiver_number = ? AND caller_number = ?)
                ORDER BY id DESC LIMIT 2
            ]],
			ContactsCallHistory.InCall,
			callStartTime,
			playerPhoneNumber,
			targetPhoneNumber,
			playerPhoneNumber,
			targetPhoneNumber
		)
	else
		source:removeData("call")
		if isElement(targetPlayer) then
			targetPlayer:removeData("call")
		end

		if activeCalls[playerPhoneNumber] then
			triggerClientEvent(source, "phone.callEnded", source)
		end

		if activeCalls[targetPhoneNumber] then
			if isElement(targetPlayer) then
				triggerClientEvent(targetPlayer, "phone.callEnded", targetPlayer)
			end
		end

		dbExec(
			exports.mek_mysql:getConnection(),
			[[
				UPDATE phone_call_history 
				SET call_type = ? 
				WHERE (receiver_number = ? AND caller_number = ? AND call_type = 'Incoming')
				ORDER BY id DESC LIMIT 1
			]],
			ContactsCallHistory.Missed,
			playerPhoneNumber,
			targetPhoneNumber
		)
		dbExec(
			exports.mek_mysql:getConnection(),
			[[
				UPDATE phone_call_history 
				SET call_type = ? 
				WHERE (caller_number = ? AND receiver_number = ? AND call_type = 'Outgoing')
				ORDER BY id DESC LIMIT 1
			]],
			ContactsCallHistory.Missed,
			playerPhoneNumber,
			targetPhoneNumber
		)
	end

	if activeCalls[targetPhoneNumber] then
		if isTimer(activeCalls[targetPhoneNumber].timer) then
			killTimer(activeCalls[targetPhoneNumber].timer)
		end
		activeCalls[targetPhoneNumber] = nil
	end

	if activeCalls[playerPhoneNumber] then
		if isTimer(activeCalls[playerPhoneNumber].timer) then
			killTimer(activeCalls[playerPhoneNumber].timer)
		end
		activeCalls[playerPhoneNumber] = nil
	end
end)

addEvent("phone.endCall", true)
addEventHandler("phone.endCall", root, function(playerPhoneNumber, targetPhoneNumber)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	playerPhoneNumber = tonumber(playerPhoneNumber)
	targetPhoneNumber = tonumber(targetPhoneNumber)

	if not playerPhoneNumber or not targetPhoneNumber then
		return
	end

	local targetPlayer = getPlayerByPhoneNumber(targetPhoneNumber)
	if not isElement(targetPlayer) then
		targetPlayer = nil
	end

	source:removeData("call")
	if targetPlayer then
		targetPlayer:removeData("call")
	end

	triggerClientEvent(source, "phone.callEnded", source)
	if targetPlayer then
		triggerClientEvent(targetPlayer, "phone.callEnded", targetPlayer)
	end

	local callEndTime = getRealTime().timestamp

	dbExec(
		exports.mek_mysql:getConnection(),
		[[
			UPDATE phone_call_history 
			SET call_type = ?, in_call_time = ?
			WHERE (caller_number = ? AND receiver_number = ?) OR (receiver_number = ? AND caller_number = ?)
			ORDER BY id DESC LIMIT 2
		]],
		ContactsCallHistory.InCall,
		callEndTime,
		playerPhoneNumber,
		targetPhoneNumber,
		playerPhoneNumber,
		targetPhoneNumber
	)
end)

addEvent("phone.toggleSpeaker", true)
addEventHandler("phone.toggleSpeaker", root, function(phoneNumber, state)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	local callData = source:getData("call")
	if not callData then
		return
	end

	callData.isSpeakerOn = state
	source:setData("call", callData, false)
end)

addEvent("phone.toggleMute", true)
addEventHandler("phone.toggleMute", root, function(phoneNumber, state)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	local callData = source:getData("call")
	if not callData then
		return
	end

	callData.isMuted = state
	source:setData("call", callData, false)
end)

addEvent("phone.contacts.add", true)
addEventHandler("phone.contacts.add", root, function(playerPhoneNumber, name, number)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	local queryHandle = dbQuery(
		exports.mek_mysql:getConnection(),
		"SELECT * FROM phone_contacts WHERE phone_number = ? AND target_number = ?",
		playerPhoneNumber,
		number
	)
	local result = dbPoll(queryHandle, -1)
	dbFree(queryHandle)

	if result and #result > 0 then
		triggerClientEvent(
			source,
			"phone.contacts.onAddContact",
			source,
			{ success = false, message = "Bu numara zaten rehberinizde kayıtlı." }
		)
	else
		local querySuccess = dbExec(
			exports.mek_mysql:getConnection(),
			"INSERT INTO phone_contacts (phone_number, name, target_number, is_favorite, is_blocked) VALUES (?, ?, ?, 0, 0)",
			playerPhoneNumber,
			name,
			number
		)
		if querySuccess then
			triggerClientEvent(
				source,
				"phone.contacts.onAddContact",
				source,
				{ success = true, message = "Kişi başarıyla eklendi." }
			)
		else
			triggerClientEvent(
				source,
				"phone.contacts.onAddContact",
				source,
				{ success = false, message = "Kişi eklenirken bir hata oluştu." }
			)
		end
	end
end)

addEvent("phone.contacts.edit", true)
addEventHandler("phone.contacts.edit", root, function(playerPhoneNumber, contactID, name, number)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	local querySuccess = dbExec(
		exports.mek_mysql:getConnection(),
		"UPDATE phone_contacts SET name = ?, target_number = ? WHERE id = ? AND phone_number = ?",
		name,
		number,
		contactID,
		playerPhoneNumber
	)
	if querySuccess then
		triggerClientEvent(
			source,
			"phone.contacts.onEditContact",
			source,
			{ success = true, message = "Kişi başarıyla güncellendi." }
		)
	else
		triggerClientEvent(
			source,
			"phone.contacts.onEditContact",
			source,
			{ success = false, message = "Kişi güncellenirken bir hata oluştu." }
		)
	end
end)

addEvent("phone.contacts.delete", true)
addEventHandler("phone.contacts.delete", root, function(playerPhoneNumber, contactID)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	local querySuccess = dbExec(
		exports.mek_mysql:getConnection(),
		"DELETE FROM phone_contacts WHERE id = ? AND phone_number = ?",
		contactID,
		playerPhoneNumber
	)
	if querySuccess then
		triggerClientEvent(
			source,
			"phone.contacts.onDeleteContact",
			source,
			{ success = true, message = "Kişi başarıyla silindi." }
		)
	else
		triggerClientEvent(
			source,
			"phone.contacts.onDeleteContact",
			source,
			{ success = false, message = "Kişi silinirken bir hata oluştu." }
		)
	end
end)

addEvent("phone.contacts.updateBlock", true)
addEventHandler("phone.contacts.updateBlock", root, function(contactID, isBlocked)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	dbExec(
		exports.mek_mysql:getConnection(),
		"UPDATE phone_contacts SET is_blocked = ? WHERE id = ?",
		isBlocked == ContactsIsBlocked.Yes and 1 or 0,
		contactID
	)
end)

addEvent("phone.contacts.updateFavorite", true)
addEventHandler("phone.contacts.updateFavorite", root, function(contactID, isFavorite)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	dbExec(
		exports.mek_mysql:getConnection(),
		"UPDATE phone_contacts SET is_favorite = ? WHERE id = ?",
		isFavorite == ContactsIsFavorite.Yes and 1 or 0,
		contactID
	)
end)

addEvent("phone.contacts.get", true)
addEventHandler("phone.contacts.get", root, function(playerPhoneNumber, options)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	local offset = options.offset or 0
	local limit = options.limit or 10

	local queryHandleContacts = dbQuery(
		exports.mek_mysql:getConnection(),
		"SELECT * FROM phone_contacts WHERE phone_number = ? LIMIT ?, ?",
		playerPhoneNumber,
		offset,
		limit
	)
	local contacts = dbPoll(queryHandleContacts, -1)
	dbFree(queryHandleContacts)

	local queryHandleCount = dbQuery(
		exports.mek_mysql:getConnection(),
		"SELECT COUNT(*) as totalCount FROM phone_contacts WHERE phone_number = ?",
		playerPhoneNumber
	)
	local countResult = dbPoll(queryHandleCount, -1)
	dbFree(queryHandleCount)

	local totalCount = countResult and countResult[1] and countResult[1].totalCount or 0
	triggerClientEvent(source, "phone.contacts.onGetContacts", source, offset, limit, contacts, totalCount)
end)

addEvent("phone.contacts.getHistory", true)
addEventHandler("phone.contacts.getHistory", root, function(playerPhoneNumber, options)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	local offset = options.offset or 0
	local limit = options.limit or 10

	local queryHandleHistory = dbQuery(
		exports.mek_mysql:getConnection(),
		"SELECT * FROM phone_call_history WHERE caller_number = ? OR receiver_number = ? ORDER BY created_at DESC LIMIT ?, ?",
		playerPhoneNumber,
		playerPhoneNumber,
		offset,
		limit
	)
	local history = dbPoll(queryHandleHistory, -1)
	dbFree(queryHandleHistory)

	local queryHandleCount = dbQuery(
		exports.mek_mysql:getConnection(),
		"SELECT COUNT(*) as totalCount FROM phone_call_history WHERE caller_number = ? OR receiver_number = ?",
		playerPhoneNumber,
		playerPhoneNumber
	)
	local countResult = dbPoll(queryHandleCount, -1)
	dbFree(queryHandleCount)

	local totalCount = countResult and countResult[1] and countResult[1].totalCount or 0
	triggerClientEvent(source, "phone.contacts.onGetHistory", source, offset, limit, history, totalCount)
end)

addEvent("phone.gallery.add", true)
addEventHandler("phone.gallery.add", root, function(phoneNumber, photoData)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not photoData then
		return
	end

	local posX, posY, posZ = getElementPosition(source)
	local exifLocation = toJSON({ x = posX, y = posY, z = posZ })

	local result = dbExec(
		exports.mek_mysql:getConnection(),
		[[
			INSERT INTO phone_gallery
			(phone_number, photo_id, size_width, size_height, exif_date, exif_location)
			VALUES (?, ?, ?, ?, NOW(), ?)
		]],
		phoneNumber,
		photoData.id,
		photoData.width,
		photoData.height,
		exifLocation
	)

	if result then
		triggerClientEvent(source, "phone.gallery.onProcessComplete", source)
	end
end)

addEvent("phone.gallery.getPhotos", true)
addEventHandler("phone.gallery.getPhotos", root, function(phoneNumber, params)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not params then
		return
	end

	local offset = params.offset or 0
	local limit = params.limit or 10

	local countQuery = "SELECT COUNT(*) as total_count FROM phone_gallery WHERE phone_number = ?"
	local countResult = dbQuery(exports.mek_mysql:getConnection(), countQuery, phoneNumber)
	local totalPhotos = 0

	local countFetch = dbPoll(countResult, -1)
	if countFetch and countFetch[1] then
		totalPhotos = countFetch[1].total_count
	end
	dbFree(countResult)

	local photoResult = dbQuery(
		exports.mek_mysql:getConnection(),
		[[
			SELECT id, photo_id, size_width, size_height, exif_date, exif_location
			FROM phone_gallery
			WHERE phone_number = ?
			ORDER BY id DESC
			LIMIT ? OFFSET ?
		]],
		phoneNumber,
		limit,
		offset
	)
	local photoRows = dbPoll(photoResult, -1)
	dbFree(photoResult)

	local photosToSend = {}
	if photoRows then
		for _, row in ipairs(photoRows) do
			table.insert(photosToSend, {
				id = row.id,
				photoID = row.photo_id,
				sizeWidth = row.size_width,
				sizeHeight = row.size_height,
				exifDate = row.exif_date,
				exifLocation = row.exif_location,
			})
		end
	end

	triggerClientEvent(
		source,
		"phone.gallery.onGetPhotos",
		source,
		offset,
		offset + #photosToSend,
		photosToSend,
		totalPhotos
	)
end)

addEvent("phone.gallery.deletePhoto", true)
addEventHandler("phone.gallery.deletePhoto", root, function(phoneNumber, photoID)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	local queryHandle = "DELETE FROM phone_gallery WHERE phone_number = ? AND id = ?"
	local result = dbExec(exports.mek_mysql:getConnection(), queryHandle, phoneNumber, photoID)

	if result then
		triggerClientEvent(source, "phone.gallery.onDeletePhoto", source)
	end
end)

-- Twitter: ensure table on resource start
addEventHandler("onResourceStart", resourceRoot, function()
    dbExec(
        exports.mek_mysql:getConnection(),
        [[
            CREATE TABLE IF NOT EXISTS `twitteracc` (
                `id` INT NOT NULL AUTO_INCREMENT,
                `phone_number` BIGINT NOT NULL UNIQUE,
                `full_name` VARCHAR(64) NOT NULL,
                `created_at` INT NOT NULL,
                `last_tweet_at` INT NULL,
                PRIMARY KEY (`id`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
        ]]
    )

	dbExec(
		exports.mek_mysql:getConnection(),
		[[
			CREATE TABLE IF NOT EXISTS `phone_gallery` (
				`id` INT NOT NULL AUTO_INCREMENT,
				`phone_number` BIGINT NOT NULL,
				`photo_id` VARCHAR(255) NOT NULL,
				`size_width` INT NOT NULL,
				`size_height` INT NOT NULL,
				`exif_date` DATETIME NOT NULL,
				`exif_location` TEXT,
				PRIMARY KEY (`id`)
			) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
		]]
	)
end)

-- Twitter: ensure account (auto-login by phone number)
addEvent("twitter.ensureAccount", true)
addEventHandler("twitter.ensureAccount", root, function(phoneNumber)
    if client and source and client ~= source then
        exports.mek_sac:banForEventAbuse(client, eventName)
        return
    end

    if not phoneNumber then
        triggerClientEvent(source, "twitter.onEnsureAccount", source, { success = false, exists = false, message = "Geçersiz numara." })
        return
    end

    local qh = dbQuery(
        exports.mek_mysql:getConnection(),
        "SELECT phone_number, full_name, last_tweet_at FROM twitteracc WHERE phone_number = ? LIMIT 1",
        phoneNumber
    )
    local rows = dbPoll(qh, -1)
    dbFree(qh)

    if rows and #rows > 0 then
        triggerClientEvent(source, "twitter.onEnsureAccount", source, { success = true, exists = true, account = { phoneNumber = rows[1].phone_number, fullName = rows[1].full_name, lastTweetAt = rows[1].last_tweet_at } })
    else
        triggerClientEvent(source, "twitter.onEnsureAccount", source, { success = true, exists = false })
    end
end)

-- Twitter: create account by phone number and full name
addEvent("twitter.createAccount", true)
addEventHandler("twitter.createAccount", root, function(phoneNumber, fullName)
    if client and source and client ~= source then
        exports.mek_sac:banForEventAbuse(client, eventName)
        return
    end

    if not phoneNumber or not fullName or type(fullName) ~= "string" then
        triggerClientEvent(source, "twitter.onCreateAccount", source, { success = false, message = "Eksik bilgiler." })
        return
    end

    fullName = fullName:gsub("^%s+", ""):gsub("%s+$", "")
    if #fullName < 3 or #fullName > 64 then
        triggerClientEvent(source, "twitter.onCreateAccount", source, { success = false, message = "İsim 3-64 karakter olmalıdır." })
        return
    end

    local nowTs = getRealTime().timestamp

    local insertOk = dbExec(
        exports.mek_mysql:getConnection(),
        "INSERT IGNORE INTO twitteracc (phone_number, full_name, created_at, last_tweet_at) VALUES (?, ?, ?, NULL)",
        phoneNumber,
        fullName,
        nowTs
    )

    if insertOk then
        triggerClientEvent(source, "twitter.onCreateAccount", source, { success = true, account = { phoneNumber = phoneNumber, fullName = fullName, lastTweetAt = false } })
    else
        triggerClientEvent(source, "twitter.onCreateAccount", source, { success = false, message = "Hesap oluşturulamadı. Zaten mevcut olabilir." })
    end
end)

-- Twitter: tweet with 5-minute rate limit
addEvent("twitter.tweet", true)
addEventHandler("twitter.tweet", root, function(phoneNumber, message)
    if client and source and client ~= source then
        exports.mek_sac:banForEventAbuse(client, eventName)
        return
    end

    if not phoneNumber or not message or type(message) ~= "string" then
        triggerClientEvent(source, "twitter.onTweetResult", source, { success = false, message = "Geçersiz veri." })
        return
    end

    message = message:gsub("^%s+", ""):gsub("%s+$", "")
    if #message < 1 or #message > 200 then
        triggerClientEvent(source, "twitter.onTweetResult", source, { success = false, message = "Mesaj 1-200 karakter olmalıdır." })
        return
    end

    local qh = dbQuery(
        exports.mek_mysql:getConnection(),
        "SELECT full_name, last_tweet_at FROM twitteracc WHERE phone_number = ? LIMIT 1",
        phoneNumber
    )
    local rows = dbPoll(qh, -1)
    dbFree(qh)

    if not rows or #rows == 0 then
        triggerClientEvent(source, "twitter.onTweetResult", source, { success = false, message = "Önce bir Twitter hesabı oluşturun." })
        return
    end

    local fullName = rows[1].full_name
    local lastTweetAt = rows[1].last_tweet_at or 0
    local nowTs = getRealTime().timestamp
    local rateLimitSeconds = 300

    if lastTweetAt and (nowTs - lastTweetAt) < rateLimitSeconds then
        local remaining = rateLimitSeconds - (nowTs - lastTweetAt)
        triggerClientEvent(source, "twitter.onTweetResult", source, { success = false, code = "rate_limit", remaining = remaining, message = "Tekrar tweet atmak için bekleyin." })
        return
    end

    dbExec(
        exports.mek_mysql:getConnection(),
        "UPDATE twitteracc SET last_tweet_at = ? WHERE phone_number = ?",
        nowTs,
        phoneNumber
    )

    local blueHex = "#3b82f6" -- Tailwind blue-500
    local whiteHex = "#FFFFFF"
    local formatted = string.format("%s[Twitter]%s (%s) %s", blueHex, whiteHex, fullName, message)

    outputChatBox(formatted, root, 255, 255, 255, true)

    triggerClientEvent(source, "twitter.onTweetResult", source, { success = true, message = "Tweet gönderildi.", nowTs = nowTs })
end)

addEventHandler("onPlayerQuit", root, function()
	local player = source
	local callData = player:getData("call")

	if callData then
		local targetPlayer = callData.player
		local playerNumber = callData.number
		local targetNumber = callData.targetNumber

		player:removeData("call")
		if isElement(targetPlayer) then
			targetPlayer:removeData("call")
			triggerClientEvent(targetPlayer, "phone.callEnded", targetPlayer)
		end

		if activeCalls[playerNumber] then
			if isTimer(activeCalls[playerNumber].timer) then
				killTimer(activeCalls[playerNumber].timer)
			end
			activeCalls[playerNumber] = nil
		end

		if activeCalls[targetNumber] then
			if isTimer(activeCalls[targetNumber].timer) then
				killTimer(activeCalls[targetNumber].timer)
			end
			activeCalls[targetNumber] = nil
		end
	end
end)

-- Banka: Havale - sohbet mesajı gönderimi ve UI yükleme durumunu temizleme
addEvent("bank.transferMoney", true)
addEventHandler("bank.transferMoney", root, function(payload)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if type(payload) ~= "table" then
		triggerClientEvent(source, "phone.showNotification", source, "error", "Geçersiz istek.")
		return
	end

	local targetName = tostring(payload.targetEntity or ""):gsub("^%s+", ""):gsub("%s+$", "")
	local amount = tonumber(payload.amount)
	if not targetName or targetName == "" or not amount or amount <= 0 then
		triggerClientEvent(source, "phone.showNotification", source, "error", "Alıcı ve tutar geçerli olmalıdır.")
		triggerClientEvent(source, "bank.removeLoading", source)
		return
	end

	local function stripCodes(name)
		-- MTA renk kodlarını ve köşeli parantez içi etiketleri temizle
		name = name:gsub("#%x%x%x%x%x%x", "")
		name = name:gsub("%b[]", ""):gsub("%s+", " ")
		return name
	end

	local function findPlayerByFullName(fullName)
		fullName = stripCodes(fullName):lower()
		for _, p in ipairs(getElementsByType("player")) do
			local pn = stripCodes(getPlayerName(p)):lower()
			if pn == fullName then
				return p
			end
		end
		return nil
	end

	local targetPlayer = findPlayerByFullName(targetName)
	if not isElement(targetPlayer) or targetPlayer == source then
		triggerClientEvent(source, "phone.showNotification", source, "error", "Alıcı bulunamadı.")
		triggerClientEvent(source, "bank.removeLoading", source)
		return
	end

	-- Burada gerçek para transferi başka bir resource tarafından yapılmalıdır.
	-- Bu resource içinde sadece bilgilendirici sohbet mesajları gönderiyoruz.
	local green = "#22c55e" -- Tailwind green-500
	local white = "#FFFFFF"

	local senderName = stripCodes(getPlayerName(source))
	local receiverName = stripCodes(getPlayerName(targetPlayer))

	-- Gönderene bildirim
	outputChatBox(string.format("%s[Banka]%s %s adlı kişiye ₺%s gönderdiniz.", green, white, receiverName, exports.mek_global and exports.mek_global:formatMoney(amount) or tostring(amount)), source, 255, 255, 255, true)

	-- Alıcıya bildirim
	outputChatBox(string.format("%s[Banka]%s %s adlı kişiden ₺%s aldınız.", green, white, senderName, exports.mek_global and exports.mek_global:formatMoney(amount) or tostring(amount)), targetPlayer, 255, 255, 255, true)

	-- Telefon UI yükleme durumunu kapat
	triggerClientEvent(source, "bank.removeLoading", source)
end)

-- Banka: Geçmiş (şimdilik boş dizi dön)
addEvent("bank.getHistory", true)
addEventHandler("bank.getHistory", root, function()
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	triggerClientEvent(source, "bank.sendHistory", source, {})
end)
