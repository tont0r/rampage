Object = require "classic"
Rocket = Object:extend()

function Rocket:new(x,y)
	self.rocket = love.graphics.newImage("graphics/rocket.png")   
    self.rocket:setFilter("nearest", "nearest")
    self.x = x
    self.y = y
end

function Rocket:draw()
	love.graphics.draw(self.rocket, self.x,self.y)        
end

