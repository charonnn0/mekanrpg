local factionToggleState = {}
local lastPlayerMessage = {}
local lastPlayerMessageTick = {}

addEvent("chat.executeCommand", true)
addEventHandler("chat.executeCommand", root, function(command, args)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if getElementData(source, "cked") then
		return
	end

	executeCommandHandler(command, source, args)
end)

addEvent("chat.sendText", true)
addEventHandler("chat.sendText", root, function(message, messageType)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if getElementData(source, "cked") then
		return
	end

	triggerEvent("onPlayerChat", source, message, messageType)
end)

addEventHandler("onPlayerChat", root, function(message, messageType)
	local currentTick = getTickCount()
	if lastPlayerMessage[source] == message then
		if lastPlayerMessageTick[source] and (currentTick - lastPlayerMessageTick[source]) < 30000 then
			outputChatBox("[!]#FFFFFF Aynı mesajı tekrar tekrar gönderemezsiniz. (30 saniye bekleyin)", source, 255, 0, 0, true)
			cancelEvent()
			return
		end
	end
	lastPlayerMessage[source] = message
	lastPlayerMessageTick[source] = currentTick

	cancelEvent()
	if messageType == 0 then
		localIC(source, message)
		exports.mek_logs:addLog("ic-chat", exports.mek_global:getPlayerName(source) .. ": " .. message)
	elseif messageType == 1 then
		meEmote(source, "me", message)
	elseif messageType == 2 then
		radio(source, 1, message)
	end
end)

addEventHandler("onPlayerQuit", root, function()
	if lastPlayerMessage[source] then
		lastPlayerMessage[source] = nil
	end
	if lastPlayerMessageTick[source] then
		lastPlayerMessageTick[source] = nil
	end
end)

addEventHandler("onPlayerPrivateMessage", root, function(message, player)
	cancelEvent()
	pmPlayer(source, "pm", player, message)
end)


local aksanlar = {
    ["laz"] = "Laz Aksanı",
    ["trakya"] = "Trakya Aksanı",
    ["karadeniz"] = "Karadeniz Aksanı",
    ["dogu"] = "Doğu Aksanı",
    ["guneydogu"] = "Güneydoğu Aksanı",
    ["ege"] = "Ege Aksanı" ,
	["kurt"] = "Kürt Aksanı",
}

addEvent("aksan->degistir", true)
addEventHandler("aksan->degistir", root, function(aksanTuru)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end
	
    aksanSec(client, aksanTuru)
end)

function aksanSec(source, aksanTuru)
    if aksanTuru == "none" or aksanTuru == "kapat" then
        removeElementData(source, "player_accent")
        outputChatBox("[!]#FFFFFF Aksanınız kapatıldı.", source, 0, 255, 0, true)
        return
    end
    
    if aksanlar[aksanTuru] then
        setElementData(source, "player_accent", aksanTuru)
        outputChatBox("[!]#FFFFFF Aksanınız ".. aksanlar[aksanTuru] .." olarak ayarlandı.", source, 0, 255, 0, true)
    else
        outputChatBox("[!]#FFFFFF Geçersiz bir aksan türü algılandı.", source, 255, 0, 0, true)
    end
end


function getAksanGosterimi(source)
    local aksan = getElementData(source, "player_accent")
    if aksan and aksanlar[aksan] then
        return " (".. aksanlar[aksan] ..")"
    end
    return ""
end

function localIC(source, message)
    local playerName = exports.mek_global:getPlayerName(source)
    local aksanGosterimi = getAksanGosterimi(source)
    message = string.gsub(message, "#%x%x%x%x%x%x", "")

    local function getFocusColor(fromPlayer, toPlayer, defaultColor)
        local focus = getElementData(toPlayer, "focus")
        if type(focus) == "table" then
            for target, col in pairs(focus) do
                if target == fromPlayer then
                    return col, true
                end
            end
        end
        return defaultColor, false
    end

    local color = { 0xEE, 0xEE, 0xEE }

    local emotes = {
        [":)"] = { "me", "gülümser." },
        [":D"] = { "me", "kahkaha atar." },
        [";)"] = { "me", "göz kırpar." },
        ["O.o"] = { "me", "sol kaşını havaya kaldırır." },
        ["O.O"] = { "me", "sağ kaşını havaya kaldırır." },
        ["X.x"] = { "me", "gözlerini yumar." },
        [":("] = { "do", "Yüzünde üzgün bir ifade oluştuğu görülebilir." },
    }

    if emotes[message] then
        local actionType, text = unpack(emotes[message])
        if actionType == "me" then
            exports.mek_global:sendLocalMeAction(source, text)
        else
            exports.mek_global:sendLocalDoAction(source, text)
        end
        return
    end

    if getElementData(source, "chat_spelling") then
        message = formatSentence(message)
    end

    local playerVehicle = getPedOccupiedVehicle(source)
    local vehicleText = ""
    if playerVehicle and exports.mek_vehicle:isVehicleWindowUp(playerVehicle) then
        vehicleText = " ((Araçta))"
    end

    if not playerVehicle and getElementData(source, "talk_anim") and not getElementData(source, "dead") then
        setPedAnimation(source, "GANGS", "prtial_gngtlkA", 1, false, true, false)
    end

    local interior, dimension = getElementInterior(source), getElementDimension(source)
    local callData = getElementData(source, "call")
    local sentToCall = false

    if type(callData) == "table" and isElement(callData.player) then
        local target = callData.player
        if getElementData(target, "logged") then
            local displayName = callData.contactName or callData.number or "Bilinmeyen"
            local gender = getElementData(source, "gender") == 1 and "K" or "E"

            if not callData.isMuted then
                outputChatBox("[Gelen][" .. displayName .. "][" .. gender .. "]: " .. message, target, 255, 194, 14)
            end

            local targetCall = getElementData(target, "call")
            local targetSpeakerOn = type(targetCall) == "table" and targetCall.isSpeakerOn

            if targetSpeakerOn then
                local tInt, tDim = getElementInterior(target), getElementDimension(target)
                for _, nearby in ipairs(getElementsByType("player")) do
                    if nearby ~= target and getElementData(nearby, "logged") then
                        if getElementInterior(nearby) == tInt and getElementDimension(nearby) == tDim then
                            if getElementDistance(target, nearby) <= 8 then
                                local targetPlayerName = exports.mek_global:getPlayerName(target)
                                outputChatBox(
                                    "[Gelen][" .. targetPlayerName .. " telefonundan](" .. gender .. "): " .. message,
                                    nearby,
                                    255,
                                    194,
                                    14
                                )
                            end
                        end
                    end
                end
            end

            outputChatBox(playerName .. aksanGosterimi .. vehicleText .. ": " .. message, source, unpack(color))
            sentToCall = true
        end
    end

    if not sentToCall then
        outputChatBox(playerName .. aksanGosterimi .. vehicleText .. ": " .. message, source, unpack(color))
        for _, player in ipairs(getElementsByType("player")) do
            if player ~= source and getElementData(player, "logged") then
                if getElementInterior(player) == interior and getElementDimension(player) == dimension then
                    local distance = getElementDistance(source, player)
                    if distance <= 20 then
                        local finalColor, isFocus = getFocusColor(source, player, { 0xEE, 0xEE, 0xEE })

                        local srcVeh, tgtVeh = playerVehicle, getPedOccupiedVehicle(player)
                        if srcVeh and exports.mek_vehicle:isVehicleWindowUp(srcVeh) then
                            for i = 0, getVehicleMaxPassengers(srcVeh) do
                                local lp = getVehicleOccupant(srcVeh, i)
                                if lp and lp ~= source then
                                    outputChatBox(playerName .. aksanGosterimi .. " ((Araçta)): " .. message, lp, unpack(finalColor))
                                end
                            end
                        elseif not (tgtVeh and exports.mek_vehicle:isVehicleWindowUp(tgtVeh)) then
                            if not isFocus then
                                local fadeColors = {
                                    { 4, { 0xEE, 0xEE, 0xEE } },
                                    { 8, { 0xDD, 0xDD, 0xDD } },
                                    { 12, { 0xCC, 0xCC, 0xCC } },
                                    { 16, { 0xBB, 0xBB, 0xBB } },
                                    { 20, { 0xAA, 0xAA, 0xAA } },
                                }
                                for _, data in ipairs(fadeColors) do
                                    if distance < data[1] then
                                        finalColor = data[2]
                                        break
                                    end
                                end
                            end

                            outputChatBox(playerName .. aksanGosterimi .. ": " .. message, player, unpack(finalColor))
                        end
                    end
                end
            end
        end
    end
end

function meEmote(thePlayer, commandName, ...)
	if not (...) then
		outputChatBox("Kullanım: /" .. commandName .. " [Aktivite]", thePlayer, 255, 194, 14)
	else
		local message = table.concat({ ... }, " ")
		exports.mek_global:sendLocalMeAction(thePlayer, message, true, true)
	end
end
addCommandHandler("me", meEmote, false, false)

function doEmote(thePlayer, commandName, ...)
	if not (...) then
		outputChatBox("Kullanım: /" .. commandName .. " [Aktivite]", thePlayer, 255, 194, 14)
	else
		local message = table.concat({ ... }, " ")
		if getElementData(thePlayer, "chat_spelling") then
			message = formatSentence(message)
		end

		exports.mek_global:sendLocalDoAction(thePlayer, message, true, true)
	end
end
addCommandHandler("do", doEmote, false, false)

function megaphoneShout(thePlayer, commandName, ...)
	if exports.mek_faction:isPlayerInFaction(thePlayer, { 1, 2, 3, 4 }) then
		if not (...) then
			outputChatBox("Kullanım: /" .. commandName .. " [Mesaj]", thePlayer, 255, 194, 14)
		else
			local message = table.concat({ ... }, " ")
			if getElementData(thePlayer, "chat_spelling") then
				message = formatSentence(message)
			end

			local interior = getElementInterior(thePlayer)
			local dimension = getElementDimension(thePlayer)

			for _, player in ipairs(getElementsByType("player")) do
				if getElementDistance(thePlayer, player) < 40 then
					local playerDimension = getElementDimension(player)
					local playerInterior = getElementInterior(player)

					if playerInterior == interior and playerDimension == dimension then
						outputChatBox(
							"((" .. getPlayerName(thePlayer):gsub("_", " ") .. ")) Megafon <O: " .. message,
							player,
							255,
							255,
							0
						)
					end
				end
			end
		end
	end
end
addCommandHandler("m", megaphoneShout, false, false)

function radio(thePlayer, radioID, message)
	local customSound = false
	local affectedElements = {}
	local indirectlyAffectedElements = {}
	table.insert(affectedElements, thePlayer)

	radioID = tonumber(radioID) or 1

	local hasRadio, itemKey, itemValue, itemID = exports.mek_item:hasItem(thePlayer, 6)
	if hasRadio or getElementType(thePlayer) == "ped" or radioID == -2 then
		local theChannel = itemValue
		if radioID < 0 then
			theChannel = radioID
		elseif
			radioID == 1
			and exports.mek_integration:isPlayerTrialAdmin(thePlayer)
			and tonumber(message)
			and tonumber(message) >= 1
			and tonumber(message) <= 10
		then
			return
		elseif radioID ~= 1 then
			local count = 0
			local items = exports.mek_item:getItems(thePlayer)
			for k, v in ipairs(items) do
				if v[1] == 6 then
					count = count + 1
					if count == radioID then
						theChannel = v[2]
						break
					end
				end
			end
		end

		local isRestricted, factionID = isThisFreqRestricted(theChannel)
		local playerFaction = getElementData(thePlayer, "faction")
		if theChannel == 1 or theChannel == 0 then
			outputChatBox(
				"[!]#FFFFFF Lütfen önce telsizi /telsizbagla [kanal] ile ayarlayın.",
				thePlayer,
				255,
				0,
				0,
				true
			)
		elseif isRestricted and tonumber(playerFaction) ~= tonumber(factionID) then
			outputChatBox(
				"[!]#FFFFFF Bu kanala erişim izniniz yok, lütfen telsizi tekrar ayarlayın.",
				thePlayer,
				255,
				0,
				0,
				true
			)
		elseif theChannel > 1 or radioID < 0 then
			local username = getPlayerName(thePlayer):gsub("_", " ")
			local channelName = "#" .. theChannel

			if getElementData(thePlayer, "chat_spelling") then
				message = formatSentence(message)
			end

			local r, g, b = 0, 102, 255
			local focus = getElementData(thePlayer, "focus")
			if type(focus) == "table" then
				for player, color in pairs(focus) do
					if player == thePlayer then
						r, g, b = unpack(color)
					end
				end
			end

			if radioID == -1 then
				local teams = {
					getTeamFromName("İstanbul Emniyet Müdürlüğü"),
					getTeamFromName("İstanbul Şehir Hastanesi"),
					getTeamFromName("Devlet Hastanesi"),
					getTeamFromName("İstanbul Devlet Hastanesi"),
					getTeamFromName("Jandarma Genel Komutanlığı"),
					getTeamFromName("İstanbul Büyükşehir Belediyesi"),
				}

				for _, faction in ipairs(teams) do
					if faction and isElement(faction) then
						for key, value in ipairs(getPlayersInTeam(faction)) do
							for _, itemRow in ipairs(exports.mek_item:getItems(value)) do
								if
									tonumber(itemRow[1])
									and tonumber(itemRow[2])
									and tonumber(itemRow[1]) == 6
									and tonumber(itemRow[2]) > 0
								then
									table.insert(affectedElements, value)
									break
								end
							end
						end
					end
				end

				channelName = "DEPARTMENT"
			elseif radioID == -2 then
				local a = {}
				for key, value in ipairs(exports.mek_sfia:getPlayersInAircraft()) do
					table.insert(affectedElements, value)
					a[value] = true
				end

				for key, value in ipairs(getPlayersInTeam(getTeamFromName("Federal Aviation Administration"))) do
					if not a[value] then
						for _, itemRow in ipairs(exports.mek_item:getItems(value)) do
							if itemRow[1] == 6 and itemRow[2] > 0 then
								table.insert(affectedElements, value)
								break
							end
						end
					end
				end

				channelName = "AIR"
			elseif radioID == -3 then
				local outputDim = getElementDimension(thePlayer)
				local vehicle
				if isPedInVehicle(thePlayer) then
					vehicle = getPedOccupiedVehicle(thePlayer)
					outputDim = tonumber(getElementData(vehicle, "dbid")) + 20000
				end
				if outputDim > 0 then
					local canUsePA = false
					if outputDim > 20000 then
						local dbid = outputDim - 20000
						if not vehicle then
							for k, v in ipairs(exports.mek_pool:getPoolElementsByType("vehicle")) do
								if getElementData(v, "dbid") == dbid then
									vehicle = v
									break
								end
							end
						end
						if vehicle then
							canUsePA = getElementData(thePlayer, "duty_admin")
								or exports.mek_item:hasItem(thePlayer, 3, tonumber(dbid))
								or exports.mek_faction:isPlayerInFaction(thePlayer, getElementData(vehicle, "faction"))
						end
					else
						canUsePA = getElementData(thePlayer, "duty_admin")
							or exports.mek_item:hasItem(thePlayer, 4, outputDim)
							or exports.mek_item:hasItem(thePlayer, 5, outputDim)
					end

					if not canUsePA then
						return false
					end

					local outputInt = getElementInterior(thePlayer)
					for i, value in ipairs(getElementsByType("player")) do
						if getElementDimension(value) == outputDim then
							if getElementInterior(value) == outputInt or vehicle then
								table.insert(affectedElements, value)
							end
						end
					end

					if vehicle then
						for i = 0, getVehicleMaxPassengers(vehicle) do
							local player = getVehicleOccupant(vehicle, i)
							if player then
								table.insert(affectedElements, player)
							end
						end
					end
					r, g, b = 0, 149, 255
					channelName = "SPEAKERS"
					customSound = "pa.mp3"
				else
					return false
				end
			elseif radioID == -4 then
				local x, y, z = getElementPosition(thePlayer)
				local zonename = exports.mek_global:getZoneName(x, y, z)
				local outputDim = getElementDimension(thePlayer)
				local allowedFactions = {
					47, --FAA
				}
				local allowedAirports = {
					["Easter Bay Airport"] = true,
					["Los Santos International"] = true,
					["Las Venturas Airport"] = true,
				}
				allowedAirportDimensions = {
					[1317] = true, --LSA terminal
					[2337] = true, --LSA deaprture hall
					[2340] = true, --LSA terminal 2
				}
				airportDimensionsSF = {}
				airportDimensionsLS = {
					[1317] = true, --terminal
					[2337] = true, --deaprture hall
					[2340] = true, --terminal 2
				}
				airportDimensionsLV = {}
				local airportDimensions = {}
				local targetAirport = zonename
				if zonename == "Easter Bay Airport" or airportDimensionsSF[outputDim] then
					airportDimensions = airportDimensionsSF
				elseif zonename == "Los Santos International" or airportDimensionsLS[outputDim] then
					airportDimensions = airportDimensionsLS
				elseif zonename == "Las Venturas Airport" or airportDimensionsLV[outputDim] then
					airportDimensions = airportDimensionsLV
				end

				local inAllowedFaction = false
				for k, v in ipairs(allowedFactions) do
					if exports.mek_faction:isPlayerInFaction(thePlayer, v) then
						inAllowedFaction = true
					end
				end

				if inAllowedFaction then
					if allowedAirportDimensions[outputDim] or outputDim == 0 and allowedAirports[zonename] then
						for key, value in ipairs(getElementsByType("player")) do
							x, y, z = getElementPosition(value)
							zonename = exports.mek_global:getZoneName(x, y, z, false)
							local dim = getElementDimension(value)
							if airportDimensions[dim] or dim == 0 and zonename == targetAirport then
								table.insert(affectedElements, value)
							end
						end
						r, g, b = 0, 149, 255
						channelName = "AIRPORT SPEAKERS"
						customSound = "pa.mp3"
					else
						return false
					end
				else
					return false
				end
			else
				for key, value in ipairs(getElementsByType("player")) do
					if exports.mek_item:hasItem(value, 6, theChannel) then
						local isRestricted, factionID = isThisFreqRestricted(theChannel)
						local playerFaction = getElementData(value, "faction")
						if (isRestricted and tonumber(playerFaction) == tonumber(factionID)) or not isRestricted then
							table.insert(affectedElements, value)
						end
					end
				end
			end

			if channelName == "DEPARTMENT" then
				outputChatBoxCar(
					getPedOccupiedVehicle(thePlayer),
					thePlayer,
					"[" .. channelName .. "] " .. username,
					": " .. message,
					{ r, 162, b }
				)
			else
				outputChatBoxCar(
					getPedOccupiedVehicle(thePlayer),
					thePlayer,
					"[" .. channelName .. "] " .. username,
					": " .. message,
					{ r, g, b }
				)
			end

			for i = #affectedElements, 1, -1 do
				if not getElementData(affectedElements[i], "logged") then
					table.remove(affectedElements, i)
				end
			end

			for key, value in ipairs(affectedElements) do
				if customSound then
					triggerClientEvent(value, "playCustomChatSound", root, customSound)
				else
					triggerClientEvent(value, "playRadioSound", root)
				end

				if value ~= thePlayer then
					local r, g, b = 0, 102, 255
					local focus = getElementData(value, "focus")
					if type(focus) == "table" then
						for player, color in pairs(focus) do
							if player == thePlayer then
								r, g, b = unpack(color)
							end
						end
					end
					if channelName == "DEPARTMENT" then
						outputChatBoxCar(
							getPedOccupiedVehicle(value),
							value,
							"[" .. channelName .. "] " .. username,
							": " .. message,
							{ r, 162, b }
						)
					else
						outputChatBoxCar(
							getPedOccupiedVehicle(value),
							value,
							"[" .. channelName .. "] " .. username,
							": " .. message,
							{ r, g, b }
						)
					end

					if not exports.mek_item:hasItem(value, 88) then
						for k, v in ipairs(exports.mek_global:getNearbyElements(value, "player", 7)) do
							local logged2 = getElementData(v, "logged")
							if logged2 then
								local found = false
								for kx, vx in ipairs(affectedElements) do
									if v == vx then
										found = true
										break
									end
								end

								if not found then
									local message2 = message
									local text1 = getPlayerName(value):gsub("_", " ") .. "'s Telsiz"
									local text2 = ": " .. message2

									if
										outputChatBoxCar(
											getPedOccupiedVehicle(value),
											v,
											text1,
											text2,
											{ 255, 255, 255 }
										)
									then
										table.insert(indirectlyAffectedElements, v)
									end
								end
							end
						end
					end
				end
			end

			for key, value in ipairs(getElementsByType("player")) do
				if getElementDistance(thePlayer, value) < 10 then
					if value ~= thePlayer then
						local message2 = message
						local text1 = getPlayerName(thePlayer):gsub("_", " ") .. " (Telsiz)"
						local text2 = ": " .. message2

						if
							outputChatBoxCar(getPedOccupiedVehicle(thePlayer), value, text1, text2, { 255, 255, 255 })
						then
							table.insert(indirectlyAffectedElements, value)
						end
					end
				end
			end

			if #indirectlyAffectedElements > 0 then
				table.insert(affectedElements, "Indirectly Affected:")
				for k, v in ipairs(indirectlyAffectedElements) do
					table.insert(affectedElements, v)
				end
			end
		else
			outputChatBox("[!]#FFFFFF Telsiziniz kapalı.", thePlayer, 255, 0, 0, true)
		end
	else
		outputChatBox("[!]#FFFFFF Telsiziniz yok.", thePlayer, 255, 0, 0, true)
	end
end

function radioCommand(thePlayer, commandName, ...)
	if ... then
		local message = table.concat({ ... }, " ")
		radio(thePlayer, 1, message)
	else
		outputChatBox("Kullanım: /" .. commandName .. " [Mesaj]", thePlayer, 255, 194, 14)
	end
end
addCommandHandler("r", radioCommand, false, false)
addCommandHandler("radio", radioCommand, false, false)

function localOOC(thePlayer, commandName, ...)
	if not (...) then
		outputChatBox("Kullanım: /" .. commandName .. " [Mesaj]", thePlayer, 255, 194, 14)
	else
		local playerName = getPlayerName(thePlayer):gsub("_", " ")
		local interior = getElementInterior(thePlayer)
		local dimension = getElementDimension(thePlayer)

		if dimension >= 1 and interior >= 1 then
			local dbid, entrance, exit, interiorType, interiorElement = exports.mek_interior:findProperty(thePlayer)
			if interiorElement then
				ooc = getElementData(interiorElement, "settings").ooc
				if ooc then
					outputChatBox(
						"[!]#FFFFFF Bulunduğunuz mülkün sahibi bu mülkte OOC sohbetinin kullanımını yasakladı.",
						thePlayer,
						255,
						0,
						0,
						true
					)
					return
				end
			end
		end

		local message = table.concat({ ... }, " ")
		local playerName = exports.mek_global:getPlayerName(thePlayer)

		if getElementData(thePlayer, "chat_spelling") then
			message = formatSentence(message)
		end

		local sending = "#ccffff[OOC]#ccffff " .. playerName .. "#ccffff: (( " .. message .. " ))"

		if exports.mek_integration:isPlayerTrialAdmin(thePlayer) and thePlayer:getData("duty_admin") then
			sending = "#ccffff[OOC]#FF0000 " .. playerName .. "#ccffff: (( " .. message .. " ))"
		end

		exports.mek_global:sendLocalText(thePlayer, sending, 220, 220, 220)
		exports.mek_logs:addLog("ooc-chat", playerName .. ": " .. message)
	end
end
addCommandHandler("b", localOOC, false, false)
addCommandHandler("LocalOOC", localOOC, false, false)

function managerChat(thePlayer, commandName, ...)
	if exports.mek_integration:isPlayerManager(thePlayer) then
		if ... then
			if getElementData(thePlayer, "hide_manager_chat") then
				setElementData(thePlayer, "hide_manager_chat", false)
				outputChatBox(
					"[!]#FFFFFF Yönetici sohbeti kapatıldığı için otomatik olarak açıldı.",
					thePlayer,
					0,
					255,
					0,
					true
				)
			end

			local message = table.concat({ ... }, " ")

			if getElementData(thePlayer, "chat_spelling") then
				message = formatSentence(message)
			end

			for _, player in ipairs(getElementsByType("player")) do
				if exports.mek_integration:isPlayerManager(player) then
					local hideManagerChat = getElementData(player, "hide_manager_chat") or false
					if not hideManagerChat then
						outputChatBox(
							"[ÜYK] " .. exports.mek_global:getPlayerFullAdminTitle(thePlayer) .. ": " .. message,
							player,
							204,
							102,
							255
						)
					end
				end
			end
			exports.mek_logs:addLog("uchat", exports.mek_global:getPlayerFullAdminTitle(thePlayer) .. ": " .. message)
		else
			outputChatBox("Kullanım: /" .. commandName .. " [Mesaj]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("u", managerChat, false, false)

function adminChat(thePlayer, commandName, ...)
	if exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
		if ... then
			if getElementData(thePlayer, "hide_admin_chat") then
				setElementData(thePlayer, "hide_admin_chat", false)
				outputChatBox(
					"[!]#FFFFFF Yetkili sohbeti kapatıldığı için otomatik olarak açıldı.",
					thePlayer,
					0,
					255,
					0,
					true
				)
			end

			local message = table.concat({ ... }, " ")

			if getElementData(thePlayer, "chat_spelling") then
				message = formatSentence(message)
			end

			for _, player in ipairs(getElementsByType("player")) do
				if exports.mek_integration:isPlayerTrialAdmin(player) then
					local hideAdminChat = getElementData(player, "hide_admin_chat") or false
					if not hideAdminChat then
						outputChatBox(
							"[ADM] " .. exports.mek_global:getPlayerFullAdminTitle(thePlayer) .. ": " .. message,
							player,
							51,
							255,
							102
						)
					end
				end
			end
			exports.mek_logs:addLog("achat", exports.mek_global:getPlayerFullAdminTitle(thePlayer) .. ": " .. message)
		else
			outputChatBox("Kullanım: /" .. commandName .. " [Mesaj]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("a", adminChat, false, false)

function gacChat(thePlayer, commandName, ...)
	if not exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
		return
	end

	local args = { ... }
	if #args == 0 then
		outputChatBox("Kullanım: /" .. commandName .. " [Mesaj]", thePlayer, 255, 194, 14)
		return
	end

	local message = table.concat(args, " ")
	if getElementData(thePlayer, "chat_spelling") then
		message = formatSentence(message)
	end

	for _, player in ipairs(getElementsByType("player")) do
		if exports.mek_integration:isPlayerTrialAdmin(player) then
			local hideGacChat = getElementData(player, "hide_gac_chat") or false
			if not hideGacChat then
				outputChatBox(
					"[MRP] " .. exports.mek_global:getPlayerFullAdminTitle(thePlayer) .. ": " .. message,
					player,
					172,
					232,
					245
				)
			end
		end
	end

	exports.mek_logs:addLog("gacchat", exports.mek_global:getPlayerFullAdminTitle(thePlayer) .. ": " .. message)

	callRemote("http://91.124.63.240:22005/cdp_api/call/sendGacMessage", function(success, response)
		if not success then
			outputChatBox("[!]#FFFFFF Sunucular arası iletişim başarısız oldu.", thePlayer, 255, 0, 0, true)
		end
	end, exports.mek_global:getPlayerFullAdminTitle(thePlayer), message)
end
addCommandHandler("gac", gacChat, false, false)

function sendGacMessage(adminTitle, message)
	for _, player in ipairs(getElementsByType("player")) do
		if exports.mek_integration:isPlayerTrialAdmin(player) then
			local hideGacChat = getElementData(player, "hide_gac_chat") or false
			if not hideGacChat then
				outputChatBox("[MRP] " .. adminTitle .. ": " .. message, player, 255, 212, 59)
			end
		end
	end

	exports.mek_logs:addLog("gacchat", adminTitle .. ": " .. message)
end

function warnAdmins(thePlayer, commandName, ...)
	if exports.mek_integration:isPlayerGeneralAdmin(thePlayer) then
		if ... then
			local message = table.concat({ ... }, " ")
			for _, player in ipairs(getElementsByType("player")) do
				if exports.mek_integration:isPlayerTrialAdmin(player) then
					outputChatBox(" ", player)
					outputChatBox(" ", player)
					outputChatBox(
						"[ÖNEMLİ] " .. getElementData(thePlayer, "account_username") .. ": " .. message,
						player,
						255,
						0,
						0,
						true
					)
					outputChatBox(" ", player)
					outputChatBox(" ", player)
					triggerClientEvent(player, "playCustomChatSound", root, "warn.mp3", true)
				end
			end
		else
			outputChatBox("Kullanım: /" .. commandName .. " [Mesaj]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("warn", warnAdmins, false, false)

function toggleManagerChat(thePlayer, commandName)
	if exports.mek_integration:isPlayerManager(thePlayer) then
		local hideManagerChat = getElementData(thePlayer, "hide_manager_chat") or false
		setElementData(thePlayer, "hide_manager_chat", not hideManagerChat)
		outputChatBox(
			"[!]#FFFFFF Yönetim sohbeti başarıyla " .. (hideManagerChat and "açıldı" or "kapatıldı") .. ".",
			thePlayer,
			0,
			255,
			0,
			true
		)
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("togu", toggleManagerChat, false, false)
addCommandHandler("toggleu", toggleManagerChat, false, false)

function toggleAdminChat(thePlayer, commandName)
	if exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
		local hideAdminChat = getElementData(thePlayer, "hide_admin_chat") or false
		setElementData(thePlayer, "hide_admin_chat", not hideAdminChat)
		outputChatBox(
			"[!]#FFFFFF Yetkili sohbeti başarıyla " .. (hideAdminChat and "açıldı" or "kapatıldı") .. ".",
			thePlayer,
			0,
			255,
			0,
			true
		)
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("toga", toggleAdminChat, false, false)
addCommandHandler("togglea", toggleAdminChat, false, false)

function toggleGacChat(thePlayer, commandName)
	if exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
		local hideGacChat = getElementData(thePlayer, "hide_gac_chat") or false
		setElementData(thePlayer, "hide_gac_chat", not hideGacChat)
		outputChatBox(
			"[!]#FFFFFF Sunucular arası sohbeti başarıyla " .. (hideGacChat and "açıldı" or "kapatıldı") .. ".",
			thePlayer,
			0,
			255,
			0,
			true
		)
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("toggac", toggleGacChat, false, false)
addCommandHandler("togglegac", toggleGacChat, false, false)

function governmentOOC(thePlayer, commandName, ...)
	if exports.mek_faction:isPlayerInFaction(thePlayer, { 1, 2, 3, 4 }) then
		if ... then
			local message = table.concat({ ... }, " ")
			if getElementData(thePlayer, "chat_spelling") then
				message = formatSentence(message)
			end

			for _, player in ipairs(getElementsByType("player")) do
				if exports.mek_faction:isPlayerInFaction(player, { 1, 2, 3, 4 }) then
					outputChatBox(
						"[Hükümet OOC] " .. getPlayerName(thePlayer):gsub("_", " ") .. ": " .. message,
						player,
						255,
						255,
						255
					)
				end
			end
			exports.mek_logs:addLog("gooc-chat", getPlayerName(thePlayer):gsub("_", " ") .. ": " .. message)
		else
			outputChatBox("Kullanım: /" .. commandName .. " [Mesaj]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox(
			"[!]#FFFFFF Bu işlemi yalnızca legal birlik üyeleri gerçekleştirebilir.",
			thePlayer,
			255,
			0,
			0,
			true
		)
	end
end
addCommandHandler("gooc", governmentOOC, false, false)

function governmentAnnouncement(thePlayer, commandName, ...)
	if exports.mek_faction:isPlayerInFaction(thePlayer, { 1, 2, 3, 4 }) then
		if ... then
			local message = table.concat({ ... }, " ")
			if getElementData(thePlayer, "chat_spelling") then
				message = formatSentence(message)
			end

			for _, player in ipairs(getElementsByType("player")) do
				if getElementData(player, "logged") then
					outputChatBox(
						">> Hükümet Duyurusu " .. getPlayerName(thePlayer):gsub("_", " "),
						player,
						0,
						183,
						239
					)
					outputChatBox(message, player, 0, 183, 239)
				end
			end
		else
			outputChatBox("Kullanım: /" .. commandName .. " [Mesaj]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("[!]#FFFFFF Yalnız legal birlik üyeleri bu komutu kullanabilir.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("gov", governmentAnnouncement, false, false)

function departmentRadio(thePlayer, commandName, ...)
	if exports.mek_faction:isPlayerInFaction(thePlayer, { 1, 2, 3, 4 }) then
		if ... then
			local message = table.concat({ ... }, " ")
			radio(thePlayer, -1, message)
		else
			outputChatBox("Kullanım: /" .. commandName .. " [Mesaj]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("[!]#FFFFFF Yalnız legal birlik üyeleri bu komutu kullanabilirr.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("dep", departmentRadio, false, false)
addCommandHandler("department", departmentRadio, false, false)

function icPublicAnnouncement(thePlayer, commandName, ...)
	if ... then
		local message = table.concat({ ... }, " ")
		radio(thePlayer, -3, message)
	else
		outputChatBox("Kullanım: /" .. commandName .. " [Mesaj]", thePlayer, 255, 194, 14)
	end
end
addCommandHandler("pa", icPublicAnnouncement, false, false)

function adminAnnouncement(thePlayer, commandName, ...)
	if exports.mek_integration:isPlayerServerManager(thePlayer) then
		if ... then
			local message = table.concat({ ... }, " ")
			if getElementData(thePlayer, "chat_spelling") then
				message = formatSentence(message)
			end

			local adminName = "("
				.. getElementData(thePlayer, "id")
				.. ") "
				.. exports.mek_global:getPlayerAdminTitle(thePlayer)
				.. " "
				.. getElementData(thePlayer, "account_username")

			for _, player in ipairs(getElementsByType("player")) do
				if getElementData(player, "logged") then
					exports.mek_infobox:addBox(player, "announcement", adminName .. ": " .. message)
				end
			end

			exports.mek_logs:addLog("duyuru", adminName .. ": " .. message)
		else
			outputChatBox("Kullanım: /" .. commandName .. " [Mesaj]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("duyuru", adminAnnouncement, false, false)

function globalOOC(thePlayer, commandName, ...)
	if exports.mek_integration:isPlayerSeniorAdmin(thePlayer) then
		if ... then
			local message = table.concat({ ... }, " ")
			if getElementData(thePlayer, "chat_spelling") then
				message = formatSentence(message)
			end

			local adminName = "("
				.. getElementData(thePlayer, "id")
				.. ") "
				.. exports.mek_global:getPlayerAdminTitle(thePlayer)
				.. " "
				.. getElementData(thePlayer, "account_username")

			for _, player in ipairs(getElementsByType("player")) do
				if getElementData(player, "logged") then
					outputChatBox(
						"[OOC] #FF0000" .. adminName .. "#CCFFFF: " .. message .. " ))",
						player,
						196,
						255,
						255,
						true
					)
				end
			end

			exports.mek_logs:addLog("global-ooc-chat", adminName .. ": " .. message)
		else
			outputChatBox("Kullanım: /" .. commandName .. " [Mesaj]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("ooc", globalOOC, false, false)
addCommandHandler("GlobalOOC", globalOOC)

function pmPlayer(thePlayer, commandName, targetPlayer, ...)
	local message = nil
	if tostring(commandName):lower() == "hızlıyanıt" and targetPlayer then
		local targetPMer = getElementData(thePlayer, "targetPMer")
		if
			not targetPMer
			or not isElement(targetPMer)
			or not (getElementType(targetPMer) == "player")
			or not (getElementData(targetPMer, "logged"))
		then
			outputChatBox("[!]#FFFFFF Kimse sana özel mesaj göndermedi.", thePlayer, 255, 0, 0, true)
			return
		end
		message = targetPlayer .. " " .. table.concat({ ... }, " ")
		targetPlayer = targetPMer
	else
		if not targetPlayer or not (...) then
			outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID] [Mesaj]", thePlayer, 255, 194, 14)
			return
		end
		message = table.concat({ ... }, " ")
	end

	if targetPlayer and message and getElementData(thePlayer, "logged") then
		local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)

		if targetPlayer then
			if not getElementData(targetPlayer, "logged") then
				outputChatBox(
					"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
					thePlayer,
					255,
					0,
					0,
					true
				)
				return
			end

			if
				getElementData(thePlayer, "admin_jailed")
				and not exports.mek_integration:isPlayerTrialAdmin(targetPlayer)
			then
				outputChatBox(
					"[!]#FFFFFF OOC hapishanesindeyken yalnızca yetkililere özel mesaj gönderebilirsiniz.",
					thePlayer,
					255,
					0,
					0,
					true
				)
				return
			end

			if getElementData(thePlayer, "private_message_state") then
				outputChatBox(
					"[!]#FFFFFF Özel mesajlaşmanız devre dışı bırakıldığı için mesaj gönderemediniz.",
					thePlayer,
					255,
					0,
					0,
					true
				)
				return
			end

			if getElementData(targetPlayer, "private_message_state") then
				outputChatBox(
					"[!]#FFFFFF Mesajlaştığınız oyuncu özel mesajlaşmayı kapattığı için mesaj gönderemediniz.",
					thePlayer,
					255,
					0,
					0,
					true
				)
				return
			end

			setElementData(targetPlayer, "targetPMer", thePlayer)

			local playerName = getPlayerName(thePlayer):gsub("_", " ")
			local targetUsername1, username1 =
				getElementData(targetPlayer, "account_username"), getElementData(thePlayer, "account_username")

			local targetUsername = " (" .. targetUsername1 .. ")"
			local username = " (" .. username1 .. ")"

			if not exports.mek_integration:isPlayerTrialAdmin(targetPlayer) then
				username = ""
			end

			if not exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
				targetUsername = ""
			end

			if getElementData(thePlayer, "chat_spelling") then
				message = formatSentence(message)
			end

			local playerID = getElementData(thePlayer, "id")
			local targetID = getElementData(targetPlayer, "id")

			outputChatBox(
    "(Giden) >> " .. targetPlayerName .. " (" .. targetID .. ") " .. targetUsername .. ": " .. message,
    thePlayer,
    255,
    194,
    14
)
triggerClientEvent(thePlayer, "pm.client", thePlayer)

outputChatBox(
    "(Gelen) << " .. playerName .. " (" .. playerID .. ") " .. username .. ": " .. message,
    targetPlayer,
    255,
    255,
    0
)
			triggerClientEvent(targetPlayer, "pm.client", targetPlayer)

			if getElementData(targetPlayer, "afk") then
				exports.mek_infobox:addBox(
					thePlayer,
					"info",
					"Mesaj göndermeye çalıştığınız oyuncu ALT-TAB, ancak mesajınız iletiliyor."
				)
			end

			exports.mek_logs:addLog("pm-chat", playerName .. " -> " .. targetPlayerName .. ": " .. message)
		end
	end
end
addCommandHandler("pm", pmPlayer, false, false)
addCommandHandler("om", pmPlayer, false, false)
addCommandHandler("hızlıyanıt", pmPlayer, false, false)

function togPM(thePlayer, commandName)
	if exports.mek_integration:isPlayerTrialAdmin(thePlayer) or (getElementData(thePlayer, "vip") > 0) then
		if not getElementData(thePlayer, "private_message_state") then
			outputChatBox(
				"[!]#FFFFFF Özel mesajlarınızı başarıyla devre dışı bıraktınız.",
				thePlayer,
				255,
				0,
				0,
				true
			)
			setElementData(thePlayer, "private_message_state", true)
		else
			outputChatBox(
				"[!]#FFFFFF Özel mesajlarınızı başarıyla etkinleştirdiniz.",
				thePlayer,
				0,
				255,
				0,
				true
			)
			setElementData(thePlayer, "private_message_state", false)
		end
	end
end
addCommandHandler("pmkapat", togPM, false, false)
addCommandHandler("pmac", togPM, false, false)
addCommandHandler("togpm", togPM, false, false)

function localShout(thePlayer, commandName, ...)
	local interior = getElementInterior(thePlayer)
	local dimension = getElementDimension(thePlayer)
	local vehicle = getPedOccupiedVehicle(thePlayer)
	local seat = getPedOccupiedVehicleSeat(thePlayer)

	if not (...) then
		outputChatBox("Kullanım: /" .. commandName .. " [Mesaj]", thePlayer, 255, 194, 14)
	else
		local affectedElements = {}

		local message = table.concat({ ... }, " ")
		if getElementData(thePlayer, "chat_spelling") then
			message = formatSentence(message)
		end

		local r, g, b = 255, 255, 255
		local focus = getElementData(thePlayer, "focus")
		if type(focus) == "table" then
			for player, color in pairs(focus) do
				if player == thePlayer then
					r, g, b = unpack(color)
				end
			end
		end

		for _, player in ipairs(getElementsByType("player")) do
			if getElementDistance(thePlayer, player) < 40 then
				local playerDimension = getElementDimension(player)
				local playerInterior = getElementInterior(player)
				if (playerInterior == interior) and (playerDimension == dimension) then
					if not (isPedDead(player)) and getElementData(player, "logged") then
						table.insert(affectedElements, player)

						local r, g, b = 255, 255, 255
						local focus = getElementData(player, "focus")
						if type(focus) == "table" then
							for player, color in pairs(focus) do
								if player == thePlayer then
									r, g, b = unpack(color)
								end
							end
						end

						outputChatBox(
							getPlayerName(thePlayer):gsub("_", " ") .. " (Bağırma): " .. message .. "!",
							player,
							r,
							g,
							b
						)
					end
				end
			end
		end
	end
end
addCommandHandler("s", localShout, false, false)

function toggleFaction(thePlayer, commandName)
	local factionDetails = getElementData(thePlayer, "faction")

	local organizedTable = {}
	for i, k in pairs(factionDetails) do
		organizedTable[k.count] = i
	end

	if commandName == "togglef" or commandName == "togf" then
		commandName = "togf1"
	end

	local pF = organizedTable[tonumber(string.sub(commandName, 5)) or tonumber(string.sub(commandName, 8))]
	if not pF then
		return
	end

	local fL = exports.mek_faction:hasMemberPermissionTo(thePlayer, pF, "toggle_chat")
	local theTeam = exports.mek_faction:getFactionFromID(pF)
	local theTeamName = getTeamName(theTeam)

	if fL then
		if factionToggleState[pF] == false or not factionToggleState[pF] then
			factionToggleState[pF] = true
			for i, player in ipairs(getElementsByType("player")) do
				if isElement(player) then
					if exports.mek_faction:isPlayerInFaction(player, pF) and getElementData(thePlayer, "logged") then
						outputChatBox(
							"[" .. theTeamName .. "] OOC birlik sohbeti devredışı bırakıldı.",
							player,
							255,
							0,
							0
						)
					end
				end
			end
		else
			factionToggleState[pF] = false
			for i, player in ipairs(getElementsByType("player")) do
				if isElement(player) then
					if exports.mek_faction:isPlayerInFaction(player, pF) and getElementData(thePlayer, "logged") then
						outputChatBox("[" .. theTeamName .. "] OOC birlik sohbeti açıldı.", player, 0, 255, 0)
					end
				end
			end
		end
	end
end
addCommandHandler("togglef", toggleFaction, false, false)
addCommandHandler("togf", toggleFaction, false, false)
addCommandHandler("togglef1", toggleFaction, false, false)
addCommandHandler("togf1", toggleFaction, false, false)
addCommandHandler("togglef2", toggleFaction, false, false)
addCommandHandler("togf2", toggleFaction, false, false)
addCommandHandler("togglef3", toggleFaction, false, false)
addCommandHandler("togf3", toggleFaction, false, false)
addCommandHandler("togglef4", toggleFaction, false, false)
addCommandHandler("togf4", toggleFaction, false, false)
addCommandHandler("togglef5", toggleFaction, false, false)
addCommandHandler("togf5", toggleFaction, false, false)

function toggleFactionSelf(thePlayer, commandName)
	local toggleFactionChat = getElementData(thePlayer, "toggle_faction_chat") or false
	setElementData(thePlayer, "toggle_faction_chat", not toggleFactionChat)
	outputChatBox(
		"[!]#FFFFFF Birlik sohbet başarıyla kendinizden "
			.. (toggleFactionChat and "aktifleştirildi" or "kapatıldı")
			.. ".",
		thePlayer,
		0,
		255,
		0,
		true
	)
end
addCommandHandler("togglefactionchat", toggleFactionSelf, false, false)
addCommandHandler("togglefaction", toggleFactionSelf, false, false)
addCommandHandler("togfaction", toggleFactionSelf, false, false)

function factionOOC(thePlayer, commandName, ...)
	if not (...) then
		outputChatBox("Kullanım: /" .. commandName .. " [Mesaj]", thePlayer, 255, 194, 14)
	else
		if commandName == "f" or commandName == "Birlik" then
			commandName = "f1"
		end

		local message = table.concat({ ... }, " ")
		if getElementData(thePlayer, "chat_spelling") then
			message = formatSentence(message)
		end

		local playerName = getPlayerName(thePlayer):gsub("_", " ")
		local factionDetails = getElementData(thePlayer, "faction")

		local organizedTable = {}
		for i, k in pairs(factionDetails) do
			organizedTable[k.count] = i
		end

		local playerFaction = organizedTable[tonumber(string.sub(commandName, 2))]
		if not playerFaction then
			outputChatBox("[!]#FFFFFF Hiç bir birlikde değilsiniz.", thePlayer, 255, 0, 0, true)
			return
		end

		local theTeam = exports.mek_faction:getFactionFromID(playerFaction)
		local theTeamName = getTeamName(theTeam)
		local factionRanks = getElementData(theTeam, "ranks")
		local playerFactionRank = exports.mek_faction:getPlayerFactionRank(thePlayer, playerFaction)
		local factionRankTitle = factionRanks[factionDetails[playerFaction].rank]

		if factionToggleState[playerFaction] then
			return
		end

		for _, player in ipairs(getElementsByType("player")) do
			if
				exports.mek_faction:isPlayerInFaction(player, playerFaction)
				and getElementData(player, "logged")
				and not getElementData(player, "toggle_faction_chat")
			then
				outputChatBox(
					"[" .. theTeamName .. "] (" .. factionRankTitle .. ") " .. playerName .. ": " .. message,
					player,
					249,
					160,
					41
				)
			end
		end

		exports.mek_logs:addLog(
			"faction-chat",
			"[" .. theTeamName .. "] (" .. factionRankTitle .. ") " .. playerName .. ": " .. message
		)
	end
end
addCommandHandler("f", factionOOC, false, false)
addCommandHandler("f1", factionOOC, false, false)
addCommandHandler("f2", factionOOC, false, false)
addCommandHandler("f3", factionOOC, false, false)
addCommandHandler("f4", factionOOC, false, false)
addCommandHandler("f5", factionOOC, false, false)
addCommandHandler("Birlik", factionOOC, false, false)

function factionLeaderOOC(thePlayer, commandName, ...)
	if not (...) then
		outputChatBox("Kullanım: /" .. commandName .. " [Mesaj]", thePlayer, 255, 194, 14)
	else
		if commandName == "fl" then
			commandName = "fl1"
		end

		local message = table.concat({ ... }, " ")
		local playerName = getPlayerName(thePlayer):gsub("_", " ")
		local factionDetails = getElementData(thePlayer, "faction")

		local organizedTable = {}
		for i, k in pairs(factionDetails) do
			organizedTable[k.count] = i
		end

		local playerFaction = organizedTable[tonumber(string.sub(commandName, 3))]
		if not playerFaction then
			outputChatBox("[!]#FFFFFF Hiç bir birlikde değilsiniz.", thePlayer, 255, 0, 0, true)
			return
		end

		if not exports.mek_faction:hasMemberPermissionTo(thePlayer, playerFaction, "use_fl") then
			outputChatBox("[!]#FFFFFF Hiç bir birlikde lider değilsiniz.", thePlayer, 255, 0, 0, true)
		else
			local theTeam = exports.mek_faction:getFactionFromID(playerFaction)
			local theTeamName = getTeamName(theTeam)
			local factionRanks = getElementData(theTeam, "ranks")
			local playerFactionRank = exports.mek_faction:getPlayerFactionRank(thePlayer, playerFaction)
			local factionRankTitle = factionRanks[factionDetails[playerFaction].rank]

			if factionToggleState[playerFaction] then
				return
			end

			if getElementData(thePlayer, "chat_spelling") then
				message = formatSentence(message)
			end

			for _, player in ipairs(getElementsByType("player")) do
				if
					exports.mek_faction:isPlayerInFaction(player, playerFaction)
					and getElementData(player, "logged")
					and not getElementData(player, "toggle_faction_chat")
					and exports.mek_faction:hasMemberPermissionTo(player, playerFaction, "use_fl")
				then
					outputChatBox(
						"[" .. theTeamName .. "] (" .. factionRankTitle .. ") " .. playerName .. ": " .. message,
						player,
						176,
						115,
						52
					)
				end
			end

			exports.mek_logs:addLog(
				"faction-leader-chat",
				"[" .. theTeamName .. "] (" .. factionRankTitle .. ") " .. playerName .. ": " .. message
			)
		end
	end
end
addCommandHandler("fl", factionLeaderOOC, false, false)
addCommandHandler("fl1", factionLeaderOOC, false, false)
addCommandHandler("fl2", factionLeaderOOC, false, false)
addCommandHandler("fl3", factionLeaderOOC, false, false)
addCommandHandler("fl4", factionLeaderOOC, false, false)
addCommandHandler("fl5", factionLeaderOOC, false, false)

function setRadioChannel(thePlayer, commandName, channel)
	channel = tonumber(channel)
	if channel then
		if exports.mek_item:hasItem(thePlayer, 6) then
			local items = exports.mek_item:getItems(thePlayer)
			for k, v in ipairs(items) do
				if v[1] == 6 then
					if v[2] > 0 then
						local isRestricted, factionID = isThisFreqRestricted(channel)
						local playerFaction = getElementData(thePlayer, "faction")

						if
							channel > 1
							and channel < 1000000000
							and (not isRestricted or (tonumber(playerFaction) == tonumber(factionID)))
						then
							if exports.mek_item:updateItemValue(thePlayer, k, channel) then
								setElementData(thePlayer, "radio_frequency", channel)
								outputChatBox(
									"[!]#FFFFFF Telsiziniz başarıyla [" .. channel .. "] kanalına bağlandı.",
									thePlayer,
									0,
									255,
									0,
									true
								)
								exports.mek_global:sendLocalMeAction(thePlayer, "telsizin frekansını ayarlar.")
							end
						else
							outputChatBox(
								"[!]#FFFFFF Telsizinizi bu kanala ayarlayamazsınız.",
								thePlayer,
								255,
								0,
								0,
								true
							)
						end
					else
						outputChatBox("[!]#FFFFFF Telsiziniz kapalı.", thePlayer, 255, 0, 0, true)
					end
					return
				end
			end
		else
			outputChatBox("[!]#FFFFFF Telsiziniz yok.", thePlayer, 255, 0, 0, true)
		end
	else
		outputChatBox("Kullanım: /" .. commandName .. " [Kanal Numarası]", thePlayer, 255, 194, 14)
	end
end
addCommandHandler("telsizbagla", setRadioChannel, false, false)
addCommandHandler("tuneradio", setRadioChannel, false, false)

function toggleRadio(thePlayer, commandName, slot)
	if exports.mek_item:hasItem(thePlayer, 6) then
		local slot = tonumber(slot)
		local items = exports.mek_item:getItems(thePlayer)
		local titemValue = false
		local count = 0
		for k, v in ipairs(items) do
			if v[1] == 6 then
				if slot then
					count = count + 1
					if count == slot then
						titemValue = v[2]
						break
					end
				else
					titemValue = v[2]
					break
				end
			end
		end

		if titemValue < 0 then
			outputChatBox("[!]#FFFFFF Telsizinizi başarıyla açtınız.", thePlayer, 0, 255, 0, true)
			exports.mek_global:sendLocalMeAction(thePlayer, "telsizini açar.")
		else
			outputChatBox("[!]#FFFFFF Telsizinizi başarıyla kapattınız.", thePlayer, 0, 255, 0, true)
			exports.mek_global:sendLocalMeAction(thePlayer, "telsizini kapatır.")
		end

		local count = 0
		for k, v in ipairs(items) do
			if v[1] == 6 then
				if slot then
					count = count + 1
					if count == slot then
						exports.mek_item:updateItemValue(
							thePlayer,
							k,
							(titemValue < 0 and 1 or -1) * math.abs(v[2] or 1)
						)
						break
					end
				else
					exports.mek_item:updateItemValue(thePlayer, k, (titemValue < 0 and 1 or -1) * math.abs(v[2] or 1))
				end
			end
		end
	else
		outputChatBox("[!]#FFFFFF Telsiziniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("toggleradio", toggleRadio, false, false)

function localWhisper(thePlayer, commandName, targetPlayerNick, ...)
	if not targetPlayerNick or not (...) then
		outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID] [Mesaj]", thePlayer, 255, 194, 14)
	else
		local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayerNick)

		if targetPlayer then
			local x, y, z = getElementPosition(thePlayer)
			local tx, ty, tz = getElementPosition(targetPlayer)

			if getDistanceBetweenPoints3D(x, y, z, tx, ty, tz) < 3 then
				local message = table.concat({ ... }, " ")
				if getElementData(thePlayer, "chat_spelling") then
					message = formatSentence(message)
				end

				exports.mek_global:sendLocalMeAction(thePlayer, targetPlayerName .. " kişisine fısıldar.")

				local r, g, b = 255, 255, 255
				local focus = getElementData(thePlayer, "focus")
				if type(focus) == "table" then
					for player, color in pairs(focus) do
						if player == thePlayer then
							r, g, b = unpack(color)
						end
					end
				end

				outputChatBox(
					getPlayerName(thePlayer):gsub("_", " ") .. " (Fısıltı): " .. message,
					thePlayer,
					r,
					g,
					b
				)

				local r, g, b = 255, 255, 255
				local focus = getElementData(targetPlayer, "focus")
				if type(focus) == "table" then
					for player, color in pairs(focus) do
						if player == thePlayer then
							r, g, b = unpack(color)
						end
					end
				end

				outputChatBox(
					getPlayerName(thePlayer):gsub("_", " ") .. " (Fısıltı): " .. message,
					targetPlayer,
					r,
					g,
					b
				)

				for _, player in ipairs(getElementsByType("player")) do
					if player ~= targetPlayer and player ~= thePlayer then
						local ax, ay, az = getElementPosition(player)
						if getDistanceBetweenPoints3D(x, y, z, ax, ay, az) < 4 then
							local playerVeh = getPedOccupiedVehicle(thePlayer)
							local targetVeh = getPedOccupiedVehicle(targetPlayer)
							local pVeh = getPedOccupiedVehicle(player)
							if playerVeh then
								if pVeh then
									if pVeh == playerVeh then
										outputChatBox(
											getPlayerName(thePlayer):gsub("_", " ")
												.. " (Fısıltı) "
												.. targetPlayerName
												.. ": "
												.. message,
											player,
											255,
											255,
											255
										)
									end
								end
							else
								outputChatBox(
									getPlayerName(thePlayer):gsub("_", " ")
										.. " (Fısıltı) "
										.. targetPlayerName
										.. ": "
										.. message,
									player,
									255,
									255,
									255
								)
							end
						end
					end
				end
			else
				outputChatBox(
					"[!]#FFFFFF " .. targetPlayerName .. " isimli oyuncudan çok uzaktasınız.",
					thePlayer,
					255,
					0,
					0,
					true
				)
			end
		end
	end
end
addCommandHandler("w", localWhisper, false, false)

function localClose(thePlayer, commandName, ...)
	if not (...) then
		outputChatBox("Kullanım: /" .. commandName .. " [Mesaj]", thePlayer, 255, 194, 14)
	else
		local affectedElements = {}

		local message = table.concat({ ... }, " ")
		if getElementData(thePlayer, "chat_spelling") then
			message = formatSentence(message)
		end

		local playerCar = getPedOccupiedVehicle(thePlayer)
		for index, targetPlayers in ipairs(getElementsByType("player")) do
			if getElementDistance(thePlayer, targetPlayers) < 3 then
				local r, g, b = 255, 255, 255
				local focus = getElementData(targetPlayers, "focus")
				if type(focus) == "table" then
					for player, color in pairs(focus) do
						if player == thePlayer then
							r, g, b = unpack(color)
						end
					end
				end
				local pveh = getPedOccupiedVehicle(targetPlayers)
				if playerCar then
					if not exports.mek_vehicle:isVehicleWindowUp(playerCar) then
						if pveh then
							if playerCar == pveh then
								table.insert(affectedElements, targetPlayers)
								outputChatBox(
									getPlayerName(thePlayer):gsub("_", " ") .. " (Kısık Ses): " .. message,
									targetPlayers,
									r,
									g,
									b
								)
							elseif not (exports.mek_vehicle:isVehicleWindowUp(pveh)) then
								table.insert(affectedElements, targetPlayers)
								outputChatBox(
									getPlayerName(thePlayer):gsub("_", " ") .. " (Kısık Ses): " .. message,
									targetPlayers,
									r,
									g,
									b
								)
							end
						else
							table.insert(affectedElements, targetPlayers)
							outputChatBox(
								getPlayerName(thePlayer):gsub("_", " ") .. " (Kısık Ses): " .. message,
								targetPlayers,
								r,
								g,
								b
							)
						end
					else
						if pveh then
							if pveh == playerCar then
								table.insert(affectedElements, targetPlayers)
								outputChatBox(
									getPlayerName(thePlayer):gsub("_", " ") .. " (Kısık Ses): " .. message,
									targetPlayers,
									r,
									g,
									b
								)
							end
						end
					end
				else
					if pveh then
						if playerCar then
							if playerCar == pveh then
								table.insert(affectedElements, targetPlayers)
								outputChatBox(
									getPlayerName(thePlayer):gsub("_", " ") .. " (Kısık Ses): " .. message,
									targetPlayers,
									r,
									g,
									b
								)
							end
						elseif not (exports.mek_vehicle:isVehicleWindowUp(pveh)) then
							table.insert(affectedElements, targetPlayers)
							outputChatBox(
								getPlayerName(thePlayer):gsub("_", " ") .. " (Kısık Ses): " .. message,
								targetPlayers,
								r,
								g,
								b
							)
						end
					else
						table.insert(affectedElements, targetPlayers)
						outputChatBox(
							getPlayerName(thePlayer):gsub("_", " ") .. " (Kısık Ses): " .. message,
							targetPlayers,
							r,
							g,
							b
						)
					end
				end
			end
		end
	end
end
addCommandHandler("c", localClose, false, false)

function focus(thePlayer, commandName, targetPlayer, r, g, b)
	local focus = getElementData(thePlayer, "focus")
	if targetPlayer then
		local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
		if targetPlayer then
			if type(focus) ~= "table" then
				focus = {}
			end

			if focus[targetPlayer] and not r then
				outputChatBox(
					"Vurgulamayı kapatdınız: "
						.. string.format("#%02x%02x%02x", unpack(focus[targetPlayer]))
						.. targetPlayerName
						.. "#ffc20e.",
					thePlayer,
					255,
					194,
					14,
					true
				)
				focus[targetPlayer] = nil
			else
				color = {
					tonumber(r) or math.random(63, 255),
					tonumber(g) or math.random(63, 255),
					tonumber(b) or math.random(63, 255),
				}
				for _, v in ipairs(color) do
					if v < 0 or v > 255 then
						outputChatBox("Geçersiz renk: " .. v, thePlayer, 255, 0, 0)
						return
					end
				end

				focus[targetPlayer] = color
				outputChatBox(
					"Vurgulamayı açtınız: "
						.. string.format("#%02x%02x%02x", unpack(focus[targetPlayer]))
						.. targetPlayerName
						.. "#00ff00.",
					thePlayer,
					0,
					255,
					0,
					true
				)
			end
			setElementData(thePlayer, "focus", focus, false)
		end
	else
		if type(focus) == "table" then
			outputChatBox("İzliyorsun: ", thePlayer, 255, 194, 14)
			for player, color in pairs(focus) do
				outputChatBox(">> " .. getPlayerName(player):gsub("_", " "), thePlayer, unpack(color))
			end
		end
		outputChatBox(
			"Birisini eklemek için, /"
				.. commandName
				.. " [player] [optional red/green/blue], to remove just /"
				.. commandName
				.. " [player] again.",
			thePlayer,
			255,
			194,
			14
		)
	end
end
addCommandHandler("focus", focus, false, false)
addCommandHandler("highlight", focus, false, false)

function temizleCommand(thePlayer, commandName)
	if exports.mek_integration:isPlayerServerManager(thePlayer) then
		for i = 0, 50 do
			outputChatBox(" ", root)
			outputChatBox(" ", root)
		end
	end
end
addCommandHandler("temizle", temizleCommand, false, false)

function districtIC(thePlayer, commandName, ...)
	if exports.mek_integration:isPlayerAdmin3(thePlayer) then
		if ... then
			local message = table.concat({ ... }, " ")
			if getElementData(thePlayer, "chat_spelling") then
				message = formatSentence(message)
			end

			outputChatBox(">> " .. message, root, 255, 194, 14)
		else
			outputChatBox("Kullanım: /" .. commandName .. " [Mesaj]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox(
			"[!]#FFFFFF Bu komutu kullanabilmek için gerekli yetkiye sahip değilsiniz.",
			thePlayer,
			255,
			0,
			0,
			true
		)
	end
end
addCommandHandler("district", districtIC, false, false)

local function sendFactionRadioMessage(thePlayer, commandName, channelInfo, ...)
	if not channelInfo then
		channelInfo = ""
	end

	if not (...) then
		outputChatBox("Kullanım: /" .. commandName .. " [Mesaj]", thePlayer, 255, 194, 14)
		return
	end

	local factionDetails = getElementData(thePlayer, "faction")
	if not factionDetails or type(factionDetails) ~= "table" then
		outputChatBox("[!]#FFFFFF Hiç bir birlik üyesi değilsiniz.", thePlayer, 255, 0, 0, true)
		return
	end

	local factionID
	for id in pairs(factionDetails) do
		if exports.mek_faction:isPlayerInFaction(thePlayer, id) then
			factionID = id
			break
		end
	end
	if not factionID then
		outputChatBox("[!]#FFFFFF Hiç bir birlik üyesi değilsiniz.", thePlayer, 255, 0, 0, true)
		return
	end

	if getElementData(thePlayer, "restrained") or getElementData(thePlayer, "dead") then
		outputChatBox(
			"[!]#FFFFFF Kelepçeli veya baygın durumdayken telsizi kullanamazsınız.",
			thePlayer,
			255,
			0,
			0,
			true
		)
		return
	end

	local theTeam = exports.mek_faction:getFactionFromID(factionID)
	local factionRanks = getElementData(theTeam, "ranks")
	local playerFactionRank = exports.mek_faction:getPlayerFactionRank(thePlayer, factionID)
	local factionRankTitle = factionRanks[playerFactionRank] or "Bilinmeyen"
	local playerName = getPlayerName(thePlayer):gsub("_", " ")
	local location = exports.mek_global:getZoneName(thePlayer.position)

	local message = table.concat({ ... }, " ")
	if getElementData(thePlayer, "chat_spelling") then
		message = formatSentence(message)
	end

	local r, g, b = 255, 255, 255
	if factionID == 1 then
		r, g, b = 65, 65, 255
	elseif factionID == 2 then
		r, g, b = 255, 130, 130
	elseif factionID == 3 then
		r, g, b = 0, 80, 0
	end

	local fadeColors = {
		{ 4, { 0xEE, 0xEE, 0xEE } },
		{ 8, { 0xDD, 0xDD, 0xDD } },
		{ 12, { 0xCC, 0xCC, 0xCC } },
		{ 16, { 0xBB, 0xBB, 0xBB } },
		{ 20, { 0xAA, 0xAA, 0xAA } },
	}

	local targetFactionIDs = factionID
	if (commandName == "op" or commandName == "operator") and (factionID == 1 or factionID == 2 or factionID == 3) then
		targetFactionIDs = { 1, 2, 3 }
	end

	for _, player in ipairs(getElementsByType("player")) do
		if exports.mek_faction:isPlayerInFaction(player, targetFactionIDs) then
			outputChatBox(
				channelInfo
					.. " "
					.. factionRankTitle
					.. " "
					.. playerName
					.. ": "
					.. message
					.. "; "
					.. location
					.. ".",
				player,
				r,
				g,
				b,
				true
			)
			triggerClientEvent(player, "playCustomChatSound", root, "radio.mp3")
		end
	end

	for _, player in ipairs(getElementsByType("player")) do
		if player ~= thePlayer and not exports.mek_faction:isPlayerInFaction(player, targetFactionIDs) then
			if player.interior == thePlayer.interior and player.dimension == thePlayer.dimension then
				local distance = getDistanceBetweenPoints3D(thePlayer.position, player.position)
				for _, fade in ipairs(fadeColors) do
					if distance <= fade[1] then
						local fr, fg, fb = unpack(fade[2])
						outputChatBox(playerName .. " (Telsiz): " .. message, player, fr, fg, fb, true)
						break
					end
				end
			end
		end
	end
end

function operatorCommand(thePlayer, commandName, ...)
	if exports.mek_faction:isPlayerInFaction(thePlayer, { 1, 2, 3 }) then
		sendFactionRadioMessage(thePlayer, commandName, "** [OP: 155]", ...)
	else
		outputChatBox(
			"[!]#FFFFFF Bu işlemi yalnızca legal birlik üyeleri gerçekleştirebilir.",
			thePlayer,
			255,
			0,
			0,
			true
		)
	end
end
addCommandHandler("op", operatorCommand, false, false)
addCommandHandler("operator", operatorCommand, false, false)

function yakaTelsizCommand(thePlayer, commandName, ...)
	if exports.mek_faction:isPlayerInFaction(thePlayer, { 1, 2, 3 }) then
		sendFactionRadioMessage(thePlayer, commandName, "** [CH: 155 S: YAKIN]", ...)
	else
		outputChatBox(
			"[!]#FFFFFF Bu işlemi yalnızca legal birlik üyeleri gerçekleştirebilir.",
			thePlayer,
			255,
			0,
			0,
			true
		)
	end
end
addCommandHandler("yt", yakaTelsizCommand, false, false)
addCommandHandler("yakatelsiz", yakaTelsizCommand, false, false)

function telsizCommand(thePlayer, commandName, ...)
	if exports.mek_faction:isPlayerInFaction(thePlayer, { 1, 2, 3 }) then
		sendFactionRadioMessage(thePlayer, commandName, "** [CH: 155]", ...)
	else
		outputChatBox(
			"[!]#FFFFFF Bu işlemi yalnızca legal birlik üyeleri gerçekleştirebilir.",
			thePlayer,
			255,
			0,
			0,
			true
		)
	end
end
addCommandHandler("t", telsizCommand, false, false)
addCommandHandler("telsiz", telsizCommand, false, false)

local function findNearbyPlayer(thePlayer, targetPlayer)
	local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
	if not targetPlayer then
		return nil
	end

	if targetPlayer == thePlayer then
		outputChatBox("[!]#FFFFFF Kendinize bu işlemi uygulayamazsınız.", thePlayer, 255, 0, 0, true)
		return nil
	end

	local x, y, z = getElementPosition(thePlayer)
	local tx, ty, tz = getElementPosition(targetPlayer)

	if getDistanceBetweenPoints3D(x, y, z, tx, ty, tz) > 3 then
		outputChatBox("[!]#FFFFFF Bu kişiye göstermek için yakında olmalısınız.", thePlayer, 255, 0, 0, true)
		return nil
	end

	return targetPlayer
end

local function showID(thePlayer, commandName, targetPlayer)
	if not targetPlayer then
		outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID]", thePlayer, 255, 194, 14)
		return
	end

	local targetPlayer = findNearbyPlayer(thePlayer, targetPlayer)
	if not targetPlayer then
		return
	end

	local identityCard
	for _, item in ipairs(exports.mek_item:getItems(thePlayer)) do
		if item[1] == 152 then
			identityCard = item[2]
			break
		end
	end

	if not identityCard then
		outputChatBox("[!]#FFFFFF Kimliğiniz yok.", thePlayer, 255, 0, 0, true)
		return
	end

	local itemExploded = split(identityCard, ";")

	outputChatBox(
		"[!]#FFFFFF " .. getPlayerName(thePlayer):gsub("_", " ") .. " isimli kişi size kimliğini gösterdi.",
		targetPlayer,
		0,
		255,
		0,
		true
	)
	outputChatBox(
		"[!]#FFFFFF "
			.. "Ad ve Soyad: '"
			.. itemExploded[1]:gsub("_", " ")
			.. "', Cinsiyeti: '"
			.. itemExploded[2]
			.. "', Yaşı: '"
			.. itemExploded[3]
			.. "', T.C. Kimlik Numarası: '"
			.. itemExploded[4]
			.. "'",
		targetPlayer,
		0,
		0,
		255,
		true
	)

	outputChatBox(
		"[!]#FFFFFF " .. getPlayerName(targetPlayer):gsub("_", " ") .. " isimli kişiye kimliğinizi gösterdiniz.",
		thePlayer,
		0,
		255,
		0,
		true
	)
end
addCommandHandler("kimlikgoster", showID, false, false)

local function formatLicense(status)
	if status == 1 then
		return "#66CCFF [Var]"
	elseif status == 3 then
		return "#66CCFF [Teori testi geçti]"
	else
		return "#66CCFF [Yok]"
	end
end

local function showLicense(thePlayer, commandName, targetPlayer)
	if not targetPlayer then
		outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID]", thePlayer, 255, 194, 14)
		return
	end

	local targetPlayer = findNearbyPlayer(thePlayer, targetPlayer)
	if not targetPlayer then
		return
	end

	local car = formatLicense(getElementData(thePlayer, "car_license"))
	local bike = formatLicense(getElementData(thePlayer, "bike_license"))
	local boat = formatLicense(getElementData(thePlayer, "boat_license"))

	outputChatBox(
		"[!]#FFFFFF " .. getPlayerName(thePlayer):gsub("_", " ") .. " isimli kişi size ehliyet durumunu gösterdi.",
		targetPlayer,
		0,
		255,
		0,
		true
	)
	outputChatBox(
		"#FFFFFF Araba Ehliyeti: "
			.. car
			.. " #FFFFFF - Motosiklet Ehliyeti: "
			.. bike
			.. " #FFFFFF - Tekne Ehliyeti: "
			.. boat,
		targetPlayer,
		255,
		255,
		255,
		true
	)

	outputChatBox(
		"[!]#FFFFFF " .. getPlayerName(targetPlayer):gsub("_", " ") .. " isimli kişiye ehliyetinizi gösterdiniz.",
		thePlayer,
		0,
		255,
		0,
		true
	)
end
addCommandHandler("ehliyetgoster", showLicense, false, false)

function payPlayer(thePlayer, commandName, targetPlayer, amount)
	if not targetPlayer or not amount or not tonumber(amount) then
		outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID] [Miktar]", thePlayer, 255, 194, 14)
	else
		local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)

		if targetPlayer then
			local x, y, z = getElementPosition(thePlayer)
			local tx, ty, tz = getElementPosition(targetPlayer)
			local distance = getDistanceBetweenPoints3D(x, y, z, tx, ty, tz)

			if distance <= 10 then
				amount = math.floor(math.abs(tonumber(amount)))
				local hoursPlayed = getElementData(thePlayer, "hours_played")

				if targetPlayer == thePlayer then
					outputChatBox("[!]#FFFFFF Kendine para gönderemezsiniz.", thePlayer, 255, 0, 0, true)
				elseif amount <= 0 then
					outputChatBox("[!]#FFFFFF 0'dan büyük bir tutar girmelisiniz.", thePlayer, 255, 0, 0, true)
				elseif
					(hoursPlayed < 5)
					and (amount > 50)
					and not exports.mek_integration:isPlayerTrialAdmin(thePlayer)
					and not exports.mek_integration:isPlayerTrialAdmin(targetPlayer)
				then
					outputChatBox(
						"[!]#FFFFFF ₺50'den fazla para atmadan önce en az 5 saat oynamalısınız.",
						thePlayer,
						255,
						0,
						0,
						true
					)
				elseif getElementData(thePlayer, "dead") then
					outputChatBox("[!]#FFFFFF Baygınken birisine para gönderemezsiniz.", thePlayer, 255, 0, 0, true)
				elseif exports.mek_global:hasMoney(thePlayer, amount) then
					if
						(hoursPlayed < 5)
						and not exports.mek_integration:isPlayerTrialAdmin(targetPlayer)
						and not exports.mek_integration:isPlayerTrialAdmin(thePlayer)
					then
						local totalAmount = (getElementData(thePlayer, "pay_amount") or 0) + amount
						if totalAmount > 1000 then
							outputChatBox(
								"[!]#FFFFFF Beş dakikada toplam ₺1,000 bağışlayabilirsiniz.",
								thePlayer,
								255,
								0,
								0,
								true
							)
							return
						end

						setElementData(thePlayer, "pay_amount", totalAmount, false)

						setTimer(function(thePlayer, amount)
							if isElement(thePlayer) then
								local totalAmount = (getElementData(thePlayer, "pay_amount") or 0) - amount
								setElementData(
									thePlayer,
									"pay_amount",
									totalAmount <= 0 and false or totalAmount,
									false
								)
							end
						end, 300000, 1, thePlayer, amount)
					end

					exports.mek_global:takeMoney(thePlayer, amount)
					exports.mek_global:giveMoney(targetPlayer, amount)

					exports.mek_global:sendLocalMeAction(
						thePlayer,
						"elini cebine atar, cüzdanından birkaç miktar para alır ve "
							.. targetPlayerName
							.. "'e verir."
					)
					outputChatBox(
						"[!]#FFFFFF Başarıyla ₺"
							.. exports.mek_global:formatMoney(amount)
							.. " parayı "
							.. targetPlayerName
							.. " isimli oyuncuya verdiniz.",
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
							.. " para verdi.",
						targetPlayer,
						0,
						255,
						0,
						true
					)
					exports.mek_logs:addLog(
						"paraver",
						getPlayerName(thePlayer):gsub("_", " ")
							.. " isimli oyuncu "
							.. targetPlayerName
							.. " isimli oyuncuya ₺"
							.. exports.mek_global:formatMoney(amount)
							.. " para verdi."
					)
					setPedAnimation(thePlayer, "DEALER", "shop_pay", 4000, false, true, true)
				else
					outputChatBox("[!]#FFFFFF Yeterli paranız yok.", thePlayer, 255, 0, 0, true)
				end
			else
				outputChatBox(
					"[!]#FFFFFF " .. targetPlayerName .. " isimli oyuncudan çok uzaksınız.",
					thePlayer,
					255,
					0,
					0,
					true
				)
			end
		end
	end
end
addCommandHandler("paraver", payPlayer, false, false)

function sendStatus(thePlayer, commandName, ...)
	if not (...) then
		removeElementData(thePlayer, "chat_status")
		return
	end

	local message = table.concat({ ... }, " ")

	setElementData(thePlayer, "chat_status", message)
	outputChatBox("[!]#FFFFFF Statusunuzu başarıyla değiştirdiniz.", thePlayer, 0, 255, 0, true)
end
addCommandHandler("status", sendStatus, false, false)

function zaratCommand(thePlayer)
	exports.mek_global:sendLocalText(
		thePlayer,
		"✪ " .. getPlayerName(thePlayer):gsub("_", " ") .. " zar attı. ((" .. math.random(1, 100) .. "))",
		102,
		255,
		255
	)
end
addCommandHandler("zarat", zaratCommand, false, false)
addCommandHandler("zarat100", zaratCommand, false, false)

function tryLuck(thePlayer, commandName, pa1, pa2)
	local p1, p2, p3 = nil
	p1 = tonumber(pa1)
	p2 = tonumber(pa2)

	if pa1 == nil and pa2 == nil and pa3 == nil then
		exports.mek_global:sendLocalText(
			thePlayer,
			"((OOC Şans)) "
				.. getPlayerName(thePlayer):gsub("_", " ")
				.. " isimli kişi 1 ile 100 arasında şansını denedi ve "
				.. math.random(100)
				.. " sayı geliyor.",
			255,
			51,
			102,
			30,
			{},
			true
		)
	elseif pa1 ~= nil and p1 ~= nil and pa2 == nil then
		exports.mek_global:sendLocalText(
			thePlayer,
			"((OOC Şans)) "
				.. getPlayerName(thePlayer):gsub("_", " ")
				.. " isimli kişi 1 ile "
				.. p1
				.. " ve arasında şansını denedi "
				.. math.random(p1)
				.. " sayı geliyor.",
			255,
			51,
			102,
			30,
			{},
			true
		)
	else
		outputChatBox("Kullanım: /" .. commandName .. " [1-(+∞)]", thePlayer, 255, 194, 14)
	end
end
addCommandHandler("sans", tryLuck, false, false)

function tryChance(thePlayer, commandName, pa1, pa2)
	local p1, p2, p3 = nil
	p1 = tonumber(pa1)
	p2 = tonumber(pa2)
	if pa1 ~= nil then
		if pa2 == nil and p1 ~= nil then
			if p1 <= 100 and p1 >= 0 then
				if math.random(100) >= p1 then
					exports.mek_global:sendLocalText(
						thePlayer,
						"((OOC Şans - %"
							.. p1
							.. ")) "
							.. getPlayerName(thePlayer):gsub("_", " ")
							.. " isimli kişi denemesi başarısızlıkla sonuçlandı.",
						255,
						51,
						102,
						30,
						{},
						true
					)
				else
					exports.mek_global:sendLocalText(
						thePlayer,
						"((OOC Şans - %"
							.. p1
							.. ")) "
							.. getPlayerName(thePlayer):gsub("_", " ")
							.. " isimli kişi denemesi başarılı oldu.",
						255,
						51,
						102,
						30,
						{},
						true
					)
				end
			else
				outputChatBox("Kullanım: /" .. commandName .. " [0-100]", thePlayer, 255, 194, 14)
			end
		else
			outputChatBox("Kullanım: /" .. commandName .. " [0-100]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("Kullanım: /" .. commandName .. " [0-100]", thePlayer, 255, 194, 14)
	end
end
addCommandHandler("chance", tryChance, false, false)
addCommandHandler("sans2", tryChance, false, false)
addCommandHandler("dene", tryChance, false, false)

addCommandHandler("imla", function(thePlayer, commandName)
	outputChatBox(
		"[!]#FFFFFF Otomatik imla modu başarıyla "
			.. (not getElementData(thePlayer, "chat_spelling") and "açıldı" or "kapandı")
			.. ", "
			.. (getElementData(thePlayer, "chat_spelling") and "açmak" or "kapatmak")
			.. " için tekrardan /"
			.. commandName
			.. " yazın.",
		thePlayer,
		0,
		255,
		0,
		true
	)
	setElementData(thePlayer, "chat_spelling", not getElementData(thePlayer, "chat_spelling") and true or false)
end, false, false)

addCommandHandler("talkanim", function(thePlayer, commandName)
	outputChatBox(
		"[!]#FFFFFF Otomatik konuşma animasyonu başarıyla "
			.. (not getElementData(thePlayer, "talk_anim") and "açıldı" or "kapandı")
			.. ", "
			.. (getElementData(thePlayer, "talk_anim") and "açmak" or "kapatmak")
			.. " için tekrardan /"
			.. commandName
			.. " yazın.",
		thePlayer,
		0,
		255,
		0,
		true
	)
	setElementData(thePlayer, "talk_anim", not getElementData(thePlayer, "talk_anim") and true or false)
end, false, false)

addEventHandler("onPlayerQuit", root, function()
	for _, player in ipairs(getElementsByType("player")) do
		if player ~= source then
			local focus = getElementData(player, "focus")
			if focus and focus[source] then
				focus[source] = nil
				setElementData(player, "focus", focus, false)
			end
		end
	end
end)

function formatSentence(text)
	if type(text) ~= "string" then
		return text
	end

	text = text:gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s+", " ")
	text = text:gsub("^%l", string.upper)

	local endings = { ".", "!", "?", ",", ";", "...", ":", "-" }
	local lastChar = text:sub(-1)

	local needsPunctuation = true
	for _, char in ipairs(endings) do
		if #char > 1 then
			if text:sub(-#char) == char then
				needsPunctuation = false
				break
			end
		else
			if lastChar == char then
				needsPunctuation = false
				break
			end
		end
	end

	if needsPunctuation then
		text = text .. "."
	end

	return text
end

function getElementDistance(thePlayer, targetPlayer)
	if
		not isElement(thePlayer)
		or not isElement(targetPlayer)
		or getElementDimension(thePlayer) ~= getElementDimension(targetPlayer)
	then
		return math.huge
	else
		local x, y, z = getElementPosition(thePlayer)
		return getDistanceBetweenPoints3D(x, y, z, getElementPosition(targetPlayer))
	end
end

function isThisFreqRestricted()
	return false
end

function outputChatBoxCar(vehicle, targetPMer, text1, text2, color)
	if vehicle and exports.mek_vehicle:isVehicleWindowUp(vehicle) then
		if getPedOccupiedVehicle(targetPMer) == vehicle then
			outputChatBox(text1 .. " (Araçta)" .. text2, targetPMer, unpack(color))
			return true
		end
		return false
	end
	outputChatBox(text1 .. text2, targetPMer, unpack(color))
	return true
end
