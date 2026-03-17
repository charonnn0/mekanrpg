local onHandlePINChange_data = nil

local GUIEditor_Button = {}
local GUIEditor_Label = {}
local GUIEditor_Image = {}

local ledFont = guiCreateFont("public/fonts/digi.ttf", 18) or "default"
local numFont = guiCreateFont(":mek_ui/public/fonts/UbuntuRegular.ttf", 20) or "default"

local currentPad = nil
local currentInt = nil
local passcode = "____"
local errorCode = "kurulmamış"
local isOwner = nil

function openKeypadInterface(thePad)
	passcode = "____"
	isIntLocked = true

	errorCode = "kurulmamış"
	isOwner = nil
	setElementData(localPlayer, "pressedAutoLock", nil, false)

	local screenText = "Sifreyi girin:\n" .. passcode
	if not thePad or not isElement(thePad) or not isElement(thePad) then
		screenText = "Hata!"
		exports.mek_infobox:addBox(
			"error",
			"Sistem düzgün kurulamadı, lütfen cihazı yeniden yükleyin."
		)
	else
		currentPad = thePad
		currentInt = getInteriorFromID(getElementData(thePad, "itemValue"))
		if not currentInt then
			errorCode = "bozuk"
			playSoundBtn("warning", thePad)
			screenText = "Bozuk ((#1))"
		else
			local stt = getElementData(currentInt, "status")
			if getElementData(currentInt, "keypad_lock") and (stt.type == 0 or stt.type == 1 or stt.type == 3) then
				errorCode = "kuruldu ancak oturum açılmadı"
			else
				errorCode = "bozuk"
				screenText = "Bozuk ((#2))"
				playSoundBtn("warning", thePad)
			end
			isIntLocked = stt.locked
			isOwner = stt.owner == getElementData(localPlayer, "dbid")
		end
	end

	if errorCode == "kuruldu ancak oturum açılmadı" then
		playSoundBtn("enter_password", thePad)
	end

	local savedPw = false
	if
		errorCode ~= "kurulmamış"
		and errorCode ~= "bozuk"
		and (not currentInt or not getElementData(currentInt, "keypad_lock_pw"))
	then
		errorCode = "yeni şifre"
		passcode = "____"
		screenText = "Yeni sifreyi girin:\n" .. passcode
	else
		savedPw = currentInt and getElementData(currentInt, "keypad_lock_pw") or false
	end

	closeKeypadInterface()
	showCursor(true)

	local r, g, b = 233, 233, 233
	GUIEditor_Image[1] = guiCreateStaticImage(619, 163, 280, 400, "public/images/keypad.png", false)
	exports.mek_global:centerWindow(GUIEditor_Image[1])

	GUIEditor_Image["lockState"] = guiCreateStaticImage(
		41,
		46,
		25,
		29,
		"public/images/keypad_" .. (isIntLocked and "locked" or "unlocked") .. ".png",
		false,
		GUIEditor_Image[1]
	)

	GUIEditor_Label[1] = guiCreateLabel(41, 46, 197, 97, screenText, false, GUIEditor_Image[1])
	guiLabelSetVerticalAlign(GUIEditor_Label[1], "center")
	guiLabelSetHorizontalAlign(GUIEditor_Label[1], "center", true)
	guiSetFont(GUIEditor_Label[1], ledFont)
	GUIEditor_Label[2] = guiCreateLabel(109, 204, 44, 36, "1", false, GUIEditor_Image[1])
	guiSetFont(GUIEditor_Label[2], numFont)
	guiLabelSetColor(GUIEditor_Label[2], r, g, b)
	GUIEditor_Label[3] = guiCreateLabel(159, 204, 44, 36, "2", false, GUIEditor_Image[1])
	guiSetFont(GUIEditor_Label[3], numFont)
	guiLabelSetColor(GUIEditor_Label[3], r, g, b)
	GUIEditor_Label[4] = guiCreateLabel(208, 205, 44, 36, "3", false, GUIEditor_Image[1])
	guiSetFont(GUIEditor_Label[4], numFont)
	guiLabelSetColor(GUIEditor_Label[4], r, g, b)
	GUIEditor_Label[5] = guiCreateLabel(109, 245, 44, 36, "4", false, GUIEditor_Image[1])
	guiSetFont(GUIEditor_Label[5], numFont)
	guiLabelSetColor(GUIEditor_Label[5], r, g, b)
	GUIEditor_Label[6] = guiCreateLabel(159, 245, 44, 36, "5", false, GUIEditor_Image[1])
	guiSetFont(GUIEditor_Label[6], numFont)
	guiLabelSetColor(GUIEditor_Label[6], r, g, b)
	GUIEditor_Label[7] = guiCreateLabel(208, 245, 44, 36, "6", false, GUIEditor_Image[1])
	guiSetFont(GUIEditor_Label[7], numFont)
	guiLabelSetColor(GUIEditor_Label[7], r, g, b)
	GUIEditor_Label[8] = guiCreateLabel(109, 286, 44, 36, "7", false, GUIEditor_Image[1])
	guiSetFont(GUIEditor_Label[8], numFont)
	guiLabelSetColor(GUIEditor_Label[8], r, g, b)
	GUIEditor_Label[9] = guiCreateLabel(159, 286, 44, 36, "8", false, GUIEditor_Image[1])
	guiSetFont(GUIEditor_Label[9], numFont)
	guiLabelSetColor(GUIEditor_Label[9], r, g, b)
	GUIEditor_Label[10] = guiCreateLabel(208, 286, 44, 36, "9", false, GUIEditor_Image[1])
	guiSetFont(GUIEditor_Label[10], numFont)
	guiLabelSetColor(GUIEditor_Label[10], r, g, b)
	GUIEditor_Label[11] = guiCreateLabel(158, 327, 44, 36, "0", false, GUIEditor_Image[1])
	guiSetFont(GUIEditor_Label[11], numFont)
	guiLabelSetColor(GUIEditor_Label[11], r, g, b)
	GUIEditor_Label[12] = guiCreateLabel(109, 326, 44, 36, "*", false, GUIEditor_Image[1])
	guiSetFont(GUIEditor_Label[12], numFont)
	guiLabelSetColor(GUIEditor_Label[12], r, g, b)
	GUIEditor_Label[13] = guiCreateLabel(207, 326, 44, 36, "#", false, GUIEditor_Image[1])
	guiSetFont(GUIEditor_Label[13], numFont)
	guiLabelSetColor(GUIEditor_Label[13], r, g, b)
	GUIEditor_Label[14] = guiCreateLabel(38, 163, 71, 25, "Giriş Yap", false, GUIEditor_Image[1])
	guiLabelSetVerticalAlign(GUIEditor_Label[14], "center")
	guiLabelSetColor(GUIEditor_Label[14], r, g, b)
	guiLabelSetHorizontalAlign(GUIEditor_Label[14], "right", false)
	guiSetFont(GUIEditor_Label[14], "default-bold-small")
	GUIEditor_Label[15] = guiCreateLabel(149, 164, 59, 24, "Oto-Kilit", false, GUIEditor_Image[1])
	guiLabelSetVerticalAlign(GUIEditor_Label[15], "center")
	guiLabelSetColor(GUIEditor_Label[15], r, g, b)
	guiLabelSetHorizontalAlign(GUIEditor_Label[15], "right", false)
	guiSetFont(GUIEditor_Label[15], "default-bold-small")
	GUIEditor_Label[16] = guiCreateLabel(62, 336, 43, 27, "Çıkış", false, GUIEditor_Image[1])
	guiLabelSetVerticalAlign(GUIEditor_Label[16], "center")
	guiLabelSetColor(GUIEditor_Label[16], r, g, b)
	GUIEditor_Label[17] = guiCreateLabel(62, 292, 43, 27, "Kaldır", false, GUIEditor_Image[1])
	guiLabelSetVerticalAlign(GUIEditor_Label[17], "center")
	guiLabelSetColor(GUIEditor_Label[17], r, g, b)
	GUIEditor_Label[18] = guiCreateLabel(62, 250, 43, 27, "Panik", false, GUIEditor_Image[1])
	guiLabelSetVerticalAlign(GUIEditor_Label[18], "center")
	guiLabelSetColor(GUIEditor_Label[18], r, g, b)
	GUIEditor_Label[19] = guiCreateLabel(62, 205, 43, 27, isIntLocked and "Kilidini Aç" or "Kilitle", false, GUIEditor_Image[1])
	guiLabelSetVerticalAlign(GUIEditor_Label[19], "center")
	guiLabelSetColor(GUIEditor_Label[19], r, g, b)

	GUIEditor_Button[1] = guiCreateButton(215, 163, 32, 29, "Oto-Kilit", false, GUIEditor_Image[1])
	GUIEditor_Button[2] = guiCreateButton(117, 163, 32, 29, "Giriş Yap", false, GUIEditor_Image[1])
	GUIEditor_Button[3] =
		guiCreateButton(25, 205, 32, 29, isIntLocked and "Kilidini Aç" or "Kilitle", false, GUIEditor_Image[1])
	GUIEditor_Button[4] = guiCreateButton(25, 250, 32, 29, "Panik", false, GUIEditor_Image[1])
	GUIEditor_Button[5] = guiCreateButton(25, 293, 32, 29, "Kaldır", false, GUIEditor_Image[1])
	GUIEditor_Button[6] = guiCreateButton(25, 336, 32, 29, "Çıkış", false, GUIEditor_Image[1])
	addEventHandler("onClientGUIClick", GUIEditor_Button[6], function(button)
		if source == GUIEditor_Button[6] then
			closeKeypadInterface()
		end
	end)

	local alpha = 0.2
	guiSetAlpha(GUIEditor_Button[1], alpha)
	guiSetAlpha(GUIEditor_Button[2], alpha)
	guiSetAlpha(GUIEditor_Button[3], alpha)
	guiSetAlpha(GUIEditor_Button[4], alpha)
	guiSetAlpha(GUIEditor_Button[5], alpha)
	guiSetAlpha(GUIEditor_Button[6], alpha)

	local hR, hG, hB = 88, 127, 138
	addEventHandler("onClientMouseEnter", GUIEditor_Image[1], function()
		if source == GUIEditor_Label[2] then
			guiLabelSetColor(GUIEditor_Label[2], hR, hG, hB)
		elseif source == GUIEditor_Label[3] then
			guiLabelSetColor(GUIEditor_Label[3], hR, hG, hB)
		elseif source == GUIEditor_Label[4] then
			guiLabelSetColor(GUIEditor_Label[4], hR, hG, hB)
		elseif source == GUIEditor_Label[5] then
			guiLabelSetColor(GUIEditor_Label[5], hR, hG, hB)
		elseif source == GUIEditor_Label[6] then
			guiLabelSetColor(GUIEditor_Label[6], hR, hG, hB)
		elseif source == GUIEditor_Label[7] then
			guiLabelSetColor(GUIEditor_Label[7], hR, hG, hB)
		elseif source == GUIEditor_Label[8] then
			guiLabelSetColor(GUIEditor_Label[8], hR, hG, hB)
		elseif source == GUIEditor_Label[9] then
			guiLabelSetColor(GUIEditor_Label[9], hR, hG, hB)
		elseif source == GUIEditor_Label[10] then
			guiLabelSetColor(GUIEditor_Label[10], hR, hG, hB)
		elseif source == GUIEditor_Label[11] then
			guiLabelSetColor(GUIEditor_Label[11], hR, hG, hB)
		elseif source == GUIEditor_Label[12] then
			guiLabelSetColor(GUIEditor_Label[12], hR, hG, hB)
		elseif source == GUIEditor_Label[13] then
			guiLabelSetColor(GUIEditor_Label[13], hR, hG, hB)
		end
	end)

	addEventHandler("onClientMouseLeave", GUIEditor_Image[1], function()
		if source == GUIEditor_Label[2] then
			guiLabelSetColor(GUIEditor_Label[2], r, g, b)
		elseif source == GUIEditor_Label[3] then
			guiLabelSetColor(GUIEditor_Label[3], r, g, b)
		elseif source == GUIEditor_Label[4] then
			guiLabelSetColor(GUIEditor_Label[4], r, g, b)
		elseif source == GUIEditor_Label[5] then
			guiLabelSetColor(GUIEditor_Label[5], r, g, b)
		elseif source == GUIEditor_Label[6] then
			guiLabelSetColor(GUIEditor_Label[6], r, g, b)
		elseif source == GUIEditor_Label[7] then
			guiLabelSetColor(GUIEditor_Label[7], r, g, b)
		elseif source == GUIEditor_Label[8] then
			guiLabelSetColor(GUIEditor_Label[8], r, g, b)
		elseif source == GUIEditor_Label[9] then
			guiLabelSetColor(GUIEditor_Label[9], r, g, b)
		elseif source == GUIEditor_Label[10] then
			guiLabelSetColor(GUIEditor_Label[10], r, g, b)
		elseif source == GUIEditor_Label[11] then
			guiLabelSetColor(GUIEditor_Label[11], r, g, b)
		elseif source == GUIEditor_Label[12] then
			guiLabelSetColor(GUIEditor_Label[12], r, g, b)
		elseif source == GUIEditor_Label[13] then
			guiLabelSetColor(GUIEditor_Label[13], r, g, b)
		end
	end)

	addEventHandler("onClientGUIClick", GUIEditor_Image[1], function()
		if source == GUIEditor_Label[2] then
			if errorCode == "kuruldu ancak oturum açılmadı" then
				playSoundBtn()
				passcode = passcode .. "1"
				passcode = string.sub(passcode, string.len(passcode) - 3, string.len(passcode))
				guiSetText(GUIEditor_Label[1], "Sifreyi girin:\n" .. passcode)
			elseif errorCode == "yeni şifre" then
				playSoundBtn()
				passcode = passcode .. "1"
				passcode = string.sub(passcode, string.len(passcode) - 3, string.len(passcode))
				guiSetText(GUIEditor_Label[1], "Yeni sifreyi girin:\n" .. passcode)
			end
		elseif source == GUIEditor_Label[3] then
			if errorCode == "kuruldu ancak oturum açılmadı" then
				playSoundBtn()
				passcode = passcode .. "2"
				passcode = string.sub(passcode, string.len(passcode) - 3, string.len(passcode))
				guiSetText(GUIEditor_Label[1], "Sifreyi girin:\n" .. passcode)
			elseif errorCode == "yeni şifre" then
				playSoundBtn()
				passcode = passcode .. "2"
				passcode = string.sub(passcode, string.len(passcode) - 3, string.len(passcode))
				guiSetText(GUIEditor_Label[1], "Yeni sifreyi girin:\n" .. passcode)
			end
		elseif source == GUIEditor_Label[4] then
			if errorCode == "kuruldu ancak oturum açılmadı" then
				playSoundBtn()
				passcode = passcode .. "3"
				passcode = string.sub(passcode, string.len(passcode) - 3, string.len(passcode))
				guiSetText(GUIEditor_Label[1], "Sifreyi girin:\n" .. passcode)
			elseif errorCode == "yeni şifre" then
				playSoundBtn()
				passcode = passcode .. "3"
				passcode = string.sub(passcode, string.len(passcode) - 3, string.len(passcode))
				guiSetText(GUIEditor_Label[1], "Yeni sifreyi girin:\n" .. passcode)
			end
		elseif source == GUIEditor_Label[5] then
			if errorCode == "kuruldu ancak oturum açılmadı" then
				playSoundBtn()
				passcode = passcode .. "4"
				passcode = string.sub(passcode, string.len(passcode) - 3, string.len(passcode))
				guiSetText(GUIEditor_Label[1], "Sifreyi girin:\n" .. passcode)
			elseif errorCode == "yeni şifre" then
				playSoundBtn()
				passcode = passcode .. "4"
				passcode = string.sub(passcode, string.len(passcode) - 3, string.len(passcode))
				guiSetText(GUIEditor_Label[1], "Yeni sifreyi girin:\n" .. passcode)
			end
		elseif source == GUIEditor_Label[6] then
			if errorCode == "kuruldu ancak oturum açılmadı" then
				playSoundBtn()
				passcode = passcode .. "5"
				passcode = string.sub(passcode, string.len(passcode) - 3, string.len(passcode))
				guiSetText(GUIEditor_Label[1], "Sifreyi girin:\n" .. passcode)
			elseif errorCode == "yeni şifre" then
				playSoundBtn()
				passcode = passcode .. "5"
				passcode = string.sub(passcode, string.len(passcode) - 3, string.len(passcode))
				guiSetText(GUIEditor_Label[1], "Yeni sifreyi girin:\n" .. passcode)
			end
		elseif source == GUIEditor_Label[7] then
			if errorCode == "kuruldu ancak oturum açılmadı" then
				playSoundBtn()
				passcode = passcode .. "6"
				passcode = string.sub(passcode, string.len(passcode) - 3, string.len(passcode))
				guiSetText(GUIEditor_Label[1], "Sifreyi girin:\n" .. passcode)
			elseif errorCode == "yeni şifre" then
				playSoundBtn()
				passcode = passcode .. "6"
				passcode = string.sub(passcode, string.len(passcode) - 3, string.len(passcode))
				guiSetText(GUIEditor_Label[1], "Yeni sifreyi girin:\n" .. passcode)
			end
		elseif source == GUIEditor_Label[8] then
			if errorCode == "kuruldu ancak oturum açılmadı" then
				playSoundBtn()
				passcode = passcode .. "7"
				passcode = string.sub(passcode, string.len(passcode) - 3, string.len(passcode))
				guiSetText(GUIEditor_Label[1], "Sifreyi girin:\n" .. passcode)
			elseif errorCode == "yeni şifre" then
				playSoundBtn()
				passcode = passcode .. "7"
				passcode = string.sub(passcode, string.len(passcode) - 3, string.len(passcode))
				guiSetText(GUIEditor_Label[1], "Yeni sifreyi girin:\n" .. passcode)
			end
		elseif source == GUIEditor_Label[9] then
			if errorCode == "kuruldu ancak oturum açılmadı" then
				playSoundBtn()
				passcode = passcode .. "8"
				passcode = string.sub(passcode, string.len(passcode) - 3, string.len(passcode))
				guiSetText(GUIEditor_Label[1], "Sifreyi girin:\n" .. passcode)
			elseif errorCode == "yeni şifre" then
				playSoundBtn()
				passcode = passcode .. "8"
				passcode = string.sub(passcode, string.len(passcode) - 3, string.len(passcode))
				guiSetText(GUIEditor_Label[1], "Yeni sifreyi girin:\n" .. passcode)
			end
		elseif source == GUIEditor_Label[10] then
			if errorCode == "kuruldu ancak oturum açılmadı" then
				playSoundBtn()
				passcode = passcode .. "9"
				passcode = string.sub(passcode, string.len(passcode) - 3, string.len(passcode))
				guiSetText(GUIEditor_Label[1], "Sifreyi girin:\n" .. passcode)
			elseif errorCode == "yeni şifre" then
				playSoundBtn()
				passcode = passcode .. "9"
				passcode = string.sub(passcode, string.len(passcode) - 3, string.len(passcode))
				guiSetText(GUIEditor_Label[1], "Yeni sifreyi girin:\n" .. passcode)
			end
		elseif source == GUIEditor_Label[11] then
			if errorCode == "kuruldu ancak oturum açılmadı" then
				playSoundBtn()
				passcode = passcode .. "0"
				passcode = string.sub(passcode, string.len(passcode) - 3, string.len(passcode))
				guiSetText(GUIEditor_Label[1], "Sifreyi girin:\n" .. passcode)
			elseif errorCode == "yeni şifre" then
				playSoundBtn()
				passcode = passcode .. "0"
				passcode = string.sub(passcode, string.len(passcode) - 3, string.len(passcode))
				guiSetText(GUIEditor_Label[1], "Yeni sifreyi girin:\n" .. passcode)
			end
		elseif source == GUIEditor_Button[3] then
			if errorCode == "logged in" then
				togKeypad(false)
				playSoundBtn("processing", thePad)
				guiSetText(GUIEditor_Label[1], "Isleniyor...")
				setTimer(function()
					local intID = getElementData(thePad, "itemValue")
					triggerServerEvent("lockUnlockHouseID", localPlayer, intID, true)
					autoLockThisInterior(intID, currentPad)
				end, 1000, 1)
			else
			end
			playSoundBtn()
		elseif source == GUIEditor_Button[1] then
			if errorCode == "logged in" and isOwner then
				if #findPadElementFromIntID(getElementData(currentInt, "dbid")) > 1 then
					if not getElementData(localPlayer, "pressedAutoLock") then
						guiSetText(
							GUIEditor_Label[1],
							"Oto-Kilit - "
								.. (getElementData(currentInt, "keypad_lock_auto") and "ACIK" or "KAPALI")
								.. "\nGecis yapmak icin tekrar basin"
						)
						setElementData(localPlayer, "pressedAutoLock", true, false)
					else
						setElementData(localPlayer, "pressedAutoLock", nil, false)
						togKeypad(false)
						playSoundBtn("processing", thePad)
						guiSetText(GUIEditor_Label[1], "Isleniyor...")
						setTimer(function()
							triggerServerEvent("togKeypadAutoLock", localPlayer, currentInt)
						end, 1000, 1)
					end
				else
					setElementData(localPlayer, "pressedAutoLock", nil, false)
					playSoundBtn("aborted", thePad)
					guiSetText(GUIEditor_Label[1], "Iptal edildi!\nOto-Kilit için iki tus takimi gerekiyor.")
					setElementData(localPlayer, "pressedAutoLock", true, false)
				end
			else
			end
			playSoundBtn()
		elseif source == GUIEditor_Button[2] then
			if errorCode == "kuruldu ancak oturum açılmadı" then
				if isPasscodeMatched(currentInt, passcode) then
					playSoundBtn("granted", thePad)
					guiSetText(GUIEditor_Label[1], "Erisim saglandi!")
					errorCode = "logged in"

					if onHandlePINChange_data then
						onHandlePINChange_data.buttons.enter = GUIEditor_Button[3]
					end
				else
					togKeypad(false)
					playSoundBtn("denied", thePad)
					passcode = "____"
					guiSetText(GUIEditor_Label[1], "Erisim engellendi!")
					setTimer(function()
						guiSetText(GUIEditor_Label[1], "Sifreyi girin:\n" .. passcode)
						togKeypad(true)
					end, 1500, 1)
				end
			elseif errorCode == "yeni şifre" then
				if string.len(passcode) == 4 and tonumber(passcode) then
					if not currentInt or not isElement(currentInt) then
						playSoundBtn("warning", thePad)
						passcode = "____"
						guiSetText(GUIEditor_Label[1], "UYARI!")
						exports.mek_infobox:addBox(
							"error",
							"Sistem düzgün kurulamadı, lütfen cihazı yeniden yükleyin."
						)
					else
						local encryptPW = encryptPW(passcode)
						togKeypad(false)
						playSoundBtn("processing", thePad)
						guiSetText(GUIEditor_Label[1], "Isleniyor...")
						setTimer(function()
							if setElementData(currentInt, "keypad_lock_pw", encryptPW, true) then
								triggerServerEvent("registerNewPasscode", localPlayer, currentInt, encryptPW)
							else
								togKeypad(true)
								playSoundBtn("warning", thePad)
								passcode = "____"
								guiSetText(GUIEditor_Label[1], "UYARI!")
								exports.mek_infobox:addBox(
									"error",
									"Sistem düzgün kurulamadı, lütfen cihazı yeniden yükleyin."
								)
							end
						end, 1000, 1)
					end
				else
					playSoundBtn("enter_password", thePad)
					passcode = "____"
					guiSetText(GUIEditor_Label[1], "Yeni sifreyi girin:\n" .. passcode)
					togKeypad(false)
					setTimer(function()
						togKeypad(true)
					end, 1500, 1)
				end
			else
				playSoundBtn()
			end
		elseif source == GUIEditor_Button[5] then
			playSoundBtn()
			if isOwner then
				togKeypad(false)
				playSoundBtn("processing", thePad)
				guiSetText(GUIEditor_Label[1], "Isleniyor...")

				setTimer(function()
					playSoundBtn("deactivating", thePad)
					guiSetText(GUIEditor_Label[1], "Devre disi birakiliyor...")
				end, 5000, 1)

				setTimer(function()
					togKeypad(true)
					triggerServerEvent("uninstallKeypad", localPlayer, thePad, currentInt)
				end, 5000 * 2, 1)
			end
		end
	end)

	addEventHandler("onClientKey", root, onHandlePINChange)
	onHandlePINChange_data = {
		buttons = {
			GUIEditor_Label[2],
			GUIEditor_Label[3],
			GUIEditor_Label[4],
			GUIEditor_Label[5],
			GUIEditor_Label[6],
			GUIEditor_Label[7],
			GUIEditor_Label[8],
			GUIEditor_Label[9],
			GUIEditor_Label[10],
			[0] = GUIEditor_Label[11],
			enter = GUIEditor_Button[2],
		},
	}
end
addEvent("openKeypadInterface", true)
addEventHandler("openKeypadInterface", localPlayer, openKeypadInterface)

function closeKeypadInterface()
	if GUIEditor_Image[1] and isElement(GUIEditor_Image[1]) then
		destroyElement(GUIEditor_Image[1])
		showCursor(false)
		if currentPad and isElement(currentPad) then
			triggerServerEvent("keypadFreeUsingSlots", localPlayer, currentPad)
		end
		currentInt = nil
		currentPad = nil
		isOwner = nil

		if onHandlePINChange_data then
			removeEventHandler("onClientKey", root, onHandlePINChange)
			onHandlePINChange_data = nil
		end
	end
end
addEvent("closeKeypadInterface", true)
addEventHandler("closeKeypadInterface", localPlayer, closeKeypadInterface)

function autoLockThisInterior(intID, thePad)
	local foundInt = nil
	local tmpPad = thePad
	for i, theInterior in pairs(getElementsByType("interior")) do
		if getElementData(theInterior, "dbid") == intID then
			foundInt = theInterior
			break
		end
	end
	if foundInt then
		setTimer(function()
			if getElementData(foundInt, "keypad_lock_auto") and not getElementData(foundInt, "status")[3] then
				triggerServerEvent("lockUnlockHouseID", localPlayer, intID, true)
			end
		end, 5000, 1)
	end
end

function togKeypad(state)
	if GUIEditor_Image[1] and isElement(GUIEditor_Image[1]) then
		guiSetEnabled(GUIEditor_Image[1], state and true or false)
	end
end

function playSoundBtn(code, thePad)
	if not code then
		playSoundFrontEnd(5)
	elseif thePad then
		local x, y, z = getElementPosition(thePad)
		local int, dim = getElementInterior(thePad), getElementDimension(thePad)
		triggerServerEvent("playSyncedSound", localPlayer, code, { x, y, z, int, dim })
	end
end

function playSyncedSound(code, thePad)
	if code == "doorLockSound" or code == "doorUnlockSound" then
		local sound = playSound3D(":mek_interior/public/sounds/" .. code .. ".mp3", thePad[1], thePad[2], thePad[3])
		setElementInterior(sound, thePad[4])
		setElementDimension(sound, thePad[5])
	else
		local sound = playSound3D("public/sounds/" .. code .. ".mp3", thePad[1], thePad[2], thePad[3])
		setSoundVolume(sound, 0.3)
		setElementInterior(sound, thePad[4])
		setElementDimension(sound, thePad[5])
	end
end
addEvent("playSyncedSound", true)
addEventHandler("playSyncedSound", root, playSyncedSound)

function keypadRecieveResponseFromServer(code, data)
	if code == "locked" then
		closeKeypadInterface()
	elseif code == "unlocked" then
		closeKeypadInterface()
	elseif code == "registerNewPasscode - ok" then
		togKeypad(false)
		playSoundBtn("all_system_actived", currentPad)
		passcode = "____"
		guiSetText(GUIEditor_Label[1], "Giris yetkilendirildi!")
		errorCode = "logged in"
		setTimer(function()
			playSoundBtn("granted", currentPad)
			guiSetText(GUIEditor_Label[1], "Erisim saglandi!")
			togKeypad(true)

			if onHandlePINChange_data then
				onHandlePINChange_data.buttons.enter = GUIEditor_Button[3]
			end
		end, 1500, 1)
	elseif code == "uninstallKeypad - failed" then
		togKeypad(true)
		playSoundBtn("aborted", currentPad)
		passcode = "____"
		guiSetText(GUIEditor_Label[1], "Iptal edildi!\nOnce kilidi acin.")
	elseif code == "uninstallKeypad - failed 2" then
		togKeypad(true)
		playSoundBtn("aborted", currentPad)
		passcode = "____"
		guiSetText(GUIEditor_Label[1], "Iptal edildi!\nEnvanter dolu.")
	elseif code == "togKeypadAutoLock - on" then
		togKeypad(true)
		guiSetText(GUIEditor_Label[1], "Oto-Kilit - ACIK\nGecis yapmak icin tekrar basin")
	elseif code == "togKeypadAutoLock - off" then
		togKeypad(true)
		guiSetText(GUIEditor_Label[1], "Oto-Kilit - KAPALI\nGecis yapmak icin tekrar basin")
	else
		togKeypad(true)
		playSoundBtn("system_overloaded", currentPad)
		guiSetText(GUIEditor_Label[1], "Sistem asiri yuklendi!")
	end
end
addEvent("keypadRecieveResponseFromServer", true)
addEventHandler("keypadRecieveResponseFromServer", localPlayer, keypadRecieveResponseFromServer)

function onHandlePINChange(button, pressOrRelease)
	if onHandlePINChange_data and pressOrRelease == true then
		if not isElement(GUIEditor_Image[1]) then
			return
		end

		for name, guiElement in pairs(onHandlePINChange_data.buttons) do
			name = tostring(name)
			if isElement(guiElement) then
				if button == name or button == ("num_" .. name) then
					triggerEvent("onClientGUIClick", guiElement, "left", "down")
					cancelEvent()
				end
			end
		end
	end
end
