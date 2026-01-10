Object = require "classic"
Rail = Object:extend()

function Rail:new(x,y)
	self.rail = love.graphics.newImage("graphics/tracks.png")   
    self.rail:setFilter("nearest", "nearest")
    self.x = x
    self.y = y
    self.top = {}
    self.top.body = love.physics.newBody(world, self.x,self.y , "static")
    self.top.shape = love.physics.newRectangleShape(0, 16, 256, 10)
    self.top.fixture = love.physics.newFixture(self.top.body, self.top.shape)    
    -- self.top.fixture:setFilterData(CAT_RAIL,CAT_PLAYER,0)
    self.top.body:setGravityScale(0)
    self.top.body:setSleepingAllowed(false)
    self.top.fixture:setUserData("rail")
    self.top.fixture:setFriction(1)
    
end

function Rail:update()
end

function Rail:draw()
	love.graphics.polygon("line", self.top.body:getWorldPoints(self.top.shape:getPoints()))
	love.graphics.draw(self.rail, self.x - player.player_x_offset,self.y)
end