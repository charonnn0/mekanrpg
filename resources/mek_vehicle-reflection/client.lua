Settings = {}
Settings.var = {}

VehicleLights = {
	textures = {
		{ "public/images/vehiclelights128.png", "vehiclelights128" },
		{ "public/images/vehiclelightson128.png", "vehiclelightson128" },
	},

	index = function(self)
		for i = 1, #self.textures do
			local shader = DxShader("public/shaders/texture_replace.fx")
			shader:applyToWorldTexture(self.textures[i][2])
			shader:setValue("gTexture", DxTexture(self.textures[i][1]))
		end
	end,
}
VehicleLights:index()

function setcpRLEffectVehicle()
	Settings.var.renderDistance = 60
	Settings.var.brightnessFactorPaint = 0.022
	Settings.var.brightnessFactorWShield = 0.099
	Settings.var.bumpSize = 0.5
	Settings.var.bumpSizeWnd = 0
	Settings.var.normal = 1
	Settings.var.bumpIntensity = { 0.25, 0.25 }
	Settings.var.minZviewAngleFade = -0.5
	Settings.var.brightnessAdd = { 0.5, 0.5 }
	Settings.var.brightnessMul = { 1.2, 1.5 }
	Settings.var.brightpassCutoff = { 0.16, 0.16 }
	Settings.var.brightpassPower = { 2.5, 2.0 }
	Settings.var.uvMul = { 1.5, 1.5 }
	Settings.var.uvMov = { 0, 0 }
	Settings.var.skyLightIntensity = 1
	Settings.var.filmDepth = 0.03
	Settings.var.filmIntensity = 0.051
	Settings.var.isEffectlayered = { false, false }
	Settings.var.scXY = { guiGetScreenSize() }
	Settings.var.envIntensity = { 0.35, 0.55 }
	Settings.var.specularValue = { 0.0, 0.0 }
	Settings.var.refTexValue = { 0.1, 0.1 }
end

local texturegrun = {
	"predator92body128",
	"monsterb92body256a",
	"monstera92body256a",
	"andromeda92wing",
	"fcr90092body128",
	"hotknifebody128b",
	"hotknifebody128a",
	"rcbaron92texpage64",
	"rcgoblin92texpage128",
	"rcraider92texpage128",
	"rctiger92body128",
	"rhino92texpage256",
	"petrotr92interior128",
	"artict1logos",
	"rumpo92adverts256",
	"dash92interior128",
	"coach92interior128",
	"combinetexpage128",
	"policemiami86body128",
	"remap_body",
	"remap",
	"policemiami868bit128",
	"hotdog92body256",
	"raindance92body128",
	"cargobob92body256",
	"andromeda92body",
	"at400_92_256",
	"body",
	"chassis",
	"nevada92body256",
	"polmavbody128a",
	"sparrow92body128",
	"hunterbody8bit256a",
	"seasparrow92floats64",
	"dodo92body8bit256",
	"cropdustbody256",
	"beagle256",
	"hydrabody256",
	"hydra128",
	"hydradecal",
	"rustler92body256",
	"shamalbody256",
	"skimmer92body128",
	"stunt256",
	"maverick92body128",
	"leviathnbody8bit256",
}

function startCarPaintRefLite()
	if cpRLEffectEnabled then
		return
	end
	local v = Settings.var
	setcpRLEffectVehicle()

	local layerString = ""
	if v.isEffectlayered[1] then
		layerString = "_layer"
	else
		layerString = ""
	end
	paintShader, tec = dxCreateShader(
		"public/shaders/car_paint" .. layerString .. ".fx",
		2,
		v.renderDistance,
		v.isEffectlayered[1],
		"vehicle"
	)
	myScreenSource = dxCreateScreenSource(v.scXY[1], v.scXY[2])
	if v.isEffectlayered[2] then
		layerString = "_layer"
	else
		layerString = ""
	end
	glassShader, tec = dxCreateShader(
		"public/shaders/car_glass" .. layerString .. ".fx",
		2,
		v.renderDistance,
		v.isEffectlayered[2],
		"vehicle"
	)
	shatterShader, tec = dxCreateShader(
		"public/shaders/car_glass" .. layerString .. ".fx",
		2,
		v.renderDistance,
		v.isEffectlayered[2],
		"vehicle"
	)

	textureVol = dxCreateTexture("public/images/smallnoise3d.dds")
	if paintShader and glassShader and shatterShader and textureVol and myScreenSource then
		addEventHandler("onClientRender", root, updateScreen)

		dxSetShaderValue(paintShader, "sRandomTexture", textureVol)
		dxSetShaderValue(paintShader, "sReflectionTexture", myScreenSource)
		dxSetShaderValue(glassShader, "sReflectionTexture", myScreenSource)
		dxSetShaderValue(shatterShader, "sReflectionTexture", myScreenSource)

		dxSetShaderValue(paintShader, "sNorFac", v.normal)
		dxSetShaderValue(paintShader, "uvMul", v.uvMul[1], v.uvMul[2])
		dxSetShaderValue(paintShader, "uvMov", v.uvMov[1], v.uvMov[2])
		dxSetShaderValue(paintShader, "bumpSize", v.bumpSize)
		dxSetShaderValue(paintShader, "bumpIntensity", v.bumpIntensity[1])
		dxSetShaderValue(paintShader, "envIntensity", v.envIntensity[1])
		dxSetShaderValue(paintShader, "specularValue", v.specularValue[1])
		dxSetShaderValue(paintShader, "refTexValue", v.refTexValue[1])

		dxSetShaderValue(paintShader, "sPower", v.brightpassPower[1])
		dxSetShaderValue(paintShader, "sAdd", v.brightnessAdd[1])
		dxSetShaderValue(paintShader, "sMul", v.brightnessMul[1])
		dxSetShaderValue(paintShader, "sCutoff", v.brightpassCutoff[1])

		dxSetShaderValue(glassShader, "sNorFac", v.normal)
		dxSetShaderValue(glassShader, "uvMul", v.uvMul[1], v.uvMul[2])
		dxSetShaderValue(glassShader, "uvMov", v.uvMov[1], v.uvMov[2])
		dxSetShaderValue(glassShader, "bumpIntensity", v.bumpIntensity[2])
		dxSetShaderValue(glassShader, "envIntensity", v.envIntensity[2])
		dxSetShaderValue(glassShader, "specularValue", v.specularValue[2])
		dxSetShaderValue(glassShader, "refTexValue", v.refTexValue[2])

		dxSetShaderValue(glassShader, "sPower", v.brightpassPower[2])
		dxSetShaderValue(glassShader, "sAdd", v.brightnessAdd[2])
		dxSetShaderValue(glassShader, "sMul", v.brightnessMul[2])
		dxSetShaderValue(glassShader, "sCutoff", v.brightpassCutoff[2])
		dxSetShaderValue(glassShader, "isShatter", false)

		dxSetShaderValue(shatterShader, "sNorFac", v.normal)
		dxSetShaderValue(shatterShader, "uvMul", v.uvMul[1], v.uvMul[2])
		dxSetShaderValue(shatterShader, "uvMov", v.uvMov[1], v.uvMov[2])
		dxSetShaderValue(shatterShader, "bumpIntensity", v.bumpIntensity[2])
		dxSetShaderValue(shatterShader, "envIntensity", v.envIntensity[2])
		dxSetShaderValue(shatterShader, "specularValue", v.specularValue[2])
		dxSetShaderValue(shatterShader, "refTexValue", v.refTexValue[2])

		dxSetShaderValue(shatterShader, "sPower", v.brightpassPower[2])
		dxSetShaderValue(shatterShader, "sAdd", v.brightnessAdd[2])
		dxSetShaderValue(shatterShader, "sMul", v.brightnessMul[2])
		dxSetShaderValue(shatterShader, "sCutoff", v.brightpassCutoff[2])
		dxSetShaderValue(shatterShader, "isShatter", true)

		engineApplyShaderToWorldTexture(paintShader, "vehiclegrunge256")
		engineApplyShaderToWorldTexture(paintShader, "?emap*")
		engineApplyShaderToWorldTexture(glassShader, "vehiclegeneric256")
		engineApplyShaderToWorldTexture(shatterShader, "vehicleshatter128")

		for _, addList in ipairs(texturegrun) do
			engineApplyShaderToWorldTexture(paintShader, addList)
		end
		cpRLEffectEnabled = true
	else
		outputChatBox(
			"Could not draw vehicle reflection shader, most likely your GPU (shader model) doesn't support it, or has driver issues.",
			255,
			0,
			0
		)
		return
	end
end

function stopCarPaintRefLite()
	if not cpRLEffectEnabled then
		return
	end
	removeEventHandler("onClientRender", root, updateScreen)
	engineRemoveShaderFromWorldTexture(paintShader, "*")
	destroyElement(paintShader)
	paintShader = nil
	engineRemoveShaderFromWorldTexture(glassShader, "*")
	destroyElement(glassShader)
	glassShader = nil
	engineRemoveShaderFromWorldTexture(shatterShader, "*")
	destroyElement(shatterShader)
	shatterShader = nil
	destroyElement(textureVol)
	textureVol = nil
	destroyElement(myScreenSource)
	myScreenSource = nil
	cpRLEffectEnabled = false
end

function updateScreen()
	if myScreenSource then
		dxUpdateScreenSource(myScreenSource)
	end
end

function switchCarPaintRefLite(isCPRefOn)
	if isCPRefOn then
		startCarPaintRefLite()
	else
		stopCarPaintRefLite()
	end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
	if exports.mek_settings:getPlayerSetting(localPlayer, "vehicle_reflection") then
		switchCarPaintRefLite(true)
	end
end)
