local GUIEditor = {
	button = {},
	window = {},
	label = {},
	memo = {},
}

local function generateMapContent(objects)
	local buffer = '<map edf:definitions="editor_main">'
	for i, obj in ipairs(objects) do
		if string.find(tostring(obj.id), "removeWorldObject") then
			buffer = buffer
				.. "\n    "
				.. '<removeWorldObject id="object ('
				.. i
				.. ')" radius="'
				.. obj.radius
				.. '" interior="'
				.. obj.interior
				.. '" model="'
				.. obj.model
				.. '" posX="'
				.. obj.posX
				.. '" posY="'
				.. obj.posY
				.. '" posZ="'
				.. obj.posZ
				.. '" rotX="'
				.. obj.rotX
				.. '" rotY="'
				.. obj.rotY
				.. '" rotZ="'
				.. obj.rotZ
				.. '"></removeWorldObject>'
		else
			buffer = buffer
				.. "\n    "
				.. '<object id="object ('
				.. i
				.. ')" breakable="'
				.. (obj.breakable == 0 and "false" or "true")
				.. '" interior="0" alpha="'
				.. (obj.alpha and obj.alpha or 255)
				.. '" model="'
				.. obj.model
				.. '" doublesided="'
				.. (obj.doublesided == 0 and "false" or "true")
				.. '" scale="'
				.. (obj.scale and obj.scale or "1.0000000")
				.. '" dimension="0" posX="'
				.. obj.posX
				.. '" posY="'
				.. obj.posY
				.. '" posZ="'
				.. obj.posZ
				.. '" rotX="'
				.. obj.rotX
				.. '" rotY="'
				.. obj.rotY
				.. '" rotZ="'
				.. obj.rotZ
				.. '"></object>'
		end
	end
	buffer = buffer .. "\n</map>"
	return buffer
end

addEvent("maps.exportInteriorMap", true)
addEventHandler("maps.exportInteriorMap", resourceRoot, function(objects)
	closeExporter()
	GUIEditor.window[1] = guiCreateWindow(
		562,
		184,
		800,
		600,
		"Harita Objeleri Dışa Aktarıcısı - Interior #" .. objects[1].dimension,
		false
	)
	guiWindowSetSizable(GUIEditor.window[1], false)
	exports.mek_global:centerWindow(GUIEditor.window[1])
	local content = generateMapContent(objects)
	GUIEditor.memo[1] = guiCreateMemo(9, 22, 781, 525, content or "", false, GUIEditor.window[1])
	GUIEditor.button[1] = guiCreateButton(679, 557, 111, 29, "Kapat", false, GUIEditor.window[1])
	GUIEditor.button[2] = guiCreateButton(558, 557, 111, 29, "Dosyaya kaydet", false, GUIEditor.window[1])
	GUIEditor.button[3] = guiCreateButton(437, 557, 111, 29, "Panoya kopyala", false, GUIEditor.window[1])
	GUIEditor.label[1] = guiCreateLabel(
		13,
		556,
		401,
		30,
		"Açıklama: " .. (objects[1].comment and objects[1].comment or "Bilinmiyor"),
		false,
		GUIEditor.window[1]
	)
	guiLabelSetVerticalAlign(GUIEditor.label[1], "center")

	addEventHandler("onClientGUIClick", GUIEditor.window[1], function()
		if source == GUIEditor.button[1] then
			closeExporter()
		elseif source == GUIEditor.button[2] then
			local file = fileCreate("exported/Interior-" .. objects[1].dimension .. ".map")
			if file then
				fileWrite(file, content)
				fileClose(file)
				triggerEvent("playSuccess", localPlayer)
				outputChatBox(
					"[!]#FFFFFF Tamamdır! Dosya MTA klasörünüzde '/mods/deathmatch/resources/mek_map-manager/exported/Interior-"
						.. objects[1].dimension
						.. ".map' konumunda bulunmaktadır.",
					0,
					255,
					0,
					true
				)
			else
				triggerEvent("playError", localPlayer)
				outputChatBox("[!]#FFFFFF Veriler dosyaya yazılırken hatalar oluştu.", 255, 0, 0, true)
			end
		elseif source == GUIEditor.button[3] then
			if setClipboard(content) then
				triggerEvent("playSuccess", localPlayer)
			end
		end
	end)
end)

addEvent("maps.exportExteriorMap", true)
addEventHandler("maps.exportExteriorMap", resourceRoot, function(objects)
	closeExporter()
	GUIEditor.window[1] = guiCreateWindow(
		562,
		184,
		800,
		600,
		"Harita Objeleri Dışa Aktarıcısı - Exterior #" .. objects[1].map_id,
		false
	)
	guiWindowSetSizable(GUIEditor.window[1], false)
	exports.mek_global:centerWindow(GUIEditor.window[1])
	local content = generateMapContent(objects)
	GUIEditor.memo[1] = guiCreateMemo(9, 22, 781, 525, content or "", false, GUIEditor.window[1])
	GUIEditor.button[1] = guiCreateButton(679, 557, 111, 29, "Kapat", false, GUIEditor.window[1])
	GUIEditor.button[2] = guiCreateButton(558, 557, 111, 29, "Dosyaya kaydet", false, GUIEditor.window[1])
	GUIEditor.button[3] = guiCreateButton(437, 557, 111, 29, "Panoya kopyala", false, GUIEditor.window[1])
	GUIEditor.label[1] = guiCreateLabel(
		13,
		556,
		401,
		30,
		"Açıklama: " .. (objects[1].comment and objects[1].comment or "Bilinmiyor"),
		false,
		GUIEditor.window[1]
	)
	guiLabelSetVerticalAlign(GUIEditor.label[1], "center")

	addEventHandler("onClientGUIClick", GUIEditor.window[1], function()
		if source == GUIEditor.button[1] then
			closeExporter()
		elseif source == GUIEditor.button[2] then
			local file = fileCreate("exported/Exterior-" .. objects[1].map_id .. ".map")
			if file then
				fileWrite(file, content)
				fileClose(file)
				triggerEvent("playSuccess", localPlayer)
				outputChatBox(
					"[!]#FFFFFF Tamamdır! Dosya MTA klasörünüzde '/mods/deathmatch/resources/mek_map-manager/exported/Exterior-"
						.. objects[1].map_id
						.. ".map' konumunda bulunmaktadır.",
					0,
					255,
					0,
					true
				)
			else
				triggerEvent("playError", localPlayer)
				outputChatBox("[!]#FFFFFF Veriler dosyaya yazılırken hatalar oluştu.", 255, 0, 0, true)
			end
		elseif source == GUIEditor.button[3] then
			if setClipboard(content) then
				triggerEvent("playSuccess", localPlayer)
			end
		end
	end)
end)

function closeExporter()
	if GUIEditor.window[1] and isElement(GUIEditor.window[1]) then
		destroyElement(GUIEditor.window[1])
		GUIEditor.window[1] = nil
	end
end
