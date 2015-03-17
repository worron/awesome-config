-----------------------------------------------------------------------------------------------------------------------
--                                            RedFlat mouse actions util                                             --
-----------------------------------------------------------------------------------------------------------------------
-- Move and resize windows by mouse
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local awful = require("awful")
local redutil = require("redflat.util")
local common = require("redflat.layout.common")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local amouse = { handler = {}, handler_list = {} }

amouse.ignored = { "dock", "splash", "desktop"}

-- Support functions
-----------------------------------------------------------------------------------------------------------------------
local function get_move_handler(lay)
	return lay.mouse_move_handler or common.mouse.move_handler[lay]
end

local function get_resize_handler(lay)
	return lay.mouse_resize_handler or common.mouse.resize_handler[lay]
end

-- Move a client
-- !!! Multi monitor moving (temporary?) removed !!!
-----------------------------------------------------------------------------------------------------------------------
function amouse.move(c)
	local c = c or client.focus

	if not c or c.fullscreen or awful.util.table.hasitem(amouse.ignored, c.type) then
		return
	end

	local lay = awful.layout.get(c.screen)
	local handler = get_move_handler(lay)

	if awful.client.floating.get(c) then
		return common.mouse.handler.move.floating(c)
	elseif handler then
		return handler(c)
	end
end

-- Resize a client
-----------------------------------------------------------------------------------------------------------------------
function amouse.resize(c)
	local c = c or client.focus

	if not c or c.fullscreen or awful.util.table.hasitem(amouse.ignored, c.type) then
		return
	end

	local lay = awful.layout.get(c.screen)
	local corner, x, y = awful.mouse.client.corner(c, corner)
	local handler = get_resize_handler(lay)

	if awful.client.floating.get(c) then
		return common.mouse.handler.resize.floating(c, corner, x, y)
	elseif handler then
		return handler(c, corner, x, y)
	end
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return amouse
