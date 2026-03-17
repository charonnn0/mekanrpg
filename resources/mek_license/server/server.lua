addEvent("license.recover", true)
addEventHandler("license.recover", root, function(licenseText, licenseCost, itemID, npcName)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not exports.mek_global:takeMoney(source, licenseCost) then
		exports.mek_global:sendLocalText(
			source,
			npcName
				.. ": Kaybolan "
				.. licenseText
				.. " belgesi için ₺"
				.. exports.mek_global:formatMoney(licenseCost)
				.. " ücret alabilir miyim, lütfen?",
			255,
			255,
			255,
			10
		)
		return false
	end

	if exports.mek_item:giveItem(source, itemID, getPlayerName(source):gsub("_", " ")) then
		exports.mek_global:sendLocalText(
			source,
			npcName
				.. ": Kaybolan "
				.. licenseText
				.. " belgesinin yeniden çıkarılması için ₺"
				.. exports.mek_global:formatMoney(licenseCost)
				.. " ücret ödediniz.",
			255,
			255,
			255,
			10
		)
	end
end)

addEvent("license.server", true)
addEventHandler("license.server", root, function()
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	local gender = getElementData(source, "gender")
	if gender == 0 then
		exports.mek_global:sendLocalText(
			source,
			"Carla Cooper: Merhaba beyefendi, ehliyet başvurusu yapmak ister misiniz?",
			255,
			255,
			255,
			10
		)
	else
		exports.mek_global:sendLocalText(
			source,
			"Carla Cooper: Merhaba hanımefendi, ehliyet başvurusu yapmak ister misiniz?",
			255,
			255,
			255,
			10
		)
	end
end)

addEvent("license.payFee", true)
addEventHandler("license.payFee", root, function(amount, reason)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if exports.mek_global:takeMoney(source, amount) then
		if not reason then
			reason = "bir ehliyet"
		end

		exports.mek_infobox:addBox(
			source,
			"success",
			"'" .. reason .. "' işlemi için ₺" .. exports.mek_global:formatMoney(amount) .. " ücret ödediniz."
		)
	end
end)
