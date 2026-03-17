local transferRequests = {}
local nextTransferId = 1

addEventHandler("onResourceStart", resourceRoot, function()
	local connection = exports.mek_mysql:getConnection()
	dbExec(connection, [[
		CREATE TABLE IF NOT EXISTS transferler (
			id INT AUTO_INCREMENT PRIMARY KEY,
			sender_account_id INT NOT NULL,
			target_account_id INT NOT NULL,
			sender_name VARCHAR(64) NOT NULL,
			target_name VARCHAR(64) NOT NULL,
			amount INT NOT NULL,
			reason VARCHAR(255) NOT NULL,
			status ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
			created_at DATETIME NOT NULL,
			approved_by VARCHAR(64) NULL,
			approved_at DATETIME NULL,
			rejected_by VARCHAR(64) NULL,
			rejected_at DATETIME NULL,
			rejection_reason VARCHAR(255) NULL
		)
	]])

	local qh = dbQuery(connection, "SELECT * FROM transferler WHERE status = 'pending'")
	local rows = dbPoll(qh, -1) or {}
	for _, row in ipairs(rows) do
		transferRequests[row.id] = {
			id = row.id,
			sender = nil,
			target = nil,
			senderAccountId = tonumber(row.sender_account_id),
			targetAccountId = tonumber(row.target_account_id),
			senderName = row.sender_name,
			targetName = row.target_name,
			amount = tonumber(row.amount),
			reason = row.reason,
			status = row.status,
			createdAt = row.created_at
		}
	end
end)

local function sanitizeReason(text)
    if not text then return "" end
    local cleaned = tostring(text)
    cleaned = cleaned:gsub("\r\n", " ")
    cleaned = cleaned:gsub("\n", " ")
    cleaned = cleaned:gsub("\r", " ")
    cleaned = cleaned:gsub("#%x%x%x%x%x%x", "")
    if #cleaned > 128 then
        cleaned = cleaned:sub(1, 125) .. "..."
    end
    return cleaned
end

function giveBalance(thePlayer, amount)
    setElementData(thePlayer, "balance", math.floor(getElementData(thePlayer, "balance") + amount))
    dbExec(exports.mek_mysql:getConnection(), "UPDATE accounts SET balance = ? WHERE id = ?", getElementData(thePlayer, "balance"), getElementData(thePlayer, "account_id"))
end

function takeBalance(thePlayer, amount)
    setElementData(thePlayer, "balance", math.floor(getElementData(thePlayer, "balance") - amount))
    dbExec(exports.mek_mysql:getConnection(), "UPDATE accounts SET balance = ? WHERE id = ?", getElementData(thePlayer, "balance"), getElementData(thePlayer, "account_id"))
end

function setBalance(thePlayer, amount)
    setElementData(thePlayer, "balance", math.floor(amount))
    dbExec(exports.mek_mysql:getConnection(), "UPDATE accounts SET balance = ? WHERE id = ?", getElementData(thePlayer, "balance"), getElementData(thePlayer, "account_id"))
end

addEvent("onBakiyeTransferRequest", true)
addEventHandler("onBakiyeTransferRequest", root, function(targetName, amount, reason)
    local thePlayer = source
    
    if not getElementData(thePlayer, "logged") then
        outputChatBox("[!] #FFFFFFÖnce giriş yapmalısınız.", thePlayer, 255, 0, 0, true)
        return
    end
    
    if not targetName or targetName == "" then
        outputChatBox("[!] #FFFFFFHedef oyuncu adını girin.", thePlayer, 255, 0, 0, true)
        return
    end
    
    if not amount or amount <= 0 then
        outputChatBox("[!] #FFFFFFGeçerli bir miktar girin.", thePlayer, 255, 0, 0, true)
        return
    end
    
    if not reason or reason == "" then
        outputChatBox("[!] #FFFFFFTransfer nedeni girin.", thePlayer, 255, 0, 0, true)
        return
    end
    
    local playerBalance = getElementData(thePlayer, "balance") or 0
    if playerBalance < amount then
        outputChatBox("[!] #FFFFFFYeterli bakiyeniz yok.", thePlayer, 255, 0, 0, true)
        return
    end
    
    local targetPlayer, targetPlayerName = exports.mek_global:findPlayerByPartialNick(thePlayer, targetName)
    if not targetPlayer then
        outputChatBox("[!] #FFFFFFHedef oyuncu bulunamadı veya online değil.", thePlayer, 255, 0, 0, true)
        return
    end
    
    if targetPlayer == thePlayer then
        outputChatBox("[!] #FFFFFFKendinize bakiye transfer edemezsiniz.", thePlayer, 255, 0, 0, true)
        return
    end
    
    if not getElementData(targetPlayer, "logged") then
        outputChatBox("[!] #FFFFFFBu oyuncu karakterine giriş yapmadığı için işlem gerçekleşmedi.", thePlayer, 255, 0, 0, true)
        return
    end
    
    local playerName = getPlayerName(thePlayer):gsub("_", " ")
    local targetResolvedName = getPlayerName(targetPlayer):gsub("_", " ")
    local currentTime = os.date("%Y-%m-%d %H:%M:%S")
	local senderAccountId = getElementData(thePlayer, "account_id")
	local targetAccountId = getElementData(targetPlayer, "account_id")

	local connection = exports.mek_mysql:getConnection()
	dbExec(connection,
		"INSERT INTO transferler (sender_account_id, target_account_id, sender_name, target_name, amount, reason, status, created_at) VALUES (?,?,?,?,?,?, 'pending', ?)",
		senderAccountId, targetAccountId, playerName, targetResolvedName, amount, sanitizeReason(reason), currentTime)

	local qh = dbQuery(connection, "SELECT LAST_INSERT_ID() AS id")
	local res = dbPoll(qh, -1)
	local requestId = res and res[1] and tonumber(res[1].id) or nextTransferId
	if not requestId then requestId = nextTransferId end
	nextTransferId = requestId + 1

	transferRequests[requestId] = {
		id = requestId,
		sender = thePlayer,
		target = targetPlayer,
		senderAccountId = senderAccountId,
		targetAccountId = targetAccountId,
		senderName = playerName,
		targetName = targetResolvedName,
		amount = amount,
		reason = sanitizeReason(reason),
		status = "pending",
		createdAt = currentTime
	}
    
    outputChatBox("[!] #FFFFFFTransfer isteğiniz başarıyla gönderildi. Üst yönetim kurulu tarafından onaylanması bekleniyor.", thePlayer, 0, 255, 0, true)
    
    local adminMessage = "[BAKİYE-TRANSFER-İSTEĞİ] " .. playerName .. " isimli oyuncu " .. targetPlayerName .. " isimli oyuncuya " .. exports.mek_global:formatMoney(amount) .. " TL transfer isteği gönderdi. ID: " .. requestId
    if exports.mek_global then
        exports.mek_global:sendMessageToAdmins(adminMessage)
    else
        for _, admin in ipairs(getElementsByType("player")) do
            if exports.mek_integration:isPlayerManager(admin) then
                outputChatBox(adminMessage, admin, 255, 255, 0, true)
            end
        end
    end
    
    exports.mek_logs:addLog("bakiyetransfer", adminMessage)
end)

addEvent("onRequestTransferHistory", true)
addEventHandler("onRequestTransferHistory", root, function()
	local thePlayer = source
	
	if not getElementData(thePlayer, "logged") then
		return
	end
	
	local accountId = getElementData(thePlayer, "account_id")
	local connection = exports.mek_mysql:getConnection()
	local qh = dbQuery(connection, [[
		SELECT target_name AS target, amount, created_at AS date, status
		FROM transferler
		WHERE sender_account_id = ?
		ORDER BY created_at DESC
		LIMIT 50
	]], accountId)
	local rows = dbPoll(qh, -1) or {}
	
	local history = {}
	for _, row in ipairs(rows) do
		row.amount = tonumber(row.amount) or 0
		table.insert(history, {
			target = row.target,
			amount = row.amount,
			date = row.date,
			status = row.status
		})
	end
	
	triggerClientEvent(thePlayer, "onTransferHistoryReceived", thePlayer, history)
end)

function onaylaTransfer(thePlayer, commandName, requestId)
    if not exports.mek_integration:isPlayerManager(thePlayer) then
        outputChatBox("[!] #FFFFFFBu komutu kullanma yetkiniz yok.", thePlayer, 255, 0, 0, true)
        return
    end
    
    if not requestId then
        outputChatBox("[!] #FFFFFFKULLANIM: /onayla [Transfer ID]", thePlayer, 255, 194, 14, true)
        return
    end
    
    requestId = tonumber(requestId)
    if not requestId then
        outputChatBox("[!] #FFFFFFGeçerli bir transfer ID girin.", thePlayer, 255, 0, 0, true)
        return
    end
    
    local transferRequest = nil
    for id, request in pairs(transferRequests) do
        if id == requestId then
            transferRequest = request
            break
        end
    end
    
    if not transferRequest then
        outputChatBox("[!] #FFFFFFTransfer isteği bulunamadı.", thePlayer, 255, 0, 0, true)
        return
    end
    
    if transferRequest.status ~= "pending" then
        outputChatBox("[!] #FFFFFFBu transfer isteği zaten işlenmiş.", thePlayer, 255, 0, 0, true)
        return
    end
    
    local senderElement = transferRequest.sender
    local targetElement = transferRequest.target
    local senderOnline = isElement(senderElement) and getElementData(senderElement, "logged")
    local targetOnline = isElement(targetElement) and getElementData(targetElement, "logged")

    local connection = exports.mek_mysql:getConnection()

    local senderAccountId = transferRequest.senderAccountId
    local targetAccountId = transferRequest.targetAccountId

    local senderBalance
    if senderOnline then
        senderBalance = getElementData(senderElement, "balance") or 0
    else
        local qh = dbQuery(connection, "SELECT balance FROM accounts WHERE id = ?", senderAccountId)
        local result = dbPoll(qh, -1)
        if not result or not result[1] then
            outputChatBox("[!] #FFFFFFGönderen hesabı bulunamadı.", thePlayer, 255, 0, 0, true)
            return
        end
        senderBalance = tonumber(result[1].balance) or 0
    end

    if senderBalance < transferRequest.amount then
        outputChatBox("[!] #FFFFFFGönderen oyuncunun yeterli bakiyesi yok.", thePlayer, 255, 0, 0, true)
        return
    end

    local targetBalance
    if targetOnline then
        targetBalance = getElementData(targetElement, "balance") or 0
    else
        local qh2 = dbQuery(connection, "SELECT balance FROM accounts WHERE id = ?", targetAccountId)
        local result2 = dbPoll(qh2, -1)
        if not result2 or not result2[1] then
            outputChatBox("[!] #FFFFFFHedef hesabı bulunamadı.", thePlayer, 255, 0, 0, true)
            return
        end
        targetBalance = tonumber(result2[1].balance) or 0
    end

    local newSenderBalance = senderBalance - transferRequest.amount
    local newTargetBalance = targetBalance + transferRequest.amount

    dbExec(connection, "UPDATE accounts SET balance = ? WHERE id = ?", newSenderBalance, senderAccountId)
    dbExec(connection, "UPDATE accounts SET balance = ? WHERE id = ?", newTargetBalance, targetAccountId)

    if senderOnline then
        setElementData(senderElement, "balance", newSenderBalance)
    end
    if targetOnline then
        setElementData(targetElement, "balance", newTargetBalance)
    end

    transferRequests[requestId].status = "approved"
    transferRequests[requestId].approvedBy = getPlayerName(thePlayer):gsub("_", " ")
    transferRequests[requestId].approvedAt = os.date("%Y-%m-%d %H:%M:%S")

	dbExec(connection, "UPDATE transferler SET status='approved', approved_by=?, approved_at=NOW() WHERE id = ?", adminName, requestId)
	transferRequests[requestId] = transferRequests[requestId] or {}
    
    local adminName = getPlayerName(thePlayer):gsub("_", " ")
    if senderOnline then
        outputChatBox("[!] #FFFFFF" .. adminName .. " isimli admin tarafından " .. transferRequest.targetName .. " isimli oyuncuya " .. exports.mek_global:formatMoney(transferRequest.amount) .. " TL bakiyeniz transfer edildi.", senderElement, 0, 255, 0, true)
    end
    if targetOnline then
        outputChatBox("[!] #FFFFFF" .. adminName .. " isimli admin tarafından " .. transferRequest.senderName .. " isimli oyuncudan " .. exports.mek_global:formatMoney(transferRequest.amount) .. " TL bakiye transfer edildi.", targetElement, 0, 0, 255, true)
    end
    
    outputChatBox("[!] #FFFFFFTransfer isteği başarıyla onaylandı.", thePlayer, 0, 255, 0, true)

	if exports.mek_global then
		local adminBroadcast = "[BAKİYE-TRANSFER-ONAY] " .. adminName .. " isimli admin, ID:" .. requestId .. " olan isteği onayladı: " .. transferRequest.senderName .. " -> " .. transferRequest.targetName .. " | " .. exports.mek_global:formatMoney(transferRequest.amount) .. " TL"
		exports.mek_global:sendMessageToAdmins(adminBroadcast)
	end
    
    local message = "[BAKİYE-TRANSFER-ONAYLANDI] " .. adminName .. " isimli admin " .. transferRequest.senderName .. " isimli oyuncunun " .. transferRequest.targetName .. " isimli oyuncuya " .. exports.mek_global:formatMoney(transferRequest.amount) .. " TL transfer isteğini onayladı."
    exports.mek_logs:addLog("bakiyetransfer", message)
end
addCommandHandler("onayla", onaylaTransfer, false, false)

function reddetTransfer(thePlayer, commandName, requestId, reason)
    if not exports.mek_integration:isPlayerManager(thePlayer) then
        outputChatBox("[!] #FFFFFFBu komutu kullanma yetkiniz yok.", thePlayer, 255, 0, 0, true)
        return
    end
    
    if not requestId then
        outputChatBox("[!] #FFFFFFKULLANIM: /reddet [Transfer ID] [Sebep]", thePlayer, 255, 194, 14, true)
        return
    end
    
    requestId = tonumber(requestId)
    if not requestId then
        outputChatBox("[!] #FFFFFFGeçerli bir transfer ID girin.", thePlayer, 255, 0, 0, true)
        return
    end
    
    reason = reason or "Sebep belirtilmedi"
    
    local transferRequest = nil
    for id, request in pairs(transferRequests) do
        if id == requestId then
            transferRequest = request
            break
        end
    end
    
    if not transferRequest then
        outputChatBox("[!] #FFFFFFTransfer isteği bulunamadı.", thePlayer, 255, 0, 0, true)
        return
    end
    
    if transferRequest.status ~= "pending" then
        outputChatBox("[!] #FFFFFFBu transfer isteği zaten işlenmiş.", thePlayer, 255, 0, 0, true)
        return
    end
    
    transferRequests[requestId].status = "rejected"
    transferRequests[requestId].rejectedBy = getPlayerName(thePlayer):gsub("_", " ")
    transferRequests[requestId].rejectedAt = os.date("%Y-%m-%d %H:%M:%S")
    transferRequests[requestId].rejectionReason = reason

	local connection = exports.mek_mysql:getConnection()
	dbExec(connection, "UPDATE transferler SET status='rejected', rejected_by=?, rejected_at=NOW(), rejection_reason=? WHERE id=?", transferRequests[requestId].rejectedBy, sanitizeReason(reason), requestId)
    
    local sender = transferRequest.sender
    if isElement(sender) and getElementData(sender, "logged") then
        local adminName = getPlayerName(thePlayer):gsub("_", " ")
        outputChatBox("[!] #FFFFFFTransfer isteğiniz " .. adminName .. " isimli admin tarafından reddedildi. Sebep: " .. reason, sender, 255, 0, 0, true)
    end
    
    outputChatBox("[!] #FFFFFFTransfer isteği başarıyla reddedildi.", thePlayer, 0, 255, 0, true)

	if exports.mek_global then
		local adminName = getPlayerName(thePlayer):gsub("_", " ")
		local adminBroadcast = "[BAKİYE-TRANSFER-RED] " .. adminName .. " isimli admin, ID:" .. requestId .. " olan isteği reddetti: " .. transferRequest.senderName .. " -> " .. transferRequest.targetName .. " | " .. exports.mek_global:formatMoney(transferRequest.amount) .. " TL | Sebep: " .. sanitizeReason(reason)
		exports.mek_global:sendMessageToAdmins(adminBroadcast)
	end
    
    local adminName = getPlayerName(thePlayer):gsub("_", " ")
    local message = "[BAKİYE-TRANSFER-REDDEDİLDİ] " .. adminName .. " isimli admin " .. transferRequest.senderName .. " isimli oyuncunun " .. transferRequest.targetName .. " isimli oyuncuya " .. exports.mek_global:formatMoney(transferRequest.amount) .. " TL transfer isteğini reddetti. Sebep: " .. reason
    exports.mek_logs:addLog("bakiyetransfer", message)
end
addCommandHandler("reddet", reddetTransfer, false, false)

function listeleTransferler(thePlayer, commandName)
    if not exports.mek_integration:isPlayerManager(thePlayer) then
        outputChatBox("[!] #FFFFFFBu komutu kullanma yetkiniz yok.", thePlayer, 255, 0, 0, true)
        return
    end
    
    outputChatBox("=== BEKLEYEN TRANSFER İSTEKLERİ ===", thePlayer, 255, 255, 0, true)
    
    local found = false
    for id, request in pairs(transferRequests) do
        if request.status == "pending" then
            local reason = sanitizeReason(request.reason)
            if #reason > 64 then
                reason = reason:sub(1, 61) .. "..."
            end
            outputChatBox("ID:" .. id .. " | " .. request.senderName .. " -> " .. request.targetName .. " | " .. exports.mek_global:formatMoney(request.amount) .. " TL", thePlayer, 255, 255, 255, true)
            outputChatBox("Sebep: " .. reason, thePlayer, 200, 200, 200, true)
            found = true
        end
    end
    
    if not found then
        outputChatBox("Bekleyen transfer isteği bulunmuyor.", thePlayer, 255, 255, 255, true)
    end
end
addCommandHandler("transferler", listeleTransferler, false, false)