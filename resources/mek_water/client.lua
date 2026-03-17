local myShader
local timer

addEventHandler("onClientResourceStart", resourceRoot, function()
	if myShader then
		return
	end

	myShader = dxCreateShader("public/shaders/water.fx")

	if myShader then
		local textureVol = dxCreateTexture("public/images/smallnoise3d.dds")
		local textureCube = dxCreateTexture("public/images/cube_env256.dds")
		dxSetShaderValue(myShader, "microflakeNMapVol_Tex", textureVol)
		dxSetShaderValue(myShader, "showroomMapCube_Tex", textureCube)

		engineApplyShaderToWorldTexture(myShader, "waterclear256")

		timer = setTimer(function()
			if myShader then
				local r, g, b, a = getWaterColor()
				dxSetShaderValue(myShader, "gWaterColor", r / 255, g / 255, b / 255, a / 255)
			end
		end, 5000, 0)
	end
end)
