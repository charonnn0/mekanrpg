local cacheData = {}
local quitReason = {
	["Unknown"] = "Bilinmiyor",
	["Quit"] = "Kendi İsteğiyle",
	["Kicked"] = "Atıldı",
	["Banned"] = "Yasaklandı",
	["Bad Connection"] = "Kötü Bağlantı",
	["Timed out"] = "Zaman Aşımı",
}

addCommandHandler("quitlog", function()
	createUI()
end)

function createUI()
	if isElement(window) then
		destroyElement(window)
	end
	window = guiCreateWindow(0, 0, 724, 474, "Yakınında Oyundan Çıkan Oyuncular", false)
	guiWindowSetSizable(window, false)
	exports.mek_global:centerWindow(window)

	close = guiCreateButton(10, 426, 704, 38, "Kapat", false, window)
	gridlist = guiCreateGridList(9, 26, 705, 382, false, window)
	guiGridListAddColumn(gridlist, "Karakter Adı", 0.2)
	guiGridListAddColumn(gridlist, "Kullanıcı Adı", 0.2)
	guiGridListAddColumn(gridlist, "Sebep", 0.2)
	guiGridListAddColumn(gridlist, "Uzaklık (mt)", 0.1)
	guiGridListAddColumn(gridlist, "Bölge", 0.1)
	guiGridListAddColumn(gridlist, "Tarih", 0.2)

	if cacheData and #cacheData > 0 then
		for index, data in ipairs(cacheData) do
			local row = guiGridListAddRow(gridlist)
			if row then
				for i = 1, 6 do
					guiGridListSetItemText(gridlist, row, i, data[i], false, false)
				end
			end
		end
	end

	addEventHandler("onClientGUIClick", close, function(b)
		if source == close then
			destroyElement(window)
		end
	end)
end

addEventHandler("onClientPlayerQuit", root, function(reason)
	if localPlayer == source then
		return
	end

	if not source:getData("logged") then
		return
	end

	local distance = getDistanceBetweenPoints3D(localPlayer.position, source.position)
	if distance < 20 then
		local time = getRealTime()
		local date = string.format(
			"%02d-%02d-%02d %02d:%02d:%02d",
			time.monthday,
			time.month + 1,
			time.year + 1900,
			time.hour,
			time.minute,
			time.second
		)

		cacheData[#cacheData + 1] = {
			source.name:gsub("_", " "),
			source:getData("account_username"),
			quitReason[reason] or "Bilinmiyor",
			math.floor(distance),
			exports.mek_global:getZoneName(source.position),
			date,
		}
	end
end)
