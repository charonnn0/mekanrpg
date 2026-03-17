function financeUpdate(state, amount)
	if exports.mek_settings:getPlayerSetting(localPlayer, "finance_update_visible") then
		if amount and tonumber(amount) and tonumber(amount) >= 0 then
			local info = {
				{ "Finans Güncellemesi", true },
				{ "" },
			}

			local totalMoney = localPlayer:getData("money") or 0

			local formattedAmount = exports.mek_global:formatMoney(amount)
			local formattedTotalMoney = exports.mek_global:formatMoney(totalMoney)

			if state then
				setSoundVolume(playSound("public/sounds/collect_money.ogg"), 0.3)
				table.insert(info, { "Cüzdanınıza +₺" .. formattedAmount .. " işlem yapıldı." })
			else
				setSoundVolume(playSound("public/sounds/pay_money.mp3"), 0.3)
				table.insert(info, { "Cüzdanınızda -₺" .. formattedAmount .. " işlem yapıldı." })
			end

			table.insert(info, { "Toplam ₺" .. formattedTotalMoney .. " paranız mevcut." })
			table.insert(info, { "" })

			triggerEvent("hud.drawOverlay", localPlayer, info)
		end
	end
end
addEvent("financeUpdate", true)
addEventHandler("financeUpdate", root, financeUpdate)
