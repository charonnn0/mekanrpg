screenSize = Vector2(guiGetScreenSize())

Loading = {}
Loading.fonts = {}
Loading.fonts.Regular = dxCreateFont(":mek_ui/public/fonts/ProximaNovaRegular.ttf", respc(16)) or "default"
Loading.fonts.Bold = dxCreateFont(":mek_ui/public/fonts/ProximaNovaBold.ttf", respc(16)) or "default"
Loading.visible = false
Loading.outerPadding = resp(50)
Loading.containerPosition = {
	x = Loading.outerPadding,
	y = Loading.outerPadding * 3,
}
Loading.progressSize = {
	x = resp(741),
	y = 15,
}
Loading.progressPosition = {
	x = screenSize.x / 2 - Loading.progressSize.x / 2,
	y = screenSize.y - Loading.outerPadding - Loading.progressSize.y,
}
Loading.sprites = {
	progress_fg = svgCreate(Loading.progressSize.x, Loading.progressSize.y, "public/images/progress-fg.svg"),
	progress_bg = svgCreate(Loading.progressSize.x, Loading.progressSize.y, "public/images/progress-bg.svg"),
	background_in = svgCreate(screenSize.x, 250, "public/images/background-in.svg"),
}
Loading.carShaderSource =
	" texture renderTexture; sampler renderSampler = sampler_state { Texture = <renderTexture>; }; texture wireTexture; sampler wireSampler = sampler_state { Texture = <wireTexture>; }; float prog = 0; float feather = 0.1; float4 PixelShaderFunction(float4 Diffuse : COLOR0, float2 TexCoord : TEXCOORD0) : COLOR0 { float4 render = tex2D(renderSampler, TexCoord); float4 wire = tex2D(wireSampler, TexCoord); if(TexCoord.x > prog) return wire; else if(TexCoord.x > prog-feather) { float p = (TexCoord.x - (prog-feather))/feather; return lerp(wire, render, 1-p*p); } else return render; } technique Technique1 { pass Pass1 { PixelShader = compile ps_2_0 PixelShaderFunction(); } } "
Loading.skinShaderSource =
	" texture renderTexture; sampler renderSampler = sampler_state { Texture = <renderTexture>; }; texture wireTexture; sampler wireSampler = sampler_state { Texture = <wireTexture>; }; texture cloudTexture; sampler cloudSampler = sampler_state { Texture = <cloudTexture>; }; float prog = 0; float feather = 0.1; float4 PixelShaderFunction(float4 Diffuse : COLOR0, float2 TexCoord : TEXCOORD0) : COLOR0 { float4 render = tex2D(renderSampler, TexCoord); float4 wire = tex2D(wireSampler, TexCoord); float4 cloud = tex2D(cloudSampler, TexCoord); float c = 1-cloud.r; if(c > prog) return wire; else if(c > prog-feather) { float p = (c - (prog-feather))/feather; return lerp(wire, render, 1-p*p); } else return render; } technique Technique1 { pass Pass1 { PixelShader = compile ps_2_0 PixelShaderFunction(); } } "
Loading.enums = {}
Loading.enums.elements = {
	Cars = "cars",
	Skins = "skins",
}
Loading.currentElement = Loading.enums.elements.Skins
Loading.currentElementIndex = 1
Loading.elementCounts = {
	[Loading.enums.elements.Cars] = 3,
	[Loading.enums.elements.Skins] = 5,
}
Loading.progresses = {
	[Loading.enums.elements.Cars] = { 0, 0 },
	[Loading.enums.elements.Skins] = { 0, 0 },
}
Loading.progressTickCount = 0
Loading.percentage = 25
Loading.downloaded = 0
Loading.total = 0
theme = {
	BLACK = "#000000",
	GRAY = "#BDBDBD",
	WHITE = "#FFFFFF",
}
Loading.music = nil

function Loading.renderElements()
	if getTickCount() - Loading.progressTickCount > 5 then
		Loading.progressTickCount = getTickCount()
		Loading.progresses[Loading.currentElement][1] =
			math.min(Loading.progresses[Loading.currentElement][1] + 0.1, 100)
		if Loading.progresses[Loading.currentElement][1] == 100 then
			Loading.progresses[Loading.currentElement][2] =
				math.min(Loading.progresses[Loading.currentElement][2] + 1, 255)
			if Loading.progresses[Loading.currentElement][2] == 255 then
				Loading.currentElementIndex = Loading.currentElementIndex + 1
				Loading.progresses[Loading.currentElement][1] = 0
				Loading.progresses[Loading.currentElement][2] = 0
				if Loading.currentElementIndex > Loading.elementCounts[Loading.currentElement] then
					Loading.currentElementIndex = 1
					Loading.currentElement = Loading.currentElement == Loading.enums.elements.Cars
							and Loading.enums.elements.Skins
						or Loading.enums.elements.Cars
				elseif Loading.currentElement == Loading.enums.elements.Cars then
					Loading.carShader:setValue("prog", 0)
					Loading.carShader:setValue(
						"wireTexture",
						Loading.elementSprites.car[Loading.currentElementIndex].wireframe
					)
					Loading.carShader:setValue(
						"renderTexture",
						Loading.elementSprites.car[Loading.currentElementIndex].render
					)
				else
					Loading.skinShader:setValue("prog", 0)
					Loading.skinShader:setValue(
						"wireTexture",
						Loading.elementSprites.skin[Loading.currentElementIndex].wireframe
					)
					Loading.skinShader:setValue(
						"renderTexture",
						Loading.elementSprites.skin[Loading.currentElementIndex].render
					)
				end
			end
		end
	end

	if Loading.currentElement == Loading.enums.elements.Cars then
		Loading.carShader:setValue("prog", Loading.progresses[Loading.currentElement][1] / 100)
		dxDrawImage(
			({
				x = screenSize.x / 2 - ({
					x = screenSize.x,
					y = screenSize.x * 0.5625,
				}).x / 2,
				y = screenSize.y / 2 - ({
					x = screenSize.x,
					y = screenSize.x * 0.5625,
				}).y / 2,
			}).x,
			({
				x = screenSize.x / 2 - ({
					x = screenSize.x,
					y = screenSize.x * 0.5625,
				}).x / 2,
				y = screenSize.y / 2 - ({
					x = screenSize.x,
					y = screenSize.x * 0.5625,
				}).y / 2,
			}).y,
			({
				x = screenSize.x,
				y = screenSize.x * 0.5625,
			}).x,
			({
				x = screenSize.x,
				y = screenSize.x * 0.5625,
			}).y,
			Loading.carShader
		)

		if Loading.progresses[Loading.currentElement][1] == 100 then
			dxDrawImage(
				({
					x = screenSize.x / 2 - ({
						x = screenSize.x,
						y = screenSize.x * 0.5625,
					}).x / 2,
					y = screenSize.y / 2 - ({
						x = screenSize.x,
						y = screenSize.x * 0.5625,
					}).y / 2,
				}).x,
				({
					x = screenSize.x / 2 - ({
						x = screenSize.x,
						y = screenSize.x * 0.5625,
					}).x / 2,
					y = screenSize.y / 2 - ({
						x = screenSize.x,
						y = screenSize.x * 0.5625,
					}).y / 2,
				}).y,
				({
					x = screenSize.x,
					y = screenSize.x * 0.5625,
				}).x,
				({
					x = screenSize.x,
					y = screenSize.x * 0.5625,
				}).y,
				Loading.elementSprites.car[Loading.currentElementIndex].lights,
				0,
				0,
				0,
				tocolor(255, 255, 255, Loading.progresses[Loading.currentElement][2])
			)
		end
	else
		Loading.skinShader:setValue("prog", Loading.progresses[Loading.currentElement][1] / 100)
		dxDrawImage(
			({
				x = screenSize.x / 2 - screenSize.y / 2,
				y = 0,
			}).x,
			({
				x = screenSize.x / 2 - screenSize.y / 2,
				y = 0,
			}).y,
			({
				x = screenSize.y,
				y = screenSize.y,
			}).x,
			({
				x = screenSize.y,
				y = screenSize.y,
			}).y,
			Loading.skinShader
		)
	end
end

function Loading.renderBackground()
	dxDrawImage(0, 0, screenSize.x, screenSize.y, "public/images/background.png")
	Loading.renderElements()
end

function Loading.renderProgress(color)
	dxDrawImage(
		Loading.progressPosition.x,
		Loading.progressPosition.y,
		Loading.progressSize.x,
		Loading.progressSize.y,
		Loading.sprites.progress_bg
	)
	dxDrawImageSection(
		Loading.progressPosition.x,
		Loading.progressPosition.y,
		Loading.percentage / 100 * Loading.progressSize.x,
		Loading.progressSize.y,
		0,
		0,
		Loading.percentage / 100 * Loading.progressSize.x,
		Loading.progressSize.y,
		Loading.sprites.progress_fg
	)
	dxDrawImage(
		Loading.progressPosition.x - 20,
		Loading.progressPosition.y - 20,
		Loading.progressSize.x + 40,
		Loading.progressSize.y + 40,
		"public/images/progress-shade.png"
	)
	dxDrawText(
		"Sistemler yükleniyor",
		Loading.progressPosition.x,
		Loading.progressPosition.y - resp(35),
		0,
		0,
		rgba(theme[color], 1),
		1,
		Loading.fonts.Bold
	)
	dxDrawText(
		"İndirme İşlemi",
		Loading.progressPosition.x,
		Loading.progressPosition.y - resp(55),
		0,
		0,
		rgba(theme[color], 0.57),
		0.7,
		Loading.fonts.Regular
	)
	dxDrawText(
		Loading.downloaded .. "mb/" .. Loading.total .. "mb",
		Loading.progressPosition.x,
		Loading.progressPosition.y - resp(25),
		Loading.progressSize.x + Loading.progressPosition.x,
		0,
		rgba(theme[color], 0.7),
		0.6,
		Loading.fonts.Regular,
		"right"
	)
end

function Loading.render()
	if not Loading.visible then
		return
	end

	if not localPlayer:getData("logged") then
		Loading.renderBackground()
	else
		dxDrawImage(0, screenSize.y - 250, screenSize.x, 250, Loading.sprites.background_in)
	end

	Loading.renderProgress("WHITE")
end
addEventHandler("onClientRender", root, Loading.render, true, "high-9999")

function Loading.hide()
	Loading.visible = false
end

function Loading.show()
	if not localPlayer:getData("logged") then
		showChat(false)
	end

	setTransferBoxVisible(false)
	Loading.visible = true
end

addEventHandler("onClientResourceStart", root, function(startedRes)
	if startedRes == getThisResource() then
		Loading.elementSprites = {
			car = {
				[1] = {
					render = dxCreateTexture("public/images/cars/car_render1.dds", "dxt5", true),
					wireframe = dxCreateTexture("public/images/cars/car_render1_wireframe.dds", "dxt5", true),
					lights = dxCreateTexture("public/images/cars/car_render1_lights.dds", "dxt5", true),
				},
				[2] = {
					render = dxCreateTexture("public/images/cars/car_render2.dds", "dxt5", true),
					wireframe = dxCreateTexture("public/images/cars/car_render2_wireframe.dds", "dxt5", true),
					lights = dxCreateTexture("public/images/cars/car_render2_lights.dds", "dxt5", true),
				},
				[3] = {
					render = dxCreateTexture("public/images/cars/car_render3.dds", "dxt5", true),
					wireframe = dxCreateTexture("public/images/cars/car_render3_wireframe.dds", "dxt5", true),
					lights = dxCreateTexture("public/images/cars/car_render3_lights.dds", "dxt5", true),
				},
			},
			skin = {
				[1] = {
					render = dxCreateTexture("public/images/skins/skins1.dds", "dxt5", true),
					wireframe = dxCreateTexture("public/images/skins/skins1_wireframe.dds", "dxt5", true),
				},
				[2] = {
					render = dxCreateTexture("public/images/skins/skins2.dds", "dxt5", true),
					wireframe = dxCreateTexture("public/images/skins/skins2_wireframe.dds", "dxt5", true),
				},
				[3] = {
					render = dxCreateTexture("public/images/skins/skins3.dds", "dxt5", true),
					wireframe = dxCreateTexture("public/images/skins/skins3_wireframe.dds", "dxt5", true),
				},
				[4] = {
					render = dxCreateTexture("public/images/skins/skins4.dds", "dxt5", true),
					wireframe = dxCreateTexture("public/images/skins/skins4_wireframe.dds", "dxt5", true),
				},
				[5] = {
					render = dxCreateTexture("public/images/skins/skins5.dds", "dxt5", true),
					wireframe = dxCreateTexture("public/images/skins/skins5_wireframe.dds", "dxt5", true),
				},
			},
			cloud = dxCreateTexture("public/images/skins/skins_noise.dds", "dxt5", true),
		}

		Loading.carShader = dxCreateShader(Loading.carShaderSource)
		Loading.carShader:setValue("wireTexture", Loading.elementSprites.car[Loading.currentElementIndex].wireframe)
		Loading.carShader:setValue("renderTexture", Loading.elementSprites.car[Loading.currentElementIndex].render)
		Loading.carShader:setValue("prog", 0)
		Loading.skinShader = dxCreateShader(Loading.skinShaderSource)
		Loading.skinShader:setValue("wireTexture", Loading.elementSprites.skin[Loading.currentElementIndex].wireframe)
		Loading.skinShader:setValue("renderTexture", Loading.elementSprites.skin[Loading.currentElementIndex].render)
		Loading.skinShader:setValue("cloudTexture", Loading.elementSprites.cloud)
		Loading.skinShader:setValue("prog", 0)

		if isTransferBoxVisible() then
			Loading.show()
		end

		return
	end
	Loading.hide()
end)

addEventHandler("onClientTransferBoxProgressChange", root, function(downloadedSize, totalSize)
	Loading.percentage = math.floor(math.min(downloadedSize / totalSize * 100, 100))
	Loading.downloaded = string.format("%.2f", downloadedSize / 1024 / 1024)
	Loading.total = string.format("%.2f", totalSize / 1024 / 1024)
	if not Loading.visible then
		Loading.show()
	end
end)
