--enable print to console
io.stdout:setvbuf("no")	
Object = require "classic"
Timer= require "timer"
Input= require "input"
Physics = require 'windfield'
globals = require "globals"
Vector = require 'vector'
profiler = require("profiler")
require 'simple-slider'

function love.load()
readObjects("Objects")
timer = Timer()
input = Input()
screenController = ScreenControler()

end

function love.update(dt)
  timer:update(dt)
  screenController:update(dt)

end

function love.draw()
  screenController:draw()
end

--reads and requires all objcts inside the folder
function readObjects (folder)
	local files = love.filesystem.getDirectoryItems(folder)
	for i, file in ipairs(files) do
		local filePath = folder .."/".. file
		if  love.filesystem.getInfo(filePath, "file") then
      local path,fileName,extension = string.match(filePath,"(.-)([^\\/]-%.?([^%.\\/]*))$")
      local filePath = filePath:sub(1,-5)	
      fileName = fileName:sub(1,-5)	
      _G[fileName] = require(filePath)	
      print("got object "..fileName.." from "..filePath)
    elseif love.filesystem.getInfo(filePath,"directory") then
				readObjects(filePath)	
		end
	end
end