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

	-- layouts list
	local layset = {
		awful.layout.suit.floating,
		redflat.layout.grid,
		awful.layout.suit.tile,
		awful.layout.suit.fair,
		redflat.layout.map,
		awful.layout.suit.max,
		awful.layout.suit.max.fullscreen,
	}

	awful.layout.layouts = layset
end

-- some advanced layout settings
redflat.layout.map.notification = false


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


-- user map layout preset
-- preset can be defined for individual tags, but this should be done after tag initialization

-- redflat.layout.map.base_construct = function(wa)
-- 	local tree = { set = {}, active = 1, autoaim = true }

-- 	tree.set[1] = redflat.layout.map.construct_itempack({}, wa, false)
-- 	tree.set[2] = redflat.layout.map.base_set_new_pack({}, wa, true, tree.set[1])
-- 	tree.set[3] = redflat.layout.map.base_set_new_pack({}, wa, true, tree.set[1])
-- 	tree.set[4] = redflat.layout.map.base_set_new_pack({}, wa, true, tree.set[1])

-- 	function tree:aim()
-- 		for i = 2, 4 do if #self.set[i].items == 0 then return i end end
-- 		local active = #self.set[4].items >= #self.set[2].items and 2 or 4
-- 		return active
-- 	end

-- 	return tree
-- end


-- End
-----------------------------------------------------------------------------------------------------------------------
return layouts
