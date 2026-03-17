local staffTitles = {
	[1] = {
		[0] = "Oyuncu",
		[1] = "Stajyer Yetkili",
		[2] = "Oyun İçi Yetkili I",
		[3] = "Oyun İçi Yetkili II",
		[4] = "Oyun İçi Yetkili III",
		[5] = "Kıdemli Yetkili",
		[6] = "Genel Yetkili",
		[7] = "Manager",
		[8] = "Developer",
		[9] = "Sunucu Sahibi",
	},
	[2] = {
		[0] = "Oyuncu",
		[1] = "Üst Yönetim Kurulu",
	},
}

function getStaffTitle(teamID, rankID)
	return staffTitles[tonumber(teamID)][tonumber(rankID)]
end

function getStaffTitles()
	return staffTitles
end

function getAdminTitles()
	return staffTitles[1]
end

function getAdminTitle(rankID)
	return staffTitles[1][tonumber(rankID)] or "Oyuncu"
end

function getPlayerAdminTitle(player)
	if not player or not isElement(player) or not getElementType(player) == "player" then
		return false
	end
	local adminLevel = getElementData(player, "admin_level") or 0
	return staffTitles[1][adminLevel] or "Oyuncu"
end

function isPlayerServerFounder(player, dutyRequired)
	if not player or not isElement(player) or not (getElementType(player) == "player") then
		return false
	end

	local adminLevel = getElementData(player, "admin_level") or 0
	if dutyRequired then
		return getElementData(player, "duty_admin") and (adminLevel == 9)
	end
	return (adminLevel == 9)
end

function isPlayerServerOwner(player, dutyRequired)
	if not player or not isElement(player) or not getElementType(player) == "player" then
		return false
	end

	local adminLevel = getElementData(player, "admin_level") or 0
	if dutyRequired then
		return getElementData(player, "duty_admin") and (adminLevel >= 8)
	end
	return (adminLevel >= 8)
end

function isPlayerServerManager(player, dutyRequired)
	if not player or not isElement(player) or not getElementType(player) == "player" then
		return false
	end

	local adminLevel = getElementData(player, "admin_level") or 0
	if dutyRequired then
		return getElementData(player, "duty_admin") and (adminLevel >= 7)
	end
	return (adminLevel >= 7)
end

function isPlayerGeneralAdmin(player, dutyRequired)
	if not player or not isElement(player) or not getElementType(player) == "player" then
		return false
	end

	local adminLevel = getElementData(player, "admin_level") or 0
	if dutyRequired then
		return getElementData(player, "duty_admin") and (adminLevel >= 6)
	end
	return (adminLevel >= 6)
end

function isPlayerSeniorAdmin(player, dutyRequired)
	if not player or not isElement(player) or not getElementType(player) == "player" then
		return false
	end

	local adminLevel = getElementData(player, "admin_level") or 0
	if dutyRequired then
		return getElementData(player, "duty_admin") and (adminLevel >= 5)
	end
	return (adminLevel >= 5)
end

function isPlayerAdmin3(player, dutyRequired)
	if not player or not isElement(player) or not getElementType(player) == "player" then
		return false
	end

	local adminLevel = getElementData(player, "admin_level") or 0
	if dutyRequired then
		return getElementData(player, "duty_admin") and (adminLevel >= 4)
	end
	return (adminLevel >= 4)
end

function isPlayerAdmin2(player, dutyRequired)
	if not player or not isElement(player) or not getElementType(player) == "player" then
		return false
	end

	local adminLevel = getElementData(player, "admin_level") or 0
	if dutyRequired then
		return getElementData(player, "duty_admin") and (adminLevel >= 3)
	end
	return (adminLevel >= 3)
end

function isPlayerAdmin1(player, dutyRequired)
	if not player or not isElement(player) or not getElementType(player) == "player" then
		return false
	end

	local adminLevel = getElementData(player, "admin_level") or 0
	if dutyRequired then
		return getElementData(player, "duty_admin") and (adminLevel >= 2)
	end
	return (adminLevel >= 2)
end

function isPlayerTrialAdmin(player, dutyRequired)
	if not player or not isElement(player) or not getElementType(player) == "player" then
		return false
	end

	local adminLevel = getElementData(player, "admin_level") or 0
	if dutyRequired then
		return getElementData(player, "duty_admin") and (adminLevel >= 1)
	end
	return (adminLevel >= 1)
end

function isPlayerManager(player, dutyRequired)
	if not player or not isElement(player) or not getElementType(player) == "player" then
		return false
	end

	local managerLevel = getElementData(player, "manager_level") or 0
	if dutyRequired then
		return getElementData(player, "duty_admin") and (managerLevel >= 1)
	end
	return (managerLevel >= 1)
end

function canAdminPunish(executor, target)
	if not executor or not target then return false end
	if not isElement(executor) or getElementType(executor) ~= "player" then return false end
	
	if isElement(target) and getElementType(target) == "player" then
		local executorLevel = getElementData(executor, "admin_level") or 0
		local targetLevel = getElementData(target, "admin_level") or 0
		
		return executorLevel > targetLevel
	end
	
	return true
end