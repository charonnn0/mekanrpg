function applyTextureToArtifact(object, texData)
	if object and isElement(object) and texData then
		for k, v in ipairs(texData) do
			local path = v[1]
			local name = v[2]
			local shader, tec = dxCreateShader("public/shaders/texreplace.fx", 2, 0, true, "object")
			local tex = dxCreateTexture("public/images/" .. tostring(path))
			engineApplyShaderToWorldTexture(shader, tostring(name), object)
			dxSetShaderValue(shader, "gTexture", tex)
		end
	end
end
addEvent("artifacts.addTexture", true)
addEventHandler("artifacts.addTexture", root, applyTextureToArtifact)

function applyTexturesToAllArtifacts(textable)
	if textable then
		for k, v in ipairs(textable) do
			applyTextureToArtifact(v[1], v[2])
		end
	end
end
addEvent("artifacts.addAllTextures", true)
addEventHandler("artifacts.addAllTextures", root, applyTexturesToAllArtifacts)
