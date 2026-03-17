local containerSizes = {
	x = 500,
	y = 300,
}

function renderPages.faction()
	local theme = useTheme()
	local fonts = useFonts()
	local factions = localPlayer:getData("faction") or {}

	local window = drawWindow({
		position = {
			x = 0,
			y = 0,
		},
		size = {
			x = containerSizes.x,
			y = containerSizes.y,
		},

		centered = true,
		radius = 8,
		padding = 20,
		alpha = 1,
		color = theme.GRAY[900],

		header = {
			title = "Birlik Banka Hesapları",
			description = "Buradan birliğinizin banka hesaplarını görüntüleyebilirsiniz.",
			icon = "",
			close = true,
		},
	})

	if window.clickedClose then
		hidePage()
		return false
	end

	if size(factions) == 0 then
		dxDrawText(
			"Herhangi bir birliğe üye değilsiniz.",
			window.x,
			window.y,
			window.x + window.width,
			window.y + window.height,
			rgba(theme.GRAY[500], 1),
			1,
			fonts.body.light,
			"center",
			"center"
		)
		return false
	end

	local tabs = {}
	local tabsIndex = {}

	for factionID, row in pairs(factions) do
		if exports.mek_faction:hasMemberPermissionTo(localPlayer, factionID, "manage_bank") then
			table.insert(
				tabs,
				drawTab({
					name = exports.mek_faction:getFactionName(factionID),
					icon = "",
				})
			)
			tabsIndex[#tabs] = factionID
		end
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

		name = "factions_bank_tab",

		placement = "horizontal",
		tabs = tabs,

		variant = "soft",
		color = "gray",
		radius = 8,

		activeTab = 1,
		disabled = false,
	})

	local activeFaction = tabsIndex[tabPanel.selected]
	if not activeFaction then
		dxDrawText(
			"Birlik verileri bulunamadı. (Data)",
			window.x,
			window.y,
			window.x + window.width,
			window.y + window.height,
			rgba(theme.GRAY[500], 1),
			1,
			fonts.body.light,
			"center",
			"center"
		)
		return
	end

	local faction = exports.mek_faction:getFactionFromID(activeFaction)
	if not faction then
		dxDrawText(
			"Birlik verileri bulunamadı. (Element)",
			window.x,
			window.y,
			window.x + window.width,
			window.y + window.height,
			rgba(theme.GRAY[500], 1),
			1,
			fonts.body.light,
			"center",
			"center"
		)
		return
	end

	local factionMoney = faction:getData("money") or 0

	drawAlert({
		position = {
			x = tabPanel.position.x,
			y = tabPanel.position.y,
		},
		size = {
			x = tabPanel.size.x,
			y = 55,
		},

		radius = 8,
		padding = 10,

		header = "Birlik verileri",
		description = "Kasada ₺" .. exports.mek_global:formatMoney(factionMoney) .. " para var.",

		variant = "solid",
		color = "green",
	})

	local amountInput = drawInput({
		position = {
			x = tabPanel.position.x,
			y = tabPanel.position.y + 90,
		},
		size = {
			x = tabPanel.size.x,
			y = 35,
		},
		radius = 8,
		padding = 10,

		name = "amountInput",

		label = "Tutar",
		placeholder = "0",
		value = "",

		variant = "solid",
		color = "gray",

		textVariant = "body",
		textWeight = "regular",

		disabled = false,

		mask = false,
	})

	local withdrawButton = drawButton({
		position = {
			x = tabPanel.position.x,
			y = tabPanel.position.y + 135,
		},
		size = {
			x = 100,
			y = 35,
		},
		radius = 8,

		textProperties = {
			align = "center",
			color = theme.WHITE,
			font = fonts.body.regular,
			scale = 1,
		},

		variant = "soft",
		color = "blue",
		disabled = false,

		text = "Para Çek",
	})

	local depositButton = drawButton({
		position = {
			x = tabPanel.position.x + 105,
			y = tabPanel.position.y + 135,
		},
		size = {
			x = 100,
			y = 35,
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
		disabled = false,

		text = "Para Yatır",
	})

	if withdrawButton.pressed then
		local amount = tonumber(amountInput.value)
		if not amount or amount and amount < 0 then
			exports.mek_infobox:addBox("error", "Tutar 0'dan küçük olamaz.")
			return false
		end

		if exports.mek_network:getNetworkStatus() then
			exports.mek_infobox:addBox("error", "İnternet bağlantınızı kontrol edin.")
			return false
		end

		triggerServerEvent("bank.faction.action", localPlayer, activeFaction, BANK_ACTION.withdraw, amount)
	end

	if depositButton.pressed then
		local amount = tonumber(amountInput.value)
		if not amount or amount and amount < 0 then
			exports.mek_infobox:addBox("error", "Tutar 0'dan küçük olamaz.")
			return false
		end

		if exports.mek_network:getNetworkStatus() then
			exports.mek_infobox:addBox("error", "İnternet bağlantınızı kontrol edin.")
			return false
		end

		triggerServerEvent("bank.faction.action", localPlayer, activeFaction, BANK_ACTION.deposit, amount)
	end
end
