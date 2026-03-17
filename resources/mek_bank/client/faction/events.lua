local ped = createPed(240, 359.712890625, 173.533203125, 1008.3828125, 270)
setElementInterior(ped, 3)
setElementDimension(ped, 11)
setElementFrozen(ped, true)
setElementData(ped, "name", "Fatih Duman")
setElementData(ped, "interaction", {
	callbackEvent = "bank.faction.onInteraction",
	args = {},
	description = ped:getData("name"):gsub("_", " "),
})

addEvent("bank.faction.onInteraction", true)
addEventHandler("bank.faction.onInteraction", root, function()
	showPage("faction")
end)
