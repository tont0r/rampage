Object = require "classic"
Car = Object:extend()
local CAT_CAR = 0x0001 

function Car:new(x,y)
	self.image = love.graphics.newImage("graphics/car.png")
	self.exploding = love.graphics.newImage("graphics/car-Sheet.png")
	self.image:setFilter("nearest", "nearest")
	self.exploding:setFilter("nearest", "nearest")
	self.x = x
	self.y = y
	self.speed = 50
	self.direction = "right" --right or left
	self.state = "driving" -- driving, flying, exploding, exploded, held
	self.box = {}
	self.radians = 0
    self.box.body = love.physics.newBody(world, 200,500 , "static")
    self.box.shape = love.physics.newRectangleShape(0, 0, 50, 25)
    self.box.fixture = love.physics.newFixture(self.box.body, self.box.shape, 5)    
    self.box.fixture:setFilterData(1, 0, 0)
    self.falling = false
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
	love.graphics.polygon("line", self.box.body:getWorldPoints(self.box.shape:getPoints()))
end

function Car:hit()
	if (self.state == "crashed") then
		return
	end
	self.state = "flying"
    self.box.body:setType("dynamic")
    self.box.body:applyLinearImpulse(300,-750)
end

function Car:held()
	self.state = "held"
end

function Car:update(dt)

	if self.state == "driving" then
		if (self.direction == "right") then
			self.x = self.x + self.speed * dt
			self.box.body:setX(self.x)
		end
		if (self.direction == "left") then
			self.x = self.x - self.speed * dt
		end
	end

	if (self.state == "flying") then
		local falling = self.y - self.box.body:getY() 
		self.x = self.box.body:getX()
		self.y = self.box.body:getY()
		self.radians = self.radians + .1
		-- this was checking the y value. id like to use isTouching
		if (falling == 0) then
			self.box.body:setType("static")
			self.box.body:setMass(100)
			self.state = "exploding"
		end
	end
end
