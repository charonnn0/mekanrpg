Webhooks = {
	["staff-activeness"] = {
		url = "https://discord.com/api/webhooks/1454181266642440334/0TFTDY1CDLy16pCHUOK3U9FOER-XSYnOn3AfU_X4ChDraUs9v8e7zLcaZOoGPaJrD0Fm",
		avatar = "https://cdn.discordapp.com/attachments/1394796862082519251/1454151547578482781/unnamed_4-Photoroom.png?ex=69500ba9&is=694eba29&hm=8ae8a7e87d112f8829c90d5cbe3a062ad08c920ba7c0d6c772c795df160943f5&",
		username = "Mekan Roleplay",
	},
	["log"] = {
		url = "https://discord.com/api/webhooks/1454418864589766667/gmaCISePz_KfIazKecsqkCL1h6pLSUvcJfv2YgnWcUwhGqKiYyeXUbdOJqr8Q2RmlM0a",
		avatar = "https://cdn.discordapp.com/attachments/1394796862082519251/1454151547578482781/unnamed_4-Photoroom.png?ex=69500ba9&is=694eba29&hm=8ae8a7e87d112f8829c90d5cbe3a062ad08c920ba7c0d6c772c795df160943f5&",
		username = "Mekan Roleplay",
	},
	["giveaway"] = {
		url = "https://discord.com/api/webhooks/1454181756617097429/FtyAjUDOpmbH8LvN0ErIK7hFKakxUDnEUeIgY1SaD7kDkJzLIhxUhU1uo0UxSAsBa4mS",
		avatar = "https://cdn.discordapp.com/attachments/1394796862082519251/1454151547578482781/unnamed_4-Photoroom.png?ex=69500ba9&is=694eba29&hm=8ae8a7e87d112f8829c90d5cbe3a062ad08c920ba7c0d6c772c795df160943f5&",
		username = "Mekan Roleplay",
	},
	["market-log"] = {
		url = "https://discord.com/api/webhooks/1454181872027439277/iVhP0TKaGRp372PWlPaELOM-hRbSZFgFAcmI8ejaDWCI4pPJfU-VrzTUYy1ateHZ8v46",
		avatar = "https://cdn.discordapp.com/attachments/1394796862082519251/1454151547578482781/unnamed_4-Photoroom.png?ex=69500ba9&is=694eba29&hm=8ae8a7e87d112f8829c90d5cbe3a062ad08c920ba7c0d6c772c795df160943f5&",
		username = "Mekan Roleplay",
	},
	["sac-log"] = {
		url = "https://discord.com/api/webhooks/1454176965773885673/h31fc7HDPFDrATmMAXHBlU3iK4vxa4k3oHhNPv-_Djl2Xm5kLRVWXCwEECjq1UeqZSl3",
		avatar = "https://cdn.discordapp.com/attachments/1394796862082519251/1454151547578482781/unnamed_4-Photoroom.png?ex=69500ba9&is=694eba29&hm=8ae8a7e87d112f8829c90d5cbe3a062ad08c920ba7c0d6c772c795df160943f5&",
		username = "Mekan Roleplay",
	},
	["cicek-logs"] = {
		url = "https://discord.com/api/webhooks/1466446774049964066/eqxyGtSgqkMgQiElnQY919u6vJwuTjZfrEWN5cSpkQBeDfDaA2FtTMgPhm5thHQwlQ2g",
		avatar = "https://cdn.discordapp.com/attachments/1466446761781367010/1466446867184484372/D49305D2-8233-46E1-B983-3A3BE2BE9FAA.png?ex=697cc692&is=697b7512&hm=7b279c27f669474a92e548aa9410e92cc3ca63c114f35f49912e3335d8635973&",
		username = "Cicek Sistem",
	},
}
WebhookList = {}
WebhookDebug = false

WebhookClass = setmetatable({
	constructor = function(self, args)
		self.username = Webhooks[args].username
		self.url = Webhooks[args].url
		self.avatar = Webhooks[args].avatar

		if WebhookDebug then
			outputDebugString("[Webhook] Created channel '" .. args .. "'.")
		end

		return self
	end,

	send = function(self, message)
		local sendOptions = {
			connectionAttempts = 3,
			connectTimeout = 5000,
			formFields = {
				content = ((message):gsub("@everyone", "")):gsub("@here", ""),
				username = self.username,
				avatar_url = self.avatar,
			},
		}

		fetchRemote(self.url, sendOptions, function(responseData, errors)
			if WebhookDebug then
				outputDebugString("[Webhook] Response Data: " .. tostring(responseData))
				outputDebugString("[Webhook] Error Code: " .. tostring(errors))
			end
		end)
	end,
}, {
	__call = function(cls, ...)
		local self = {}
		setmetatable(self, { __index = cls })
		self:constructor(...)
		return self
	end,
})

addEventHandler("onResourceStart", resourceRoot, function()
	for name, data in pairs(Webhooks) do
		WebhookList[name] = WebhookClass(name)
	end
end)

function sendMessage(channel, message)
	if WebhookList[channel] then
		WebhookList[channel]:send(message)
		if WebhookDebug then
			outputDebugString("[Webhook] Send message '" .. message .. "' from '" .. channel .. "' channel.")
		end
	else
		outputDebugString("[Webhook] Couldn't find the Discord Webhook Channel. (" .. channel .. ")")
	end
end
