--declaring specific screen objects such as physics and game objects
local ScreenControler = Object:extend()
function ScreenControler:new()
  love.window.setMode(SCREEN_WIDTH,SCREEN_HEIGHT)
  orderedUpdate =  OrderedUpdate(self)
  
  orderedUpdate:addScreenObject('UI')
  
  input:bind('mouse1','spawnBoid')
  input:bind('mouse2','spawnBoids')
  
end

function ScreenControler:update(dt)
  orderedUpdate:update(dt)
  if input:pressed('spawnBoid') then
    orderedUpdate:addScreenObject('Boidv3',love.mouse.getX(),love.mouse.getY(),{rotation = love.math.random(-math.pi,math.pi), velocity = love.math.random(30,70),colour = {0.921, 0.078, 0.266},isInfected = true})
  end
  if input:pressed('spawnBoids') then
    while desiredBoids >0 do
       orderedUpdate:addScreenObject('Boidv3',love.math.random(BOID_SPACE_WIDTH),love.math.random(BOID_SPACE_HEIGHT),{rotation = love.math.random(-math.pi,math.pi), velocity = love.math.random(30,70)})
       desiredBoids = desiredBoids -1;
    end
  end
end

function ScreenControler:draw()
  orderedUpdate:draw()
  love.graphics.rectangle("line",love.mouse.getX(),love.mouse.getY(),10,10 )
  love.graphics.setLineWidth(20)
  love.graphics.line(0,BOID_SPACE_HEIGHT+10,BOID_SPACE_WIDTH,BOID_SPACE_HEIGHT+10)
  love.graphics.setLineWidth(1)
  
end
return ScreenControler