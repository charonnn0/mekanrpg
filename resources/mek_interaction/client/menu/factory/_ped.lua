function menuPedCollector(ped)
	local interactions = {}

	local interaction = ped:getData("interaction")
	if not interaction then
		return false
	end

	local callbackEvent, args = interaction.callbackEvent, interaction.args
	local callbackText = interaction.callbackText or "Konuş"

	table.insert(interactions, {
		text = callbackText,
		callback = function()
			triggerEvent(callbackEvent, localPlayer, ped, unpack(args))
		end,
	})

	createMenuContext(ped, interactions)
end
