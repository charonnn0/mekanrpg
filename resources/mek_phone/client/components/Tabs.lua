Phone.components.tabs = function(position, size, tabs, activeTab, onChange)
	dxDrawLine(position.x, position.y + size.y, position.x + size.x, position.y + size.y, rgba(theme.GRAY[800]), 1)

	for i = 1, #tabs do
		local tab = tabs[i]
		local value = tab.value
		local label = tab.label

		local tabSize = {
			x = size.x / #tabs,
			y = size.y,
		}

		local tabPosition = {
			x = position.x + (i - 1) * tabSize.x,
			y = position.y,
		}

		local isActive = activeTab == value
		local hover = inArea(tabPosition.x, tabPosition.y, tabSize.x, tabSize.y)

		dxDrawText(
			label,
			tabPosition.x,
			tabPosition.y,
			tabPosition.x + tabSize.x,
			tabPosition.y + tabSize.y,
			rgba(theme.GRAY[50], isActive and 1 or 0.3),
			1,
			fonts.UbuntuRegular.caption,
			"center",
			"center"
		)
		if isActive then
			dxDrawLine(
				tabPosition.x,
				tabPosition.y + tabSize.y,
				tabPosition.x + tabSize.x,
				tabPosition.y + tabSize.y,
				rgba(theme.GRAY[100]),
				1
			)
		end

		if hover and isKeyPressed("mouse1") then
			onChange(value)
		end
	end
end
