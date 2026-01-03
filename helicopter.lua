Object = require "classic"
Helicopter = Object:extend()

function Helicopter:new(x,y,x_start,x_end)
	self.x = x
	self.y = y
	self.x_start = x_start
	self.x_end = x_end
	self.direction = "right"
	self.state = "flying" -- falling, exploding,flying,crashed
	self.image = love.graphics.newImage("graphics/helicopter.png")
	self.exploding = love.graphics.newImage("graphics/helicopter-Sheet.png")
	self.image:setFilter("nearest", "nearest")
	self.exploding:setFilter("nearest", "nearest")
	self.explodeFrame = 1
	self.framesBetween = 10
	self.framesUntilLoop = 0
end

function Helicopter:isColliding(player_x,player_y)
	if (self.x + 100> player_x and 
		self.y - 64 < player_y+64 and
		self.y  > player_y and
		self.state == "flying") then
		self.state = "falling"
	end
end

function Helicopter:update(dt)
	
	if (self.state == "falling") then
		if (self.y < 500) then
			self.y = self.y + 300 * dt
			self.x = self.x + 100 * dt
		else self.state="exploding"
		end
	end
	if (self.state == "flying") then
		if (self.direction == "right") then
			self.x = self.x + dt * 100
		end
		if (self.direction == "left") then
			self.x = self.x - dt * 100
		end
		if self.x > self.x_end and self.direction == "right" then
			self.direction = "left"
		end
		if self.x < self.x_start and self.direction == "left" then
			self.direction = "right"
		end
	end
end
function Helicopter:fall()
	self.state = "falling"
end

function Helicopter:draw()
	if (self.state == "exploding") then
		self:explode()
		return
	end
	if (self.state == "crashed") then
		self:crashed()
		return
	end
	if (self.direction == "right") then
		d=1
	end
	if (self.direction == "left") then
		d=-1
	end
	imageHalfWidth = self.image:getWidth() / 2
    imageHalfHeight = self.image:getHeight() / 2
	love.graphics.draw(self.image, self.x,self.y,0,d,1, imageHalfWidth, imageHalfHeight)
end

function Helicopter:crashed()
	local quad = love.graphics.newQuad(128*self.explodeFrame,0,128,64,1024,64)
	love.graphics.draw(self.exploding, quad, self.x, self.y,0)     
end

function Helicopter:explode()
	if (self.framesUntilLoop <= 100) then
		self.framesUntilLoop = self.framesUntilLoop + 1		
	end
	quad = love.graphics.newQuad(128*self.explodeFrame,0,128,64,1024,64)
	love.graphics.draw(self.exploding, quad, self.x, self.y,0)     
	
	if self.framesUntilLoop == 10 then
		self.explodeFrame = self.explodeFrame +1
		if self.explodeFrame == 7 then
			self.state="crashed"
		end
		self.framesUntilLoop = 0
	end
end
