local CONTROLS = {
	"fire",
	"aim_weapon",
	"next_weapon",
	"previous_weapon",
	"forwards",
	"backwards",
	"left",
	"right",
	"zoom_in",
	"zoom_out",
	"change_camera",
	"jump",
	"sprint",
	"look_behind",
	"crouch",
	"action",
	"walk",
	"conversation_yes",
	"conversation_no",
	"group_control_forwards",
	"group_control_back",
	"enter_exit",
	"vehicle_fire",
	"vehicle_secondary_fire",
	"vehicle_left",
	"vehicle_right",
	"steer_forward",
	"steer_back",
	"accelerate",
	"brake_reverse",
	"radio_next",
	"radio_previous",
	"radio_user_track_skip",
	"horn",
	"sub_mission",
	"handbrake",
	"vehicle_look_left",
	"vehicle_look_right",
	"vehicle_look_behind",
	"vehicle_mouse_look",
	"special_control_left",
	"special_control_right",
	"special_control_down",
	"special_control_up",
	"left",
	"right",
	"forwards",
	"backwards",
	"vehicle_left",
	"vehicle_right",
	"steer_forward",
	"steer_back",
	"accelerate",
	"brake_reverse",
	"special_control_left",
	"special_control_right",
	"special_control_up",
	"special_control_down",
}

addEventHandler("onClientResourceStart", resourceRoot, function()
	setTimer(checkPlayer, 500, 0, localPlayer)
	setTimer(handleControls, 500, 0, localPlayer)
end)

addEventHandler("onClientPlayerWeaponSwitch", localPlayer, function()
	if
		getElementData(source, "dead")
		or getElementData(source, "cked")
		or getElementData(source, "is_dragged")
		or getElementData(source, "tazed")
		or getElementData(source, "proned")
		or getElementData(source, "restrained")
		or getElementData(source, "frozen")
	then
		setPedWeaponSlot(localPlayer, 0)
	end
end)

function checkPlayer(thePlayer)
	if
		getElementData(thePlayer, "dead")
		or getElementData(thePlayer, "cked")
		or getElementData(thePlayer, "is_dragged")
		or getElementData(thePlayer, "tazed")
		or getElementData(thePlayer, "proned")
		or getElementData(thePlayer, "restrained")
		or getElementData(thePlayer, "frozen")
	then
		setPedWeaponSlot(thePlayer, 0)
	end
end

function handleControls(thePlayer)
	if
		getElementData(thePlayer, "dead")
		or getElementData(thePlayer, "cked")
		or getElementData(thePlayer, "is_dragged")
		or getElementData(thePlayer, "tazed")
		or getElementData(thePlayer, "proned")
		or getElementData(thePlayer, "frozen")
	then
		for _, control in pairs(CONTROLS) do
			toggleControl(control, false)
		end
	else
		for _, control in pairs(CONTROLS) do
			toggleControl(control, true)
		end
	end
end
