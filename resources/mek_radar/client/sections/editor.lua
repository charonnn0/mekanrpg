Radar.ZoneEditor = {}
Radar.ZoneEditor.Enabled = false
Radar.ZoneEditor.Positions = {}
Radar.ZoneEditor.RealPositions = {}

addCommandHandler("editor", function()
	if not exports.mek_integration:isPlayerServerOwner(localPlayer) then
		return false
	end

	Radar.ZoneEditor.Enabled = not Radar.ZoneEditor.Enabled
	outputChatBox(
		"[!]#FFFFFF Harita editörü " .. (Radar.ZoneEditor.Enabled and "Açıldı" or "Kapatıldı"),
		0,
		255,
		0,
		true
	)
end, false, false)

addCommandHandler("editorsifirla", function()
	if not exports.mek_integration:isPlayerServerOwner(localPlayer) then
		return false
	end

	Radar.ZoneEditor.Positions = {}
	Radar.ZoneEditor.RealPositions = {}

	outputChatBox("[!]#FFFFFF Bölge pozisyonları sıfırlandı.", 0, 255, 0, true)
end, false, false)

addCommandHandler("editorgerial", function()
	if not exports.mek_integration:isPlayerServerOwner(localPlayer) then
		return false
	end

	if not (#Radar.ZoneEditor.Positions > 0) then
		outputChatBox("[!]#FFFFFF Önce konum ekleyiniz", 255, 0, 0, true)
		return false
	end

	local totalPositions = #Radar.ZoneEditor.Positions
	table.remove(Radar.ZoneEditor.Positions, totalPositions)
	table.remove(Radar.ZoneEditor.Positions, totalPositions - 1)

	local totalPositions = #Radar.ZoneEditor.RealPositions
	table.remove(Radar.ZoneEditor.RealPositions, totalPositions)

	outputChatBox("[!]#FFFFFF Bir önceki konum silindi.", 0, 255, 0, true)
end, false, false)

addCommandHandler("editorkaydet", function()
	if not exports.mek_integration:isPlayerServerOwner(localPlayer) then
		return false
	end

	triggerServerEvent("hood.management.add", localPlayer, Radar.ZoneEditor.Positions)

	Radar.ZoneEditor.Positions = {}
	Radar.ZoneEditor.RealPositions = {}
end, false, false)
