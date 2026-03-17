local weaponConfigurations = {
	[22] = { range = 70, accuracy = 1, damage = 30 },
	[23] = { range = 150, accuracy = 50, damage = 1000 },
	[24] = { range = 90, accuracy = 1, damage = 60 },

	[25] = { range = 45, accuracy = 1.2, damage = 35 },
	[26] = { range = 25, accuracy = 0.45, damage = 25 },
	[27] = { range = 60, accuracy = 0.6, damage = 12 },

	[28] = { range = 60, accuracy = 0.7, damage = 50 },
	[32] = { range = 80, accuracy = 0.9, damage = 50 },
	[29] = { range = 120, accuracy = 0.8, damage = 50 },

	[30] = { range = 130, accuracy = 0.8, damage = 60 },
	[31] = { range = 150, accuracy = 0.8, damage = 70 },

	[33] = { range = 150, accuracy = 0.5, damage = 192 },
	[34] = { range = 300, accuracy = 1, damage = 400 },

	[35] = { range = 55, accuracy = 1, damage = 75 },
}

local skillLevels = { "poor", "std", "pro" }

local propertyMappings = {
	range = "weapon_range",
	accuracy = "accuracy",
	damage = "damage",
}

addEventHandler("onResourceStart", root, function()
	for weaponID, config in pairs(weaponConfigurations) do
		for _, skill in ipairs(skillLevels) do
			for configKey, gamePropertyName in pairs(propertyMappings) do
				if config[configKey] ~= nil then
					setWeaponProperty(weaponID, skill, gamePropertyName, config[configKey])
				end
			end
		end
	end
end)
