function submitExteriorMapRequest(name, url, who, what, why, map, thePlayer, converter)
	local uploaderID = getElementData(thePlayer, "account_id")
	if converter then
		local query =
			"INSERT INTO maps SET name = ?, preview = ?, purposes = ?, used_by = ?, reasons = ?, uploader = ?, note = ''"
		local qh = dbQuery(exports.mek_mysql:getConnection(), query, name, url, what, who, why, uploaderID)
		local res, mapID = dbPoll(qh, 10000)
		if res and mapID then
			for _, obj in ipairs(map) do
				dbExec(
					exports.mek_mysql:getConnection(),
					"INSERT INTO maps_objects SET map_id = ?, id = ?, interior = ?, dimension = ?, collisions = ?, breakable = ?, radius = ?, model = ?, lodModel = ?, posX = ?, posY = ?, posZ = ?, rotX = ?, rotY = ?, rotZ = ?, doublesided = ?, scale = ?, alpha = ?",
					mapID,
					obj.id,
					obj.interior,
					obj.dimension,
					obj.collisions,
					obj.breakable,
					obj.radius,
					obj.model,
					obj.lodModel,
					obj.posX,
					obj.posY,
					obj.posZ,
					obj.rotX,
					obj.rotY,
					obj.rotZ,
					obj.doublesided,
					obj.scale,
					obj.alpha
				)
			end
			return true
		else
			return false, "Hata: Harita eklenemedi."
		end
	else
		local query =
			"INSERT INTO maps SET name = ?, preview = ?, purposes = ?, used_by = ?, reasons = ?, uploader = ?, note = ''"
		local qh = dbQuery(exports.mek_mysql:getConnection(), query, name, url, what, who, why, uploaderID)
		local res, nums, mapID = dbPoll(qh, 10000)
		if res and mapID then
			for _, obj in ipairs(map) do
				dbExec(
					exports.mek_mysql:getConnection(),
					"INSERT INTO maps_objects SET map_id = ?, id = ?, interior = ?, dimension = ?, collisions = ?, breakable = ?, radius = ?, model = ?, lodModel = ?, posX = ?, posY = ?, posZ = ?, rotX = ?, rotY = ?, rotZ = ?, doublesided = ?, scale = ?, alpha = ?",
					mapID,
					obj.id,
					obj.interior,
					obj.dimension,
					obj.collisions,
					obj.breakable,
					obj.radius,
					obj.model,
					obj.lodModel,
					obj.posX,
					obj.posY,
					obj.posZ,
					obj.rotX,
					obj.rotY,
					obj.rotZ,
					obj.doublesided,
					obj.scale,
					obj.alpha
				)
			end
			return true
		else
			return false, "Hata: Harita eklenemedi."
		end
	end
end

addCommandHandler("exportInteriorMap", function(thePlayer, commandName, dim)
	if exports.mek_integration:isPlayerManager(thePlayer) then
		if dim and tonumber(dim) and tonumber(dim) > 0 then
			dbQuery(
				function(qh, thePlayer, dim)
					local res, nums, inserted = dbPoll(qh, 0)
					if res then
						if nums > 0 then
							triggerClientEvent(thePlayer, "maps.exportInteriorMap", resourceRoot, res)
						else
							outputChatBox(
								"Interior #" .. dim .. " için harita nesnesi bulunamadı.",
								thePlayer,
								255,
								0,
								0
							)
						end
					else
						outputChatBox(
							"Interior #" .. dim .. " için harita nesneleri alınırken hatalar oluştu.",
							thePlayer,
							255,
							0,
							0
						)
					end
				end,
				{ thePlayer, dim },
				exports.mek_mysql:getConnection(),
				"SELECT * FROM objects WHERE dimension = ? ",
				dim
			)
		else
			outputChatBox("Kullanım: /" .. commandName .. " [Interior ID]", thePlayer)
		end
	end
end, false, false)

addCommandHandler("exportExteriorMap", function(thePlayer, commandName, mapID)
	if exports.mek_integration:isPlayerManager(thePlayer) then
		if mapID and tonumber(mapID) and tonumber(mapID) > 0 then
			dbQuery(
				function(qh, thePlayer, mapID)
					local res, nums, inserted = dbPoll(qh, 0)
					if res then
						if nums > 0 then
							triggerClientEvent(thePlayer, "maps.exportExteriorMap", resourceRoot, res)
						else
							outputChatBox(
								"Exterior ID #" .. mapID .. " için harita nesnesi bulunamadı.",
								thePlayer,
								255,
								0,
								0
							)
						end
					else
						outputChatBox(
							"Exterior ID #" .. mapID .. " için harita nesneleri alınırken hatalar oluştu.",
							thePlayer,
							255,
							0,
							0
						)
					end
				end,
				{ thePlayer, mapID },
				exports.mek_mysql:getConnection(),
				"SELECT * FROM maps_objects WHERE map_id = ? ",
				mapID
			)
		else
			outputChatBox("Kullanım: /" .. commandName .. " [Exterior ID]", thePlayer)
		end
	end
end, false, false)

addCommandHandler("convertallmapfiles", function(thePlayer, commandName)
	if exports.mek_integration:isPlayerManager(thePlayer) then
		local count = { total = 0, processed = 0 }
		for _, map in ipairs(xmlNodeGetChildren(xmlLoadFile(":maps/meta.xml"))) do
			if xmlNodeGetName(map) == "map" then
				count.total = count.total + 1
				for name, value in pairs(xmlNodeGetAttributes(map)) do
					if name == "src" then
						local done, whyFailed = processMapContent(":maps/" .. value, 9999, true)
						if done then
							local done2, whyFailed2 = submitExteriorMapRequest(
								value,
								"Bilinmiyor",
								"Bilinmiyor",
								"Bilinmiyor",
								"Önceki harita sisteminden dönüştürüldü.",
								done,
								thePlayer,
								true
							)
							if done2 then
								outputConsole(
									"[MAPS] convertallmapfiles / '" .. value .. "' haritası işlendi.",
									thePlayer
								)
								count.processed = count.processed + 1
							else
								outputDebugString(
									"[MAPS] convertallmapfiles / '"
										.. value
										.. "' haritası işlenemedi. Sebep: "
										.. whyFailed2
								)
								outputChatBox(
									"[MAPS] convertallmapfiles / '"
										.. value
										.. "' haritası işlenemedi. Sebep: "
										.. whyFailed2,
									thePlayer
								)
							end
						else
							outputDebugString(
								"[MAPS] convertallmapfiles / '"
									.. value
									.. "' haritası işlenemedi. Sebep: "
									.. whyFailed
							)
							outputChatBox(
								"[MAPS] convertallmapfiles / '"
									.. value
									.. "' haritası işlenemedi. Sebep: "
									.. whyFailed,
								thePlayer
							)
						end
					end
				end
			end
		end
		outputChatBox(
			count.processed .. "/" .. count.total .. " harita dosyası dönüştürüldü.",
			thePlayer,
			0,
			255,
			0
		)
	end
end, false, false)
