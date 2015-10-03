-----------------------------------------------------------------------------------------------------------------------
--                                               Window layouts config                                               --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local lain = require("lain")
local awful = require("awful")
local redflat = require("redflat")

-- Layouts setup
-----------------------------------------------------------------------------------------------------------------------
local layouts = {
	awful.layout.suit.floating,
	redflat.layout.grid,
	lain.layout.uselesstile,
	lain.layout.uselesstile.left,
	lain.layout.uselesstile.bottom,
	lain.layout.uselessfair,
	redflat.layout.map,
	awful.layout.suit.max,
	awful.layout.suit.max.fullscreen,

	--awful.layout.suit.fair,
	--awful.layout.suit.tile,
	--awful.layout.suit.fair.horizontal,
	--awful.layout.suit.spiral,
	--awful.layout.suit.spiral.dwindle,
	--awful.layout.suit.magnifier
	--lain.layout.uselesstile.left,
	--lain.layout.uselessfair
}

-- Set layout property
-----------------------------------------------------------------------------------------------------------------------

-- Set handlers for user layouts
local red_move_handler = redflat.layout.common.mouse.move_handler
local red_resize_handler = redflat.layout.common.mouse.resize_handler
local red_key_handler = redflat.layout.common.keyboard.key_handler

red_move_handler[lain.layout.uselessfair]        = redflat.layout.common.mouse.handler.move.tile
red_move_handler[lain.layout.uselesstile]        = redflat.layout.common.mouse.handler.move.tile
red_move_handler[lain.layout.uselesstile.left]   = redflat.layout.common.mouse.handler.move.tile
red_move_handler[lain.layout.uselesstile.bottom] = redflat.layout.common.mouse.handler.move.tile

red_resize_handler[lain.layout.uselesstile]        = redflat.layout.common.mouse.handler.resize.tile.right
red_resize_handler[lain.layout.uselesstile.left]   = redflat.layout.common.mouse.handler.resize.tile.left
red_resize_handler[lain.layout.uselesstile.bottom] = redflat.layout.common.mouse.handler.resize.tile.bottom

red_key_handler[lain.layout.uselessfair]        = redflat.layout.common.keyboard.handler.fair
red_key_handler[lain.layout.uselesstile]        = redflat.layout.common.keyboard.handler.tile.right
red_key_handler[lain.layout.uselesstile.left]   = redflat.layout.common.keyboard.handler.tile.left
red_key_handler[lain.layout.uselesstile.bottom] = redflat.layout.common.keyboard.handler.tile.bottom

-- Set floating layouts for swap util
redflat.util.floating_layout = { redflat.layout.grid }

-- Find best position for new window with map layout
redflat.layout.map.autoaim = true

-- End
-----------------------------------------------------------------------------------------------------------------------
return layouts
