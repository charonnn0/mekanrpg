function renderMyAccount()
	local window = drawWindow({
		position = {
			x = 0,
			y = 0,
		},
		size = {
			x = 550,
			y = 350,
		},

		centered = true,

		header = {
			title = "Hesabım",
			description = "Hesabınızın bilgilerini görebilir ve şifrenizi değiştirebilirsiniz.",
			close = true,
		},
	})

	if window.clickedClose and not loading then
		removeEventHandler("onClientRender", root, renderMyAccount)
		return
	end

	local tabPanel = drawTabPanel({
		position = {
			x = window.x,
			y = window.y + 10,
		},
		size = {
			x = window.width,
			y = window.height - 10,
		},
		padding = 10,

		name = "account_settings_tab",

		placement = "horizontal",
		tabs = {
			drawTab({ name = "Genel", icon = "" }),
			drawTab({ name = "Güvenlik", icon = "" }),
		},

		variant = "soft",
		color = "gray",

		activeTab = 1,
		disabled = loading,
	})

	if tabPanel.selected == 1 then
		local fields = {
			"Kullanıcı Adı: " .. localPlayer:getData("account_username"),
			"E-Posta: " .. localPlayer:getData("account_email"),
			"Kayıt Tarihi: " .. localPlayer:getData("account_register_date"),
			"Toplam Oynama Saati: " .. localPlayer:getData("total_hours_played") .. " saat",
		}

		drawTypography({
			position = {
				x = tabPanel.position.x,
				y = tabPanel.position.y,
			},

			text = table.concat(fields, "\n"),
			alignX = "left",
			alignY = "top",
			color = theme.GRAY[300],
			scale = "body",
			wrap = false,

			fontWeight = "regular",
		})
	elseif tabPanel.selected == 2 then
		drawTypography({
			position = {
				x = tabPanel.position.x,
				y = tabPanel.position.y,
			},

			text = "Şifrenizi değiştirmek için aşağıdaki formu doldurun.",
			alignX = "left",
			alignY = "top",
			color = theme.GRAY[400],
			scale = "body",
			wrap = false,

			fontWeight = "regular",
		})

		local currentPasswordInput = drawInput({
			position = {
				x = tabPanel.position.x,
				y = tabPanel.position.y + 45,
			},
			size = {
				x = tabPanel.size.x / 2 - 10,
				y = 40,
			},
			
			radius = 4,

			name = "myAccount.currentPassword",

			label = "Mevcut Şifreniz",
			placeholder = "********",

			color = "gray",
			variant = "solid",

			mask = true,
			disabled = loading,
		})

		local newPasswordInput = drawInput({
			position = {
				x = tabPanel.position.x + tabPanel.size.x / 2 - 5,
				y = tabPanel.position.y + 45,
			},
			size = {
				x = tabPanel.size.x / 2 + 5,
				y = 40,
			},
			
			radius = 4,

			name = "myAccount.newPassword",

			label = "Yeni Şifreniz",
			placeholder = "********",

			color = "gray",
			variant = "solid",

			mask = true,

			disabled = loading,
		})

		local confirmButton = drawButton({
			position = {
				x = tabPanel.position.x,
				y = tabPanel.position.y + 100,
			},
			size = {
				x = tabPanel.size.x,
				y = 40,
			},
			
			radius = 4,

			name = "myAccount.changePassword",

			variant = "soft",
			color = "blue",
			disabled = loading,

			text = "Şifremi Değiştir",
		})

		if confirmButton.pressed then
			local currentPassword = currentPasswordInput.value
			local newPassword = newPasswordInput.value

			if not currentPassword or currentPassword == "" then
				exports.mek_infobox:addBox("error", "Mevcut şifrenizi girmelisiniz.")
				return
			end

			if not newPassword or newPassword == "" then
				exports.mek_infobox:addBox("error", "Yeni şifrenizi girmelisiniz.")
				return
			end

			if #newPassword < 6 then
				exports.mek_infobox:addBox("error", "Yeni şifreniz en az 6 karakterden oluşmalıdır.")
				return
			end

			if #newPassword > 32 then
				exports.mek_infobox:addBox("error", "Yeni şifreniz en fazla 32 karakterden oluşmalıdır.")
				return
			end

			if currentPassword == newPassword then
				exports.mek_infobox:addBox("error", "Mevcut şifreniz ile yeni şifreniz aynı olamaz.")
				return
			end

			if exports.mek_network:getNetworkStatus() then
				exports.mek_infobox:addBox(
					"error",
					"Şifrenizi değiştirebilmek için internet bağlantınızın olması gerekmektedir."
				)
				return
			end

			loading = true
			triggerServerEvent("account.changePassword", localPlayer, currentPassword, newPassword)
		end
	end

	if loading then
		dxDrawRectangle(window.x, window.y, window.width, window.height, rgba(theme.GRAY[900], 0.5))
		drawSpinner({
			position = {
				x = window.x + (window.width - 128) / 2,
				y = window.y + (window.height - 128) / 2,
			},
			size = 128,

			speed = 2,

			variant = "soft",
			color = "gray",
		})
	end
end
