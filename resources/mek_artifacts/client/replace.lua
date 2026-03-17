function replaceModels()
	local col = engineLoadCOL("public/models/helmet.col")

	local txd = engineLoadTXD("public/models/rod.txd")
	engineImportTXD(txd, 16442)
	local dff = engineLoadDFF("public/models/rod.dff", 16442)
	engineReplaceModel(dff, 16442)

	local txd = engineLoadTXD("public/models/pro.txd")
	engineImportTXD(txd, 2799)
	local dff = engineLoadDFF("public/models/pro.dff", 2799)
	engineReplaceModel(dff, 2799)
	engineReplaceCOL(col, 2799)

	local txd = engineLoadTXD("public/models/bikerhelmet.txd")
	engineImportTXD(txd, 3911)
	local dff = engineLoadDFF("public/models/bikerhelmet.dff", 3911)
	engineReplaceModel(dff, 3911)
	engineReplaceCOL(col, 3911)

	local txd = engineLoadTXD("public/models/fullfacehelmet.txd")
	engineImportTXD(txd, 3917)
	local dff = engineLoadDFF("public/models/fullfacehelmet.dff", 3917)
	engineReplaceModel(dff, 3917)
	engineReplaceCOL(col, 3917)

	local txd = engineLoadTXD("public/models/gasmask.txd")
	engineImportTXD(txd, 3890)
	local dff = engineLoadDFF("public/models/gasmask.dff", 3890)
	engineReplaceModel(dff, 3890)

	local txd = engineLoadTXD("public/models/dufflebag.txd")
	engineImportTXD(txd, 3915)
	local dff = engineLoadDFF("public/models/dufflebag.dff", 3915)
	engineReplaceModel(dff, 3915)

	local txd = engineLoadTXD("public/models/kevlar.txd")
	engineImportTXD(txd, 3916)
	local dff = engineLoadDFF("public/models/kevlar.dff", 3916)
	engineReplaceModel(dff, 3916)
end

addEventHandler("onClientResourceStart", resourceRoot, function()
	replaceModels()
	setTimer(replaceModels, 1000, 1)
end)
