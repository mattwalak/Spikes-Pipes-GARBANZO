--A pipe is a tObject



--[[pipe options:
	startCol: Index of starting column
	endCol: Index of ending column
	endHeight: Height at end
	colSwitch: List of lists with the following format
		{height, new, turn_left, start_3_branch, end_3_branch} 
		<- Height at which switch occured, new column, does the pipe turn left (turn right if false), does the pipe end with a 3 branch

	branch_4: list of all heights where 4branches occur
		EX: {4, 10, 20}

	branch_3: list of pairs with the following format
		{height, left} <- height where it occurs, if the branch is a left branch

]]--


--[[
	pipe:
	{maxCol, refreshSize, nextRefreshCol, color, pixelsLeft,
		scale, relative_speed}
]]

--addToPipe(pipeOptions, color, scale, relative_speed, offset)

--newPipe(maxCol, refreshSize, nextRefreshCol, color, scale, relative_speed)



--MOVE THIS TO VARIABLES FILE LATER
local BG_BASE_SPEED = 1 --Pixels per loop
local REFRESH_DIST = 5


local M = {}
local N = require("crazy_numbers")
local V = require("visuals")
local tObjects = {}

local pipePieces = {}
local pipes = {}

local bg = display.newRect(display.contentWidth/2, display.contentHeight/2, display.contentWidth, display.contentHeight)
bg:setFillColor(.8)




--Where 1,1 is the bottom left
local function newPipePiece(col, row, piece, color_table, scale, relative_speed, offset)
	local blurSize = 15 * (1/scale)
	local sigma = 25 * (1/scale)
	if(offset == nil)then
		offset = 0
	end
	local pipe = display.newImageRect("pipes/"..piece..".png", N.COL_SIZE*scale, N.COL_SIZE*scale)
	pipe:setFillColor(color_table[1], color_table[2], color_table[3])

	--Pieces start immediately above the top of the screen
	pipe.x = ((col-1)*N.COL_SIZE*scale)+(N.COL_SIZE/2)
	pipe.y = -((row-1)*N.COL_SIZE*scale)-(N.COL_SIZE/2) + offset
	pipe.relative_speed = relative_speed
	pipe.type = piece
	pipe.scale = scale
	--pipe.fill.effect = "filter.blurGaussian"
	--pipe.fill.effect.horizontal.blurSize = blurSize
	--pipe.fill.effect.horizontal.sigma = sigma
	--pipe.fill.effect.vertical.blurSize = blurSize
	--pipe.fill.effect.vertical.sigma = sigma



	local light = display.newImageRect("pipes/O_"..piece..".png", N.COL_SIZE*scale, N.COL_SIZE*scale)
	light.x = pipe.x
	light.y = pipe.y
	light.relative_speed = pipe.relative_speed
	light.type = pipe.type
	light.scale = pipe.scale
	--light.fill.effect = "filter.blurGaussian"
	--light.fill.effect.horizontal.blurSize = blurSize
	--light.fill.effect.horizontal.sigma = sigma
	--light.fill.effect.vertical.blurSize = blurSize
	--light.fill.effect.vertical.sigma = sigma



	table.insert(pipePieces, pipe)
	table.insert(pipePieces, light)
end

--Returns special options occuring at a given height, nil if no special options
local function getSpecial(pipeOptions, i)
	if(pipeOptions.colSwitch ~= nil) then
		for j = 1, #pipeOptions.colSwitch, 1 do
			if(pipeOptions.colSwitch[j][1] == i) then
				return pipeOptions.colSwitch[j], "colSwitch"
			end
		end
	end

	if(pipeOptions.branch_4 ~= nil) then
		for j = 1, #pipeOptions.branch_4, 1 do
			if(pipeOptions.branch_4[j] == i) then
				return pipeOptions.branch_4[j], "branch_4"
			end
		end
	end

	if(pipeOptions.branch_3 ~= nil) then
		for j = 1, #pipeOptions.branch_3, 1 do
			if(pipeOptions.branch_3[j][1] == i) then
				return pipeOptions.branch_3[j], "branch_3"
			end
		end
	end

	return nil
end

local function insertList(original, add)
	for i = 1, #add, 1 do
		table.insert(original, add[i])
	end
end

--Assumes pipeOptions is valid
local function addToPipe(pipeOptions, color, scale, relative_speed, offset)
	local objects = {}
	local currentCol = pipeOptions.startCol	

	for i = 1, pipeOptions.endHeight, 1 do
		local action --Name of special action to complete
		local special --Data for special action
		special, action = getSpecial(pipeOptions,i)
		if(special == nil) then
			newPipePiece(currentCol, i, "Up", color, scale, relative_speed, offset)
		elseif(action == "colSwitch") then
			local dx
			local startPipe
			local endPipe
			if(special[3])then
				dx = -1 --To the Left!
				startPipe = "TD"
				endPipe = "TB"
			else
				dx = 1 --To the Right!
				startPipe = "TA"
				endPipe = "TC"
			end

			local startEmpty = true
			local endEmpty = true
			if(special[4]) then --Start is 3 branch
				for l = currentCol-dx, 1, -dx do
					newPipePiece(l, i, "Side", color, scale, relative_speed, offset)						
				end
				newPipePiece(currentCol, i, "3D", color, scale, relative_speed, offset)
				startEmpty = false
			end
			if(special[5]) then--End is 3 branch
				for l = special[2] + dx, 16, dx do
					newPipePiece(l, i, "Side", color, scale, relative_speed, offset)
				end
				newPipePiece(special[2], i, "3B", color, scale, relative_speed, offset)
				endEmpty = false
			end

			if(startEmpty) then --Start is turn
				newPipePiece(currentCol, i, startPipe, color, scale, relative_speed, offset)
			end
			if(endEmpty) then --End is turn
				newPipePiece(special[2], i, endPipe, color, scale, relative_speed, offset)
			end

			--Build over to newCol
			local oldCol = currentCol
			currentCol = currentCol + dx
			while(currentCol ~= special[2]) do
				newPipePiece(currentCol, i, "Side", color, scale, relative_speed, offset)
				currentCol = currentCol + dx
				if(currentCol > 16) then --Loop back around
					currentCol = 1
				elseif(currentCol < 1)then
					currentCol = 16
				end										
			end 
			currentCol = special[2]				
		elseif(action == "branch_4") then
			--Build left branch
			for l = currentCol-1, 1, -1 do
				newPipePiece(l, i, "Side", color, scale, relative_speed, offset)
			end

			--Build right branch
			for l = currentCol + 1, 16, 1 do
				newPipePiece(l, i, "Side", color, scale, relative_speed, offset)	
			end

			newPipePiece(currentCol, i, "4", color, scale, relative_speed, offset)

		elseif(action == "branch_3") then
			if(special[2]) then --Left Branch
				for l = currentCol - 1, 1, -1 do
					newPipePiece(l, i, "Side", color, scale, relative_speed, offset)	
				end
				newPipePiece(currentCol, i, "3C", color, scale, relative_speed, offset)
			else --Right Branch
				for l = currentCol + 1, 16, 1 do
					newPipePiece(l, i, "Side", color, scale, relative_speed, offset)	
				end
				newPipePiece(currentCol, i, "3A", color, scale, relative_speed, offset)
			end
		end

	end
end

local pipeOptions = {
	startCol = 5,
	endCol = 8,
	endHeight = 30,
	colSwitch = {{6, 3, false, false, false}},
	branch_4 = {10},
	branch_3 = {{12, false}}
}

local pipeOptions2 = {
	startCol = 3,
	endCol = 10,
	endHeight = 30,
	colSwitch = {{2, 10, true, false, false}, {20, 16, false, false, false}},
	branch_4 = {22, 5},
	branch_3 = nil
}

local pipeOptions3 = {
	startCol = 10,
	endCol = 1,
	endHeight = 30,
	colSwitch = {{10, 1, true, false, false}, {1, 10, false, false, false}},
	branch_4 = {19, 27},
	branch_3 = nil
}

local function generatePipeOptions(maxCol, height, currentCol)

	local startCol = currentCol
	local colSwitch = {}
	local branch_4 = {}
	local branch_3 = {}

	for i = 1, height, 1 do
		local rand = math.random()


		if((0 < rand) and (rand <= .02)) then
			--Generate pipe turn
			local newColumn = math.random(1, maxCol)
			local left
			local startBranch = false
			local endBranch = false

			if(math.random() <= .5) then
				left = true
			else
				left = false
			end

			if(((newColumn - currentCol) >= 0) and left) then
				startBranch = false
				endBranch = false
			elseif(((newColumn - currentCol) <= 0) and (not left)) then
				startBranch = false
				endBranch = false
			else
				if(math.random() <= .2) then
					startBranch = true
				end
				if(math.random() <= .2) then
					endBranch = true
				end
			end

			table.insert(colSwitch, {i, newColumn, left, startBranch, endBranch})
			currentCol = newColumn
		elseif((.02 < rand) and (rand <= .04)) then
			--4 Way branch
			table.insert(branch_4, i)
		elseif((.04 < rand) and (rand <= .06)) then
			--3 Way branch
			local left
			if(math.random() <= .5) then
				left = true
			else
				left = false
			end
			table.insert(branch_3,{i, left})
		end
	end

	return {startCol=startCol, endCol=currentCol, endHeight=height, 
		colSwitch=colSwitch, branch_4=branch_4, branch_3=branch_3}
end

local function updatePipes()
	for i = #pipes, 1, -1 do
		pipes[i].pixelsLeft = pipes[i].pixelsLeft - BG_BASE_SPEED*pipes[i].relative_speed
		if(pipes[i].pixelsLeft < REFRESH_DIST*N.COL_SIZE) then
			local options = generatePipeOptions(pipes[i].maxCol, 
				pipes[i].refreshSize, pipes[i].nextRefreshCol)
			addToPipe(options, pipes[i].color, pipes[i].scale, 
				pipes[i].relative_speed, -pipes[i].pixelsLeft)
			pipes[i].nextRefreshCol = options.endCol
			pipes[i].pixelsLeft = pipes[i].pixelsLeft + pipes[i].refreshSize*N.COL_SIZE*pipes[i].scale
		end

	end


	for i = #pipePieces, 1, -1 do
		thisPipe = pipePieces[i]
		thisPipe.y = thisPipe.y + BG_BASE_SPEED*thisPipe.relative_speed
		if(thisPipe.y > (display.contentHeight+(N.COL_SIZE*thisPipe.scale))) then
			table.remove(pipePieces,i)
			thisPipe:removeSelf()
		end
	end
end

local function gameLoop()
	updatePipes()
end

local function offsetObject(object, dy)
	if(object == nil) then
		return 
	end

	if(object.r_y ~= nil) then
		object.r_y = object.r_y + dy
	end
	if(object.objects ~= nil) then
		for j = 1, #thisObject.objects, 1 do
			offsetObject(thisObject.objects[i], dy)
		end
	end
end

local function offsetAll(dy)
	for i = #pipePieces, 1, -1 do
		pipePieces[i].y = pipePieces[i].y + dy
	end

	for i = #pipes, 1, -1 do
		pipes[i].pixelsLeft = pipes[i].pixelsLeft - dy
	end
end

local function newPipe(maxCol, refreshSize, nextRefreshCol, color, scale, relative_speed)
	local this = {}
	this.maxCol = maxCol
	this.refreshSize = refreshSize
	this.nextRefreshCol = nextRefreshCol
	this.color = color
	this.pixelsLeft = 0
	this.scale = scale
	this.relative_speed = relative_speed
	return this
end


function M.getReady()
	table.insert(pipes, newPipe(16, 2, -1, V.red, 2, 2))
	table.insert(pipes, newPipe(16, 2, -1, V.yellow, 1.5, 1.5))
	table.insert(pipes, newPipe(16, 2, -1, V.green, 1, 1))
	table.insert(pipes, newPipe(16, 2, -1, V.blue, 1, 1))


	gameLoop()
	--offsetAll(display.contentHeight)
end

M.getReady()

local gameLoopTimer
gameLoopTimer = timer.performWithDelay(10, gameLoop, 0)
timer.pause(gameLoopTimer)

function M.start()
	timer.resume(gameLoopTimer)
end

function M.gameOver()
	timer.pause(gameLoopTimer)
end

function M.reset()

end

return M
