local factories = {
	vehicle = "menuVehicleCollector",
	player = "menuPlayerCollector",
	object = "menuObjectCollector",
	ped = "menuPedCollector",
}

addEventHandler("onClientClick", root, function(button, state, _, _, _, _, _, element)
	if button == "right" and state == "down" and element and isElement(element) then
		local distance = getDistanceBetweenPoints3D(localPlayer.position, element.position)
		if distance <= 4 then
			local factory = factories[element:getType()]
			if factory then
				_G[factory](element)
			end
		end
	end
end)
