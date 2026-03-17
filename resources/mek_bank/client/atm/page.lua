local containerSize = {
	x = 450,
	y = 450,
}

local combinedMoney = ""

local function moneyActionsSection(position, size, action)
	local store = useStore("moneyActions")
	local theme = useTheme()
	local fonts = useFonts()

	local networkStatus = exports.mek_network:getNetworkStatus()

	local buttonText = action == BANK_ACTION.deposit and "Para Yatır" or "Para Çek"

	local amountInput = drawInput({
		position = {
			x = position.x + 10,
			y = position.y + 30,
		},
		size = {
			x = size.x - 20,
			y = 40,
		},
		radius = 8,
		padding = 10,

		name = "amountInput",

		label = "Tutar",
		placeholder = "0",
		value = "",
		helperText = {
			text = store.get("inputHelperText") or "",
			color = theme.RED[700],
		},

		variant = "solid",
		color = "gray",

		textVariant = "body",
		textWeight = "regular",

		disabled = false,

		mask = false,
	})

	local confirmButton = drawButton({
		position = {
			x = position.x + 10,
			y = position.y + 205,
		},
		size = {
			x = size.x - 20,
			y = 40,
		},
		radius = 8,

		textProperties = {
			align = "center",
			color = theme.WHITE,
			font = fonts.body.regular,
			scale = 1,
		},

		variant = "soft",
		color = "green",
		disabled = networkStatus,

		text = buttonText,
		icon = "",
	})

	if confirmButton.pressed then
		if networkStatus then
			store.set("inputHelperText", "İnternet bağlantınızı kontrol edin.")
			return
		end

		local amount = tonumber(amountInput.value)

		store.set("inputHelperText", "")

		if not amount or amount <= 0 then
			store.set("inputHelperText", "Lütfen geçerli bir tutar girin.")
			return
		end

		local actionLimit = useStore("bank").actionLimit or ATM_ACTION_LIMIT
		if actionLimit < amount then
			store.set(
				"inputHelperText",
				"İşlem limitini aştınız, en fazla ₺"
					.. exports.mek_global:formatMoney(actionLimit)
					.. " işlem yapabilirsiniz."
			)
			return
		end

		triggerServerEvent("bank.action", localPlayer, action, amount)
	end
end

local function moneyTransferSection(position, size)
	local store = useStore("moneyActions")

	local theme = useTheme()
	local fonts = useFonts()

	local networkStatus = exports.mek_network:getNetworkStatus()

	local sendToInput = drawInput({
		position = {
			x = position.x + 10,
			y = position.y + 30,
		},
		size = {
			x = size.x - 20,
			y = 40,
		},
		radius = 8,
		padding = 10,

		name = "toTransferInput",

		label = "Kime",
		placeholder = "Karakter Adı",
		value = "",
		helperText = {
			text = store.get("sendToInputHelperText") or "",
			color = theme.RED[700],
		},

		variant = "solid",
		color = "gray",

		textVariant = "body",
		textWeight = "regular",

		disabled = networkStatus or loading,

		mask = false,
	})

	local amountInput = drawInput({
		position = {
			x = position.x + 10,
			y = position.y + 115,
		},
		size = {
			x = size.x - 20,
			y = 40,
		},
		radius = 8,
		padding = 10,

		name = "amountInput",

		label = "Tutar",
		placeholder = "0",
		value = "",
		helperText = {
			text = "Max: " .. combinedMoney,
			color = theme.GRAY[700],
		},

		variant = "solid",
		color = "gray",

		textVariant = "body",
		textWeight = "regular",

		disabled = networkStatus or loading,

		mask = false,
	})

	local confirmButton = drawButton({
		position = {
			x = position.x + 10,
			y = position.y + 205,
		},
		size = {
			x = size.x - 20,
			y = 40,
		},
		radius = 8,

		textProperties = {
			align = "center",
			color = theme.WHITE,
			font = fonts.body.regular,
			scale = 1,
		},

		variant = "soft",
		color = "green",
		disabled = networkStatus or loading,

		text = "Gönder",
		icon = "",
	})

	if confirmButton.pressed then
		local sendToValue = sendToInput.value
		local amount = tonumber(amountInput.value)
		local bankMoney = tonumber(localPlayer:getData("bank_money"))

		if string.match(amountInput.value, "[^%d]") then
			store.set("sendToInputHelperText", "Girdiğiniz tutar geçersizdir.")
			return
		end

		if not amount or amount <= 0 or amount > bankMoney then
			store.set("sendToInputHelperText", "Girdiğiniz tutar geçersizdir.")
			return
		end

		if networkStatus then
			store.set("sendToInputHelperText", "İnternet bağlantınızı kontrol edin.")
			return
		end

		if not sendToValue or sendToValue == "" then
			store.set("sendToInputHelperText", "Lütfen geçerli bir karakter adı girin.")
			return
		end

		local actionLimit = useStore("bank").actionLimit or ATM_ACTION_LIMIT
		if actionLimit < amount then
			store.set(
				"inputHelperText",
				"İşlem limitini aştınız, en fazla ₺"
					.. exports.mek_global:formatMoney(actionLimit)
					.. " işlem yapabilirsiniz."
			)
			return
		end

		triggerServerEvent("bank.transferMoney", localPlayer, {
			targetEntity = sendToValue,
			amount = amount,
		})
		store.set("loading", true)
	end
end

function moneyHistorySection(position, size)
	local store = useStore("bank")
	local history = store.get("history")

	if history and #history > 0 then
		local historyItems = {}

		for _, value in ipairs(history) do
			local actionText = value.action == BANK_ACTION.deposit and "Para Yatırma" or "Para Çekme"
			local dateDiff = value.dateDiff

			if dateDiff == 0 then
				dateDiffText = "Bugün"
			else
				dateDiffText = dateDiff .. " gün önce"
			end

			actionText = actionText .. " (₺" .. exports.mek_global:formatMoney(value.amount) .. ")"
			actionText = actionText .. " - " .. dateDiffText

			table.insert(historyItems, { icon = "", text = actionText, key = _ })
		end

		drawList({
			position = position,
			size = size,

			padding = 20,
			rowHeight = 30,

			name = "bank_history_list",
			header = "Son 5 İşlemler",
			items = historyItems,

			variant = "soft",
			color = "gray",
		})
	else
		drawTypography({
			position = {
				x = position.x + 10,
				y = position.y + 10,
			},
			size = {
				x = size.x - 20,
				y = size.y - 20,
			},
			text = "Geçmişinizde herhangi bir işlem bulunmamaktadır.",
			scale = "body",
			weight = "regular",
			color = "#555555",
		})
	end
end

function renderPages.atm()
	local coreStore = useStore("bank")
	local loading = coreStore.get("loading")

	local position = drawWindow({
		position = {
			x = 0,
			y = 0,
		},
		size = containerSize,

		centered = true,
		radius = 12,
		padding = 20,

		header = {
			title = "Merkez Bankası",
			description = "",
			icon = "",
			close = not loading,
		},
	})

	if position.clickedClose then
		hidePage()
		return
	end

	combinedMoney = "₺" .. exports.mek_global:formatMoney(localPlayer:getData("bank_money"))

	drawAlert({
		position = {
			x = position.x,
			y = position.y,
		},
		size = {
			x = containerSize.x - 25,
			y = 57,
		},

		radius = 4,
		padding = 10,

		header = "Hoş geldin, " .. userStore.get("name") .. "!",
		description = "Güncel bakiyeniz: " .. combinedMoney,

		variant = "solid",
		color = "green",
	})

	local tabSize = {
		x = containerSize.x - 25,
		y = containerSize.y - 135,
	}

	local tabPanel = drawTabPanel({
		position = {
			x = position.x,
			y = position.y + 75,
		},
		size = tabSize,
		padding = 10,

		name = "",

		placement = "horizontal",
		tabs = {
			drawTab({ name = "Para Çek", icon = "", disabled = false }),
			drawTab({ name = "Para Yatır", icon = "", disabled = false }),
			drawTab({ name = "Havale", icon = "", disabled = false }),
			drawTab({ name = "Geçmiş", icon = "", disabled = false }),
		},

		variant = "soft",
		color = "gray",
		radius = 8,

		activeTab = 1,
		disabled = loading,
	})

	if loading then
		drawSpinner({
			position = {
				x = tabPanel.position.x + tabPanel.size.x / 2 - 64 / 2,
				y = tabPanel.position.y + tabPanel.size.y / 2 - 64 / 2,
			},
			size = 64,

			speed = 2,

			variant = "soft",
			color = "blue",
		})
	elseif tabPanel then
		if tabPanel.selected == 1 then
			moneyActionsSection(tabPanel.position, tabPanel.size, BANK_ACTION.withdraw)
		elseif tabPanel.selected == 2 then
			moneyActionsSection(tabPanel.position, tabPanel.size, BANK_ACTION.deposit)
		elseif tabPanel.selected == 3 then
			moneyTransferSection(tabPanel.position, tabPanel.size)
		elseif tabPanel.selected == 4 then
			moneyHistorySection(tabPanel.position, tabPanel.size)
		end
	end
end
