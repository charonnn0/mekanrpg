setTimer(function()
	if _voiceStatus == VoiceStatus.DISABLED then
		return false
	end

	if not localPlayer:getData("logged") then
		return false
	end

	if exports.mek_item:isInventoryVisible() then
		return
	end

	if not exports.mek_settings:getPlayerSetting(localPlayer, "voice_channels_visible") then
		return false
	end

	if _voiceStatus == VoiceStatus.ADMIN_ONLY then
		if
			not exports.mek_integration:isPlayerTrialAdmin(localPlayer)
			and not exports.mek_global:isAdminOnDuty(localPlayer)
		then
			return false
		end
	end

	local currentChannel = localPlayer:getData("voice_channel") or VoiceChannel.NEAR
	local collapsable = _voiceStatus == VoiceStatus.ADMIN_ONLY

	local tabSize = {
		x = 42,
		y = 42,
	}
	local tabPosition = {
		x = screenSize.x - tabSize.x,
		y = screenSize.y / 2 - tabSize.y / 2,
	}

	dxDrawText(
		"",
		tabPosition.x + 1,
		tabPosition.y - tabSize.y + 1,
		tabPosition.x + tabSize.x,
		tabPosition.y,
		rgba(theme.GRAY[900]),
		0.5,
		fonts.icon,
		"center",
		"center"
	)
	dxDrawText(
		"",
		tabPosition.x,
		tabPosition.y - tabSize.y,
		tabPosition.x + tabSize.x,
		tabPosition.y,
		rgba(theme.GRAY[50]),
		0.5,
		fonts.icon,
		"center",
		"center"
	)

	for i, channel in ipairs(voiceChannels) do
		local isRadioActive = localPlayer:getData("radio_active")
		local isActive = i == VoiceChannel.RADIO and isRadioActive or currentChannel == i

		if channel.canSwitch(localPlayer) then
			dxDrawGradient(tabPosition.x, tabPosition.y, tabSize.x, tabSize.y, 0, 0, 0, 225, false, false)

			dxDrawText(
				channel.icon,
				tabPosition.x,
				tabPosition.y,
				tabPosition.x + tabSize.x,
				tabPosition.y + tabSize.y,
				isActive and rgba(getServerColor(2)) or rgba(theme.GRAY[300]),
				0.5,
				fonts.icon,
				"center",
				"center"
			)

			local hover = inArea(tabPosition.x, tabPosition.y, tabSize.x, tabSize.y)
			if hover then
				local nameWidth = dxGetTextWidth(channel.name, 1, fonts.UbuntuRegular.body) + 20
				local nameSize = {
					x = nameWidth,
					y = tabSize.y,
				}
				local namePosition = {
					x = tabPosition.x - nameWidth,
					y = tabPosition.y,
				}

				dxDrawText(
					channel.name,
					namePosition.x + 1,
					namePosition.y + 1,
					namePosition.x + nameSize.x + 1,
					namePosition.y + nameSize.y + 1,
					rgba(theme.GRAY[900]),
					1,
					fonts.UbuntuRegular.body,
					"center",
					"center"
				)
				dxDrawText(
					channel.name,
					namePosition.x,
					namePosition.y,
					namePosition.x + nameSize.x,
					namePosition.y + nameSize.y,
					isActive and rgba(getServerColor(2)) or rgba(theme.GRAY[300]),
					1,
					fonts.UbuntuRegular.body,
					"center",
					"center"
				)

				if inArea(tabPosition.x, tabPosition.y, tabSize.x, tabSize.y) and isKeyPressed("mouse1") then
					if i == VoiceChannel.RADIO then
						triggerServerEvent("voice.radio.toggleState", localPlayer)
					else
						setEntityChannel(i)
					end
				end
			end

			tabPosition.y = tabPosition.y + tabSize.y + 2
		end
	end
end, 0, 0)
