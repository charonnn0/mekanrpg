function getPropertyTaxRate(interiorType, faction)
	if not interiorType then
		interiorType = 0
	end

	local propertyTaxRate = 0.0005
	if interiorType == 1 or faction then
		propertyTaxRate = propertyTaxRate + 0.0002
	end

	return propertyTaxRate
end

function hasMoney(thePlayer, amount)
	amount = tonumber(amount) or 0
	if thePlayer and isElement(thePlayer) and amount > 0 then
		amount = math.floor(amount)
		return getMoney(thePlayer) >= amount
	end
	return false
end

function getMoney(element)
	if element and isElement(element) then
		return getElementData(element, "money") or 0
	end
	return 0
end

function hasBankMoney(element, amount)
	amount = tonumber(amount) or 0
	if element and isElement(element) and amount >= 0 then
		amount = math.floor(amount)
		return getBankMoney(element) >= amount
	end
	return false
end

function getBankMoney(element)
	return getElementData(element, "bank_money") or 0
end

function formatMoney(amount)
	if not amount or not tonumber(amount) or amount == 0 then
		return 0
	end
	local left, num, right = string.match(tostring(amount), "^([^%d]*%d)(%d*)(.-)$")
	return left .. (num:reverse():gsub("(%d%d%d)", "%1,"):reverse()) .. right
end
