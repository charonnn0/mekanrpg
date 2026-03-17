local CONTAINER_SIZES = {
	x = 310,
	y = 555,
}

local INPUT_SIZES = {
	x = 270,
	y = 35,
}

local CHANGE_SKIN_CONTAINER = {
	x = screenSize.x * 0.070,
	y = screenSize.y,
}

local renderInputs = {
	{
		key = "name",
		label = "Karakter Adı",
		placeholder = "örn: Ceyhun Boncukcu",
	},
	{
		key = "age",
		label = "Yaş",
		placeholder = "örn: 26",
	},
	{
		key = "height",
		label = "Boy",
		placeholder = "örn: 172",
	},
	{
		key = "weight",
		label = "Kilo",
		placeholder = "örn: 73",
	},
}

local lastClick = getTickCount()
local lastCreateButtonClickTime = 0

local fadeStart = 0
local fadeDuration = 1000
local fadingIn = false

local function startFadeIn()
	fadeStart = getTickCount()
	fadingIn = true
end

local store = nil

local function updatePedModel(diff)
	local ped = store.get("ped")

	if not ped or not isElement(ped) then
		return
	end

	local currentSkinIndex = store.get("skin")
	local gender = store.get("gender")
	local race = store.get("race")

	local genderNum = tonumber(gender)
	local raceNum = tonumber(race)

	if genderNum == nil or raceNum == nil then
		return
	end

	local skinsForCategory
	local availableSkins = exports.mek_global:getAvailableSkins()

	if availableSkins[genderNum] then
		skinsForCategory = availableSkins[genderNum][raceNum] or {}
	else
		skinsForCategory = {}
	end

	if #skinsForCategory == 0 then
		return
	end

	local newSkinIndex = currentSkinIndex

	if diff then
		newSkinIndex = newSkinIndex + diff
	end

	if newSkinIndex > #skinsForCategory then
		newSkinIndex = 1
	elseif newSkinIndex < 1 then
		newSkinIndex = #skinsForCategory
	end

	local skinIDToSet = skinsForCategory[newSkinIndex]

	if skinIDToSet then
		ped:setModel(skinIDToSet)
		store.set("skin", skinIDToSet)
	end
end

function renderCharacterCreation()
	if not store then
		store = useStore("characterCreation")
		store.set("skin", 1)
		store.set("gender", 0)
		store.set("race", 1)
	end

	localPlayer:setInterior(0)
	localPlayer:setDimension(0)
	setCameraInterior(localPlayer.interior)
	setCameraMatrix(600.89440917969, -1776.279296875, 15.298573493958, 619.44946289062, -1678.060546875, 12.332509040833)

	if not store.get("ped") and not isElement(store.get("ped")) then
		local ped = createPed(0, pedPosition.x, pedPosition.y, pedPosition.z, pedPosition.rotation)
		ped:setFrozen(true)
		ped:setAnimation("SMOKING", "M_smkstnd_loop")
		ped:setInterior(localPlayer.interior)
		ped:setDimension(localPlayer.dimension)
		store.set("ped", ped)
		updatePedModel()

		if isElement(characterLight) then
			characterLight:destroy()
		end
		characterLight = createLight(0, pedPosition.x + 2, pedPosition.y, pedPosition.z, 7, 195, 195, 195, pedPosition.x, pedPosition.y, pedPosition.z, true)
		characterLight:setInterior(localPlayer.interior)
		characterLight:setDimension(localPlayer.dimension)
	end

	local nowTick = getTickCount()
	local alpha = 1

	if fadingIn then
		local elapsed = nowTick - fadeStart
		alpha = math.min(elapsed / fadeDuration, 1)
		if alpha >= 1 then
			fadingIn = false
		end
	end

	local inputs = {}

	local x = CHANGE_SKIN_CONTAINER.x + 20
	local y = screenSize.y / 2 - CONTAINER_SIZES.y / 2

	dxDrawRectangle(x, y, CONTAINER_SIZES.x, CONTAINER_SIZES.y, rgba(theme.GRAY[900], alpha))

	x, y = x + 20, y + 20

	drawTypography({
		position = {
			x = x,
			y = y,
		},

		text = "Karakter Oluştur",
		alignX = "left",
		alignY = "top",
		color = theme.GRAY[100],
		alpha = alpha,
		scale = "h5",
		wrap = false,

		fontWeight = "regular",
	})

	y = y + 25

	drawTypography({
		position = {
			x = x,
			y = y,
		},

		text = "Karakterinizi oluşturmak için\naşağıdaki bilgileri doldurun.",
		alignX = "left",
		alignY = "top",
		color = theme.GRAY[400],
		alpha = alpha,
		scale = "caption",
		wrap = false,

		fontWeight = "regular",
	})

	y = y + 60

	for _, value in ipairs(renderInputs) do
		inputs[value.key] = drawInput({
			position = {
				x = x,
				y = y,
			},
			size = INPUT_SIZES,
			
			radius = 8,

			name = "account_" .. value.key,

			label = value.label,
			placeholder = value.placeholder,
			value = "",
			helperText = {
				text = "",
				color = "gray",
			},

			variant = "solid",
			color = "gray",
			alpha = alpha,

			borderWidth = 1,
			borderColor = theme.GRAY[800],

			disabled = loading,
		})
		y = y + INPUT_SIZES.y + 40
	end

	y = y - 20

	drawTypography({
		position = {
			x = x,
			y = y,
		},

		text = "Cinsiyet",
		alignX = "left",
		alignY = "top",
		color = theme.GRAY[50],
		alpha = alpha,
		scale = "body",
		wrap = false,

		fontWeight = "regular",
	})

	y = y + 25

	genderRadioGroup = drawRadioGroup({
		position = {
			x = x,
			y = y,
		},

		name = "account_gender",
		options = {
			drawRadio({ name = "0", text = "Erkek" }),
			drawRadio({ name = "1", text = "Kadın" }),
		},
		defaultSelected = "0",
		placement = "vertical",

		variant = "soft",
		color = "gray",
		alpha = alpha,
	})

	if genderRadioGroup.current ~= store.get("gender") then
		store.set("skin", 1)
		store.set("gender", genderRadioGroup.current)
		updatePedModel()
	end

	y = y + 30

	drawTypography({
		position = {
			x = x,
			y = y,
		},

		text = "Uyruk",
		alignX = "left",
		alignY = "top",
		color = theme.GRAY[50],
		alpha = alpha,
		scale = "body",
		wrap = false,

		fontWeight = "regular",
	})

	y = y + 25

	raceRadioGroup = drawRadioGroup({
		position = {
			x = x,
			y = y,
		},

		name = "account_race",
		options = {
			drawRadio({ name = "1", text = "Beyaz" }),
			drawRadio({ name = "2", text = "Siyahi" }),
			drawRadio({ name = "3", text = "Asyalı" }),
		},
		defaultSelected = "1",
		placement = "vertical",

		variant = "soft",
		color = "gray",
		alpha = alpha,
	})

	if raceRadioGroup.current ~= store.get("race") then
		store.set("skin", 1)
		store.set("race", raceRadioGroup.current)
		updatePedModel()
	end

	y = y + 30

	local createButton = drawButton({
		position = {
			x = x,
			y = y,
		},
		size = {
			x = INPUT_SIZES.x,
			y = 35,
		},
		
		radius = 8,

		textProperties = {
			align = "center",
			color = theme.WHITE[50],
			font = fonts.body.regular,
			scale = 1,
		},

		variant = "solid",
		color = "green",
		alpha = alpha,
		disabled = loading,

		text = "Oluştur",

		borderWidth = 1,
		borderColor = theme.GREEN[400],
	})

	local leftArrowPosition = {
		x = 0,
		y = 0,
	}

	local hover = inArea(leftArrowPosition.x, leftArrowPosition.y, CHANGE_SKIN_CONTAINER.x, CHANGE_SKIN_CONTAINER.y)

	dxDrawRectangle(
		leftArrowPosition.x,
		leftArrowPosition.y,
		CHANGE_SKIN_CONTAINER.x,
		CHANGE_SKIN_CONTAINER.y,
		rgba(theme.GRAY[900], math.max(0, math.min(0.75, alpha * 0.75))),
		false
	)
	drawButton({
		position = {
			x = CHANGE_SKIN_CONTAINER.x / 2 - 64 / 2,
			y = CHANGE_SKIN_CONTAINER.y / 2 - 64 / 2,
		},
		size = {
			x = 64,
			y = 64,
		},
		
		radius = 6,

		textProperties = {
			align = "center",
			color = theme.WHITE[50],
			font = fonts.icon,
			scale = 1,
		},

		variant = "plain",
		color = "blue",
		alpha = alpha,
		disabled = loading,

		text = "",
	})

	if hover and isKeyPressed("mouse1") and lastClick + 300 <= getTickCount() then
		lastClick = getTickCount()
		updatePedModel(-1)
	end

	local rightArrowPosition = {
		x = screenSize.x - CHANGE_SKIN_CONTAINER.x,
		y = 0,
	}

	local hover = inArea(rightArrowPosition.x, rightArrowPosition.y, CHANGE_SKIN_CONTAINER.x, CHANGE_SKIN_CONTAINER.y)

	dxDrawRectangle(
		rightArrowPosition.x,
		rightArrowPosition.y,
		CHANGE_SKIN_CONTAINER.x,
		CHANGE_SKIN_CONTAINER.y,
		rgba(theme.GRAY[900], math.max(0, math.min(0.75, alpha * 0.75))),
		false
	)
	drawButton({
		position = {
			x = rightArrowPosition.x + CHANGE_SKIN_CONTAINER.x / 2 - 64 / 2,
			y = CHANGE_SKIN_CONTAINER.y / 2 - 64 / 2,
		},
		size = {
			x = 64,
			y = 64,
		},
		
		radius = 6,

		textProperties = {
			align = "center",
			color = theme.WHITE[50],
			font = fonts.icon,
			scale = 1,
		},

		variant = "plain",
		color = "blue",
		alpha = alpha,
		disabled = loading,

		text = "",
	})

	if hover and isKeyPressed("mouse1") and lastClick + 300 <= getTickCount() then
		lastClick = getTickCount()
		updatePedModel(1)
	end

	if createButton.pressed and not loading then
		local currentTime = getTickCount()
		if currentTime - lastCreateButtonClickTime >= 3000 then
			lastCreateButtonClickTime = currentTime

			local name = inputs.name.value
			local age = tonumber(inputs.age.value) or 0
			local height = tonumber(inputs.height.value) or 0
			local weight = tonumber(inputs.weight.value) or 0

			local gender = store.get("gender")
			local race = store.get("race")
			local skin = store.get("skin")

			local valid, reason = checkCharacterName(name)

			local characters = localPlayer:getData("characters") or {}
			local maxCharacters = tonumber(getElementData(localPlayer, "max_characters") or 0)
			local characterCount = (characters and #characters or 1) - 1

			if characterCount >= maxCharacters then
				exports.mek_infobox:addBox(
					"error",
					"Maksimum karakter sayısına ulaştınız. Daha fazla karakter oluşturabilmek için karakter slotu satın almanız gerekiyor."
				)
				return
			end

			if name == "" or age == "" or height == "" or weight == "" then
				exports.mek_infobox:addBox("error", "Lütfen tüm alanları doldurunuz.")
				return
			end

			if age < 16 or age > 90 then
				exports.mek_infobox:addBox("error", "Yaşınız 16 ile 90 arasında olmalıdır.")
				return
			end

			if weight < 50 and weight > 150 then
				exports.mek_infobox:addBox("error", "Kilonuz 50 ile 150 arasında olmalıdır.")
				return
			end

			if height < 150 and height > 200 then
				exports.mek_infobox:addBox("error", "Boyunuz 150 ile 200 arasında olmalıdır.")
				return
			end

			if not valid then
				exports.mek_infobox:addBox("error", reason)
				return
			end

			local packedData = {
				name = name,
				age = age,
				gender = gender,
				height = height,
				weight = weight,
				race = race,
				skin = skin,
			}

			loading = true
			addEventHandler("onClientRender", root, renderQueryLoading)
			triggerServerEvent("account.createCharacter", localPlayer, packedData)
		else
			exports.mek_infobox:addBox("error", "Art arda birden fazla işlem yaptınız, lütfen 3 saniye bekleyin.")
		end
	end
end

addEvent("account.characterCreationPage", true)
addEventHandler("account.characterCreationPage", root, function()
	startFadeIn()
	addEventHandler("onClientRender", root, renderCharacterCreation)
end)

addEvent("account.characterCreationComplete", true)
addEventHandler("account.characterCreationComplete", root, function()
	local ped = store.get("ped")
	if isElement(ped) then
		ped:destroy()
	end

	if isElement(characterLight) then
		characterLight:destroy()
	end
end)
