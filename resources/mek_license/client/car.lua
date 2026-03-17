guiIntroLabel1 = nil
guiIntroProceedButton = nil
guiIntroWindow = nil
guiQuestionLabel = nil
guiQuestionAnswer1Radio = nil
guiQuestionAnswer2Radio = nil
guiQuestionAnswer3Radio = nil
guiQuestionWindow = nil
guiFinalPassTextLabel = nil
guiFinalFailTextLabel = nil
guiFinalRegisterButton = nil
guiFinalCloseButton = nil
guiFinishWindow = nil

local NoQuestions = 10
local NoQuestionToAnswer = 7
local correctAnswers = 0
local passPercent = 50

selection = {}

function createlicenseTestIntroWindow()
	showCursor(true)

	local screenwidth, screenheight = guiGetScreenSize()

	local Width = 450
	local Height = 200
	local X = (screenwidth - Width) / 2
	local Y = (screenheight - Height) / 2

	guiIntroWindow = guiCreateWindow(X, Y, Width, Height, "Sürüş Teorisi Testi", false)

	guiIntroLabel1 = guiCreateLabel(
		0,
		0.3,
		1,
		0.5,
		[[Şimdi sürüş teorisi sınavına geçeceksiniz.
Size temel sürüş teorisine dayalı yedi soru sorulacak.
Geçmek için en az %50 puan almanız gerekiyor.

İyi şanslar.]],
		true,
		guiIntroWindow
	)

	guiLabelSetHorizontalAlign(guiIntroLabel1, "center", true)
	guiSetFont(guiIntroLabel1, "default-bold-small")

	guiIntroProceedButton = guiCreateButton(0.4, 0.75, 0.2, 0.1, "Testi Başlat", true, guiIntroWindow)

	addEventHandler("onClientGUIClick", guiIntroProceedButton, function(button, state)
		if button == "left" and state == "up" then
			startLicenceTest()
			guiSetVisible(guiIntroWindow, false)
		end
	end, false)
end

function createLicenseQuestionWindow(number)
	local screenwidth, screenheight = guiGetScreenSize()

	local Width = 450
	local Height = 200
	local X = (screenwidth - Width) / 2
	local Y = (screenheight - Height) / 2

	guiQuestionWindow = guiCreateWindow(X, Y, Width, Height, "Soru " .. number .. " / " .. NoQuestionToAnswer, false)

	guiQuestionLabel = guiCreateLabel(0.1, 0.2, 0.9, 0.2, selection[number][1], true, guiQuestionWindow)
	guiSetFont(guiQuestionLabel, "default-bold-small")
	guiLabelSetHorizontalAlign(guiQuestionLabel, "left", true)

	if not (selection[number][2] == "nil") then
		guiQuestionAnswer1Radio =
			guiCreateRadioButton(0.1, 0.4, 0.9, 0.1, selection[number][2], true, guiQuestionWindow)
	end

	if not (selection[number][3] == "nil") then
		guiQuestionAnswer2Radio =
			guiCreateRadioButton(0.1, 0.5, 0.9, 0.1, selection[number][3], true, guiQuestionWindow)
	end

	if not (selection[number][4] == "nil") then
		guiQuestionAnswer3Radio =
			guiCreateRadioButton(0.1, 0.6, 0.9, 0.1, selection[number][4], true, guiQuestionWindow)
	end

	if number < NoQuestionToAnswer then
		guiQuestionNextButton = guiCreateButton(0.4, 0.75, 0.2, 0.1, "Sonraki Soru", true, guiQuestionWindow)

		addEventHandler("onClientGUIClick", guiQuestionNextButton, function(button, state)
			if button == "left" and state == "up" then
				local selectedAnswer = 0

				if guiRadioButtonGetSelected(guiQuestionAnswer1Radio) then
					selectedAnswer = 1
				elseif guiRadioButtonGetSelected(guiQuestionAnswer2Radio) then
					selectedAnswer = 2
				elseif guiRadioButtonGetSelected(guiQuestionAnswer3Radio) then
					selectedAnswer = 3
				else
					selectedAnswer = 0
				end

				if selectedAnswer ~= 0 then
					if selectedAnswer == selection[number][5] then
						correctAnswers = correctAnswers + 1
					end

					guiSetVisible(guiQuestionWindow, false)
					createLicenseQuestionWindow(number + 1)
				end
			end
		end, false)
	else
		guiQuestionSumbitButton = guiCreateButton(0.4, 0.75, 0.3, 0.1, "Cevapları Gönder", true, guiQuestionWindow)

		addEventHandler("onClientGUIClick", guiQuestionSumbitButton, function(button, state)
			if button == "left" and state == "up" then
				local selectedAnswer = 0

				if guiRadioButtonGetSelected(guiQuestionAnswer1Radio) then
					selectedAnswer = 1
				elseif guiRadioButtonGetSelected(guiQuestionAnswer2Radio) then
					selectedAnswer = 2
				elseif guiRadioButtonGetSelected(guiQuestionAnswer3Radio) then
					selectedAnswer = 3
				elseif guiRadioButtonGetSelected(guiQuestionAnswer4Radio) then
					selectedAnswer = 4
				else
					selectedAnswer = 0
				end

				if selectedAnswer ~= 0 then
					if selectedAnswer == selection[number][5] then
						correctAnswers = correctAnswers + 1
					end

					guiSetVisible(guiQuestionWindow, false)
					createTestFinishWindow()
				end
			end
		end, false)
	end
end

function createTestFinishWindow()
	local score = math.floor((correctAnswers / NoQuestionToAnswer) * 100)

	local screenwidth, screenheight = guiGetScreenSize()

	local Width = 450
	local Height = 200
	local X = (screenwidth - Width) / 2
	local Y = (screenheight - Height) / 2

	guiFinishWindow = guiCreateWindow(X, Y, Width, Height, "Testin Sonu", false)

	if score >= passPercent then
		guiFinalPassLabel =
			guiCreateLabel(0, 0.3, 1, 0.1, "Tebrikler! Sınavın bu bölümünü geçtiniz.", true, guiFinishWindow)
		guiSetFont(guiFinalPassLabel, "default-bold-small")
		guiLabelSetHorizontalAlign(guiFinalPassLabel, "center")
		guiLabelSetColor(guiFinalPassLabel, 0, 255, 0)

		guiFinalPassTextLabel = guiCreateLabel(
			0,
			0.4,
			1,
			0.4,
			"Başarı oranınız %" .. score .. ", geçme notu ise %" .. passPercent .. ". Tebrikler!",
			true,
			guiFinishWindow
		)
		guiLabelSetHorizontalAlign(guiFinalPassTextLabel, "center", true)

		guiFinalRegisterButton = guiCreateButton(0.35, 0.8, 0.3, 0.1, "Devam", true, guiFinishWindow)

		addEventHandler("onClientGUIClick", guiFinalRegisterButton, function(button, state)
			if button == "left" and state == "up" then
				initiateDrivingTest()
				correctAnswers = 0
				toggleAllControls(true)
				destroyElement(guiIntroLabel1)
				destroyElement(guiIntroProceedButton)
				destroyElement(guiIntroWindow)
				destroyElement(guiQuestionLabel)
				destroyElement(guiQuestionAnswer1Radio)
				destroyElement(guiQuestionAnswer2Radio)
				destroyElement(guiQuestionAnswer3Radio)
				destroyElement(guiQuestionWindow)
				destroyElement(guiFinalPassTextLabel)
				destroyElement(guiFinalRegisterButton)
				destroyElement(guiFinishWindow)
				guiIntroLabel1 = nil
				guiIntroProceedButton = nil
				guiIntroWindow = nil
				guiQuestionLabel = nil
				guiQuestionAnswer1Radio = nil
				guiQuestionAnswer2Radio = nil
				guiQuestionAnswer3Radio = nil
				guiQuestionWindow = nil
				guiFinalPassTextLabel = nil
				guiFinalRegisterButton = nil
				guiFinishWindow = nil

				correctAnswers = 0
				selection = {}

				showCursor(false)
			end
		end, false)
	else
		guiFinalFailLabel = guiCreateLabel(0, 0.3, 1, 0.1, "Üzgünüz, bu sefer geçemediniz.", true, guiFinishWindow)
		guiSetFont(guiFinalFailLabel, "default-bold-small")
		guiLabelSetHorizontalAlign(guiFinalFailLabel, "center")
		guiLabelSetColor(guiFinalFailLabel, 255, 0, 0)

		guiFinalFailTextLabel = guiCreateLabel(
			0,
			0.4,
			1,
			0.4,
			"Başarı oranınız %" .. math.ceil(score) .. ", geçme notu ise %" .. passPercent .. ".",
			true,
			guiFinishWindow
		)
		guiLabelSetHorizontalAlign(guiFinalFailTextLabel, "center", true)

		guiFinalCloseButton = guiCreateButton(0.2, 0.8, 0.25, 0.1, "Kapat", true, guiFinishWindow)

		addEventHandler("onClientGUIClick", guiFinalCloseButton, function(button, state)
			if button == "left" and state == "up" then
				destroyElement(guiIntroLabel1)
				destroyElement(guiIntroProceedButton)
				destroyElement(guiIntroWindow)
				destroyElement(guiQuestionLabel)
				destroyElement(guiQuestionAnswer1Radio)
				destroyElement(guiQuestionAnswer2Radio)
				destroyElement(guiQuestionAnswer3Radio)
				destroyElement(guiQuestionWindow)
				destroyElement(guiFinalFailTextLabel)
				destroyElement(guiFinalCloseButton)
				destroyElement(guiFinishWindow)
				guiIntroLabel1 = nil
				guiIntroProceedButton = nil
				guiIntroWindow = nil
				guiQuestionLabel = nil
				guiQuestionAnswer1Radio = nil
				guiQuestionAnswer2Radio = nil
				guiQuestionAnswer3Radio = nil
				guiQuestionWindow = nil
				guiFinalFailTextLabel = nil
				guiFinalCloseButton = nil
				guiFinishWindow = nil

				selection = {}
				correctAnswers = 0

				showCursor(false)
			end
		end, false)
	end
end

function startLicenceTest()
	chooseTestQuestions()
	createLicenseQuestionWindow(1)
end

function chooseTestQuestions()
	for i = 1, 10 do
		local number = math.random(1, NoQuestions)

		if testQuestionAlreadyUsed(number) then
			repeat
				number = math.random(1, NoQuestions)
			until testQuestionAlreadyUsed(number) == false
		end

		selection[i] = questionsCar[number]
	end
end

function testQuestionAlreadyUsed(number)
	local same = 0

	for i, j in pairs(selection) do
		if j[1] == questionsCar[number][1] then
			same = 1
		end
	end

	if same == 1 then
		return true
	else
		return false
	end
end

testRoute = {
	{ 1092.20703125, -1759.1591796875, 13.023070335388 },
	{ 1124.701171875, -1743.5966796875, 13.056550979614 },
	{ 1162.4326171875, -1743.6298828125, 13.056522369385 },
	{ 1181.919921875, -1740.716796875, 13.056303024292 },
	{ 1182.11328125, -1724.6015625, 13.123280525208 },
	{ 1246.9765625, -1714.966796875, 13.040835380554 },
	{ 1284.765625, -1715.24609375, 13.040912628174 },
	{ 1294.70703125, -1735.7734375, 13.040860176086 },
	{ 1299.7919921875, -1796.8583984375, 13.040873527527 },
	{ 1299.63671875, -1839.908203125, 13.040887832642 },
	{ 1305.568359375, -1854.4638671875, 13.040900230408 },
	{ 1314.81640625, -1837.453125, 13.040904998779 },
	{ 1314.6875, -1780.0390625, 13.040893554688 },
	{ 1314.81640625, -1746.6767578125, 13.040936470032 },
	{ 1375.3037109375, -1734.568359375, 13.040926933289 },
	{ 1489.7236328125, -1734.796875, 13.040790557861 },
	{ 1603.630859375, -1735.201171875, 13.040933609009 },
	{ 1676.9462890625, -1734.8203125, 13.040908813477 },
	{ 1737.8876953125, -1734.48046875, 13.051963806152 },
	{ 1809.451171875, -1734.8310546875, 13.048633575439 },
	{ 1818.73046875, -1745.6708984375, 13.040826797485 },
	{ 1834.1904296875, -1754.5888671875, 13.04089641571 },
	{ 1897.080078125, -1754.6884765625, 13.040921211243 },
	{ 1950.6337890625, -1754.75, 13.040934562683 },
	{ 1958.93359375, -1765.388671875, 13.04093170166 },
	{ 1958.9501953125, -1796.953125, 13.040910720825 },
	{ 1959.318359375, -1864.236328125, 13.040975570679 },
	{ 1959.5322265625, -1920.8408203125, 13.040843963623 },
	{ 1975.5859375, -1934.55078125, 13.040920257568 },
	{ 2035.345703125, -1934.552734375, 12.993081092834 },
	{ 2081.056640625, -1933.259765625, 12.98653793335 },
	{ 2084.0556640625, -1908.44140625, 13.040873527527 },
	{ 2094.1103515625, -1896.759765625, 13.039360046387 },
	{ 2144.1513671875, -1896.83984375, 13.021877288818 },
	{ 2209.2353515625, -1896.3642578125, 13.143925666809 },
	{ 2215.4794921875, -1909.1923828125, 13.018997192383 },
	{ 2211.541015625, -1954.705078125, 13.013573646545 },
	{ 2226.396484375, -1974.455078125, 13.03962802887 },
	{ 2275.2587890625, -1974.48828125, 13.031688690186 },
	{ 2300.8291015625, -1974.3388671875, 13.052042961121 },
	{ 2316.04296875, -1959.8779296875, 13.037763595581 },
	{ 2314.220703125, -1894.837890625, 13.070441246033 },
	{ 2231.1923828125, -1892.0986328125, 13.040887832642 },
	{ 2221.3203125, -1880.55078125, 13.040870666504 },
	{ 2218.958984375, -1808.5107421875, 12.853454589844 },
	{ 2218.8408203125, -1749.9638671875, 13.049014091492 },
	{ 2200.9423828125, -1729.6552734375, 13.080856323242 },
	{ 2182.611328125, -1737.7724609375, 13.033122062683 },
	{ 2171.9072265625, -1749.6826171875, 13.043260574341 },
	{ 2106.447265625, -1749.7548828125, 13.059499740601 },
	{ 2079.849609375, -1749.712890625, 13.043148994446 },
	{ 2015.9228515625, -1749.6708984375, 13.040927886963 },
	{ 1965.4052734375, -1749.634765625, 13.040921211243 },
	{ 1920.6376953125, -1749.599609375, 13.040939331055 },
	{ 1867.8623046875, -1750.013671875, 13.040932655334 },
	{ 1834.431640625, -1749.693359375, 13.040906906128 },
	{ 1824.6025390625, -1739.6240234375, 13.04088306427 },
	{ 1824.03515625, -1686.99609375, 13.040928840637 },
	{ 1823.7958984375, -1626.0556640625, 13.040854454041 },
	{ 1809.00390625, -1609.9560546875, 13.009611129761 },
	{ 1740.1572265625, -1595.8740234375, 13.039266586304 },
	{ 1646.84765625, -1590.0458984375, 13.055871009827 },
	{ 1574.384765625, -1590.0244140625, 13.040942192078 },
	{ 1506.5791015625, -1590.021484375, 13.040884971619 },
	{ 1442.4072265625, -1590.015625, 13.040890693665 },
	{ 1417.1259765625, -1590.0146484375, 13.023401260376 },
	{ 1325.158203125, -1570.3046875, 13.027077674866 },
	{ 1311.8212890625, -1558.4111328125, 13.3828125 },
	{ 1350.1328125, -1402.880859375, 13.320591926575 },
	{ 1295.3310546875, -1570.1083984375, 13.3828125 },
	{ 1285.12890625, -1569.9150390625, 13.040904998779 },
	{ 1207.41015625, -1570.0712890625, 13.045068740845 },
	{ 1162.982421875, -1569.6962890625, 12.944114685059 },
	{ 1147.5087890625, -1584.5966796875, 12.997039794922 },
	{ 1147.919921875, -1699.6806640625, 13.439339637756 },
	{ 1160.7841796875, -1714.4091796875, 13.433871269226 },
	{ 1172.8017578125, -1724.697265625, 13.261546134949 },
	{ 1162.5517578125, -1738.53515625, 13.150225639343 },
	{ 1109.314453125, -1738.59375, 13.147988319397 },
	{ 1085.056640625, -1740.5791015625, 13.152918815613 },
}

testVehicle = {
	[410] = true,
}
local vehicleIdUsedToStartTest = nil

local blip = nil
local marker = nil

function initiateDrivingTest()
	triggerServerEvent("theoryComplete", localPlayer)
	local x, y, z = testRoute[1][1], testRoute[1][2], testRoute[1][3]
	blip = createBlip(x, y, z, 0, 2, 0, 255, 0, 255)
	marker = createMarker(x, y, z, "checkpoint", 4, 0, 255, 0, 150)
	addEventHandler("onClientMarkerHit", marker, startDrivingTest)

	outputChatBox(
		"[!]#FFFFFF Artık pratik sürüş sınavına girmeye hazırsınız. Bir test aracı alın ve rotaya başlayın.",
		0,
		255,
		0,
		true
	)
end

function startDrivingTest(element)
	if element == localPlayer then
		local vehicle = getPedOccupiedVehicle(localPlayer)
		if not vehicle or not testVehicle[getElementModel(vehicle)] then
			outputChatBox(
				"[!]#FFFFFF Kontrol noktalarından geçerken bir test aracı kullanıyor olmalısınız.",
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
			x1 = testRoute[2][1]
			y1 = testRoute[2][2]
			z1 = testRoute[2][3]
			setElementData(localPlayer, "drivingTest.checkmarkers", #testRoute, false)

			blip = createBlip(x1, y1, z1, 0, 2, 255, 0, 255, 255)
			marker = createMarker(x1, y1, z1, "checkpoint", 4, 255, 0, 255, 150)

			addEventHandler("onClientMarkerHit", marker, UpdateCheckpoints)

			outputChatBox(
				"[!]#FFFFFF Test aracına zarar vermeden rotayı tamamlamanız gerekiyor. İyi şanslar ve dikkatli sürün.",
				0,
				0,
				255,
				true
			)
		end
	end
end

function UpdateCheckpoints(element)
	if element == localPlayer then
		local vehicle = getPedOccupiedVehicle(localPlayer)
		if not vehicle or not testVehicle[getElementModel(vehicle)] then
			outputChatBox(
				"[!]#FFFFFF Kontrol noktalarından geçerken bir test aracı kullanıyor olmalısınız.",
				255,
				0,
				0,
				true
			)
		elseif getElementData(vehicle, "dbid") ~= vehicleIdUsedToStartTest then
			outputChatBox("[!]#FFFFFF Bu teste başladığınız bu aracı kullanmıyordunuz.", 255, 0, 0, true)
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
					"[!]#FFFFFF Testi tamamlamak için aracınızı otoparktaki alana park edin.",
					0,
					0,
					255,
					true
				)

				local newnumber = m_number + 1
				setElementData(localPlayer, "drivingTest.marker", newnumber, false)

				local x2, y2, z2 = nil
				x2 = testRoute[newnumber][1]
				y2 = testRoute[newnumber][2]
				z2 = testRoute[newnumber][3]

				marker = createMarker(x2, y2, z2, "checkpoint", 4, 255, 0, 255, 150)
				blip = createBlip(x2, y2, z2, 0, 2, 255, 0, 255, 255)

				addEventHandler("onClientMarkerHit", marker, EndTest)
			else
				local newnumber = m_number + 1
				setElementData(localPlayer, "drivingTest.marker", newnumber, false)

				local x2, y2, z2 = nil
				x2 = testRoute[newnumber][1]
				y2 = testRoute[newnumber][2]
				z2 = testRoute[newnumber][3]

				marker = createMarker(x2, y2, z2, "checkpoint", 4, 255, 0, 255, 150)
				blip = createBlip(x2, y2, z2, 0, 2, 255, 0, 255, 255)

				addEventHandler("onClientMarkerHit", marker, UpdateCheckpoints)
			end
		end
	end
end

function EndTest(element)
	if element == localPlayer then
		local vehicle = getPedOccupiedVehicle(localPlayer)
		if not vehicle or not testVehicle[getElementModel(vehicle)] then
			outputChatBox(
				"[!]#FFFFFF Kontrol noktalarından geçerken bir test aracı kullanıyor olmalısınız.",
				255,
				0,
				0,
				true
			)
		else
			local vehicleHealth = getElementHealth(vehicle)
			if getElementData(vehicle, "dbid") ~= vehicleIdUsedToStartTest then
				outputChatBox("[!]#FFFFFF Bu teste başladığınız bu aracı kullanmıyordunuz.", 255, 0, 0, true)
				outputChatBox("[!]#FFFFFF Pratik sürüş sınavında başarısız oldunuz.", 255, 0, 0, true)
			elseif vehicleHealth >= 800 then
				outputChatBox("[!]#FFFFFF Aracı incelediğimizde herhangi bir hasar göremiyoruz.", 0, 255, 0, true)
				triggerServerEvent("acceptCarLicense", localPlayer)
			else
				outputChatBox("[!]#FFFFFF Aracı incelediğimizde hasarlı olduğunu görüyoruz.", 0, 255, 0, true)
				outputChatBox("[!]#FFFFFF Pratik sürüş sınavında başarısız oldunuz.", 255, 0, 0, true)
			end

			destroyElement(blip)
			destroyElement(marker)
			blip = nil
			marker = nil
		end
	end
end
