function cekilisKatil(thePlayer)
	local accountID = getElementData(thePlayer, "account_id")
	if not accountID then
		return
	end

	local query = dbQuery(
		giveawayCallback,
		{ thePlayer, accountID },
		exports.mek_mysql:getConnection(),
		"SELECT account_id FROM giveaway WHERE account_id = ?",
		accountID
	)
end
addCommandHandler("cekiliskatil", cekilisKatil, false, false)

function giveawayCallback(queryHandle, client, accountID)
	local result, rows = dbPoll(queryHandle, 0)
	if rows > 0 then
		outputChatBox("[!]#FFFFFF Zaten çekilişe katıldınız.", client, 255, 0, 0, true)
	else
		local success =
			dbExec(exports.mek_mysql:getConnection(), "INSERT INTO giveaway (account_id) VALUES (?)", accountID)
		if success then
			exports.mek_discord:sendMessage(
				"giveaway",
				getPlayerName(client):gsub("_", " ")
					.. " ("
					.. (getElementData(client, "account_username") or "?")
					.. ") isimli oyuncu çekilişe katıldı."
			)
			outputChatBox("[!]#FFFFFF Başarıyla çekilişe katıldınız.", client, 0, 255, 0, true)
			triggerClientEvent(client, "playSuccess", client)
		else
			outputChatBox("[!]#FFFFFF Veritabanı hatası, lütfen tekrar deneyin.", client, 255, 0, 0, true)
		end
	end
end
