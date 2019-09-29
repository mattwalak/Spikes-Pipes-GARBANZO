local M = {}

--[[
	BUBBLETABLE stores the actual bubbles that are displayed
	GROUPTABLE stores corresponding group numbers (Numbers [0,n), -1 is used to indicate the absence of a group)
	Example: bubbleTable[i] -> ith bubble's display variable
			 groupTable[i] -> ith bubble's group number


	GROUPSIZE stores the size of each group
	Example: groupSize[i] -> size of ith group (Could be 0 if no bubbles are in that group)

	MEDIAN stores the median of each group
]]
local bubbleTable = {}
local groupTable = {}
local groupSize = {}
local mediansx = {}
local mediansy = {}

local N = require("crazy_numbers")


--[[local physics = require("physics")
physics.start()
physics.setGravity(0,0)]]

--Wind data
local touch
local wind_x
local wind_y
local targetGroup

function M.getCount()
	return #bubbleTable
end

--Removes obj from table (if it exists)
function M.removeFromTable(obj, tableIn)
	for i = #tableIn, 1, -1 do
		if(tableIn[i] == obj) then
			table.remove(tableIn, i)
			return
		end
	end
end

--Returns true if 'table' M.contains the value 'val', false otherwise
function M.contains(table, val)
   for i=1,#table do
      if table[i] == val then 
         return true
      end
   end
   return false
end

function M.printTable(t)
	if(t == nil) then
		print("nil table")
		return
	end

	for i = 1, #t, 1 do
		if(t[i] == nil) then
			io.write("nill, ")
		else
			io.write(t[i]..", ")
		end
	end
	print("")
end

function M.findDuplicates(t)
    seen = {} --keep record of elements we've seen
    duplicated = {} --keep a record of duplicated elements
    for i = 1, #t do
        element = t[i]  
        if seen[element] then  --check if we've seen the element before
            duplicated[element] = true --if we have then it must be a duplicate! add to a table to keep track of this
        else
            seen[element] = true -- set the element to seen
        end
    end 
    return duplicated
end 

--For all i > 1, all bubbles in group # groupTable[i] are moved into group # groupTable[1]
function M.mergeGroups(close)
	--BASE CASE: nothing happens
	if(#close <= 1) then
		return
	end


	--For all i >= 1, move all bubbles from close[i] into the close[1] group
	for i = 1, #bubbleTable, 1 do
		if((not (groupTable[i] == close[1])) and (M.contains(close, groupTable[i]))) then
			groupTable[i] = close[1]
			groupSize[close[1]] = groupSize[close[1]] + 1
		end
	end

	--Reset groupSize for merged groups
	for i = 2, #close, 1 do
		groupSize[close[i]] = 0
	end
end

--Function to create a new bubble
function M.addBubble()
	local newBubble = display.newImageRect("Bubble.png", N.BUBBLE_DISPLAY_SIZE, N.BUBBLE_DISPLAY_SIZE)
	--local newBubble = display.newText{ x=100, y=200, text="0", fontSize=10 }
	newBubble.x = math.random(display.contentWidth)
	newBubble.y = math.random(display.contentHeight)
	physics.addBody(newBubble,"dynamic",{radius=N.BUBBLE_RADIUS})
	newBubble.linearDamping = N.LINEAR_DAMPING
	newBubble.type = "bubble"
	table.insert(bubbleTable, newBubble)
end

--Returns closes group to event, returns -1 if no bubbles
function M.closestGroup(event)
	if(#bubbleTable < 1) then
		return -1
	end

	local min = math.sqrt(math.pow((bubbleTable[1].x-event.x),2) + math.pow((bubbleTable[1].y-event.y),2))
	local groupMin = groupTable[1]

	for i = #bubbleTable, 1, -1 do
		local thisBubble = bubbleTable[i]
		local dist = math.sqrt(math.pow((thisBubble.x-event.x),2) + math.pow((thisBubble.y-event.y),2))
		--If bubble is within distance, not -1, and not a duplicate
		if((dist < min) and (not (groupTable[i] == -1)) ) then
			min = dist
			groupMin = groupTable[i]
		end
	end
	return groupMin
end

function M.onTouch(event)
	if(event.phase == "began") then
		touch = true
		wind_x = event.x
		wind_y = event.y
		targetGroup = M.closestGroup(event)
	elseif(event.phase == "ended") then
		touch = false
	elseif(event.phase == "moved") then
		wind_x = event.x
		wind_y = event.y
		targetGroup = M.closestGroup(event)
	elseif(event.phase == "cancelled") then
		touch = false
	end

end

--Initializes data arrays to default values
function M.initData(n)
	local newGroupTable = {}
	local newGroupSize = {}
	local newMediansx = {}
	local newMediansy = {}

	for i = 1, n, 1 do
		newGroupTable[i] = -1
		newGroupSize[i] = 0
		newMediansx[i] = 0
		newMediansy[i] = 0
	end

	groupTable = newGroupTable
	groupSize = newGroupSize
	medianx = newMediansx
	mediany = newMediansy
end

--Creates a new bubble clump with 100 random bubbles in individual clumps
function M.initBubbleClump()
	repeats = 0
	speed = N.INIT_SPEED
	for i = 1, N.INIT_CLUMP_SIZE, 1 do
		local newBubble = display.newImageRect("Bubble.png", N.BUBBLE_DISPLAY_SIZE, N.BUBBLE_DISPLAY_SIZE)
		--local newBubble = display.newText{ x=100, y=200, text="0", fontSize=18 }
		--newBubble:setFillColor( gray )
		newBubble.x = math.random((display.contentWidth/4))+display.contentWidth/2
		newBubble.y = math.random((display.contentHeight/4))+display.contentHeight/2
		physics.addBody(newBubble,"dynamic",{radius=N.BUBBLE_RADIUS})
		newBubble.linearDamping = N.LINEAR_DAMPING
		newBubble.type = "bubble"
		table.insert(bubbleTable,newBubble)

	end
	M.initData(N.INIT_CLUMP_SIZE)
end

--Creates an new bubble clump for start screen
function M.newStartScreenBubble(dispGroup)
	local newBubble = display.newImageRect(dispGroup,"Bubble.png", N.BUBBLE_DISPLAY_SIZE, N.BUBBLE_DISPLAY_SIZE)
	--local newBubble = display.newText{ x=100, y=200, text="0", fontSize=18 }
	--newBubble:setFillColor( gray )
	newBubble.x = display.contentWidth/2
	newBubble.y = 7*display.contentHeight/8
	physics.addBody(newBubble,"dynamic",{radius=N.BUBBLE_RADIUS})
	newBubble.linearDamping = N.LINEAR_DAMPING
	newBubble.type = "bubble"
	table.insert(bubbleTable,newBubble)
	table.insert(groupTable, -1)
	table.insert(groupSize, 0)
	table.insert(mediansx, 0)
	table.insert(mediansy, 0)
	newBubble:applyForce(0,-800*newBubble.mass,newBubble.x, newBubble.y)
end

--Returns a unique table of numbers representing the groups surrounding a given bubble
--Group numbers are the indicies of a bubbleClump in the bubbleClumpTable
function M.findCloseGroups(search)
	local out = {}

	--Test each bubble (Maybe find better algorithm)
	for i = #bubbleTable, 1, -1 do
		local thisBubble = bubbleTable[i]
		local dist = math.sqrt(math.pow((thisBubble.x-search.x),2) + math.pow((thisBubble.y-search.y),2))
		--If bubble is within distance, not -1, and not a duplicate
		if((dist <= N.MIN_CLUMP_DIST) and (not (groupTable[i] == -1)) and (not M.contains(out, groupTable[i]))) then
			table.insert(out, groupTable[i])
		end
	end
	return out
end
	
--Reassigns bubble to new clumps as appropriate
function M.reconnectClump()

	--TEMPORARY SOLUTION
	--Reset all bubbles so they are not in any clump
	M.initData(#bubbleTable)

	--Keeps track of which groups have already been populated (in the event a new group must be created)
	local groupCount = 1;

	for i = 1, #bubbleTable, 1 do
		local close = M.findCloseGroups(bubbleTable[i])

		--CASE 1: No groups within min distance, assign a new group number
		if(#close == 0) then
			--Change group number and update new group size
			groupTable[i] = groupCount
			groupSize[groupCount] = 1
			groupCount = groupCount + 1
		end

		--CASE 2: One or more groups exist. Join the first group and merge the rest
		if(#close >= 1) then
			--Change group number, update group size, and merge
			groupTable[i] = close[1]
			groupSize[close[1]] = groupSize[close[1]] + 1
			M.mergeGroups(close)
		end

	end
end

function M.updateMedians()
	local magx = {}
	local magy = {}

	for i = 1, #bubbleTable, 1 do
		table.insert(magx, 0)
		table.insert(magy, 0)
	end

	for i = 1, #bubbleTable, 1 do
		magx[groupTable[i]] = magx[groupTable[i]] + bubbleTable[i].x
		magy[groupTable[i]] = magy[groupTable[i]] + bubbleTable[i].y
	end

	for i = 1, #bubbleTable, 1 do
		if(not (groupSize[i] == 0)) then
			mediansx[i] = (magx[i] / groupSize[i])
			mediansy[i] = (magy[i] / groupSize[i])
		else
			mediansx[i] = 0
			mediansy[i] = 0
		end
	end

end

--Applys a foce on every bubble towards the median of the bubble clump
function M.applyForce()
	for i = 1, #bubbleTable, 1 do
		local thisBubble = bubbleTable[i]

		--Apply bubble-to-bubble force
		thisBubble:applyForce(-(thisBubble.x - mediansx[groupTable[i]])*N.CLUMP_FORCE_FACTOR*thisBubble.mass,
			-(thisBubble.y - mediansy[groupTable[i]])*N.CLUMP_FORCE_FACTOR*thisBubble.mass,
			thisBubble.x, thisBubble.y)

		--Apply wind force
		if(touch and (groupTable[i] == targetGroup)) then
			local distance = math.sqrt(math.pow((thisBubble.x-wind_x),2)
				+math.pow((thisBubble.y-wind_y),2))

			local direction = math.atan((mediansy[groupTable[i]]-wind_y)/(mediansx[groupTable[i]]-wind_x))
	 		local impulse_x = N.BLOW_FACTOR*math.cos(direction)*(N.BLOW_NUM/distance)*thisBubble.mass
	 		local impulse_y = N.BLOW_FACTOR*math.sin(direction)*(N.BLOW_NUM/distance)*thisBubble.mass
	 		if((mediansx[groupTable[i]]-wind_x)<0) then
	 			impulse_x = -impulse_x
	 			impulse_y = -impulse_y
	 		end
	 		if((mediansy[groupTable[i]]-wind_y)<0) then
	 			--impulse_y = -impulse_y
	 		end
 			thisBubble:applyForce(impulse_x,impulse_y,
 				thisBubble.x, thisBubble.y)
	 	end

	 	--Apply random variation force
	 	local magnitude = (N.RANDOM_WIND_FACTOR/groupSize[groupTable[i]])*thisBubble.mass
	 	thisBubble:applyForce(2*math.random()*magnitude-magnitude,2*math.random()*magnitude-magnitude,
	 		thisBubble.x, thisBubble.y)
	 	
	 	--Applies wall restoring force
	 	if(thisBubble.x <= N.EDGE_DIST) then
	 		thisBubble:applyForce(N.EDGE_FORCE_FACTOR*N.EDGE_DIST*N.CLUMP_FORCE_FACTOR*thisBubble.mass, 0, thisBubble.x, thisBubble.y)
	 	elseif((display.contentWidth-thisBubble.x) <= N.EDGE_DIST) then
	 		thisBubble:applyForce(-N.EDGE_FORCE_FACTOR*N.EDGE_DIST*N.CLUMP_FORCE_FACTOR*thisBubble.mass, 0, thisBubble.x, thisBubble.y)
	 	elseif(thisBubble.y <= N.EDGE_DIST) then
	 		thisBubble:applyForce(0, N.EDGE_FORCE_FACTOR*N.EDGE_DIST*N.CLUMP_FORCE_FACTOR*thisBubble.mass, thisBubble.x, thisBubble.y)
	 	elseif((display.contentHeight-thisBubble.y) <= N.EDGE_DIST) then
	 		thisBubble:applyForce(0, -N.EDGE_FORCE_FACTOR*N.EDGE_DIST*N.CLUMP_FORCE_FACTOR*thisBubble.mass, thisBubble.x, thisBubble.y)
	 	end
	end

end

function M.cleanUp()
	for i = #bubbleTable, 1, -1 do
		local thisBubble = bubbleTable[i]
		if(thisBubble == nil) then
			print("nil bubble")
            table.remove( bubbleTable, i )
        elseif ( thisBubble.x < -200 or
             thisBubble.x > display.contentWidth + 200 or
             thisBubble.y < -200 or
             thisBubble.y > display.contentHeight + 200 )
        then
            display.remove( thisBubble )
            table.remove( bubbleTable, i )
        end


	end
end

function M.onCollision(event)

	if(event.phase == "began") then
		local obj1 = event.object1
		local obj2 = event.object2
		
		--SPIKE COLLISION
		if(obj1.type == "bubble" and obj2.type == "spike") then
			if(event.element2 == 2) then
				return
			end

			M.removeFromTable(obj1, bubbleTable)
			display.remove(obj1)
			obj1 = nil
		elseif(obj1.type == "spike" and obj2.type == "bubble") then
			if(event.element1 == 2) then
				return
			end

			M.removeFromTable(obj2, bubbleTable)
			display.remove(obj2)
			obj2 = nil
		end

		--COIN COLLISION
		if(obj1.type == "bubble" and obj2.type == "coin") then
			obj2:removeSelf()
		elseif(obj1.type == "coin" and obj2.type == "bubble") then
			obj2:removeSelf()
		end

		--PLUS COLLISION
		if(obj1.type == "bubble" and obj2.type == "plus") then
			obj2:removeSelf()
		elseif(obj1.type == "coin" and obj2.type == "plus") then
			obj2:removeSelf()
		end


	end
end

function M.reset()
	
end

return M
