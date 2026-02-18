
--local ANIM_X = animations.wheelchair.lookHorizontal:speed(0)
local ANIM_Y = animations.wheelchair.lookVertical:speed(0)


--ANIM_X:speed(0):play()
ANIM_Y:speed(0):play()

events.RENDER:register(function (delta, ctx)
	-- avoid recalculating in the shadow pass
	if ctx == "RENDER" then
		local rot = vanilla_model.BODY:getOriginRot()._y - vanilla_model.HEAD:getOriginRot().xy
		rot.y = ((rot.y + 180) % 360 - 180) / -50
		rot.x = rot.x / 90
		---@cast rot Vector2
	--	ANIM_X:setTime(rot.y*-0.5+0.5)
		ANIM_Y:setTime(rot.x*0.5+0.5)
	end
end)


