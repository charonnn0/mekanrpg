local screenSource = dxCreateScreenSource(screenSize.x, screenSize.y)
local blackWhiteShader = dxCreateShader("public/shaders/blackwhite.fx")

Death = {}
Death.radioOptions = eachi(DeathReasons, function(reason, label)
	return { name = reason, text = label }
end)

function Death.render()
	if not localPlayer:getData("logged") then
		Death.hide()
		return
	end

	local window = drawWindow({
		position = {
			x = 0,
			y = 0,
		},
		size = {
			x = 650,
			y = 200,
		},
		centered = true,

		header = {
			title = "Karakter Ölümü",
			description = false,
			icon = "",
			close = true,
		},
	})

	if window.clickedClose then
		Death.hide()
		return
	end

	drawTypography({
		position = {
			x = window.x,
			y = window.y,
		},

		text = ("%s karakterinizi geri dönüşü olmayacak şekilde öldüreceksiniz.\nEmin misiniz?\n\nSebep:"):format(
			localPlayer.name:gsub("_", " ")
		),
		scale = "body",
		fontScale = 1,
		color = theme.GRAY[300],

		fontWeight = "regular",
	})

	local radioGroup = drawRadioGroup({
		position = {
			x = window.x,
			y = window.y + 75,
		},

		name = "ck_reason",
		options = Death.radioOptions,
		defaultSelected = 1,

		placement = "vertical",
		variant = "soft",
		color = "gray",
	})

	local submitButton = drawButton({
		position = {
			x = window.x,
			y = window.y + window.height - 35,
		},
		size = {
			x = window.width,
			y = 35,
		},

		textProperties = {
			align = "center",
			color = theme.GRAY[100],
			font = fonts.body.regular,
			scale = 1,
		},

		variant = "soft",
		color = "red",

		text = "Öl",
	})

	if submitButton.pressed then
		local reason = DeathReasons[radioGroup.current]
		if not reason then
			exports.mek_infobox:addBox("error", "Lütfen bir sebep seçin.")
			return
		end

		triggerServerEvent("death.selfCharacterKill", localPlayer, reason)
		Death.hide()
	end
end

function Death.show()
	if not isEventHandlerAdded("onClientRender", root, Death.render) then
		addEventHandler("onClientRender", root, Death.render)
		showCursor(true)
	end
end

function Death.hide()
	if isEventHandlerAdded("onClientRender", root, Death.render) then
		removeEventHandler("onClientRender", root, Death.render)
		showCursor(false)
	end
end

addCommandHandler("ck", function()
	if not localPlayer:getData("logged") then
		return
	end

	if localPlayer:getData("cked") then
		exports.mek_infobox:addBox("error", "Ölüyken bu komutu kullanamazsınız.")
		return
	end

	Death.show()
end)

addEvent("death.renderBlackWhiteShader", true)
addEventHandler("death.renderBlackWhiteShader", root, function()
	if blackWhiteShader then
		addEventHandler("onClientPreRender", root, renderBlackWhiteShader)
	end
end)



addEvent("death.removeBlackWhiteShader", true)
addEventHandler("death.removeBlackWhiteShader", root, function()
	if blackWhiteShader then
		if isEventHandlerAdded("onClientPreRender", root, renderBlackWhiteShader) then
			removeEventHandler("onClientPreRender", root, renderBlackWhiteShader)
		end
	end
end)

function renderBlackWhiteShader()
	if blackWhiteShader then
		dxUpdateScreenSource(screenSource)
		dxSetShaderValue(blackWhiteShader, "screenSource", screenSource)
		dxDrawImage(0, 0, screenSize.x, screenSize.y, blackWhiteShader)
	end
end
