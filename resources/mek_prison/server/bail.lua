local bailBasePrice = 7000
local lifeTimeBailPrice = 3000000

addEvent("prison.payBail", true)
addEventHandler("prison.payBail", root, function(method)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	local days, hours, remainingTime = cleanMath(getElementData(client, "pd_jail_time"))
	if not remainingTime then
		outputChatBox("[!]#FFFFFF Hapiste değilsiniz.", client, 255, 0, 0, true)
		return
	end

	if days ~= PRISONER_STATUS.LifeTime then
		hours = hours + (days * 24)
	end
	local price = (days == PRISONER_STATUS.LifeTime) and lifeTimeBailPrice or (bailBasePrice * hours)

	if method == "cash" then
		if not exports.mek_global:hasMoney(client, price) then
			outputChatBox("[!]#FFFFFF Üzerinizde yeterli para yok.", client, 255, 0, 0, true)
			return
		end

		exports.mek_global:takeMoney(client, price)
		bailReleasePlayer(client, price, "cash")
	elseif method == "bank" then
		if not exports.mek_global:hasBankMoney(client, price) then
			outputChatBox("[!]#FFFFFF Banka hesabınızda yeterli bakiye yok.", client, 255, 0, 0, true)
			return
		end

		exports.mek_global:takeBankMoney(client, price)
		bailReleasePlayer(client, price, "bank")
	end
end)

function bailReleasePlayer(player, price, method)
	if not isElement(player) then
		return
	end

	local characterID = getElementData(player, "dbid")
	if not characterID then
		return
	end

	dbExec(mysql:getConnection(), "DELETE FROM jailed WHERE character_id = ?", characterID)
	dbExec(mysql:getConnection(), "UPDATE characters SET pd_jailed = 0 WHERE id = ?", characterID)

	if not getElementData(player, "admin_jailed") then
		local cell = getElementData(player, "pd_jail_cell")
		local location = releaseLocations[cells[cell].location]
		setElementPosition(player, location[1], location[2], location[3])
		setElementInterior(player, location[4])
		setElementDimension(player, location[5])
	end

	removeElementData(player, "pd_jailed")
	removeElementData(player, "pd_jail_time")
	removeElementData(player, "pd_jail_id")
	removeElementData(player, "pd_jail_cell")
	removeElementData(player, "pd_jail_charges")

	outputChatBox(
		string.format(
			"[!]#FFFFFF %s ₺%s kefalet ödediniz ve serbest bırakıldınız.",
			method == "cash" and "Üzerinizden" or "Bankadan",
			exports.mek_global:formatMoney(price)
		),
		player,
		0,
		255,
		0,
		true
	)
	sendPrisonMessage(
		("** [Kefalet] %s isimli mahkum ₺%s kefalet ödeyerek serbest kaldı. (%s)"):format(
			getPlayerName(player):gsub("_", " "),
			exports.mek_global:formatMoney(price),
			method == "cash" and "Üzerinden" or "Bankadan"
		)
	)
	
	if getElementData(player, "restrained") then
		exports.mek_realism:forceUncuff(player)
	end
end
