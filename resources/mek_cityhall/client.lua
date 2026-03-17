local ped = createPed(240, 359.7129, 173.5332, 1008.3828, 270)
setElementInterior(ped, 3)
setElementDimension(ped, 7)
setElementFrozen(ped, true)
setElementData(ped, "name", "Barış Polat")
setElementData(ped, "interaction", {
	callbackEvent = "cityhall.window.show",
	args = {},
	description = ped:getData("name"):gsub("_", " "),
})

local cityHallWindow
local wEmployment, jobList, bAcceptJob, bCancel

local function closeCityHallWindow()
	if isElement(cityHallWindow) then
		destroyElement(cityHallWindow)
		cityHallWindow = nil
	end
	showCursor(false)
end

local function onJobApplicationClick()
	closeCityHallWindow()
	triggerEvent("cityhall.employment.show", localPlayer)
end

local function onIdentityCardRequestClick()
	closeCityHallWindow()
	triggerServerEvent("cityhall.requestIdentityCard", localPlayer)
end

local function onExitClick()
	closeCityHallWindow()
end

local function createCityHallButton(parent, x, y, w, h, text, callback)
	local btn = guiCreateButton(x, y, w, h, text, true, parent)
	addEventHandler("onClientGUIClick", btn, callback, false)
	return btn
end

local function openCityHallWindow()
	closeCityHallWindow()

	local width, height = 240, 180
	local scrW, scrH = guiGetScreenSize()
	local x, y = (scrW - width) / 2, (scrH - height) / 2

	cityHallWindow = guiCreateStaticImage(x, y, width, height, ":mek_ui/public/images/window_body.png", false)

	local label = guiCreateLabel(
		0,
		0.08,
		1,
		0.2,
		"Belediye Binasına Hoş Geldiniz.\nSize nasıl yardımcı olabiliriz?",
		true,
		cityHallWindow
	)
	guiLabelSetHorizontalAlign(label, "center")
	guiLabelSetVerticalAlign(label, "center")

	createCityHallButton(cityHallWindow, 0.05, 0.3, 0.9, 0.18, "İş Başvurusunda Bulunun", onJobApplicationClick)
	createCityHallButton(
		cityHallWindow,
		0.05,
		0.5,
		0.9,
		0.18,
		"Yeni Kimlik Kartı Talep Edin (₺200)",
		onIdentityCardRequestClick
	)
	createCityHallButton(cityHallWindow, 0.05, 0.7, 0.9, 0.18, "Kapat", onExitClick)

	showCursor(true)
end
addEvent("cityhall.window.show", true)
addEventHandler("cityhall.window.show", root, openCityHallWindow)

function showEmploymentWindow()
	local width, height = 300, 400
	local scrWidth, scrHeight = guiGetScreenSize()
	local x, y = scrWidth / 2 - (width / 2), scrHeight / 2 - (height / 2)

	wEmployment = guiCreateWindow(x, y, width, height, "İş İlanları", false)

	jobList = guiCreateGridList(0.05, 0.05, 0.9, 0.8, true, wEmployment)
	local column = guiGridListAddColumn(jobList, "İş", 0.9)

	local jobs = {
		"Teslimat Şoförü",
		"Taksi Şoförü",
		"Otobüs Şoförü",
	}
	for _, name in ipairs(jobs) do
		local row = guiGridListAddRow(jobList)
		guiGridListSetItemText(jobList, row, column, name, false, false)
	end

	bAcceptJob = guiCreateButton(0.05, 0.85, 0.45, 0.1, "İşi Kabul Et", true, wEmployment)
	bCancel = guiCreateButton(0.5, 0.85, 0.45, 0.1, "İptal", true, wEmployment)

	showCursor(true)

	addEventHandler("onClientGUIClick", bAcceptJob, acceptJob, false)
	addEventHandler("onClientGUIDoubleClick", jobList, acceptJob, false)
	addEventHandler("onClientGUIClick", bCancel, cancelJob, false)
end
addEvent("cityhall.employment.show", true)
addEventHandler("cityhall.employment.show", root, showEmploymentWindow)

function acceptJob(button)
	if button ~= "left" then
		return
	end

	local row, col = guiGridListGetSelectedItem(jobList)
	local job = getElementData(localPlayer, "job")

	if (row == -1) or (col == -1) then
		outputChatBox("[!]#FFFFFF Lütfen önce bir iş seçin.", 255, 0, 0, true)
	elseif job > 0 then
		outputChatBox(
			"[!]#FFFFFF Zaten çalışıyorsunuz, lütfen önce diğer işinizden ayrılın: /isayril",
			255,
			0,
			0,
			true
		)
	else
		local jobID = 0
		local jobText = guiGridListGetItemText(jobList, row, 1)

		if jobText == "Teslimat Şoförü" or jobText == "Taksi Şoförü" or jobText == "Otobüs Şoförü" then
			local carLicense = getElementData(localPlayer, "car_license")
			if carLicense ~= 1 then
				outputChatBox("[!]#FFFFFF Bu işi yapabilmek için ehliyetinizin olması gerekiyor.", 255, 0, 0, true)
				return
			end
		end

		if jobText == "Teslimat Şoförü" then
			jobID = 1
			exports["mek_job-trucker"]:displayTruckerJob()
		elseif jobText == "Taksi Şoförü" then
			jobID = 2
			exports.mek_job:displayTaxiJob()
		elseif jobText == "Otobüs Şoförü" then
			jobID = 3
			exports.mek_job:displayBusJob()
		end

		triggerServerEvent("acceptJob", localPlayer, jobID)
		destroyEmploymentWindow()
	end
end

function cancelJob(button)
	if button == "left" then
		destroyEmploymentWindow()
	end
end

function destroyEmploymentWindow()
	if isElement(jobList) then
		destroyElement(jobList)
	end
	if isElement(bAcceptJob) then
		destroyElement(bAcceptJob)
	end
	if isElement(bCancel) then
		destroyElement(bCancel)
	end
	if isElement(wEmployment) then
		destroyElement(wEmployment)
	end
	wEmployment, jobList, bAcceptJob, bCancel = nil, nil, nil, nil
	showCursor(false)
end
