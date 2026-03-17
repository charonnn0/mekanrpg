local variantColors = {
	solid = function(color)
		return {
			background = color[500],
			textColor = color[50],
		}
	end,
	soft = function(color)
		return {
			background = color[50],
			textColor = color[700],
		}
	end,
	outlined = function(color)
		return {
			background = BACKGROUND.SURFACE,
			textColor = color[500],
		}
	end,
	plain = function(color)
		return {
			background = BACKGROUND.BODY,
			textColor = color[400],
		}
	end,
}

function useAlertVariant(variant, color)
	return variantColors[variant] and variantColors[variant](_G[string.upper(color)])
end
