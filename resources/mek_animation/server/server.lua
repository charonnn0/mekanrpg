local walk = {
	"WALK_armed",
	"WALK_civi",
	"WALK_csaw",
	"WOMAN_walksexy",
	"WALK_drunk",
	"WALK_fat",
	"WALK_fatold",
	"WALK_gang1",
	"WALK_gang2",
	"WALK_old",
	"WALK_player",
	"WALK_rocket",
	"WALK_shuffle",
	"Walk_Wuzi",
	"woman_run",
	"WOMAN_runbusy",
	"WOMAN_runfatold",
	"woman_runpanic",
	"WOMAN_runsexy",
	"WOMAN_walkbusy",
	"WOMAN_walkfatold",
	"WOMAN_walknorm",
	"WOMAN_walkold",
	"WOMAN_walkpro",
	"WOMAN_walksexy",
	"WOMAN_walkshop",
	"run_1armed",
	"run_armed",
	"run_civi",
	"run_csaw",
	"run_fat",
	"run_fatold",
	"run_old",
	"run_player",
	"run_rocket",
	"Run_Wuzi",
}

local ignoredCommands = {
	["decodeEvent"] = true,
	["anims"] = true,
	["animasyonlar"] = true,
}

addEventHandler("onPlayerJoin", root, function()
	bindKey(source, "space", "down", stopAnimation)
end)

addEventHandler("onResourceStart", resourceRoot, function()
	for _, player in pairs(getElementsByType("player")) do
		bindKey(player, "space", "down", stopAnimation)
	end
end)

function stopAnimation(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer)
	end
end

function coverAnimation(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "ped", "duck_cower", -1, false, false, false)
	end
end
addCommandHandler("cop", coverAnimation, false, false)

function sertkonusAnimation(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "benchpress", "gym_bp_celebrate", -1, false, false, false)
	end
end
addCommandHandler("sertkonus", sertkonusAnimation, false, false)

function cprAnimation(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "medic", "cpr", 8000, false, true, false)
	end
end
addCommandHandler("tedavi", cprAnimation, false, false)

function elsallaAnimation(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "ON_LOOKERS", "wave_loop", -1, true, true, false)
	end
end
addCommandHandler("elsalla", elsallaAnimation, false, false)

function drugAnimation(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "DEALER", "DRUGS_BUY", 8000, false, true, false)
	end
end
addCommandHandler("adrug", drugAnimation, false, false)

function kostomachAnimation(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "ped", "KO_shot_stom", -1, false, true, false)
	end
end
addCommandHandler("bayilma", kostomachAnimation, false, false)

function copawayAnimation(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "police", "coptraf_away", 1300, true, false, false)
	end
end
addCommandHandler("trafikdevam", copawayAnimation, false, false)

function copcomeAnimation(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "POLICE", "CopTraf_Come", -1, true, false, false)
	end
end
addCommandHandler("trafikgel", copcomeAnimation, false, false)

function copleftAnimation(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "POLICE", "CopTraf_Left", -1, true, false, false)
	end
end
addCommandHandler("trafiksol", copleftAnimation, false, false)

function copstopAnimation(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "POLICE", "CopTraf_Stop", -1, true, false, false)
	end
end
addCommandHandler("trafikdur", copstopAnimation, false, false)

function durusAnimation(thePlayer, commandName, arg)
	if canUseAnimation(thePlayer) then
		arg = tonumber(arg)
		if arg == 2 then
			setPedAnimation(thePlayer, "DEALER", "DEALER_IDLE_01", -1, true, false, false)
		elseif arg == 3 then
			setPedAnimation(thePlayer, "COP_AMBIENT", "Coplook_loop", -1, true, false, false)
		elseif arg == 4 then
			setPedAnimation(thePlayer, "COP_AMBIENT", "Coplook_think", -1, true, false, false)
		elseif arg == 5 then
			setPedAnimation(thePlayer, "cop_ambient_3", "Coplook_loop", -1, true, false, false)
		elseif arg == 6 then
			setPedAnimation(thePlayer, "cop_ambient_3", "Coplook_in", -1, true, false, false)
		elseif arg == 7 then
			setPedAnimation(thePlayer, "woman_idle_1", "Coplook_loop", -1, true, false, false)
		elseif arg == 8 then
			setPedAnimation(thePlayer, "woman_idle_2", "Coplook_loop", -1, true, false, false)
		elseif arg == 9 then
			setPedAnimation(thePlayer, "woman_idle_3", "Coplook_loop", -1, true, false, false)
		elseif arg == 10 then
			setPedAnimation(thePlayer, "woman_idle_4", "Coplook_loop", -1, true, false, false)
		elseif arg == 11 then
			setPedAnimation(thePlayer, "woman_idle_5", "RAP_B_Loop", -1, true, false, false)
		elseif arg == 12 then
			setPedAnimation(thePlayer, "Coplook_out2", "Coplook_out", -1, true, false, false)
		elseif arg == 13 then
			setPedAnimation(thePlayer, "hands_behind_back", "Coplook_loop", -1, true, false, false)
		elseif arg == 14 then
			setPedAnimation(thePlayer, "hands_entwined_behind", "Coplook_loop", -1, true, false, false)
		elseif arg == 15 then
			setPedAnimation(thePlayer, "new_strip3", "PUN_LOOP", -1, true, false, false)
		elseif arg == 16 then
			setPedAnimation(thePlayer, "rekawkieszeni", "Coplook_loop", -1, true, false, false)
		elseif arg == 17 then
			setPedAnimation(thePlayer, "COP_AMBIENT", "Coplook_shake", -1, true, false, false)
		else
			setPedAnimation(thePlayer, "ped", "XPRESSscratch", -1, true, false, false)
		end
	end
end
addCommandHandler("durus", durusAnimation, false, false)

function idleAnimation(thePlayer, commandName, arg)
	if canUseAnimation(thePlayer) then
		arg = tonumber(arg)
		if arg == 2 then
			setPedAnimation(thePlayer, "DEALER", "DEALER_IDLE", -1, true, false, false)
		else
			setPedAnimation(thePlayer, "DEALER", "DEALER_IDLE_01", -1, true, false, true)
		end
	end
end
addCommandHandler("idle", idleAnimation, false, false)

function pedPiss(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "PAULNMAC", "Piss_loop", -1, true, false, false)
	end
end
addCommandHandler("piss", pedPiss, false, false)

function pedWank(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "PAULNMAC", "wank_loop", -1, true, false, false)
	end
end
addCommandHandler("wank", pedWank, false, false)
addCommandHandler("31", pedWank, false, false)

function pedSlapAss(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "SWEET", "sweet_ass_slap", 2000, true, false, false)
	end
end
addCommandHandler("saplak", pedSlapAss, false, false)

function pedCarFix(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "CAR", "Fixn_Car_loop", -1, true, false, false)
	end
end
addCommandHandler("aractamir", pedCarFix, false, false)

function pedHandsup(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "ped", "handsup", -1, false, false, false)
	end
end
addCommandHandler("handsup", pedHandsup, false, false)
addCommandHandler("elkaldir", pedHandsup, false, false)

function pedTaxiHail(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "MISC", "Hiker_Pose", -1, false, true, false)
	end
end
addCommandHandler("otostop", pedTaxiHail, false, false)

function pedScratch(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "MISC", "Scratchballs_01", -1, true, true, false)
	end
end
addCommandHandler("aletkontrol", pedScratch, false, false)

function pedFU(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "RIOT", "RIOT_FUKU", 800, false, true, false)
	end
end
addCommandHandler("fu", pedFU, false, false)

function pedStrip(thePlayer, commandName, arg)
	if canUseAnimation(thePlayer) then
		arg = tonumber(arg)
		if arg == 2 then
			setPedAnimation(thePlayer, "STRIP", "STR_Loop_C", -1, false, true, false)
		elseif arg == 3 then
			setPedAnimation(thePlayer, "STRIP", "strip_D", -1, false, true, false)
		elseif arg == 4 then
			setPedAnimation(thePlayer, "new_strip10", "STR_Loop_A", -1, false, true, false)
		elseif arg == 5 then
			setPedAnimation(thePlayer, "new_strip11", "STR_Loop_B", -1, false, true, false)
		elseif arg == 6 then
			setPedAnimation(thePlayer, "new_strip4", "strip_E", -1, false, true, false)
		else
			setPedAnimation(thePlayer, "taniecstriptizerka", "STR_Loop_A", -1, false, true, false)
		end
	end
end
addCommandHandler("strip", pedStrip, false, false)

function pedLightup(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "SMOKING", "M_smk_in", 4000, true, true, false)
	end
end
addCommandHandler("sigarayak", pedLightup, false, false)

function pedHeil(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "ON_LOOKERS", "Pointup_in", 999999, false, true, false)
	end
end
addCommandHandler("duaet", pedHeil, false, false)

function pedDrink(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "BAR", "dnk_stndM_loop", 2300, false, false, false)
	end
end
addCommandHandler("ic", pedDrink, false, false)

function pedLay(thePlayer, commandName, arg)
	if canUseAnimation(thePlayer) then
		arg = tonumber(arg)
		if arg == 2 then
			setPedAnimation(thePlayer, "BEACH", "sitnwait_Loop_W", -1, true, false, false)
		elseif arg == 3 then
			setPedAnimation(thePlayer, "beach_2", "bather", -1, true, false, false)
		elseif arg == 4 then
			setPedAnimation(thePlayer, "beach_2", "Lay_Bac_Loop", -1, true, false, false)
		elseif arg == 5 then
			setPedAnimation(thePlayer, "beach_4", "ParkSit_W_loop", -1, true, false, false)
		elseif arg == 6 then
			setPedAnimation(thePlayer, "beach_5", "ParkSit_M_loop", -1, true, false, false)
		elseif arg == 7 then
			setPedAnimation(thePlayer, "beach_5", "bather", -1, true, false, false)
		elseif arg == 8 then
			setPedAnimation(thePlayer, "beach_3", "ParkSit_M_loop", -1, true, false, false)
		elseif arg == 9 then
			setPedAnimation(thePlayer, "beach_6", "bather", -1, true, false, false)
		elseif arg == 10 then
			setPedAnimation(thePlayer, "fekves", "bather", -1, true, false, false)
		elseif arg == 11 then
			setPedAnimation(thePlayer, "woman_lay_1", "Lay_Bac_Loop", -1, true, false, false)
		elseif arg == 12 then
			setPedAnimation(thePlayer, "new2_beach", "SitnWait_loop_W", -1, true, false, false)
		elseif arg == 13 then
			setPedAnimation(thePlayer, "BEACH", "ParkSit_W_loop", -1, true, false, false)
		else
			setPedAnimation(thePlayer, "BEACH", "Lay_Bac_Loop", -1, true, false, false)
		end
	end
end
addCommandHandler("uzan", pedLay, false, false)

function begAnimation(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "SHOP", "SHP_Rob_React", 4000, true, false, false)
	end
end
addCommandHandler("yalvar", begAnimation, false, false)

function pedMourn(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "GRAVEYARD", "mrnM_loop", -1, true, false, false)
	end
end
addCommandHandler("saygi", pedMourn, false, false)

function pedCry(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "GRAVEYARD", "mrnF_loop", -1, true, false, false)
	end
end
addCommandHandler("agla", pedCry, false, false)

function pedCheer(thePlayer, commandName, arg)
	if canUseAnimation(thePlayer) then
		arg = tonumber(arg)
		if arg == 2 then
			setPedAnimation(thePlayer, "OTB", "wtchrace_win", -1, true, false, false)
		elseif arg == 3 then
			setPedAnimation(thePlayer, "RIOT", "RIOT_shout", -1, true, false, false)
		else
			setPedAnimation(thePlayer, "STRIP", "PUN_HOLLER", -1, true, false, false)
		end
	end
end
addCommandHandler("bagir", pedCheer, false, false)

function danceAnimation(thePlayer, commandName, arg)
	if canUseAnimation(thePlayer) then
		arg = tonumber(arg)
		if arg == 2 then
			setPedAnimation(thePlayer, "DANCING", "DAN_Down_A", -1, true, false, false)
		elseif arg == 3 then
			setPedAnimation(thePlayer, "DANCING", "dnce_M_d", -1, true, false, false)
		elseif arg == 4 then
			setPedAnimation(thePlayer, "DANCING", "DAN_Down_A", -1, true, false, false)
		elseif arg == 5 then
			setPedAnimation(thePlayer, "DANCING", "bd_clap", -1, true, false, false)
		elseif arg == 6 then
			setPedAnimation(thePlayer, "DANCING", "bd_clap1", -1, true, false, false)
		elseif arg == 7 then
			setPedAnimation(thePlayer, "DANCING", "dan_down_a", -1, true, false, false)
		elseif arg == 8 then
			setPedAnimation(thePlayer, "DANCING", "dan_left_a", -1, true, false, false)
		elseif arg == 9 then
			setPedAnimation(thePlayer, "DANCING", "dan_loop_a", -1, true, false, false)
		elseif arg == 10 then
			setPedAnimation(thePlayer, "DANCING", "dan_right_a", -1, true, false, false)
		elseif arg == 11 then
			setPedAnimation(thePlayer, "DANCING", "dan_up_a", -1, true, false, false)
		elseif arg == 12 then
			setPedAnimation(thePlayer, "custom_5", "blocdance", -1, true, false, false)
		else
			setPedAnimation(thePlayer, "DANCING", "DAN_Right_A", -1, true, false, false)
		end
	end
end
addCommandHandler("dans", danceAnimation, false, false)

function crackAnimation(thePlayer, commandName, arg)
	if canUseAnimation(thePlayer) then
		arg = tonumber(arg)
		if arg == 2 then
			setPedAnimation(thePlayer, "CRACK", "crckidle1", -1, true, false, false)
		elseif arg == 3 then
			setPedAnimation(thePlayer, "CRACK", "crckidle3", -1, true, false, false)
		elseif arg == 4 then
			setPedAnimation(thePlayer, "CRACK", "crckidle4", -1, true, false, false)
		else
			setPedAnimation(thePlayer, "CRACK", "crckidle2", -1, true, false, false)
		end
	end
end
addCommandHandler("yarali", crackAnimation, false, false)

function gsignAnimation(thePlayer, commandName, arg)
	if canUseAnimation(thePlayer) then
		arg = tonumber(arg)
		if arg == 2 then
			setPedAnimation(thePlayer, "GHANDS", "gsign2", 4000, true, false, false)
		elseif arg == 3 then
			setPedAnimation(thePlayer, "GHANDS", "gsign3", 4000, true, false, false)
		elseif arg == 4 then
			setPedAnimation(thePlayer, "GHANDS", "gsign4", 4000, true, false, false)
		elseif arg == 5 then
			setPedAnimation(thePlayer, "GHANDS", "gsign5", 4000, true, false, false)
		else
			setPedAnimation(thePlayer, "GHANDS", "gsign1", 4000, true, false, false)
		end
	end
end
addCommandHandler("gsign", gsignAnimation, false, false)

function pukeAnimation(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "FOOD", "EAT_Vomit_P", 8000, true, false, false)
	end
end
addCommandHandler("kus", pukeAnimation, false, false)

function rapAnimation(thePlayer, commandName, arg)
	if canUseAnimation(thePlayer) then
		arg = tonumber(arg)
		if arg == 2 then
			setPedAnimation(thePlayer, "LOWRIDER", "RAP_B_Loop", -1, true, false, false)
		elseif arg == 3 then
			setPedAnimation(thePlayer, "LOWRIDER", "RAP_C_Loop", -1, true, false, false)
		else
			setPedAnimation(thePlayer, "LOWRIDER", "RAP_A_Loop", -1, true, false, false)
		end
	end
end
addCommandHandler("rap", rapAnimation, false, false)

function aimAnimation(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "SHOP", "ROB_Loop_Threat", -1, false, true, false)
	end
end
addCommandHandler("silahcek", aimAnimation, false, false)

function sitAnimation(thePlayer, commandName, arg)
	arg = tonumber(arg)
	if isPedInVehicle(thePlayer) then
		if arg == 2 then
			setPedAnimation(thePlayer, "CAR", "Sit_relaxed")
		else
			setPedAnimation(thePlayer, "CAR", "Tap_hand")
		end
	else
		if canUseAnimation(thePlayer) then
			if arg == 2 then
				setPedAnimation(thePlayer, "FOOD", "FF_Sit_Look", -1, true, false, false)
			elseif arg == 3 then
				setPedAnimation(thePlayer, "Attractors", "Stepsit_loop", -1, true, false, false)
			elseif arg == 4 then
				setPedAnimation(thePlayer, "BEACH", "ParkSit_W_loop", 1, true, false, false)
			elseif arg == 5 then
				setPedAnimation(thePlayer, "BEACH", "ParkSit_M_loop", 1, true, false, false)
			elseif arg == 6 then
				setPedAnimation(thePlayer, "BLOWJOBZ", "BJ_Couch_Loop_P", -1, true, false, false)
			elseif arg == 7 then
				setPedAnimation(thePlayer, "JST_BUISNESS", "girl_02", -1, true, false, false)
			else
				setPedAnimation(thePlayer, "ped", "SEAT_idle", -1, true, false, false)
			end
		end
	end
end
addCommandHandler("otur", sitAnimation, false, false)

function smokeAnimation(thePlayer, commandName, arg)
	if canUseAnimation(thePlayer) then
		arg = tonumber(arg)
		if arg == 2 then
			setPedAnimation(thePlayer, "SMOKING", "M_smkstnd_loop", -1, true, false, false)
		elseif arg == 3 then
			setPedAnimation(thePlayer, "LOWRIDER", "M_smkstnd_loop", -1, true, false, false)
		else
			setPedAnimation(thePlayer, "GANGS", "smkcig_prtl", -1, true, false, false)
		end
	end
end
addCommandHandler("sigara", smokeAnimation, false, false)

function smokeleanAnimation(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "LOWRIDER", "M_smklean_loop", -1, true, false, false)
	end
end
addCommandHandler("sigarayaslan", smokeleanAnimation, false, false)

function smokedragAnimation(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "SMOKING", "M_smk_drag", 4000, true, false, false)
	end
end
addCommandHandler("esrarcek", smokedragAnimation, false, false)

function laughAnimation(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "RAPPING", "Laugh_01", -1, true, false, false)
	end
end
addCommandHandler("kahkaha", laughAnimation, false, false)

function startraceAnimation(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "CAR", "flag_drop", 4200, true, false, false)
	end
end
addCommandHandler("yarisbasla", startraceAnimation, false, false)

function carchatAnimation(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "CAR_CHAT", "car_talkm_loop", -1, true, false, false)
	end
end
addCommandHandler("arabasohbet", carchatAnimation, false, false)

function tiredAnimation(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "FAT", "idle_tired", -1, true, false, false)
	end
end
addCommandHandler("egil", tiredAnimation, false, false)

function handshakeAnimation(thePlayer, commandName, targetPlayer)
	if canUseAnimation(thePlayer) then
		if targetPlayer then
			local targetPlayer = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
			if targetPlayer then
				if (not getPedOccupiedVehicle(thePlayer)) and (not getPedOccupiedVehicle(targetPlayer)) then
					local x, y, z = getElementPosition(thePlayer)
					local tx, ty, tz = getElementPosition(targetPlayer)
					if getDistanceBetweenPoints3D(x, y, z, tx, ty, tz) < 1 then
						setPedAnimation(thePlayer, "GANGS", "hndshkfa", -1, false, false, false)
						setPedAnimation(targetPlayer, "GANGS", "hndshkfa", -1, false, false, false)
					else
						outputChatBox("[!]#FFFFFF Bu oyuncudan çok uzaksınız.", thePlayer, 255, 0, 0, true)
					end
				else
					outputChatBox("[!]#FFFFFF Araçtayken bunu kullanamazsınız.", thePlayer, 255, 0, 0, true)
				end
			end
		else
			setPedAnimation(thePlayer, "GANGS", "hndshkfa", -1, false, false, false)
		end
	end
end
addCommandHandler("selam", handshakeAnimation, false, false)

function shoveAnimation(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "GANGS", "shake_carSH", -1, true, false, false)
	end
end
addCommandHandler("kapikir", shoveAnimation, false, false)

function bitchslapAnimation(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "MISC", "bitchslap", -1, true, false, false)
	end
end
addCommandHandler("saplakla", bitchslapAnimation, false, false)

function shockedAnimation(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "ON_LOOKERS", "panic_loop", -1, true, false, false)
	end
end
addCommandHandler("saskin", shockedAnimation, false, false)

function diveAnimation(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "ped", "EV_dive", -1, false, true, false)
	end
end
addCommandHandler("atla", diveAnimation, false, false)

function whatAnimation(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "RIOT", "RIOT_ANGRY", -1, true, false, false)
	end
end
addCommandHandler("ne", whatAnimation, false, false)

function polisoturAnimation(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "CAMERA", "camcrch_idleloop", -1, true, false, false)
	end
end
addCommandHandler("cok", polisoturAnimation, false, false)

function fallfrontAnimation(thePlayer, commandName, arg)
	if canUseAnimation(thePlayer) then
		arg = tonumber(arg)
		if arg == 2 then
			setPedAnimation(thePlayer, "ped", "FLOOR_hit_f", -1, false, false, false)
		else
			setPedAnimation(thePlayer, "ped", "FLOOR_hit", -1, false, false, false)
		end
	end
end
addCommandHandler("yereyat", fallfrontAnimation, false, false)

function walkAnimation(thePlayer, commandName, arg)
	if canUseAnimation(thePlayer) then
		arg = tonumber(arg)

		if not walk[arg] then
			arg = 2
		end

		setPedAnimation(thePlayer, "PED", walk[arg], -1, true, true, false)
	end
end
addCommandHandler("yuru", walkAnimation, false, false)

function batAnimation(thePlayer, commandName, arg)
	if canUseAnimation(thePlayer) then
		arg = tonumber(arg)
		if arg == 2 then
			setPedAnimation(thePlayer, "CRACK", "Bbalbat_Idle_02", -1, true, false, false)
		elseif arg == 3 then
			setPedAnimation(thePlayer, "Baseball", "Bat_IDLE", -1, true, false, false)
		else
			setPedAnimation(thePlayer, "CRACK", "Bbalbat_Idle_01", -1, true, false, false)
		end
	end
end
addCommandHandler("sopa", batAnimation, false, false)

function winAnimation(thePlayer, commandName, arg)
	if canUseAnimation(thePlayer) then
		arg = tonumber(arg)
		if arg == 2 then
			setPedAnimation(thePlayer, "CASINO", "manwinb", 2000, false, false, false)
		else
			setPedAnimation(thePlayer, "CASINO", "manwind", 2000, false, false, false)
		end
	end
end
addCommandHandler("sevin", winAnimation, false, false)

function asilAnimation(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "BSKTBALL", "BBALL_Dnk", 1, false, false, false)
	end
end
addCommandHandler("asil", asilAnimation, false, false)

function grabbAnimation(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "BAR", "Barserve_bottle", 2000, false, false, false)
	end
end
addCommandHandler("barservis", grabbAnimation, false, false)

function taichiAnimation(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "PARK", "Tai_Chi_Loop", -1, false, false, false)
	end
end
addCommandHandler("taichi", taichiAnimation, false, false)

function bompAnimation(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "BOMBER", "BOM_Plant", -1, false, false, false)
	end
end
addCommandHandler("bombakur", bompAnimation, false, false)

function kartopuAnimation(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "GRENADE", "WEAPON_throw", -1, false, false, false)
	end
end
addCommandHandler("karat", kartopuAnimation, false, false)

function kapakAnimation(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "GANGS", "hndshkaa", -1, false, false, false)
	end
end
addCommandHandler("kapak", kapakAnimation, false, false)

function kollariniAcAnimation(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "BSKTBALL", "BBALL_def_loop", -1, false, false, false)
	end
end
addCommandHandler("kollariac", kollariniAcAnimation, false, false)

function sikerimAnimation(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "GANGS", "hndshkba", -1, false, false, false)
	end
end
addCommandHandler("senisikerim", sikerimAnimation, false, false)

function teklifAnimation(thePlayer, commandName, arg)
	if canUseAnimation(thePlayer) then
		arg = tonumber(arg)
		if arg == 2 then
			setPedAnimation(thePlayer, "GANGS", "Invite_No", -1, false, false, false)
		else
			setPedAnimation(thePlayer, "GANGS", "Invite_Yes", -1, false, false, false)
		end
	end
end
addCommandHandler("teklif", teklifAnimation, false, false)

function anlatAnimation(thePlayer, commandName, arg)
	if canUseAnimation(thePlayer) then
		arg = tonumber(arg)
		if arg == 2 then
			setPedAnimation(thePlayer, "GANGS", "prtial_gngtlkB", -1, false, false, false)
		elseif arg == 3 then
			setPedAnimation(thePlayer, "GANGS", "prtial_gngtlkC", -1, false, false, false)
		elseif arg == 4 then
			setPedAnimation(thePlayer, "GANGS", "prtial_gngtlkD", -1, false, false, false)
		elseif arg == 5 then
			setPedAnimation(thePlayer, "GANGS", "prtial_gngtlkE", -1, false, false, false)
		elseif arg == 6 then
			setPedAnimation(thePlayer, "GANGS", "prtial_gngtlkF", -1, false, false, false)
		else
			setPedAnimation(thePlayer, "GANGS", "prtial_gngtlkA", -1, false, false, false)
		end
	end
end
addCommandHandler("anlat", anlatAnimation, false, false)

function coffeeAnimation(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "BAR", "Barcustom_get", -1, false, false, false)
	end
end
addCommandHandler("kahveal", coffeeAnimation, false, false)

function spreyAnimation(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "GRAFFITI", "spraycan_fire", -1, false, false, false)
	end
end
addCommandHandler("sprey", spreyAnimation, false, false)

function itAnimation(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "gangs", "shake_cara", -1, false, false, false)
	end
end
addCommandHandler("it", itAnimation, false, false)

function tekmeAtAnimation(thePlayer)
	if canUseAnimation(thePlayer) then
		setPedAnimation(thePlayer, "police", "Door_Kick", -1, false, false, false)
	end
end
addCommandHandler("tekmeat", tekmeAtAnimation, false, false)

function yaslanmaAnimasyonlari(thePlayer, commandName, arg)
	if canUseAnimation(thePlayer) then
		arg = tonumber(arg)
		if arg == 2 then
			setPedAnimation(thePlayer, "BAR", "BARman_idle", -1, true, false, false)
		elseif arg == 3 then
			setPedAnimation(thePlayer, "Attractors", "Stepsit_loop", -1, true, false, false)
		else
			setPedAnimation(thePlayer, "GANGS", "leanIDLE", -1, true, false, false)
		end
	end
end
addCommandHandler("yaslan", yaslanmaAnimasyonlari, false, false)

function kissingAnimation(thePlayer, commandName, targetPlayer)
	if canUseAnimation(thePlayer) then
		if not targetPlayer or targetPlayer == "" then
			outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID]", thePlayer, 255, 194, 14)
			return
		end

		local targetPlayer = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
		if not targetPlayer then
			return
		end

		local x, y, z = getElementPosition(thePlayer)
		local tx, ty, tz = getElementPosition(targetPlayer)

		if
			(getDistanceBetweenPoints3D(x, y, z, tx, ty, tz) < 1)
			and (not getPedOccupiedVehicle(thePlayer))
			and (not getPedOccupiedVehicle(targetPlayer))
		then
			setPedAnimation(thePlayer, "KISSING", "Grlfrd_Kiss_01", -1, false, false, false)
			setPedAnimation(targetPlayer, "KISSING", "Grlfrd_Kiss_01", -1, false, false, false)
		end
	end
end
addCommandHandler("opus", kissingAnimation, false, false)

function kselamAnimation(thePlayer, commandName, targetPlayer)
	if canUseAnimation(thePlayer) then
		if not targetPlayer or targetPlayer == "" then
			outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID]", thePlayer, 255, 194, 14)
			return
		end

		local targetPlayer = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
		if not targetPlayer then
			return
		end

		local x, y, z = getElementPosition(thePlayer)
		local tx, ty, tz = getElementPosition(targetPlayer)

		if
			(getDistanceBetweenPoints3D(x, y, z, tx, ty, tz) < 1)
			and (not getPedOccupiedVehicle(thePlayer))
			and (not getPedOccupiedVehicle(targetPlayer))
		then
			setPedAnimation(thePlayer, "GANGS", "prtial_hndshk_biz_01", -1, false, false, false)
			setPedAnimation(targetPlayer, "GANGS", "prtial_hndshk_biz_01", -1, false, false, false)
		end
	end
end
addCommandHandler("kselam", kselamAnimation, false, false)

function ysexAnimation(thePlayer, commandName, targetPlayer)
	if canUseAnimation(thePlayer) then
		if not targetPlayer or targetPlayer == "" then
			outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID]", thePlayer, 255, 194, 14)
			return
		end

		local targetPlayer = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
		if not targetPlayer then
			return
		end

		local x, y, z = getElementPosition(thePlayer)
		local tx, ty, tz = getElementPosition(targetPlayer)

		if
			(getDistanceBetweenPoints3D(x, y, z, tx, ty, tz) < 1)
			and (not getPedOccupiedVehicle(thePlayer))
			and (not getPedOccupiedVehicle(targetPlayer))
		then
			setPedAnimation(thePlayer, "BLOWJOBZ", "BJ_Couch_end_P", -1, false, false, false)
			setPedAnimation(targetPlayer, "BLOWJOBZ", "BJ_Couch_end_W", -1, false, false, false)
		end
	end
end
addCommandHandler("ysex", ysexAnimation, false, false)

function ysex2Animation(thePlayer, commandName, targetPlayer)
	if canUseAnimation(thePlayer) then
		if not targetPlayer or targetPlayer == "" then
			outputChatBox("Kullanım: /" .. commandName .. " [Karakter Adı / ID]", thePlayer, 255, 194, 14)
			return
		end

		local targetPlayer = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
		if not targetPlayer then
			return
		end

		local x, y, z = getElementPosition(thePlayer)
		local tx, ty, tz = getElementPosition(targetPlayer)

		if
			(getDistanceBetweenPoints3D(x, y, z, tx, ty, tz) < 1)
			and (not getPedOccupiedVehicle(thePlayer))
			and (not getPedOccupiedVehicle(targetPlayer))
		then
			setPedAnimation(thePlayer, "BLOWJOBZ", "BJ_Couch_Loop_P", -1, false, false, false)
			setPedAnimation(targetPlayer, "BLOWJOBZ", "BJ_Couch_Loop_W", -1, false, false, false)
		end
	end
end
addCommandHandler("ysex2", ysex2Animation, false, false)

function realHandshakeAnimation(thePlayer, commandName, targetPlayer)
	if canUseAnimation(thePlayer) then
		if targetPlayer then
			local targetPlayer = exports.mek_global:findPlayerByPartialNick(thePlayer, targetPlayer)
			if targetPlayer then
				if (not getPedOccupiedVehicle(thePlayer)) and (not getPedOccupiedVehicle(targetPlayer)) then
					local x, y, z = getElementPosition(thePlayer)
					local tx, ty, tz = getElementPosition(targetPlayer)
					if getDistanceBetweenPoints3D(x, y, z, tx, ty, tz) < 1.5 then
						setPedAnimation(thePlayer, "GANGS", "prtial_hndshk_biz_01", -1, false, false, false)
						setPedAnimation(targetPlayer, "GANGS", "prtial_hndshk_biz_01", -1, false, false, false)
					else
						outputChatBox("[!]#FFFFFF Bu oyuncudan çok uzaksınız.", thePlayer, 255, 0, 0, true)
					end
				else
					outputChatBox("[!]#FFFFFF Araçtayken bunu kullanamazsınız.", thePlayer, 255, 0, 0, true)
				end
			end
		else
			setPedAnimation(thePlayer, "GANGS", "prtial_hndshk_biz_01", -1, false, false, false)
		end
	end
end
addCommandHandler("elsikis", realHandshakeAnimation, false, false)

function listAnims(thePlayer)
	local handlers = getCommandHandlers(getThisResource())
	if not handlers or #handlers == 0 then
		outputChatBox("[!]#FFFFFF Animasyon bulunamadı.", thePlayer, 255, 0, 0, true)
		return
	end

	outputChatBox("[!]#FFFFFF Mevcut animasyon komutları:", thePlayer, 0, 255, 0, true)

	local line = ""
	for i, cmd in ipairs(handlers) do
		if not ignoredCommands[cmd] then
			line = line .. "/" .. cmd .. " "
			if i % 8 == 0 then
				outputChatBox(line, thePlayer, 255, 255, 255, true)
				line = ""
			end
		end
	end

	if line ~= "" then
		outputChatBox(line, thePlayer, 255, 255, 255, true)
	end
end
addCommandHandler("anims", listAnims, false, false)
addCommandHandler("animasyonlar", listAnims, false, false)

function canUseAnimation(thePlayer)
	return not isPedInVehicle(thePlayer)
		and not isPedDead(thePlayer)
		and not exports.mek_superman:isPlayerFlying(thePlayer)
		and not getElementData(thePlayer, "dead")
		and not getElementData(thePlayer, "dragged_player")
		and not getElementData(thePlayer, "is_dragged")
		and not getElementData(thePlayer, "proned")
		and not getElementData(thePlayer, "tazed")
		and not getElementData(thePlayer, "frozen")
end
