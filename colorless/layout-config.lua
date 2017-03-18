-----------------------------------------------------------------------------------------------------------------------
--                                                Layouts config                                                     --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local awful = require("awful")
local redflat = require("redflat")


-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local layouts = {}


-- Build  table
-----------------------------------------------------------------------------------------------------------------------
function layouts:init(args)
	local args = args or {}

	local layset = {
		awful.layout.suit.floating,
		awful.layout.suit.tile,
		awful.layout.suit.tile.left,
		awful.layout.suit.tile.bottom,
		awful.layout.suit.tile.top,
		awful.layout.suit.fair,
		awful.layout.suit.max,
		awful.layout.suit.max.fullscreen,
		redflat.layout.grid,
	}

	awful.layout.layouts = layset
end


client.disconnect_signal("request::geometry", awful.layout.move_handler)
client.connect_signal("request::geometry", redflat.layout.common.mouse.move)

-- End
-----------------------------------------------------------------------------------------------------------------------
return layouts
