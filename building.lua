Object = require "classic"
Building = Object:extend()
local CAT_WINDOW = 0x0002

function Building:new(x,y,floors,positions)
	self.window_sheet = love.graphics.newImage("graphics/window-sheet.png")   
    self.window_sheet:setFilter("nearest", "nearest")
	self.x = x
	self.y = y
	self.buildingWidth = x + (positions * 64)
	self.buildingWorldY = y + (floors * 64) + 64
	self.buildingHeight = (floors * 64) + 64
	self.floors = floors
	self.positions = positions
	self.windows = {}
	for i = 0,floors do
		self.windows[i] = {}
		for j = 0,positions do
			self.windows[i][j] = {}
			local box = {}
			local type = "dynamic"
		    box.body = love.physics.newBody(world, self.x + (j * 64), self.y-(i * 64) , type)
		    box.shape = love.physics.newRectangleShape(32, 32, 59,59)
		    box.fixture = love.physics.newFixture(box.body, box.shape, 1)  
		    box.body:setUserData("building ".. i ..", " .. j)  
		    -- box.fixture:setFilterData(CAT_WINDOW, 0, 0)
		    self.windows[i][j].box = box
			self.windows[i][j].frame = 0
		end
	end
end

function Building:isColliding(x,player_y,direction)
	value = self.y -self.buildingHeight
	final = (value-player_y > 64 -8 and direction == "up") or (direction == "down" and player_y + 64 > self.y)
	return x <=self.buildingWidth and x+32 > self.x and final ~= true
end

function Building:draw()
	-- building:drawColliders()
    for i = 0,self.floors do    
        for j = 0,self.positions do
        	local window = self.windows[i][j]        	    
            quad = love.graphics.newQuad(window.frame*32,0,32,32,96,32)
            if window.box.body:isDestroyed() == false then 
            	love.graphics.draw(self.window_sheet, quad, window.box.body:getX() - player.player_x_offset, window.box.body:getY(),window.box.body:getAngle(),2)        
            end
            
        end    
    end
end


function Building:windowAtPoint(px, py)
  
  for i = 0, self.floors do
    for j = 0, self.positions do
      local box = self.windows[i][j].box
      if box.body:isDestroyed() == false then 
	      local tx, ty = box.body:getPosition()
	      local tr     = box.body:getAngle()
	      -- print("Testing "..tx ..", "..ty)
	      -- Shape:testPoint(tx, ty, tr, x, y)
	      if box.shape:testPoint(tx, ty, tr, px, py-80) then
	        return i, j, self.windows[i][j]   -- found the window being touched
	      end
      end
    end
  end

  return nil
end


function Building:hitWindow(x,y)
	-- hit = Shape:testPoint( tx, ty, tr, x, y )

	-- window_position = math.floor((x-self.x)/64)
	-- window_floor = math.ceil((self.y-y+64)/64)
	local i, j, win = self:windowAtPoint(x, y)
	  if win then
    	if win.frame < 2 then
			win.frame = win.frame + 1
		end
		if win.frame == 2 then
			local direction = 200
			if player.direction == "left" then
				direction = -200
			end
			
			win.box.body:applyLinearImpulse(direction,500)
			local floorDestroyed = true
			for x = 0,self.positions do
				local w = self.windows[i][x]
				if (w.frame ~= 2) then
					floorDestroyed = false
				end
			end
			if floorDestroyed == true then
				for x = 0,self.positions do
					local w = self.windows[i][x]
					w.box.body:destroy()
				end
			end
		end

	  end

end


