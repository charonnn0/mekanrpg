-- Client-side script for /adminol command
-- Displays adminol.png using dxDrawImage for 5 seconds and plays adminol.mp3

local screenW, screenH = guiGetScreenSize() -- Get screen resolution for centering
local isImageVisible = false -- Flag to control image rendering
local soundElement = nil -- To store the sound element
local imageEndTime = 0 -- To track when to stop drawing

-- Function to start showing the image and playing sound
function showAdminOL()
    -- Prevent overlap if command is spammed
    if isImageVisible then
        removeEventHandler("onClientRender", root, drawAdminImage)
    end
    if soundElement and isElement(soundElement) then
        destroyElement(soundElement)
    end

    -- Set flag and timer for image display
    isImageVisible = true
    imageEndTime = getTickCount() + 5000 -- 5 seconds from now

    -- Add render event to draw image
    addEventHandler("onClientRender", root, drawAdminImage)

    -- Play the sound (non-looping, full volume)
    soundElement = playSound("adminol.mp3")
    setSoundVolume(soundElement, 1.0)

    -- Stop rendering image after 5 seconds
    setTimer(function()
        if isImageVisible then
            isImageVisible = false
            removeEventHandler("onClientRender", root, drawAdminImage)
        end
        -- Sound stops naturally if ~5 seconds; force stop if needed
        if soundElement and isElement(soundElement) then
            destroyElement(soundElement)
            soundElement = nil
        end
    end, 5000, 1)
end

-- Function to draw the image each frame
function drawAdminImage()
    if isImageVisible and getTickCount() <= imageEndTime then
        -- Draw image centered, 512x512 pixels (adjust size as needed)
        dxDrawImage((screenW - 512) / 2, (screenH - 512) / 2, 512, 512, "adminol.png", 0, 0, 0, tocolor(255, 255, 255, 255))
        -- For full-screen: dxDrawImage(0, 0, screenW, screenH, "adminol.png", 0, 0, 0, tocolor(255, 255, 255, 255))
        -- Last parameter (tocolor) is white with full opacity; adjust alpha (last number) for transparency
    end
end

-- Bind the command /adminol to the function
addCommandHandler("adminol", showAdminOL)