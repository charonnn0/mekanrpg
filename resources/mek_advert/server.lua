local advertCooldowns = {}
local COOLDOWN_TIME = 5 * 60 * 1000

local bannedPatterns = {
	"discord%.gg",
	"discord%.com",
	"discordapp%.com",
	"t%.me",
	"telegram%.me",
	"bit%.ly",
	"tinyurl%.com",
	"youtu%.be",
}

local function containsBannedContent(text)
	local lowerText = text:lower()
	for _, pattern in ipairs(bannedPatterns) do
		if lowerText:find(pattern) then
			return true
		end
	end
	return false
end

addEvent("advert.send", true)
addEventHandler("advert.send", root, function(text)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	local serial = getPlayerSerial(client)
	local currentTime = getTickCount()
	
	if advertCooldowns[serial] then
		local timePassed = currentTime - advertCooldowns[serial]
		if timePassed < COOLDOWN_TIME then
			local remainingTime = math.ceil((COOLDOWN_TIME - timePassed) / 1000)
			exports.mek_infobox:addBox(client, "error", "Reklam göndermek için " .. remainingTime .. " saniye beklemelisiniz.")
			return
		end
	end

	if exports.mek_global:hasMoney(client, 100) then
		if #text > 0 then
			if containsBannedContent(text) then
				exports.mek_infobox:addBox(client, "error", "Reklamda yasaklı içerik (link, discord vb.) bulundu.")
				return
			end
			if not getElementData(client, "admin_jailed") then
				exports.mek_global:takeMoney(client, 100)
				advertCooldowns[serial] = getTickCount()
				exports.mek_infobox:addBox(
					client,
					"success",
					"Reklamınız kabul edildi, 10 saniye içinde gönderilecek."
				)

				local phoneNumber = "-"
				for _, item in ipairs(exports.mek_item:getItems(client)) do
					if item[1] == 2 then
						phoneNumber = item[2]
					end
				end

				setTimer(function(client)
					outputChatBox("[TRT] " .. text, root, 0, 255, 0)
					outputChatBox(
						"[TRT] İletişim: " .. phoneNumber .. " // " .. getPlayerName(client):gsub("_", " "),
						root,
						0,
						255,
						0
					)
				end, 10 * 1000, 1, client)
			else
				exports.mek_infobox:addBox(client, "error", "Hapishanedeyken reklam yayınlayamazsın.")
			end
		else
			exports.mek_infobox:addBox(client, "error", "İçerik boş olamaz.")
		end
	else
		exports.mek_infobox:addBox(client, "error", "Reklam yayınlamak için yeterli paranız yok.")
	end
end)
