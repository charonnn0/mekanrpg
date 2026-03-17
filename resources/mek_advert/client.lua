local screenSize = Vector2(guiGetScreenSize())

local ped = createPed(5, 8.4716796875, -3.6376953125, 40.4296875)
setElementRotation(ped, 0, 0, 90)
setElementInterior(ped, 24)
setElementDimension(ped, 16)
setElementFrozen(ped, true)
setElementData(ped, "name", "Beyza Demirtaş")
setElementData(ped, "interaction", {
	callbackEvent = "advert.show",
	args = {},
	description = ped:getData("name"):gsub("_", " "),
})

function advertGUI()
	guiSetInputMode("no_binds_when_editing")

	window = guiCreateWindow((screenSize.x - 480) / 2, (screenSize.y - 180) / 2, 480, 180, "Reklam Arayüzü", false)
	guiWindowSetSizable(window, false)

	label = guiCreateLabel(10, 24, 464, 26, "İçerik:", false, window)
	guiLabelSetVerticalAlign(label, "center")

	edit = guiCreateEdit(10, 50, 464, 29, "", false, window)

	submit = guiCreateButton(10, 89, 464, 34, "Gönder (₺100)", false, window)
	guiSetProperty(submit, "NormalTextColour", "FFAAAAAA")

	close = guiCreateButton(10, 133, 464, 34, "Kapat", false, window)
	guiSetProperty(close, "NormalTextColour", "FFAAAAAA")

	addEventHandler("onClientGUIClick", guiRoot, function()
		if source == close then
			destroyElement(window)
		elseif source == submit then
			if not isTimer(spamTimer) then
				if exports.mek_global:hasMoney(localPlayer, 100) then
					if not getElementData(localPlayer, "admin_jailed") then
						local editText = guiGetText(edit)
						if #editText > 0 then
							triggerServerEvent("advert.send", localPlayer, editText)
							spamTimer = setTimer(function() end, 5 * 60 * 1000, 1)
						else
							exports.mek_infobox:addBox("error", "İçerik boş olamaz.")
						end
					else
						exports.mek_infobox:addBox("error", "Hapishanedeyken reklam yayınlayamazsın.")
					end
				else
					exports.mek_infobox:addBox("error", "Reklam yayınlamak için yeterli paranız yok.")
				end
			else
				exports.mek_infobox:addBox("error", "Her 5 saniyede bir reklam gönderebilirsiniz.")
			end
			destroyElement(window)
		end
	end)
end
addEvent("advert.show", true)
addEventHandler("advert.show", root, advertGUI)

addCommandHandler("reklamver", function()
	if getElementData(localPlayer, "vip") > 0 then
		advertGUI()
	end
end, false, false)
