local mysql = exports.mek_mysql
vips = {}

addEventHandler("onResourceStart", resourceRoot, function()
	dbQuery(function(queryHandle)
		local res, rows, err = dbPoll(queryHandle, 0)
		if rows > 0 then
			for index, row in ipairs(res) do
				loadVip(row.char_id)
			end
		end
	end, mysql:getConnection(), "SELECT `char_id` FROM `vips`")
end)

addEventHandler("onResourceStop", resourceRoot, function()
	for _, player in pairs(getElementsByType("player")) do
		local charID = tonumber(getElementData(player, "dbid"))
		if charID then
			saveVip(charID)
		end
	end
end)

addEventHandler("onPlayerQuit", root, function()
	local charID = getElementData(source, "dbid")
	if not charID then
		return false
	end
	saveVip(charID)
end)

function loadVip(charID)
	local charID = tonumber(charID)
	if not charID then
		return false
	end

	dbQuery(function(queryHandle)
		local res, rows, err = dbPoll(queryHandle, 0)
		if rows > 0 then
			for index, row in ipairs(res) do
				local vipType = tonumber(row["vip_type"]) or 0
				local endTick = tonumber(row["vip_end_tick"]) or 0
				if vipType > 0 then
					vips[charID] = {}
					vips[charID].type = vipType
					vips[charID].endTick = endTick
					local targetPlayer = exports.mek_global:getPlayerFromCharacterID(charID)
					if targetPlayer then
						setElementData(targetPlayer, "vip", vipType)
					end
				else
					setElementData(targetPlayer, "vip", 0)
				end
			end
		end
	end, mysql:getConnection(), "SELECT `vip_type`, `vip_end_tick` FROM `vips` WHERE `char_id` = ?", charID)
end

function addVip(targetPlayer, vipRank, days)
	if targetPlayer and vipRank and days then
		local charID = tonumber(getElementData(targetPlayer, "dbid"))
		if not charID then
			return false
		end

		local endTick = math.max(days, 1) * 24 * 60 * 60 * 1000
		if not isPlayerVip(charID) then
			local id = exports.mek_mysql:getSmallestID("vips")
			dbExec(
				mysql:getConnection(),
				"INSERT INTO `vips` (`id`, `char_id`, `vip_type`, `vip_end_tick`) VALUES (?, ?, ?, ?)",
				id,
				charID,
				vipRank,
				endTick
			)
			loadVip(charID)
		else
			dbExec(
				mysql:getConnection(),
				"UPDATE `vips` SET vip_end_tick = vip_end_tick + ? WHERE char_id = ? and vip_type = ? LIMIT 1",
				endTick,
				charID,
				vipRank
			)
			loadVip(charID)
		end
	end
end

function saveVip(charID)
	local charID = tonumber(charID)
	if not charID then
		return false
	end
	if not vips[charID] then
		return false
	end
	dbExec(
		mysql:getConnection(),
		"UPDATE `vips` SET `vip_end_tick` = ? WHERE `char_id` = ? LIMIT 1",
		vips[charID].endTick,
		charID
	)
end

function removeVip(charID)
	if not vips[charID] then
		return false
	end
	local query = dbExec(mysql:getConnection(), "DELETE FROM `vips` WHERE `char_id` = ? LIMIT 1", charID)
	if query then
		local targetPlayer = exports.mek_global:getPlayerFromCharacterID(charID)
		if targetPlayer then
			setElementData(targetPlayer, "vip", 0)
			outputChatBox("[!]#FFFFFF Vip üyeliğinizin süresi doldu.", targetPlayer, 0, 0, 255, true)
		end
		vips[charID] = nil
		return true
	end
	return false
end

function getVipExpireTime(charID)
	if charID and tonumber(charID) then
		charID = tonumber(charID)
		if vips[charID] then
			local vipType = vips[charID].type
			local remaining = vips[charID].endTick
			local remainingInfo = exports.mek_datetime:secondsToTimeDesc(remaining / 1000)
			return remainingInfo
		end
	end
	return false
end

function checkExpireTime()
	for charID, data in pairs(vips) do
		if charID and data then
			if vips[charID] then
				if vips[charID].endTick and vips[charID].endTick <= 0 then
					removeVip(charID)
				elseif vips[charID].endTick and vips[charID].endTick > 0 then
					vips[charID].endTick = math.max(vips[charID].endTick - (60 * 1000), 0)
					saveVip(charID)

					if vips[charID].endTick == 0 then
						removeVip(charID)
					end
				end
			end
		end
	end
end
setTimer(checkExpireTime, 60 * 1000, 0)
