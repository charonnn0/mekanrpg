function getInteriorSetting(interiorID, key)
	if interiorID and interiorID > 0 then
		if interiorID > 20000 then
			vehicleID = interiorID - 20000
			local vehicleElement = exports.mek_pool:getElementByID("vehicle", vehicleID)
			if vehicleElement then
				local data = getElementData(vehicleElement, "settings") or {}
				return data[tostring(key)]
			else
				return false
			end
		else
			local interiorElement = exports.mek_pool:getElementByID("interior", interiorID)
			if interiorElement then
				local data = getElementData(interiorElement, "settings") or {}
				return data[tostring(key)]
			else
				return false
			end
		end
	end
	return false
end

function saveInteriorSettings(element, interiorID, isVehicleInterior, data, newName, newFee, newCost, newFurniture, newForSale)
	-- Triggered from client; prefer 'client' (player) over resource root.
	local thePlayer = nil
	if isElement(client) and getElementType(client) == "player" then
		thePlayer = client
	elseif isElement(source) and getElementType(source) == "player" then
		thePlayer = source
	end
	if interiorID and data then
		if isVehicleInterior then
			vehicleID = interiorID - 20000
			if not element then
				element = exports.mek_pool:getElementByID("vehicle", vehicleID)
			end
			if element then
				dbExec(
					exports.mek_mysql:getConnection(),
					"UPDATE `vehicles` SET `settings` = ? WHERE `id` = ? LIMIT 1;",
					toJSON(data),
					vehicleID
				)
				setElementData(element, "settings", data)
			end
		else
			if not element then
				element = exports.mek_pool:getElementByID("interior", interiorID)
			end
			if element then
				-- Ensure all boolean values are properly saved as booleans (not strings)
				local cleanedData = {}
				for key, value in pairs(data) do
					if type(value) == "boolean" then
						cleanedData[key] = value
					elseif value == "true" or value == true or value == 1 then
						cleanedData[key] = true
					elseif value == "false" or value == false or value == 0 then
						cleanedData[key] = false
					else
						cleanedData[key] = value
					end
				end
				
				-- Save settings
				dbExec(
					exports.mek_mysql:getConnection(),
					"UPDATE `interiors` SET `settings` = ? WHERE `id` = ?",
					toJSON(cleanedData),
					interiorID
				)
				setElementData(element, "settings", cleanedData)
				
				-- İsim değişikliği: paneli açabilen herkes deneyebilir; boş / küfür / link filtreli, loglu
				if newName then
					local currentName = getElementData(element, "name") or ""
					local trimmedName = tostring(newName or ""):gsub("^%s+", ""):gsub("%s+$", "")
					local lowerName = trimmedName:lower()
					local normalized = lowerName:gsub("%s+", "") -- boşlukları kaldırarak kontrol et
					
					if trimmedName ~= currentName then
						-- Boş isim engeli
						if trimmedName == "" then
							outputChatBox("[!]#FFFFFF Mülk adı boş bırakılamaz.", thePlayer, 255, 0, 0, true)
						else
							-- Küfür filtresi
							local bannedWords = {
								"amk", "aq", "orospu", "yarrak", "siktir", "sik", "pic", "piç", "salak", "gerizekali", "gerizekalı",
							}
							local hasBadWord = false
							for _, bad in ipairs(bannedWords) do
								if lowerName:find(bad, 1, true) or normalized:find(bad, 1, true) then
									hasBadWord = true
									break
								end
							end
							
							-- Link / discord filtresi (boşluklu halleri de yakalamak için normalized kullanıldı)
							local hasForbidden =
								normalized:find("discord%.gg", 1, true)
								or normalized:find("discord.com", 1, true)
								or normalized:find("http://", 1, true)
								or normalized:find("https://", 1, true)
								or normalized:find("www%.", 1, false)
							
							if hasBadWord then
								outputChatBox("[!]#FFFFFF Mülk adında küfür kullanamazsınız.", thePlayer, 255, 0, 0, true)
							elseif hasForbidden then
								outputChatBox("[!]#FFFFFF Mülk adında link veya discord adresi kullanamazsınız.", thePlayer, 255, 0, 0, true)
							else
								dbExec(
									exports.mek_mysql:getConnection(),
									"UPDATE `interiors` SET `name` = ? WHERE `id` = ?",
									trimmedName,
									interiorID
								)
								setElementData(element, "name", trimmedName)
								
								-- Log
								local adminTitle = thePlayer and exports.mek_global:getPlayerFullAdminTitle(thePlayer) or "?"
								local adminUsername = thePlayer and (getElementData(thePlayer, "account_username") or getPlayerName(thePlayer)) or "?"
								exports.mek_logs:addLog(
									"int-name",
									adminTitle
										.. " ("
										.. adminUsername
										.. ") mülk ID #"
										.. tostring(interiorID)
										.. " adını '"
										.. tostring(currentName)
										.. "' -> '"
										.. tostring(trimmedName)
										.. "' olarak değiştirdi."
								)
							end
						end
					end
				end
				
				-- Save entrance fee if provided
				if newFee and tonumber(newFee) then
					local feeValue = tonumber(newFee)
					-- Limit entrance fee to 500
					if feeValue > 500 then
						feeValue = 500
					end
					
					local entrance = getElementData(element, "entrance") or {}
					entrance.fee = feeValue
					entrance[7] = feeValue
					setElementData(element, "entrance", entrance)
					
					-- Save entrance fee in settings for persistence
					cleanedData.entranceFee = feeValue
					
					-- Re-save settings with entrance fee
					dbExec(
						exports.mek_mysql:getConnection(),
						"UPDATE `interiors` SET `settings` = ? WHERE `id` = ?",
						toJSON(cleanedData),
						interiorID
					)
					setElementData(element, "settings", cleanedData)
				end
				
				-- Save cost if provided
				if newCost and tonumber(newCost) then
					dbExec(
						exports.mek_mysql:getConnection(),
						"UPDATE `interiors` SET `cost` = ? WHERE `id` = ?",
						tonumber(newCost),
						interiorID
					)
					local interiorStatus = getElementData(element, "status") or {}
					interiorStatus.cost = tonumber(newCost)
					setElementData(element, "status", interiorStatus)
				end
				
				-- Save furniture if provided
				if newFurniture ~= nil then
					dbExec(
						exports.mek_mysql:getConnection(),
						"UPDATE `interiors` SET `furniture` = ? WHERE `id` = ?",
						newFurniture and 1 or 0,
						interiorID
					)
					local interiorStatus = getElementData(element, "status") or {}
					interiorStatus.furniture = newFurniture and 1 or 0
					setElementData(element, "status", interiorStatus)
				end
				
				-- Save for sale status if provided
				if newForSale ~= nil then
					local interiorStatus = getElementData(element, "status") or {}
					local interiorType = interiorStatus.type or 0
					
					-- Don't allow government interiors to be put on sale
					if interiorType == 2 then
						if thePlayer and isElement(thePlayer) then
							outputChatBox("[!]#FFFFFF Devlet mülkleri satışa çıkarılamaz.", thePlayer, 255, 0, 0, true)
						end
					else
						if newForSale then
							-- Set for sale - owner = -1, locked = 1
							-- Save current owner before putting on sale (if not already -1)
							if interiorStatus.owner and interiorStatus.owner > 0 then
								-- Store original owner in settings for later restoration
								local currentSettings = getElementData(element, "settings") or {}
								currentSettings.originalOwner = interiorStatus.owner
								setElementData(element, "settings", currentSettings)
							end
							
							dbExec(
								exports.mek_mysql:getConnection(),
								"UPDATE `interiors` SET `owner` = -1, `locked` = 1 WHERE `id` = ?",
								interiorID
							)
							interiorStatus.owner = -1
							interiorStatus.locked = true
							setElementData(element, "status", interiorStatus)
							
							-- Reload interior to update pickup icon
							if exports["mek_interior-load"] then
								exports["mek_interior-load"]:reloadInterior(interiorID)
							end
						else
							-- Remove from sale - restore original owner
							if interiorStatus.owner == -1 then
								local settings = getElementData(element, "settings") or {}
								local originalOwner = settings.originalOwner
								
								-- If we have original owner, restore it; otherwise use current player's ID
								local newOwner = originalOwner
								if not newOwner or newOwner <= 0 then
									-- Fallback: use player's ID (they must own it to remove from sale)
									if thePlayer and isElement(thePlayer) then
										newOwner = getElementData(thePlayer, "dbid")
									end
								end
								
								if newOwner and newOwner > 0 then
									dbExec(
										exports.mek_mysql:getConnection(),
										"UPDATE `interiors` SET `owner` = ?, `locked` = 0 WHERE `id` = ?",
										newOwner,
										interiorID
									)
									interiorStatus.owner = newOwner
									interiorStatus.locked = false
									setElementData(element, "status", interiorStatus)
									
									-- Remove originalOwner from settings
									if settings.originalOwner then
										settings.originalOwner = nil
										setElementData(element, "settings", settings)
									end
									
									-- Reload interior to update pickup icon
									if exports["mek_interior-load"] then
										exports["mek_interior-load"]:reloadInterior(interiorID)
									end
								end
							end
						end
					end
				end
			end
			
			-- Send success message to player
			if thePlayer and isElement(thePlayer) and getElementType(thePlayer) == "player" then
				outputChatBox("[!]#FFFFFF Mülk ayarları başarıyla kaydedildi.", thePlayer, 0, 255, 0, true)
			end
		end
	end
end
addEvent("interior.saveSettings", true)
addEventHandler("interior.saveSettings", resourceRoot, saveInteriorSettings)

function openInteriorSettings(thePlayer, cmd)
	local playerInterior = getElementInterior(thePlayer)
	local playerDimension = getElementDimension(thePlayer)

	if playerInterior > 0 and playerDimension > 0 then
		local interiorID = playerDimension
		local hasPermission = false
		
		-- Check if player has permission
		if interiorID < 20000 then
			-- Normal interior: check for keys (item 4 or 5) or admin
			hasPermission = exports.mek_item:hasItem(thePlayer, 4, interiorID)
				or exports.mek_item:hasItem(thePlayer, 5, interiorID)
				or (exports.mek_integration:isPlayerManager(thePlayer) and exports.mek_global:isAdminOnDuty(thePlayer))
		else
			-- Vehicle interior: check for vehicle key (item 3) or admin
			hasPermission = exports.mek_item:hasItem(thePlayer, 3, interiorID - 20000)
				or (exports.mek_integration:isPlayerManager(thePlayer) and exports.mek_global:isAdminOnDuty(thePlayer))
		end
		
		if hasPermission then
			if interiorID > 20000 then
				vehicleID = interiorID - 20000
				local vehicleElement = exports.mek_pool:getElementByID("vehicle", vehicleID)
				if vehicleElement then
					local data = getElementData(vehicleElement, "settings") or {}
					triggerClientEvent(
						thePlayer,
						"interior.settingsGui",
						vehicleElement,
						playerInterior,
						playerDimension,
						data
					)
				else
					return false
				end
			else
				local interiorElement = exports.mek_pool:getElementByID("interior", interiorID)
				if interiorElement then
					local data = getElementData(interiorElement, "settings") or {}
					triggerClientEvent(
						thePlayer,
						"interior.settingsGui",
						thePlayer,
						interiorElement,
						playerInterior,
						playerDimension,
						data
					)
				else
					return false
				end
			end
		else
			-- No permission - show error message
			outputChatBox("[!]#FFFFFF Bu mülkün ayarlarına erişim yetkiniz yok.", thePlayer, 255, 0, 0, true)
			return false
		end
	else
		-- Not in an interior
		outputChatBox("[!]#FFFFFF Bir mülkün içinde olmanız gerekiyor.", thePlayer, 255, 0, 0, true)
		return false
	end
end
addCommandHandler("intsettings", openInteriorSettings)
addCommandHandler("interiorsettings", openInteriorSettings)
addCommandHandler("intset", openInteriorSettings)
