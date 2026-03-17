local outlinedElements = {}

local serverColor = getServerColor(3)
local elementColorize = { serverColor[1] / 255, serverColor[2] / 255, serverColor[3] / 255, 1 }

local specularPower = 1.3

function createOutline(element, isMRT)
	assert(isElement(element), "Bad argument @ 'createOutline' [element expected, got " .. type(element) .. "]")

	if not isElementStreamedIn(element) then
		return false
	end

	if outlinedElements[element] then
		return false
	end

	local shader = dxCreateShader(isMRT and "public/shaders/wall_mrt.fx" or "public/shaders/wall.fx", 1, 0, true, "all")

	if not shader then
		return
	end

	dxSetShaderValue(shader, "sColorizePed", elementColorize)
	dxSetShaderValue(shader, "sSpecularPower", specularPower)
	engineApplyShaderToWorldTexture(shader, "*", element)
	engineRemoveShaderFromWorldTexture(shader, "muzzle_texture*", element)

	outlinedElements[element] = {
		shader = shader,
		isMRT = isMRT,
		color = elementColorize,
	}

	if not isMRT then
		element:setAlpha(254)
	end
end

function destroyOutline(element)
	assert(isElement(element), "Bad argument @ 'destroyOutline' [element expected, got " .. type(element) .. "]")

	if not outlinedElements[element] then
		return false
	end

	local outline = outlinedElements[element]

	if isElement(outline.shader) then
		destroyElement(outline.shader)
	end

	outlinedElements[element] = nil

	if not outline.isMRT then
		element:setAlpha(255)
	end
end
