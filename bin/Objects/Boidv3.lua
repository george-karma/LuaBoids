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
	self.speed = opts.velocity
	self.maxSpeed = 50
  
	self.acceleration = Vector.new(0,0)
  self.velocity = Vector.new(math.cos(self.rotation),math.sin(self.rotation))
  self.canObserve = true 
  
  
  input:bind("mouse1","spawnBoid")
  
end

function Boid:update(dt)
  clamp(0,self.speed, self.maxSpeed)
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
    self.velocity = self.velocity + self.acceleration
    self.rotation = math.atan2(self.velocity.y,self.velocity.x)
    self.collider:setLinearVelocity(self.velocity.x,self.velocity.y)
    self.x,self.y = self.collider:getPosition() 
    self.acceleration = self.acceleration *0
	end
end

function Boid:draw()
 love.graphics.line(self.x+1*self.w*math.cos(self.rotation),
							self.y+1*self.w*math.sin(self.rotation),
							self.x+1.3*self.w*math.cos(self.rotation),
							self.y+1.3*self.w*math.sin(self.rotation))
  
end



function Boid:observe(dt)
  local colliders = orderedUpdate.physicsWorld:queryCircleArea(self.x,self.y,observeRange)
  local nearbyBoids = {}
  --if there are other colliders around
  if #colliders>1 then
    for i,collider in ipairs(colliders) do
        if collider.collision_class == "Boid"  and collider:getObject() ~= self then
          table.insert(nearbyBoids,collider:getObject())
        end
    end
    local aligmentSteer = self:aligment(nearbyBoids)
    local separationSteer = self:separation(nearbyBoids)
    self.acceleration = self.acceleration + aligmentSteer 
    self.acceleration = self.acceleration + separationSteer
  end
end




function Boid:aligment(nearbyBoids)
  local sum = Vector.new(0,0)
  for i,boid in ipairs(nearbyBoids) do
    sum = sum + boid.velocity
  end
  --average the velocity of nearby boids 
  sum = sum/#nearbyBoids
  sum:normalizeInplace()
  sum = sum*self.speed
  --amount to steer = desired velocity - current velocity
  sum = sum-self.velocity
  sum:trimInplace(self.maxSpeed )
  return sum
   
  
end


function Boid:separation(nearbyBoids)
  local closestBoid = nearbyBoids[1]
  local separateSteer= Vector.new(0,0)
  for i, boid in ipairs(nearbyBoids)do
    if self.velocity:dist(boid.velocity) < self.velocity:dist(closestBoid.velocity) then
      closestBoid = boid
    end
  end
  if self.velocity:dist(closestBoid.velocity) < minSeparation then
    
    separateSteer.x = self.x - closestBoid.x
    separateSteer.y = self.y - closestBoid.y
    --divide by distance to other to lower the steer if its farther
    separateSteer = separateSteer * self.velocity:dist(closestBoid.velocity)
    separateSteer:normalizeInplace()
    separateSteer = separateSteer*self.speed
    separateSteer = separateSteer - self.velocity
    separateSteer:trimInplace(self.maxSpeed )
  end
  return separateSteer
end

function clamp(min, val, max)
    return math.max(min, math.min(val, max));
end



return Boid