-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

--[[
	Box: 540x180
	Head: 140x204
	Still: 540x170
	Sign: 500*150
	Entire animation: 540x515
]]

local N = require("crazy_numbers")
local M = {}

local ANIMATION_WIDTH = 540

local loopTimer
local repeats = 0
local conveyors = {}
local bubble = require("bubble")
local game = require("game")

physics.start()
physics.setGravity(0,0)
physics.setDrawMode("normal")

local bg = display.newRect(display.contentWidth/2, display.contentHeight/2, display.contentWidth, display.contentHeight)
bg:setFillColor(1,1,1)

local bubbleDisplay
local frontDisplay
local backWallDisplay
local UIDisplay

local function tapListener(event)
	print("x: "..event.x.."; y: "..event.y)
end

bg:addEventListener( "tap", tapListener )

local sheetOptions_Box =
{
	width = 540,
	height = 180,
	numFrames = 24
}

local sheetOptions_Head =
{
	width = 140,
	height = 204,
	numFrames = 25
}

local sheetOptions_Crack =
{
	width = 114,
	height = 28,
	numFrames = 9
}

local sheet_Box = graphics.newImageSheet("Box_Slide.png", sheetOptions_Box)
local sheet_Head = graphics.newImageSheet("Head.png", sheetOptions_Head)
local sheet_Crack = graphics.newImageSheet("Crack.png", sheetOptions_Crack)


local sequences_Box = {
	{
		name = "normal",
		frames = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,1,1,1,1,1,1,
			1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
		time = 2000,
		loopCount = 0,
		loopDirection = "forward"
	}
}

local sequences_Head = {
	{
		name = "normal",
		frames = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
			1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,25,25,25,25,25},
		time = 2000,
		loopCount = 0,
		loopDirection = "forward"
	}
}

local sequences_Crack = {
	{
		name = "normal",
		frames = {1,2,3,4,5,6,7,8,9},
		time = 1, --Originally 1000
		loopCount = 1,
		loopDirection = "forward"
	}
}


local function newLine(scale)
	print("new line with scale: "..scale)
	local imageWidth = scale*ANIMATION_WIDTH
	local dispGroup = display.newGroup()
	for i = 0, math.ceil(display.contentWidth/imageWidth), 1 do

		local head = display.newSprite(dispGroup, sheet_Head, sequences_Head)
		head.x = i*imageWidth + (imageWidth/2)
		head.y = 2*display.contentHeight/3 - (scale*180)
		head.xScale = scale
		head.yScale = scale
		head:play()

		local box = display.newSprite(dispGroup, sheet_Box, sequences_Box)
		box.x = i*imageWidth + (imageWidth/2)
		box.y = 2*display.contentHeight/3
		box.xScale = scale
		box.yScale = scale
		box:play()

		local top = display.newImageRect(dispGroup, "Still.png", imageWidth, scale*170)
		top.x = i*imageWidth + (imageWidth/2)
		top.y = 2*display.contentHeight/3 - (scale*350)
	end
	dispGroup.relative_scale = scale
	return dispGroup
end

local function crackListener(event)
	if(event.phase == "ended") then
		bubbleDisplay = display.newGroup()
		timer.resume(loopTimer)
	end
end

local function crack_pipe(obj)
	local crack = display.newSprite(frontDisplay, sheet_Crack, sequences_Crack)
	crack.x = display.contentWidth/2
	crack.y = 7*display.contentHeight/8
	crack:addEventListener("sprite", crackListener)
	crack:play()
end

local function play_clicked(event)
	local button = event.target
	transition.cancel()
	transition.to( button, { time=500, alpha=0, xScale=2, yScale=2, transition=easing.outExpo, onComplete=crack_pipe} )	
end


local function buttonScaleLoop(obj)
	if(obj.xScale > 1) then
		transition.to( obj, { time=1500, xScale=1, yScale=1, onComplete=buttonScaleLoop, transition=easing.inSine} )
	else
		transition.to( obj, { time=1500, xScale=1.1, yScale=1.1, onComplete=buttonScaleLoop, transition=easing.outSine } )
	end
end

local function initStartScreen(init_scale, relative_scale, lines)

	backWallDisplay = display.newGroup()
	for i = lines-1, 0, -1 do
		table.insert(conveyors, newLine(init_scale*math.pow(relative_scale, i)))
	end
	frontDisplay = display.newGroup()
	UIDisplay = display.newGroup()

	local sign = display.newImageRect(backWallDisplay, "SnP_Sign.png", 500*init_scale, 150*init_scale)
	sign.x = display.contentWidth/2
	sign.y = 2*display.contentHeight/3 - (init_scale*515)

	--Takes up bottom 5th of screen
	local bottomPipe = display.newImageRect(frontDisplay, "Bottom_Pipe.png", (900/145)*(display.contentHeight/5), display.contentHeight/5)
	bottomPipe.x = display.contentWidth/2
	bottomPipe.y = 7*display.contentHeight/8

	local play = display.newImageRect(UIDisplay, "Play_Button.png", (291/145)*(display.contentHeight/5), display.contentHeight/5)
	play.x = display.contentWidth/2
	play.y = 7*display.contentHeight/8 - (display.contentHeight/(5*2))

	transition.to( play, { time=1000, xScale=1.1, yScale=1.1, onComplete=buttonScaleLoop } )

	play:addEventListener( "tap", play_clicked )
end


local bubbleNum = 0
local blastingOff = false


local function lets_go(obj)
	print("Game starting")
	game.start()
end

local function BLASTOFF()
	print("BLASTOFF")
	local TIME = 750 --Originally 750 --- Fast = 1
	local TIME2 = 1000 --Originally 1000 === Fast = 1

	local least
	transition.to(frontDisplay, {time=1000, y=display.contentHeight, transition=easing.linear})
	for i = 1, #conveyors, 1 do
		if(least == nil) then
			least = conveyors[i].relative_scale
		end
		if(conveyors[i].relative_scale < least) then
			least = conveyors[i].relative_scale
		end
		transition.to(conveyors[i], {time=TIME/conveyors[i].relative_scale, y=display.contentHeight, transition=easing.linear})
	end
	transition.to(backWallDisplay, {time=TIME2/least, y=display.contentHeight, transition=easing.linear, onComplete=lets_go})

end

function M.start()
	initStartScreen(display.contentHeight/(2*515),.7,4)
end

local function loop()
	if(repeats%3 == 0 and bubbleNum < N.INIT_CLUMP_SIZE) then
		bubble.newStartScreenBubble(bubbleDisplay)
		bubbleNum = bubbleNum + 1
	end

	if(bubbleNum == N.INIT_CLUMP_SIZE and (not blastingOff)) then
		timer.performWithDelay(1000, BLASTOFF)
		blastingOff = true
	end

	bubble.cleanUp()
	bubble.reconnectClump()
	bubble.updateMedians()
	bubble.applyForce()
	repeats = repeats + 1
end

loopTimer = timer.performWithDelay(N.LOOP_DELAY, loop, 0)
timer.pause(loopTimer)

return M


