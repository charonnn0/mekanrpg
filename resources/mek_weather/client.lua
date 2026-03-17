local timeH, timeM, timeS = 0, 0, 0
local skyColors = {
	{
		4.5,
		4,
		7,
		10,
		5,
		12,
		25,
	},
	{
		7,
		65,
		132,
		208,
		209,
		199,
		154,
	},
	{
		7.5,
		17,
		107,
		219,
		77,
		147,
		230,
	},
	{
		12,
		17,
		107,
		219,
		77,
		147,
		230,
	},
	{
		14.75,
		17,
		107,
		219,
		77,
		147,
		230,
	},
	{
		17.5,
		71,
		100,
		136,
		135,
		87,
		45,
	},
	{
		19.5,
		70,
		92,
		117,
		123,
		101,
		101,
	},
	{
		22,
		4,
		7,
		10,
		5,
		12,
		25,
	},
}
local ambientColor = {
	{
		2,
		10,
		20,
		33,
	},
	{
		5,
		10,
		15,
		20,
	},
	{
		6,
		10,
		6,
		5,
	},
	{
		7,
		19,
		15,
		15,
	},
	{
		8,
		11,
		7,
		1,
	},
	{
		12,
		13,
		7,
		2,
	},
	{
		15,
		20,
		11,
		4,
	},
	{
		17,
		22,
		15,
		4,
	},
	{
		19,
		16,
		8,
		10,
	},
	{
		20,
		10,
		6,
		5,
	},
	{
		21,
		10,
		20,
		33,
	},
}
local ambientObjColor = {
	{
		2,
		160,
		165,
		175,
	},
	{
		5,
		210,
		194,
		182,
	},
	{
		12,
		220,
		200,
		195,
	},
	{
		15,
		215,
		194,
		190,
	},
	{
		17,
		255,
		220,
		185,
	},
	{
		20,
		210,
		194,
		182,
	},
	{
		21,
		160,
		165,
		175,
	},
}
local spriteShadow = {
	{
		2,
		10,
		5,
		225,
	},
	{
		12,
		5,
		2.5,
		255,
	},
	{
		21,
		10,
		5,
		225,
	},
}

function processSkyDay(p)
	local n = #skyColors
	for i = n, 1, -1 do
		if p >= skyColors[i][1] then
			if i >= n then
				return skyColors[n][2],
					skyColors[n][3],
					skyColors[n][4],
					skyColors[n][5],
					skyColors[n][6],
					skyColors[n][7]
			else
				local prog = (p - skyColors[i][1]) / (skyColors[i + 1][1] - skyColors[i][1])
				return skyColors[i][2] + (skyColors[i + 1][2] - skyColors[i][2]) * prog,
					skyColors[i][3] + (skyColors[i + 1][3] - skyColors[i][3]) * prog,
					skyColors[i][4] + (skyColors[i + 1][4] - skyColors[i][4]) * prog,
					skyColors[i][5] + (skyColors[i + 1][5] - skyColors[i][5]) * prog,
					skyColors[i][6] + (skyColors[i + 1][6] - skyColors[i][6]) * prog,
					skyColors[i][7] + (skyColors[i + 1][7] - skyColors[i][7]) * prog
			end
		end
	end
	return skyColors[1][2], skyColors[1][3], skyColors[1][4], skyColors[1][5], skyColors[1][6], skyColors[1][7]
end

function processAmbientColor(p)
	local n = #ambientColor
	for i = n, 1, -1 do
		if p >= ambientColor[i][1] then
			if i >= n then
				return ambientColor[n][2], ambientColor[n][3], ambientColor[n][4]
			else
				local prog = (p - ambientColor[i][1]) / (ambientColor[i + 1][1] - ambientColor[i][1])
				return ambientColor[i][2] + (ambientColor[i + 1][2] - ambientColor[i][2]) * prog,
					ambientColor[i][3] + (ambientColor[i + 1][3] - ambientColor[i][3]) * prog,
					ambientColor[i][4] + (ambientColor[i + 1][4] - ambientColor[i][4]) * prog
			end
		end
	end
	return ambientColor[1][2], ambientColor[1][3], ambientColor[1][4]
end

function processSpriteShadow(p)
	local n = #spriteShadow
	for i = n, 1, -1 do
		if p >= spriteShadow[i][1] then
			if i >= n then
				return spriteShadow[n][2], spriteShadow[n][3], spriteShadow[n][4]
			else
				local prog = (p - spriteShadow[i][1]) / (spriteShadow[i + 1][1] - spriteShadow[i][1])
				return spriteShadow[i][2] + (spriteShadow[i + 1][2] - spriteShadow[i][2]) * prog,
					spriteShadow[i][3] + (spriteShadow[i + 1][3] - spriteShadow[i][3]) * prog,
					spriteShadow[i][4] + (spriteShadow[i + 1][4] - spriteShadow[i][4]) * prog
			end
		end
	end
	return spriteShadow[1][2], spriteShadow[1][3], spriteShadow[1][4]
end

function processAmbientObjColor(p)
	local n = #ambientObjColor
	for i = n, 1, -1 do
		if p >= ambientObjColor[i][1] then
			if i >= n then
				return ambientObjColor[n][2], ambientObjColor[n][3], ambientObjColor[n][4]
			else
				local prog = (p - ambientObjColor[i][1]) / (ambientObjColor[i + 1][1] - ambientObjColor[i][1])
				return ambientObjColor[i][2] + (ambientObjColor[i + 1][2] - ambientObjColor[i][2]) * prog,
					ambientObjColor[i][3] + (ambientObjColor[i + 1][3] - ambientObjColor[i][3]) * prog,
					ambientObjColor[i][4] + (ambientObjColor[i + 1][4] - ambientObjColor[i][4]) * prog
			end
		end
	end
	return ambientObjColor[1][2], ambientObjColor[1][3], ambientObjColor[1][4]
end

function processSky(p)
	local tr, tg, tb, br, bg, bb = processSkyDay(p)
	setSkyGradient(tr, tg, tb, br, bg, bb)
end

local forceH, forceM, forceS, forceW = false, false, false, false

addEvent("weather.gotTimeChange", true)
addEventHandler("weather.gotTimeChange", root, function(h, m, s)
	timeH, timeM, timeS = h, m, s
	if not forceH then
		processSky(h + m / 60 + s / 3600)
	end
end)

function setForceTime(h, m, s, w)
	forceH, forceM, forceS, forceW = h, m, s, w
	processSky(forceH + forceM / 60 + forceS / 3600)
end

function resetWeather()
	forceH, forceM, forceS, forceW = false, false, false, false
	setMinuteDuration(1147483647)
	resetSkyGradient()
	resetWaterColor()
	processSky(timeH + timeM / 60 + timeS / 3600)
end
resetWeather()

addEventHandler("onClientPreRender", root, function()
	setTime(forceH or timeH, forceM or timeM, forceS or timeS)
	setWeather(forceW or 2)
	setWeatherBlended(forceW or 2)
	setCloudsEnabled(true)
	setSunSize(3)
	setMoonSize(3)
	setFogDistance(0)
end, true, "high+9999999")
