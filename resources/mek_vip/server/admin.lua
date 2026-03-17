local mysql = exports.mek_mysql

function vipVer(thePlayer, commandName, targetPlayer, vipID, day)
	if exports.mek_integration:isPlayerServerManager(thePlayer) then
		if
			not targetPlayer
			or not tonumber(vipID)
			or not tonumber(day)
			or (tonumber(vipID) < 1 or tonumber(vipID) > 4)
		then
			outputChatBox(
				"Kullanım: /" .. commandName .. " [Karakter Adı / ID] [1-4] [Gün]", 
				thePlayer,
				255,
				194,
				14
			)
		else
			vipID = math.floor(tonumber(vipID))
			day = math.floor(tonumber(day))
			local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
			if targetPlayer then
				if getElementData(targetPlayer, "logged") then
					local charID = getElementData(targetPlayer, "dbid")
					local endTick = math.max(day, 1) * 24 * 60 * 60 * 1000
					local vipName = getVipName(vipID) or "VIP " .. vipID

					if not isPlayerVip(charID) then
						local id = exports.mek_mysql:getSmallestID("vips")

						dbExec(
							mysql:getConnection(),
							"INSERT INTO `vips` (`id`, `char_id`, `vip_type`, `vip_end_tick`) VALUES (?, ?, ?, ?)",
							id,
							charID,
							vipID,
							endTick
						)

						outputChatBox(
							"[!]#FFFFFF "
								.. targetPlayerName
								.. " isimli oyuncuya "
								.. day
								.. " günlük "
								.. vipName
								.. " verildi.",
							thePlayer,
							0,
							255,
							0,
							true
						)
						outputChatBox(
							"[!]#FFFFFF "
								.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili size "
								.. day
								.. " günlük "
								.. vipName
								.. " verdi.",
							targetPlayer,
							0,
							255,
							0,
							true
						)
						exports.mek_logs:addLog(
							"vip",
							exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili "
								.. targetPlayerName
								.. " isimli oyuncuya "
								.. day
								.. " günlük "
								.. vipName
								.. " verdi."
						)

						loadVip(charID)
					else
						local currentVipID = getElementData(targetPlayer, "vip") or 0
						if vipID ~= currentVipID then
							outputChatBox(
								"[!]#FFFFFF Bu oyuncu zaten " .. getVipName(currentVipID) or ("VIP " .. currentVipID) .. " üyeliğine sahip. Farklı bir VIP seviyesi veremezsiniz.",
								thePlayer,
								255,
								0,
								0,
								true
							)
							return
						end

						dbExec(
							mysql:getConnection(),
							"UPDATE `vips` SET vip_end_tick = vip_end_tick + ? WHERE char_id = ? and vip_type = ? LIMIT 1",
							endTick,
							charID,
							vipID
						)

						outputChatBox(
							"[!]#FFFFFF "
								.. targetPlayerName
								.. " isimli oyuncunun "
								.. vipName
								.. " süresine "
								.. day
								.. " gün ilave edildi.",
							thePlayer,
							0,
							255,
							0,
							true
						)
						outputChatBox(
							"[!]#FFFFFF "
								.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili "
								.. vipName
								.. " sürenizi "
								.. day
								.. " gün uzatdı.",
							targetPlayer,
							0,
							255,
							0,
							true
						)
						exports.mek_logs:addLog(
							"vip",
							exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili "
								.. targetPlayerName
								.. " isimli oyuncunun "
								.. vipName
								.. " süreni "
								.. day
								.. " gün uzatdı."
						)

						loadVip(charID)
					end
				else
					outputChatBox(
						"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
						thePlayer,
						255,
						0,
						0,
						true
					)
				end
			end
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("vipver", vipVer, false, false)

function vipAl(thePlayer, commandName, targetPlayer)
	if exports.mek_integration:isPlayerServerManager(thePlayer) then
		if not targetPlayer then
			outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
			if targetPlayer then
				if getElementData(targetPlayer, "logged") then
					local charID = getElementData(targetPlayer, "dbid")
					if isPlayerVip(charID) then
						local vip = getElementData(targetPlayer, "vip") or 0
						if removeVip(charID) then
							local vipName = getVipName(vip) or "?"

							outputChatBox(
								"[!]#FFFFFF "
									.. targetPlayerName
									.. " isimli oyuncunun "
									.. vipName
									.. " üyeliğini aldınız.",
								thePlayer,
								0,
								255,
								0,
								true
							)
							outputChatBox(
								"[!]#FFFFFF "
									.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
									.. " isimli yetkili "
									.. vipName
									.. " üyeliğinizi aldı.",
								thePlayer,
								255,
								0,
								0,
								true
							)
							exports.mek_logs:addLog(
								"vip",
								exports.mek_global:getPlayerFullAdminTitle(thePlayer)
									.. " isimli yetkili "
									.. targetPlayerName
									.. " isimli oyuncunun "
									.. vipName
									.. " üyeliğini aldı."
							)
						end
					else
						outputChatBox("[!]#FFFFFF Bu oyuncunun VIP üyeliği yok.", thePlayer, 255, 0, 0, true)
					end
				else
					outputChatBox(
						"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
						thePlayer,
						255,
						0,
						0,
						true
					)
				end
			end
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("vipal", vipAl, false, false)

function distributeVip(thePlayer, commandName, vipID, day)
	if exports.mek_integration:isPlayerServerOwner(thePlayer) then
		if vipID and day and tonumber(vipID) and tonumber(day) then
			vipID = math.floor(tonumber(vipID))
			day = math.floor(tonumber(day))
			if vipID >= 1 and vipID <= 4 then
				if day >= 1 then
					local vipName = getVipName(vipID) or "?"
					local totalGiven = 0

					for _, player in ipairs(getElementsByType("player")) do
						if getElementData(player, "logged") then
							local charID = getElementData(player, "dbid")
							if charID then
								if isPlayerVip(charID) then
									local addDay = math.max(1, math.floor(day / 2))
									removeVip(charID)
									addVip(player, vipID, addDay)
									exports.mek_infobox:addBox(
										player,
										"success",
										"Mekan Game tarafından "
											.. vipName
											.. " üyeliğinizin süresine "
											.. addDay
											.. " gün daha ilave olundu."
									)
								else
									removeVip(charID)
									addVip(player, vipID, day)
									exports.mek_infobox:addBox(
										player,
										"success",
										"Mekan Game tarafından "
											.. day
											.. " günlük "
											.. vipName
											.. " kazandınız."
									)
								end
								totalGiven = totalGiven + 1
							end
						end
					end

					exports.mek_logs:addLog(
						"vip",
						exports.mek_global:getPlayerFullAdminTitle(thePlayer)
							.. " isimli yetkili "
							.. day
							.. " günlük "
							.. vipName
							.. " dağıttı. ("
							.. totalGiven
							.. " kişi)"
					)
				else
					outputChatBox("[!]#FFFFFF Geçerli bir gün girin.", thePlayer, 255, 0, 0, true)
				end
			else
				outputChatBox("[!]#FFFFFF Bu numarada VIP yok.", thePlayer, 255, 0, 0, true)
			end
		else
			outputChatBox("Kullanım: /" .. commandName .. " [1-4] [Gün]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("vipdagit", distributeVip, false, false)
