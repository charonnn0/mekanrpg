local screenSize = Vector2(guiGetScreenSize())

local wPedRightClick, bTalkToPed, bClosePedMenu, closing, selectedElement = nil
local wGui = nil
local sent = false

addEventHandler("onClientPedDamage", resourceRoot, function()
	cancelEvent()
end)

addEvent("toll.startConvo", true)
addEventHandler("toll.startConvo", root, function(ped)
	triggerServerEvent("toll.startConvo", localPlayer, ped)
end)

function onQuestionShow(questionArray)
	selectedElement = source
	local w, h = 150, 75
	local x = (screenSize.x - w) / 2
	local y = (screenSize.y - h) / 2
	local verticalPos = 0.3

	if not wGui then
		wGui = guiCreateStaticImage(x, y, w, h, ":mek_ui/public/images/window_body.png", false)
		local label = guiCreateLabel(0, 0.08, 1, 0.25, "Diyalog", true, wGui)
		guiLabelSetHorizontalAlign(label, "center")
		for answerID, answerStr in ipairs(questionArray) do
			if answerStr then
				local option = guiCreateButton(0.05, verticalPos, 0.87, 0.25, answerStr, true, wGui)
				setElementData(option, "option", answerID, false)
				setElementData(option, "option_str", answerStr, false)
				addEventHandler("onClientGUIClick", option, answerConvo, false)
			end
			verticalPos = verticalPos + 0.3
		end
		showCursor(true)
	end
end
addEvent("toll.interact", true)
addEventHandler("toll.interact", root, onQuestionShow)

function answerConvo(mouseButton)
	if mouseButton == "left" then
		theButton = source
		local option = getElementData(theButton, "option")
		if option then
			local option_str = getElementData(theButton, "option_str")
			triggerServerEvent("toll.interact", selectedElement, option, option_str)
			cleanGUI()
		end
	end
end

function cleanGUI()
	destroyElement(wGui)
	wGui = nil
	showCursor(false)
end
