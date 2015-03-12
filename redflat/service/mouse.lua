-----------------------------------------------------------------------------------------------------------------------
--                                            RedFlat mouse actions util                                             --
-----------------------------------------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local awful = require("awful")
local redutil = require("redflat.util")
local common = require("redflat.layout.common")

local ipairs = ipairs
local math = math


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

	local orig = c:geometry()
	local m_c = mouse.coords()
	local dist = {
		x = m_c.x - orig.x,
		y = m_c.y - orig.y
	}

	mousegrabber.run(
		function (_mouse)
			for k, v in ipairs(_mouse.buttons) do
				if v then
					local lay = awful.layout.get(c.screen)
					local handler = get_move_handler(lay)
					if awful.client.floating.get(c) then
						common.mouse.handler.move.floating(c, _mouse, dist)
					elseif handler then
						handler(c, _mouse, dist)
					end
					return true
				end
			end
			return false
		end,
		"fleur"
	)
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
