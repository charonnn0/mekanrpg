local screenW, screenH = guiGetScreenSize()

local tabela = {
    visible = false,
    x = screenW - 150, 
    y = screenH * 0.3, 
    w = 80,
    h = 100
}

addEvent("hizTabelaGoster", true)
addEventHandler("hizTabelaGoster", root, function()
    tabela.visible = true
end)

addEvent("hizTabelaGizle", true)
addEventHandler("hizTabelaGizle", root, function()
    tabela.visible = false
end)

addEventHandler("onClientRender", root, function()
    if not tabela.visible then return end

    dxDrawImage(
        tabela.x,
        tabela.y,
        tabela.w,
        tabela.h,
        "tabela.png"
    )
end)
