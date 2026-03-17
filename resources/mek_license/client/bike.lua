guiIntroLabel1B = nil
guiIntroProceedButtonB = nil
guiIntroWindowB = nil
guiQuestionLabelB = nil
guiQuestionAnswer1RadioB = nil
guiQuestionAnswer2RadioB = nil
guiQuestionAnswer3RadioB = nil
guiQuestionWindowB = nil
guiFinalPassTextLabelB = nil
guiFinalFailTextLabelB = nil
guiFinalRegisterButtonB = nil
guiFinalCloseButtonB = nil
guiFinishWindowB = nil

local NoQuestions = 10
local NoQuestionToAnswer = 7
local correctAnswers = 0
local passPercent = 50

selection = {}

function createlicenseBikeTestIntroWindow()
	showCursor(true)
	local screenwidth, screenheight = guiGetScreenSize()

	local Width = 450
	local Height = 200
	local X = (screenwidth - Width) / 2
	local Y = (screenheight - Height) / 2

	guiIntroWindowB = guiCreateWindow(X, Y, Width, Height, "Bisiklet Teorisi Testi", false)

	guiIntroLabel1B = guiCreateLabel(
		0,
		0.3,
		1,
		0.5,
		[[Şimdi motosiklet teorisi sınavına geçeceksiniz.
Size temel sürüş teorisine dayalı yedi soru sorulacak.
Geçmek için en az %50 puan almanız gerekiyor.

İyi şanslar.]],
		true,
		guiIntroWindowB
	)

	guiLabelSetHorizontalAlign(guiIntroLabel1B, "center", true)
	guiSetFont(guiIntroLabel1B, "default-bold-small")

	guiIntroProceedButtonB = guiCreateButton(0.4, 0.75, 0.2, 0.1, "Testi Başlat", true, guiIntroWindowB)

	addEventHandler("onClientGUIClick", guiIntroProceedButtonB, function(button, state)
		if button == "left" and state == "up" then
			startLicenceBikeTest()
			guiSetVisible(guiIntroWindowB, false)
		end
	end, false)
end

function createBikeLicenseQuestionWindow(number)
	local screenwidth, screenheight = guiGetScreenSize()

	local Width = 450
	local Height = 200
	local X = (screenwidth - Width) / 2
	local Y = (screenheight - Height) / 2

	guiQuestionWindowB = guiCreateWindow(X, Y, Width, Height, "Soru " .. number .. " / " .. NoQuestionToAnswer, false)

	guiQuestionLabelB = guiCreateLabel(0.1, 0.2, 0.9, 0.2, selection[number][1], true, guiQuestionWindowB)
	guiSetFont(guiQuestionLabelB, "default-bold-small")
	guiLabelSetHorizontalAlign(guiQuestionLabelB, "left", true)

	if not (selection[number][2] == "nil") then
		guiQuestionAnswer1RadioB =
			guiCreateRadioButton(0.1, 0.4, 0.9, 0.1, selection[number][2], true, guiQuestionWindowB)
	end

	if not (selection[number][3] == "nil") then
		guiQuestionAnswer2RadioB =
			guiCreateRadioButton(0.1, 0.5, 0.9, 0.1, selection[number][3], true, guiQuestionWindowB)
	end

	if not (selection[number][4] == "nil") then
		guiQuestionAnswer3RadioB =
			guiCreateRadioButton(0.1, 0.6, 0.9, 0.1, selection[number][4], true, guiQuestionWindowB)
	end

	if number < NoQuestionToAnswer then
		guiQuestionNextButtonB = guiCreateButton(0.4, 0.75, 0.2, 0.1, "Sonraki Soru", true, guiQuestionWindowB)

		addEventHandler("onClientGUIClick", guiQuestionNextButtonB, function(button, state)
			if button == "left" and state == "up" then
				local selectedAnswer = 0

				if guiRadioButtonGetSelected(guiQuestionAnswer1RadioB) then
					selectedAnswer = 1
				elseif guiRadioButtonGetSelected(guiQuestionAnswer2RadioB) then
					selectedAnswer = 2
				elseif guiRadioButtonGetSelected(guiQuestionAnswer3RadioB) then
					selectedAnswer = 3
				else
					selectedAnswer = 0
				end

				if selectedAnswer ~= 0 then
					if selectedAnswer == selection[number][5] then
						correctAnswers = correctAnswers + 1
					end

					guiSetVisible(guiQuestionWindowB, false)
					createBikeLicenseQuestionWindow(number + 1)
				end
			end
		end, false)
	else
		guiQuestionSumbitButtonB = guiCreateButton(0.4, 0.75, 0.3, 0.1, "Cevapları Gönder", true, guiQuestionWindowB)

		addEventHandler("onClientGUIClick", guiQuestionSumbitButtonB, function(button, state)
			if button == "left" and state == "up" then
				local selectedAnswer = 0

				if guiRadioButtonGetSelected(guiQuestionAnswer1RadioB) then
					selectedAnswer = 1
				elseif guiRadioButtonGetSelected(guiQuestionAnswer2RadioB) then
					selectedAnswer = 2
				elseif guiRadioButtonGetSelected(guiQuestionAnswer3RadioB) then
					selectedAnswer = 3
				elseif guiRadioButtonGetSelected(guiQuestionAnswer4RadioB) then
					selectedAnswer = 4
				else
					selectedAnswer = 0
				end

				if selectedAnswer ~= 0 then
					if selectedAnswer == selection[number][5] then
						correctAnswers = correctAnswers + 1
					end

					guiSetVisible(guiQuestionWindowB, false)
					createBikeTestFinishWindow()
				end
			end
		end, false)
	end
end

function createBikeTestFinishWindow()
	local score = math.floor((correctAnswers / NoQuestionToAnswer) * 100)

	local screenwidth, screenheight = guiGetScreenSize()

	local Width = 450
	local Height = 200
	local X = (screenwidth - Width) / 2
	local Y = (screenheight - Height) / 2

	guiFinishWindowB = guiCreateWindow(X, Y, Width, Height, "Testin Sonu", false)

	if score >= passPercent then
		guiFinalPassLabelB =
			guiCreateLabel(0, 0.3, 1, 0.1, "Tebrikler! Sınavın bu bölümünü geçtiniz.", true, guiFinishWindowB)
		guiSetFont(guiFinalPassLabelB, "default-bold-small")
		guiLabelSetHorizontalAlign(guiFinalPassLabelB, "center")
		guiLabelSetColor(guiFinalPassLabelB, 0, 255, 0)

		guiFinalPassTextLabelB = guiCreateLabel(
			0,
			0.4,
			1,
			0.4,
			"Başarı oranınız %" .. score .. ", geçme notu ise %" .. passPercent .. ". Tebrikler!",
			true,
			guiFinishWindowB
		)
		guiLabelSetHorizontalAlign(guiFinalPassTextLabelB, "center", true)

		guiFinalRegisterButtonB = guiCreateButton(0.35, 0.8, 0.3, 0.1, "Devam", true, guiFinishWindowB)

		addEventHandler("onClientGUIClick", guiFinalRegisterButtonB, function(button, state)
			if button == "left" and state == "up" then
				initiateBikeTest()
				correctAnswers = 0
				toggleAllControls(true)
				destroyElement(guiIntroLabel1B)
				destroyElement(guiIntroProceedButtonB)
				destroyElement(guiIntroWindowB)
				destroyElement(guiQuestionLabelB)
				destroyElement(guiQuestionAnswer1RadioB)
				destroyElement(guiQuestionAnswer2RadioB)
				destroyElement(guiQuestionAnswer3RadioB)
				destroyElement(guiQuestionWindowB)
				destroyElement(guiFinalPassTextLabelB)
				destroyElement(guiFinalRegisterButtonB)
				destroyElement(guiFinishWindowB)
				guiIntroLabel1B = nil
				guiIntroProceedButtonB = nil
				guiIntroWindowB = nil
				guiQuestionLabelB = nil
				guiQuestionAnswer1RadioB = nil
				guiQuestionAnswer2RadioB = nil
				guiQuestionAnswer3RadioB = nil
				guiQuestionWindowB = nil
				guiFinalPassTextLabelB = nil
				guiFinalRegisterButtonB = nil
				guiFinishWindowB = nil

				correctAnswers = 0
				selection = {}

				showCursor(false)
			end
		end, false)
	else
		guiFinalFailLabelB =
			guiCreateLabel(0, 0.3, 1, 0.1, "Üzgünüz, bu sefer geçemediniz.", true, guiFinishWindowB)
		guiSetFont(guiFinalFailLabelB, "default-bold-small")
		guiLabelSetHorizontalAlign(guiFinalFailLabelB, "center")
		guiLabelSetColor(guiFinalFailLabelB, 255, 0, 0)

		guiFinalFailTextLabelB = guiCreateLabel(
			0,
			0.4,
			1,
			0.4,
			"Başarı oranınız %" .. math.ceil(score) .. ", geçme notu ise %" .. passPercent .. ".",
			true,
			guiFinishWindowB
		)
		guiLabelSetHorizontalAlign(guiFinalFailTextLabelB, "center", true)

		guiFinalCloseButtonB = guiCreateButton(0.2, 0.8, 0.25, 0.1, "Kapat", true, guiFinishWindowB)

		addEventHandler("onClientGUIClick", guiFinalCloseButtonB, function(button, state)
			if button == "left" and state == "up" then
				destroyElement(guiIntroLabel1B)
				destroyElement(guiIntroProceedButtonB)
				destroyElement(guiIntroWindowB)
				destroyElement(guiQuestionLabelB)
				destroyElement(guiQuestionAnswer1RadioB)
				destroyElement(guiQuestionAnswer2RadioB)
				destroyElement(guiQuestionAnswer3RadioB)
				destroyElement(guiQuestionWindowB)
				destroyElement(guiFinalPassTextLabelB)
				destroyElement(guiFinalRegisterButtonB)
				destroyElement(guiFinishWindowB)
				guiIntroLabel1B = nil
				guiIntroProceedButtonB = nil
				guiIntroWindowB = nil
				guiQuestionLabelB = nil
				guiQuestionAnswer1RadioB = nil
				guiQuestionAnswer2RadioB = nil
				guiQuestionAnswer3RadioB = nil
				guiQuestionWindowB = nil
				guiFinalPassTextLabelB = nil
				guiFinalRegisterButtonB = nil
				guiFinishWindowB = nil

				selection = {}
				correctAnswers = 0

				showCursor(false)
			end
		end, false)
	end
end

function startLicenceBikeTest()
	chooseBikeTestQuestions()
	createBikeLicenseQuestionWindow(1)
end

function chooseBikeTestQuestions()
	for i = 1, 10 do
		local number = math.random(1, NoQuestions)

		if testBikeQuestionAlreadyUsed(number) then
			repeat
				number = math.random(1, NoQuestions)
			until testBikeQuestionAlreadyUsed(number) == false
		end

		selection[i] = questionsBike[number]
	end
end

function testBikeQuestionAlreadyUsed(number)
	local same = 0

	for i, j in pairs(selection) do
		if j[1] == questionsBike[number][1] then
			same = 1
		end
	end

	if same == 1 then
		return true
	else
		return false
	end
end

testBikeRoute = {
	{ 1092.20703125, -1759.1591796875, 13.023070335388 },
	{ 1167.5771484375, -1743.3544921875, 13.066892623901 },
	{ 1173.171875, -1843.9365234375, 13.07141494751 },
	{ 1319.13671875, -1854.3408203125, 13.052598953247 },
	{ 1382.615234375, -1873.7451171875, 13.052177429199 },
	{ 1559.7392578125, -1875.140625, 13.050706863403 },
	{ 1571.5244140625, -1859.8037109375, 13.050792694092 },
	{ 1571.8427734375, -1740.0810546875, 13.050458908081 },
	{ 1680.7255859375, -1734.396484375, 13.055520057678 },
	{ 1691.6259765625, -1715.3349609375, 13.050860404968 },
	{ 1691.5712890625, -1599.6298828125, 13.054371833801 },
	{ 1669.734375, -1590.0703125, 13.051850318909 },
	{ 1518.28515625, -1590.2666015625, 13.052554130554 },
	{ 1426.9873046875, -1590.0029296875, 13.058673858643 },
	{ 1319.5224609375, -1569.0380859375, 13.042145729065 },
	{ 1359.40234375, -1416.8935546875, 13.050371170044 },
	{ 1331.08984375, -1395.2607421875, 13.012241363525 },
	{ 1136.51171875, -1393.3408203125, 13.176746368408 },
	{ 1012.11328125, -1393.45703125, 12.736813545227 },
	{ 837.7568359375, -1392.7607421875, 13.025742530823 },
	{ 804.1962890625, -1392.9248046875, 13.181559562683 },
	{ 800.14453125, -1370.953125, 13.049411773682 },
	{ 799.982421875, -1285.041015625, 13.049916267395 },
	{ 799.6279296875, -1161.751953125, 23.290950775146 },
	{ 797.2490234375, -1061.5009765625, 24.365398406982 },
	{ 755.2783203125, -1054.138671875, 23.414789199829 },
	{ 707.0498046875, -1114.193359375, 17.771127700806 },
	{ 657.474609375, -1190.5693359375, 17.324506759644 },
	{ 629.720703125, -1208.3291015625, 17.772462844849 },
	{ 622.671875, -1230.0146484375, 17.729223251343 },
	{ 627.8359375, -1308.2685546875, 13.577067375183 },
	{ 630.0869140625, -1425.345703125, 13.397357940674 },
	{ 630.3798828125, -1572.8544921875, 15.133798599243 },
	{ 632.1416015625, -1660.2255859375, 15.142672538757 },
	{ 654.5322265625, -1674.0439453125, 14.000010490417 },
	{ 803.4462890625, -1677.0830078125, 13.050843238831 },
	{ 812.54296875, -1662.7041015625, 13.043465614319 },
	{ 832.4482421875, -1623.37109375, 13.052579879761 },
	{ 895.9052734375, -1574.603515625, 13.050440788269 },
	{ 1028.7724609375, -1574.8671875, 13.051753044128 },
	{ 1034.87890625, -1589.0283203125, 13.051016807556 },
	{ 1035.052734375, -1699.5732421875, 13.050029754639 },
	{ 1049.9208984375, -1714.2490234375, 13.053936004639 },
	{ 1165.490234375, -1714.7138671875, 13.40420627594 },
	{ 1172.11328125, -1734.9443359375, 13.159434318542 },
	{ 1085.056640625, -1740.5791015625, 13.152918815613 },
}

testBike = {
	[468] = true,
}
local vehicleIdUsedToStartTest = nil

local blip = nil
local marker = nil

function initiateBikeTest()
	triggerServerEvent("theoryBikeComplete", localPlayer)
	local x, y, z = testBikeRoute[1][1], testBikeRoute[1][2], testBikeRoute[1][3]
	blip = createBlip(x, y, z, 0, 2, 0, 255, 0, 255)
	marker = createMarker(x, y, z, "checkpoint", 4, 0, 255, 0, 150)
	addEventHandler("onClientMarkerHit", marker, startBikeTest)

	outputChatBox(
		"[!]#FFFFFF Artık pratik sürüş sınavına girmeye hazırsınız. Bir test motosikleti alın ve rotaya başlayın.",
		0,
		255,
		0,
		true
	)
end

function startBikeTest(element)
	if element == localPlayer then
		local vehicle = getPedOccupiedVehicle(localPlayer)
		if not vehicle or not testBike[getElementModel(vehicle)] then
			outputChatBox(
				"[!]#FFFFFF Kontrol noktalarından geçerken bir test motosikleti kullanıyor olmalısınız.",
				255,
				0,
				0,
				true
			)
		else
			destroyElement(blip)
			destroyElement(marker)

			setElementData(localPlayer, "drivingTest.marker", 2, false)
			vehicleIdUsedToStartTest = getElementData(vehicle, "dbid")

			local x1, y1, z1 = nil
			x1 = testBikeRoute[2][1]
			y1 = testBikeRoute[2][2]
			z1 = testBikeRoute[2][3]
			setElementData(localPlayer, "drivingTest.checkmarkers", #testBikeRoute, false)

			blip = createBlip(x1, y1, z1, 0, 2, 255, 0, 255, 255)
			marker = createMarker(x1, y1, z1, "checkpoint", 4, 255, 0, 255, 150)

			addEventHandler("onClientMarkerHit", marker, UpdateBikeCheckpoints)

			outputChatBox(
				"[!]#FFFFFF Test motosikletine zarar vermeden rotayı tamamlamanız gerekiyor. İyi şanslar ve dikkatli sürün.",
				0,
				0,
				255,
				true
			)
		end
	end
end

function UpdateBikeCheckpoints(element)
	if element == localPlayer then
		local vehicle = getPedOccupiedVehicle(localPlayer)
		if not vehicle or not testBike[getElementModel(vehicle)] then
			outputChatBox(
				"[!]#FFFFFF Kontrol noktalarından geçerken bir test motosikleti kullanıyor olmalısınız.",
				255,
				0,
				0,
				true
			)
		elseif getElementData(vehicle, "dbid") ~= vehicleIdUsedToStartTest then
			outputChatBox("[!]#FFFFFF Bu teste başladığınız bu motosikleti kullanmıyordunuz.", 255, 0, 0, true)
			outputChatBox("[!]#FFFFFF Pratik sürüş sınavında başarısız oldunuz.", 255, 0, 0, true)

			destroyElement(blip)
			destroyElement(marker)
			blip = nil
			marker = nil
		else
			destroyElement(blip)
			destroyElement(marker)
			blip = nil
			marker = nil

			local m_number = getElementData(localPlayer, "drivingTest.marker")
			local max_number = getElementData(localPlayer, "drivingTest.checkmarkers")

			if tonumber(max_number - 1) == tonumber(m_number) then
				outputChatBox(
					"[!]#FFFFFF Testi tamamlamak için motosikletinizi otoparktaki alana park edin.",
					0,
					0,
					255,
					true
				)

				local newnumber = m_number + 1
				setElementData(localPlayer, "drivingTest.marker", newnumber, false)

				local x2, y2, z2 = nil
				x2 = testBikeRoute[newnumber][1]
				y2 = testBikeRoute[newnumber][2]
				z2 = testBikeRoute[newnumber][3]

				marker = createMarker(x2, y2, z2, "checkpoint", 4, 255, 0, 255, 150)
				blip = createBlip(x2, y2, z2, 0, 2, 255, 0, 255, 255)

				addEventHandler("onClientMarkerHit", marker, EndBikeTest)
			else
				local newnumber = m_number + 1
				setElementData(localPlayer, "drivingTest.marker", newnumber, false)

				local x2, y2, z2 = nil
				x2 = testBikeRoute[newnumber][1]
				y2 = testBikeRoute[newnumber][2]
				z2 = testBikeRoute[newnumber][3]

				marker = createMarker(x2, y2, z2, "checkpoint", 4, 255, 0, 255, 150)
				blip = createBlip(x2, y2, z2, 0, 2, 255, 0, 255, 255)

				addEventHandler("onClientMarkerHit", marker, UpdateBikeCheckpoints)
			end
		end
	end
end

function EndBikeTest(element)
	if element == localPlayer then
		local vehicle = getPedOccupiedVehicle(localPlayer)
		if not vehicle or not testBike[getElementModel(vehicle)] then
			outputChatBox(
				"[!]#FFFFFF Kontrol noktalarından geçerken bir test motosikleti kullanıyor olmalısınız.",
				255,
				0,
				0,
				true
			)
		else
			local vehicleHealth = getElementHealth(vehicle)
			if getElementData(vehicle, "dbid") ~= vehicleIdUsedToStartTest then
				outputChatBox("[!]#FFFFFF Bu teste başladığınız bu motosikleti kullanmıyordunuz.", 255, 0, 0, true)
				outputChatBox("[!]#FFFFFF Pratik sürüş sınavında başarısız oldunuz.", 255, 0, 0, true)
			elseif vehicleHealth >= 800 then
				outputChatBox("[!]#FFFFFF Motosikleti incelediğimizde herhangi bir hasar göremiyoruz.", 0, 255, 0, true)
				triggerServerEvent("acceptBikeLicense", localPlayer)
			else
				outputChatBox("[!]#FFFFFF Motosikleti incelediğimizde hasarlı olduğunu görüyoruz.", 0, 255, 0, true)
				outputChatBox("[!]#FFFFFF Pratik sürüş sınavında başarısız oldunuz.", 255, 0, 0, true)
			end

			destroyElement(blip)
			destroyElement(marker)
			blip = nil
			marker = nil
		end
	end
end
