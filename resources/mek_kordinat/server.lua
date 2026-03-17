function koordinatYaz(thePlayer)
    if not isElement(thePlayer) then return end
    local x, y, z = getElementPosition(thePlayer)
    outputChatBox(
        string.format("[!] #FFFFFF Senin konumun: X: %.2f, Y: %.2f, Z: %.2f", x, y, z),
        thePlayer, 0, 255, 0, true
    )
end
addCommandHandler("koordinat", koordinatYaz)
