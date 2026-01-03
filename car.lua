Object = require "classic"
Car = Object:extend()


function Car:new(x,y)
	self.image = love.graphics.newImage("graphics/car.png")
	self.exploding = love.graphics.newImage("graphics/car-Sheet.png")
	self.image:setFilter("nearest", "nearest")
	self.exploding:setFilter("nearest", "nearest")
	self.x = x
	self.y = y
	self.speed = 50
	self.direction = "right" --right or left
	self.state = "driving" -- driving, flying, exploding, exploded
	self.ball = {}
	self.radians = 0
    self.ball.body = love.physics.newBody(world, 200,500 , "static")
    self.ball.shape = love.physics.newRectangleShape(0, 0, 50, 100)
    self.ball.fixture = love.physics.newFixture(self.ball.body, self.ball.shape, 5)    
    self.ball.fixture:setFilterData(1, 0, 0)
    self.explodeFrame = 1
	self.framesBetween = 10
	self.framesUntilLoop = 0
end

function Car:draw()
	if (self.state == "driving" or self.state == "flying") then
		imageHalfWidth = self.image:getWidth() / 2
	    imageHalfHeight = self.image:getHeight() / 2
	    local d = -1
	    if (self.direction == "left") then
	    	d = 1
	    end
		love.graphics.draw(self.image, self.x -player.player_x_offset,self.y,self.radians,d,1, imageHalfWidth,imageHalfHeight)
	end
	if (self.state == "exploding") then
		if (self.framesUntilLoop <= 100) then
			self.framesUntilLoop = self.framesUntilLoop + 1		
		end
		quad = love.graphics.newQuad(32*self.explodeFrame,0,32,16,224,16)
		love.graphics.draw(self.exploding, quad, self.x, self.y,0,2.5,2.5)     
		
		if self.framesUntilLoop == 10 then
			self.explodeFrame = self.explodeFrame +1
			if self.explodeFrame == 7 then
				self.state="crashed"
			end
			self.framesUntilLoop = 0
		end
	end
	if (self.state == "crashed") then
		quad = love.graphics.newQuad(32*6,0,32,16,224,16)
		love.graphics.draw(self.exploding, quad, self.x, self.y,0,2.5,2.5)
	end
end

function Car:hit()
	if (self.state == "crashed") then
		return
	end
	self.state = "flying"
    self.ball.body:setType("dynamic")
    self.ball.body:applyLinearImpulse(1000,-3000)
end

function Car:update(dt)
	if self.state == "driving" then
		if (self.direction == "right") then
			self.x = self.x + self.speed * dt
			self.ball.body:setX(self.x)
		end
		if (self.direction == "left") then
			self.x = self.x - self.speed * dt
		end
	end

	if (self.state == "flying") then
		print(self.ball.body:getType())
		self.x = self.ball.body:getX()
		self.y = self.ball.body:getY()
		self.radians = self.radians + .1
		if (self.y >= 500) then
			self.ball.body:setType("static")
			self.state = "exploding"
		end
	end
end
