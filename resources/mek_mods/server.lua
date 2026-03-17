local mods = {}

addEventHandler("onResourceStart", resourceRoot, function()
	local meta = xmlLoadFile("meta.xml")
	parseMeta(mods, meta)
end)

addEvent("mods.onLoad", true)
addEventHandler("mods.onLoad", root, function()
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if exports.mek_settings:getPlayerSetting(client, "game_mods") then
		triggerClientEvent(client, "mods.request", client, mods)
	end
end)

function parseMeta(datas, meta)
	for _, data in ipairs(xmlNodeGetChildren(meta)) do
		if xmlNodeGetName(data) == "file" then
			local model = tonumber(xmlNodeGetAttribute(data, "model"))
			local file = xmlNodeGetAttribute(data, "src")
			table.insert(datas, {
				file = file,
				model = model,
			})
		end
	end
end
