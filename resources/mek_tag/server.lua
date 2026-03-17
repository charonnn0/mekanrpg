function addTag(playerOrCharacterID, tagID, days)
	local characterID = tonumber(playerOrCharacterID)
	if type(playerOrCharacterID) == "userdata" then
		characterID = getElementData(playerOrCharacterID, "dbid") or 0
	end

	if not characterID then
		return false
	end

	dbQuery(function(queryHandle)
		local result = dbPoll(queryHandle, 0)
		if result and #result > 0 then
			local tags = fromJSON(result[1].tags or "") or {}
			local tagExists = false

			for _, tag in ipairs(tags) do
				if tag.id == tagID then
					tag.expiry_time = tag.expiry_time + (days * 86400)
					tagExists = true
					break
				end
			end

			if not tagExists then
				table.insert(tags, {
					id = tagID,
					expiry_time = getRealTime().timestamp + (days * 86400),
				})
			end

			if type(playerOrCharacterID) == "userdata" then
				setElementData(playerOrCharacterID, "tags", tags)
			end

			dbExec(
				exports.mek_mysql:getConnection(),
				"UPDATE characters SET tags = ? WHERE id = ?",
				toJSON(tags),
				characterID
			)
		end
	end, exports.mek_mysql:getConnection(), "SELECT tags FROM characters WHERE id = ?", characterID)
end

function removeTag(playerOrCharacterID, tagID)
	local characterID = tonumber(playerOrCharacterID)
	if type(playerOrCharacterID) == "userdata" then
		characterID = getElementData(playerOrCharacterID, "dbid") or 0
	end

	if not characterID then
		return false
	end

	dbQuery(function(queryHandle)
		local result = dbPoll(queryHandle, 0)
		if result and #result > 0 then
			local tags = fromJSON(result[1].tags) or {}
			for i, tag in ipairs(tags) do
				if tag.id == tagID then
					table.remove(tags, i)
					break
				end
			end

			if type(playerOrCharacterID) == "userdata" then
				setElementData(playerOrCharacterID, "tags", tags)
			end

			dbExec(
				exports.mek_mysql:getConnection(),
				"UPDATE characters SET tags = ? WHERE id = ?",
				toJSON(tags),
				characterID
			)
		end
	end, exports.mek_mysql:getConnection(), "SELECT tags FROM characters WHERE id = ?", characterID)
end

function updateTags()
	dbQuery(function(queryHandle)
		local result = dbPoll(queryHandle, 0)
		if result and #result > 0 then
			for _, row in ipairs(result) do
				local tags = (fromJSON(row.tags or "")) or {}
				local updatedTags = {}
				local currentTime = getRealTime().timestamp
				local changed = false

				for _, tag in ipairs(tags) do
					if tag.expiry_time > currentTime then
						table.insert(updatedTags, tag)
					else
						changed = true
						for _, player in ipairs(getElementsByType("player")) do
							if getElementData(player, "dbid") == row.id then
								outputChatBox(
									"[!]#FFFFFF [" .. tag.id .. "] ID'li etiketinizin süresi doldu.",
									player,
									0,
									0,
									255,
									true
								)
							end
						end
					end
				end

				if changed then
					dbExec(
						exports.mek_mysql:getConnection(),
						"UPDATE characters SET tags = ? WHERE id = ?",
						toJSON(updatedTags),
						row.id
					)
				end
			end
		end
	end, exports.mek_mysql:getConnection(), "SELECT id, tags FROM characters")
end
setTimer(updateTags, 60000, 0)

function tagsCommand(thePlayer, commandName, targetPlayer)
	if targetPlayer then
		local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
		if targetPlayer then
			if exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
				local tags = getElementData(targetPlayer, "tags") or {}
				if #tags > 0 then
					outputChatBox(
						"[!]#FFFFFF " .. targetPlayerName .. " isimli oyuncunun etiketleri:",
						thePlayer,
						0,
						0,
						255,
						true
					)
					for _, tag in pairs(tags) do
						local tagID = tag.id
						local expiryTime = tag.expiry_time
						local currentTime = getRealTime().timestamp
						local remainingTime = expiryTime - currentTime

						local days = math.floor(remainingTime / 86400)
						local hours = math.floor((remainingTime % 86400) / 3600)
						local minutes = math.floor((remainingTime % 3600) / 60)
						local seconds = remainingTime % 60

						if expiryTime > currentTime then
							outputChatBox(
								"[!]#FFFFFF Etiket ID: "
									.. tagID
									.. " - Süre: "
									.. days
									.. " gün "
									.. hours
									.. " saat "
									.. minutes
									.. " dakika "
									.. seconds
									.. " saniye",
								thePlayer,
								0,
								255,
								0,
								true
							)
						else
							outputChatBox(
								"[!]#FFFFFF Etiket ID: " .. tagID .. " - Süresi dolmuş.",
								thePlayer,
								255,
								0,
								0,
								true
							)
						end
					end
				else
					outputChatBox(
						"[!]#FFFFFF " .. targetPlayerName .. " isimli oyuncunun hiç etiketi yok.",
						thePlayer,
						255,
						0,
						0,
						true
					)
				end
			else
				outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
			end
			return
		end
	end

	local tags = getElementData(thePlayer, "tags") or {}
	if #tags > 0 then
		outputChatBox("[!]#FFFFFF Etiketleriniz:", thePlayer, 0, 0, 255, true)

		for _, tag in pairs(tags) do
			local tagID = tag.id
			local expiryTime = tag.expiry_time
			local currentTime = getRealTime().timestamp
			local remainingTime = expiryTime - currentTime

			local days = math.floor(remainingTime / 86400)
			local hours = math.floor((remainingTime % 86400) / 3600)
			local minutes = math.floor((remainingTime % 3600) / 60)
			local seconds = remainingTime % 60

			if expiryTime > currentTime then
				outputChatBox(
					"[!]#FFFFFF Etiket ID: "
						.. tagID
						.. " - Süre: "
						.. days
						.. " gün "
						.. hours
						.. " saat "
						.. minutes
						.. " dakika "
						.. seconds
						.. " saniye",
					thePlayer,
					0,
					255,
					0,
					true
				)
			else
				outputChatBox("[!]#FFFFFF Etiket ID: " .. tagID .. " - Süresi dolmuş.", thePlayer, 255, 0, 0, true)
			end
		end
	else
		outputChatBox("[!]#FFFFFF Hiç etiketiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("etiketler", tagsCommand, false, false)
