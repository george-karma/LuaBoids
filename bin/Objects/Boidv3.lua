--common functions among screen objects
local Boid = Object:extend()



function Boid:new(orderedUpdate,x,y,opts)
  --[[profiler.start()
  timer:after(30,function()
    profiler.stop()
    profiler.report("5_boid.log")
    love.event.quit()
    end)--]]
  self.x = x
  self.y = y
  self.w = 10
  self.position = Vector.new(self.x,self.y)
  
  
  self.collider = orderedUpdate.physicsWorld:newCircleCollider(self.x,self.y,self.w)
  self.collider:setObject(self)
  self.collider:setCollisionClass("Boid")    

  self.rotation = opts.rotation
	self.rotationVelocity = 1.77*math.pi
	self.speed = 10
	self.maxSpeed = 0.3
  
	self.acceleration = Vector.new(0,0)
  self.velocity = Vector.new(math.cos(self.rotation),math.sin(self.rotation))
  
  self.colours = {
    red = {0.921, 0.078, 0.266},
    green = {0.137, 0.678, 0.062},
    white = {1, 1, 1}
  }
  self.colour = opts.colour  or self.colours.green
  self.isInfected = opts.isInfected or false
  
end

function Boid:update(dt)
  self:observe()
  --sync collider and drawable
  if self.x < -self.w then 
    self.collider:setPosition(BOID_SPACE_WIDTH + self.w, self.y) 
    self.x,self.y = self.collider:getPosition() 
    end
  if self.y < -self.w then 
    self.collider:setPosition(self.x,BOID_SPACE_HEIGHT+self.w) 
    self.x,self.y = self.collider:getPosition() 
    end
  if self.x > self.w + BOID_SPACE_WIDTH then 
    self.collider:setPosition(-self.w, self.y) 
    self.x,self.y = self.collider:getPosition() 
    end
  if self.y > self.w + BOID_SPACE_HEIGHT then
    self.collider:setPosition(self.x, -self.w) 
    self.x,self.y = self.collider:getPosition() 
  end
  
  --updating velocity
  self.velocity = self.velocity + self.acceleration
  --matching rotation to velocity
  self.rotation = math.atan2(self.velocity.y,self.velocity.x)
  --applying the new velocity
  self.collider:setLinearVelocity(self.velocity.x*self.speed,self.velocity.y*self.speed)
  --get the x and y of the collider and update the potition vector
  self.x,self.y = self.collider:getPosition() 
  self.position.x = self.x
  self.position.y = self.y 
  --reset acceleration to 0
  self.acceleration = self.acceleration *0
  
  --solving the chance that this boid is infected
  if self.collider:enter('Boid') then
    local collision_data = self.collider:getEnterCollisionData('Boid')
    if collision_data.collider:getObject().isInfected then
      if math.random() <= chanceToInfect then
        self.infected = true
        self.colour = self.colours.red
        end--]]
    end
  end
end

function Boid:draw()
  
  love.graphics.line(self.x+1*self.w*math.cos(self.rotation),
							self.y+1*self.w*math.sin(self.rotation),
							self.x+1.3*self.w*math.cos(self.rotation),
							self.y+1.3*self.w*math.sin(self.rotation))
  love.graphics.setColor(self.colour)
  love.graphics.circle("fill", self.x,self.y,self.w/2)
  love.graphics.setColor(self.colours.white)
  
end



 function Boid:observe(dt)
  local colliders = orderedUpdate.physicsWorld:queryCircleArea(self.x,self.y,observeRange)
  local nearbyBoids = {}
  local velocitySum = Vector.new(0,0)
  --if there are other colliders around
  if #colliders>1 then
    for i,collider in ipairs(colliders) do
        if collider.collision_class == "Boid"  and collider:getObject() ~= self then
          velocitySum = velocitySum + collider:getObject().velocity
          table.insert(nearbyBoids,collider:getObject())
        end
    end
    local aligmentSteer = self:aligment(velocitySum, #nearbyBoids)
    local separationSteer = self:separation(nearbyBoids)
    local cohestionSteer = self:cohesion(nearbyBoids)
    self.acceleration = self.acceleration + aligmentSteer
    self.acceleration = self.acceleration + separationSteer
    self.acceleration = self.acceleration + cohestionSteer
    
  end
end

 function Boid:aligment(sum, nearbyBoids)
  --average the velocity of nearby boids 
  sum = sum/nearbyBoids
  sum:normalizeInplace()
  sum = sum*self.speed
  --amount to steer = desired velocity - current velocity
  sum = sum-self.velocity
  sum:trimInplace(self.maxSpeed )
  return sum
   
  
end


function Boid:separation(nearbyBoids)
  local separateSteer= Vector.new(0,0)
  local howMannyCloseBoids = 0
  for i, boid in ipairs(nearbyBoids)do
    if self.position:dist(boid.position) < minSeparation then
      local avoidSingleBoid = Vector.new(0,0)
      avoidSingleBoid.x = self.x - boid.x  
      avoidSingleBoid.y = self.y - boid.y
      avoidSingleBoid:normalizeInplace()
      --divide by distance to other to lower the steer if its farther
      avoidSingleBoid = avoidSingleBoid / self.position:dist(boid.position)
      separateSteer = separateSteer + avoidSingleBoid
      howMannyCloseBoids = howMannyCloseBoids +1
    end
  end
  --average location to avoid close boids
  if howMannyCloseBoids > 0 then
    separateSteer = separateSteer/howMannyCloseBoids
    separateSteer:normalizeInplace()
    separateSteer = separateSteer*self.speed
    separateSteer = separateSteer - self.velocity
    separateSteer:trimInplace(self.maxSpeed )
   end
  return separateSteer
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
  local cohestionSteer = Vector.new(xAverage,yAverage)
  cohestionSteer = cohestionSteer - self.position
  cohestionSteer:normalizeInplace()
  cohestionSteer = cohestionSteer *self.speed
  cohestionSteer = cohestionSteer - self.velocity
  cohestionSteer:trimInplace(self.maxSpeed )
  return cohestionSteer
  
end

function clamp(min, val, max)
    return math.max(min, math.min(val, max));
end



return Boid