function etiketVer(thePlayer, commandName, targetPlayer, tagID, days)
	if exports.mek_integration:isPlayerManager(thePlayer) then
		if targetPlayer and tagID and days then
			tagID = tonumber(tagID)
			days = tonumber(days)
			if days <= 30 then
				if fileExists("public/images/tags/" .. tagID .. ".png") then
					local targetPlayer, targetPlayerName =
						exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
					if targetPlayer then
						if getElementData(targetPlayer, "logged") then
							local tags = getElementData(targetPlayer, "tags") or {}
							local foundTag = false

							for _, tag in pairs(tags) do
								if tag.id == tagID then
									foundTag = true
									break
								end
							end

							if foundTag then
								exports.mek_tag:removeTag(targetPlayer, tagID)
								outputChatBox(
									"[!]#FFFFFF "
										.. targetPlayerName
										.. " isimli oyuncunun ["
										.. tagID
										.. "] ID'li etiketi alındı.",
									thePlayer,
									0,
									255,
									0,
									true
								)
								outputChatBox(
									"[!]#FFFFFF "
										.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
										.. " isimli yetkili sizin ["
										.. tagID
										.. "] ID'li etiketinizi aldı.",
									targetPlayer,
									0,
									0,
									255,
									true
								)
								exports.mek_logs:addLog(
									"etiket",
									exports.mek_global:getPlayerFullAdminTitle(thePlayer)
										.. " isimli yetkili "
										.. targetPlayerName
										.. " isimli oyuncunun ["
										.. tagID
										.. "] ID'li etiketini aldı."
								)
							else
								if #tags < 5 then
									exports.mek_tag:addTag(targetPlayer, tagID, days)
									outputChatBox(
										"[!]#FFFFFF "
											.. targetPlayerName
											.. " isimli oyuncuya "
											.. days
											.. " günlük ["
											.. tagID
											.. "] ID'li etiket verildi.",
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
											.. days
											.. " günlük ["
											.. tagID
											.. "] ID'li etiket verdi.",
										targetPlayer,
										0,
										0,
										255,
										true
									)
									exports.mek_logs:addLog(
										"etiket",
										exports.mek_global:getPlayerFullAdminTitle(thePlayer)
											.. " isimli yetkili "
											.. targetPlayerName
											.. " isimli oyuncuya "
											.. days
											.. " günlük ["
											.. tagID
											.. "] ID'li etiketi verdi."
									)
								else
									outputChatBox(
										"[!]#FFFFFF Maksimum 5 tane etiket verebilirsiniz.",
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
								"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
								thePlayer,
								255,
								0,
								0,
								true
							)
						end
					end
				else
					outputChatBox("[!]#FFFFFF Bu sayıya ait bir etiket bulunmuyor.", thePlayer, 255, 0, 0, true)
				end
			else
				outputChatBox("[!]#FFFFFF Maksimum 30 günlük etiket verebilirsiniz.", thePlayer, 255, 0, 0, true)
			end
		else
			outputChatBox(
				"Kullanım: /" .. commandName .. " [Karakter Adı / ID] [Etiket ID] [Gün]",
				thePlayer,
				255,
				194,
				14
			)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("etiketver", etiketVer, false, false)

function etiketAl(thePlayer, commandName, targetPlayer)
	if exports.mek_integration:isPlayerManager(thePlayer) then
		if targetPlayer then
			local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
			if targetPlayer then
				if getElementData(targetPlayer, "logged") then
					setElementData(targetPlayer, "tags", {})
					dbExec(
						exports.mek_mysql:getConnection(),
						"UPDATE characters SET tags = ? WHERE id = ?",
						toJSON({}),
						getElementData(targetPlayer, "dbid")
					)
					outputChatBox(
						"[!]#FFFFFF " .. targetPlayerName .. " isimli oyuncunun etiketleri alındı.",
						thePlayer,
						0,
						255,
						0,
						true
					)
					outputChatBox(
						"[!]#FFFFFF "
							.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
							.. " isimli yetkili etiketlerinizi aldı.",
						targetPlayer,
						0,
						0,
						255,
						true
					)
					exports.mek_logs:addLog(
						"etiket",
						exports.mek_global:getPlayerFullAdminTitle(thePlayer)
							.. " isimli yetkili "
							.. targetPlayerName
							.. " isimli oyuncunun etiketlerini aldı."
					)
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
		else
			outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("etiketal", etiketAl, false, false)

function donaterVer(thePlayer, commandName, targetPlayer, donaterID)
	if exports.mek_integration:isPlayerServerOwner(thePlayer) then
		if targetPlayer then
			donaterID = tonumber(donaterID)
			if donaterID then
				if (donaterID == 0) or (fileExists("public/images/donaters/" .. donaterID .. ".png")) then
					local targetPlayer, targetPlayerName =
						exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
					if targetPlayer then
						if getElementData(targetPlayer, "logged") then
							setElementData(targetPlayer, "donater", donaterID)
							dbExec(
								exports.mek_mysql:getConnection(),
								"UPDATE accounts SET donater = ? WHERE id = ?",
								donaterID,
								getElementData(targetPlayer, "account_id")
							)
							outputChatBox(
								"[!]#FFFFFF "
									.. targetPlayerName
									.. " isimli oyuncuya ["
									.. donaterID
									.. "] ID'li donater etiketi verildi.",
								thePlayer,
								0,
								255,
								0,
								true
							)
							outputChatBox(
								"[!]#FFFFFF "
									.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
									.. " isimli yetkili size ["
									.. donaterID
									.. "] ID'li donater etiketi verdi.",
								targetPlayer,
								0,
								0,
								255,
								true
							)
							exports.mek_logs:addLog(
								"etiket",
								exports.mek_global:getPlayerFullAdminTitle(thePlayer)
									.. " isimli yetkili "
									.. targetPlayerName
									.. " isimli oyuncuya ["
									.. donaterID
									.. "] ID'li donater etiketi verdi."
							)
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
				else
					outputChatBox(
						"[!]#FFFFFF Bu sayıya ait bir donater etiketi bulunmuyor.",
						thePlayer,
						255,
						0,
						0,
						true
					)
				end
			else
				outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID] [0-6]", thePlayer, 255, 194, 14)
			end
		else
			outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID] [0-6]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("donaterver", donaterVer, false, false)

function youtuberVer(thePlayer, commandName, targetPlayer)
	if exports.mek_integration:isPlayerManager(thePlayer) then
		if targetPlayer then
			local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
			if targetPlayer then
				if getElementData(targetPlayer, "logged") then
					if getElementData(targetPlayer, "youtuber") then
						setElementData(targetPlayer, "youtuber", false)
						dbExec(
							exports.mek_mysql:getConnection(),
							"UPDATE accounts SET youtuber = 0 WHERE id = ?",
							getElementData(targetPlayer, "account_id")
						)
						outputChatBox(
							"[!]#FFFFFF " .. targetPlayerName .. " isimli oyuncunun YouTuber etiketi alındı.",
							thePlayer,
							0,
							255,
							0,
							true
						)
						outputChatBox(
							"[!]#FFFFFF "
								.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili sizin YouTuber etiketinizi aldı.",
							targetPlayer,
							0,
							0,
							255,
							true
						)
						exports.mek_logs:addLog(
							"etiket",
							exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili "
								.. targetPlayerName
								.. " isimli oyuncunun YouTuber etiketini aldı."
						)
					else
						setElementData(targetPlayer, "youtuber", true)
						dbExec(
							exports.mek_mysql:getConnection(),
							"UPDATE accounts SET youtuber = 1 WHERE id = ?",
							getElementData(targetPlayer, "account_id")
						)
						outputChatBox(
							"[!]#FFFFFF " .. targetPlayerName .. " isimli oyuncuya YouTuber etiketi verildi.",
							thePlayer,
							0,
							255,
							0,
							true
						)
						outputChatBox(
							"[!]#FFFFFF "
								.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili size YouTuber etiketi verdi.",
							targetPlayer,
							0,
							0,
							255,
							true
						)
						exports.mek_logs:addLog(
							"etiket",
							exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili "
								.. targetPlayerName
								.. " isimli oyuncuya YouTuber etiketi verdi."
						)
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
		else
			outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("ytver", youtuberVer, false, false)
addCommandHandler("youtuberver", youtuberVer, false, false)

function rpPlusVer(thePlayer, commandName, targetPlayer)
	if exports.mek_integration:isPlayerServerOwner(thePlayer) then
		if targetPlayer then
			local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
			if targetPlayer then
				if getElementData(targetPlayer, "logged") then
					if getElementData(targetPlayer, "rp_plus") then
						setElementData(targetPlayer, "rp_plus", false)
						dbExec(
							exports.mek_mysql:getConnection(),
							"UPDATE accounts SET rp_plus = 0 WHERE id = ?",
							getElementData(targetPlayer, "account_id")
						)
						outputChatBox(
							"[!]#FFFFFF " .. targetPlayerName .. " isimli oyuncunun RP+ etiketi alındı.",
							thePlayer,
							0,
							255,
							0,
							true
						)
						outputChatBox(
							"[!]#FFFFFF "
								.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili sizin RP+ etiketinizi aldı.",
							targetPlayer,
							0,
							0,
							255,
							true
						)
						exports.mek_logs:addLog(
							"etiket",
							exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili "
								.. targetPlayerName
								.. " isimli oyuncunun RP+ etiketini aldı."
						)
					else
						setElementData(targetPlayer, "rp_plus", true)
						dbExec(
							exports.mek_mysql:getConnection(),
							"UPDATE accounts SET rp_plus = 1 WHERE id = ?",
							getElementData(targetPlayer, "account_id")
						)
						outputChatBox(
							"[!]#FFFFFF " .. targetPlayerName .. " isimli oyuncuya RP+ etiketi verildi.",
							thePlayer,
							0,
							255,
							0,
							true
						)
						outputChatBox(
							"[!]#FFFFFF "
								.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili size RP+ etiketi verdi.",
							targetPlayer,
							0,
							0,
							255,
							true
						)
						exports.mek_logs:addLog(
							"etiket",
							exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili "
								.. targetPlayerName
								.. " isimli oyuncuya RP+ etiketi verdi."
						)
					end
					exports.mek_global:updateNametagColor(targetPlayer)
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
		else
			outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("rpver", rpPlusVer, false, false)
addCommandHandler("rpplusver", rpPlusVer, false, false)
