promoCodes = {
	{
		code = "Mekan",
		gift = function(player, isAdmin)
			exports.mek_vip:addVip(player, 1, 3)
			exports.mek_global:giveMoney(player, 15000)

			if not isAdmin then
				outputChatBox(
					"[!]#FFFFFF 'Mekan' promo kodunu kullanarak kayıt olduğunuz için 3 günlük VIP ve ₺15,000 kazandınız.",
					player,
					0,
					255,
					0,
					true
				)
				exports.mek_logs:addLog(
					"promo",
					getPlayerName(player):gsub("_", " ")
						.. " ("
						.. (getElementData(player, "account_username") or "?")
						.. ") isimli oyuncu 'Mekan' promo kodunu kullanarak kayıt olduğu için 3 günlük VIP ve ₺15,000 kazandı."
				)
			end

			return true
		end,
	},
	{
		code = "CHARON3",
		gift = function(player, isAdmin)
			exports.mek_vip:addVip(player, 1, 3)
			exports.mek_global:giveMoney(player, 15000)

			if not isAdmin then
				outputChatBox(
					"[!]#FFFFFF 'CHARON3' promo kodunu kullanarak kayıt olduğunuz için 3 günlük VIP ve ₺15,000 kazandınız.",
					player,
					0,
					255,
					0,
					true
				)
				exports.mek_logs:addLog(
					"promo",
					getPlayerName(player):gsub("_", " ")
						.. " ("
						.. (getElementData(player, "account_username") or "?")
						.. ") isimli oyuncu 'CHARON3' promo kodunu kullanarak kayıt olduğu için 3 günlük VIP ve ₺15,000 kazandı."
				)
			end

			return true
		end,
	},
	{
		code = "NOEL",
		gift = function(player, isAdmin)
			exports.mek_vip:addVip(player, 1, 3)
			exports.mek_global:giveMoney(player, 15000)

			if not isAdmin then
				outputChatBox(
					"[!]#FFFFFF 'NOEL' promo kodunu kullanarak kayıt olduğunuz için 3 günlük VIP ve ₺15,000 kazandınız.",
					player,
					0,
					255,
					0,
					true
				)
				exports.mek_logs:addLog(
					"promo",
					getPlayerName(player):gsub("_", " ")
						.. " ("
						.. (getElementData(player, "account_username") or "?")
						.. ") isimli oyuncu 'NOEL' promo kodunu kullanarak kayıt olduğu için 3 günlük VIP ve ₺15,000 kazandı."
				)
			end

			return true
		end,
	},
}

function getPromoData(promoKey)
	if not promoKey then
		return false
	end

	for _, promo in ipairs(promoCodes) do
		if promo.code:upper() == promoKey:upper() then
			return promo
		end
	end

	return false
end

function givePlayerPromoGift(player, promoCode, isAdmin)
	local data = getPromoData(promoCode)
	if data then
		if type(data.gift) == "function" then
			data.gift(player, isAdmin)
			return true
		end
	end
	return false
end
