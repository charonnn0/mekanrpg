local maxLoginAttempts = 10
local restrictionDuration = 10000
local connectionAttempts = {}
local serverStartTime = getTickCount()

addEventHandler("onPlayerConnect", root, function()
	local currentTime = getTickCount()
	local serverPassword = getServerPassword()

	if currentTime - serverStartTime < 60000 and not serverPassword then
		cancelEvent(true, "Sunucu başlatıldıktan sonra 1 dakika boyunca giriş yapılamaz, lütfen bekleyin.")
		return
	end

	for i = #connectionAttempts, 1, -1 do
		if currentTime - connectionAttempts[i] > restrictionDuration then
			table.remove(connectionAttempts, i)
		end
	end

	table.insert(connectionAttempts, currentTime)

	if #connectionAttempts > maxLoginAttempts then
		cancelEvent(true, "Çok fazla giriş denemesi yapıldı, lütfen bekleyin.")
	end
end)
