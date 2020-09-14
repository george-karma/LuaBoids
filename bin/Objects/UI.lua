--declaring specific screen objects such as physics and game objects
local UI = Object:extend()
local elements = {}

function UI:new()
  
	table.insert(elements, addSlider(1,minObserveRange,maxObserveRange,"observeRange"))

end


function UI:update(dt)
  for i = #elements, 1,-1 do
    elements[i]:update()
  end
end

function UI:draw()
  for i = #elements, 1,-1 do
    elements[i]:draw()
  end
  love.graphics.print( observeRange, 100, BOID_SPACE_HEIGHT+60, 0, 1, 1, 0, 0 )
end
 
function addSlider(elementCount,min,max,variable)
  local x,y = 120 , BOID_SPACE_HEIGHT + 40 + 20*elementCount
  local slider = newSlider(x, y, 100,
    _G[variable],min,max,
    function(v) _G[variable] = math.floor(v) end,
    {width=20, orientation='horizontal', track='line', knob='circle'})
  return slider
end
return UI