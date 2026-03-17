function reconPlayer(thePlayer, commandName, targetPlayer)
	if exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
		if not targetPlayer then
			local rx = getElementData(thePlayer, "reconx")
			local ry = getElementData(thePlayer, "recony")
			local rz = getElementData(thePlayer, "reconz")
			local reconrot = getElementData(thePlayer, "reconrot")
			local recondimension = getElementData(thePlayer, "recondimension")
			local reconinterior = getElementData(thePlayer, "reconinterior")

			if not rx or not ry or not rz or not reconrot or not recondimension or not reconinterior then
				outputChatBox("Kullanım: /recon [Karakter Adı / ID]", thePlayer, 255, 194, 14)
			else
				detachElements(thePlayer)

				setElementPosition(thePlayer, rx, ry, rz)
				setPedRotation(thePlayer, reconrot)
				setElementDimension(thePlayer, recondimension)
				setElementInterior(thePlayer, reconinterior)
				setCameraInterior(thePlayer, reconinterior)

				setElementData(thePlayer, "reconx", nil, false)
				setElementData(thePlayer, "recony", nil, false)
				setElementData(thePlayer, "reconz", nil, false)
				setElementData(thePlayer, "reconrot", nil, false)
				setCameraTarget(thePlayer, thePlayer)
				setElementAlpha(thePlayer, 255)
				outputChatBox("[!]#FFFFFF İzlemeyi bıraktınız.", thePlayer, 0, 255, 0, true)
			end
		else
			local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
			if targetPlayer then
				if not getElementData(targetPlayer, "logged") then
					outputChatBox(
						"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
						thePlayer,
						255,
						0,
						0,
						true
					)
				else
					if targetPlayer == thePlayer then
						outputChatBox("[!]#FFFFFF Kendinizi reconlayamazsınız.", thePlayer, 255, 0, 0, true)
						return
					end
					
					if not exports.mek_integration:canAdminPunish(thePlayer, targetPlayer) then
						outputChatBox("[!]#FFFFFF Kendinizden üst veya eşit yetkideki birini izleyemezsiniz.", thePlayer, 255, 0, 0, true)
						return
					end

					setElementAlpha(thePlayer, 0)

					if getPedOccupiedVehicle(thePlayer) then
						removePedFromVehicle(thePlayer)
					end

					if
						(not getElementData(thePlayer, "reconx") or getElementData(thePlayer, "reconx") == true)
						and not getElementData(thePlayer, "recony")
					then
						local x, y, z = getElementPosition(thePlayer)
						local rot = getPedRotation(thePlayer)
						local dimension = getElementDimension(thePlayer)
						local interior = getElementInterior(thePlayer)
						setElementData(thePlayer, "reconx", x, false)
						setElementData(thePlayer, "recony", y, false)
						setElementData(thePlayer, "reconz", z, false)
						setElementData(thePlayer, "reconrot", rot, false)
						setElementData(thePlayer, "recondimension", dimension, false)
						setElementData(thePlayer, "reconinterior", interior, false)
					end
					setPedWeaponSlot(thePlayer, 0)

					local playerdimension = getElementDimension(targetPlayer)
					local playerinterior = getElementInterior(targetPlayer)

					setElementDimension(thePlayer, playerdimension)
					setElementInterior(thePlayer, playerinterior)
					setCameraInterior(thePlayer, playerinterior)

					local x, y, z = getElementPosition(targetPlayer)
					setElementPosition(thePlayer, x - 10, y - 10, z - 5)
					local success = attachElements(thePlayer, targetPlayer, -10, -10, -5)
					if not success then
						success = attachElements(thePlayer, targetPlayer, -5, -5, -5)
						if not success then
							success = attachElements(thePlayer, targetPlayer, 5, 5, -5)
						end
					end

					if not success then
						outputChatBox("[!]#FFFFFF Bir sorun oluştu.", thePlayer, 255, 0, 0, true)
					else
						setCameraTarget(thePlayer, targetPlayer)
						outputChatBox(
							"[!]#FFFFFF İzlediğiniz oyuncu: " .. targetPlayerName,
							thePlayer,
							0,
							255,
							0,
							true
						)
						exports.mek_global:sendMessageToAdmins(
							"[ADM] "
								.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili "
								.. targetPlayerName
								.. " isimli oyuncuyu izlemeye başladı."
						)
						exports.mek_logs:addLog(
							"recon",
							exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili "
								.. targetPlayerName
								.. " isimli oyuncuyu izlemeye başladı."
						)
					end
				end
			end
		end
	end
end
addCommandHandler("recon", reconPlayer, false, false)

addEventHandler("onPlayerInteriorChange", root, function()
	for _, player in ipairs(getElementsByType("player")) do
		if isElement(player) then
			local cameraTarget = getCameraTarget(player)
			if cameraTarget then
				if cameraTarget == source then
					local interior = getElementInterior(source)
					local dimension = getElementDimension(source)
					setCameraInterior(player, interior)
					setElementInterior(player, interior)
					setElementDimension(player, dimension)
				end
			end
		end
	end
end)

addEventHandler("onPlayerQuit", root, function()
	for _, player in ipairs(getElementsByType("player")) do
		if isElement(player) then
			local cameraTarget = getCameraTarget(player)
			if cameraTarget then
				if cameraTarget == source then
					reconPlayer(player)
				end
			end
		end
	end
end)
