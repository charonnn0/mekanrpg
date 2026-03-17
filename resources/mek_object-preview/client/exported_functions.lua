function createObjectPreview(objElement, rotX, rotY, rotZ, projPosX, projPosY, projSizeX, projSizeY, ...)
	if not isElement(objElement) then
		return false
	end
	local elementType = getElementType(objElement)
	if not elementType == "vehicle" and not elementType == "object" and not elementType == "ped" then
		return false
	end
	local reqParam = { rotX, rotY, rotZ, projPosX, projPosY, projSizeX, projSizeY }
	local isThisValid = true
	local countParam = 0
	for m, param in ipairs(reqParam) do
		countParam = countParam + 1
		isThisValid = isThisValid and param ~= nil and (type(param) == "number")
	end
	local optParam = { ... }
	if not isThisValid or (#optParam > 3 or #reqParam ~= 7) or (countParam ~= 7) then
		return false
	end
	local isRelative, postGui, isSecRT, isAtt = false, false, true, false
	if #optParam > 0 then
		if type(optParam[1]) == "boolean" then
			isRelative = optParam[1]
		end
	end
	if #optParam > 1 then
		if type(optParam[2]) == "boolean" then
			postGui = optParam[2]
		end
	end
	if #optParam > 2 then
		if type(optParam[3]) == "boolean" then
			isSecRT = optParam[3]
		end
	end
	if #optParam > 3 then
		if type(optParam[4]) == "boolean" then
			isAtt = optParam[4]
		end
	end
	local thisObj = objectPreview:create(
		objElement,
		rotX,
		rotY,
		rotZ,
		projPosX,
		projPosY,
		projSizeX,
		projSizeY,
		isRelative,
		postGui,
		isSecRT,
		isAtt
	)
	if thisObj and true then
		return createElement("SOVelement", tostring(thisObj:getID()))
	else
		return false
	end
end

function destroyObjectPreview(w)
	if not isElement(w) then
		return false
	end
	local SOVelementID = tonumber(getElementID(w))
	local isThisValid = (type(SOVelementID) == "number") and true
	if isThisValid then
		isThisValid = false
		if refOPTable[SOVelementID] then
			if refOPTable[SOVelementID].enabled then
				local instance = refOPTable[SOVelementID].instance
				if instance then
					return instance:destroy()
				end
			end
		end
		return false
	else
		return false
	end
end

function createTextureReplace(w, texElement, texName)
	if not isElement(w) then
		return false
	end
	local SOVelementID = tonumber(getElementID(w))
	local reqParam = { SOVelementID, texElement, texName }
	local isThisValid = true
	local countParam = 0
	for m, param in ipairs(reqParam) do
		countParam = countParam + 1
	end
	isThisValid = isThisValid and (type(texName) == "string") and (type(SOVelementID) == "number")
	if isElement(texElement) then
		if not (getElementType(texElement) == "texture") then
			isThisValid = false
		end
	else
		isThisValid = false
	end
	if isThisValid and (countParam == 3) then
		if refOPTable[SOVelementID] then
			if refOPTable[SOVelementID].enabled then
				local instance = refOPTable[SOVelementID].instance
				if instance then
					return instance:createTextureReplace(texElement, texName)
				end
			end
			return false
		end
		return false
	else
		return false
	end
end

function setTextureReplaceTexture(w, elementNr, texElement)
	if not isElement(w) then
		return false
	end
	local SOVelementID = tonumber(getElementID(w))
	local reqParam = { SOVelementID, elementNr, texElement }
	local isThisValid = true
	local countParam = 0
	for m, param in ipairs(reqParam) do
		countParam = countParam + 1
	end
	isThisValid = isThisValid and (type(elementNr) == "number") and (type(SOVelementID) == "number")
	if isElement(texElement) then
		if not (getElementType(texElement) == "texture") then
			isThisValid = false
		end
	else
		isThisValid = false
	end
	if isThisValid and (countParam == 3) then
		if refOPTable[SOVelementID] then
			if refOPTable[SOVelementID].enabled then
				local instance = refOPTable[SOVelementID].instance
				if instance then
					return instance:setTextureReplaceTexture(elementNr, texElement)
				end
			end
			return false
		end
		return false
	else
		return false
	end
end

function destroyTextureReplace(w, elementNr)
	if not isElement(w) then
		return false
	end
	local SOVelementID = tonumber(getElementID(w))
	local reqParam = { SOVelementID, elementNr }
	local isThisValid = true
	local countParam = 0
	for m, param in ipairs(reqParam) do
		countParam = countParam + 1
	end
	isThisValid = isThisValid and (type(elementNr) == "number") and (type(SOVelementID) == "number")
	if isThisValid and (countParam == 2) then
		if refOPTable[SOVelementID] then
			if refOPTable[SOVelementID].enabled then
				local instance = refOPTable[SOVelementID].instance
				if instance then
					return instance:destroyTextureReplace(elementNr)
				end
			end
			return false
		end
		return false
	else
		return false
	end
end

function saveRTToFile(w, filePath)
	if not isElement(w) then
		return false
	end
	if not dxGetStatus().AllowScreenUpload then
		return false
	end
	if type(filePath) ~= "string" then
		return false
	end
	local SOVelementID = tonumber(getElementID(w))
	local lastBit = #filePath
	local texExt = string.sub(filePath, lastBit - 3, lastBit)
	if texExt ~= ".png" then
		return false
	end
	local texName = string.sub(filePath, string.len(1, lastBit - 4))
	if #texName < 1 then
		return false
	end
	local outPath = ":" .. getResourceName(sourceResource) .. "/" .. filePath
	if refOPTable[SOVelementID] then
		if refOPTable[SOVelementID].enabled then
			local instance = refOPTable[SOVelementID].instance
			if instance then
				return instance:saveToFile(outPath)
			end
		end
		return false
	else
		return false
	end
end

function setRotation(w, rotX, rotY, rotZ)
	if not isElement(w) then
		return false
	end
	local SOVelementID = tonumber(getElementID(w))
	local reqParam = { SOVelementID, rotX, rotY, rotZ }
	local isThisValid = true
	local countParam = 0
	for m, param in ipairs(reqParam) do
		countParam = countParam + 1
		isThisValid = isThisValid and param and (type(param) == "number")
	end
	if isThisValid and (countParam == 4) then
		if refOPTable[SOVelementID] then
			if refOPTable[SOVelementID].enabled then
				local instance = refOPTable[SOVelementID].instance
				if instance then
					return instance:setRotation(rotX, rotY, rotZ)
				end
			end
			return false
		end
		return false
	else
		return false
	end
end

function setProjection(w, projPosX, projPosY, projSizeX, projSizeY, ...)
	if not isElement(w) then
		return false
	end
	local SOVelementID = tonumber(getElementID(w))
	local reqParam = { SOVelementID, projPosX, projPosY, projSizeX, projSizeY }
	local isThisValid = true
	local countParam = 0
	for m, param in ipairs(reqParam) do
		countParam = countParam + 1
		isThisValid = isThisValid and param and (type(param) == "number")
	end
	local optParam = { ... }
	if not isThisValid or (#optParam > 2 or #reqParam ~= 5) or (countParam ~= 5) then
		return false
	end
	local isRelative, postGui = false, false
	if #optParam > 0 then
		if type(optParam[1]) == "boolean" then
			isRelative = optParam[1]
		end
	end
	if #optParam > 1 then
		if type(optParam[2]) == "boolean" then
			postGui = optParam[2]
		end
	end
	if refOPTable[SOVelementID] then
		if refOPTable[SOVelementID].enabled then
			local instance = refOPTable[SOVelementID].instance
			if instance then
				return instance:setProjection(projPosX, projPosY, projSizeX, projSizeY, postGui, isRelative)
			end
		end
		return false
	else
		return false
	end
end

function setDistanceSpread(w, zSpread)
	if not isElement(w) then
		return false
	end
	local SOVelementID = tonumber(getElementID(w))
	local reqParam = { SOVelementID, zSpread }
	local isThisValid = true
	local countParam = 0
	for m, param in ipairs(reqParam) do
		countParam = countParam + 1
		isThisValid = isThisValid and param and (type(param) == "number")
	end
	if isThisValid and (countParam == 2) then
		if refOPTable[SOVelementID] then
			if refOPTable[SOVelementID].enabled then
				local instance = refOPTable[SOVelementID].instance
				if instance then
					return instance:setDistanceSpread(zSpread)
				end
			end
			return false
		else
			return false
		end
	else
		return false
	end
end

function setPositionOffsets(w, offsX, offsY, offsZ)
	if not isElement(w) then
		return false
	end
	local SOVelementID = tonumber(getElementID(w))
	local reqParam = { SOVelementID, offsX, offsY, offsZ }
	local isThisValid = true
	local countParam = 0
	for m, param in ipairs(reqParam) do
		countParam = countParam + 1
		isThisValid = isThisValid and param and (type(param) == "number")
	end
	if isThisValid and (countParam == 4) then
		if refOPTable[SOVelementID] then
			if refOPTable[SOVelementID].enabled then
				local instance = refOPTable[SOVelementID].instance
				if instance then
					return instance:setPositionOffsets(offsX, offsY, offsZ)
				end
			end
			return false
		else
			return false
		end
	else
		return false
	end
end

function setRotationOffsets(w, offsX, offsY, offsZ)
	if not isElement(w) then
		return false
	end
	local SOVelementID = tonumber(getElementID(w))
	local reqParam = { SOVelementID, offsX, offsY, offsZ }
	local isThisValid = true
	local countParam = 0
	for m, param in ipairs(reqParam) do
		countParam = countParam + 1
		isThisValid = isThisValid and param and (type(param) == "number")
	end
	if isThisValid and (countParam == 4) then
		if refOPTable[SOVelementID] then
			if refOPTable[SOVelementID].enabled then
				local instance = refOPTable[SOVelementID].instance
				if instance then
					return instance:setRotationOffsets(offsX, offsY, offsZ)
				end
			end
			return false
		else
			return false
		end
	else
		return false
	end
end

function setAlpha(w, alphaValue)
	if not isElement(w) then
		return false
	end
	local SOVelementID = tonumber(getElementID(w))
	local isThisValid = (type(SOVelementID) == "number") and (type(alphaValue) == "number") and true
	if isThisValid then
		if refOPTable[SOVelementID] then
			if refOPTable[SOVelementID].enabled then
				local instance = refOPTable[SOVelementID].instance
				if instance then
					return instance:setAlpha(alphaValue)
				end
			end
			return false
		else
			return false
		end
	else
		return false
	end
end

function setAttached(w, isAtt)
	if not isElement(w) then
		return false
	end
	local SOVelementID = tonumber(getElementID(w))
	local isThisValid = (type(SOVelementID) == "number") and (type(isAtt) == "boolean") and true
	if isThisValid then
		if refOPTable[SOVelementID] then
			if refOPTable[SOVelementID].enabled then
				local instance = refOPTable[SOVelementID].instance
				if instance then
					return instance:setAttached(isAtt)
				end
			end
			return false
		else
			return false
		end
	else
		return false
	end
end

function setVisible(w, isVis)
	if not isElement(w) then
		return false
	end
	local SOVelementID = tonumber(getElementID(w))
	local isThisValid = (type(SOVelementID) == "number") and (type(isVis) == "boolean") and true
	if isThisValid then
		if refOPTable[SOVelementID] then
			if refOPTable[SOVelementID].enabled then
				local instance = refOPTable[SOVelementID].instance
				if instance then
					return instance:setVisible(isVis)
				end
			end
			return false
		else
			return false
		end
	else
		return false
	end
end

function isVisible(w)
	if not isElement(w) then
		return false
	end
	local SOVelementID = tonumber(getElementID(w))
	local isThisValid = (type(SOVelementID) == "number") and true
	if isThisValid then
		if refOPTable[SOVelementID] then
			if refOPTable[SOVelementID].enabled then
				local instance = refOPTable[SOVelementID].instance
				if instance then
					return instance:isVisible()
				end
			end
			return false
		else
			return false
		end
	else
		return false
	end
end

function getRenderTarget()
	local outputRT = getRTarget()
	if outputRT then
		return outputRT
	else
		return false
	end
end

function setColorFilter(...)
	local reqParam = { ... }
	if #reqParam ~= 8 then
		return false
	else
		local isThisValid = true
		local countParam = 0
		for m, param in ipairs(reqParam) do
			countParam = countParam + 1
			isThisValid = isThisValid and param and (type(param) == "number")
		end
		if isThisValid then
			return setCFilter(reqParam)
		else
			return false
		end
	end
end
