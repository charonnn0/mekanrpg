pressed = nil
local show = false
local delay = 4000
local screenW, screenH = guiGetScreenSize()
local hotkeys = {}
local itemSize = 100
local margin = 6
local padding = 4

local fonts = useFonts()

switching = nil
usingWeapon = {}

function weaponSwitch(prevSlot, newSlot)
	if not pressed then
		addEventHandler("onClientRender", root, renderWeaponSelector)
	end

	pressed = getTickCount()

	if switching or reloading then
		cancelEvent()
		return
	end
end
addEventHandler("onClientPlayerWeaponSwitch", localPlayer, weaponSwitch)

local function hasWeapon(weapons, weaponID)
	for _, weapon in ipairs(weapons) do
		if weapon.id == weaponID then
			return true
		end
	end
end

local function getPedWeapons(player)
	local items = exports.mek_item:getItems(player)
	local weapons = {}
	local total = 1
	local slots = 1

	weapons[1] = {}
	table.insert(weapons[1], {
		dbid = 0,
		id = 0,
		slot = 0,
		name = "Fist",
	})

	for _, item in ipairs(items) do
		if item[1] == 115 then
			local dbid = tonumber(item[3])
			local weaponDetails = split(item[2], ":")
			local weaponID = tonumber(weaponDetails[1])
			local serial = tonumber(weaponDetails[1])
			local weaponSlot = getSlotFromWeapon(weaponID) + 1

			if not weapons[weaponSlot] then
				weapons[weaponSlot] = {}
				slots = slots + 1
			end

			table.insert(weapons[weaponSlot], {
				dbid = dbid,
				id = weaponID,
				slot = weaponSlot,
				name = weaponDetails[3],
				serial = weaponDetails[2],
			})

			total = total + 1
		end
	end

	return weapons, total, slots
end

function renderWeaponSelector()
	if
		not isPedDead(localPlayer)
		and getElementData(localPlayer, "logged")
		and exports.mek_settings:getPlayerSetting(localPlayer, "weapon_interface_visible")
	then
		local weapons, total, slots = getPedWeapons(localPlayer)

		local bgW = (itemSize + padding) * slots + padding
		local bgH = itemSize + padding * 2
		local bgX = (screenW - bgW) / 2
		local bgY = screenH / 10

		local startX = bgX + padding
		local startY = bgY + padding

		local iwX = (screenW - bgW) / 2
		local iwY = (screenH - bgH) / 2

		local success, error = canPlayerShoot()
		if error and #error > 0 then
			dxDrawText(
				error,
				-1,
				bgY - 20 - 1,
				screenW - 1,
				bgH - 1,
				tocolor(0, 0, 0, 255),
				1,
				fonts.SFUIBold.body,
				"center",
				"top",
				false,
				true,
				false,
				false,
				false
			)
			dxDrawText(
				error,
				0 + 1,
				bgY - 20 - 1,
				screenW + 1,
				bgH - 1,
				tocolor(0, 0, 0, 255),
				1,
				fonts.SFUIBold.body,
				"center",
				"top",
				false,
				true,
				false,
				false,
				false
			)
			dxDrawText(
				error,
				0 - 1,
				bgY - 20 + 1,
				screenW - 1,
				bgH - 1,
				tocolor(0, 0, 0, 255),
				1,
				fonts.SFUIBold.body,
				"center",
				"top",
				false,
				true,
				false,
				false,
				false
			)
			dxDrawText(
				error,
				0 + 1,
				bgY - 20 + 1,
				screenW + 1,
				bgH + 1,
				tocolor(0, 0, 0, 255),
				1,
				fonts.SFUIBold.body,
				"center",
				"top",
				false,
				true,
				false,
				false,
				false
			)
			dxDrawText(
				error,
				0,
				bgY - 20,
				screenW,
				bgH,
				tocolor(255, 255, 255, 255),
				1,
				fonts.SFUIBold.body,
				"center",
				"top",
				false,
				true,
				false,
				false,
				false
			)
		end

		local count = 0
		local selectedSomething = false

		for slot = 1, 13 do
			if weapons[slot] then
				for i = 1, #weapons[slot] do
					local weapon = weapons[slot][i]
					if not weapon.dbid or (usingWeapon and usingWeapon[slot - 1] == weapon.dbid) then
						local startX = startX + count * (itemSize + padding)
						local currentWeapon = getPedWeapon(localPlayer)
						local bgColor = tocolor(150, 150, 150, switching and 40 or 81)
						local alpha = 100

						if currentWeapon == weapon.id then
							selectedSomething = true
							bgColor = tocolor(51, 173, 51, switching and 50 or 100)

							local count2 = 1
							local currentSlot = getPedWeaponSlot(localPlayer)

							for _, weapon2 in ipairs(weapons[slot]) do
								if
									weapon2
									and (weapon2.dbid ~= 0 or usingWeapon[currentSlot] ~= 0)
									and weapon2.dbid ~= usingWeapon[currentSlot]
								then
									local startY2 = startY + count2 * (itemSize + padding) + 15

									dxDrawImage(
										startX,
										startY2,
										itemSize,
										itemSize,
										":mek_item/public/images/items/-" .. weapon2.id .. ".png",
										0,
										0,
										0,
										tocolor(255, 255, 255, switching and 100 or 255),
										false
									)
									dxDrawText(
										weapon2.name or "",
										startX,
										startY2 + 15,
										startX + itemSize,
										startY2 + itemSize + 15,
										tocolor(255, 255, 255, switching and 100 or 255),
										1,
										fonts.SFUIBold.body,
										"right",
										"bottom",
										false,
										true,
										false,
										false,
										false
									)
									dxDrawText(
										count2,
										startX,
										startY2,
										startX + itemSize,
										startY2 + itemSize,
										tocolor(255, 255, 255, switching and 100 or 255),
										1,
										fonts.SFUIBold.body,
										"left",
										"top",
										false,
										true,
										false,
										false,
										false
									)

									if not hotkeys then
										hotkeys = {}
									end

									hotkeys[count2] = weapon2
									count2 = count2 + 1
								end
							end

							alpha = 245

							if count2 == 1 then
								hotkeys = nil
							end
						end

						dxDrawImage(
							startX + 5,
							startY + 5,
							itemSize - 10,
							itemSize - 10,
							":mek_item/public/images/items/-" .. weapon.id .. ".png",
							0,
							0,
							0,
							tocolor(255, 255, 255, switching and 100 or alpha),
							false
						)
						dxDrawText(
							weapon.name or "",
							startX,
							startY + 15,
							startX + itemSize,
							startY + itemSize + 15,
							tocolor(255, 255, 255, switching and 100 or alpha),
							1,
							fonts.SFUIBold.body,
							"center",
							"bottom",
							false,
							true,
							false,
							false,
							false
						)

						count = count + 1
						break
					end
				end
			end
		end

		if not selectedSomething or count == 0 or not pressed or getTickCount() - pressed > delay then
			removeEventHandler("onClientRender", root, renderWeaponSelector)
			pressed = nil
			hotkeys = nil
		end
	end
end
addEventHandler("onClientRender", root, renderWeaponSelector)

function updateUsingGun(_usingWeapon)
	usingWeapon = _usingWeapon
end
addEvent("weapon.updateUsingGun", true)
addEventHandler("weapon.updateUsingGun", resourceRoot, updateUsingGun)

function weaponSwitch(button, press)
	if press and not switching and hotkeys then
		for key, weapon in pairs(hotkeys) do
			if tostring(key) == button then
				cancelEvent()
				switching = "Değiştiriliyor..."
				triggerServerEvent("weapon.switchWeaponInSameSlot", localPlayer, weapon.dbid, weapon.slot)
				pressed = getTickCount()
				hotkeys = nil
				break
			end
		end
	end
end
addEventHandler("onClientKey", root, weaponSwitch)

function weaponSwitchCallback(weapon)
	switching = nil
	pressed = getTickCount()
	usingWeapon[weapon.slot] = weapon.dbid
end
addEvent("weapon.weaponSwitchCallback", true)
addEventHandler("weapon.weaponSwitchCallback", root, weaponSwitchCallback)

addEventHandler("onClientPlayerWeaponFire", root, function()
	if source == localPlayer then
		if not pressed then
			addEventHandler("onClientRender", root, renderWeaponSelector)
		end
		pressed = getTickCount()
	end
end)
