-- Crosshair değişkenleri
local Crosshair_table = nil

-- Yardımcı mesaj fonksiyonu
local function outputInfo(msg)
    outputChatBox("#FF0000[!]#EAB30C " .. msg, 255, 255, 255, true)
end

-- /crosshair komutu
addCommandHandler("crosshair", function(cmd, arg)
    if not arg then
        outputInfo("Kullanım: /crosshair [1-5 | reset]")
        return
    end


    if arg == "reset" then
        if Crosshair_table then
            destroyElement(Crosshair_table)
            Crosshair_table = nil
        end
        outputInfo("Varsayılan crosshair'e dönüldü.")
        return
    end

    local num = tonumber(arg)
    if num and num >= 1 and num <= 81 then
        if fileExists("public/images/" .. num .. ".png") then
            if Crosshair_table then
                destroyElement(Crosshair_table)
            end
            Crosshair_table = dxCreateShader("public/shaders/texreplace.fx")
            engineApplyShaderToWorldTexture(Crosshair_table, "siteM16")
            dxSetShaderValue(Crosshair_table, "gTexture", dxCreateTexture("public/images/" .. num .. ".png"))
            outputInfo("Crosshair [" .. num .. "] olarak değiştirildi.")
            triggerEvent("playSuccessfulSound", localPlayer)
        else
            outputInfo("Resim bulunamadı: public/images/" .. num .. ".png")
        end
    else
        outputInfo("Geçersiz kullanım. /crosshair [1-81 | reset]")
    end
end)