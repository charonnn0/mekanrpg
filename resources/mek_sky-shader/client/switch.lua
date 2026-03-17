addEventHandler("onClientResourceStart", resourceRoot, function()
	triggerEvent("switchDynamicSky", resourceRoot, true)
end)

function switchDynamicSky(dsOn)
	if dsOn then
		startDynamicSky()
	else
		stopDynamicSky()
	end
end

addEvent("switchDynamicSky", true)
addEventHandler("switchDynamicSky", resourceRoot, switchDynamicSky)

addEventHandler("onClientResourceStop", resourceRoot, stopDynamicSky)
