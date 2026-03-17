local variantColors = {
	solid = function(color)
		return {
			background = color[600],
			tab = color[900],
		}
	end,
	soft = function(color)
		return {
			background = color[800],
			tab = color[900],
		}
	end,
	outlined = function(color)
		return {
			background = color[900],
			tab = color[900],
		}
	end,
	plain = function(color)
		return {
			background = color[900],
			tab = color[900],
		}
	end,
}

function useTabPanelVariant(variant, color)
	return variantColors[variant] and variantColors[variant](_G[string.upper(color)])
end
