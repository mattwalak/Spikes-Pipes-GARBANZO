local x = display.contentWidth/16 --(COL_SIZE)

--Original bubble mass (As simulated on 1920*1080 Galaxy S5)
local originalMass = 0.0035784705542028

local M = {

		--Display is divided into 16 columns of equal size
	 COL_SIZE = x, --Originally 20


	--CRAZY NUMBERS (Defined in relation to COL_SIZE)
	 BUBBLE_DISPLAY_SIZE = (x)*(30/20),
	 BUBBLE_RADIUS = (x)*(9/20),
	 SPIKE_DISPLAY_SIZE = (x),
	 SPIKE_RADIUS = (x)*(9/20),
	 BLOW_FACTOR = (x)*(.05/20),  --<-- Literally no clue what this one does...

	 MIN_BLOW_DIST = (x)*(50/20),
	 MIN_CLUMP_DIST = (x)*(40/20),
	 EDGE_DIST = 1.5*(x)*(20/20),

	 RANDOM_WIND_FACTOR = (x)*(.1/20)/originalMass,
	 BLOW_NUM = (x)*(150/20)/originalMass,
	 CLUMP_FORCE_FACTOR = 1.4*(20/((x)*5000))/originalMass, ---1.4 CURRENTLY

	 EDGE_FORCE_FACTOR = 10, --(How many times the force of clump force factor)

	 INIT_SPEED = (x)*(100/20), --Measured COL_SIZE pixles per second


	--LESS CRAZY NUMBERS (Not defined in relation to COL_SIZE)
	 LINEAR_DAMPING = 1.4,
	 INIT_CLUMP_SIZE = 10,
	 LOOP_DELAY = 10,

	 SPIKE_IMAGE_HEIGHT = 300,
	 SPIKE_IMAGE_WIDTH = 100,
	 COIN_IMAGE_HEIGHT = 100,
	 COIN_IMAGE_WIDTH = 100,

	 COIN_SCALE = x/50,
	 COIN_RADIUS = x,

	 PLUS_IMAGE_HEIGHT = 150,
	 PLUS_IMAGE_WIDTH = 150,

	 PLUS_SCALE = x/50,
	 PLUS_RADIUS = x,
}

return M