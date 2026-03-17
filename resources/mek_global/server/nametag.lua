function updateNametagColor(thePlayer)
	if source then
		thePlayer = source
	end

	if not getElementData(thePlayer, "logged") then
		setPlayerNametagColor(thePlayer, 127, 127, 127)
		return
	end

	if exports.mek_integration:isPlayerTrialAdmin(thePlayer) and getElementData(thePlayer, "duty_admin") then
		setPlayerNametagColor(thePlayer, 255, 0, 0)
		return
	end

	local badge = getElementData(thePlayer, "badge")
	if badge and badge.color then
		setPlayerNametagColor(thePlayer, badge.color[1], badge.color[2], badge.color[3])
		return
	end
	
	if getElementData(thePlayer, "job") == 2 then
		setPlayerNametagColor(thePlayer, 250, 210, 5)
		return
	end
	
	if getElementData(thePlayer, "mechanic") and getElementData(thePlayer, "mechanic_duty") then
		setPlayerNametagColor(thePlayer, 101, 67, 33)
		return
	end

	if getElementData(thePlayer, "rp_plus") then
		setPlayerNametagColor(thePlayer, 176, 136, 78)
		return
	end

	setPlayerNametagColor(thePlayer, 255, 255, 255)
end
addEvent("updateNametagColor", true)
addEventHandler("updateNametagColor", root, updateNametagColor)

for _, player in ipairs(getElementsByType("player")) do
	updateNametagColor(player)
end
