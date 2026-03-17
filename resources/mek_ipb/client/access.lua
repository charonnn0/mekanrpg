
addEvent("ipb.accessControl", true)
addEventHandler("ipb.accessControl", root,
    function (access)
        if access then
            GUI:create()
            GUI:setVisible(true)
        else
            GUI:destroy()
        end
    end,
true)
