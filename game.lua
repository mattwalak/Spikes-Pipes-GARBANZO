-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

--LOAD MODULES:
local bubble = require("bubble")
local N = require("crazy_numbers")
local object = require("object")
local background = require("background")
local gameLoopTimer

local M = {}

background.getReady()
--actuall speed (Changes as game progresses)
local speed

--Loop repeats
local repeats = -400

--Border Objects
local borderGroup
local leftBorder
local rightBorder
local bottomBorder
local topBorder


--Initialize physics
local physics = require("physics")
physics.start()
physics.setGravity(0,0)
physics.setDrawMode("normal")

--Border initialization
borderGroup = display.newGroup()
borderProperties = {density = 1.0, bounce = 0.2};
leftBorder = display.newRect(-100, display.contentHeight/2, 200, display.contentHeight)
rightBorder = display.newRect(display.contentWidth+100, display.contentHeight/2, 200, display.contentHeight)
topBorder = display.newRect(display.contentWidth/2, -100, display.contentWidth, 200)
bottomBorder = display.newRect(display.contentWidth/2, display.contentHeight+100, display.contentWidth, 200)

topBorder:setFillColor(1,1,1)

borderGroup:insert(leftBorder)
borderGroup:insert(rightBorder)
borderGroup:insert(topBorder)
borderGroup:insert(bottomBorder)


physics.addBody(leftBorder,"static", borderProperties)
physics.addBody(rightBorder,"static", borderProperties)
physics.addBody(topBorder,"static", borderProperties)
physics.addBody(bottomBorder,"static", borderProperties)


--Initialize background
local background1 = display.newRect(display.contentWidth/2,display.contentHeight/2,display.contentWidth, display.contentHeight)
background1:setFillColor(1,1,1,0) 


local bg = display.newRect(display.contentWidth/2,display.contentHeight/2,display.contentWidth, display.contentHeight)
bg:setFillColor(0,.9,1, .01)  ---Alpha was .2

--Checkerboard

--[[
for y = 0, display.contentHeight, N.COL_SIZE do
	for x = 0, display.contentWidth, N.COL_SIZE do
		local rect = display.newRect(x+(N.COL_SIZE/2), y+(N.COL_SIZE/2),N.COL_SIZE, N.COL_SIZE)
		if(((y+x)/N.COL_SIZE)%2 == 0) then
			rect:setFillColor(.9,.9,.9)
		else
			rect:setFillColor(1,1,1)
		end
	end
end]]


function M.reset()
	
end

local function playAgainClicked()
	--Reset everything
	bubble.reset()
	object.reset()
	background.reset()
	M.reset()
end

local function gameOver(event)
	timer.pause(gameLoopTimer)
	background.gameOver()
	local playAgain = display.newRect(100,100,100,100)
	playAgain.x = display.contentWidth/2
	playAgain.y= display.contentHeight/2
	playAgain:setFillColor(.5, .5, .5)
	playAgain:addEventListener("touch", playAgainClicked)
end

--local start = display.newRect(display.contentWidth/2,display.contentHeight/2,10*N.COL_SIZE,5*N.COL_SIZE)
--start:setFillColor(0,0,0,1)
--start:addEventListener("tap", startTap)




local objectTable = {}

--[[
	addBigSquare1
	addLineHell1
	addLineLattice1
	addLineLattice2
	addSquareLine1
]]

local function gameLoop()

	if(bubble.getCount() == 0) then
		print("GAME OVER :(")
		gameOver()
	end

	if(repeats == 0) then
		object.addVerticalSweep1()
	end

	bubble.cleanUp()

	object.updateTObjects()
	bubble.reconnectClump()
	bubble.updateMedians()
	bubble.applyForce()
	
	repeats = repeats + 1
end

local function onCollision(event)
	bubble.onCollision(event)
end

local function onTouch(event)
	bubble.onTouch(event)
end

bg:addEventListener("touch", onTouch)
Runtime:addEventListener("collision", onCollision)

gameLoopTimer = timer.performWithDelay(N.LOOP_DELAY, gameLoop, 0)
timer.pause(gameLoopTimer)

function M.start()
	timer.resume(gameLoopTimer)
	--background.start()
end

return M