Twitter = {}
Twitter.padding = 15
Twitter.state = {
    loading = false,
    hasAccount = false,
    fullName = "",
    compose = "",
    lastTweetAt = 0,
}

local function drawTwitterHeader(onClick, header, rightSection)
    Phone.components.Header(function(headerPosition, headerSize)
        dxDrawText(
            header or "Twitter",
            headerPosition.x + Twitter.padding,
            headerPosition.y + 10,
            0,
            0,
            rgba(theme.BLUE[400]),
            1,
            fonts.BebasNeueBold.h1
        )

        if rightSection then
            rightSection()
        else
            dxDrawText(
                Twitter.state.hasAccount and (Twitter.state.fullName or "") or "hoşgeldiniz!",
                headerPosition.x - Twitter.padding,
                headerPosition.y + 22,
                headerPosition.x + headerSize.x - Twitter.padding,
                0,
                rgba(theme.GRAY[600]),
                1,
                fonts.UbuntuRegular.caption,
                "right"
            )
        end
    end, onClick)
end

local function drawCreateAccount(position, size)
    local nameInput = drawInput({
        position = {
            x = position.x + Twitter.padding,
            y = position.y + Twitter.padding * 8,
        },
        size = {
            x = size.x - Twitter.padding * 2,
            y = 35,
        },
        name = "twitter.fullname",

        label = "İsim Soyisim",
        placeholder = "örn: John Doe",

        variant = "outlined",
        color = "gray",
        disabled = Twitter.state.loading,
    })

    local createBtn = drawButton({
        position = {
            x = position.x + Twitter.padding,
            y = position.y + Twitter.padding * 15,
        },
        size = {
            x = size.x - Twitter.padding * 2,
            y = 35,
        },

        variant = "soft",
        color = "blue",
        text = "Hesap Oluştur",
        disabled = Twitter.state.loading,
    })

    if createBtn.pressed and not Twitter.state.loading then
        local fullName = (nameInput.value or ""):gsub("^%s+", ""):gsub("%s+$", "")
        if #fullName < 3 then
            Phone.showNotification("error", "İsim en az 3 karakter olmalıdır.")
            return
        end
        Twitter.state.loading = true
        triggerServerEvent("twitter.createAccount", localPlayer, Phone.number, fullName)
    end
end

local function secondsToClock(s)
    local m = math.floor(s / 60)
    local r = s % 60
    return string.format("%02d:%02d", m, r)
end

local function drawCompose(position, size)
    local infoText = "Herkese açık tweet atarsınız. 5 dakikada bir atabilirsiniz."
    dxDrawText(
        infoText,
        position.x + Twitter.padding,
        position.y + Twitter.padding * 7,
        position.x + size.x - Twitter.padding,
        0,
        rgba(theme.GRAY[500]),
        1,
        fonts.UbuntuRegular.caption,
        "left",
        "top",
        true,
        true
    )

    local composeInput = drawInput({
        position = {
            x = position.x + Twitter.padding,
            y = position.y + Twitter.padding * 10,
        },
        size = {
            x = size.x - Twitter.padding * 2,
            y = 80,
        },
        name = "twitter.compose",

        label = "Ne oluyor?",
        placeholder = "Mesajınızı yazın...",

        value = Twitter.state.compose,
        multiline = true,
        maxLength = 200,

        variant = "outlined",
        color = "gray",
        disabled = Twitter.state.loading,
    })

    Twitter.state.compose = composeInput.value or ""

    local sendBtn = drawButton({
        position = {
            x = position.x + Twitter.padding,
            y = position.y + Twitter.padding * 20,
        },
        size = {
            x = size.x - Twitter.padding * 2,
            y = 35,
        },

        variant = "soft",
        color = "blue",
        text = "Gönder",
        disabled = Twitter.state.loading or (#(Twitter.state.compose or "") == 0),
    })

    if sendBtn.pressed and not Twitter.state.loading then
        Twitter.state.loading = true
        triggerServerEvent("twitter.tweet", localPlayer, Phone.number, Twitter.state.compose)
    end
end

Phone.addApp(Phone.enums.Apps.Twitter, function(position, size, onClick, header, rightSection)
    drawTwitterHeader(onClick, header, rightSection)

    if not Twitter.state.initialized then
        Twitter.state.initialized = true
        triggerServerEvent("twitter.ensureAccount", localPlayer, Phone.number)
    end

    if not Twitter.state.hasAccount then
        drawCreateAccount(position, size)
    else
        drawCompose(position, size)
    end
end, "public/apps/twitter.png", "Twitter")

addEvent("twitter.onEnsureAccount", true)
addEventHandler("twitter.onEnsureAccount", root, function(response)
    if not response.success then
        Phone.showNotification("error", response.message or "Twitter hesabı doğrulanamadı.")
        return
    end
    if response.exists then
        Twitter.state.hasAccount = true
        Twitter.state.fullName = response.account.fullName
        Twitter.state.lastTweetAt = tonumber(response.account.lastTweetAt or 0) or 0
    else
        Twitter.state.hasAccount = false
    end
end)

addEvent("twitter.onCreateAccount", true)
addEventHandler("twitter.onCreateAccount", root, function(response)
    Twitter.state.loading = false
    if not response.success then
        Phone.showNotification("error", response.message or "Hesap oluşturulamadı.")
        return
    end
    Twitter.state.hasAccount = true
    Twitter.state.fullName = response.account.fullName
    Twitter.state.lastTweetAt = 0
    Phone.showNotification("success", "Hesap oluşturuldu.")
end)

addEvent("twitter.onTweetResult", true)
addEventHandler("twitter.onTweetResult", root, function(response)
    Twitter.state.loading = false
    if response.success then
        Twitter.state.compose = ""
        Twitter.state.lastTweetAt = tonumber(response.nowTs or getRealTime().timestamp)
        Phone.showNotification("success", "Tweet gönderildi.")
    else
        if response.code == "rate_limit" then
            local remaining = tonumber(response.remaining or 0) or 0
            Phone.showNotification("error", "Hız sınırı: " .. secondsToClock(remaining) .. " sonra tekrar deneyin.")
        else
            Phone.showNotification("error", response.message or "Tweet gönderilemedi.")
        end
    end
end)
