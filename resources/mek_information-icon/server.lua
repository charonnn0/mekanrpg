local informationIcons = {}

function loadAllInformationIcons()
	dbQuery(function(queryHandle)
		local result, rows = dbPoll(queryHandle, 0)
		if rows > 0 then
			for _, data in ipairs(result) do
				local id = tonumber(data.id)
				local createdBy = tostring(data.created_by)
				local x = tonumber(data.x)
				local y = tonumber(data.y)
				local z = tonumber(data.z)
				local interior = tonumber(data.interior)
				local dimension = tonumber(data.dimension)
				local text = tostring(data.text)

				informationIcons[id] = createPickup(x, y, z, 3, 1239, 0)

				setElementInterior(informationIcons[id], interior)
				setElementDimension(informationIcons[id], dimension)

				setElementData(informationIcons[id], "id", id)
				setElementData(informationIcons[id], "created_by", createdBy)
				setElementData(informationIcons[id], "text", text)
			end
		end
	end, exports.mek_mysql:getConnection(), "SELECT * FROM information_icons")
end
addEventHandler("onResourceStart", resourceRoot, loadAllInformationIcons)

function getNearbyInformationIcons(thePlayer, commandName)
	if exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
		local posX, posY, posZ = getElementPosition(thePlayer)
		local count = 0

		outputChatBox("[!]#FFFFFF Yakındaki Bilgi İkonları:", thePlayer, 0, 0, 255, true)

		for key, value in ipairs(informationIcons) do
			local id = getElementData(informationIcons[key], "id")
			if id then
				local x, y, z = getElementPosition(informationIcons[key])
				local distance = getDistanceBetweenPoints3D(posX, posY, posZ, x, y, z)
				if
					distance <= 10
					and getElementDimension(informationIcons[key]) == getElementDimension(thePlayer)
					and getElementInterior(informationIcons[key]) == getElementInterior(thePlayer)
				then
					local createdBy = getElementData(informationIcons[key], "created_by")
					local text = getElementData(informationIcons[key], "text")
					outputChatBox(
						"#" .. id .. " tarafından: " .. createdBy .. " - İkon: " .. text,
						thePlayer,
						255,
						255,
						255
					)
					count = count + 1
				end
			end
		end

		if count == 0 then
			outputChatBox("[!]#FFFFFF Hiçbir şey bulunamadı.", thePlayer, 255, 0, 0, true)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("nearbyii", getNearbyInformationIcons, false, false)

function makeInformationIcon(thePlayer, commandName, ...)
	if exports.mek_integration:isPlayerManager(thePlayer) then
		if ... then
			local args = { ... }
			local text = table.concat(args, " ")
			local x, y, z = getElementPosition(thePlayer)
			local interior = getElementInterior(thePlayer)
			local dimension = getElementDimension(thePlayer)
			local id = exports.mek_mysql:getSmallestID("information_icons")
			local createdBy = exports.mek_global:getPlayerFullAdminTitle(thePlayer)

			local query = dbExec(
				exports.mek_mysql:getConnection(),
				"INSERT INTO information_icons (id, x, y, z, interior, dimension, created_by, text) "
					.. "VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
				id,
				x,
				y,
				z,
				interior,
				dimension,
				createdBy,
				text
			)

			if query then
				informationIcons[id] = createPickup(x, y, z, 3, 1239, 0)

				setElementInterior(informationIcons[id], interior)
				setElementDimension(informationIcons[id], dimension)

				setElementData(informationIcons[id], "id", id)
				setElementData(informationIcons[id], "created_by", createdBy)
				setElementData(informationIcons[id], "text", text)

				outputChatBox("[!]#FFFFFF Bilgi ikonu oluşturuldu. ID: " .. id, thePlayer, 0, 255, 0, true)
			else
				outputChatBox("[!]#FFFFFF Bilgi ikonu oluşturulurken bir hata oluştu.", thePlayer, 255, 0, 0, true)
			end
		else
			outputChatBox("Kullanım: /" .. commandName .. " [Bilgi]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("addii", makeInformationIcon, false, false)

function deleteInformationIcon(thePlayer, commandName, id)
	if exports.mek_integration:isPlayerManager(thePlayer) then
		if tonumber(id) then
			local id = tonumber(id)
			if informationIcons[id] then
				destroyElement(informationIcons[id])
				local query = dbExec(exports.mek_mysql:getConnection(), "DELETE FROM information_icons WHERE id = ?", id)
				if query then
					informationIcons[id] = nil
					outputChatBox("[!]#FFFFFF Bilgi ikonu silindi. ID: " .. id, thePlayer, 0, 255, 0, true)
				else
					outputChatBox("[!]#FFFFFF Bilgi ikonu silinirken bir hata oluştu.", thePlayer, 255, 0, 0, true)
				end
			else
				outputChatBox("[!]#FFFFFF Bu ID'ye sahip bir bilgi ikonu mevcut değil.", thePlayer, 255, 0, 0, true)
			end
		else
			outputChatBox("Kullanım: /delii [id]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("delii", deleteInformationIcon, false, false)
