-----------------------------------------------------------------------------------------------------------------------
--                                                Layouts config                                                     --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local awful = require("awful")
local redflat = require("redflat")
local beautiful = require("beautiful")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local layouts = {}


-- Build  table
-----------------------------------------------------------------------------------------------------------------------
function layouts:init()

	-- layouts list
	local layset = {
		awful.layout.suit.floating,
		awful.layout.suit.tile,
		awful.layout.suit.tile.left,
		awful.layout.suit.tile.bottom,
		awful.layout.suit.tile.top,
		awful.layout.suit.fair,
		awful.layout.suit.corner.nw,
		awful.layout.suit.corner.ne,
		awful.layout.suit.corner.sw,
		awful.layout.suit.corner.se,
		awful.layout.suit.spiral,
		awful.layout.suit.magnifier,
		awful.layout.suit.max,
		awful.layout.suit.max.fullscreen,
		redflat.layout.grid,
		redflat.layout.map,
	}

	awful.layout.layouts = layset
end

-- some advanced layout settings
redflat.layout.map.notification = true
redflat.layout.map.notification_style = { icon = redflat.util.table.check(beautiful, "widget.layoutbox.icon.usermap") }


-- connect alternatve moving handler to allow using custom handler per layout
-- by now custom handler provided for 'redflat.layout.grid' only
-- feel free to remove if you don't use this one
client.disconnect_signal("request::geometry", awful.layout.move_handler)
client.connect_signal("request::geometry", redflat.layout.common.mouse.move)


-- connect additional signal for 'redflat.layout.map'
-- this one removing client in smart way and correct tiling scheme
-- feel free to remove if you want to restore plain queue behavior
client.connect_signal("unmanage", redflat.layout.map.clean_client)

client.connect_signal("property::minimized", function(c)
	if c.minimized and redflat.layout.map.check_client(c) then redflat.layout.map.clean_client(c) end
end)
client.connect_signal("property::floating", function(c)
	if c.floating and redflat.layout.map.check_client(c) then redflat.layout.map.clean_client(c) end
end)

client.connect_signal("untagged", function(c, t)
	if redflat.layout.map.data[t] then redflat.layout.map.clean_client(c) end
end)

-- End
-----------------------------------------------------------------------------------------------------------------------
return layouts
