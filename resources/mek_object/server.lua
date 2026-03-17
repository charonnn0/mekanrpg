local objects = {}

addEventHandler("onResourceStart", resourceRoot, function()
	dbQuery(function(qh)
		local results = dbPoll(qh, 0)
		for _, row in ipairs(results) do
			loadDimension(row.dimension)
		end
	end, exports.mek_mysql:getConnection(), "SELECT distinct(`dimension`) FROM `objects` ORDER BY `dimension` ASC")
end)

function loadDimension(dimension, onComplete)
	objects[dimension] = {}
	dbQuery(function(qh)
		local results = dbPoll(qh, 0)
		for _, row in ipairs(results) do
			table.insert(objects[dimension], {
				model = row.model,
				x = row.posX,
				y = row.posY,
				z = row.posZ,
				rot_x = row.rotX,
				rot_y = row.rotY,
				rot_z = row.rotZ,
				interior = row.interior,
				is_solid = row.solid == 1,
				is_double_sided = row.doublesided == 1,
				id = tostring(row.id),
				scale = row.scale,
				is_breakable = row.breakable == 1,
				alpha = row.alpha or 255,
			})
		end

		syncDimension(dimension)

		if type(onComplete) == "function" then
			onComplete(#objects[dimension])
		end
	end, exports.mek_mysql:getConnection(), "SELECT * FROM objects WHERE dimension = ?", dimension)
end

function removeInteriorObjects(dimension)
	dbExec(exports.mek_mysql:getConnection(), "DELETE FROM objects WHERE dimension = ?", dimension)
	objects[dimension] = nil
	triggerClientEvent(root, "object.clear", root, dimension)
end

function transferDimension(player, dimension)
	if dimension and objects[dimension] then
		triggerClientEvent(player, "object.sync", root, objects[dimension], dimension)
	else
		triggerClientEvent(player, "object.safeTrue", root)
	end
end

function syncDimension(dimension)
	for _, player in ipairs(getElementsByType("player")) do
		if dimension == getElementDimension(player) then
			transferDimension(player, dimension)
		end
	end
end

addEvent("object.requestsync", true)
addEventHandler("object.requestsync", root, function(dimension)
	transferDimension(source, dimension)
end)

addEvent("onPlayerInteriorChange", true)
addEventHandler("onPlayerInteriorChange", root, function(interior, dim)
	triggerClientEvent(root, "onClientInteriorChange", root, client, interior, dim)
end)

addCommandHandler("reloadinterior", function(player, command, dimension)
	if not exports.mek_integration:isPlayerTrialAdmin(player) then
		return
	end

	if not dimension then
		outputChatBox("Kullanım: /" .. command .. " [Dimension]", player, 255, 255, 255)
	end

	loadDimension(dimension, function(objectCount)
		outputChatBox(
			"[!]#FFFFFF "
				.. dimension
				.. " numaralı boyutta "
				.. objectCount
				.. " nesne başarıyla yeniden oluşturuldu.",
			player,
			0,
			255,
			0,
			true
		)
	end)
end, false, false)
