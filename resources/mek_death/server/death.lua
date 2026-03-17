local deathMessages = {
	"tahtalı köyü boyladı",
	"nalları dikti",
	"imamın kayığına bindi",
	"sizlere ömür",
	"cenaze namazı kılındı",
	"meftun oldu",
	"rahmetli oldu",
	"toprakla buluştu",
	"hesap vermeye gitti",
	"daha fazla dayanamadı",
	"hakkın rahmetine kavuştu",
	"ebedi uykuya daldı",
	"sol yolculuğuna uğurlandı",
	"ölümün soğuk kollarına teslim oldu.",
}

addEvent("death.selfCharacterKill", true)
addEventHandler("death.selfCharacterKill", root, function(reason)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not source:getData("logged") then
		return
	end

	if source:getData("cked") then
		exports.mek_infobox:addBox(source, "error", "Zaten ölüsünüz.")
		return
	end

	if type(reason) ~= "string" or #reason > 50 then
		exports.mek_infobox:addBox(source, "error", "Geçersiz sebep.")
		return
	end

	if
		dbExec(
			exports.mek_mysql:getConnection(),
			"UPDATE characters SET cked = 1, ck_reason = ? WHERE id = ?",
			reason,
			source:getData("dbid")
		)
	then
		fadeCamera(source, false)
		
		setTimer(function(source)
			triggerClientEvent(source, "death.renderBlackWhiteShader", source)
			fadeCamera(source, true, 3)
		end, 1500, 1, source)
		
		source:setData("cked", true)
		source:setData("ck_reason", reason)
		source:setFrozen(true)
		source:setData("frozen", true)
		toggleAllControls(source, false, true, false)
		
		if isPedInVehicle(source) then
			source:setAnimation("ped", "CAR_dead_LHS", -1, true, false, false)
		else
			source:setAnimation("CRACK", "crckidle2", -1, true, false, false)
		end

		local randomMessage = deathMessages[math.random(#deathMessages)]

		outputChatBox(
			"(( "
				.. getPlayerName(source):gsub("_", " ")
				.. " " .. randomMessage .. " - Sebep: "
				.. reason
				.. " ))",
			root,
			255,
			0,
			0
		)
	else
		exports.mek_infobox:addBox(source, "error", "Bir sorun oluştu.")
	end
end)

addEventHandler("onPlayerCommand", root, function()
	if getElementData(source, "cked") then
		cancelEvent(true)
	end
end)

addEventHandler("onVehicleStartEnter", root, function(player)
    if getElementData(player, "cked") then
        cancelEvent(true)
    end
end)

addEventHandler("onVehicleStartExit", root, function(player)
    if getElementData(player, "cked") then
        cancelEvent(true)
    end
end)
