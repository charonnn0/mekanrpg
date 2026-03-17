Call = {
	enums = {
		Pages = {
			Outgoing = "outgoing",
			Incoming = "incoming",
			Active = "active",
		},
	},
}

Call.sounds = {}
Call.components = {}
Call.currentPage = Call.enums.Pages.Outgoing

Call.addPage = function(page, callback)
	Call.components[page] = callback
end

Call.destroyAllSounds = function()
	for _, sound in pairs(Call.sounds) do
		if isElement(sound) then
			destroyElement(sound)
		end
	end

	CallSoundStreamer.destroyAllSounds()
end

Phone.addApp(Phone.enums.Apps.Call, function(position, size)
	local currentPage = Call.components[Call.currentPage]
	if currentPage then
		currentPage(position, size)
	end
end, "public/apps/phone.png", "Ara")
