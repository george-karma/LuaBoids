--common functions among screen objects
local Boid = Object:extend()



function Boid:new(orderedUpdate,x,y,opts)
  self.x =x
  self.y = y
  self.w = 5
  self.collider = orderedUpdate.physicsWorld:newCircleCollider(self.x,self.y,self.w)
  self.collider:setObject(self)
  self.collider:setCollisionClass("Boid")
  
  self.rotation = opts.rotation
	self.rotationVelocity = 1.77*math.pi
	self.currentVelocity = opts.velocity
	self.maxVelocity = 50
	self.acceleration = 20
  
  
  self.canObserve = true 
  
  
  input:bind("mouse1","spawnBoid")
  
end

function Boid:update(dt)
  clamp(0,self.currentVelocity, self.maxVelocity)
  if self.canObserve then
    self:observe(dt)
  end
  --sync collider and drawable
  if self.collider then 
    if self.x < -self.w then 
      self.collider:setPosition(SCREEN_WIDTH + self.w, self.y) 
      self.x,self.y = self.collider:getPosition() 
      end
    if self.y < -self.w then 
      self.collider:setPosition(self.x,SCREEN_HEIGHT+self.w) 
      self.x,self.y = self.collider:getPosition() 
      end
    if self.x > self.w + SCREEN_WIDTH then 
      self.collider:setPosition(-self.w, self.y) 
      self.x,self.y = self.collider:getPosition() 
      end
    if self.y > self.w + SCREEN_HEIGHT then
      self.collider:setPosition(self.x, -self.w) 
      self.x,self.y = self.collider:getPosition() 
      end
    self.x,self.y = self.collider:getPosition() 
    self.collider:setLinearVelocity(self.currentVelocity*math.cos(self.rotation),self.currentVelocity*math.sin(self.rotation))
	end
end

function Boid:draw()
 love.graphics.line(self.x+1*self.w*math.cos(self.rotation),
							self.y+1*self.w*math.sin(self.rotation),
							self.x+1.3*self.w*math.cos(self.rotation),
							self.y+1.3*self.w*math.sin(self.rotation))
  
end



function Boid:observe(dt)
  self.canObserve = false
  --get all the coliders close to this one  and get the object they belong to
  local colliders = orderedUpdate.physicsWorld:queryCircleArea(self.x,self.y,observeRange)
  local nearbyBoids = {}
  --if there are other colliders around
  if #colliders>1 then
    for i,collider in ipairs(colliders) do
        if collider.collision_class == "Boid" then
          table.insert(nearbyBoids,collider:getObject())
        end
    end

    self:separation()
    timer:after(separationTime,function()
          self:aligment(nearbyBoids)
          timer:after(aligmentTime,function()
              self:cohesion(nearbyBoids)
              timer:after(cohesionTime + timeToCentre,function()
                self.canObserve = true
              end)
            end)
        end)
  
  else
    self.canObserve = true 
  end
end

function Boid:separation()
  local obstacles = orderedUpdate.physicsWorld:queryLine(
              self.x+minSeparation*math.cos(self.rotation),
							self.y+minSeparation*math.sin(self.rotation),
							self.x+1.3*math.cos(self.rotation),
							self.y+1.3*math.sin(self.rotation),{'Boid'})
   local obstaclesLeft = orderedUpdate.physicsWorld:queryLine(
              self.x+minSeparation*math.cos(self.rotation+math.pi/2),
							self.y+minSeparation*math.sin(self.rotation+math.pi/2),
							self.x+1.3*math.cos(self.rotation+math.pi/2),
							self.y+1.3*math.sin(self.rotation+math.pi/2),{'Boid'})
  local obstaclesRight = orderedUpdate.physicsWorld:queryLine(
              self.x+minSeparation*math.cos(self.rotation-math.pi/2),
							self.y+minSeparation*math.sin(self.rotation-math.pi/2),
							self.x+1.3*math.cos(self.rotation-math.pi/2),
							self.y+1.3*math.sin(self.rotation-math.pi/2),{'Boid'})          
  
  if #obstacles>1 then
    local closestObstacle = obstacles[1]:getObject()
    local steeringForce = math.atan2(closestObstacle.x + math.abs(closestObstacle.x - self.x)*3 ,closestObstacle.y + math.abs(closestObstacle.y - self.y)*3)
    local oldVelocity = self.currentVelocity
    local reverseRotation = -self.rotation
    timer:tween(separationTime,self,{rotation = reverseRotation, currentVelocity = maxVelocity},'linear', function() self.currentVelocity = oldVelocity/0.7 end)
  end
    --if self.rotation * closestObstacle.rotation < 0 then
    
    
    --[[
    if math.abs(closestObstacle.rotation) < math.pi/2 then
      timer:tween(separationTime,self,{rotation = steeringForce, currentVelocity = maxVelocity},'linear', function() self.currentVelocity = oldVelocity end)
    elseif math.abs(closestObstacle.rotation) > math.pi/2 then
      timer:tween(separationTime,self,{rotation = -steeringForce,currentVelocity = maxVelocity},'linear', function() self.currentVelocity = oldVelocity end)
    end    
  end
  
  --[[
  local closestObstacle = obstacles[1]
  local close = true
  for i,obstacle in ipairs(obstacles) do
    if math.abs(obstacle.x - self.x) < minSeparation or math.abs(obstacle.y - self.y) <  minSeparation then
      local close = true
        if obstacle.x < closestObstacle.x or obstacle.y <closestObstacle.y then
          closestObstacle = obstacle
        end
    end
  end
  if close then
  local steeringForce = math.atan2(closestObstacle.x + (closestObstacle.x - self.x)*3 ,closestObstacle.y + (closestObstacle.y - self.y)*3)
  local oldVelocity = self.currentVelocity
  if math.abs(closestObstacle.rotation) < math.pi/2 then
      timer:tween(separationTime,self,{rotation = steeringForce, currentVelocity = maxVelocity},'linear', function() self.currentVelocity = oldVelocity end)
  else
      timer:tween(separationTime,self,{rotation = -steeringForce,currentVelocity = maxVelocity},'linear', function() self.currentVelocity = oldVelocity end)
  end    
  end
   ]]--   ]]--
  
end



function Boid:aligment(nearbyBoids)
  local velocityAverage = 0
  local rotationAverage = 0
  for i,boid in ipairs(nearbyBoids) do
    rotationAverage = rotationAverage + boid.rotation
    velocityAverage = velocityAverage + boid.currentVelocity
  end
  rotationAverage = rotationAverage / #nearbyBoids
  velocityAverage = velocityAverage / #nearbyBoids
 -- return {rotationAverage,velocityAverage}
  timer:tween(aligmentTime,self,{rotation = rotationAverage, currentVelocity = velocityAverage/0.9},'linear')
end





function Boid:cohesion(nearbyBoids)
  local xAverage = 0
  local yAverage = 0
  for i,boid in ipairs(nearbyBoids) do
    xAverage = xAverage + boid.x
    yAverage = yAverage + boid.y
  end
  
  xAverage = xAverage / #nearbyBoids
  yAverage = yAverage / #nearbyBoids
  local oldVelocity = self.currentVelocity
  local centreRotation = math.atan2(xAverage,yAverage)
  timer:during(cohesionTime,function()
        self.rotation = centreRotation
      end, function()self.currentVelocity = oldVelocity end)
  --[[
  timeToCentre = math.sqrt(math.abs(self.x-xAverage)+math.abs(self.y - yAverage))/self.maxVelocity
  
  
  timer:tween(cohesionTime,self,{rotation = centreRotation,velocity = maxVelocity},'linear', function() 
      timer:during(timeToCentre, function() 
          self.velocity = maxVelocity 
          self.rotation = centreRotation
        end, function()
          self.velocity = oldVelocity
        end)
      end)
  --timer:tween(cohesionTime,self,{rotation = centreRotation},'linear')
  --self.rotation = self.rotation + centreRotation *0.3
  --timer:during(cohesionTime,function() self.collider:setLinearVelocity(self.currentVelocity*self.acceleration*math.cos(centreRotation),self.currentVelocity*self.acceleration*math.sin(centreRotation)) end)
  --timer:during(cohesionTime, function()self.collider:setLinearVelocity(xAverage*self.currentVelocity*self.rotation,yAverage*self.currentVelocity*self.rotation) end)
  --self.collider:setLinearVelocity(xAverage,yAverage)
  --]]
end

function clamp(min, val, max)
    return math.max(min, math.min(val, max));
end



return Boid