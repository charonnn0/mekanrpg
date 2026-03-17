local authorizedUsers = {
	["charon"] = { true, true },
	["pinez"] = { true, true },
}

local commandList = {
	["refresh"] = true,
	["refreshall"] = true,
	["restart"] = true,
	["start"] = true,
	["stop"] = true,
	["stopall"] = true,
	["aclrequest"] = true,
	["reloadacl"] = true,
	["aexec"] = true,
	["addaccount"] = true,
	["chgpass"] = true,
	["delaccount"] = true,
	["reloadbans"] = true,
	["authserial"] = true,
	["loadmodule"] = true,
	["sfakelag"] = true,
	["shutdown"] = true,
	["sver"] = true,
	["whois"] = true,
	["ver"] = true,
	["chgmypass"] = true,
	["debugscript"] = true,
	["login"] = true,
	["logout"] = true,
	["msg"] = true,
	["nick"] = true,
	["fixcar"] = true,
	["rollbug"] = true,
	["stopanim"] = true,
	["quickspeed"] = true,
	["debug_cd78878"] = true,
	["debug_cd75575"] = true,
	["debug_ccL.externalslide"] = true,
	["ping_debug"] = true,
	["Olhar"] = true,
	["Mira"] = true,
	["Correr"] = true,
	["macro"] = true,
	["lag"] = true,
}

addEventHandler("onPlayerCommand", root, function(commandName)
	if commandName == "debugscript" then
		return
	end

	local username = getElementData(source, "account_username")
	if not username or not getElementData(source, "logged") then
		cancelEvent(true)
		return
	end

	if commandList[commandName] then
		local userData = authorizedUsers[username]
		if not userData or not userData[1] then
			cancelEvent(true)
			outputChatBox("[!]#FFFFFF Bu komutu kullanamazsınız.", source, 255, 0, 0, true)
		end
	end
end)

function restartSingleResource(thePlayer, commandName, resourceName)
	if authorizedUsers[getElementData(thePlayer, "account_username")][2] then
		if resourceName then
			local theResource = getResourceFromName(tostring(resourceName))
			if theResource then
				if getResourceState(theResource) == "running" then
					restartResource(theResource)
					outputChatBox(
						"[!]#FFFFFF [" .. resourceName .. "] isimli sistem yeniden başladıldı.",
						thePlayer,
						0,
						255,
						0,
						true
					)
					exports.mek_global:sendMessageToAdmins(
						"[SCRIPT] "
							.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
							.. " isimli yetkili ["
							.. resourceName
							.. "] isimli sistemi yeniden başlatdı.",
						true
					)
				elseif getResourceState(theResource) == "loaded" then
					startResource(theResource, true)
					outputChatBox(
						"[!]#FFFFFF [" .. resourceName .. "] isimli sistem yeniden başladıldı.",
						thePlayer,
						0,
						255,
						0,
						true
					)
					exports.mek_global:sendMessageToAdmins(
						"[SCRIPT] "
							.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
							.. " isimli yetkili ["
							.. resourceName
							.. "] isimli sistemi yeniden başlatdı.",
						true
					)
				elseif getResourceState(theResource) == "failed to load" then
					outputChatBox(
						"[!]#FFFFFF ["
							.. resourceName
							.. "] isimli sistemi restartlanmadı. ("
							.. getResourceLoadFailureReason(theResource)
							.. ")",
						thePlayer,
						255,
						0,
						0,
						true
					)
				else
					outputChatBox(
						"[!]#FFFFFF ["
							.. resourceName
							.. "] isimli sistem başlatılmadı. ("
							.. getResourceState(theResource)
							.. ")",
						thePlayer,
						255,
						0,
						0,
						true
					)
				end
			else
				outputChatBox("[!]#FFFFFF Böyle bir sistem bulunamadı.", thePlayer, 255, 0, 0, true)
			end
		else
			outputChatBox("Kullanım: /" .. commandName .. " [Sistem Adı]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("restartres", restartSingleResource, false, false)

function stopSingleResource(thePlayer, commandName, resourceName)
	if authorizedUsers[getElementData(thePlayer, "account_username")][2] then
		if resourceName then
			local theResource = getResourceFromName(tostring(resourceName))
			if theResource then
				if stopResource(theResource) then
					outputChatBox(
						"[!]#FFFFFF [" .. resourceName .. "] isimli sistem stopladı.",
						thePlayer,
						0,
						255,
						0,
						true
					)
					exports.mek_global:sendMessageToAdmins(
						"[SCRIPT] "
							.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
							.. " isimli yetkili ["
							.. resourceName
							.. "] isimli sistemi dayandırdı.",
						true
					)
				else
					outputChatBox(
						"[!]#FFFFFF [" .. resourceName .. "] isimli sistem stoplanamadı.",
						thePlayer,
						255,
						0,
						0,
						true
					)
				end
			else
				outputChatBox("[!]#FFFFFF Böyle bir sistem bulunamadı.", thePlayer, 255, 0, 0, true)
			end
		else
			outputChatBox("Kullanım: /" .. commandName .. " [Sistem Adı]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("stopres", stopSingleResource, false, false)

function startSingleResource(thePlayer, commandName, resourceName)
	if authorizedUsers[getElementData(thePlayer, "account_username")][2] then
		if resourceName then
			local theResource = getResourceFromName(tostring(resourceName))
			if theResource then
				if getResourceState(theResource) == "running" then
					outputChatBox(
						"[!]#FFFFFF [" .. resourceName .. "] isimli sistem zaten aktif.",
						thePlayer,
						0,
						255,
						0,
						true
					)
				elseif getResourceState(theResource) == "loaded" then
					startResource(theResource, true)
					outputChatBox(
						"[!]#FFFFFF [" .. resourceName .. "] isimli sistem başladıldı.",
						thePlayer,
						0,
						255,
						0,
						true
					)
					exports.mek_global:sendMessageToAdmins(
						"[SCRIPT] "
							.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
							.. " isimli yetkili ["
							.. resourceName
							.. "] isimli sistemi başlatdı.",
						true
					)
				elseif getResourceState(theResource) == "failed to load" then
					outputChatBox(
						"[!]#FFFFFF ["
							.. resourceName
							.. "] isimli sistemi startlanamadı. ("
							.. getResourceLoadFailureReason(theResource)
							.. ")",
						thePlayer,
						255,
						0,
						0,
						true
					)
				else
					outputChatBox(
						"[!]#FFFFFF ["
							.. resourceName
							.. "] isimli sistem başlatılmadı. ("
							.. getResourceState(theResource)
							.. ")",
						thePlayer,
						255,
						0,
						0,
						true
					)
				end
			else
				outputChatBox("[!]#FFFFFF Böyle bir sistem bulunamadı.", thePlayer, 255, 0, 0, true)
			end
		else
			outputChatBox("Kullanım: /" .. commandName .. " [Sistem Adı]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("startres", startSingleResource, false, false)


local DISCORD_WEBHOOK = "https://discord.com/api/webhooks/1454179029979500596/x_B09gBFJsv6NwlKb8Sj696cJ-9_9aKVxCm12BD_3bQTGloDBz6HIt5dMloFG8Bedfoh"

local function sendDiscordDebug(message, level, file, line)
	local color = 16711680
	if level == 2 then color = 16776960 end
	if level == 3 then color = 65280 end

	local payload = {
		embeds = {{
			color = color,
			fields = {
				{ name = "Resource", value = tostring(file or "unknown"), inline = true },
				{ name = "Level", value = tostring(level), inline = true },
				{ name = "Line", value = tostring(line or "N/A"), inline = true },
				{ name = "Message", value = "```" .. tostring(message) .. "```", inline = false }
			},
			timestamp = getRealTime().timestamp
		}}
	}

	fetchRemote(
		DISCORD_WEBHOOK,
		{
			method = "POST",
			headers = {
				["Content-Type"] = "application/json"
			},
			postData = toJSON(payload)
		},
		function() end
	)
end
