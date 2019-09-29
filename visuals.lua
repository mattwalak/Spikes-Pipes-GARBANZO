local N = require("crazy_numbers")

--Coin sprite things
local sheetOptions_coin =
{
	width = 100,
	height = 100,
	numFrames = 8
}

local sheet_coin = graphics.newImageSheet("Coin.png", sheetOptions_coin)
local sequences_coin = {
	{
		name = "normal",
		start = 1,
		count = 8,
		time = 800,
		loopCount = 0,
		loopDirection = "forward"
	}
}

--Plus sprite things
local sheetOptions_plus =
{
	width = 150,
	height = 150,
	numFrames = 12
}

local sheet_plus = graphics.newImageSheet("Plus.png", sheetOptions_plus)
local sequences_plus = {
	{
		name = "normal",
		start = 1,
		count = 12,
		time = 1200,
		loopCount = 0,
		loopDirection = "forward"
	}
}





local M = {
	spike_topSpike = {0, -145, 27, -49, -27, -49},
	spike_box = {-48, -47, 47, -48, 47, 47, -48, 48},
	spike_bottomSpike = {-27, 48, 26, 48, 0, 141},
	sheet_coin = sheet_coin,
	sequences_coin = sequences_coin,
	sheet_plus = sheet_plus,
	sequences_plus = sequences_plus,
	blue = {0, 0, 225},
	red = {225, 0, 0},
	green = {0, 225, 0},
	yellow = {255, 225, 0}
}

return M

--[[
	spike_topSpike = {0/150, -145/150, 27/150, -49/150, -27/150, -49/150},
	spike_box = {-48/150, -47/150, 47/150, -48/150, 47/150, 47/150, -48/150, 48/150},
	spike_bottomSpike = {-27/150, 48/150, 26/150, 48/150, 0/150, 141/150},


	spike_topSpike = {0, -145, 27, -49, -27, -49},
	spike_box = {-48, -47, 47, -48, 47, 47, -48, 48},
	spike_bottomSpike = {-27, 48, 26, 48, 0, 141},
]]

