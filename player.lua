Object = require "classic"
Player = Object:extend()

function Player:new(x,y)
	self.player_sheet = love.graphics.newImage("graphics/player-sheet.png")   
    self.player_sheet:setFilter("nearest", "nearest")
	self.x = x
	self.y = y
	self.starting_y = y
	self.platform_state = "below" -- below | jumped | exited | landed
	self.state = 0 --standing. 1 is attacking
	self.isClimbing = false
	self.speed  =2
	self.attacking = false
	self.direction = "right"
	self.player_x_offset = 0
	self.isHolding = false
	self.holding = nil

	self.player = {}

	self.player.body = love.physics.newBody(world, x, y, "dynamic")
	self.player.body:setFixedRotation(true)

	-- Main body shape
	self.player.bodyShape = love.physics.newRectangleShape(32, 64)
	self.player.bodyFixture = love.physics.newFixture(self.player.body, self.player.bodyShape, 1)
	self.player.bodyFixture:setUserData("player_body")



	-- self.feet.body = love.physics.newBody(world, self.x,self.y + 80 , "dynamic")
    self.player.feetShape = love.physics.newRectangleShape(16, 128, 32, 25)
    self.player.feetFixture = love.physics.newFixture(self.player.body, self.player.feetShape, 0)
    -- self.feet.fixture:setFilterData(0,0,0)    
    self.player.feetFixture:setSensor(true)
    self.player.feetFixture:setUserData("player_feet")
    self.player.feetFixture:setFriction(1)
    
end
local function drawFixtureAABB(fixture)
  local left, top, right, bottom = fixture:getBoundingBox()
  love.graphics.rectangle("line", left, top, right - left, bottom - top)
end

function Player:update(dt)
	if self.x > 600 then
		self.player_x_offset = self.x - 600
		-- print(self.player_x_offset)
	end
	if (self.platform_state == "jumping" or self.platform_state == "entered" or self.platform_state == "exited" ) then
		print(1)
		self.y = self.player.body:getY()
		self.x = self.player.body:getX()
	end
	if self.platform_state == "landed" then
		self.player.feetFixture:setSensor(false)
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
			self.player.body:setX(self.x)
		end
		-- and self.x > 48 
		if (direction == "left")and (self.isClimbing == false or (building ~= nil and self.isClimbing == true and self.x > building.x + 32)) then
			self.direction = direction
			self.x = self.x - self.speed
			self.player.body:setX(self.x)
		end
		if (direction == "up") then			
			self.y = self.y - self.speed
			self.player.body:setY(self.y)
			self.isClimbing = true
		end
		if (direction == "down") then
			self.y = self.y + self.speed
			if self.y >= self.starting_y then
				self.player.body:setY(self.y)
				self.isClimbing = false
			end
		end
		-- self.feet.body:setX(self.x)
		-- self.feet.body:setY(self.y)
	end
end

function Player:draw()
	drawFixtureAABB(self.player.feetFixture)
	quad = love.graphics.newQuad(32*self.state,0,32,64,64,64)
	if self.direction == "right" then
		d = 2
	else 
		if self.direction == "left" then
			d = -2
		end
	end
	local max_x = math.min(self.player.body:getX(),love.graphics.getWidth() - 200)
    love.graphics.draw(self.player_sheet, quad, max_x, self.player.body:getY(),0,d,2)        
end

function Player:jump()
	self.platform_state = "jumped"
	print(self.platform_state)
	self.player.body:setType("dynamic")
    self.player.body:applyLinearImpulse(50,-200)	
end


function Player:attack()
	self.state = 1
	self.attacking = true
end

function Player:resetState()
	self.attacking = false
	self.state = 0
end