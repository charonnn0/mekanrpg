local ids = {}

local function findFreeID()
	for i = 1, getMaxPlayers() do
		if not ids[i] then
			return i
		end
	end
	return nil
end

local function assignPlayerID(player)
	local id = findFreeID()
	if not id then
		return
	end

	ids[id] = player
	setElementData(player, "id", id)
	exports.mek_pool:allocateElement(player, id)

	if not getElementData(player, "logged") then
		setElementData(player, "legal_name_change", true)
		setPlayerName(player, "Mekan." .. id)
		setElementData(player, "legal_name_change", false)
	end
end

addEventHandler("onPlayerJoin", root, function()
	assignPlayerID(source)

	exports.mek_logs:addLog(
		"giriş-çıkış",
		getPlayerName(source):gsub("_", " ")
			.. " sunucuya katıldı.;IP: "
			.. getPlayerIP(source)
			.. ";Serial: "
			.. getPlayerSerial(source)
	)
end)

addEventHandler("onPlayerQuit", root, function(reason)
	local id = getElementData(source, "id")
	if id then
		ids[id] = nil
	end

	exports.mek_logs:addLog(
		"giriş-çıkış",
		getPlayerName(source):gsub("_", " ")
			.. " sunucudan ayrıldı. ("
			.. reason
			.. ");IP: "
			.. getPlayerIP(source)
			.. ";Serial: "
			.. getPlayerSerial(source)
	)

	if exports.mek_integration:isPlayerTrialAdmin(source) then
		exports.mek_discord:sendMessage(
			"staff-activeness",
			exports.mek_global:getPlayerFullAdminTitle(source)
				.. " isimli yetkili sunucudan ayrıldı ve "
				.. (getElementData(source, "temporary_hours_played") or 0)
				.. " saat "
				.. (getElementData(source, "temporary_minutes_played") or 0)
				.. " dakikadır sunucudaydı."
		)
	end
end)

for _, player in ipairs(getElementsByType("player")) do
	assignPlayerID(player)
end
