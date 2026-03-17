local singleGateSound = nil
local allGatesSound = nil

function singleGateSound(x, y, z)
	if not isElement(singleGateSound) then
		singleGateSound = playSound3D("public/sounds/single_gate.mp3", x, y, z, false)
		setElementDimension(singleGateSound, gateDim)
		setElementInterior(singleGateSound, gateInt)
	end
end
addEvent("singleGateSound", true)
addEventHandler("singleGateSound", localPlayer, singleGateSound)

function allGatesSound()
	if not isElement(allGatesSound) then
		allGatesSound = playSound("public/sounds/buzz.wav", false)
		setTimer(function()
			allGatesSound = playSound("public/sounds/all_gates.mp3", false)
		end, 1400, 1)
	end
end
addEvent("allGatesSound", true)
addEventHandler("allGatesSound", localPlayer, allGatesSound)
