local variantColors = {
	solid = function(color)
		return {
			background = color[600],
			textColor = color[50],
			hover = color[700],
		}
	end,
	soft = function(color)
		return {
			background = color[800],
			textColor = color[200],
			hover = color[700],
		}
	end,
	outlined = function(color)
		return {
			background = color[700],
			textColor = color[400],
			hover = color[600],
		}
	end,
	plain = function(color)
		return {
			background = FULL_OPACITY,
			textColor = color[300],
			hover = color[500],
		}
	end,
}

function useCheckboxVariant(variant, color)
	return variantColors[variant] and variantColors[variant](_G[string.upper(color)])
end
