local socials = {
	{
		key = "discord",
		header = "Discord Sunucumuz",
		message = "Topluluğa katılmak için Discord sunucumuza gelin! Tıklayarak linki kopyalayın.",
		url = "https://discord.gg/Mekanrp",
	},
	{
		key = "instagram",
		header = "Instagram Hesabımız",
		message = ("@%s hesabımızı takip et, etkinlikleri kaçırma!"):format("Mekanroleplay"),
		url = "https://www.instagram.com/Mekanroleplay",
	},
	{
		key = "youtube",
		header = "YouTube Kanalımız",
		message = "Yeni videolar için kanalımıza göz atın! Tıklayıp linki kopyalayın, abone olun!",
		url = "https://www.youtube.com/@Mekanroleplay",
	},
	{
		key = "tiktok",
		header = "TikTok Hesabımız",
		message = "Eğlenceli videolar için bizi takip et! Tıklayarak linki kopyalayabilirsin.",
		url = "https://www.tiktok.com/@Mekanroleplay",
	},
}

local function announceSocialMediaAccounts()
	if not localPlayer:getData("logged") then
		return false
	end

	local social = socials[math.random(1, #socials)]
	addBox(social.key, {
		header = social.header,
		message = social.message,
	}, 15000, "bottom-center", social.url)
end
--setTimer(announceSocialMediaAccounts, 1000 * 60 * 5, 0)
