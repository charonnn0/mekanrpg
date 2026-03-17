local securityNumber = 5
local resetTimer = nil

function createWeaponSerial(methodSpawned, spawnedBy, givenTo)
	if not givenTo then
		givenTo = spawnedBy
	end

	securityNumber = securityNumber + 1
	local buffer = tostring(getRealTime().timestamp - 1314835200)
	buffer = buffer .. "/"
	buffer = buffer .. methodSpawned
	buffer = buffer .. "/"
	buffer = buffer .. spawnedBy
	buffer = buffer .. "/"
	buffer = buffer .. securityNumber

	if not resetTimer then
		resetTimer = setTimer(resetWeaponSecurityNumber, 60000, 1)
	end

	local buff2 = weaponenc(string.reverse(buffer))

	return buff2
end

function resetWeaponSecurityNumber()
	securityNumber = 5
	resetTimer = nil
end
