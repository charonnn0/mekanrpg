local store = useStore("menuContext")

local function getCursorRelativePosition()
	local cursorX, cursorY = getCursorPosition()

	return Vector2(cursorX * screenSize.x, cursorY * screenSize.y)
end

local function renderMenu()
	local position = store.get("position")
	local size = store.get("size")
	local header = store.get("header")
	local items = store.get("items")

	local itemsCombiner = {}
	for key, item in ipairs(items) do
		table.insert(itemsCombiner, {
			icon = "",
			text = item.text,
			key = key,
		})
	end

	local list = drawList({
		position = position,
		size = size,

		padding = 15,
		rowHeight = 35,

		name = "menu__list__" .. header,
		header = header,
		items = itemsCombiner,

		variant = "soft",
		color = "gray",
	})

	if list and list.pressed then
		local item = items[list.pressed]
		if item.callback then
			item.callback()
			destroyMenuContext()
		end
	end
end

function createMenuContext(element, items)
	local visible = store.get("visible")
	local position = getCursorRelativePosition()

	if visible then
		destroyMenuContext()
	end

	if not (#items > 0) then
		return
	end

	table.insert(items, {
		text = "Kapat",
		callback = destroyMenuContext,
	})

	store.set("items", items)
	store.set("element", element)

	local elementType = element:getType()
	if elementType == "vehicle" then
		store.set("header", exports.mek_global:getVehicleName(element))
	elseif elementType == "player" then
		store.set("header", element:getName():gsub("_", " "))
	elseif elementType == "ped" then
		store.set("header", element:getData("name"):gsub("_", " "))
	else
		store.set("header", "Menü")
	end

	store.set("size", {
		x = 300,
		y = 100 + #items * 35,
	})

	local timerRef = setTimer(renderMenu, 0, 0)
	store.set("timerRef", timerRef)
	store.set("visible", true)

	store.set("position", position)

	showCursor(true)
	createOutline(element)
end

function destroyMenuContext()
	local timerRef = store.get("timerRef")
	local element = store.get("element")

	if isTimer(timerRef) then
		killTimer(timerRef)
	end

	store.set("visible", false)

	showCursor(false)
	destroyOutline(element)
end
