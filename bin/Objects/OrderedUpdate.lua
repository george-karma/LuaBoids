--interface for updating objects on screen  and drawing them in order
local OrderedUpdate = Object:extend()

function OrderedUpdate:new(screenControler)
  self.screenControler = screenControler
  self.physicsWorld = Physics.newWorld(0,0,true)
  self.physicsWorld:setQueryDebugDrawing(seeObserverRange)
  self.physicsWorld:addCollisionClass("Boid")
  self.physicsWorld:addCollisionClass("Boundary")
  --[[wall = self.physicsWorld:newChainCollider({0,0,960,0,960,720,0,720}, true)
  wall:setType('static')
  wall:setCollisionClass("Boundary")]]--
  
  
  self.screenObjects = {}
end

function OrderedUpdate:update(dt)
  if self.physicsWorld then self.physicsWorld:update(dt) end
  for i = #self.screenObjects, 1,-1 do
    local screenObject = self.screenObjects[i]
    if screenObject.dead then 
      table.remove(self.screenObjects,i) --if the object is dead remove it from que
    end
    screenObject:update(dt)
  end
end

function OrderedUpdate:draw()
  self.physicsWorld:draw()
  --draw objects in order
  table.sort(self.screenObjects, function(a,b)
			if a.order and b.order then
				return a.order<b.order
			end
		end)

	for i, screenObject in ipairs(self.screenObjects) do
		screenObject:draw()
	end
  
end

function OrderedUpdate:addScreenObject(type,x,y,opts)
	local opts = opts or {}
	local screenObject = _G[type](self,x or 0, y or 0, opts)
	table.insert(self.screenObjects, screenObject)
	return screenObject
end

return OrderedUpdate