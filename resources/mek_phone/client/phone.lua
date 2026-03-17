screenSize = Vector2(guiGetScreenSize())

aspectRatio = 5

if screenSize.y < 650 then
	aspectRatio = 5.5
end

Phone = {
	enums = {
		Rotation = {
			Vertical = 0,
			Horizontal = 1,
		},
		Apps = {
			Home = "home",

			Contacts = "contacts",
			Call = "call",
			Gallery = "gallery",
			Camera = "camera",
			Bank = "bank",
			Settings = "settings",
		},
	},
}
Phone.visible = false
Phone.frameSize = {
	x = math.floor(1606 / aspectRatio),
	y = math.floor(3196 / aspectRatio),
}

Phone.framePosition = {
	x = screenSize.x - Phone.frameSize.x - 15,
	y = screenSize.y - Phone.frameSize.y - 30,
}

Phone.innerSize = {
	x = Phone.frameSize.x - 29,
	y = Phone.frameSize.y - 24,
}

Phone.innerPosition = {
	x = Phone.framePosition.x + 15,
	y = Phone.framePosition.y + 12,
}
Phone.rotationGap = Phone.frameSize.y - Phone.frameSize.x
Phone.number = nil
Phone.rotation = Phone.enums.Rotation.Vertical

Phone.components = {}

Phone.weekDays = {
	[0] = "Pazar",
	[1] = "Pazartesi",
	[2] = "Salı",
	[3] = "Çarşamba",
	[4] = "Perşembe",
	[5] = "Cuma",
	[6] = "Cumartesi",
}

Phone.months = {
	"Ocak",
	"Şubat",
	"Mart",
	"Nisan",
	"Mayıs",
	"Haziran",
	"Temmuz",
	"Ağustos",
	"Eylül",
	"Ekim",
	"Kasım",
	"Aralık",
}

Phone.backgroundID = 1
Phone.apps = {}

function Phone.showNotification(errorType, message)
	exports.mek_infobox:addBox(errorType, message)
end
addEvent("phone.showNotification", true)
addEventHandler("phone.showNotification", root, Phone.showNotification)

function Phone.addApp(key, callback, icon, name, styles, onOpen, onClose)
	theme = useTheme()
	theme.GRAY[900] = "#000000"

	Phone.apps[key] = {
		callback = callback,
		icon = icon,
		name = name,
		styles = styles and styles(theme) or {
			background = theme.GRAY[900],
			foreground = theme.GRAY[50],
		},
		onOpen = onOpen,
		onClose = onClose,
	}
end

function Phone.render()
	theme = useTheme()
	fonts = useFonts()

	local serverTime = getRealTime()

	time = string.format("%02d:%02d", serverTime.hour, serverTime.minute)
	dayTime = (serverTime.monthday or 0)
		.. " "
		.. Phone.months[(serverTime.month or 0) + 1]
		.. " "
		.. Phone.weekDays[serverTime.weekday or 0]

	Phone.frameSize = {
		x = 1606 / aspectRatio,
		y = 3196 / aspectRatio,
	}

	Phone.framePosition = {
		x = screenSize.x - Phone.frameSize.x - 15,
		y = screenSize.y - Phone.frameSize.y - 30,
	}

	Phone.innerSize = {
		x = Phone.frameSize.x - 30,
		y = Phone.frameSize.y - 27,
	}

	Phone.innerPosition = {
		x = Phone.framePosition.x + 15,
		y = Phone.framePosition.y + 13,
	}

	local animation = PhoneAnimation.get(localPlayer)

	if Phone.currentApp == Phone.enums.Apps.Call then
		Phone.innerPosition.y = screenSize.y - 85
		Phone.framePosition.y = screenSize.y - 85 - 12
		if Call.currentPage == Call.enums.Pages.Active and animation ~= PhoneAnimation.In then
			PhoneAnimation.process(localPlayer, PhoneAnimation.In)
		end
	elseif Phone.currentApp == Phone.enums.Apps.Camera then
		if animation ~= PhoneAnimation.Camera then
			PhoneAnimation.process(localPlayer, PhoneAnimation.Camera)
		end
	else
		if animation ~= PhoneAnimation.Hold then
			PhoneAnimation.process(localPlayer, PhoneAnimation.Hold)
		end
	end

	if Phone.rotation == Phone.enums.Rotation.Horizontal then
		Phone.innerSize = {
			x = Phone.innerSize.y,
			y = Phone.innerSize.x,
		}
		Phone.frameSize = {
			x = Phone.frameSize.y,
			y = Phone.frameSize.x,
		}
		Phone.framePosition = {
			x = screenSize.x - Phone.innerSize.x - 30,
			y = screenSize.y - Phone.innerSize.y - 50,
		}
		Phone.innerPosition = {
			x = Phone.framePosition.x + 13,
			y = Phone.framePosition.y + 15,
		}
	end

	local currentApp = Phone.apps[Phone.currentApp]
	styles = currentApp.styles

	dxDrawImage(
		Phone.innerPosition.x,
		Phone.innerPosition.y,
		Phone.innerSize.x,
		Phone.innerSize.y,
		"public/background/white.png",
		0,
		0,
		0,
		rgba(styles.background)
	)

	currentApp.callback(Phone.innerPosition, Phone.innerSize)
	Phone.components.layout()

	dxDrawImage(
		Phone.framePosition.x,
		Phone.framePosition.y,
		Phone.frameSize.x,
		Phone.frameSize.y,
		Phone.frameTexture[Phone.rotation]
	)
end

function Phone.show(number, ignoreRedirect)
	if Phone.visible then
		Phone.hide()
		return
	end

	if localPlayer:getData("pd_jailed") or localPlayer:getData("admin_jailed") then
		outputChatBox("[!]#FFFFFF Ceza durumunda telefon kullanamazsınız.", 255, 0, 0, true)
		return
	end

	Phone.number = tonumber(number)
	requestBrowserDomains({
		"https://api.imgur.com/3/image",
		"api.imgur.com",
		"imgur.com",
		"i.imgur.com",
		"https://api.imgur.com",
	})

	if not ignoreRedirect and Phone.currentApp ~= Phone.enums.Apps.Call then
		Phone.goToApp(Phone.enums.Apps.Home)
		PhoneAnimation.process(localPlayer, PhoneAnimation.Hold)
	end

	if not isEventHandlerAdded("onClientRender", root, Phone.render) then
		addEventHandler("onClientRender", root, Phone.render)
	end

	Phone.rotation = Phone.enums.Rotation.Vertical
	Phone.visible = true
end
addEvent("phone.show", true)
addEventHandler("phone.show", localPlayer, Phone.show)

function Phone.hide()
	if isEventHandlerAdded("onClientRender", root, Phone.render) then
		removeEventHandler("onClientRender", root, Phone.render)
	end

	Call.destroyAllSounds()
	Phone.visible = false
	PhoneAnimation.process(localPlayer, nil)
	guiSetInputEnabled(false)

	if Phone.currentApp then
		local onClose = Phone.apps[Phone.currentApp].onClose
		if onClose then
			onClose()
		end
	end

	if Phone.currentApp == Phone.enums.Apps.Camera then
		setCameraTarget(localPlayer)
	end
end
addEvent("phone.hide", true)
addEventHandler("phone.hide", localPlayer, Phone.hide)

function Phone.goToApp(app)
	if Phone.currentApp == Phone.enums.Apps.Camera then
		setCameraTarget(localPlayer)
	end

	if Phone.currentApp then
		local onClose = Phone.apps[Phone.currentApp].onClose
		if onClose then
			onClose()
		end
	end

	Phone.currentApp = app
	Phone.rotation = Phone.enums.Rotation.Vertical

	local onOpen = Phone.apps[app].onOpen
	if onOpen then
		onOpen()
	end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
	Phone.frameTexture = {
		[Phone.enums.Rotation.Horizontal] = dxCreateTexture("public/frames/frame_horizontal.png", "dxt5"),
		[Phone.enums.Rotation.Vertical] = dxCreateTexture("public/frames/frame.png", "dxt5"),
	}
end)

function inAreaInRenderTarget(position, size, containerPosition)
	return inArea(containerPosition.x + position.x, containerPosition.y + position.y, size.x, size.y)
end

local spamTimer = false
local isRctrlPressed = false

addEventHandler("onClientKey", root, function(button, state)
	if not localPlayer:getData("logged") then
		return
	end

	if button == "rctrl" then
		isRctrlPressed = state
		cancelEvent()
	end

	if state then
		if localPlayer:getData("writing") then
			return
		end

		if isChatBoxInputActive() or isConsoleActive() then
			return
		end

		if isRctrlPressed and button == "arrow_u" then
			if isTimer(spamTimer) then
				return
			end

			spamTimer = setTimer(function()
				isRctrlPressed = false
			end, 750, 1)

			local hasPhone, _, number = exports.mek_item:hasItem(localPlayer, 2)
			if hasPhone then
				Phone.show(number)
			end
		elseif button == "arrow_d" and Phone.visible then
			cancelEvent()
			Phone.hide()
			
			Call.sounds.lock = playSound("public/sounds/lock.mp3")
			setSoundVolume(Call.sounds.lock, 0.5)

			if Phone.currentApp ~= Phone.enums.Apps.Call then
				triggerServerEvent(
					"phone.answerCall",
					localPlayer,
					Phone.number,
					Call.incomingNumber or Call.activeNumber or Call.outgoingNumber,
					false
				)
			end
		end
	end
end)

function isVisible()
	return Phone.visible
end
