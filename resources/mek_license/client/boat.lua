guiIntroLabel1Bo = nil
guiIntroProceedButtonBo = nil
guiIntroWindowBo = nil
guiQuestionLabelBo = nil
guiQuestionAnswer1RadioBo = nil
guiQuestionAnswer2RadioBo = nil
guiQuestionAnswer3RadioBo = nil
guiQuestionWindowBo = nil
guiFinalPassTextLabelBo = nil
guiFinalFailTextLabelBo = nil
guiFinalRegisterButtonBo = nil
guiFinalCloseButtonBo = nil
guiFinishWindowBo = nil

local NoQuestions = 10
local NoQuestionToAnswer = 7
local correctAnswers = 0
local passPercent = 50

selection = {}

function createlicenseBoatTestIntroWindow()
	showCursor(true)
	local screenwidth, screenheight = guiGetScreenSize()
	local Width = 450
	local Height = 200
	local X = (screenwidth - Width) / 2
	local Y = (screenheight - Height) / 2

	guiIntroWindowBo = guiCreateWindow(X, Y, Width, Height, "Tekne Teorisi Testi", false)

	guiIntroLabel1Bo = guiCreateLabel(
		0,
		0.3,
		1,
		0.5,
		[[Şimdi tekne teorisi sınavına geçeceksiniz.
Size tekne teorisine dayalı yedi soru sorulacak.
Geçmek için en az %50 puan almanız gerekiyor.

İyi şanslar.]],
		true,
		guiIntroWindowBo
	)

	guiLabelSetHorizontalAlign(guiIntroLabel1Bo, "center", true)
	guiSetFont(guiIntroLabel1Bo, "default-bold-small")

	guiIntroProceedButtonBo = guiCreateButton(0.4, 0.75, 0.2, 0.1, "Testi Başlat", true, guiIntroWindowBo)

	addEventHandler("onClientGUIClick", guiIntroProceedButtonBo, function(button, state)
		if button == "left" and state == "up" then
			startBoatLicenceTest()
			guiSetVisible(guiIntroWindowBo, false)
		end
	end, false)
end

function createBoatLicenseQuestionWindow(number)
	local screenwidth, screenheight = guiGetScreenSize()

	local Width = 450
	local Height = 200
	local X = (screenwidth - Width) / 2
	local Y = (screenheight - Height) / 2

	guiQuestionWindowBo = guiCreateWindow(X, Y, Width, Height, "Soru " .. number .. " / " .. NoQuestionToAnswer, false)

	guiQuestionLabelBo = guiCreateLabel(0.1, 0.2, 0.9, 0.2, selection[number][1], true, guiQuestionWindowBo)
	guiSetFont(guiQuestionLabelBo, "default-bold-small")
	guiLabelSetHorizontalAlign(guiQuestionLabelBo, "left", true)

	if not (selection[number][2] == "nil") then
		guiQuestionAnswer1RadioBo =
			guiCreateRadioButton(0.1, 0.4, 0.9, 0.1, selection[number][2], true, guiQuestionWindowBo)
	end

	if not (selection[number][3] == "nil") then
		guiQuestionAnswer2RadioBo =
			guiCreateRadioButton(0.1, 0.5, 0.9, 0.1, selection[number][3], true, guiQuestionWindowBo)
	end

	if not (selection[number][4] == "nil") then
		guiQuestionAnswer3RadioBo =
			guiCreateRadioButton(0.1, 0.6, 0.9, 0.1, selection[number][4], true, guiQuestionWindowBo)
	end

	if number < NoQuestionToAnswer then
		guiQuestionNextButtonBo = guiCreateButton(0.4, 0.75, 0.2, 0.1, "Sonraki Soru", true, guiQuestionWindowBo)

		addEventHandler("onClientGUIClick", guiQuestionNextButtonBo, function(button, state)
			if button == "left" and state == "up" then
				local selectedAnswer = 0

				if guiRadioButtonGetSelected(guiQuestionAnswer1RadioBo) then
					selectedAnswer = 1
				elseif guiRadioButtonGetSelected(guiQuestionAnswer2RadioBo) then
					selectedAnswer = 2
				elseif guiRadioButtonGetSelected(guiQuestionAnswer3RadioBo) then
					selectedAnswer = 3
				else
					selectedAnswer = 0
				end

				if selectedAnswer ~= 0 then
					if selectedAnswer == selection[number][5] then
						correctAnswers = correctAnswers + 1
					end

					guiSetVisible(guiQuestionWindowBo, false)
					createBoatLicenseQuestionWindow(number + 1)
				end
			end
		end, false)
	else
		guiQuestionSumbitButtonBo =
			guiCreateButton(0.4, 0.75, 0.3, 0.1, "Cevapları Gönder", true, guiQuestionWindowBo)

		addEventHandler("onClientGUIClick", guiQuestionSumbitButtonBo, function(button, state)
			if button == "left" and state == "up" then
				local selectedAnswer = 0

				if guiRadioButtonGetSelected(guiQuestionAnswer1RadioBo) then
					selectedAnswer = 1
				elseif guiRadioButtonGetSelected(guiQuestionAnswer2RadioBo) then
					selectedAnswer = 2
				elseif guiRadioButtonGetSelected(guiQuestionAnswer3RadioBo) then
					selectedAnswer = 3
				elseif guiRadioButtonGetSelected(guiQuestionAnswer4RadioBo) then
					selectedAnswer = 4
				else
					selectedAnswer = 0
				end

				if selectedAnswer ~= 0 then
					if selectedAnswer == selection[number][5] then
						correctAnswers = correctAnswers + 1
					end

					guiSetVisible(guiQuestionWindowBo, false)
					createBoatTestFinishWindow()
				end
			end
		end, false)
	end
end

function createBoatTestFinishWindow()
	local score = math.floor((correctAnswers / NoQuestionToAnswer) * 100)

	local screenwidth, screenheight = guiGetScreenSize()

	local Width = 450
	local Height = 200
	local X = (screenwidth - Width) / 2
	local Y = (screenheight - Height) / 2

	guiFinishWindowBo = guiCreateWindow(X, Y, Width, Height, "Testin Sonu", false)

	if score >= passPercent then
		guiFinalPassLabelBo =
			guiCreateLabel(0, 0.3, 1, 0.1, "Tebrikler! Tekne teori sınavını geçtiniz.", true, guiFinishWindowBo)
		guiSetFont(guiFinalPassLabelBo, "default-bold-small")
		guiLabelSetHorizontalAlign(guiFinalPassLabelBo, "center")
		guiLabelSetColor(guiFinalPassLabelBo, 0, 255, 0)

		guiFinalPassTextLabelBo = guiCreateLabel(
			0,
			0.4,
			1,
			0.4,
			"Başarı oranınız %" .. score .. ", geçme notu ise %" .. passPercent .. ". Tebrikler!",
			true,
			guiFinishWindowBo
		)
		guiLabelSetHorizontalAlign(guiFinalPassTextLabelBo, "center", true)

		guiFinalRegisterButtonBo = guiCreateButton(0.35, 0.8, 0.3, 0.1, "Devam", true, guiFinishWindowBo)

		addEventHandler("onClientGUIClick", guiFinalRegisterButtonBo, function(button, state)
			if button == "left" and state == "up" then
				correctAnswers = 0
				toggleAllControls(true)
				destroyElement(guiIntroLabel1Bo)
				destroyElement(guiIntroProceedButtonBo)
				destroyElement(guiIntroWindowBo)
				destroyElement(guiQuestionLabelBo)
				destroyElement(guiQuestionAnswer1RadioBo)
				destroyElement(guiQuestionAnswer2RadioBo)
				destroyElement(guiQuestionAnswer3RadioBo)
				destroyElement(guiQuestionWindowBo)
				destroyElement(guiFinalPassTextLabelBo)
				destroyElement(guiFinalRegisterButtonBo)
				destroyElement(guiFinishWindowBo)
				guiIntroLabel1Bo = nil
				guiIntroProceedButtonBo = nil
				guiIntroWindowBo = nil
				guiQuestionLabelBo = nil
				guiQuestionAnswer1RadioBo = nil
				guiQuestionAnswer2RadioBo = nil
				guiQuestionAnswer3RadioBo = nil
				guiQuestionWindowBo = nil
				guiFinalPassTextLabelBo = nil
				guiFinalRegisterButtonBo = nil
				guiFinishWindowBo = nil

				correctAnswers = 0
				selection = {}

				showCursor(false)

				triggerServerEvent("acceptBoatLicense", localPlayer)
			end
		end, false)
	else
		guiFinalFailLabelBo =
			guiCreateLabel(0, 0.3, 1, 0.1, "Üzgünüz, bu sefer geçemediniz.", true, guiFinishWindowBo)
		guiSetFont(guiFinalFailLabelBo, "default-bold-small")
		guiLabelSetHorizontalAlign(guiFinalFailLabelBo, "center")
		guiLabelSetColor(guiFinalFailLabelBo, 255, 0, 0)

		guiFinalFailTextLabelBo = guiCreateLabel(
			0,
			0.4,
			1,
			0.4,
			"Başarı oranınız %" .. math.ceil(score) .. ", geçme notu ise %" .. passPercent .. ".",
			true,
			guiFinishWindowBo
		)
		guiLabelSetHorizontalAlign(guiFinalFailTextLabelBo, "center", true)

		guiFinalCloseButtonBo = guiCreateButton(0.2, 0.8, 0.25, 0.1, "Kapat", true, guiFinishWindowBo)

		addEventHandler("onClientGUIClick", guiFinalCloseButtonBo, function(button, state)
			if button == "left" and state == "up" then
				destroyElement(guiIntroLabel1Bo)
				destroyElement(guiIntroProceedButtonBo)
				destroyElement(guiIntroWindowBo)
				destroyElement(guiQuestionLabelBo)
				destroyElement(guiQuestionAnswer1RadioBo)
				destroyElement(guiQuestionAnswer2RadioBo)
				destroyElement(guiQuestionAnswer3RadioBo)
				destroyElement(guiQuestionWindowBo)
				destroyElement(guiFinalPassTextLabelBo)
				destroyElement(guiFinalRegisterButtonBo)
				destroyElement(guiFinishWindowBo)
				guiIntroLabel1Bo = nil
				guiIntroProceedButtonBo = nil
				guiIntroWindowBo = nil
				guiQuestionLabelBo = nil
				guiQuestionAnswer1RadioBo = nil
				guiQuestionAnswer2RadioBo = nil
				guiQuestionAnswer3RadioBo = nil
				guiQuestionWindowBo = nil
				guiFinalPassTextLabelBo = nil
				guiFinalRegisterButtonBo = nil
				guiFinishWindowBo = nil

				selection = {}
				correctAnswers = 0

				showCursor(false)
			end
		end, false)
	end
end

function startBoatLicenceTest()
	chooseBoatTestQuestions()
	createBoatLicenseQuestionWindow(1)
end

function chooseBoatTestQuestions()
	for i = 1, 10 do
		local number = math.random(1, NoQuestions)

		if testBoatQuestionAlreadyUsed(number) then
			repeat
				number = math.random(1, NoQuestions)
			until testQuestionAlreadyUsed(number) == false
		end

		selection[i] = questionsBoat[number]
	end
end

function testBoatQuestionAlreadyUsed(number)
	local same = 0

	for i, j in pairs(selection) do
		if j[1] == questionsBoat[number][1] then
			same = 1
		end
	end

	if same == 1 then
		return true
	else
		return false
	end
end
