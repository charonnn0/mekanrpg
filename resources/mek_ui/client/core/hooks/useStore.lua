local stores = {}

function useStore(key)
	if not stores[key] then
		stores[key] = {}
	end

	return {
		get = function(column)
			return stores[key][column]
		end,
		set = function(column, value)
			stores[key][column] = value
		end,
		value = stores[key],
	}
end

function clearStore(key)
	stores[key] = nil
	collectgarbage()
end
