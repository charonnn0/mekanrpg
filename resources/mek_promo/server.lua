function givePromo(thePlayer, commandName, targetPlayer, promoCode)
	if exports.mek_integration:isPlayerAdmin3(thePlayer) then
		if targetPlayer and promoCode then
			local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
			if targetPlayer then
				local promoData = getPromoData(promoCode)
				if promoData then
					if getElementData(targetPlayer, "logged") then
						if not getElementData(targetPlayer, "promo_used") then
							exports.mek_promo:givePlayerPromoGift(targetPlayer, promoData.code, true)
							setElementData(targetPlayer, "promo_code", promoData.code)
							setElementData(targetPlayer, "promo_used", true)
							dbExec(
								exports.mek_mysql:getConnection(),
								"UPDATE accounts SET promo_used = 1 WHERE id = ?",
								getElementData(targetPlayer, "account_id")
							)

							outputChatBox(
								"[!]#FFFFFF "
									.. targetPlayerName
									.. " isimli oyuncuya ["
									.. promoData.code
									.. "] promo kodunun ödülleri verildi.",
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
									.. promoData.code
									.. "] promo kodunun ödüllerini verdi.",
								targetPlayer,
								0,
								0,
								255,
								true
							)
							exports.mek_logs:addLog(
								"promo",
								exports.mek_global:getPlayerFullAdminTitle(thePlayer)
									.. " isimli yetkili "
									.. targetPlayerName
									.. " isimli oyuncuya ["
									.. promoData.code
									.. "] promo kodunun ödüllerini verdi."
							)
						else
							outputChatBox(
								"[!]#FFFFFF Bu oyuncu zaten promosyon kodunu kullanmış.",
								thePlayer,
								255,
								0,
								0,
								true
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
				else
					outputChatBox("[!]#FFFFFF Geçersiz bir promo kodu girdiniz.", thePlayer, 255, 0, 0, true)
				end
			end
		else
			outputChatBox(
				"Kullanım: /" .. commandName .. " [Karakter Adı / ID] [Promo Kodu]",
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
addCommandHandler("givepromo", givePromo, false, false)
