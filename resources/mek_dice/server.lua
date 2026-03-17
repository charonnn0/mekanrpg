local invites = {}
local pairedPlayers = {}

function invitePlayer(thePlayer, commandName, option, amount)
	if thePlayer.interior ~= 12 or thePlayer.dimension ~= 14 then
		return
	end

	if not (option == "kabul" or option == "red") then
		if not (option and amount) then
			outputChatBox(
				"Kullanım: /" .. commandName .. " [Karakter Adı / ID] [Bahis Miktarı]",
				thePlayer,
				255,
				194,
				14
			)
			outputChatBox("Kullanım: /" .. commandName .. " [kabul/red]", thePlayer, 255, 194, 14)
			return
		end
	end

	if tonumber(option) then
		amount = tonumber(amount)
		local invitedPlayer = exports.mek_global:findPlayerByPartialNick(thePlayer, option)

		if not type(invitedPlayer) == "thePlayer" then
			outputChatBox("[!]#FFFFFF Eşleşmek istediğiniz oyuncu bulunamadı.", thePlayer, 255, 0, 0, true)
			return
		end

		if pairedPlayers[thePlayer] then
			outputChatBox("[!]#FFFFFF Zaten bir rakip ile eşleştiniz.", thePlayer, 255, 0, 0, true)
			return
		end

		if pairedPlayers[invitedPlayer] then
			outputChatBox(
				"[!]#FFFFFF Davet etmeye çalıştığınız oyuncu zaten başka birisi ile eşleşmiş.",
				thePlayer,
				255,
				0,
				0,
				true
			)
			return
		end

		if invites[invitedPlayer] then
			local text = invites[invitedPlayer] == thePlayer and "zaten davet gönderdin."
				or "başka birisi davet göndermiş."
			outputChatBox(
				"[!]#FFFFFF " .. getPlayerName(invitedPlayer):gsub("_", " ") .. " isimli oyuncuya " .. text,
				thePlayer,
				255,
				0,
				0,
				true
			)
			return
		end

		if amount < 50 or amount > 10000000 then
			outputChatBox(
				"[!]#FFFFFF Bahis miktarı ₺50 ile ₺10,000,000 arasında olmalıdır.",
				thePlayer,
				255,
				0,
				0,
				true
			)
			return
		end

		if not inDistance3D(thePlayer, invitedPlayer, 5) then
			outputChatBox("[!]#FFFFFF Davet ettiğiniz oyuncu sizden oldukça uzak.", thePlayer, 255, 0, 0, true)
			return false
		end

		local interior, targetInterior = getElementInterior(thePlayer), getElementInterior(invitedPlayer)
		if interior ~= targetInterior then
			outputChatBox("[!]#FFFFFF Davet ettiğiniz oyuncu sizden oldukça uzak.", thePlayer, 255, 0, 0, true)
			return false
		end

		if not exports.mek_global:hasMoney(thePlayer, amount) then
			outputChatBox("[!]#FFFFFF Bahis yaptığınız kadar para üzerinizde yok.", thePlayer, 255, 0, 0, true)
			return
		end

		if not exports.mek_global:hasMoney(invitedPlayer, amount) then
			outputChatBox(
				"[!]#FFFFFF Bahis oynayabilmek için üzerinizde yeterli para yok.",
				invitedPlayer,
				255,
				0,
				0,
				true
			)
			outputChatBox("[!]#FFFFFF Karşı tarafın üzerinde yeterli para yok.", thePlayer, 255, 0, 0, true)
			return
		end
		invites[invitedPlayer] = thePlayer

		outputChatBox(
			"[!]#FFFFFF " .. getPlayerName(invitedPlayer):gsub("_", " ") .. " isimli oyuncuya davet gönderildi.",
			thePlayer,
			0,
			255,
			0,
			true
		)
		outputChatBox(
			"[!]#FFFFFF "
				.. getPlayerName(thePlayer):gsub("_", " ")
				.. " isimli oyuncu size ₺"
				.. exports.mek_global:formatMoney(amount)
				.. " bahise davet etti.",
			invitedPlayer,
			0,
			0,
			255,
			true
		)
		triggerClientEvent(
			invitedPlayer,
			"dice.inviteGUI",
			invitedPlayer,
			getPlayerName(thePlayer):gsub("_", " "),
			amount
		)
		setElementData(thePlayer, "dice_amount", amount)
		setElementData(invitedPlayer, "dice_amount", amount)
	elseif option == "kabul" then
		amount = getElementData(thePlayer, "dice_amount")

		if not exports.mek_global:hasMoney(thePlayer, amount) then
			outputChatBox("[!]#FFFFFF Bahis alacağınız kadar para üzerinizde yok.", thePlayer, 255, 0, 0, true)
			return
		end

		local inviterPlayer = invites[thePlayer]
		if isElement(inviterPlayer) then
			pairedPlayers[thePlayer] = { opponent = inviterPlayer, bet = amount, spinned = false }
			pairedPlayers[inviterPlayer] = { opponent = thePlayer, bet = amount, spinned = false }

			outputChatBox(
				"[!]#FFFFFF "
					.. getPlayerName(inviterPlayer):gsub("_", " ")
					.. " isimli oyuncunun davetini kabul ettin.",
				thePlayer,
				255,
				0,
				0,
				true
			)
			outputChatBox(
				"[!]#FFFFFF " .. getPlayerName(thePlayer):gsub("_", " ") .. " isimli oyuncu davetinizi kabul etti.",
				inviterPlayer,
				255,
				0,
				0,
				true
			)

			triggerClientEvent(
				inviterPlayer,
				"dice.showGUI",
				inviterPlayer,
				getPlayerName(thePlayer):gsub("_", " "),
				amount
			)
			triggerClientEvent(
				thePlayer,
				"dice.showGUI",
				thePlayer,
				getPlayerName(inviterPlayer):gsub("_", " "),
				amount
			)
		else
			outputChatBox("[!]#FFFFFF Kimse sana zar bahisi daveti göndermemiş.", thePlayer, 255, 0, 0, true)
		end
	elseif option == "red" then
		local inviterPlayer = invites[thePlayer]
		if isElement(inviterPlayer) then
			invites[thePlayer] = nil

			outputChatBox(
				"[!]#FFFFFF "
					.. getPlayerName(inviterPlayer):gsub("_", " ")
					.. " isimli oyuncunun bahis davetini red ettin.",
				thePlayer,
				255,
				0,
				0,
				true
			)
			outputChatBox(
				"[!]#FFFFFF " .. getPlayerName(thePlayer):gsub("_", " ") .. " isimli oyuncu bahis davetinizi reddetti.",
				inviterPlayer,
				255,
				0,
				0,
				true
			)
		end
	end
end
addCommandHandler("davet", invitePlayer, false, false)
addEvent("dice.invite", true)
addEventHandler("dice.invite", root, invitePlayer)

addEvent("dice.spin", true)
addEventHandler("dice.spin", root, function()
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	local clientData = pairedPlayers[client]
	if not clientData then
		outputChatBox("[!]#FFFFFF Önce birisiyle eşleşmelisin.", client, 255, 0, 0, true)
		return
	end

	local opponent = clientData.opponent
	if not isElement(opponent) then
		outputChatBox(
			"[!]#FFFFFF Rakip oyuncu oyunda değil, başka birisiyle eşleşebilirsin.",
			client,
			255,
			0,
			0,
			true
		)
		pairedPlayers[client] = nil
		return
	end

	if not exports.mek_global:hasMoney(client, getElementData(client, "dice_amount")) then
		pairedPlayers[pairedPlayers[client].opponent] = nil
		outputChatBox(
			"[!]#FFFFFF Rakibinizde yeterli para bulunmadığı için kumar iptal edildi.",
			pairedPlayers[client].opponent,
			255,
			0,
			0,
			true
		)
		invites[pairedPlayers[client].opponent] = nil
		pairedPlayers[client] = nil
		invites[client] = nil
		outputChatBox("[!]#FFFFFF Üzerinizde yeterli para bulunmamaktır.", client, 255, 0, 0, true)
		return
	end

	local opponentData = pairedPlayers[opponent]
	if not opponentData then
		outputChatBox("[!]#FFFFFF Rakip verisi bulunamadı.", client, 255, 0, 0, true)
		return
	end

	local opponentSpinned = opponentData.spinned
	local spinned = clientData.spinned
	if not spinned then
		math.randomseed(getTickCount())
		pairedPlayers[client].spinned = { math.random(1, 6), math.random(1, 6) }
		outputChatBox(
			"[!]#FFFFFF Döndürdünüz rakibin döndürmesi bekleniyor [Rakip: "
				.. (opponentSpinned and "Döndürdü" or "Döndürmedi")
				.. "]",
			client,
			255,
			0,
			0,
			true
		)
	elseif spinned and not opponentSpinned then
		outputChatBox("[!]#FFFFFF Sıra rakip oyuncuda.", client, 255, 0, 0, true)
		return
	end

	if not opponentSpinned then
		outputChatBox(
			"[!]#FFFFFF Sonuçların açıklanması için karşı tarafın döndürmesini bekliyoruz.",
			client,
			255,
			0,
			0,
			true
		)
		return
	end

	local number1, number2 = pairedPlayers[client].spinned[1], pairedPlayers[client].spinned[2]
	local number3, number4 = opponentSpinned[1], opponentSpinned[2]

	local myScore = number1 + number2
	local opponentScore = number3 + number4

	local winner = false
	if myScore > opponentScore then
		winner = client
	elseif myScore < opponentScore then
		winner = opponent
	end

	for i, client in ipairs({ client, opponent }) do
		local playerData = pairedPlayers[client]
		if exports.mek_global:hasMoney(client, getElementData(client, "dice_amount")) then
			exports.mek_global:takeMoney(client, getElementData(client, "dice_amount"))
		else
			outputChatBox(
				"[!]#FFFFFF Karşı tarafın oynayacak parası kalmadığı için oyun iptal edildi.",
				pairedPlayers[pairedPlayers[client].opponent],
				255,
				0,
				0,
				true
			)
			pairedPlayers[pairedPlayers[client].opponent] = nil
			invites[pairedPlayers[client].opponent] = nil
			invites[client] = nil
			invites[opponet] = nil
			pairedPlayers[opponent] = nil
			pairedPlayers[client] = nil
			outputChatBox("[!]#FFFFFF Oynayacak paran kalmadığın için oyun iptal edildi.", client, 255, 0, 0, true)
			return
		end

		outputChatBox(
			">>#FFFFFF "
				.. getPlayerName(client):gsub("_", " ")
				.. ", (1. Zar: "
				.. number1
				.. "), (2. Zar: "
				.. number2
				.. ") (Toplam: "
				.. myScore
				.. ")",
			client,
			0,
			0,
			255,
			true
		)
		outputChatBox(
			">>#FFFFFF "
				.. getPlayerName(opponent):gsub("_", " ")
				.. ", (1. Zar: "
				.. number3
				.. "), (2. Zar: "
				.. number4
				.. ") (Toplam: "
				.. opponentScore
				.. ")",
			client,
			0,
			0,
			255,
			true
		)

		if winner then
			if winner == client then
				colorCode = "#00ff00"
			else
				colorCode = "#ff0000"
			end
			outputChatBox(
				colorCode .. ">>#FFFFFF Bu raundu " .. getPlayerName(winner):gsub("_", " ") .. " kazandı.",
				client,
				255,
				255,
				255,
				true
			)
			if winner == client then
				exports.mek_global:giveMoney(winner, getElementData(client, "dice_amount") * 2)
			end
			exports.mek_logs:addLog(
				"bahis",
				getPlayerName(winner):gsub("_", " ")
					.. " ve "
					.. getPlayerName(client):gsub("_", " ")
					.. " isimli oyuncular ₺"
					.. exports.mek_global:formatMoney(getElementData(client, "dice_amount") * 2)
					.. " bahse girdiler ve "
					.. getPlayerName(winner):gsub("_", " ")
					.. " kazandı."
			)
		else
			outputChatBox("[!]#FFFFFF Bu raundu kimse kazanamadı. (Berabere)", client, 255, 0, 0, true)
			exports.mek_global:giveMoney(client, getElementData(client, "dice_amount"))
			exports.mek_logs:addLog(
				"bahis",
				getPlayerName(opponent):gsub("_", " ")
					.. " ve "
					.. getPlayerName(client):gsub("_", " ")
					.. " isimli oyuncular ₺"
					.. exports.mek_global:formatMoney(getElementData(client, "dice_amount") * 2)
					.. " bahse girdiler ve kimse kazanmadı."
			)
		end

		if pairedPlayers[client] then
			pairedPlayers[client].spinned = false
		end

		if exports.mek_global:hasMoney(client, getElementData(client, "dice_amount")) then
			triggerClientEvent(
				client,
				"dice.showGUI",
				client,
				getPlayerName(opponent):gsub("_", " "),
				getElementData(client, "dice_amount")
			)
		else
			outputChatBox("[!]#FFFFFF Bahis oynayacak paran kalmadı.", client, 255, 0, 0, true)

			invites[pairedPlayers[client].opponent] = nil
			pairedPlayers[pairedPlayers[client].opponent] = nil
			pairedPlayers[client] = nil

			invites[client] = nil
		end
	end
end)

addEvent("dice.remove", true)
addEventHandler("dice.remove", root, function()
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	outputChatBox("[!]#FFFFFF Bahisten başarıyla ayrıldınız.", client, 255, 0, 0, true)
	outputChatBox(
		"[!]#FFFFFF " .. getPlayerName(client):gsub("_", " ") .. " bahisten ayrıldı.",
		pairedPlayers[client].opponent,
		255,
		0,
		0,
		true
	)
	triggerClientEvent(pairedPlayers[client].opponent, "dice.closeGUI", pairedPlayers[client].opponent)
	pairedPlayers[pairedPlayers[client].opponent] = nil
	invites[pairedPlayers[client].opponent] = nil
	pairedPlayers[client] = nil
	invites[client] = nil
	setElementData(client, "dice_amount", 0)
end)

function inDistance3D(element1, element2, distance)
	if isElement(element1) and isElement(element2) then
		local x1, y1, z1 = getElementPosition(element1)
		local x2, y2, z2 = getElementPosition(element2)
		local distance2 = getDistanceBetweenPoints3D(x1, y1, z1, x2, y2, z2)

		if distance2 <= distance then
			return true, distance2
		end
	end

	return false, 99999
end
