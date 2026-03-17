local colors = {
	{ 174, 239, 255, 255 },
	"#AEEFFF",        
	{ 174, 239, 255 }       
}

function getServerColor(colorType, alpha)
	local color = colors[colorType]

	if not color then
		color = { 255, 255, 255, 255 }
	end

	if alpha and tonumber(alpha) then
		if #color == 3 then
			return tocolor(color[1], color[2], color[3], alpha)
		elseif #color == 4 then
			return tocolor(color[1], color[2], color[3], alpha)
		end
	end

	if #color == 4 then
		return tocolor(color[1], color[2], color[3], color[4])
	end

	return color
end
