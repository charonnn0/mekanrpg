local shaders = {}

function createShader(name)
	if not shaders[sourceResource] then
		shaders[sourceResource] = {}
	end

	if shaders[sourceResource][name] then
		return shaders[sourceResource][name]
	end

	local shader = dxCreateShader("public/shaders/" .. name)
	shaders[sourceResource][name] = shader

	return shader
end
