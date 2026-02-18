local Spring = require("lib.spring")

local WHEEL_CHAIR = models.wheelchair
local LEFT_WHEEL = WHEEL_CHAIR.Base.lWheel
local RIGHT_WHEEL = WHEEL_CHAIR.Base.rWheel

local ROW = 0.0375
local SPEED = 1.2

renderer:setRootRotationAllowed(false)

local key = {
	left = keybinds:fromVanilla("key.left"),
	right = keybinds:fromVanilla("key.right"),
	forward = keybinds:fromVanilla("key.forward"),
	backward = keybinds:fromVanilla("key.back")
}

for key, value in pairs(key) do
	value.press = function (modifiers, self)
		return true
	end
end



local pos = vec(0,0,0)
local rot = 0
local lrot = 0
local llrot = 0

local lwheel = Spring.new(0.5,0.2,0.05)
local rwheel = Spring.new(0.5,0.2,0.05)

events.ENTITY_INIT:register(function ()
	pos = player:getPos()
end)

function pings.moveLeft()
	lwheel.target = lwheel.target - ROW
	animations.wheelchair.lMove:stop():play()
end

function pings.moveRight()
	rwheel.target = rwheel.target - ROW
	animations.wheelchair.rMove:stop():play()
end

function pings.syncRot(r)
	rot = r
end


key.left.press = function (modifiers, self)
	pings.moveLeft()
	return true
end

key.right.press = function (modifiers, self)
	pings.moveRight()
	return true
end

local syncTime = 0
events.TICK:register(function ()
	local vel = vec(table.unpack(player:getNbt().Motion))
	local dir = vectors.rotateAroundAxis(math.deg(rot), vec(0,0,1), vec(0,1,0))
	llrot = lrot
	lrot = rot
	rot = rot + lwheel.vel * SPEED
	rot = rot - rwheel.vel * SPEED
	if host:isHost() then
		silly:setVelocity(dir * math.min(lwheel.vel,rwheel.vel) + vel._y_)
		syncTime = syncTime + 1
		if syncTime > 5*20 then
			syncTime = 0
			pings.syncRot(rot)
		end
	end
end)

events.RENDER:register(function (delta, ctx, matrix)
	if ctx == "RENDER" then
		local trot = math.lerp(lrot, rot, delta)
		WHEEL_CHAIR:setRot(0,math.deg(trot),0)
		LEFT_WHEEL:setRot(math.deg(lwheel.pos)*48,0,0)
		RIGHT_WHEEL:setRot(math.deg(rwheel.pos)*48,0,0)
	end
end)


if host:isHost() then
	local lastTime = client:getSystemTime()
	events.WORLD_RENDER:register(function (delta)
		if player:isLoaded() then
			local tlrot = math.lerp(llrot, lrot, delta)
			local trot = math.lerp(lrot, rot, delta)
			local time = client:getSystemTime()
			local d = (time - lastTime) / 1000
			lastTime = time
			silly:setRot(player:getRot() - vec(0,math.deg(tlrot-trot) * d * -20))
		end
	end)
end
