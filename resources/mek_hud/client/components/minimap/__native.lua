createHudComponent("minimap/native", function(store)
	setPlayerHudComponentVisible("radar", true)

	local zoneName =
		exports.mek_global:getZoneName(localPlayer.position.x, localPlayer.position.y, localPlayer.position.z)
	if zoneName then
		dxDrawBorderedText(
			1,
			zoneName,
			0,
			0,
			screenSize.x * 0.265,
			screenSize.y * 0.975,
			tocolor(255, 255, 255),
			1.3,
			"default-bold",
			"center",
			"bottom"
		)
	end
end, {
	name = "Native",
})

function isNativeRadarVisible()
	return isPlayerHudComponentVisible("radar")
end
