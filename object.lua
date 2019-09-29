local M = {}

local N = require("crazy_numbers")
local V = require("visuals")
local tObjects = {}
local speed = N.INIT_SPEED
--[[
	TRAVELING OBJECT CLASS: (tObject)
	start_x: where the object started
	start_y: calculated when object is created
	end_y: calculated when object is created
	start_time: when the object started its animation
	objects: {
		List of all display objects
	}

	OBJECT CLASS: (Object) extends display object
	r_x: relative position to this objects center (considered 0,0)
	r_y: relative potition to this objects center (considered 0,0)
	r_rot: relative rotation to objects parent
	r_scale: relative scale to objects parent
	type: type of objects ("spike","powerup","dot")

	GROUP OBJECT CLASS (gObject) extends Object
	objects: {
		List of all child objects
	}

	NSquare: extension of Object
	line: extension of Object
]]



--Adds fields to a display object to make it an Object
function M.newObject(original, r_x, r_y, r_rot, r_scale, typeIn, objects)
	original.r_x = r_x
	original.r_y = r_y
	original.r_rot = r_rot
	original.r_scale = r_scale
	original.type = typeIn
	original.objects = objects

	return original
end

local function scaleTable(t,c)
	local out = {}
	for i = 1, #t, 1 do
		if(i%2 == 0) then
			table.insert(out, (t[i]*c)/N.SPIKE_IMAGE_WIDTH)
		else
			table.insert(out, (t[i]*c*3)/N.SPIKE_IMAGE_HEIGHT)
		end
	end
	return out
end


--Returns a new spike Object at 0,0
function M.newSpike(x, y, rot)
	local spike = display.newImageRect("Spike.png", N.SPIKE_DISPLAY_SIZE, N.SPIKE_DISPLAY_SIZE*3)
	physics.addBody(spike,"static",
		{shape=scaleTable(V.spike_topSpike,N.SPIKE_DISPLAY_SIZE)},
		{shape=scaleTable(V.spike_box,N.SPIKE_DISPLAY_SIZE)},
		{shape=scaleTable(V.spike_bottomSpike,N.SPIKE_DISPLAY_SIZE)}
		)

	if(x == nil) then
		spike.r_x = 0
	else
		spike.r_x = x
	end

	if(y == nil) then
		spike.r_y = 0
	else
		spike.r_y = y
	end

	if(rot == nil) then
		spike.r_rot = 0
	else
		spike.r_rot = rot
	end

	spike.r_scale = 1
	spike.type = "spike"
	spike.objects = {}
	return spike
end

--Creates a Line object
function M.newLine(startx, starty, endx, endy, spike_speed, spike_num, left_to_right, ping_pong, objects)
	local original = display.newRect(0,0,N.COL_SIZE, N.COL_SIZE)
	original:setFillColor(0,0,0,0)
	original.r_x = 0
	original.r_y = 0
	original.r_scale = 1
	original.type = "Line"
	original.objects = {}

	--Special Line attributes
	original.spike_speed = spike_speed
	original.spike_num = spike_num
	original.direction = left_to_right
	original.ping_pong = ping_pong

	original.start_x = startx*N.COL_SIZE
	original.start_y = starty*N.COL_SIZE
	original.end_x = endx*N.COL_SIZE
	original.end_y = endy*N.COL_SIZE

	if(objects == nil) then
		--Insert spikes (Default)
		for i = 1, spike_num, 1 do
			table.insert(original.objects, M.newSpike())
		end
	else
		original.objects = objects
	end

	--[[Insert dashed line
	local dashed = display.newLine(original.start_x, original.start_y, 
		original.end_x, original.end_y)
	dashed:setStrokeColor(0,0,0,.5)
	--dashed:setStrokeWidth(2)
	table.insert(original.objects, dashed)]]--

	return original
end

--Creates an NSquare object 
function M.newNSquare(spike_speed, square_size, spike_num, objects)
	local original = display.newRect(0,0,square_size*N.COL_SIZE, square_size*N.COL_SIZE)
	original:setFillColor(0,0,0,0)
	original.r_x = 0
	original.r_y = 0
	original.r_rot = 0
	original.r_scale = 1
	original.type = "NSquare"
	original.objects = {}

	--Special NSquare attributes
	original.spike_speed = spike_speed
	original.size = square_size
	original.spike_num = spike_num

	if(objects == nil) then
		--Insert spikes (Default)
		for i = 1, spike_num, 1 do
			table.insert(original.objects, M.newSpike())
		end
	else
		original.objects = objects
	end
	return original
end

function M.destroyObject(thisObject, i)

	if(thisObject.objects ~= nil) then
		for j = #thisObject.objects, 1, -1 do
			local this = thisObject.objects[j]
			table.remove(thisObject.objects, j)
			M.destroyObject(this)
		end
	end
	display.remove(thisObject)
	thisObject = nil
end

function M.destroyTObject(thisObject, i)
	if(thisObject.objects ~= nil) then
		for j = #thisObject.objects, 1, -1 do
			local this = thisObject.objects[j]
			table.remove(thisObject.objects, j)
			M.destroyObject(this)
		end
	end
	table.remove(tObjects, i)
	thisObject = nil
end

function M.updateLine(line, completion)

	local x_dist = line.end_x - line.start_x
	local y_dist = line.end_y - line.start_y
	local percent = completion
	local max_completion = 1/line.ping_pong

	-- Initialize percent according to propper "ping-pong" direction
	percent = percent%(max_completion*2)
	if(percent > max_completion) then
		percent = (2*max_completion)-percent
	end
	percent = ((percent*1)*line.spike_speed)%100

	for i = 1, #line.objects, 1 do
		local thisObject = line.objects[i]

		if(line.direction) then
			if(x_dist ~= 0)then
				thisObject.r_x = line.start_x 
					+ ((percent*x_dist) + (i-1)*(x_dist/line.spike_num))%x_dist
			else
				thisObject.r_x = line.start_x
			end

			if(y_dist ~= 0)then
				thisObject.r_y = line.start_y 
					+ ((percent*y_dist) + (i-1)*(y_dist/line.spike_num))%y_dist
			else
				thisObject.r_y = line.start_y
			end
		else
			if(x_dist ~= 0)then
				thisObject.r_x = line.end_x 
					- ((percent*x_dist) - (i-1)*(x_dist/line.spike_num))%x_dist
			else
				thisObject.r_x = line.end_x
			end

			if(y_dist ~= 0)then
				thisObject.r_y = line.end_y 
					- ((percent*y_dist) - (i-1)*(y_dist/line.spike_num))%y_dist
			else
				thisObject.r_y = line.end_y
			end
		end
	end
end

--Updates nSquare based on completion percent (And nothing else)
function M.updateNSquare(square, completion)
	local percent = completion*100
	percent = (percent*square.spike_speed)%100
	local n = square.contentWidth
	local length = n*(5/8)
	--NOTE: loop starts at 1, goes up
	for i = 1, #square.objects, 1 do
		local updatedPercent = (percent+((100/square.spike_num)*(i-1)))%100
		local edgePercent = ((updatedPercent*4))%100
		local progress = length*(edgePercent/100)

		if(updatedPercent < 25)then
			square.objects[i].r_y = n*(3/16) + progress -(n/2)
			square.objects[i].r_x = n*(3/16) -(n/2)
		elseif(updatedPercent < 50)then
			square.objects[i].r_x = n*(3/16) + progress -(n/2)
			square.objects[i].r_y = n*(13/16) -(n/2)
		elseif(updatedPercent < 75)then
			square.objects[i].r_y = n*(13/16) - progress -(n/2)
			square.objects[i].r_x = n*(13/16) -(n/2)
		else
			square.objects[i].r_x = n*(13/16) - progress -(n/2)
			square.objects[i].r_y = n*(3/16) -(n/2)
		end
	end
end

function M.Object_update(thisObject, completion, off_x, off_y, off_rot, off_scl)
	local rot_r_x = off_x*math.cos(math.rad(off_rot)) - off_y*math.sin(math.rad(off_rot))
	local rot_r_y = off_x*math.sin(math.rad(off_rot)) + off_y*math.cos(math.rad(off_rot))
	rot_r_x = rot_r_x*off_scl
	rot_r_y = rot_r_y*off_scl

	thisObject.x = thisObject.r_x + off_x
	thisObject.y = thisObject.r_y + off_y
	thisObject.rotation = off_rot

	--Update .objects
	if(thisObject.type == "NSquare") then
		M.updateNSquare(thisObject, completion)
	elseif(thisObject.type == "Line") then
		M.updateLine(thisObject, completion)
	end


	if(thisObject.objects ~= nil)then
		for i = #thisObject.objects, 1, -1 do
			local nextObj = thisObject.objects[i]
			M.Object_update(thisObject.objects[i], completion,
				thisObject.x, thisObject.y, thisObject.rotation,
				off_scl
				)
		end
	end
end

--Returns this objects MinY, MaxY (At given config)
function M.getMinMaxY(Object)

end

function M.tObject_update(thisObject, i)
	--local fullHeight = display.contentHeight+thisObject.height
	local fullHeight = display.contentHeight + thisObject.end_y - thisObject.start_y
	local totalTime = fullHeight/speed
	local completion = (system.getTimer()-thisObject.start_time)/(totalTime*1000)

	if(completion > 1) then
		print("Object destroyed")
		M.destroyTObject(thisObject, i)
	end


	local new_y = thisObject.start_y+(completion*fullHeight)
	local new_x = thisObject.start_x

	if(thisObject.objects ~= nil) then
		for j = #thisObject.objects, 1, -1 do
			M.Object_update(thisObject.objects[j], completion, new_x, new_y, 0, 1)
		end
	end

end

function M.updateTObjects()
	for i = #tObjects, 1, -1 do
		M.tObject_update(tObjects[i], i)
	end
end

--Returns StartY, EndY
function M.getStartEndY(thisObject, off_y)
	--Update all objects at completion 0
	local minY
	local maxY
	if(thisObject.contentHeight ~= nil) then
		--We are working with an Object
		print("OBJECT, off_y: "..off_y)
		print("object height: "..thisObject.contentHeight)
		minY = 0 + off_y - (thisObject.contentHeight/2)
		maxY = 0 + off_y + (thisObject.contentHeight/2)
	else
		--We are working with the initial tObject
		print("T-OBJECT, off_y: "..off_y)
	 	minY = 0
		maxY = 0
	end

	local absoluteMin = minY
	local absoluteMax = maxY

	print("Entering with minY: "..minY.."; maxY: "..maxY)
	if(thisObject.objects ~= nil) then
		for j = #thisObject.objects, 1, -1 do
			--Update to 0 completion
			M.Object_update(thisObject.objects[j], 0, 0, 0, 0, 1)
			minY, maxY = M.getStartEndY(thisObject.objects[j], thisObject.objects[j].y)
			if(maxY > absoluteMax)then
				absoluteMax = maxY
			end
		end
	end
	print("Ending with absoluteMax: "..absoluteMax)

	if(thisObject.objects ~= nil) then
		for j = #thisObject.objects, 1, -1 do
			--Update to 100 completion
			M.Object_update(thisObject.objects[j], 1, 0, 0, 0, 1)
			minY, maxY = M.getStartEndY(thisObject.objects[j], thisObject.objects[j].y)
			if(minY < absoluteMin)then
				absoluteMin = minY
			end
		end
	end
	print("Ending with absoluteMin: "..absoluteMin)

	return absoluteMin, absoluteMax
end

--Initalizes a new tObject (startT is ommitted because it is calculated)
function M.newTObject(objects, start_x, start_y, end_y)
	local tObject = {}
	tObject.start_x = start_x
	tObject.start_y = start_y*N.COL_SIZE
	tObject.end_y = end_y*N.COL_SIZE
	tObject.start_time = system.getTimer()
	tObject.objects = objects
	tObject.height = height
	tObject.objects = objects

	return tObject
end

function M.newCoin(x,y)
	local coin = display.newSprite(V.sheet_coin, V.sequences_coin)
	physics.addBody(coin,"static",
		{radius=N.COIN_RADIUS}
		)

	coin:scale(N.COIN_SCALE, N.COIN_SCALE)

	if(x == nil) then
		coin.r_x = 0
	else
		coin.r_x = x
	end

	if(y == nil) then
		coin.r_y = 0
	else
		coin.r_y = y
	end

	coin.r_rot = 0

	coin.r_scale = 1
	coin.type = "coin"
	coin.objects = {}
	coin:play()
	return coin
end

function M.newPlus(x,y)
	local plus = display.newSprite(V.sheet_plus, V.sequences_plus)
	physics.addBody(plus,"static",
		{radius=N.PLUS_RADIUS}
		)

	plus:scale(N.PLUS_SCALE, N.PLUS_SCALE)

	if(x == nil) then
		plus.r_x = 0
	else
		plus.r_x = x
	end

	if(y == nil) then
		plus.r_y = 0
	else
		plus.r_y = y
	end

	plus.r_rot = 0

	plus.r_scale = 1
	plus.type = "plus"
	plus.objects = {}
	plus:play()
	return plus
end

--*******************************************************************************--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-----------------------------------Fun Obstacles-----------------------------------
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--*******************************************************************************--

-- newLine(startx, starty, endx, endy, 
--		spike_speed, spike_num, left_to_right, ping_pong, objects)
-- newObject(original, r_x, r_y, r_rot, r_scale, typeIn, objects)
-- newSpike(x, y, rot)
-- newNSquare(spike_speed, square_size, spike_num, objects)


function M.addTwoColumnSquares()


	
end

function M.addVerticalSweep1()
	local sweep_height = 10
	local objects = {}

	for i = sweep_height, 1, -1 do
		local spikes = {M.newSpike(0,0,90)}

		table.insert(objects, M.newLine(-4, -i, 4, -i,
			4, 2, true, 4, spikes
			))
	end 

	table.insert(tObjects, M.newTObject(objects, display.contentWidth/2, -1.5, 12))
end

function M.addSquareLine1()
	local square1 = M.newNSquare(1, 8, 4)
	local square2 = M.newNSquare(1, 8, 4)

	local lineObjects = {square1, square2}

	local line1 = M.newLine(-12, 0, 12, 0,
		1, 2, true, 1, lineObjects
		)

	local objects = {line1}
	table.insert(tObjects, M.newTObject(objects, display.contentWidth/2, -4, 4))
end


function M.addLineLattice2()
	local line1 = M.newLine(-8.5, -8, 8.5, 0,
		1, 2, true, 1
		)

	local line3 = M.newLine(-8.5, 0, 8.5, -8,
		1, 2, false, 1
		)


	local objects = {line1, line3}
	table.insert(tObjects, M.newTObject(objects, display.contentWidth/2, -1.5, 8.5))
end


function M.addLineLattice1()
	local line1 = M.newLine(-8.5, -8, 8.5, 0,
		4, 1, true, 1
		)

	local line2 = M.newLine(-8.5, -16, 8.5, -8,
		4, 1, true, 1
		)

	local line3 = M.newLine(-8.5, -4, 8.5, -12,
		4, 1, false, 1
		)

	local line4 = M.newLine(-8.5, -12, 8.5, -20,
		4, 1, false, 1
		)

	local objects = {line1, line2, line3, line4}
	table.insert(tObjects, M.newTObject(objects, display.contentWidth/2, -1.5, 20))
end

function M.addLineHell1()
	local line1 = M.newLine(-8.5, 0, 8.5, 0,
		1, 3, true, 1
		)

	local line2 = M.newLine(-8.5, -8, 8.5, -8,
		1, 3, false, 1
		)

	local line3 = M.newLine(-8.5, -16, 8.5, -16,
		1, 3, true, 1
		)

	local objects = {line1, line2, line3}

	table.insert(tObjects, M.newTObject(objects, display.contentWidth/2, -1.5, 17.5))
end

function M.addBigSquare1()
	local square1 = M.newNSquare(.5, 14, 3)
	local coin = M.newPlus(0,-7)

	local objects = {square1, coin}
	table.insert(tObjects, M.newTObject(objects, display.contentWidth/2, -7,7))
end

function M.reset()

end

return M