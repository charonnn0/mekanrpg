addEvent("key.get", true)
addEventHandler("key.get", root, function(type, id, price)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if exports.mek_global:hasMoney(client, price) then
		if type == "vehicle" then
			local theVehicle = exports.mek_pool:getElementByID("vehicle", id)
			if theVehicle then
				if getElementData(client, "dbid") == getElementData(theVehicle, "owner") then
					if exports.mek_item:hasSpaceForItem(client, 3, id) then
						local success, reason = exports.mek_item:giveItem(client, 3, id)
						if success then
							exports.mek_global:takeMoney(client, price)
							exports.mek_infobox:addBox(
								client,
								"success",
								"Başarıyla ₺"
									.. exports.mek_global:formatMoney(price)
									.. " karşılığında ["
									.. id
									.. "] ID'li aracınızın anahtarını çıkardınız."
							)
						else
							exports.mek_infobox:addBox(client, "error", "Bir sorun oluştu.")
						end
					else
						exports.mek_infobox:addBox(client, "error", "Envanterinizde yeterli alan yok.")
					end
				else
					exports.mek_infobox:addBox(client, "error", "Bu araç size ait değil.")
				end
			else
				exports.mek_infobox:addBox(client, "error", "Böyle bir araç bulunamadı.")
			end
		elseif type == "interior" then
			local theInterior = exports.mek_pool:getElementByID("interior", id)
			if theInterior then
				local interiorStatus = getElementData(theInterior, "status")
				if interiorStatus then
					if getElementData(client, "dbid") == interiorStatus.owner then
						local keyType = false
						local interiorType = interiorStatus.type

						if interiorType == 0 or interiorType == 2 or interiorType == 3 then
							keyType = 4
						else
							keyType = 5
						end

						if keyType then
							if exports.mek_item:hasSpaceForItem(client, keyType, id) then
								local success, reason = exports.mek_item:giveItem(client, keyType, id)
								if success then
									exports.mek_global:takeMoney(client, price)
									exports.mek_infobox:addBox(
										client,
										"success",
										"Başarıyla ₺"
											.. exports.mek_global:formatMoney(price)
											.. " karşılığında ["
											.. id
											.. "] ID'li mülkünüzün anahtarını çıkardınız."
									)
								else
									exports.mek_infobox:addBox(client, "error", "Bir sorun oluştu.")
								end
							else
								exports.mek_infobox:addBox(client, "error", "Envanterinizde yeterli alan yok.")
							end
						else
							exports.mek_infobox:addBox(client, "error", "Bir sorun oluştu.")
						end
					else
						exports.mek_infobox:addBox(client, "error", "Bu mülk size ait değil.")
					end
				else
					exports.mek_infobox:addBox(client, "error", "Bir sorun oluştu.")
				end
			else
				exports.mek_infobox:addBox(client, "error", "Böyle bir mülk bulunamadı.")
			end
		end
	else
		exports.mek_infobox:addBox(client, "error", "Yeterli paranız yok.")
	end
end)
