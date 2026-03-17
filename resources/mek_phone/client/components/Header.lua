local headerSize = {
	x = Phone.innerSize.x,
	y = 50,
}

local headerPosition = {
	x = Phone.innerPosition.x,
	y = Phone.innerPosition.y + 25,
}

Phone.headerPadding = headerSize.y + 25

Phone.components.Header = function(headerContent, disableBackground)
	if not disableBackground then
		dxDrawRectangle(headerPosition.x, headerPosition.y, headerSize.x, headerSize.y, rgba(styles.background))
	end

	headerContent(headerPosition, headerSize)
end
