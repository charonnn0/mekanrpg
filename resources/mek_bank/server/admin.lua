function addATM(thePlayer)
	if not exports.mek_integration:isPlayerManager(thePlayer) then
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
		return
	end

	local x, y, z = getElementPosition(thePlayer)
	local rotation = getPedRotation(thePlayer)
	local interior = getElementInterior(thePlayer)
	local dimension = getElementDimension(thePlayer)

	z = z - 0.5
	rotation = rotation - 180

	local id = exports.mek_mysql:getSmallestID("atms")
	if not id then
		outputChatBox("[!]#FFFFFF ATM ID'si alınamadı. Veritabanı hatası olabilir.", thePlayer, 255, 0, 0, true)
		return
	end

	local querySuccess = dbExec(
		exports.mek_mysql:getConnection(),
		"INSERT INTO atms (id, x, y, z, rotation, interior, dimension) VALUES (?, ?, ?, ?, ?, ?, ?)",
		id,
		x,
		y,
		z,
		rotation,
		interior,
		dimension
	)
	if querySuccess then
		outputChatBox(
			"[!]#FFFFFF Başarıyla #" .. id .. " numaralı bir ATM oluşturdunuz.",
			thePlayer,
			0,
			255,
			0,
			true
		)

		local newATM = createObject(2942, x, y, z, 0, 0, rotation)
		if newATM then
			setElementInterior(newATM, interior)
			setElementDimension(newATM, dimension)
			setElementFrozen(newATM, true)
			setObjectBreakable(newATM, false)
			setElementData(newATM, "atm", true)
			setElementData(newATM, "dbid", id)
			setElementData(newATM, "interaction", {
				callbackEvent = "atm.onInteraction",
				args = {},
				description = "ATM",
			})
			atms[id] = newATM
		else
			outputChatBox("[!]#FFFFFF ATM nesnesi oluşturulurken bir hata oluştu.", thePlayer, 255, 0, 0, true)
		end

		setElementPosition(thePlayer, x + 1, y, z)
	else
		outputChatBox("[!]#FFFFFF ATM oluşturulurken veritabanı hatası oluştu.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("addatm", addATM, false, false)

function deleteATM(thePlayer, commandName, atmID)
	if not exports.mek_integration:isPlayerManager(thePlayer) then
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
		return
	end

	if not atmID then
		outputChatBox("Kullanım: /" .. commandName .. " [ATM Numarası]", thePlayer, 255, 194, 14)
		return
	end

	local numericAtmID = tonumber(atmID)
	if not numericAtmID then
		outputChatBox("[!]#FFFFFF Geçersiz ATM numarası girdiniz.", thePlayer, 255, 0, 0, true)
		return
	end

	local atmToDestroy = atms[numericAtmID]

	if isElement(atmToDestroy) then
		local querySuccess = dbExec(exports.mek_mysql:getConnection(), "DELETE FROM atms WHERE id = ?", numericAtmID)
		if querySuccess then
			destroyElement(atmToDestroy)
			atms[numericAtmID] = nil
			outputChatBox(
				"[!]#FFFFFF #" .. numericAtmID .. " numaralı ATM başarıyla tüm dünyadan silindi.",
				thePlayer,
				0,
				0,
				255,
				true
			)
		else
			outputChatBox("[!]#FFFFFF ATM silinirken veritabanı hatası oluştu.", thePlayer, 255, 0, 0, true)
		end
	else
		outputChatBox("[!]#FFFFFF Böyle bir ATM numarası bulunmuyor veya yüklü değil.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("delatm", deleteATM, false, false)

function nearbyATMS(thePlayer)
	if not exports.mek_integration:isPlayerManager(thePlayer) then
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
		return
	end

	local mx, my, mz = getElementPosition(thePlayer)
	local playerDimension = getElementDimension(thePlayer)
	local playerInterior = getElementInterior(thePlayer)

	local foundATMs = 0
	for _, obj in ipairs(getElementsByType("object")) do
		if getElementData(obj, "atm") then
			if playerDimension == getElementDimension(obj) and playerInterior == getElementInterior(obj) then
				local x, y, z = getElementPosition(obj)
				local distance = getDistanceBetweenPoints3D(x, y, z, mx, my, mz)
				
				if distance < 5 then
					local atmID = getElementData(obj, "dbid")
					if atmID then
						outputChatBox(
							"[!]#FFFFFF Yakın ATM Numarası: #"
								.. atmID
								.. " (Uzaklık: "
								.. string.format("%.2f", distance)
								.. "m)",
							thePlayer,
							0,
							0,
							255,
							true
						)
						foundATMs = foundATMs + 1
					end
				end
			end
		end
	end

	if foundATMs == 0 then
		outputChatBox("[!]#FFFFFF Yakınınızda ATM bulunamadı.", thePlayer, 255, 194, 14, true)
	end
end
addCommandHandler("nearbyatms", nearbyATMS, false, false)
