addEvent("interior.settingsGui", true)
addEventHandler("interior.settingsGui", root, function(element, playerInterior, interiorID, data)
	local localPlayerInterior = getElementInterior(localPlayer)
	local localPlayerDimension = getElementDimension(localPlayer)
	
	if localPlayerInterior == playerInterior and localPlayerDimension == interiorID then
		if playerInterior > 0 and interiorID > 0 then
			local isVehicleInterior = interiorID > 20000
			
			local store = useStore("interiorSettings")
			
			-- Yeni bir interior için açılırken, önceki panelden kalan input/state'leri sıfırla
			store.set("interiorName", nil)
			store.set("entranceFee", nil)
			store.set("saleCost", nil)
			
			-- Genel / satış / özelleştir sekmelerindeki checkbox cache'lerini temizle
			store.set("checkbox_lights", nil)
			store.set("checkbox_ooc", nil)
			store.set("checkbox_gps", nil)
			store.set("checkbox_forSale", nil)
			store.set("checkbox_furniture", nil)
			
			-- İşyeri yönetimi sekmesi ile ilgili state'ler
			store.set("checkbox_isWorkplace", nil)
			store.set("workplaceActive", nil)
			store.set("workplaceLogoUrl", nil)
			store.set("workplaceBannerUrl", nil)
			store.set("workplaceOpenTime", nil)
			store.set("workplaceCloseTime", nil)
			
			-- Müzik ayarları
			store.set("musicUrl", nil)
			store.set("musicVolume", nil)
			
			store.set("interiorElement", element)
			store.set("interiorID", interiorID)
			store.set("isVehicleInterior", isVehicleInterior)
			store.set("settingsData", data or {})
			
			showPage("settings")
		end
	end
end)

-- URL yapıştırma komutu
addCommandHandler("pasteurl", function(cmd, ...)
	local url = table.concat({...}, " ")
	if not url or url == "" then
		outputChatBox("[!] #FFFFFFKullanım: #00FF00/pasteurl [URL]#FFFFFF", 255, 255, 255, true)
		outputChatBox("[!] #FFFFFFÖrnek: #00FF00/pasteurl https://www.youtube.com/watch?v=B1CDoDyS6xs#FFFFFF", 255, 255, 255, true)
		return
	end
	
	local store = useStore("interiorSettings")
	if not store.get("interiorElement") then
		exports.mek_infobox:addBox("error", "Önce mülk ayarları panelini açın (/intsettings)")
		return
	end
	
	-- Clean the URL
	local cleanedUrl = url:gsub("^%s+", ""):gsub("%s+$", "") -- Trim whitespace
	
	-- Clean YouTube URL - remove unnecessary parameters
	if cleanedUrl:find("youtube%.com") or cleanedUrl:find("youtu%.be") then
		-- Extract video ID and create clean URL
		local videoId = cleanedUrl:match("v=([^&]+)") or cleanedUrl:match("youtu%.be/([^?]+)") or cleanedUrl:match("embed/([^?]+)")
		if videoId then
			cleanedUrl = "https://www.youtube.com/watch?v=" .. videoId
		end
	end
	
	store.set("musicUrl", cleanedUrl)
	exports.mek_infobox:addBox("success", "URL yapıştırıldı! Ayarlar panelinde görünecektir.")
	outputChatBox("[!] #00FF00URL yapıştırıldı: #FFFFFF" .. cleanedUrl, 255, 255, 255, true)
end)

