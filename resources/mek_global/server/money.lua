local TAX_LIMIT = 30
local INCOME_TAX_LIMIT = 25

local tax = 15
local incomeTax = 10

function getTaxAmount()
	return tax / 100
end

function setTaxAmount(new)
	tax = clamp(math.ceil(tonumber(new) or 0), 0, TAX_LIMIT)
end

function getIncomeTaxAmount()
	return incomeTax / 100
end

function setIncomeTaxAmount(new)
	incomeTax = clamp(math.ceil(tonumber(new) or 0), 0, INCOME_TAX_LIMIT)
end

function giveMoney(element, amount)
	amount = tonumber(amount) or 0
	if amount == 0 then
		return true
	elseif element and isElement(element) and amount > 0 then
		amount = math.floor(amount)
		if getElementType(element) == "player" then
			dbExec(
				exports.mek_mysql:getConnection(),
				"UPDATE characters SET money = money + ? WHERE id = ?",
				amount,
				getElementData(element, "dbid")
			)
			setElementData(element, "money", getMoney(element) + amount)
			triggerClientEvent(element, "financeUpdate", element, true, amount)
			return true
		elseif getElementType(element) == "team" then
			dbExec(
				exports.mek_mysql:getConnection(),
				"UPDATE factions SET money = money + ? WHERE id = ?",
				amount,
				getElementData(element, "id")
			)
			setElementData(element, "money", getMoney(element) + amount)
			return true
		end
	end
	return false
end

function takeMoney(element, amount, rest)
	amount = tonumber(amount) or 0
	if amount == 0 then
		return true
	elseif element and isElement(element) and amount > 0 then
		amount = math.ceil(amount)

		local money = getMoney(element)
		if rest and amount > money then
			amount = money
		end

		if amount == 0 then
			return true
		elseif hasMoney(element, amount) then
			if getElementType(element) == "player" then
				dbExec(
					exports.mek_mysql:getConnection(),
					"UPDATE characters SET money = money - ? WHERE id = ?",
					amount,
					getElementData(element, "dbid")
				)
				setElementData(element, "money", money - amount)
				triggerClientEvent(element, "financeUpdate", element, false, amount)
				return true
			elseif getElementType(element) == "team" then
				dbExec(
					exports.mek_mysql:getConnection(),
					"UPDATE factions SET money = money - ? WHERE id = ?",
					amount,
					getElementData(element, "id")
				)
				setElementData(element, "money", money - amount)
				return true
			end
		end
	end
	return false
end

function setMoney(element, amount, onSpawn)
	amount = tonumber(amount) or 0
	if element and isElement(element) and (amount >= 0 or onSpawn) then
		amount = math.floor(amount)
		if getElementType(element) == "player" then
			if not onSpawn then
				if
					not dbExec(
						exports.mek_mysql:getConnection(),
						"UPDATE characters SET money = ? WHERE id = ?",
						amount,
						getElementData(element, "dbid")
					)
				then
					return false
				end
			end

			local currentMoney = getElementData(element, "money")

			if not setElementData(element, "money", amount) then
				return false
			end

			if not onSpawn then
				if amount > currentMoney then
					triggerClientEvent(element, "financeUpdate", element, true, amount - currentMoney)
				elseif amount < currentMoney then
					triggerClientEvent(element, "financeUpdate", element, false, currentMoney - amount)
				end
			end

			return true
		elseif getElementType(element) == "team" then
			dbExec(
				exports.mek_mysql:getConnection(),
				"UPDATE factions SET money = ? WHERE id = ?",
				amount,
				getElementData(element, "id")
			)
			setElementData(element, "money", amount)
			return true
		end
	end
	return false
end

function giveBankMoney(element, amount)
	amount = tonumber(amount) or 0
	if amount == 0 then
		return true
	elseif element and isElement(element) and amount > 0 then
		amount = math.floor(amount)
		if getElementType(element) == "player" then
			dbExec(
				exports.mek_mysql:getConnection(),
				"UPDATE characters SET bank_money = bank_money + ? WHERE id = ?",
				amount,
				getElementData(element, "dbid")
			)
			setElementData(element, "bank_money", getBankMoney(element) + amount)
			return true
		end
	end
	return false
end

function takeBankMoney(element, amount, rest)
	amount = tonumber(amount) or 0
	if amount == 0 then
		return true
	elseif element and isElement(element) and amount > 0 then
		amount = math.ceil(amount)

		local money = getBankMoney(element)
		if rest and amount > money then
			amount = money
		end

		if amount == 0 then
			return true
		elseif hasBankMoney(element, amount) then
			if getElementType(element) == "player" then
				dbExec(
					exports.mek_mysql:getConnection(),
					"UPDATE characters SET bank_money = bank_money - ? WHERE id = ?",
					amount,
					getElementData(element, "dbid")
				)
				setElementData(element, "bank_money", money - amount)
				return true, amount
			end
		end
	end
	return false
end

function setBankMoney(element, amount)
	amount = tonumber(amount) or 0
	if element and isElement(element) and amount >= 0 then
		amount = math.floor(amount)
		if getElementType(element) == "player" then
			dbExec(
				exports.mek_mysql:getConnection(),
				"UPDATE characters SET bank_money = ? WHERE id = ?",
				amount,
				getElementData(element, "dbid")
			)
			setElementData(element, "bank_money", amount)
			return true
		end
	end
	return false
end
