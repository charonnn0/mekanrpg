settings = {
	clientFile = "map.xml",
	mapContentMaxLength = 1000000,
	externalMapMaxObjects = 1000,
	externalMapMaxConcurrentRequests = 1,
}

function getReqStatus(v)
	if v.approved == 0 then
		return "Bekleniyor", 255, 255, 255, 200
	elseif v.approved == 2 then
		return "Reddedildi", 255, 0, 0, 255
	else
		if v.enabled == 1 then
			return "Kabul Edildi ve Aktif Edildi", 0, 255, 0, 255
		else
			return "Kabul Edildi ve Devre Dışı Bırakıldı", 255, 0, 0, 200
		end
	end
end

function getCurrentTimeString()
	local time = getRealTime()
	return "[" .. time.monthday .. "/" .. (time.month + 1) .. "/" .. (time.year + 1900) .. "]"
end

function canAdminMaps(player)
	return exports.mek_integration:isPlayerManager(player)
end

function canAccessMgmtTab(player)
	return exports.mek_integration:isPlayerManager(player)
end

function canEditMap(player, map, tabID)
	local isReqEditable = not exports["mek_map-load"]:isMapLoaded(map.id) and map.approved == 0
	if tabID == 1 then
		return isReqEditable
	else
		return isReqEditable and canAdminMaps(player)
	end
end

function canDeleteMap(player, map, tabID)
	if tabID == 1 then
		return map.approved == 0 and map.enabled == 0 and not exports["mek_map-load"]:isMapLoaded(map.id)
	elseif tabID == 3 then
		return (not exports["mek_map-load"]:isMapLoaded(map.id) and map.enabled == 0) and canAdminMaps(player)
	end
	return false
end

function canAcceptMap(player, map, tabID)
	return (map.approved ~= 1 and map.enabled == 0) and canAdminMaps(player)
end

function canDeclineMap(player, map, tabID)
	return (map.approved ~= 2 and map.enabled == 0) and canAdminMaps(player)
end

function canImplementMap(player, map, tabID)
	return map.approved == 1 and map.enabled ~= 1 and canAdminMaps(player)
end

function canDisableMap(player, map, tabID)
	return map.approved == 1 and map.enabled == 1 and canAdminMaps(player)
end

function processMapContent(content, maxObjects, contentIsFilepath)
	local map = contentIsFilepath or fileCreate(settings.clientFile)
	result, message = false, "Harita içeriği işlenirken hatalar oluştu."
	if map then
		if not contentIsFilepath then
			fileWrite(map, content)
			fileClose(map)
		end
		local root = xmlLoadFile(contentIsFilepath and content or settings.clientFile)
		if root then
			local objects = xmlNodeGetChildren(root)
			if objects then
				if #objects < 1 or #objects > settings.externalMapMaxObjects then
					result, message =
						false,
						"Haritan ("
							.. #objects
							.. " nesne) en az bir, en fazla "
							.. maxObjects
							.. " nesne (world model kaldırmaları dahil) içermelidir."
				else
					local submitObjects = {}
					local int, dim
					for index, object in ipairs(objects) do
						local submitOneObject = {}
						for name, value in pairs(xmlNodeGetAttributes(object)) do
							submitOneObject[name] = tonumber(value) or value
							if submitOneObject[name] == "true" then
								submitOneObject[name] = 1
							elseif submitOneObject[name] == "false" then
								submitOneObject[name] = 0
							end
							if name == "interior" and value then
								if not int then
									int = value
								else
									if int ~= value then
										xmlUnloadFile(root)
										if not contentIsFilepath then
											fileDelete(settings.clientFile)
										end
										return false, "Bir haritadaki tüm nesneler aynı interiorda olmalıdır."
									end
								end
							elseif name == "dimension" and value then
								if not dim then
									dim = value
								else
									if dim ~= value then
										xmlUnloadFile(root)
										if not contentIsFilepath then
											fileDelete(settings.clientFile)
										end
										return false, "Bir haritadaki tüm nesneler aynı dimensionda olmalıdır."
									end
								end
							end
						end
						table.insert(submitObjects, submitOneObject)
					end
					xmlUnloadFile(root)
					if not contentIsFilepath then
						fileDelete(settings.clientFile)
					end
					return submitObjects
				end
			else
				result, message = false, "Harita içeriği işlenirken hatalar oluştu."
			end
			xmlUnloadFile(root)
		else
			result, message = false, "Harita içeriği işlenirken hatalar oluştu."
		end
		if not contentIsFilepath then
			fileDelete(settings.clientFile)
		end
	end
	return result, message
end
