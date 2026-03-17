addEvent("maps.managerTabSync", true)
addEventHandler("maps.managerTabSync", resourceRoot, function(tabID, dontShowPopUp)
	if tabID == 1 then
		dbQuery(
			function(qh, client, tabID)
				local res, nums, id = dbPoll(qh, 0)
				if res then
					triggerLatentClientEvent(client, "maps.populateTab", resourceRoot, tabID, "ok", res, dontShowPopUp)
				else
					dbFree(qh)
					triggerClientEvent(
						client,
						"maps.populateTab",
						resourceRoot,
						tabID,
						"Veriler senkronize edilirken hata oluştu.",
						nil,
						dontShowPopUp
					)
				end
			end,
			{ client, tabID },
			exports.mek_mysql:getConnection(),
			"SELECT m.*, m.reviewer AS reviewer FROM maps m WHERE uploader = ? ORDER BY m.approved, m.enabled, m.id DESC",
			getElementData(client, "account_id")
		)
	elseif tabID == 3 then
		dbQuery(
			function(qh, client, tabID)
				local res, nums, id = dbPoll(qh, 0)
				if res then
					triggerLatentClientEvent(client, "maps.populateTab", resourceRoot, tabID, "ok", res, dontShowPopUp)
				else
					dbFree(qh)
					triggerClientEvent(
						client,
						"maps.populateTab",
						resourceRoot,
						tabID,
						"Veriler senkronize edilirken hata oluştu.",
						nil,
						dontShowPopUp
					)
				end
			end,
			{ client, tabID },
			exports.mek_mysql:getConnection(),
			"SELECT m.*, m.reviewer AS reviewer_name, m.uploader AS uploader_name FROM maps m ORDER BY m.approved, m.enabled, m.id DESC"
		)
	end
end)

addEvent("maps.submitExteriorMapRequest", true)
addEventHandler("maps.submitExteriorMapRequest", resourceRoot, function(name, url, who, what, why, map)
	if not canAdminMaps(client) then
		local check = dbQuery(
			exports.mek_mysql:getConnection(),
			"SELECT COUNT(id) AS count FROM maps WHERE approved = 0 AND type = 'exterior' AND uploader = ?",
			getElementData(client, "account_id")
		)
		local res1, nums1, id1 = dbPoll(check, 10000)
		if res1 and nums1 > 0 then
			if res1[1].count >= settings.externalMapMaxConcurrentRequests then
				return not triggerClientEvent(
					client,
					"maps.exteriorMapRequestResponse",
					resourceRoot,
					"Şu anda onay bekleyen "
						.. res1[1].count
						.. " haritanız var. Lütfen bekleyin veya önceki isteklerinizi iptal edin."
				)
			end
		else
			dbFree(check)
			triggerClientEvent(client, "maps.exteriorMapRequestResponse", resourceRoot, "Hata.")
		end
	end

	local done, whyFailed = submitExteriorMapRequest(name, url, who, what, why, map, client)
	triggerClientEvent(client, "maps.exteriorMapRequestResponse", resourceRoot, done and "ok" or whyFailed)
end)

addEvent("maps.updateReq", true)
addEventHandler("maps.updateReq", resourceRoot, function(tabid, name, url, who, what, why, id)
	dbQuery(
		function(qh, client, tabid)
			local res, nums, id = dbPoll(qh, 0)
			if res and nums > 0 then
				triggerClientEvent(client, "maps.updateMyReqResponse", resourceRoot, "ok", tabid)
			else
				triggerClientEvent(
					client,
					"maps.updateMyReqResponse",
					resourceRoot,
					"Harita verileri güncellenirken hatalar oluştu."
				)
			end
		end,
		{ client, tabid },
		exports.mek_mysql:getConnection(),
		"UPDATE maps SET name = ?, preview = ?, used_by = ?, purposes = ?, reasons = ? WHERE id = ?",
		name,
		url,
		who,
		what,
		why,
		id
	)
end)

addEvent("maps.delReq", true)
addEventHandler("maps.delReq", resourceRoot, function(tabID, id)
	dbQuery(function(qh, client, tabID, id)
		local res, nums, id1 = dbPoll(qh, 0)
		if res and nums > 0 then
			triggerClientEvent(client, "maps.updateMyReqResponse", resourceRoot, "ok", tabID)
			dbExec(exports.mek_mysql:getConnection(), "DELETE FROM maps_objects WHERE map_id = ?", id)
		else
			triggerClientEvent(
				client,
				"maps.updateMyReqResponse",
				resourceRoot,
				"Harita verileri silinirken hatalar oluştu."
			)
		end
	end, { client, tabID, id }, exports.mek_mysql:getConnection(), "DELETE FROM maps WHERE id = ?", id)
end)

addEvent("maps.testMap", true)
addEventHandler("maps.testMap", resourceRoot, function(mapID)
	local res = exports["mek_map-load"]:getMapObjects(mapID)
	if res then
		triggerLatentClientEvent(client, "maps.testMap", resourceRoot, "ok", res, mapID)
	else
		triggerClientEvent(client, "maps.testMap", resourceRoot, "Harita içerikleri sorgulanırken hatalar oluştu.")
	end
end)

addEvent("maps.approveRequest", true)
addEventHandler("maps.approveRequest", resourceRoot, function(mapID, note, accepting)
	note = getCurrentTimeString()
		.. " "
		.. exports.mek_global:getPlayerFullAdminTitle(client)
		.. ": "
		.. (accepting and "Onaylandı" or "Reddedildi")
		.. ": "
		.. note
		.. "\n"
	dbQuery(
		function(qh, client, mapID, note)
			local res, nums, id = dbPoll(qh, 0)
			if res and nums > 0 then
				triggerClientEvent(client, "maps.approveRequest", resourceRoot, "ok", mapID, accepting)
			else
				dbFree(qh)
				triggerClientEvent(client, "maps.approveRequest", resourceRoot, "İstek işlenirken hata oluştu.")
			end
		end,
		{ client, mapID, note },
		exports.mek_mysql:getConnection(),
		"UPDATE maps SET approved = ?, note = CONCAT(note, ?), reviewer = ? WHERE id = ?",
		accepting and 1 or 2,
		note,
		getElementData(client, "account_id"),
		mapID
	)
end)

addEvent("maps.implement", true)
addEventHandler("maps.implement", resourceRoot, function(mapID, implementing)
	local note = getCurrentTimeString()
		.. " "
		.. exports.mek_global:getPlayerFullAdminTitle(client)
		.. ": "
		.. (implementing and "Harita aktif edildi." or "Harita devre dışı bırakıldı.")
		.. "\n"
	dbQuery(
		function(qh, client, mapID, note)
			local res, nums, id = dbPoll(qh, 0)
			if res and nums > 0 then
				if
					implementing and exports["mek_map-load"]:loadMap(mapID)
					or exports["mek_map-load"]:unloadMap(mapID)
				then
					triggerClientEvent(client, "maps.implement", resourceRoot, "ok", mapID, implementing)
				else
					triggerClientEvent(
						client,
						"maps.implement",
						resourceRoot,
						"Harita "
							.. (implementing and "aktif edilirken" or "devre dışı bırakılırken")
							.. " hata oluştu."
					)
				end
			else
				dbFree(qh)
				triggerClientEvent(
					client,
					"maps.implement",
					resourceRoot,
					"Harita "
						.. (implementing and "aktif edilirken" or "devre dışı bırakılırken")
						.. " hata oluştu."
				)
			end
		end,
		{ client, mapID, note },
		exports.mek_mysql:getConnection(),
		"UPDATE maps SET enabled = ?, approved = 1, note = CONCAT(note, ?) WHERE id = ?",
		implementing and 1 or 0,
		note,
		mapID
	)
end)

addCommandHandler("nearbymaps", function(thePlayer, commandName)
	if canAdminMaps(thePlayer) then
		local x, y, z = getElementPosition(thePlayer)
		dbQuery(
			function(qh, player)
				local res = dbPoll(qh, 0)
				if res then
					local found = false
					outputChatBox("Yakındaki Haritalar:", player, 255, 194, 14)
					for _, map in ipairs(res) do
						local dist = getDistanceBetweenPoints3D(x, y, z, map.posX, map.posY, map.posZ)
						if dist <= 100 then
							outputChatBox(
								"ID: " .. map.id .. " - Isim: " .. map.name .. " (" .. math.floor(dist) .. "m)",
								player,
								255,
								255,
								255
							)
							found = true
						end
					end
					if not found then
						outputChatBox("Yakında harita bulunamadı.", player, 255, 0, 0)
					end
				end
			end,
			{ thePlayer },
			exports.mek_mysql:getConnection(),
			"SELECT m.id, m.name, mo.posX, mo.posY, mo.posZ FROM maps m INNER JOIN maps_objects mo ON m.id = mo.map_id WHERE m.enabled = 1 AND m.approved = 1 GROUP BY m.id"
		)
	end
end)
