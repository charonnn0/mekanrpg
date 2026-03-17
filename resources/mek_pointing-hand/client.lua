local v3 = {
	guiGetScreenSize(),
}
local v4 = "r"
local v5 = false
local v6 = false
local v7 = false
local v8 = 0

local function v41()
	if not getKeyState(v4) then
		v5 = false
		return
	elseif
		getPedControlState(localPlayer, "aim_weapon")
		or getPedTask(localPlayer, "secondary", 0) == "TASK_SIMPLE_USE_GUN"
	then
		v5 = false
		return
	else
		local __, __, v11 = getElementRotation(localPlayer)
		local v12, v13, v14, v15, v16, __ = getCameraMatrix()
		local v18, __, v20, v21, v22 = getCursorPosition()
		local v23 = false
		local v24 = false
		local v25 = false
		local v26 = false

		if v18 then
			local l_v20_0 = v20
			local l_v21_0 = v21
			v25 = v22
			v24 = l_v21_0
			v23 = l_v20_0
			v26 = math.rad(v11) - math.atan2(v24 - v13, v23 - v12)
		else
			v26 = math.rad(v11) - math.atan2(v16 - v13, v15 - v12)
		end

		v26 = (v26 + math.pi) % (math.pi * 2) - math.pi
		if v26 < 0 then
			if getPedWeapon(localPlayer) <= 0 then
				if math.abs(v26 + math.pi * 0.5) > math.pi / 6 then
					v6 = v26 < -math.pi * 0.5 and 30 or 20
				end
			else
				v6 = v26 < -math.pi / 3 and (30 or false)
			end
		else
			v6 = false
		end

		if v6 then
			if not v23 then
				local v29, v30, v31 = getWorldFromScreenPosition(v3[1] * (v6 > 20 and 0.45 or 0.55), v3[2] * 0.45, 100)
				v25 = v31
				v24 = v30
				v23 = v29
			end

			if v23 then
				local v32, v33, v34, v35 = processLineOfSight(
					v12,
					v13,
					v14,
					v23,
					v24,
					v25,
					true,
					true,
					true,
					true,
					true,
					false,
					false,
					false,
					localPlayer
				)
				if v32 then
					local l_v33_0 = v33
					local l_v34_0 = v34
					v25 = v35
					v24 = l_v34_0
					v23 = l_v33_0
				end

				local v38 = math.floor(v23 * 10 + 0.5) * 0.1
				local v39 = math.floor(v24 * 10 + 0.5) * 0.1

				v25 = math.floor(v25 * 10 + 0.5) * 0.1
				v24 = v39
				v23 = v38
			end
		end

		if v6 and v23 and v24 and v25 then
			local __ = 24
			v5 = {
				v6,
				v23,
				v24,
				v25,
			}
		else
			v5 = false
		end

		return
	end
end

addEventHandler("onClientHUDRender", root, function()
	if not localPlayer:getData("logged") then
		return
	elseif exports.mek_chat:isChatBoxInputVisible() or isConsoleActive() then
		return
	else
		v41()
		local v42 = #Element.getAllByType("player")
		local v43 = 300
		v43 = v42 > 50 and v42 < 100 and 500 or v42 > 100 and v42 < 200 and 700 or 1000

		if v7 ~= v5 then
			if v8 + 700 < getTickCount() then
				v8 = getTickCount()
				v7 = v5
				triggerServerEvent("pointingHand.sync", localPlayer, v5)
			end
		elseif v5 and v8 + 700 < getTickCount() then
			v8 = getTickCount()
			triggerServerEvent("pointingHand.sync", localPlayer, v5)
		end

		setElementData(localPlayer, "pointing_hand", v5, false)
		return
	end
end, false, "low-5")

addEvent("pointingHand.onSync", true)
addEventHandler("pointingHand.onSync", root, function(v44, v45)
	setElementData(v44, "pointing_hand", v45, false)
end)

local v46 = {
	status = {
		pointed = {},
	},
}

local function v52(v47, v48, v49, v50)
	local v51 = -v47[1][1] * v47[2][2] * v47[3][3]
		+ v47[1][1] * v47[3][2] * v47[2][3]
		- v47[1][3] * v47[2][1] * v47[3][2]
		+ v47[1][3] * v47[2][2] * v47[3][1]
		+ v47[2][1] * v47[3][3] * v47[1][2]
		- v47[1][2] * v47[2][3] * v47[3][1]
	return (
		-v47[2][1] * v47[3][2] * v50
		+ v47[2][1] * v47[3][3] * v49
		- v47[2][2] * v47[3][3] * v48
		+ v47[2][2] * v47[3][1] * v50
		+ v47[3][2] * v47[2][3] * v48
		- v47[2][3] * v47[3][1] * v49
	) / v51,
		(
			v47[1][1] * v47[3][2] * v50
			- v47[1][1] * v47[3][3] * v49
			- v47[1][3] * v47[3][2] * v48
			+ v47[1][3] * v47[3][1] * v49
			+ v47[3][3] * v47[1][2] * v48
			- v47[1][2] * v47[3][1] * v50
		) / v51,
		(
			-v47[1][1] * v47[2][2] * v50
			+ v47[1][1] * v47[2][3] * v49
			- v47[1][3] * v47[2][1] * v49
			+ v47[1][3] * v47[2][2] * v48
			+ v47[2][1] * v47[1][2] * v50
			- v47[1][2] * v47[2][3] * v48
		) / v51
end

local function v56(v53, v54)
	v54 = v54 and true or false
	if not v53 or v54 == (v46.status.pointed[v53] and true or false) then
		return false
	else
		if v54 then
			local v55 = getElementData(v53, "pointing_hand")
			if not v55 or not isElementStreamedIn(v53) then
				v46.status.pointed[v53] = nil
				return false
			else
				v46.status.pointed[v53] = v55
			end
		else
			v46.status.pointed[v53] = nil
		end
		return true
	end
end

local function v58(v57)
	return type(v57) == "number" and v57 == v57 and v57 ~= math.huge and v57 ~= -math.huge
end

local function v60(v59)
	if not v58(v59) then
		return 0
	else
		return v59
	end
end

local function v94(v61, v62)
	if not v61 or not isElement(v61) or not v62 then
		return false
	elseif not isElementStreamedIn(v61) then
		return false
	else
		local v63 = v62[2]
		local v64 = v62[3]
		local v65 = v62[4]
		local v66 = v62[1] + 1
		local v67 = getElementBoneMatrix(v61, v66)

		if not v67 then
			return false
		else
			local v68, v69, v70 = getElementBonePosition(v61, v62[1] + 2)
			local v71, v72, v73 = getElementBonePosition(v61, v62[1] + 3)
			local v74, v75, v76 = getElementBonePosition(v61, v62[1] + 4)

			if not v68 or not v69 or not v70 or not v71 or not v72 or not v73 or not v74 or not v75 or not v76 then
				return false
			elseif
				not v58(v68)
				or not v58(v69)
				or not v58(v70)
				or not v58(v71)
				or not v58(v72)
				or not v58(v73)
				or not v58(v74)
				or not v58(v75)
				or not v58(v76)
			then
				return false
			else
				local v77, v78, v79, v80 = processLineOfSight(
					v68,
					v69,
					v70,
					v63,
					v64,
					v65,
					true,
					true,
					true,
					true,
					true,
					false,
					false,
					false,
					v61
				)
				if v77 then
					local l_v78_0 = v78
					local l_v79_0 = v79
					v65 = v80
					v64 = l_v79_0
					v63 = l_v78_0
				end

				local v83 = v67[4]
				local v84 = v67[4]
				local v85 = v67[4]
				local l_v68_0 = v68
				local l_v69_0 = v69

				v85[3] = v70
				v84[2] = l_v69_0
				v83[1] = l_v68_0
				v83, v84, v85 = v52(v67, v63 - v68, v64 - v69, v65 - v70)

				if not v83 or not v84 or not v85 or not v58(v83) or not v58(v84) or not v58(v85) then
					return false
				else
					l_v68_0 = getDistanceBetweenPoints3D(v68, v69, v70, v71, v72, v73) or 0
					l_v69_0 = getDistanceBetweenPoints3D(v71, v72, v73, v74, v75, v76) or 0

					local v88 = math.sqrt(v83 * v83 + v84 * v84 + v85 * v85)

					if not v58(l_v68_0) or not v58(l_v69_0) or not v58(v88) then
						return false
					else
						local v89 = 180
						if v88 < l_v68_0 + l_v69_0 then
							local v90 = (l_v68_0 * l_v68_0 + l_v69_0 * l_v69_0 - v88 * v88) / (2 * l_v68_0 * l_v69_0)
							if v90 >= -1 and v90 <= 1 then
								v89 = v60(math.deg(math.acos(v90)))
							end
						end

						local v91 = math.sqrt(v83 * v83 + v84 * v84)
						if not v58(v91) then
							return false
						else
							local v92 = 0
							if v91 > 0 then
								v92 = v60(math.deg(math.atan2(-v85, v91)))
							end

							local v93 = v60(math.deg(math.atan2(v84, v83)) + (180 - v89) * 0.5)
							if not v58(v93) or not v58(v92) or not v58(v89) then
								return false
							else
								setElementBoneRotation(v61, v62[1] + 2, 0, v93, v92)
								setElementBoneRotation(v61, v62[1] + 3, 0, v60(-(180 - v89)), 0)
								setElementBoneRotation(v61, v62[1] + 4, v62[1] > 20 and 270 or 90, 0, 0)
								updateElementRpHAnim(v61)
								return true
							end
						end
					end
				end
			end
		end
	end
end

local function v97()
	for v95, v96 in pairs(v46.status.pointed) do
		v94(v95, v96)
	end
end

local v98 = false
local function v99()
	if not v98 then
		addEventHandler("onClientPedsProcessed", root, v97, false, "high+5")
		v98 = true
	end
end

local function v100()
	if v98 then
		removeEventHandler("onClientPedsProcessed", root, v97)
		v98 = false
	end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
	for __, v102 in ipairs(getElementsByType("player", _, true)) do
		if isElementStreamedIn(v102) then
			v56(v102, true)
		end
	end
	v99()
end)

addEventHandler("onClientElementStreamIn", root, function()
	if getElementType(source) == "player" then
		v56(source, true)
		v99()
	end
end)

addEventHandler("onClientElementStreamOut", root, function()
	if getElementType(source) == "player" then
		v56(source, false)
		if not next(v46.status.pointed) then
			v100()
		end
	end
end)

addEventHandler("onClientElementDataChange", root, function(v103, __, __)
	if v103 == "pointing_hand" and getElementType(source) == "player" then
		v56(source, false)
		v56(source, true)
		if next(v46.status.pointed) then
			v99()
		else
			v100()
		end
	end
end)
