require "building"
require "player"
require "helicopter"
require "carManager"
require "rocket"
require "railManager"
function love.load()
    helicopter_arr = {}
    Object = require "classic"

    screen_width = love.graphics.getWidth()
    screen_height = love.graphics.getHeight()

    love.physics.setMeter(64) --the height of a meter our worlds will be 64px
    world = love.physics.newWorld(0, 9.81*64, true) 
    world:setCallbacks(beginContact,endContact,preSolve,nil)
    road = {}
    road.body = love.physics.newBody(world, 5, 800 , "static")
    road.shape = love.physics.newRectangleShape(5, 5, screen_width+10000, screen_height-5)
    road.fixture = love.physics.newFixture(road.body, road.shape, 0) 
    road.body:setUserData("road") 
    x=300
    y=450
    carManager = CarManager()
    railManager = RailManager()

    player = Player(100,y-64)
    buildings = {}
    building1 = Building(x,y,5,3)
    helicopter = Helicopter(150,100,0,300)

    building2 = Building(x+600,y,3,5)

    building3 = Building(x+1200,y,6,4)
    buildings[0] = building1
    buildings[1] = building2
    buildings[2] = building3    
    buidling_count = 3


    rocket = Rocket(50,125)

    heli_count = 0
    helicopter_arr[0] = helicopter
    background = love.graphics.newImage("graphics/background.png")   
    background:setFilter("nearest", "nearest")

end
local function bodyTag(fix)
  return fix:getBody():getUserData()
end

function beginContact(a, b, contact)
  local ua, ub = a:getUserData(), b:getUserData()

  -- Feet touching rail?
  if (ua == "player_feet" and ub == "rail") or (ub == "player_feet" and ua == "rail") then
    print("b "..player.platform_state)
    -- We only "land" after we've exited once (passed through from below)
    if player.platform_state == "below" or player.platform_state == "jumped" then
      player.platform_state = "entered"
    end
    if player.platform_state == "exited" then
      player.platform_state = "landed"
      print("LANDED")
    else
      print("FEET TOUCH (ignored; still below)")
    end
  end
end

function endContact(a, b, contact)
  local ua, ub = a:getUserData(), b:getUserData()
    print("e "..player.platform_state)
  if (ua == "player_feet" and ub == "rail") or (ub == "player_feet" and ua == "rail") then
    if player.platform_state == "entered" then
        player.platform_state = "exited"
    end
    -- player.feetTouchingRail = math.max(0, player.feetTouchingRail - 1)
    -- print("feet touching rail:", player.feetTouchingRail)
  end
end


function love.draw()
    love.graphics.draw(background,0,0)
    for i = 0,buidling_count-1 do
        building = buildings[i]
        building:draw()
    end
    rocket:draw()
    player:draw()
    railManager:draw()
    helicopter:draw()
    carManager:drawCars()
    love.graphics.polygon("line", road.body:getWorldPoints(road.shape:getPoints()))
    
    
end

function love.update(dt)
    world:update(dt)
    carManager:updateCars(dt)
    player:update(dt)
    for h= 0,heli_count do
        helicopter:update(dt)
    end
    local building_touching = nil
    for i = 0,buidling_count-1 do
        building = buildings[i]
        if building:isColliding(player.x-32,player.y,"down") then
            building_touching = building
        end
    end


    if love.keyboard.isDown("up") then
        for i = 0,buidling_count-1 do
            building = buildings[i]
            if building:isColliding(player.x,player.y,"up") then
                player:move("up",building_touching)
            end
        end
        
    end
    
    if (helicopter:isColliding(player.x,player.y)) then
    end

    if love.keyboard.isDown("down") then
        for i = 0,buidling_count-1 do
            building = buildings[i]
            if building:isColliding(player.x,player.y,"down") then
                player:move("down",building_touching)
            end
        end
    end

    if love.keyboard.isDown("rshift") then
        pushRadial(world, player.x, player.y+64, 100, 100)
        -- pushRadial(world, player.x, player.y+64, -50, 00)
    end


    if love.keyboard.isDown("left") then
        player:move("left",building_touching)
    end
    if love.keyboard.isDown("right") then
        player:move("right",building_touching)
    end
    if love.keyboard.isDown("space") then
        if (player.attacking == false) then
            player:attack()
            if player.direction == "right" then
                for i = 0,buidling_count-1 do
                    building = buildings[i]
                    building:hitWindow(player.x+64,player.y+128)
                end
            else 
                for i = 0,buidling_count-1 do
                    building = buildings[i]
                    building:hitWindow(player.x-64,player.y+128)
                end
            end
        end
    end
end

function love.keyreleased(key)
    if (key == "space") then
        player:resetState()
    end
    if (key == "lshift") then
        carManager:isColliding(player.x,player.y,"hit") 
    end
    if (key == "lgui") then
        -- carManager:isColliding(player.x,player.y,"pickup") 
        -- world:queryBoundingBox(player.x - 32, player.y - 32, player.x + 32, player.y + 32, function(fixture)
        --     print(fixture)
        --     return true
        -- end)
        player:jump()
    end
end


function pushRadial(world, cx, cy, radius, strength)
  -- Broad-phase: get fixtures in a bounding box (fast)
  world:queryBoundingBox(cx - radius, cy - radius, cx + radius, cy + radius, function(fixture)
    local body = fixture:getBody()
    if body:getType() ~= "dynamic" then return true end

    local bx, by = body:getWorldCenter()
    local dx, dy = bx - cx, by - cy
    local dist2 = dx*dx + dy*dy
    if dist2 == 0 or dist2 > radius*radius then return true end

    local dist = math.sqrt(dist2)
    local nx, ny = dx / dist, dy / dist

    -- falloff: stronger near center, weaker at edge
    local t = 1 - (dist / radius)
    local impulse = strength * t

    body:applyLinearImpulse(nx * impulse, ny * impulse)

    return true -- keep searching
  end)
end