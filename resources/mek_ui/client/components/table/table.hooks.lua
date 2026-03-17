local variantColors = {
	solid = function(color)
		return {
			background = color[600],
			header = color[700],
		}
	end,
	soft = function(color)
		return {
			background = color[800],
			header = color[800],
		}
	end,
	outlined = function(color)
		return {
			background = color[900],
			header = color[700],
		}
	end,
	plain = function(color)
		return {
			background = color[900],
			header = color[700],
		}
	end,
}

function useTableVariant(variant, color)
	return variantColors[variant] and variantColors[variant](_G[string.upper(color)])
end
