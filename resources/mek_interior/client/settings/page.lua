local containerSize = {
	x = 600,
	y = 500, -- varsayılan yükseklik
}

-- İşyeri önizleme için texture cache (browser yok, izin istemez)
local workplaceLogoTexture = nil
local workplaceLogoUrlCached = nil
local workplaceLogoLoading = false

local workplaceBannerTexture = nil
local workplaceBannerUrlCached = nil
local workplaceBannerLoading = false

local function getWorkplaceTexture(kind, url)
	if not url or url == "" then
		return nil
	end

	-- geçersiz url ise hiç uğraşma
	if not url:find("^https?://") then
		return nil
	end

	if kind == "logo" then
		if workplaceLogoTexture and isElement(workplaceLogoTexture) and workplaceLogoUrlCached == url then
			return workplaceLogoTexture
		end

		if not workplaceLogoLoading then
			workplaceLogoLoading = true
			fetchRemote(url, function(data, errno)
				workplaceLogoLoading = false
				if errno == 0 and data then
					if isElement(workplaceLogoTexture) then
						destroyElement(workplaceLogoTexture)
					end
					workplaceLogoTexture = dxCreateTexture(data)
					workplaceLogoUrlCached = url
				end
			end, "", false)
		end

		return workplaceLogoTexture
	elseif kind == "banner" then
		if workplaceBannerTexture and isElement(workplaceBannerTexture) and workplaceBannerUrlCached == url then
			return workplaceBannerTexture
		end

		if not workplaceBannerLoading then
			workplaceBannerLoading = true
			fetchRemote(url, function(data, errno)
				workplaceBannerLoading = false
				if errno == 0 and data then
					if isElement(workplaceBannerTexture) then
						destroyElement(workplaceBannerTexture)
					end
					workplaceBannerTexture = dxCreateTexture(data)
					workplaceBannerUrlCached = url
				end
			end, "", false)
		end

		return workplaceBannerTexture
	end

	return nil
end

function renderPages.settings()
	local store = useStore("interiorSettings")
	local theme = useTheme()
	local fonts = useFonts()
	
	local interiorElement = store.get("interiorElement")
	local interiorID = store.get("interiorID")
	local isVehicleInterior = store.get("isVehicleInterior")
	local settingsData = store.get("settingsData") or {}
	
	if not interiorElement or not interiorID then
		hidePage()
		return
	end
	
	-- Get interior data
	local interiorName = getElementData(interiorElement, "name") or ""
	local entrance = getElementData(interiorElement, "entrance") or {}
	local entranceFee = entrance.fee or entrance[7] or 0
	local interiorStatus = getElementData(interiorElement, "status") or {}

	-- İşletme / işyeri bilgisi
	local isBusinessType = interiorStatus.type == 1
	local isWorkplaceSetting = false
	if settingsData.isWorkplace ~= nil then
		if
			settingsData.isWorkplace == true
			or settingsData.isWorkplace == 1
			or settingsData.isWorkplace == "1"
			or settingsData.isWorkplace == "true"
		then
			isWorkplaceSetting = true
		end
	end
	-- İşyeri Yönetimi sekmesi sadece işletme/interiorlarda gözüksün
	local showWorkplaceTab = isBusinessType or isWorkplaceSetting

	-- Sekmeye göre dinamik yükseklik: sadece İşyeri Yönetimi sekmesinde büyüt
	local uiStore = useStore("interiorSettingsUI")
	local lastSelectedTab = uiStore.get("selectedTab") or 1
	local dynamicHeight = containerSize.y
	if showWorkplaceTab and lastSelectedTab == 5 then
		-- İşyeri Yönetimi sekmesinde en alttaki çalışma saatleri alanı ile Kaydet butonu
		-- üst üste binmesin diye pencereyi biraz daha büyütüyoruz.
		dynamicHeight = 860
	end

	local windowSize = {
		x = containerSize.x,
		y = dynamicHeight,
	}
	
	-- Initialize input values in store if not exists
	if not store.get("interiorName") then
		store.set("interiorName", interiorName)
	end
	if not store.get("entranceFee") then
		store.set("entranceFee", tostring(entranceFee))
	end
	
	local window = drawWindow({
		position = {
			x = 0,
			y = 0,
		},
		size = windowSize,
		
		centered = true,
		radius = 12,
		padding = 20,
		
		header = {
			title = "Mülk Ayarları",
			description = "",
			icon = "",
			close = true,
		},
	})
	
	if window.clickedClose then
		-- Texture cache'i temizle
		if workplaceLogoTexture and isElement(workplaceLogoTexture) then
			destroyElement(workplaceLogoTexture)
		end
		workplaceLogoTexture = nil
		workplaceLogoUrlCached = nil
		workplaceLogoLoading = false

		if workplaceBannerTexture and isElement(workplaceBannerTexture) then
			destroyElement(workplaceBannerTexture)
		end
		workplaceBannerTexture = nil
		workplaceBannerUrlCached = nil
		workplaceBannerLoading = false

		hidePage()
		return
	end
	
	-- Tab Panel
	local tabs = {
		drawTab({ name = "Genel", icon = "", disabled = false }),
		drawTab({ name = "Satış", icon = "", disabled = false }),
		drawTab({ name = "Özelleştir", icon = "", disabled = false }),
		drawTab({ name = "Ses", icon = "", disabled = false }),
	}

	if showWorkplaceTab then
		table.insert(tabs, drawTab({ name = "İşyeri Yönetimi", icon = "", disabled = false }))
	end

	local tabPanel = drawTabPanel({
		position = {
			x = window.x,
			y = window.y,
		},
		size = {
			x = window.width,
			y = windowSize.y - 80,
		},
		padding = 10,
		
		name = "interior_settings_tabs",
		
		placement = "horizontal",
		tabs = tabs,
		
		variant = "soft",
		color = "gray",
		radius = 8,
		
		activeTab = 1,
		disabled = false,
	})
	
	if tabPanel then
		local selectedTab = tabPanel.selected or 1

		-- Seçili sekmeyi store'a yaz, bir sonraki frame'de yüksekliği buna göre ayarlayalım
		if uiStore.get("selectedTab") ~= selectedTab then
			uiStore.set("selectedTab", selectedTab)
		end
		local contentY = tabPanel.position.y
		local contentX = tabPanel.position.x
		local contentWidth = tabPanel.size.x
		
		if selectedTab == 1 then
			-- Genel Tab
			local currentY = contentY
			
			-- Mülk Adı
			drawTypography({
				position = {
					x = contentX,
					y = currentY,
				},
				size = {
					x = contentWidth,
					y = 20,
				},
				text = "Mülk Adı",
				scale = "body",
				weight = "regular",
				color = theme.GRAY[300],
			})
			
			currentY = currentY + 25
			
			local nameInput = drawInput({
				position = {
					x = contentX,
					y = currentY,
				},
				size = {
					x = contentWidth,
					y = 40,
				},
				radius = 8,
				padding = 10,
				
				name = "interiorNameInput",
				
				label = "",
				placeholder = "Mülk adı girin",
				value = store.get("interiorName") or interiorName,
				
				variant = "solid",
				color = "gray",
				
				textVariant = "body",
				textWeight = "regular",
				
				disabled = false,
				
				mask = false,
			})
			
			if nameInput.value ~= (store.get("interiorName") or interiorName) then
				store.set("interiorName", nameInput.value)
			end
			
			-- Banner URL inputundan sonra biraz daha boşluk bırak
			currentY = currentY + 75
			
			-- Giriş Ücreti
			drawTypography({
				position = {
					x = contentX,
					y = currentY,
				},
				size = {
					x = contentWidth,
					y = 20,
				},
				text = "Giriş Ücreti",
				scale = "body",
				weight = "regular",
				color = theme.GRAY[300],
			})
			
			currentY = currentY + 25
			
			local feeInput = drawInput({
				position = {
					x = contentX,
					y = currentY,
				},
				size = {
					x = contentWidth,
					y = 40,
				},
				radius = 8,
				padding = 10,
				
				name = "entranceFeeInput",
				
				label = "",
				placeholder = "0 (Max: 500)",
				value = store.get("entranceFee") or tostring(entranceFee),
				
				variant = "solid",
				color = "gray",
				
				textVariant = "body",
				textWeight = "regular",
				
				disabled = false,
				
				mask = false,
			})
			
			-- Update store when input value changes (no validation here to prevent spam)
			if feeInput.value ~= (store.get("entranceFee") or tostring(entranceFee)) then
				store.set("entranceFee", feeInput.value)
			end
			
			currentY = currentY + 70
			
			-- Checkboxes
			local checkboxSettings = {
				{ "Mülk Işıkları", "lights" },
				{ "OOC Sohbet", "ooc" },
				{ "GPS İzni", "gps" },
			}
			
			for k, v in ipairs(checkboxSettings) do
				-- Get current value from settings, default to true if not set
				local currentValue = true
				if settingsData[v[2]] ~= nil then
					-- Check the actual value - if it's explicitly false, use false
					if settingsData[v[2]] == false or settingsData[v[2]] == "false" then
						currentValue = false
					elseif settingsData[v[2]] == true or settingsData[v[2]] == "true" or settingsData[v[2]] == 1 then
						currentValue = true
					else
						-- For any other value, default to true
						currentValue = true
					end
				end
				
				local checkboxResult = drawCheckbox({
					position = {
						x = contentX,
						y = currentY,
					},
					size = 24,
					
					name = "setting_" .. v[2],
					
					text = v[1],
					helperText = {
						text = "",
						color = theme.GRAY[700],
					},
					
					variant = "soft",
					color = "gray",
					
					checked = currentValue,
					disabled = false,
				})
				
				-- Store checkbox state for saving
				if checkboxResult and checkboxResult.checked ~= nil then
					store.set("checkbox_" .. v[2], checkboxResult.checked)
				end
				
				currentY = currentY + 45
			end
		elseif selectedTab == 2 then
			-- Satış Tab
			local currentY = contentY
			
			-- Satış Fiyatı
			drawTypography({
				position = {
					x = contentX,
					y = currentY,
				},
				size = {
					x = contentWidth,
					y = 20,
				},
				text = "Satış Fiyatı",
				scale = "body",
				weight = "regular",
				color = theme.GRAY[300],
			})
			
			currentY = currentY + 25
			
			local costInput = drawInput({
				position = {
					x = contentX,
					y = currentY,
				},
				size = {
					x = contentWidth,
					y = 40,
				},
				radius = 8,
				padding = 10,
				
				name = "saleCostInput",
				
				label = "",
				placeholder = "0",
				value = tostring(interiorStatus.cost or 0),
				
				variant = "solid",
				color = "gray",
				
				textVariant = "body",
				textWeight = "regular",
				
				disabled = false,
				
				mask = false,
			})
			
			if not store.get("saleCost") then
				store.set("saleCost", tostring(interiorStatus.cost or 0))
			end
			
			if costInput.value ~= (store.get("saleCost") or tostring(interiorStatus.cost or 0)) then
				store.set("saleCost", costInput.value)
			end
			
			currentY = currentY + 70
			
			-- Satış Durumu
			drawTypography({
				position = {
					x = contentX,
					y = currentY,
				},
				size = {
					x = contentWidth,
					y = 20,
				},
				text = "Satış Durumu",
				scale = "body",
				weight = "regular",
				color = theme.GRAY[300],
			})
			
			currentY = currentY + 25
			
			-- Check if interior is government type (can't be put on sale)
			local isGovernment = (interiorStatus.type == 2)
			
			local forSaleCheckbox = drawCheckbox({
				position = {
					x = contentX,
					y = currentY,
				},
				size = 24,
				
				name = "setting_forSale",
				
				text = "Mülkü Satışa Çıkar",
				helperText = {
					text = isGovernment and "Devlet mülkleri satışa çıkarılamaz" or "",
					color = theme.GRAY[700],
				},
				
				variant = "soft",
				color = "gray",
				
				checked = (interiorStatus.owner == -1 and interiorStatus.locked == true) or false,
				disabled = isGovernment,
			})
			
			-- Store checkbox state for saving (only if not government)
			if not isGovernment and forSaleCheckbox and forSaleCheckbox.checked ~= nil then
				store.set("checkbox_forSale", forSaleCheckbox.checked)
			end
		elseif selectedTab == 3 then
			-- Özelleştir Tab
			local currentY = contentY
			
			-- Mobilya
			drawTypography({
				position = {
					x = contentX,
					y = currentY,
				},
				size = {
					x = contentWidth,
					y = 20,
				},
				text = "Mobilya Ayarları",
				scale = "body",
				weight = "regular",
				color = theme.GRAY[300],
			})
			
			currentY = currentY + 25
			
			local furnitureCheckbox = drawCheckbox({
				position = {
					x = contentX,
					y = currentY,
				},
				size = 24,
				
				name = "setting_furniture",
				
				text = "Mobilyaları Aktif Et",
				helperText = {
					text = "",
					color = theme.GRAY[700],
				},
				
				variant = "soft",
				color = "gray",
				
				checked = (interiorStatus.furniture == 1) or false,
				disabled = false,
			})
			
			-- Store checkbox state for saving
			if furnitureCheckbox and furnitureCheckbox.checked ~= nil then
				store.set("checkbox_furniture", furnitureCheckbox.checked)
			end
			
			currentY = currentY + 70
			
			-- Mülk Tipi
			drawTypography({
				position = {
					x = contentX,
					y = currentY,
				},
				size = {
					x = contentWidth,
					y = 20,
				},
				text = "Mülk Tipi",
				scale = "body",
				weight = "regular",
				color = theme.GRAY[300],
			})
			
			currentY = currentY + 25
			
			local typeText = "Bilinmiyor"
			if interiorStatus.type == 0 then
				typeText = "Ev"
			elseif interiorStatus.type == 1 then
				typeText = "İşletme"
			elseif interiorStatus.type == 2 then
				typeText = "Devlet"
			elseif interiorStatus.type == 3 then
				typeText = "Kiralık"
			end
			
			drawTypography({
				position = {
					x = contentX,
					y = currentY,
				},
				size = {
					x = contentWidth,
					y = 30,
				},
				text = typeText,
				scale = "body",
				weight = "regular",
				color = theme.GRAY[400],
			})
		elseif selectedTab == 4 then
			-- Ses Tab
			local currentY = contentY
			
			-- Müzik URL ve Ses Seviyesi
			drawTypography({
				position = {
					x = contentX,
					y = currentY,
				},
				size = {
					x = contentWidth,
					y = 20,
				},
				text = "URL",
				scale = "body",
				weight = "regular",
				color = theme.GRAY[300],
			})
			
			currentY = currentY + 25
			
			-- Initialize music URL and volume in store if not exists
			if store.get("musicUrl") == nil then
				store.set("musicUrl", settingsData.musicUrl or "")
			end
			if store.get("musicVolume") == nil then
				store.set("musicVolume", tostring(settingsData.musicVolume or 50))
			end
			
			local musicUrl = store.get("musicUrl") or ""
			
			local urlInput = drawInput({
				position = {
					x = contentX,
					y = currentY,
				},
				size = {
					x = contentWidth,
					y = 50,
				},
				radius = 8,
				padding = 10,
				
				name = "musicUrlInput",
				
				label = "",
				placeholder = "YouTube URL veya doğrudan ses URL'si yapıştırın...",
				value = musicUrl,
				
				variant = "solid",
				color = "gray",
				
				textVariant = "body",
				textWeight = "regular",
				
				disabled = false,
				
				mask = false,
			})
			
			if urlInput.value and urlInput.value ~= musicUrl then
				local cleanedUrl = urlInput.value:gsub("^%s+", ""):gsub("%s+$", "") -- Trim whitespace
				
				-- Clean YouTube URL - remove unnecessary parameters
				if cleanedUrl:find("youtube%.com") or cleanedUrl:find("youtu%.be") then
					-- Extract video ID and create clean URL
					local videoId = cleanedUrl:match("v=([^&]+)") or cleanedUrl:match("youtu%.be/([^?]+)") or cleanedUrl:match("embed/([^?]+)")
					if videoId then
						cleanedUrl = "https://www.youtube.com/watch?v=" .. videoId
					end
				end
				
				store.set("musicUrl", cleanedUrl)
				musicUrl = cleanedUrl
			end
			
			currentY = currentY + 60
			
			-- Ses Seviyesi
			drawTypography({
				position = {
					x = contentX,
					y = currentY,
				},
				size = {
					x = contentWidth,
					y = 20,
				},
				text = "Ses Seviyesi",
				scale = "body",
				weight = "regular",
				color = theme.GRAY[300],
			})
			
			currentY = currentY + 25
			
			local volumeValue = store.get("musicVolume") or "50"
			
			-- Volume input with icon
			local volumeContainerWidth = contentWidth
			local volumeInputWidth = volumeContainerWidth - 50
			
			local volumeInput = drawInput({
				position = {
					x = contentX,
					y = currentY,
				},
				size = {
					x = volumeInputWidth,
					y = 40,
				},
				radius = 8,
				padding = 10,
				
				name = "musicVolumeInput",
				
				label = "",
				placeholder = "0-100",
				value = volumeValue,
				
				variant = "solid",
				color = "gray",
				
				textVariant = "body",
				textWeight = "regular",
				
				disabled = false,
				
				mask = false,
			})
			
			-- Speaker icon (text representation)
			drawTypography({
				position = {
					x = contentX + volumeInputWidth + 10,
					y = currentY + 10,
				},
				size = {
					x = 30,
					y = 20,
				},
				text = "♪",
				scale = "body",
				weight = "regular",
				color = theme.GRAY[400],
			})
			
			-- Display volume percentage
			drawTypography({
				position = {
					x = contentX + volumeInputWidth + 10,
					y = currentY + 30,
				},
				size = {
					x = 30,
					y = 20,
				},
				text = volumeValue,
				scale = "body",
				weight = "regular",
				color = theme.GRAY[400],
			})
			
			if volumeInput.value ~= volumeValue then
				local vol = tonumber(volumeInput.value) or 50
				if vol < 0 then vol = 0 end
				if vol > 100 then vol = 100 end
				store.set("musicVolume", tostring(vol))
				volumeValue = tostring(vol)
			end
			
			currentY = currentY + 60
			
			-- Oynat butonu
			local playButton = drawButton({
				position = {
					x = contentX,
					y = currentY,
				},
				size = {
					x = contentWidth,
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
				disabled = false,
				
				text = "Oynat",
				icon = "",
			})
			
			if playButton.pressed then
				local url = store.get("musicUrl") or ""
				local volume = tonumber(store.get("musicVolume") or 50) or 50
				
				if url and url ~= "" then
					-- Trigger play music event
					triggerServerEvent("interior.playMusic", resourceRoot, interiorElement, interiorID, url, volume)
				else
					exports.mek_infobox:addBox("error", "Lütfen bir URL girin.")
				end
			end
		elseif selectedTab == 5 and showWorkplaceTab then
			-- İşyeri Yönetimi Tab
			local currentY = contentY

			-- Bilgi başlığı
			drawTypography({
				position = {
					x = contentX,
					y = currentY,
				},
				size = {
					x = contentWidth,
					y = 20,
				},
				text = "İşyeri Ayarları",
				scale = "body",
				weight = "regular",
				color = theme.GRAY[300],
			})

			currentY = currentY + 25

			-- İç mekan tipi bilgisi
			local typeText = "Bu mülk tipi: Bilinmiyor"
			if interiorStatus.type == 0 then
				typeText = "Bu mülk tipi: Ev"
			elseif interiorStatus.type == 1 then
				typeText = "Bu mülk tipi: İşletme"
			elseif interiorStatus.type == 2 then
				typeText = "Bu mülk tipi: Devlet"
			elseif interiorStatus.type == 3 then
				typeText = "Bu mülk tipi: Kiralık"
			end

			drawTypography({
				position = {
					x = contentX,
					y = currentY,
				},
				size = {
					x = contentWidth,
					y = 30,
				},
				text = typeText,
				scale = "body",
				weight = "regular",
				color = theme.GRAY[400],
			})

			currentY = currentY + 40

			-- İşyeri Aktif / Pasif butonu
			local workplaceActive = settingsData.workplaceActive
			if workplaceActive == nil then
				-- İşletme tipi ise varsayılan olarak aktif gelsin
				workplaceActive = isBusinessType and 1 or 0
			end

			if store.get("workplaceActive") == nil then
				store.set("workplaceActive", workplaceActive)
			end

			local currentActive = store.get("workplaceActive") or 0

			local activeButton = drawButton({
				position = {
					x = contentX + contentWidth - 120,
					y = currentY,
				},
				size = {
					x = 110,
					y = 32,
				},
				radius = 8,

				textProperties = {
					align = "center",
					color = theme.WHITE,
					font = fonts.body.regular,
					scale = 1,
				},

				variant = "soft",
				color = currentActive == 1 and "green" or "gray",
				disabled = false,

				text = currentActive == 1 and "Aktif" or "Pasif",
				icon = "",
			})

			if activeButton.pressed then
				if currentActive == 1 then
					store.set("workplaceActive", 0)
				else
					store.set("workplaceActive", 1)
				end
			end

			currentY = currentY + 40

			-- Logo ve banner URL değerlerini store'a al
			if store.get("workplaceLogoUrl") == nil then
				store.set("workplaceLogoUrl", settingsData.workplaceLogoUrl or "")
			end
			if store.get("workplaceBannerUrl") == nil then
				store.set("workplaceBannerUrl", settingsData.workplaceBannerUrl or "")
			end
			if store.get("workplaceOpenTime") == nil then
				store.set("workplaceOpenTime", settingsData.workplaceOpenTime or "20:00")
			end
			if store.get("workplaceCloseTime") == nil then
				store.set("workplaceCloseTime", settingsData.workplaceCloseTime or "00:00")
			end

			local logoUrl = store.get("workplaceLogoUrl") or ""
			local bannerUrl = store.get("workplaceBannerUrl") or ""

			-- Logo Önizleme başlığı
			drawTypography({
				position = {
					x = contentX,
					y = currentY,
				},
				size = {
					x = contentWidth,
					y = 20,
				},
				text = "Logo Önizleme",
				scale = "body",
				weight = "regular",
				color = theme.GRAY[300],
			})

			currentY = currentY + 25

			-- Logo önizleme alanı (biraz daha büyük göster)
			local logoPreviewHeight = 110

			if logoUrl ~= "" then
				local logoTexture = getWorkplaceTexture("logo", logoUrl)
				if logoTexture and isElement(logoTexture) then
					dxDrawImage(contentX, currentY, contentWidth, logoPreviewHeight, logoTexture)
				else
					drawRoundedRectangle({
						position = {
							x = contentX,
							y = currentY,
						},
						size = {
							x = contentWidth,
							y = logoPreviewHeight,
						},
						color = theme.GRAY[800],
						variant = "soft",
						radius = 8,
					})

					drawTypography({
						position = {
							x = contentX + 10,
							y = currentY + 30,
						},
						size = {
							x = contentWidth - 20,
							y = 20,
						},
						text = "Logo yükleniyor...",
						scale = "body",
						weight = "regular",
						color = theme.GRAY[400],
					})
				end
			else
				drawRoundedRectangle({
					position = {
						x = contentX,
						y = currentY,
					},
					size = {
						x = contentWidth,
						y = logoPreviewHeight,
					},
					color = theme.GRAY[800],
					variant = "soft",
					radius = 8,
				})

				drawTypography({
					position = {
						x = contentX + 10,
						y = currentY + 30,
					},
					size = {
						x = contentWidth - 20,
						y = 20,
					},
					text = "İşyeri logo URL'si girildiğinde burada önizleme gösterilecektir. (Imgur önerilir)",
					scale = "body",
					weight = "regular",
					color = theme.GRAY[400],
				})
			end

			currentY = currentY + logoPreviewHeight + 15

			-- İşyeri Logo URL alanı
			drawTypography({
				position = {
					x = contentX,
					y = currentY,
				},
				size = {
					x = contentWidth,
					y = 20,
				},
				text = "İşyeri Logo URL",
				scale = "body",
				weight = "regular",
				color = theme.GRAY[300],
			})

			currentY = currentY + 25

			local logoInput = drawInput({
				position = {
					x = contentX,
					y = currentY,
				},
				size = {
					x = contentWidth,
					y = 40,
				},
				radius = 8,
				padding = 10,

				name = "workplaceLogoUrlInput",

				label = "",
				placeholder = "https://i.imgur.com/..... (512x512 piksel önerilir)",
				value = logoUrl,

				variant = "solid",
				color = "gray",

				textVariant = "body",
				textWeight = "regular",

				disabled = false,

				mask = false,
			})

			if logoInput.value ~= logoUrl then
				store.set("workplaceLogoUrl", logoInput.value)
				logoUrl = logoInput.value
			end

			currentY = currentY + 60

			-- Banner Önizleme başlığı
			drawTypography({
				position = {
					x = contentX,
					y = currentY,
				},
				size = {
					x = contentWidth,
					y = 20,
				},
				text = "Banner Önizleme",
				scale = "body",
				weight = "regular",
				color = theme.GRAY[300],
			})

			currentY = currentY + 25

			-- Banner önizleme alanı (daha büyük ve okunaklı)
			local bannerPreviewHeight = 140

			if bannerUrl ~= "" then
				local bannerTexture = getWorkplaceTexture("banner", bannerUrl)
				if bannerTexture and isElement(bannerTexture) then
					dxDrawImage(contentX, currentY, contentWidth, bannerPreviewHeight, bannerTexture)
				else
					drawRoundedRectangle({
						position = {
							x = contentX,
							y = currentY,
						},
						size = {
							x = contentWidth,
							y = bannerPreviewHeight,
						},
						color = theme.GRAY[800],
						variant = "soft",
						radius = 8,
					})

					drawTypography({
						position = {
							x = contentX + 10,
							y = currentY + 40,
						},
						size = {
							x = contentWidth - 20,
							y = 20,
						},
						text = "Banner yükleniyor...",
						scale = "body",
						weight = "regular",
						color = theme.GRAY[400],
					})
				end
			else
				drawRoundedRectangle({
					position = {
						x = contentX,
						y = currentY,
					},
					size = {
						x = contentWidth,
						y = bannerPreviewHeight,
					},
					color = theme.GRAY[800],
					variant = "soft",
					radius = 8,
				})

				drawTypography({
					position = {
						x = contentX + 10,
						y = currentY + 40,
					},
					size = {
						x = contentWidth - 20,
						y = 20,
					},
					text = "İşyeri banner URL'si girildiğinde burada önizleme gösterilecektir.",
					scale = "body",
					weight = "regular",
					color = theme.GRAY[400],
				})
			end

			currentY = currentY + bannerPreviewHeight + 15

			-- İşyeri Banner URL alanı
			drawTypography({
				position = {
					x = contentX,
					y = currentY,
				},
				size = {
					x = contentWidth,
					y = 20,
				},
				text = "İşyeri Banner URL",
				scale = "body",
				weight = "regular",
				color = theme.GRAY[300],
			})

			currentY = currentY + 25

			local bannerInput = drawInput({
				position = {
					x = contentX,
					y = currentY,
				},
				size = {
					x = contentWidth,
					y = 40,
				},
				radius = 8,
				padding = 10,

				name = "workplaceBannerUrlInput",

				label = "",
				placeholder = "https://i.imgur.com/..... (1024x200 piksel önerilir)",
				value = bannerUrl,

				variant = "solid",
				color = "gray",

				textVariant = "body",
				textWeight = "regular",

				disabled = false,

				mask = false,
			})

			if bannerInput.value ~= bannerUrl then
				store.set("workplaceBannerUrl", bannerInput.value)
				bannerUrl = bannerInput.value
			end

			currentY = currentY + 60

			-- Çalışma saatleri (Açılış / Kapanış)
			drawTypography({
				position = {
					x = contentX,
					y = currentY,
				},
				size = {
					x = contentWidth,
					y = 20,
				},
				text = "Çalışma Saatleri",
				scale = "body",
				weight = "regular",
				color = theme.GRAY[300],
			})

			currentY = currentY + 46

			local halfWidth = (contentWidth - 10) / 2

			local openTimeValue = store.get("workplaceOpenTime") or "20:00"
			local closeTimeValue = store.get("workplaceCloseTime") or "00:00"

			-- Açılış
			local openInput = drawInput({
				position = {
					x = contentX,
					y = currentY,
				},
				size = {
					x = halfWidth,
					y = 40,
				},
				radius = 8,
				padding = 10,

				name = "workplaceOpenTimeInput",

				label = "Açılış Saati",
				placeholder = "20:00",
				value = openTimeValue,

				variant = "solid",
				color = "gray",

				textVariant = "body",
				textWeight = "regular",

				disabled = false,

				mask = false,
			})

			-- Kapanış
			local closeInput = drawInput({
				position = {
					x = contentX + halfWidth + 10,
					y = currentY,
				},
				size = {
					x = halfWidth,
					y = 40,
				},
				radius = 8,
				padding = 10,

				name = "workplaceCloseTimeInput",

				label = "Kapanış Saati",
				placeholder = "00:00",
				value = closeTimeValue,

				variant = "solid",
				color = "gray",

				textVariant = "body",
				textWeight = "regular",

				disabled = false,

				mask = false,
			})

			if openInput.value ~= openTimeValue then
				store.set("workplaceOpenTime", openInput.value)
			end
			if closeInput.value ~= closeTimeValue then
				store.set("workplaceCloseTime", closeInput.value)
			end
		end
	end
	
	-- Save button
	local saveButton = drawButton({
		position = {
			x = window.x,
			y = window.y + window.height - 50,
		},
		size = {
			x = window.width,
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
		disabled = false,
		
		text = "Kaydet",
		icon = "",
	})
	
	if saveButton.pressed then
		local newData = {}
		local checkboxStore = useStore("interiorSettings")
		
		-- Get checkbox values from Genel tab
		local checkboxSettings = { "lights", "ooc", "gps" }
		for k, v in ipairs(checkboxSettings) do
			-- Read from store where we saved checkbox state
			local storedValue = store.get("checkbox_" .. v)
			if storedValue ~= nil then
				newData[v] = storedValue == true
			else
				-- Fallback to settings data or default
				if settingsData[v] ~= nil then
					newData[v] = settingsData[v] ~= false and settingsData[v] ~= "false"
				else
					newData[v] = true
				end
			end
		end
		
		-- Get music settings
		local musicUrl = store.get("musicUrl")
		if musicUrl and musicUrl ~= "" then
			newData.musicUrl = musicUrl
		else
			-- Clear music URL if empty
			newData.musicUrl = ""
		end
		
		local musicVolume = tonumber(store.get("musicVolume") or 50) or 50
		if musicVolume < 0 then musicVolume = 0 end
		if musicVolume > 100 then musicVolume = 100 end
		newData.musicVolume = musicVolume

		-- Get workplace settings (0 / 1, url ve saatler) sadece işyeri sekmesi açıksa kaydet
		if showWorkplaceTab then
			-- isWorkplace flag
			if isBusinessType or settingsData.isWorkplace ~= nil then
				newData.isWorkplace = 1
			else
				newData.isWorkplace = 0
			end

			-- Active flag
			local activeValue = store.get("workplaceActive")
			if activeValue ~= nil then
				newData.workplaceActive = tonumber(activeValue) or 0
			end

			-- Logo / banner URL
			local logoUrl = store.get("workplaceLogoUrl")
			if logoUrl and logoUrl ~= "" then
				newData.workplaceLogoUrl = logoUrl
			end

			local bannerUrl = store.get("workplaceBannerUrl")
			if bannerUrl and bannerUrl ~= "" then
				newData.workplaceBannerUrl = bannerUrl
			end

			-- Çalışma saatleri
			local openTime = store.get("workplaceOpenTime")
			local closeTime = store.get("workplaceCloseTime")

			if openTime and openTime ~= "" then
				newData.workplaceOpenTime = openTime
			end
			if closeTime and closeTime ~= "" then
				newData.workplaceCloseTime = closeTime
			end
		end
		
		-- Get input values
		local newName = store.get("interiorName") or interiorName
		local newFee = tonumber(store.get("entranceFee")) or entranceFee
		-- Limit entrance fee to 500 and show error only once when saving
		if newFee > 500 then
			newFee = 500
			exports.mek_infobox:addBox("error", "Giriş ücreti maksimum 500 olabilir.")
			-- Update store to reflect the corrected value
			store.set("entranceFee", "500")
		end
		local newCost = tonumber(store.get("saleCost")) or interiorStatus.cost or 0
		
		-- Get furniture setting
		local furnitureStoredValue = store.get("checkbox_furniture")
		local newFurniture = false
		if furnitureStoredValue ~= nil then
			newFurniture = furnitureStoredValue == true
		else
			newFurniture = (interiorStatus.furniture == 1) or false
		end
		
		-- Get for sale setting
		local forSaleStoredValue = store.get("checkbox_forSale")
		local newForSale = false
		if forSaleStoredValue ~= nil then
			newForSale = forSaleStoredValue == true
		end
		
		-- Save settings
		triggerServerEvent(
			"interior.saveSettings",
			resourceRoot,
			interiorElement,
			interiorID,
			isVehicleInterior,
			newData,
			newName,
			newFee,
			newCost,
			newFurniture,
			newForSale
		)
		
		hidePage()
	end
end
