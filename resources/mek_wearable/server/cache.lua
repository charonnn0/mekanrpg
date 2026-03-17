local mysql = exports.mek_mysql
local playerWearables = {}

addEventHandler("onResourceStart", resourceRoot, function()
	for _, player in ipairs(getElementsByType("player")) do
		playerWearables[player] = {}
	end
end)

addEventHandler("onPlayerJoin", root, function()
	playerWearables[source] = {}
end)

addEventHandler("onPlayerQuit", root, function()
	for index, value in ipairs(playerWearables[source]) do
		if isElement(value["object"]) then
			value["object"]:destroy()
		end
	end
	playerWearables[source] = {}
end)

function addWearablePlayer(player, temp_table)
	if player:getData("logged") then
		x, y, z = player.position
		createdObject = Object(temp_table.model, x, y, z)
		createdObject:setData("dbid", temp_table.id)
		createdObject:setScale(temp_table.sx, temp_table.sy, temp_table.sz)
		createdObject.interior = player.interior
		createdObject.dimension = player.dimension

		exports.mek_bones:attachElementToBone(
			createdObject,
			player,
			temp_table.bone,
			temp_table.x,
			temp_table.y,
			temp_table.z,
			temp_table.rx,
			temp_table.ry,
			temp_table.rz
		)

		playerWearables[player][#playerWearables[player] + 1] = {
			["id"] = temp_table.id,
			["object"] = createdObject,
			["model"] = createdObject.model,
			["data"] = { temp_table.bone, temp_table.x, temp_table.rx, temp_table.ry, temp_table.rz },
		}
		setElementData(player, "wearables", playerWearables[player])
	end
end

function removeWearableToPlayer(player, object)
	if player:getData("logged") then
		if isElement(object) then
			for index, value in ipairs(playerWearables[player]) do
				if value["object"] == object then
					table.remove(playerWearables[player], index)
				end
			end
			exports.mek_bones:detachElementFromBone(object)
			object:destroy()
			setElementData(player, "wearables", playerWearables[player])
		end
	end
end

function loadWearables(player, dat)
	if #dat > 0 then
		loadPlayerWearables(player, { use = true, data = dat })
	end
end

addEventHandler("onPlayerQuit", root, function()
	local wearablesToSave = {}
	for index, value in ipairs(playerWearables[source]) do
		if isElement(value["object"]) then
			value["object"]:destroy()
			wearablesToSave[#wearablesToSave + 1] = { id = value["id"] }
		end
	end
	playerWearables[source] = {}
end)

addEvent("wearable.updatePosition", true)
addEventHandler("wearable.updatePosition", root, function(object, int, dim)
	if not client then return end
	if not isElement(object) then return end
	
	local isOwner = false
	if playerWearables[client] then
		for _, wearable in ipairs(playerWearables[client]) do
			if wearable["object"] == object then
				isOwner = true
				break
			end
		end
	end
	
	if not isOwner then
		outputDebugString("[mek_wearable] Exploit attempt blocked from: " .. getPlayerName(client), 2)
		return
	end
	
	object:setInterior(int)
	object:setDimension(dim)
end)

addEvent("wearable.delete", true)
addEventHandler("wearable.delete", root, function(player, dbid)
	if not client then return end
	if client ~= player then
		return
	end
	
	local playerDbid = client:getData("dbid")
	if not playerDbid then return end
	
	dbExec(mysql:getConnection(), "DELETE FROM `wearables` WHERE `id` = ? AND `owner` = ?", dbid, playerDbid)
	loadPlayerWearables(client)
	outputChatBox("[!]#FFFFFF Seçili aksesuar başarıyla silindi.", client, 0, 255, 0, true)
end)

addEvent("wearable.savePositions", true)
addEventHandler("wearable.savePositions", root, function(player, data)
	if not client then return end
	if client ~= player then
		return
	end
	
	local playerDbid = client:getData("dbid")
	if not playerDbid then return end
	
	local self = {}
	self.x, self.y, self.z, self.rx, self.ry, self.rz, self.sx, self.sy, self.sz, self.bone, self.dbid =
		data["position"][1],
		data["position"][2],
		data["position"][3],
		data["position"][4],
		data["position"][5],
		data["position"][6],
		data["position"][7],
		data["position"][8],
		data["position"][9],
		data["bone"],
		data["dbid"]
	dbExec(
		mysql:getConnection(),
		"UPDATE `wearables` SET `x` = ?, `y` = ?, `z` = ?, `rx` = ?, `ry` = ?, `rz` = ?, `sx` = ?, `sy` = ?, `sz` = ?, `bone` = ? WHERE `id` = ? AND `owner` = ?",
		self.x,
		self.y,
		self.z,
		self.rx,
		self.ry,
		self.rz,
		self.sx,
		self.sy,
		self.sz,
		self.bone,
		self.dbid,
		playerDbid
	)
	outputChatBox("[!]#FFFFFF Aksesuarınızın pozisyonu başarıyla kaydedildi!", client, 0, 255, 0, true)
	loadPlayerWearables(client)
end)

addEvent("wearable.useArtifact", true)
addEventHandler("wearable.useArtifact", root, function(player, data)
	if not client then return end
	if client ~= player then
		outputDebugString("[mek_wearable] UseArtifact exploit attempt from: " .. getPlayerName(client), 2)
		return
	end
	
	local playerDbid = client:getData("dbid")
	if not playerDbid then return end
	if tonumber(data.owner) ~= tonumber(playerDbid) then
		outputDebugString("[mek_wearable] UseArtifact ownership exploit from: " .. getPlayerName(client), 2)
		return
	end
	
	addWearablePlayer(client, data)
end)

addEvent("wearable.detachArtifact", true)
addEventHandler("wearable.detachArtifact", root, function(player, data)
	if not client then return end
	if client ~= player then
		outputDebugString("[mek_wearable] DetachArtifact exploit attempt from: " .. getPlayerName(client), 2)
		return
	end
	
	if not playerWearables[client] then return end
	for index, value in ipairs(playerWearables[client]) do
		if tonumber(value.model) == tonumber(data.model) then
			removeWearableToPlayer(client, value.object)
		end
	end
end)

function loadPlayerWearables(player, settings)
	local pWearables = {}
	dbQuery(function(queryHandle)
		local res, query_lines, err = dbPoll(queryHandle, 0)
		if query_lines > 0 then
			for i, v in ipairs(res) do
				local id = tonumber(v.id)
				local objectID = tonumber(v.model)
				local owner = tonumber(v.owner)
				local bone = tonumber(v.bone)
				local x = tonumber(v.x)
				local y = tonumber(v.y)
				local z = tonumber(v.z)
				local rx = tonumber(v.rx)
				local ry = tonumber(v.ry)
				local rz = tonumber(v.rz)
				local sx = tonumber(v.sx)
				local sy = tonumber(v.sy)
				local sz = tonumber(v.sz)
				pWearables[#pWearables + 1] = {
					["id"] = id,
					["model"] = objectID,
					["owner"] = owner,
					["bone"] = bone,
					["x"] = x,
					["y"] = y,
					["z"] = z,
					["rx"] = rx,
					["ry"] = ry,
					["rz"] = rz,
					["sx"] = sx,
					["sy"] = sy,
					["sz"] = sz,
				}
				if settings and settings.use == true then
					for i, v in ipairs(settings.data) do
						if tonumber(v.id) == tonumber(id) then
							addWearablePlayer(player, {
								["id"] = id,
								["model"] = objectID,
								["owner"] = owner,
								["bone"] = bone,
								["x"] = x,
								["y"] = y,
								["z"] = z,
								["rx"] = rx,
								["ry"] = ry,
								["rz"] = rz,
								["sx"] = sx,
								["sy"] = sy,
								["sz"] = sz,
							})
						end
					end
				end
				--addWearablePlayer(player, {objectID, bone, x, y, z, rx, ry, rz})
			end
			triggerClientEvent(player, "wearable.loadWearables", player, pWearables)
		end
	end, mysql:getConnection(), "SELECT * FROM `wearables` WHERE `owner` = ?", player:getData("dbid"))
end
addEvent("wearable.loadMyWearables", true)
addEventHandler("wearable.loadMyWearables", root, function(player)
	if not client then return end
	if client ~= player then
		outputDebugString("[mek_wearable] LoadWearables exploit attempt from: " .. getPlayerName(client), 2)
		return
	end
	loadPlayerWearables(client)
end)
