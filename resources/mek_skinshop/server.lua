addEvent("skinshop.buy", true)
addEventHandler("skinshop.buy", root, function(data)
	if client and source and client ~= source then
		exports.mek_sac:banForEventAbuse(client, eventName)
		return
	end

	if not data then
		return
	end

	local price = 100
	if not exports.mek_global:hasMoney(source, price) then
		exports.mek_infobox:addBox(source, "error", "Kıyafeti alabilmek için yeterli paranız yok.")
		return
	end

	local itemValue = ""
	if type(data) == "number" then
		itemValue = data .. ";0;0"
	elseif type(data) == "table" and data.model then
		itemValue = "0;0;" .. tonumber(data.model)
	else
		return
	end

	if not exports.mek_item:hasSpaceForItem(source, 16, itemValue) then
		exports.mek_infobox:addBox(source, "error", "Kıyafeti alabilmek için envanterinizde yeterli alan yok.")
		return
	end

	exports.mek_global:takeMoney(source, price)
	exports.mek_item:giveItem(source, 16, itemValue)
	exports.mek_infobox:addBox(source, "success", "Kıyafeti başarıyla satın aldınız.")
end)
