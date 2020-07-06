--declaring specific screen objects such as physics and game objects
local ScreenControler = Object:extend()
SCREEN_WIDTH = 1280
SCREEN_HEIGHT = 720
function ScreenControler:new()
  love.window.setMode(SCREEN_WIDTH,SCREEN_HEIGHT)
  orderedUpdate =  OrderedUpdate(self)
  
  input:bind('mouse1','spawnBoid')
  input:bind('mouse2','spawnBoids')
end

function ScreenControler:update(dt)
  orderedUpdate:update(dt)
  if input:pressed('spawnBoid') then
    orderedUpdate:addScreenObject('Boidv3',love.mouse.getX(),love.mouse.getY(),{rotation = love.math.random(-math.pi,math.pi), velocity = love.math.random(30,70)})
  end
  if input:pressed('spawnBoids') then
    while desiredBoids >0 do
       orderedUpdate:addScreenObject('Boidv3',love.math.random(SCREEN_WIDTH),love.math.random(SCREEN_HEIGHT),{rotation = love.math.random(-math.pi,math.pi), velocity = love.math.random(30,70)})
       desiredBoids = desiredBoids -1;
    end
  end
end

function ScreenControler:draw()
  orderedUpdate:draw()
  love.graphics.rectangle("line",love.mouse.getX(),love.mouse.getY(),10,10 )
  
end
return ScreenControler