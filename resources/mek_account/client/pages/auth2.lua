local fadeStart = 0
local fadeDuration = 1000
local fadingIn = false

local selectedPage = 1

function startAccountFadeIn()
	fadeStart = getTickCount()
	fadingIn = true
end

function renderAuth()
	if not passedIntro then
		drawIntro()
		return
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

	local store = useStore("account")
	if not store.get("accountData") then
		local data, status = exports.mek_json:get("credentials", true)
		if status then
			if data and data.rememberMe then
				store.set("loginIdentifier", tostring(data.username))
				store.set("loginPassword", tostring(data.password))
				store.set("rememberMe", true)
			else
				store.set("rememberMe", false)
			end
		end
		store.set("accountData", true)
	end

	local x, y = screenSize.x / 2 - INPUT_SIZES.x / 2, screenSize.y / 2 - INPUT_SIZES.y / 2 - (INPUT_SIZES.y * 2)

	if passedIntro then
		local hoverOffset = math.sin(nowTick / 1200) * 8
		local breathingScale = 1 + (math.sin(nowTick / 1800) * 0.03)
		
		local currentLogoW = LOGO_SIZES.x * breathingScale
		local currentLogoH = LOGO_SIZES.y * breathingScale
		
		local logoX = logoPosition.x - (currentLogoW - LOGO_SIZES.x) / 2
		local logoY = (y - LOGO_SIZES.y - 70) + hoverOffset - (currentLogoH - LOGO_SIZES.y) / 2
		
		local outerGlowSize = 30 * breathingScale
		dxDrawImage(
			logoX - outerGlowSize,
			logoY - outerGlowSize,
			currentLogoW + outerGlowSize * 2,
			currentLogoH + outerGlowSize * 2,
			":mek_ui/public/images/logo.png",
			0, 0, 0,
			tocolor(147, 51, 234, 40 * alpha)
		)
		
		local glowPulse = math.abs(math.sin(nowTick / 1200)) 
		local innerGlowSize = (10 + (5 * glowPulse)) * breathingScale
		dxDrawImage(
			logoX - innerGlowSize,
			logoY - innerGlowSize,
			currentLogoW + innerGlowSize * 2,
			currentLogoH + innerGlowSize * 2,
			":mek_ui/public/images/logo.png",
			0, 0, 0,
			tocolor(168, 85, 247, (60 + (40 * glowPulse)) * alpha)
		)
		
		dxDrawImage(
			logoX,
			logoY,
			currentLogoW,
			currentLogoH,
			":mek_ui/public/images/logo.png",
			0, 0, 0,
			tocolor(255, 255, 255, alpha * 255)
		)
	end

	if selectedPage == 1 then
		dxDrawText(
			"Giriş Yap",
			0,
			y - 40,
			screenSize.x,
			0,
			rgba(theme.WHITE, alpha),
			1,
			fonts.BebasNeueBold.h0,
			"center",
			"top"
		)
		dxDrawText(
			"Hadi başlayalım, bilgilerini gir ve giriş yap",
			0,
			y - 5,
			screenSize.x,
			0,
			rgba(theme.GRAY[200], alpha),
			1,
			fonts.BebasNeueLight.h2,
			"center",
			"top"
		)

		y = y + 45

		loginIdentifierInput = drawInput({
			position = {
				x = x,
				y = y,
			},
			size = INPUT_SIZES,

			radius = 8,

			name = "account_login_identifier",

			regex = "^[a-zA-Z0-9_.@-]*$",

			placeholder = "Kullanıcı Adı / E-posta",
			value = store.get("loginIdentifier"),

			startIcon = "",

			variant = "solid",
			alpha = alpha,

			borderWidth = 1,
			borderColor = theme.GRAY[800],

			disabled = loading,
		})

		y = y + INPUT_SIZES.y + 5

		loginPasswordInput = drawInput({
			position = {
				x = x,
				y = y,
			},
			size = INPUT_SIZES,

			radius = 8,

			name = "account_login_password",

			placeholder = "Şifre",
			value = store.get("loginPassword"),

			startIcon = "",

			variant = "solid",
			alpha = alpha,

			borderWidth = 1,
			borderColor = theme.GRAY[800],

			disabled = loading,
			mask = true,
		})

		y = y + INPUT_SIZES.y + 5

		rememberMeCheckbox = drawCheckbox({
			position = {
				x = x,
				y = y,
			},
			size = 20,

			name = "account_rememberMe",

			text = "Beni Hatırla",

			variant = "soft",
			color = "gray",
			alpha = alpha,
			checked = store.get("rememberMe"),

			disabled = loading,
		})

		y = y + 25

		loginButton = drawButton({
			position = {
				x = x,
				y = y,
			},
			size = INPUT_SIZES,

			radius = 8,

			textProperties = {
				align = "center",
				color = "#FFFFFF",
				font = fonts.body.regular,
				scale = 1,
			},

			variant = "soft",
			color = "purple",
			alpha = alpha,
			disabled = loading,

			text = "Giriş Yap",

			borderWidth = 1,
			borderColor = theme.WHITE[400],
		})

		y = y + INPUT_SIZES.y + 5

		registerPageButton = drawButton({
			position = {
				x = x,
				y = y,
			},
			size = INPUT_SIZES,

			radius = 8,

			textProperties = {
				align = "center",
				color = "#FFFFFF",
				font = fonts.body.regular,
				scale = 1,
			},

			variant = "soft",
			color = "white",
			alpha = alpha,
			disabled = loading,

			text = "Kayıt Ol",

			borderWidth = 1,
			borderColor = theme.WHITE[400],
		})

		y = y + INPUT_SIZES.y + 10

		forgotPasswordButton = drawButton({
			position = {
				x = x,
				y = y,
			},
			size = {
				x = INPUT_SIZES.x,
				y = 24,
			},

			textProperties = {
				align = "center",
				color = "#FFFFFF",
				font = fonts.body.regular,
				scale = 1,
			},

			text = "Şifrenizi mi unuttunuz? Sıfırlayın!",

			variant = "plain",
			color = "gray",
			alpha = alpha,

			disabled = loading,
		})

		if loginButton.pressed then
			if loginIdentifierInput.value == "" then
				exports.mek_infobox:addBox("error", "Kullanıcı adı boş bırakılamaz.")
				return
			end

			if loginPasswordInput.value == "" then
				exports.mek_infobox:addBox("error", "Şifre boş bırakılamaz.")
				return
			end

			if
				string.match(loginIdentifierInput.value, "['\"\\%;]")
				or string.match(loginPasswordInput.value, "['\"\\%;]")
			then
				loginIdentifierInput.value = ""
				loginPasswordInput.value = ""
				exports.mek_infobox:addBox("error", "Geçersiz karakterler algılandı.")
				return
			end

			if #loginIdentifierInput.value < 3 or #loginIdentifierInput.value > 32 then
				exports.mek_infobox:addBox("error", "Kullanıcı adı 3 ile 32 karakter arasında olmalıdır.")
				return
			end

			if #loginPasswordInput.value < 6 or #loginPasswordInput.value > 32 then
				exports.mek_infobox:addBox("error", "Şifre 6 ile 32 karakter arasında olmalıdır.")
				return
			end

			if isTransferBoxActive() then
				exports.mek_infobox:addBox("error", "Sunucu dosyaları yüklenirken hesabınıza erişemezsiniz.")
				return
			end

			if isTimer(spamTimer) then
				exports.mek_infobox:addBox(
					"error",
					"Art arda birden fazla işlem yaptınız, lütfen 3 saniye bekleyin."
				)
				return
			end

			spamTimer = setTimer(function() end, 3000, 1)

			loading = true
			addEventHandler("onClientRender", root, renderQueryLoading)
			triggerServerEvent(
				"account.requestLogin",
				localPlayer,
				loginIdentifierInput.value,
				loginPasswordInput.value
			)

			if rememberMeCheckbox.checked then
				exports.mek_json:save("credentials", {
					username = loginIdentifierInput.value,
					password = loginPasswordInput.value,
					rememberMe = rememberMeCheckbox.checked,
				}, true)
			end
		end

		if registerPageButton.pressed then
			selectedPage = 2
		end
		if forgotPasswordButton.pressed then
			exports.mek_infobox:addBox("error", "Bu özellik bakım nedeniyle devre dışı.")
		end
	elseif selectedPage == 2 then
		dxDrawText(
			"Kayıt Ol",
			0,
			y - 40,
			screenSize.x,
			0,
			rgba(theme.WHITE, alpha),
			1,
			fonts.BebasNeueBold.h0,
			"center",
			"top"
		)
		dxDrawText(
			"Benzersiz rol dünyamıza katılmaya bir adım kaldı",
			0,
			y - 5,
			screenSize.x,
			0,
			rgba(theme.GRAY[200], alpha),
			1,
			fonts.BebasNeueLight.h2,
			"center",
			"top"
		)

		y = y + 45

		registerUsernameInput = drawInput({
			position = {
				x = x,
				y = y,
			},
			size = INPUT_SIZES,

			radius = 8,

			name = "account_register_username",
			regex = "^[a-zA-Z0-9_.-]*$",

			placeholder = "Kullanıcı Adı",
			value = store.get("registerUsername"),

			startIcon = "",

			variant = "solid",
			alpha = alpha,

			borderWidth = 1,
			borderColor = theme.GRAY[800],

			disabled = loading,
		})

		y = y + INPUT_SIZES.y + 5

		registerPasswordInput = drawInput({
			position = {
				x = x,
				y = y,
			},
			size = INPUT_SIZES,

			radius = 8,

			name = "account_register_password",

			placeholder = "Şifre",
			value = store.get("registerPassword"),

			startIcon = "",

			variant = "solid",
			alpha = alpha,

			borderWidth = 1,
			borderColor = theme.GRAY[800],

			disabled = loading,
			mask = true,
		})

		y = y + INPUT_SIZES.y + 5

		registerEmailInput = drawInput({
			position = {
				x = x,
				y = y,
			},
			size = INPUT_SIZES,

			radius = 8,

			name = "account_register_email",

			placeholder = "E-posta",
			value = store.get("registerEmail"),

			startIcon = "",

			variant = "solid",
			alpha = alpha,

			borderWidth = 1,
			borderColor = theme.GRAY[800],

			disabled = loading,
		})

		y = y + INPUT_SIZES.y + 10

		privacyAgreementCheckbox = drawCheckbox({
			position = {
				x = x,
				y = y,
			},
			size = 20,

			name = "account_privacyAgreement",

			text = "Gizlilik Sözleşmesini ve KVKK kapsamında\nverilerimin işlenmesini kabul ediyorum.",

			variant = "soft",
			color = "gray",
			alpha = alpha,
			checked = store.get("privacyAgreement"),

			disabled = loading,
		})

		y = y + 30

		registerButton = drawButton({
			position = {
				x = x,
				y = y,
			},
			size = INPUT_SIZES,

			radius = 8,

			textProperties = {
				align = "center",
				color = "#FFFFFF",
				font = fonts.body.regular,
				scale = 1,
			},

			variant = "soft",
			color = "purple",
			alpha = alpha,
			disabled = loading,

			text = "Kayıt Ol",

			borderWidth = 1,
			borderColor = theme.WHITE[400],
		})

		y = y + INPUT_SIZES.y + 5

		previousPageButton = drawButton({
			position = {
				x = x,
				y = y,
			},
			size = INPUT_SIZES,

			radius = 8,

			textProperties = {
				align = "center",
				color = "#FFFFFF",
				font = fonts.body.regular,
				scale = 1,
			},

			variant = "solid",
			color = "white",
			alpha = alpha,
			disabled = loading,

			text = "Geri Dön",

			borderWidth = 1,
			borderColor = theme.WHITE[400],
		})

		if registerButton.pressed then
			if registerUsernameInput.value == "" then
				exports.mek_infobox:addBox("error", "Kullanıcı adı boş bırakılamaz.")
				return
			end

			if registerPasswordInput.value == "" then
				exports.mek_infobox:addBox("error", "Şifre boş bırakılamaz.")
				return
			end

			if registerEmailInput.value == "" then
				exports.mek_infobox:addBox("error", "E-posta boş bırakılamaz.")
				return
			end

			if not privacyAgreementCheckbox.checked then
				exports.mek_infobox:addBox("error", "Gizlilik sözleşmesini kabul etmelisiniz.")
				return
			end

			if
				string.match(registerUsernameInput.value, "['\"\\%;]")
				or string.match(registerPasswordInput.value, "['\"\\%;]")
				or string.match(registerEmailInput.value, "['\"\\%;]")
			then
				registerUsernameInput.value = ""
				registerPasswordInput.value = ""
				exports.mek_infobox:addBox("error", "Geçersiz karakterler algılandı.")
				return
			end

			if #registerUsernameInput.value < 3 or #registerUsernameInput.value > 32 then
				exports.mek_infobox:addBox("error", "Kullanıcı adı 3 ile 32 karakter arasında olmalıdır.")
				return
			end

			if #registerPasswordInput.value < 6 or #registerPasswordInput.value > 32 then
				exports.mek_infobox:addBox("error", "Şifre 6 ile 32 karakter arasında olmalıdır.")
				return
			end

			if not checkMail(registerEmailInput.value) then
				exports.mek_infobox:addBox("error", "E-posta geçerli değil.")
				return
			end

			if isTimer(spamTimer) then
				exports.mek_infobox:addBox(
					"error",
					"Art arda birden fazla işlem yaptınız, lütfen 3 saniye bekleyin."
				)
				return
			end

			spamTimer = setTimer(function() end, 3000, 1)

			loading = true
			addEventHandler("onClientRender", root, renderQueryLoading)
			triggerServerEvent(
				"account.requestRegister",
				localPlayer,
				registerUsernameInput.value,
				registerPasswordInput.value,
				registerEmailInput.value
			)
		end

		if previousPageButton.pressed then
			selectedPage = 1
		end
	end
end

addEvent("account.authPage", true)
addEventHandler("account.authPage", root, function()
	loading = false
	removeEventHandler("onClientRender", root, renderLoading)

	if not countdownMusic then
		Music.play()
	end



	introStartTick = getTickCount() + 500
	addEventHandler("onClientRender", root, renderSplash)
	addEventHandler("onClientRender", root, renderAuth)
end)

addEvent("account.switchToCharactersPage", true)
addEventHandler("account.switchToCharactersPage", root, function(characters)
	function removePages()
		if isEventHandlerAdded("onClientRender", root, renderSplash) then
			removeEventHandler("onClientRender", root, renderSplash)
		end

		if isEventHandlerAdded("onClientRender", root, renderAuth) then
			removeEventHandler("onClientRender", root, renderAuth)
		end

		if onboardingRenderHandler then
			removeEventHandler("onClientRender", root, onboardingRenderHandler)
			onboardingRenderHandler = nil
		end
	end

	local playerCharacters = characters

	fadeIn(2000, function()
		removePages()
		fadeOut(2000, function()
			if #playerCharacters > 0 then
				triggerEvent("account.charactersPage", localPlayer, playerCharacters)
			else
				triggerEvent("account.characterCreationPage", localPlayer)
			end
		end)
	end)
end)
