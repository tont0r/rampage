Object = require "classic"
RailManager = Object:extend()
require "rail"
function RailManager:new()
	self.rails = {}
	for i = 0,10 do
		self.rails[i] = Rail(i*256,380)
	end
	
end


function RailManager:draw()
	for i = 0,10 do
		self.rails[i]:draw()
	end
end

