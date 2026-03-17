function makeGlowStick(x, y, z)
    local marker = createMarker(x, y, z, "corona", 1, 0, 255, 0, 150)
    setTimer(destroyGlowStick, 600000, 1, marker)
end
addEvent("createGlowStick", true)
addEventHandler("createGlowStick", root, makeGlowStick)

function destroyGlowStick(marker)
    destroyElement(marker)
end