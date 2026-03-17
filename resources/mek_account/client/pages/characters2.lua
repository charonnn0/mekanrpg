local CONTAINER_PADDING = 20
local lastClick = getTickCount()

local fadeStart = 0
local fadeDuration = 1000
local fadingIn = false

local function startFadeIn()
	fadeStart = getTickCount()
	fadingIn = true
end


local cameraTransitionStart = 0
local cameraTransitionDuration = 3000
local cameraTransitioning = false


local cameraPosStart = {
	x = 583.00988769531,
	y = -1772.90234375,
	z = 15.298573493958,
	lookX = 601.56494140625,
	lookY = -1674.68359375,
	lookZ = 12.332509040833
}


local cameraPosEnd = {
	x = 600.89440917969,
	y = -1776.279296875,
	z = 15.298573493958,
	lookX = 619.44946289062,
	lookY = -1678.060546875,
	lookZ = 12.332509040833
}

local function startCameraTransition()
	cameraTransitionStart = getTickCount()
	cameraTransitioning = true
end

local function easeInOutQuad(t)
	if t < 0.5 then
		return 2 * t * t
	else
		return -1 + (4 - 2 * t) * t
	end
end

local function interpolateCamera()
	if not cameraTransitioning then
		return
	end
	
	local elapsed = getTickCount() - cameraTransitionStart
	local progress = math.min(elapsed / cameraTransitionDuration, 1)
	local easedProgress = easeInOutQuad(progress)
	
	local currentX = cameraPosStart.x + (cameraPosEnd.x - cameraPosStart.x) * easedProgress
	local currentY = cameraPosStart.y + (cameraPosEnd.y - cameraPosStart.y) * easedProgress
	local currentZ = cameraPosStart.z + (cameraPosEnd.z - cameraPosStart.z) * easedProgress
	local currentLookX = cameraPosStart.lookX + (cameraPosEnd.lookX - cameraPosStart.lookX) * easedProgress
	local currentLookY = cameraPosStart.lookY + (cameraPosEnd.lookY - cameraPosStart.lookY) * easedProgress
	local currentLookZ = cameraPosStart.lookZ + (cameraPosEnd.lookZ - cameraPosStart.lookZ) * easedProgress
	
	setCameraMatrix(currentX, currentY, currentZ, currentLookX, currentLookY, currentLookZ)
	
	if progress >= 1 then
		cameraTransitioning = false
		startFadeIn()
	end
end



local store = nil
if not store then
	store = useStore("characters")
	store.set("currentCharacter", 1)
end

function renderCharacters()
	local nowTick = getTickCount()
	local alpha = 1

	if fadingIn then
		local elapsed = nowTick - fadeStart
		alpha = math.min(elapsed / fadeDuration, 1)
		if alpha >= 1 then
			fadingIn = false
		end
	elseif fadeStart > 0 then
		alpha = 1
	else
		alpha = 0
	end
	
	interpolateCamera()

	local characters = getElementData(localPlayer, "characters") or {}
	local characterCount = characters and #characters or 1

	local accountUsername = getElementData(localPlayer, "account_username") or "?"

	local ped = store.get("ped")

	if alpha > 0 then
	local createCharacterButton = drawButton({
		position = {
			x = CONTAINER_PADDING,
			y = CONTAINER_PADDING,
		},
		size = {
			x = 200,
			y = 35,
		},

		radius = 8,

		variant = "soft",
		color = "blue",
		alpha = alpha,

		disabled = not characters or loading,

		text = "Karakter Oluştur",

		borderWidth = 1,
		borderColor = theme.BLUE[400],
	})

	drawTypography({
		position = {
			x = CONTAINER_PADDING,
			y = screenSize.y - CONTAINER_PADDING * 3,
		},

		text = accountUsername,
		color = theme.GRAY[100],
		alpha = alpha,

		fontWeight = "bold",
	})

	if not characters then
		drawSpinner({
			position = {
				x = screenSize.x / 2 - 128 / 2,
				y = screenSize.y / 2 - 128 / 2,
			},
			size = 128,
			color = "blue",
			alpha = alpha,
			speed = 1,
			variant = "soft",
		})
	end

	drawSlider({
		position = {
			x = screenSize.x / 2 - 500 / 2,
			y = screenSize.y - 200,
		},
		size = {
			x = 500,
			y = 200,
		},
		containerSize = {
			x = 250,
			y = 70,
		},
		count = characterCount,
		current = store.get("currentCharacter"),
		alpha = alpha,
		content = function()
			local row = characters and characters[store.get("currentCharacter")]
			if row and store.get("ped") then
				local bonePositionX, bonePositionY, bonePositionZ = getPedBonePosition(store.get("ped"), 32)
				local x, y = getScreenFromWorldPosition(bonePositionX, bonePositionY, bonePositionZ, 0, false)

				if x and y then
					local name = row.name:gsub("_", " ")

					drawList({
						position = {
							x = x + 100,
							y = y,
						},
						size = {
							x = 200,
							y = 200,
						},

						padding = 15,
						rowHeight = 30,

						name = "characters_list",
						header = name,
						items = {
							{
								text = "Yaş: " .. row.age,
								icon = "",
								key = "",
							},
							{
								text = "Cinsiyet: " .. (row.gender == 0 and "Erkek" or "Kadın"),
								icon = "",
								key = "",
							},
							{
								text = "Boy: " .. row.height .. " cm",
								icon = "",
								key = "",
							},
							{
								text = "Kilo: " .. row.weight .. " kg",
								icon = "",
								key = "",
							},
						},

						variant = "soft",
						color = "gray",
						alpha = alpha,
					})

					local joinCharacterButton = drawButton({
						position = {
							x = x + 100,
							y = y + 210,
						},
						size = {
							x = 200,
							y = 35,
						},

						radius = 8,

						textProperties = {
							align = "center",
							color = "#FFFFFF",
							font = fonts.h6.regular,
							scale = 1,
						},

						variant = "soft",
						color = "green",
						alpha = alpha,

						disabled = not characters or loading,

						text = "Karaktere Gir",

						borderWidth = 1,
						borderColor = theme.GREEN[400],
					})

					if joinCharacterButton.pressed then
						loading = true
						addEventHandler("onClientRender", root, renderQueryLoading)
						triggerServerEvent("account.joinCharacter", localPlayer, row.id)
					end
				end
			end
		end,
		switch = function(current)
			if not loading then
				store.set("currentCharacter", current)
				ped:setModel(characters[current].skin)
				ped:setData("clothing_id", characters[current].clothingID, false)
				ped:setData("model", characters[current].model, false)
			end
		end,
	})

	if characters and not loading then
		if isKeyPressed("arrow_l") and lastClick + 300 <= getTickCount() then
			lastClick = getTickCount()
			local newIndex = math.max(1, store.get("currentCharacter") - 1)
			store.set("currentCharacter", newIndex)
			ped:setModel(characters[newIndex].skin)
			ped:setData("clothing_id", characters[newIndex].clothingID, false)
			ped:setData("model", characters[newIndex].model, false)
		end

		if isKeyPressed("arrow_r") and lastClick + 300 <= getTickCount() then
			lastClick = getTickCount()
			local newIndex = math.min(characterCount, store.get("currentCharacter") + 1)
			store.set("currentCharacter", newIndex)
			ped:setModel(characters[newIndex].skin)
			ped:setData("clothing_id", characters[newIndex].clothingID, false)
			ped:setData("model", characters[newIndex].model, false)
		end

		if createCharacterButton.pressed then
			local characters = getElementData(localPlayer, "characters")
			local maxCharacters = tonumber(getElementData(localPlayer, "max_characters") or 0)
			local characterCount = characters and #characters or 1

			if characterCount >= maxCharacters then
				exports.mek_infobox:addBox(
					"error",
					"Maksimum karakter sayısına ulaştınız. Daha fazla karakter oluşturabilmek için karakter slotu satın almanız gerekiyor."
				)
				return
			end

			fadeIn(2000, function()
				local ped = store.get("ped")
				if isElement(ped) then
					ped:destroy()
				end

				if isElement(characterLight) then
					characterLight:destroy()
				end

				removeEventHandler("onClientRender", root, renderCharacters)

				fadeOut(2000, function()
					triggerEvent("account.characterCreationPage", localPlayer)
				end)
			end)
		end
	end
	end
end

addEvent("account.characterSelection", true)
addEventHandler("account.characterSelection", root, function()
    localPlayer:setDimension(1)
    localPlayer:setInterior(0)
    
    
    setCameraMatrix(
        cameraPosEnd.x,
        cameraPosEnd.y,
        cameraPosEnd.z,
        cameraPosEnd.lookX,
        cameraPosEnd.lookY,
        cameraPosEnd.lookZ
    )
    
    cameraTransitioning = false
    
    startFadeIn()
    
    addEventHandler("onClientRender", root, renderCharacters)
end)

addEvent("account.charactersPage", true)
addEventHandler("account.charactersPage", root, function(characters, skipAnimation)
	if not characters then
		characters = getElementData(localPlayer, "characters")
	end
	local characterCount = characters and #characters or 1

	lastClick = getTickCount()

	lastClick = getTickCount()

	localPlayer:setInterior(0)
	localPlayer:setDimension(1)
	setCameraInterior(localPlayer.interior)
	
	if skipAnimation then
		setCameraMatrix(
			cameraPosEnd.x,
			cameraPosEnd.y,
			cameraPosEnd.z,
			cameraPosEnd.lookX,
			cameraPosEnd.lookY,
			cameraPosEnd.lookZ
		)
		
		cameraTransitioning = false
		startFadeIn()
	else
		setCameraMatrix(
			cameraPosStart.x, 
			cameraPosStart.y, 
			cameraPosStart.z, 
			cameraPosStart.lookX, 
			cameraPosStart.lookY, 
			cameraPosStart.lookZ
		)
		
		startCameraTransition()
	end

	if not store.get("ped") and not isElement(store.get("ped")) then
		local ped = createPed(0, pedPosition.x, pedPosition.y, pedPosition.z, pedPosition.rotation)
		ped:setFrozen(true)
		ped:setModel(characters[store.get("currentCharacter")].skin)
		ped:setData("clothing_id", characters[store.get("currentCharacter")].clothingID, false)
		ped:setData("model", characters[store.get("currentCharacter")].model, false)
		ped:setAnimation("SMOKING", "M_smkstnd_loop")
		ped:setInterior(localPlayer.interior)
		ped:setDimension(localPlayer.dimension)
		store.set("ped", ped)

		if isElement(characterLight) then
			characterLight:destroy()
		end
		characterLight = createLight(
			0,
			pedPosition.x + 2,
			pedPosition.y,
			pedPosition.z,
			7,
			195,
			195,
			195,
			pedPosition.x,
			pedPosition.y,
			pedPosition.z,
			true
		)
		characterLight:setInterior(localPlayer.interior)
		characterLight:setDimension(localPlayer.dimension)
	end

	addEventHandler("onClientRender", root, renderCharacters)
end)

addEvent("account.joinCharacterComplete", true)
addEventHandler("account.joinCharacterComplete", root, function(newCharacter, data)
	fadeIn(2000, function()
		if isEventHandlerAdded("onClientRender", root, renderCharacters) then
			removeEventHandler("onClientRender", root, renderCharacters)
		end

		if isEventHandlerAdded("onClientRender", root, renderCharacterCreation) then
			removeEventHandler("onClientRender", root, renderCharacterCreation)
		end

		if isEventHandlerAdded("onClientRender", root, renderQueryLoading) then
			loading = false
			removeEventHandler("onClientRender", root, renderQueryLoading)
		end

		local ped = store.get("ped")
		if isElement(ped) then
			ped:destroy()
		end

		if isElement(characterLight) then
			characterLight:destroy()
		end

		fadeOut(2000, function()
			local playerName = getPlayerName(localPlayer):gsub("_", " ")

			Music.stop()
			executeCommandHandler("clearchat")
			showChat(true)
			showCursor(false)
			setCameraInterior(localPlayer.interior)
			setCameraTarget(localPlayer, localPlayer)

			outputChatBox(
				"[!]#FFFFFF Merhaba, " .. playerName .. "! Karakterinle başarıyla giriş yaptın.",
				0,
				255,
				0,
				true
			)
			outputChatBox(
				"[!]#FFFFFF İlk girişte kısa süreli donmalar yaşanabilir. Bu, harita ve mod dosyalarının yüklenmesinden kaynaklanır.",
				0,
				0,
				255,
				true
			)

			outputChatBox("[!]#FFFFFF Keyifli vakit geçirmenizi ve iyi roller yapmanızı dileriz!", 0, 255, 0, true)

			triggerEvent("playSuccess", localPlayer)
			triggerServerEvent("account.joinCharacterComplete", localPlayer, newCharacter, data)
		end)
	end)
end)
