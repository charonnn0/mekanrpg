local activeWorkplacesStoreName = "activeWorkplaces"

-- Banner / logo önizlemeleri için texture cache
local workplaceListBannerTextures = {}
local workplaceListLogoTextures = {}

local function getWorkplaceListTexture(id, kind, url)
	if not url or url == "" then
		return nil
	end

	if not url:find("^https?://") then
		return nil
	end

	if kind == "banner" then
		local cached = workplaceListBannerTextures[id]
		if cached and cached.texture and isElement(cached.texture) and cached.url == url then
			return cached.texture
		end

		if cached and cached.loading then
			return cached.texture
		end

		workplaceListBannerTextures[id] = {
			texture = cached and cached.texture or nil,
			url = url,
			loading = true,
		}

		fetchRemote(url, function(data, errno)
			local current = workplaceListBannerTextures[id]
			if not current then
				return
			end
			current.loading = false

			if errno == 0 and data then
				if current.texture and isElement(current.texture) then
					destroyElement(current.texture)
				end
				current.texture = dxCreateTexture(data)
				current.url = url
				workplaceListBannerTextures[id] = current
			end
		end, "", false)

		return workplaceListBannerTextures[id].texture
	elseif kind == "logo" then
		local cached = workplaceListLogoTextures[id]
		if cached and cached.texture and isElement(cached.texture) and cached.url == url then
			return cached.texture
		end

		if cached and cached.loading then
			return cached.texture
		end

		workplaceListLogoTextures[id] = {
			texture = cached and cached.texture or nil,
			url = url,
			loading = true,
		}

		fetchRemote(url, function(data, errno)
			local current = workplaceListLogoTextures[id]
			if not current then
				return
			end
			current.loading = false

			if errno == 0 and data then
				if current.texture and isElement(current.texture) then
					destroyElement(current.texture)
				end
				current.texture = dxCreateTexture(data)
				current.url = url
				workplaceListLogoTextures[id] = current
			end
		end, "", false)

		return workplaceListLogoTextures[id].texture
	end

	return nil
end

addEvent("workplace.showActiveList", true)
addEventHandler("workplace.showActiveList", root, function(list)
	local store = useStore(activeWorkplacesStoreName)
	store.set("workplaces", list or {})

	showPage("activeWorkplaces")
end)

addEvent("workplace.showAdminList", true)
addEventHandler("workplace.showAdminList", root, function(list)
	local store = useStore(activeWorkplacesStoreName)
	store.set("workplacesAdmin", list or {})

	showPage("activeWorkplacesAdmin")
end)

function renderPages.activeWorkplaces()
	local store = useStore(activeWorkplacesStoreName)
	local theme = useTheme()
	local fonts = useFonts()

	local workplaces = store.get("workplaces") or {}
	local uiStore = useStore("activeWorkplacesUI")

	local containerSize = {
		x = 900,
		y = 520,
	}

	local window = drawWindow({
		position = {
			x = 0,
			y = 0,
		},
		size = containerSize,

		centered = true,
		radius = 12,
		padding = 20,

		header = {
			title = "Aktif İşyerleri",
			description = "Sunucudaki aktif işyerlerini görüntüleyebilirsiniz.",
			icon = "",
			close = true,
		},
	})

	if window.clickedClose then
		hidePage()
		return
	end

	-- İçerik alanı: pencerenin kenarlarından biraz içeri girerek çiz
	local innerMarginX = 15
	local innerMarginY = 40
	local contentX = window.x + innerMarginX
	-- Header içinde zaten açıklama var; burada tekrar yazmıyoruz.
	local contentY = window.y + innerMarginY
	local contentWidth = window.width - innerMarginX * 2

	-- Kart listesi yüksekliği (alt tarafta da biraz boşluk bırak)
	local listHeight = containerSize.y - (contentY - window.y) - 70
	-- Banner ve bilgi alanı için daha rahat alan
	local cardHeight = 193
	local cardGap = 14

	-- Sayfa başına kaç kart sığar?
	local perPage = math.max(1, math.floor((listHeight + cardGap) / (cardHeight + cardGap)))
	local totalPages = math.max(1, math.ceil(#workplaces / perPage))

	local currentPage = uiStore.get("page") or 1
	if currentPage > totalPages then
		currentPage = totalPages
	end
	if currentPage < 1 then
		currentPage = 1
	end
	uiStore.set("page", currentPage)

	local startIndex = (currentPage - 1) * perPage + 1
	local endIndex = math.min(#workplaces, currentPage * perPage)

	local cardY = contentY

	for i = startIndex, endIndex do
		local wp = workplaces[i]
		if wp then
			local cardX = contentX
			local cardW = contentWidth
			-- Kart arkaplanı (tamamen koyu)
			drawRoundedRectangle({
				position = {
					x = cardX,
					y = cardY,
				},
				size = {
					x = cardW,
					y = cardHeight,
				},
				color = theme.GRAY[900],
				variant = "soft",
				radius = 8,
			})

			-- Banner alanı (üstte, içeri gömülü)
			local bannerMarginX = 10
			local bannerMarginY = 8
			local bannerHeight = 110
			local bannerWidth = cardW - bannerMarginX * 2
			local bannerX = cardX + bannerMarginX
			local bannerY = cardY + bannerMarginY
			local bannerUrl = wp.bannerUrl or ""
			if bannerUrl ~= "" then
				local bannerTexture = getWorkplaceListTexture(wp.id, "banner", bannerUrl)
				if bannerTexture and isElement(bannerTexture) then
					dxDrawImage(bannerX, bannerY, bannerWidth, bannerHeight, bannerTexture)
				else
					drawRoundedRectangle({
						position = {
							x = bannerX,
							y = bannerY,
						},
						size = {
							x = bannerWidth,
							y = bannerHeight,
						},
						color = theme.GRAY[800],
						variant = "soft",
						radius = 8,
					})
				end
			else
				drawRoundedRectangle({
					position = {
						x = bannerX,
						y = bannerY,
					},
					size = {
						x = bannerWidth,
						y = bannerHeight,
					},
					color = theme.GRAY[800],
					variant = "soft",
					radius = 8,
				})

				-- Görsel yoksa No Data yazısı
				drawTypography({
					position = {
						x = bannerX,
						y = bannerY + bannerHeight / 2 - 10,
					},
					size = {
						x = bannerWidth,
						y = 20,
					},
					text = "No data",
					scale = "body",
					weight = "regular",
					color = theme.GRAY[500],
				})
			end

			-- Alt bilgi alanı (daha koyu arka plan)
			local infoY = bannerY + bannerHeight + 10
			local infoHeight = 80

			drawRoundedRectangle({
				position = {
					x = cardX,
					y = infoY,
				},
				size = {
					x = cardW,
					y = infoHeight,
				},
				color = theme.GRAY[800],
				variant = "soft",
				radius = 8,
			})

			-- İşyeri adı
			local name = wp.name or "Bilinmiyor"
			drawTypography({
				position = {
					x = cardX + 15,
					y = infoY + 5,
				},
				size = {
					x = cardW * 0.6,
					y = 20,
				},
				text = name,
				scale = "body",
				weight = "bold",
				color = theme.GRAY[100],
			})

			-- ID ve çalışma saatleri
			local idText = "İşyeri ID: " .. tostring(wp.id or 0)
			local hoursText = (wp.openTime or "20:00") .. " - " .. (wp.closeTime or "00:00")

			drawTypography({
				position = {
					x = cardX + 15,
					y = infoY + 25,
				},
				size = {
					x = cardW * 0.4,
					y = 18,
				},
				text = idText,
				scale = "body",
				weight = "regular",
				color = theme.GRAY[400],
			})

			drawTypography({
				position = {
					x = cardX + 15,
					y = infoY + 42,
				},
				size = {
					x = cardW * 0.4,
					y = 18,
				},
				text = "Çalışma Saatleri: " .. hoursText,
				scale = "body",
				weight = "regular",
				color = theme.GRAY[400],
			})

			-- Giriş ücreti
			local fee = wp.fee or 0
			drawTypography({
				position = {
					x = cardX + cardW * 0.45,
					y = infoY + 18,
				},
				size = {
					x = cardW * 0.15,
					y = 18,
				},
				text = "Giriş Ücreti: ₺" .. tostring(fee),
				scale = "body",
				weight = "regular",
				color = theme.GRAY[300],
			})

			-- Aktif butonu (Konuma Git ile aynı hizada)
			local statusButton = drawButton({
				position = {
					x = cardX + cardW - 90,
					y = infoY + 12,
				},
				size = {
					x = 80,
					y = 26,
				},
				radius = 6,

				textProperties = {
					align = "center",
					color = theme.WHITE,
					font = fonts.body.regular,
					scale = 1,
				},

				variant = "soft",
				color = "green",
				disabled = true,

				text = "Aktif",
			})

			-- Konuma Git butonu (aynı satır)
			local gotoButton = drawButton({
				position = {
					x = cardX + cardW - 200,
					y = infoY + 12,
				},
				size = {
					x = 110,
					y = 26,
				},
				radius = 6,

				textProperties = {
					align = "center",
					color = theme.WHITE,
					font = fonts.body.regular,
					scale = 1,
				},

				variant = "soft",
				color = "blue",
				disabled = false,

				text = "Konuma Git",
			})

			-- Konuma Git'e basınca /mgps <kapıID> komutunu çalıştır
			if gotoButton.pressed then
				-- Server tarafındaki /mgps (findInteriorGPS) mantığını kullan
				triggerServerEvent("workplace.goto", localPlayer, wp.id or 0)
			end

			-- Logo: banner üzerinde sol üst köşeye küçük kare olarak çiz
			local logoUrl = wp.logoUrl or ""
			if logoUrl ~= "" then
				local logoSize = 64
				local logoPadding = 12
				local logoTexture = getWorkplaceListTexture(wp.id, "logo", logoUrl)
				if logoTexture and isElement(logoTexture) then
					dxDrawImage(
						bannerX + logoPadding,
						bannerY + logoPadding,
						logoSize,
						logoSize,
						logoTexture
					)
				end
			end

			cardY = cardY + cardHeight + cardGap
		end
	end

	-- Sayfalandırma butonları (pencerenin içinde)
	if totalPages > 1 then
		local paginationY = window.y + containerSize.y - 35
		local btnSize = {
			x = 30,
			y = 24,
		}

		for i = 1, totalPages do
			local btn = drawButton({
				position = {
					x = contentX + (i - 1) * (btnSize.x + 5),
					y = paginationY,
				},
				size = btnSize,
				radius = 4,

				textProperties = {
					align = "center",
					color = theme.WHITE,
					font = fonts.body.regular,
					scale = 1,
				},

				variant = "soft",
				color = i == currentPage and "green" or "gray",
				disabled = false,

				text = tostring(i),
			})

			if btn.pressed then
				uiStore.set("page", i)
			end
		end
	end
end

function renderPages.activeWorkplacesAdmin()
	local store = useStore(activeWorkplacesStoreName)
	local uiStore = useStore("activeWorkplacesAdminUI")
	local theme = useTheme()
	local fonts = useFonts()

	local workplaces = store.get("workplacesAdmin") or {}

	local containerSize = {
		x = 900,
		y = 520,
	}

	local window = drawWindow({
		position = {
			x = 0,
			y = 0,
		},
		size = containerSize,

		centered = true,
		radius = 12,
		padding = 20,

		header = {
			title = "Aktif İşyerleri (Admin)",
			description = "İşyeri durumlarını ve sahiplerini görüntüleyebilirsiniz.",
			icon = "",
			close = true,
		},
	})

	if window.clickedClose then
		hidePage()
		return
	end

	local innerMarginX = 15
	local innerMarginY = 40
	local contentX = window.x + innerMarginX
	local contentY = window.y + innerMarginY
	local contentWidth = window.width - innerMarginX * 2

	local listHeight = containerSize.y - (contentY - window.y) - 70
	local cardHeight = 130
	local cardGap = 10

	local perPage = math.max(1, math.floor((listHeight + cardGap) / (cardHeight + cardGap)))
	local totalPages = math.max(1, math.ceil(#workplaces / perPage))

	local currentPage = uiStore.get("page") or 1
	if currentPage > totalPages then
		currentPage = totalPages
	end
	if currentPage < 1 then
		currentPage = 1
	end
	uiStore.set("page", currentPage)

	local startIndex = (currentPage - 1) * perPage + 1
	local endIndex = math.min(#workplaces, currentPage * perPage)

	local cardY = contentY

	for i = startIndex, endIndex do
		local wp = workplaces[i]
		if wp then
			local cardX = contentX
			local cardW = contentWidth

			drawRoundedRectangle({
				position = {
					x = cardX,
					y = cardY,
				},
				size = {
					x = cardW,
					y = cardHeight,
				},
				color = theme.GRAY[900],
				variant = "soft",
				radius = 8,
			})

			local name = wp.name or "Bilinmiyor"
			local idText = "İşyeri ID: " .. tostring(wp.id or 0)
			local ownerName = wp.ownerName or "Hiçbiri"
			local ownerStatus = wp.ownerOnline and "Çevrimiçi" or "Çevrimdışı"
			local activeStatus = wp.active and "Aktif" or "Pasif"

			-- Üst satır: isim + aktif/pasif
			drawTypography({
				position = {
					x = cardX + 15,
					y = cardY + 8,
				},
				size = {
					x = cardW * 0.6,
					y = 20,
				},
				text = name,
				scale = "body",
				weight = "bold",
				color = theme.GRAY[100],
			})

			drawTypography({
				position = {
					x = cardX + cardW - 130,
					y = cardY + 8,
				},
				size = {
					x = 115,
					y = 20,
				},
				text = "Durum: " .. activeStatus,
				scale = "body",
				weight = "regular",
				color = wp.active and theme.GREEN[300] or theme.GRAY[400],
			})

			-- Aktif/Pasif toggle butonu
			local toggleButton = drawButton({
				position = {
					x = cardX + cardW - 130,
					y = cardY + 34,
				},
				size = {
					x = 115,
					y = 24,
				},
				radius = 6,

				textProperties = {
					align = "center",
					color = theme.WHITE,
					font = fonts.body.regular,
					scale = 1,
				},

				variant = "soft",
				color = wp.active and "green" or "red",
				disabled = false,

				text = wp.active and "Pasif Yap" or "Aktif Yap",
			})

			-- Orta satır: ID + sahip
			drawTypography({
				position = {
					x = cardX + 15,
					y = cardY + 32,
				},
				size = {
					x = cardW * 0.4,
					y = 18,
				},
				text = idText,
				scale = "body",
				weight = "regular",
				color = theme.GRAY[400],
			})

			drawTypography({
				position = {
					x = cardX + cardW * 0.4,
					y = cardY + 32,
				},
				size = {
					x = cardW * 0.4,
					y = 18,
				},
				text = "Sahip: " .. ownerName .. " (" .. ownerStatus .. ")",
				scale = "body",
				weight = "regular",
				color = theme.GRAY[400],
			})

			-- Alt satır: çalışma saatleri + giriş ücreti
			local hoursText = (wp.openTime or "20:00") .. " - " .. (wp.closeTime or "00:00")
			local fee = wp.fee or 0

			drawTypography({
				position = {
					x = cardX + 15,
					y = cardY + 54,
				},
				size = {
					x = cardW * 0.4,
					y = 18,
				},
				text = "Çalışma Saatleri: " .. hoursText,
				scale = "body",
				weight = "regular",
				color = theme.GRAY[400],
			})

			drawTypography({
				position = {
					x = cardX + cardW * 0.4,
					y = cardY + 54,
				},
				size = {
					x = cardW * 0.4,
					y = 18,
				},
				text = "Giriş Ücreti: ₺" .. tostring(fee),
				scale = "body",
				weight = "regular",
				color = theme.GRAY[400],
			})

			cardY = cardY + cardHeight + cardGap

			-- Toggle butonuna basıldıysa server'a bildir
			if toggleButton.pressed then
				triggerServerEvent("workplace.adminToggle", localPlayer, wp.id or 0, not wp.active)
			end
		end
	end

	-- Sayfalandırma butonları
	if totalPages > 1 then
		local paginationY = window.y + containerSize.y - 35
		local btnSize = {
			x = 30,
			y = 24,
		}

		for i = 1, totalPages do
			local btn = drawButton({
				position = {
					x = contentX + (i - 1) * (btnSize.x + 5),
					y = paginationY,
				},
				size = btnSize,
				radius = 4,

				textProperties = {
					align = "center",
					color = theme.WHITE,
					font = fonts.body.regular,
					scale = 1,
				},

				variant = "soft",
				color = i == currentPage and "green" or "gray",
				disabled = false,

				text = tostring(i),
			})

			if btn.pressed then
				uiStore.set("page", i)
			end
		end
	end
end

