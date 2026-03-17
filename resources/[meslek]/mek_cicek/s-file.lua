DOUBLE_SALARY = false

mysql = exports.mek_mysql

toplamamarker = createMarker(1872.6982421875, -1236.8017578125, 12.745145797729, "cylinder", 12, 10, 177, 255, 20)
satmarker = createMarker(1884.107421875, -1268.2333984375, 12.546875, "cylinder", 3.5, 10, 177, 255, 20)

function cicekbindsoygun()
	local players = exports.mek_pool:getPoolElementsByType("player")
	for k, arrayPlayer in ipairs(players) do
		if not(isKeyBound(arrayPlayer, "e", "down", cicek_gir)) then
			bindKey(arrayPlayer, "e", "down", cicek_gir)
		end
	end
end

function ciceksoygunbind()
	bindKey(source, "e", "down", cicek_gir)
end
addEventHandler("onResourceStart", getResourceRootElement(), cicekbindsoygun)
addEventHandler("onPlayerJoin", getRootElement(), ciceksoygunbind)

function cicek_gir(thePlayer)
	x,y,z = getElementPosition(thePlayer)
	if getElementData(thePlayer, "bind:engel") then return end
	if isPedInVehicle(thePlayer) then return end

	if isElementWithinMarker(thePlayer, toplamamarker) then
		if getElementData(thePlayer, "dead") == 1 then exports.mek_infobox:addBox(thePlayer, "error", "Baygın olduğun için cicek toplayamazsın.") return end
		if z > 20.3 then exports.mek_infobox:addBox(thePlayer, "error", "Önce bir yere in akıllı.") return end	
		setElementFrozen(thePlayer, true)	
		setPedAnimation(thePlayer, "BOMBER", "BOM_Plant", -1, true, false, false)
		triggerClientEvent(thePlayer, "cicek:toplama", thePlayer)
		setElementData(thePlayer, "cicek:top", true)
		setElementData(thePlayer, "bind:engel", true)
	elseif isElementWithinMarker(thePlayer, satmarker) then
		if exports["mek_item"]:hasItem(thePlayer, 351) then
			setElementFrozen(thePlayer, true)
			setPedAnimation(thePlayer, "PED", "IDLE_CHAT", -1, true, false, false)
			setTimer(function()
				setPedAnimation(thePlayer, nil)
				setElementFrozen(thePlayer, false)
				triggerEvent("cicek:ver", thePlayer, thePlayer)
				setElementData(thePlayer, "cicek:top", false)
				setElementData(thePlayer, "bind:engel", false)
			end, 2000, 1)
		else
			exports.mek_infobox:addBox(thePlayer, "error", "Çiçek olmadan satma işlemi yapamazsın.")
		end
	end
end

function cicek_ver(thePlayer)
	if getElementData(thePlayer, "cicek:tur") == "toplama" then
		local now = getTickCount()
		local lastCollect = getElementData(thePlayer, "cicek:lastCollect") or 0
		if now - lastCollect < 3200 then
			kickPlayer(thePlayer, "hahahaha")
			setElementFrozen(thePlayer, false)
			setPedAnimation(thePlayer, nil)
			setElementData(thePlayer, "cicek:top", false)
			setElementData(thePlayer, "bind:engel", false)
			return
		end
		setElementData(thePlayer, "cicek:lastCollect", now)

		setElementFrozen(thePlayer, false)
		setPedAnimation(thePlayer, nil)
		exports.mek_infobox:addBox(thePlayer, "success", "Bir adet çiçek topladın.")
		exports["mek_item"]:giveItem(thePlayer, 351, 1)	
		exports.mek_logs:addLog("ciceks", "[CİÇEK] " .. getPlayerName(thePlayer) .. " isimli oyuncu çiçek topladı.")
		--exports.mek_discord:sendMessage("cicek", "[CİCEK] **" .. getPlayerName(thePlayer):gsub("_", " ") .. "** isimli oyuncu bir adet çiçek topladı.")
	elseif getElementData(thePlayer, "cicek:tur") == "satma" then
		setPedAnimation(thePlayer, nil)
		local cicekler = exports["mek_item"]:countItems(thePlayer, 351, 1)
		local basePrice = 1500
		local multiplier = DOUBLE_SALARY and 2 or 1
		toplamPara = (cicekler * basePrice * multiplier)
		exports.mek_global:giveMoney(thePlayer, toplamPara)
		exports.mek_logs:addLog("ciceks", "[CİÇEK] " .. getPlayerName(thePlayer) .. " isimli oyuncu " .. cicekler .. " adet çiçek sattı ve " .. exports.mek_global:formatMoney(toplamPara) .. " kazandı.")
		--exports.mek_discord:sendMessage("cicek", "[CİÇEK] **" .. getPlayerName(thePlayer):gsub("_", " ") .. "** isimli oyuncu **" .. cicekler .. "** adet çiçek sattı ve **" .. exports.mek_global:formatMoney(toplamPara) .. "** kazandı.")
		for i = 0, cicekler do
			exports["mek_item"]:takeItem(thePlayer, 351, 1)
		end
	end	
end
addEvent("cicek:ver", true)
addEventHandler("cicek:ver", root, cicek_ver)

function cicek_e_gostre(player)
setElementData(player, "cicek:e", true)
setElementData(player, "cicek:tur", "toplama")
end
addEventHandler("onMarkerHit", toplamamarker, cicek_e_gostre)
function cicek_e_gizle(player)
setElementData(player, "cicek:e", false)
setElementData(player, "cicek:tur", false)
end
addEventHandler("onMarkerLeave", toplamamarker, cicek_e_gizle)
addEventHandler("onMarkerLeave", satmarker, cicek_e_gizle)
function cicek_e_gostre3(player)
setElementData(player, "cicek:e", true)
setElementData(player, "cicek:tur", "satma")
end
addEventHandler("onMarkerHit", satmarker, cicek_e_gostre3)