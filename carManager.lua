Object = require "classic"
CarManager = Object:extend()
require "car"

function CarManager:new()
	self.off_screen = love.graphics.getWidth() + 50
	self.respawnTime = 1 --milliseconds?
	self.timer = self.respawnTime
	self.startCars = 0
	self.totalCars = 0
	self.cars = {}
	for i = 0,self.startCars do 
		self.cars[i] = Car(0-(i * 100),500)
		self.totalCars = i+1
	end
	print("Total cars : " .. self.totalCars)
end

function CarManager:isColliding(player_x,player_y,action)
	for i = 0,self.totalCars do 
		if self.cars[i] ~= nil then
			local car = self.cars[i]
			if (math.abs(player_x - car.x) < 100) and car.state ~= "flying" then
				car:hit()
			end
		end
	end
end

function CarManager:addCar()
	self.timer = self.respawnTime
	local number = love.math.random( -500, 0 )
	self.cars[self.totalCars+1] = Car(number,500)
	self.totalCars = self.totalCars + 1
	print("Total cars : " .. self.totalCars)
	-- if (i ~= -1) then
	-- 	local car = Car(0,500)	
	-- 	self.cars[i] = car
	-- 	print("Added car")	
	-- end
	

end

function CarManager:drawCars()
	for i = 0,self.totalCars do 
		if self.cars[i] ~= nil then
			local car = self.cars[i]
			local startState = car.state
			car:draw(dt)			
			local endState = car.state
			if (endState == "crashed" and startState ~= "crashed") then
				self:addCar()
			end
		end
	end
end

function CarManager:resetCar(i)
	self.cars[i].x= 0
end

function CarManager:updateCars(dt)
	self.timer = self.timer - dt
	for i = 0,self.totalCars do 
		if self.cars[i] ~= nil then
			local car = self.cars[i]
			
			car:update(dt)		
			if (car.x > self.off_screen) then
				self:resetCar(i)
			end
			
		end
	end

end



function CarManager:findIndex()
	for i = 0,self.totalCars do 
		if self.cars[i] == nil then
			return i 
		end
	end
	return -1
end

