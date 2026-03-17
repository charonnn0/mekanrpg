Animation = {}
Animation.matrixRotations = {
	[PhoneAnimation.Camera] = {
		[22] = { 0, 270, -30 },
		[23] = { 0, -20, 30 },
		[24] = { 205, -45, 0 },
		[25] = { -25, 0, 25 },
	},
	[PhoneAnimation.Hold] = {
		[22] = { 0, 320, -70 },
		[23] = { 0, -90, 25 },
		[24] = { 175, 0, -55 },
		[25] = { -25, 0, 25 },
	},
	[PhoneAnimation.In] = {
		[22] = { 0, 270, -30 },
		[23] = { 0, 10, 155 },
		[24] = { 205, 0, 0 },
		[25] = { -25, 0, 0 },
	},
}

Animation.phoneModel = 330

Animation.phones = {}

function Animation.attachElementToBone(element, ped, bone, offX, offY, offZ, offrx, offry, offrz)
	if isElementOnScreen(ped) then
		local boneMat = getElementBoneMatrix(ped, bone)
		local sroll, croll, spitch, cpitch, syaw, cyaw =
			math.sin(offrz), math.cos(offrz), math.sin(offry), math.cos(offry), math.sin(offrx), math.cos(offrx)
		local rotMat = {
			{
				sroll * spitch * syaw + croll * cyaw,
				sroll * cpitch,
				sroll * spitch * cyaw - croll * syaw,
			},
			{
				croll * spitch * syaw - sroll * cyaw,
				croll * cpitch,
				croll * spitch * cyaw + sroll * syaw,
			},
			{ cpitch * syaw, -spitch, cpitch * cyaw },
		}
		local finalMatrix = {
			{
				boneMat[2][1] * rotMat[1][2] + boneMat[1][1] * rotMat[1][1] + rotMat[1][3] * boneMat[3][1],
				boneMat[3][2] * rotMat[1][3] + boneMat[1][2] * rotMat[1][1] + boneMat[2][2] * rotMat[1][2],
				boneMat[2][3] * rotMat[1][2] + boneMat[3][3] * rotMat[1][3] + rotMat[1][1] * boneMat[1][3],
				0,
			},
			{
				rotMat[2][3] * boneMat[3][1] + boneMat[2][1] * rotMat[2][2] + rotMat[2][1] * boneMat[1][1],
				boneMat[3][2] * rotMat[2][3] + boneMat[2][2] * rotMat[2][2] + boneMat[1][2] * rotMat[2][1],
				rotMat[2][1] * boneMat[1][3] + boneMat[3][3] * rotMat[2][3] + boneMat[2][3] * rotMat[2][2],
				0,
			},
			{
				boneMat[2][1] * rotMat[3][2] + rotMat[3][3] * boneMat[3][1] + rotMat[3][1] * boneMat[1][1],
				boneMat[3][2] * rotMat[3][3] + boneMat[2][2] * rotMat[3][2] + rotMat[3][1] * boneMat[1][2],
				rotMat[3][1] * boneMat[1][3] + boneMat[3][3] * rotMat[3][3] + boneMat[2][3] * rotMat[3][2],
				0,
			},
			{
				offX * boneMat[1][1] + offY * boneMat[2][1] + offZ * boneMat[3][1] + boneMat[4][1],
				offX * boneMat[1][2] + offY * boneMat[2][2] + offZ * boneMat[3][2] + boneMat[4][2],
				offX * boneMat[1][3] + offY * boneMat[2][3] + offZ * boneMat[3][3] + boneMat[4][3],
				1,
			},
		}
		setElementMatrix(element, finalMatrix)
		return true
	else
		setElementPosition(element, 0, 0, -1000)
		return false
	end
end

addEventHandler("onClientPedsProcessed", root, function()
	local nearestPlayers =
		getElementsWithinRange(localPlayer.position, 20, "player", localPlayer.interior, localPlayer.dimension)
	for _, player in ipairs(nearestPlayers) do
		local animation = PhoneAnimation.get(player)
		if animation then
			local offsets = Animation.matrixRotations[animation]

			if not Animation.phones[player] then
				Animation.phones[player] = createObject(Animation.phoneModel, 0, 0, 0)
				setElementCollisionsEnabled(Animation.phones[player], false)
				setElementParent(Animation.phones[player], player)
				setElementInterior(Animation.phones[player], player.interior)
				setElementDimension(Animation.phones[player], player.dimension)
			end

			for bone, rotation in pairs(offsets) do
				if localPlayer == player and animation == PhoneAnimation.Camera then
					rotation[3] = Camera.rightHandZ
				end

				setElementBoneRotation(player, bone, unpack(rotation))
			end

			updateElementRpHAnim(player)

			if animation == PhoneAnimation.Hold then
				local x, y, z = getElementBonePosition(player, 24)
				setPedLookAt(player, x, y, z)
			end

			if Animation.phones[player] then
				Animation.attachElementToBone(Animation.phones[player], player, 25, 0.02, 0.018, 0.05, 4.85, 4.9, 4.5)
				setElementInterior(Animation.phones[player], player.interior)
				setElementDimension(Animation.phones[player], player.dimension)
			end
		else
			if Animation.phones[player] then
				destroyElement(Animation.phones[player])
				Animation.phones[player] = nil
			end
		end
	end
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
	local txd = engineLoadTXD("public/objects/phone.txd")
	engineImportTXD(txd, Animation.phoneModel)
	local dff = engineLoadDFF("public/objects/phone.dff")
	engineReplaceModel(dff, Animation.phoneModel)
end)
