local pickupsCache = {}

local fonts = useFonts()

addEventHandler("onClientResourceStart", resourceRoot, function()
	for _, pickup in ipairs(getElementsByType("pickup")) do
		if not pickupsCache[pickup] then
			if isElementStreamedIn(pickup) then
				createCache(pickup)
			end
		end
	end
	addEventHandler("onClientRender", root, drawInformationIcons)
end)

addEventHandler("onClientElementStreamIn", root, function()
	if getElementType(source) == "pickup" then
		createCache(source)
	end
end)

addEventHandler("onClientElementStreamOut", root, function()
	if getElementType(source) == "pickup" then
		destroyCache(source)
	end
end)

function createCache(pickup)
	if pickup and isElement(pickup) then
		local x, y, z = getElementPosition(pickup)
		pickupsCache[pickup] = {
			id = getElementData(pickup, "id"),
			text = getElementData(pickup, "text"),
			position = { x, y, z },
		}
	end
end

function destroyCache(pickup)
	if pickup and isElement(pickup) then
		pickupsCache[pickup] = nil
	end
end

function drawInformationIcons()
	local cx, cy, cz = getCameraMatrix()

	for pickup, value in pairs(pickupsCache) do
		if not isElement(pickup) then
			pickupsCache[pickup] = nil
			break
		end

		if value.text then
			local id = value.id or 0
			local text = value.text or "?"
			local x, y, z = unpack(value.position)

			if exports.mek_global:isAdminOnDuty(localPlayer) then
				text = text .. " (" .. id .. ")"
			else
				text = text
			end

			if getDistanceBetweenPoints3D(cx, cy, cz, x, y, z) <= 20 then
				local px, py, pz = getScreenFromWorldPosition(x, y, z + 0.5, 0.05)
				if isLineOfSightClear(cx, cy, cz, x, y, z, true, true, true, true, true, false, false) then
					if px and py then
						dxDrawFramedText(
							text,
							px,
							py,
							px,
							py,
							tocolor(255, 215, 0, 255),
							1,
							fonts.ProximaNovaBold.h6,
							"center",
							"top",
							false,
							false,
							false,
							true,
							true
						)
					end
				end
			end
		end
	end
end
