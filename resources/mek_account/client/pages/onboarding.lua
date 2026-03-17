local CONTAINER_SIZES = {
	x = 500,
	y = 500,
}

local store = nil

onboardingRenderHandler = nil

function renderOnboarding(username, password)
	if not store then
		store = useStore("onboarding")
		store.set("promoCodeHelperText", "")

		if username and password then
			store.set("username", username)
			store.set("password", password)
		else
			store.set("username", "")
			store.set("password", "")
		end
	end

	local x, y = screenSize.x / 2 - CONTAINER_SIZES.x / 2, screenSize.y / 2 - CONTAINER_SIZES.y / 2

	dxDrawImage(x + CONTAINER_SIZES.x / 2 - 128 / 2, y, 128, 128, ":mek_ui/public/images/logo.png")

	drawTypography({
		position = {
			x = x,
			y = y + 170,
		},

		text = "Hopp! Merhaba, " .. store.get("username"),
		alignX = "left",
		alignY = "top",
		color = theme.WHITE,
		scale = "h1",
		wrap = false,

		fontWeight = "bold",
	})

	drawTypography({
		position = {
			x = x,
			y = y + 220,
		},

		text = "Sunucuya başarıyla kayıt oldunuz. Şimdiden fazlasıyla heyecanlıyız.\nEğer bir promo kodunuz varsa girerek sürpriz hediyelerden yararlanabilirsiniz.\n\nHazırsan başlayalım!",
		alignX = "left",
		alignY = "top",
		color = theme.GRAY[300],
		scale = "body",
		wrap = false,

		fontWeight = "regular",
	})

	startButton = drawButton({
		position = {
			x = x,
			y = y + 300,
		},
		size = {
			x = 120,
			y = 40,
		},

		radius = 8,

		textProperties = {
			align = "center",
			color = WHITE,
			font = fonts.body.regular,
			scale = 1,
		},

		variant = "soft",
		color = "blue",

		disabled = loading,

		text = "Hemen Başla",

		borderWidth = 1,
		borderColor = theme.BLUE[400],
	})

	drawDivider({
		position = {
			x = x,
			y = y + 360,
		},
		size = {
			x = CONTAINER_SIZES.x,
			y = 1,
		},
		text = "promo kodun varsa",
	})

	promoCodeInput = drawInput({
		position = {
			x = x + 110,
			y = y + 390,
		},
		size = {
			x = 150,
			y = 40,
		},

		radius = 8,

		name = "account_onboarding_promo_code",

		label = "",
		placeholder = "Promo kodu",
		value = "",
		helperText = {
			text = store.get("promoCodeHelperText"),
			color = theme.RED[800],
		},

		variant = "solid",
		color = "gray",

		disabled = loading,

		borderWidth = 1,
		borderColor = theme.GRAY[800],
	})

	promoCodeButton = drawButton({
		position = {
			x = x + 270,
			y = y + 390,
		},
		size = {
			x = 120,
			y = 40,
		},

		radius = 8,

		textProperties = {
			align = "center",
			color = WHITE,
			font = fonts.body.regular,
			scale = 1,
		},

		variant = "soft",
		color = "green",

		disabled = loading,

		text = "Kodu Kullan",

		borderWidth = 1,
		borderColor = theme.GREEN[400],
	})

	if startButton.pressed or (promoCodeButton and promoCodeButton.pressed) then
		local promoCodeInputValue = promoCodeInput and promoCodeInput.value:upper() or ""
		local promoData = exports.mek_promo:getPromoData(promoCodeInput.value)

		if promoCodeButton and promoCodeButton.pressed then
			if promoCodeInputValue == "" then
				store.set("promoCodeHelperText", "Lütfen bir promo kodu girin.")
				return
			end

			if not promoData then
				store.set("promoCodeHelperText", "Geçersiz bir promo kodu girdiniz.")
				return
			end
		end

		if promoCodeInputValue ~= "" and not promoData then
			store.set("promoCodeHelperText", "Lütfen geçerli bir promo kod girin veya boş bırakın.")
			return
		end

		triggerServerEvent("account.onboardingComplete", localPlayer, promoCodeInputValue)
		triggerServerEvent("account.requestLogin", localPlayer, store.get("username"), store.get("password"))
	end
end

addEvent("account.onboardingPage", true)
addEventHandler("account.onboardingPage", root, function(username, password)
	if isEventHandlerAdded("onClientRender", root, renderAuth) then
		removeEventHandler("onClientRender", root, renderAuth)
	end

	onboardingRenderHandler = function()
		renderOnboarding(username, password)
	end
	addEventHandler("onClientRender", root, onboardingRenderHandler)
end)

addEvent("account.removeOnboardingPage", true)
addEventHandler("account.removeOnboardingPage", root, function()
	if isEventHandlerAdded("onClientRender", root, renderSplash) then
		removeEventHandler("onClientRender", root, renderSplash)
	end

	if onboardingRenderHandler then
		removeEventHandler("onClientRender", root, onboardingRenderHandler)
		onboardingRenderHandler = nil
	end
end)
