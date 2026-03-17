PhoneAnimation = {
	Hold = "hold",
	In = "in",
	Out = "out",
	Camera = "camera",
}

PhoneAnimation.process = function(entity, state)
	entity:setData("phone_hold", state)
end

PhoneAnimation.get = function(entity)
	return entity:getData("phone_hold")
end
