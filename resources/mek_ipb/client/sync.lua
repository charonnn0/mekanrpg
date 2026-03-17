
addEvent("ipb.updateStats", true)
addEventHandler("ipb.updateStats", root,
    function (mode, columns, rows)
        if not GUI.window then
            return
        end

        GUI:fill(mode, columns, rows)
    end,
true)
