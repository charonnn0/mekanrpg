local Superman = {}

addEvent("superman.start", true)
addEvent("superman.stop", true)

function Superman.Start()
	local self = Superman
	addEventHandler("superman.start", root, self.clientStart)
	addEventHandler("superman.stop", root, self.clientStop)
end
addEventHandler("onResourceStart", resourceRoot, Superman.Start, false)

function Superman.clientStart()
	if not client or not isElement(client) or getElementType(client) ~= "player" then
		return
	end

	if source ~= client then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not exports.mek_integration:isPlayerTrialAdmin(client) or not getElementData(client, "duty_admin") then
		return
	end

	setElementData(client, "superman", true)
end

function Superman.clientStop()
	if not client or not isElement(client) or getElementType(client) ~= "player" then
		return
	end

	if source ~= client then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not exports.mek_integration:isPlayerTrialAdmin(client) or not getElementData(client, "duty_admin") then
		return
	end

	removeElementData(client, "superman")
end

function isPlayerFlying(player)
	return getElementData(player, "superman")
end
