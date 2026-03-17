function registerEnum(array)
	local enum = {}
	for _, v in ipairs(array) do
		enum[string.upper(v)] = v
	end
	return enum
end
