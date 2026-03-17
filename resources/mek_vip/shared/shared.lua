vipNames = {
	[1] = "VIP 1",
	[2] = "VIP 2",
	[3] = "VIP 3",
	[4] = "VIP 4",
}

function isPlayerVip(charID)
	return vips[charID] or false
end

function getVipName(vipID)
	return vipNames[vipID] or "?"
end
