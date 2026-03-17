function calculateElementPosition(element, playerPosition, nearestComponent)
	local drawPosition = {
		x = -50,
		y = -50,
	}

	local worldPosition = element.position

	if element.type == "ped" or element.type == "player" and isElement(element) then
		local bonePositionX, bonePositionY, bonePositionZ = getElementBonePosition(element, 3)

		local x, y = getScreenFromWorldPosition(bonePositionX, bonePositionY, bonePositionZ)

		drawPosition = {
			x = x,
			y = y,
		}
	elseif element.type == "vehicle" then
		local nearestVehicleComponent = nearestComponent or getNearestVehicleComponent(element, playerPosition)

		if nearestVehicleComponent then
			local componentX, componentY, componentZ =
				getVehicleComponentPosition(element, nearestVehicleComponent, "world")
			local vehicleRotation = element.rotation

			local x0, y0, z0, x1, y1, z1 = getElementBoundingBox(element)
			local offsets = components[nearestVehicleComponent]

			if offsets and offsets[4] then
				componentX, componentY, componentZ = getElementPosition(element)
				if offsets[4] == "y" then
					offsets[2] = (math.abs(y0)) + offsets[1]
				elseif offsets[4] == "y2" then
					offsets[2] = -(math.abs(y0))
				end
			end

			local vehicleMatrix = Matrix(componentX, componentY, componentZ, vehicleRotation)
			local componentPosition = vehicleMatrix:transformPosition(unpack(offsets))
			componentPosition.z = worldPosition.z

			worldPosition = componentPosition

			local x, y = getScreenFromWorldPosition(componentPosition)

			drawPosition = {
				x = x,
				y = y,
			}
		else
			local x, y = getScreenFromWorldPosition(worldPosition)

			drawPosition = {
				x = x,
				y = y,
			}
		end
	elseif element.type == "object" then
		local x, y = getScreenFromWorldPosition(element.position.x, element.position.y, element.position.z)
		drawPosition = {
			x = x,
			y = y,
		}
	end

	return drawPosition, worldPosition
end
