--declaring specific screen objects such as physics and game objects
local UI = Object:extend()
function UI:new()
  observeRangeSlider = newSlider(100, BOID_SPACE_HEIGHT+60, 100,
    observeRange,minObserveRange,maxObserveRange,
    function(v) observeRange = math.floor(v) end,
     {width=20, orientation='horizontal', track='line', knob='circle'})
   
end

function UI:update(dt)
 
  observeRangeSlider:update()
end

function UI:draw()
  observeRangeSlider:draw()
  love.graphics.print( observeRange, 100, BOID_SPACE_HEIGHT+60, 0, 1, 1, 0, 0 )
end
 
return UI