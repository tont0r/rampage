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


	local bodyW, bodyH = 64, 128      -- match your drawn sprite if you want
	local feetW, feetH = 30, 10
	local feetYOffset = (bodyH / 2) - (feetH / 2) 


	self.player.bodyShape = love.physics.newRectangleShape(32, 100)
	self.player.bodyFixture = love.physics.newFixture(self.player.body, self.player.bodyShape, 1)
	self.player.bodyFixture:setUserData("player_body")
	self.player.bodyFixture:setFilterData(CAT_PLAYER,CAT_ROAD,0)
	self.player.bodyFixture:setFriction(1)
	-- self.feet.body = love.physics.newBody(world, self.x,self.y + 80 , "dynamic")
    
	self.player.feetShape = love.physics.newRectangleShape(0, feetYOffset, feetW, feetH)
    self.player.feetFixture = love.physics.newFixture(self.player.body, self.player.feetShape, 1)
    -- self.feet.fixture:setFilterData(0,0,0)    
    self.player.feetFixture:setSensor(true)
    self.player.feetFixture:setFilterData(CAT_FEET,CAT_RAIL,0)
    self.player.feetFixture:setUserData("player_feet")
    self.player.feetFixture:setFriction(1)

    
end
local function drawFixtureAABB(fixture)
  local left, top, right, bottom = fixture:getBoundingBox()
  love.graphics.rectangle("line", left, top, right - left, bottom - top)
end

function Player:update(dt)
	self.x = self.player.body:getX()
	self.y = self.player.body:getY()
	if self.player.body:getX() > 600 then
		self.player_x_offset = self.player.body:getX() - 600
		-- print(self.player_x_offset)
	end
	if (self.platform_state == "jumping" or self.platform_state == "entered" or self.platform_state == "exited" ) then
		self.y = self.player.body:getY()
		self.x = self.player.body:getX()
	end
	if self.platform_state == "landed" then
		self.player.feetFixture:setSensor(false)
	end
	-- print(self.player.body:getLinearVelocity())
	if self.platform_state == "dropping" and self.player.body:getLinearVelocity() == 0 then
		self.platform_state = "below"
	end

end

function Player:pickup(car)
	self.isHolding = true
	self.holding = car
end

function Player:move(direction,building)	

	if (self.state == 0) then		
		if (direction == "right") then
			self.player.body:setLinearVelocity(100, 0)
			-- print(self.state,direction,self.player.body:getLinearVelocity())
		end
		if (direction == "left") then
			self.player.body:setLinearVelocity(-100, 0)
		end
		-- if (direction == "right")  and (self.isClimbing == false or (building ~= nil and self.isClimbing == true and self.x < building.buildingWidth + 16)) then
		-- 	self.direction = direction
		-- 	self.x = self.x + self.speed
		-- 	self.player.body:setX(self.x)
		-- end
		-- -- and self.x > 48 
		-- if (direction == "left")and (self.isClimbing == false or (building ~= nil and self.isClimbing == true and self.x > building.x + 32)) then
		-- 	self.direction = direction
		-- 	self.x = self.x - self.speed
		-- 	self.player.body:setX(self.x)
		-- end
		-- if (direction == "up") then			
		-- 	self.y = self.y - self.speed
		-- 	self.player.body:setY(self.y)
		-- 	self.isClimbing = true
		-- end
		-- if (direction == "down" and self.isClimbing == true) then
		-- 	self.y = self.y + self.speed
		-- 	if self.y >= self.starting_y then
		-- 		self.player.body:setY(self.y)
		-- 		self.isClimbing = false
		-- 	end
		-- end
		-- print(self.platform_state )
		if (direction == "down" and self.platform_state == "landed") then
			self.platform_state = "dropping"
			self.player.feetFixture:setSensor(true)
		end
	end
end

function Player:draw()
	drawFixtureAABB(self.player.bodyFixture)
	drawFixtureAABB(self.player.feetFixture)
	quad = love.graphics.newQuad(32*self.state,0,32,64,64,64)
	
  local sx = (self.direction == "right") and 2 or -2
  local sy = 2

  local bx, by = self.player.body:getPosition()
  local maxX = love.graphics.getWidth() - 200
  local drawX = math.min(bx, maxX)
  -- quad is 32x64, scaled by 2 => 64x128 on screen
  -- So origin should be half of the *unscaled* quad, because scale is applied after origin
  local ox, oy = 16, 32

  love.graphics.draw(self.player_sheet, quad, bx, by, 0, sx, sy, ox, oy)     
end

function Player:jump()
    if self.platform_state ~= "landed" then
        self.platform_state = "jumped"
    end
    self.player.body:applyLinearImpulse(50,-400)
end


function Player:attack()
	self.state = 1
	self.attacking = true
end

function Player:resetState()
	self.attacking = false
	self.state = 0
end