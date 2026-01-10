Object = require "classic"
Player = Object:extend()

function Player:new(x,y)
	self.player_sheet = love.graphics.newImage("graphics/player-sheet.png")   
    self.player_sheet:setFilter("nearest", "nearest")
	self.x = x
	self.y = y
	self.starting_y = y
	self.platform_state = "below" -- below | exited | landed
	self.state = 0 --standing. 1 is attacking
	self.isClimbing = false
	self.speed  =2
	self.attacking = false
	self.direction = "right"
	self.player_x_offset = 0
	self.isHolding = false
	self.holding = nil
	self.feet = {}
	self.feet.body = love.physics.newBody(world, self.x,self.y + 80 , "dynamic")
    self.feet.shape = love.physics.newRectangleShape(16, 32, 32, 25)
    self.feet.fixture = love.physics.newFixture(self.feet.body, self.feet.shape, 5)
    -- self.feet.fixture:setFilterData(0,0,0)    
    self.feet.body:setUserData("player")
    self.feet.body:setGravityScale(0)
    self.feet.fixture:setFriction(1)
    -- self.top.fixture:setSensor(true)
    
    -- self.top.body:setUserData("player")
    
end

function Player:update(dt)
	if self.x > 600 then
		self.player_x_offset = self.x - 600
		-- print(self.player_x_offset)
	end

end

function Player:pickup(car)
	self.isHolding = true
	self.holding = car
end

function Player:move(direction,building)	

	--and self.x < love.graphics.getWidth() - 48
	if (self.state == 0) then		
		if (direction == "right")  and (self.isClimbing == false or (building ~= nil and self.isClimbing == true and self.x < building.buildingWidth + 16)) then
			self.direction = direction
			self.x = self.x + self.speed
		end
		-- and self.x > 48 
		if (direction == "left")and (self.isClimbing == false or (building ~= nil and self.isClimbing == true and self.x > building.x + 32)) then
			self.direction = direction
			self.x = self.x - self.speed
		end
		if (direction == "up") then			
			self.y = self.y - self.speed
			self.isClimbing = true
		end
		if (direction == "down") then
			self.y = self.y + self.speed
			if self.y >= self.starting_y then
				self.isClimbing = false
			end
		end
		self.feet.body:setX(self.x)
		self.feet.body:setY(self.y)
	end
end

function Player:draw()
	love.graphics.polygon("line", self.feet.body:getWorldPoints(self.feet.shape:getPoints()))


	quad = love.graphics.newQuad(32*self.state,0,32,64,64,64)
	if self.direction == "right" then
		d = 2
	else 
		if self.direction == "left" then
			d = -2
		end
	end
	local max_x = math.min(self.x,love.graphics.getWidth() - 200)
    love.graphics.draw(self.player_sheet, quad, max_x, self.y,0,d,2)        
end

function Player:jump()
	self.feet.body:setGravityScale(1)
	self.feet.body:setType("dynamic")
    self.feet.body:applyLinearImpulse(50,-550)	
end


function Player:attack()
	self.state = 1
	self.attacking = true
end

function Player:resetState()
	self.attacking = false
	self.state = 0
end