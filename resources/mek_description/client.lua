local theme = useTheme()
local fonts = useFonts()

local serverColorHex = getServerColor(2)

local vehicles = {}

local viewDistance = 10
local heightOffset = 1.6

local playerID = 0

local renderTimers = {}

local basePlateSize = {
	x = 1024,
	y = 512,
}

function createRender(funcName, func, tick)
	if not tick then
		tick = 0
	end

	if not renderTimers[funcName] then
		renderTimers[funcName] = setTimer(func, tick, 0)
	end
end

function checkRender(funcName)
	return renderTimers[funcName]
end

function destroyRender(funcName)
	if renderTimers[funcName] then
		killTimer(renderTimers[funcName])
		renderTimers[funcName] = nil
		collectgarbage("collect")
	end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
	bindKey("lalt", "down", function()
		if not localPlayer:getData("logged") then
			return
		end

		if not checkRender("showText") then
			refreshNearByVehs()
			createRender("showText", showText)
		end
	end)

	bindKey("lalt", "up", function()
		if not localPlayer:getData("logged") then
			return
		end

		if checkRender("showText") then
			destroyRender("showText")
		end
	end)

	bindKey("ralt", "down", function()
		if not localPlayer:getData("logged") then
			return
		end

		if checkRender("showText") then
			destroyRender("showText")
		else
			refreshNearByVehs()
			createRender("showText", showText)
		end
	end)
end)

function showText()
	for i = 1, #vehicles, 1 do
		local row = vehicles[i]
		local vehicle = row.vehicle
		if row and vehicle and isElement(vehicle) then
			local x, y, z = getElementPosition(vehicle)
			local cx, cy, cz = getCameraMatrix()
			if getDistanceBetweenPoints3D(cx, cy, cz, x, y, z) <= viewDistance then
				local px, py = getScreenFromWorldPosition(x, y, z + heightOffset, 0.05)
				if
					(getElementDimension(localPlayer) == getElementDimension(vehicle))
					and px
					and isLineOfSightClear(cx, cy, cz, x, y, z, true, false, false, true, true, false, false)
				then
					local plate = tostring(row.plate):upper()

					local containerWidth = 300
					local textColor = tocolor(255, 255, 255, 255)

					local grids = {}

					if row.carshop then
						local price = row.carshopcost or 0
						local taxes = row.carshoptax or 0

						table.insert(grids, {
							title = "Galerİ FİyatI",
							value = "₺" .. exports.mek_global:formatMoney(price),
						})

						table.insert(grids, {
							title = "Vergİ",
							value = "₺" .. exports.mek_global:formatMoney(taxes),
						})
					else
						table.insert(grids, {
							title = "AraÇ ID",
							value = row.dbid,
						})

						local vowner = row.owner or -1
						local vfaction = row.faction or -1
						if vowner == playerID or exports.mek_global:isAdminOnDuty(localPlayer) then
							local ownerName = "Bilinmiyor"
							if vfaction > 0 then
								ownerName = exports.mek_cache:getFactionNameFromID(vfaction)
							elseif vowner > 0 then
								ownerName = exports.mek_cache:getCharacterNameFromID(vowner)
							end

							table.insert(grids, {
								title = "Sahİbİ",
								value = ownerName,
								loading = not ownerName or ownerName == "",
							})
						end
					end

					px = px - (containerWidth / 2)

					local plateOneLineHeight = dxGetFontHeight(1, fonts.SFUIBold.body)
					local plateFontWidth = dxGetTextWidth(plate, 1, fonts.License.h4)

					local plateW, plateH = basePlateSize.x / 5, basePlateSize.y / 13
					if existsSpecialFile then
						plateW, plateH = 180, 39
					end
					if plateW < plateFontWidth then
						plateW = plateFontWidth + 20
					end

					local r, g, b = 11, 29, 141
					if exports["mek_vehicle-plate"]:getPlateDesigns()[row.plateDesign] then
						local plateDesign = row.plateDesign
						r, g, b = unpack(exports["mek_vehicle-plate"]:getPlateDesigns()[plateDesign].textColor)
						backgroundImage = ":mek_vehicle-plate/public/images/" .. plateDesign .. ".png"
					else
						r, g, b = 0, 0, 0
						backgroundImage = ":mek_vehicle-plate/public/images/1.png"
					end

					if getVehicleType(vehicle) ~= "BMX" then
						local platePosition = {
							x = px + (containerWidth - plateW) / 2,
							y = py - plateH,
						}

						dxDrawImage(platePosition.x, platePosition.y, plateW, plateH, backgroundImage)

						if existsSpecialFile then
							py = row.faction == 1 and py - 18 or py - 20
							px = px + 5
						end

						dxDrawText(
							plate,
							platePosition.x + 10,
							platePosition.y,
							plateW + platePosition.x,
							plateH + platePosition.y - 5,
							tocolor(r, g, b, 255),
							1,
							fonts.License.h3,
							"center",
							"bottom"
						)

						py = py + 5
					end

					dxDrawRectangle(px, py, containerWidth, 30, rgba(theme.GRAY[900], 0.8))
					dxDrawText(
						row.name,
						px + 10,
						py,
						0,
						30 + py,
						rgba(theme.GRAY[100], 0.8),
						1,
						fonts.BebasNeueRegular.h5,
						"left",
						"center"
					)
					py = py + 30

					for i = 1, #grids do
						local grid = grids[i]
						local title = grid.title
						local value = grid.value
						local loading = grid.loading

						dxDrawRectangle(
							px,
							py,
							containerWidth,
							30,
							rgba(i % 2 == 0 and theme.GRAY[700] or theme.GRAY[800], 0.8)
						)
						dxDrawText(
							title:upper(),
							px + 10,
							py,
							0,
							30 + py,
							rgba(serverColorHex),
							1,
							fonts.BebasNeueRegular.h5,
							"left",
							"center"
						)
						if not loading then
							dxDrawText(
								value,
								px - 10,
								py,
								px + containerWidth - 10,
								30 + py,
								rgba(theme.GRAY[400], 0.8),
								1,
								fonts.BebasNeueRegular.h5,
								"right",
								"center"
							)
						else
							drawSpinner({
								position = {
									x = px + containerWidth - 25,
									y = py + 15 / 2,
								},
								size = 15,

								speed = 2,

								variant = "soft",
								color = "gray",
							})
						end

						py = py + 30
					end
				end
			end
		end
	end
end

function refreshNearByVehs()
	playerID = getElementData(localPlayer, "dbid")
	for index, vehicle in
		ipairs(getElementsWithinRange(localPlayer.position, 30, "vehicle", localPlayer.interior, localPlayer.dimension))
	do
		if isElement(vehicle) and vehicle:getData("dbid") then
			vehicles[index] = {
				vehicle = vehicle,
				dbid = vehicle:getData("dbid"),
				plate = vehicle:getData("carshop") and (vehicle:getData("plate") or (getVehiclePlateText(vehicle)))
					or (vehicle:getData("plate") or getVehiclePlateText(vehicle)),
				plateDesign = vehicle:getData("plate_design") or 1,

				carshop = vehicle:getData("carshop"),
				carshopcost = vehicle:getData("carshop:cost") or 0,
				carshoptax = vehicle:getData("carshop:taxcost") or 0,

				owner = vehicle:getData("owner"),
				faction = vehicle:getData("faction"),

				name = exports.mek_global:getVehicleName(vehicle),
			}
		end
	end
end
