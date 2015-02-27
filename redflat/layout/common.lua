-----------------------------------------------------------------------------------------------------------------------
--                                          RedFlat layout shared functions                                          --
-----------------------------------------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------------------------------------
-- Some code was taken from
------ awful.mouse v3.5.6
------ (c) 2008 Julien Danjou
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local layout = require("awful.layout")
local awful = require("awful")

local ipairs = ipairs
local math = math

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local common = { mouse = {} }

common.mouse.snap = 10
common.mouse.ignored = { "dock", "splash", "desktop"}

-- Support functions
-----------------------------------------------------------------------------------------------------------------------
common.mouse.handler = { move = {}, resize = {} }

function common.mouse.handler.move.floating(c, _mouse, dist)
	local x = _mouse.x - dist.x
	local y = _mouse.y - dist.y
	c:geometry(awful.mouse.client.snap(c, common.mouse.snap, x, y, c.maximized_horizontal, c.maximized_vertical))
end

function common.mouse.handler.move.tile(c)
	local c_u_m = awful.mouse.client_under_pointer()
	if c_u_m and not awful.client.floating.get(c_u_m) then
		if c_u_m ~= c then c:swap(c_u_m) end
	end
end

function get_move_handler(lay)
	return lay.mouse_move_handler or common.mouse.move_handler[lay]
end

-- Move handlers table
-----------------------------------------------------------------------------------------------------------------------
common.mouse.move_handler = {}
common.mouse.move_handler[layout.suit.floating]    = common.mouse.handler.move.floating
common.mouse.move_handler[layout.suit.fair]        = common.mouse.handler.move.tile
common.mouse.move_handler[layout.suit.tile]        = common.mouse.handler.move.tile
common.mouse.move_handler[layout.suit.tile.left]   = common.mouse.handler.move.tile
common.mouse.move_handler[layout.suit.tile.top]    = common.mouse.handler.move.tile
common.mouse.move_handler[layout.suit.tile.bottom] = common.mouse.handler.move.tile
common.mouse.move_handler[layout.suit.spiral]      = common.mouse.handler.move.tile

-- Move a client
-----------------------------------------------------------------------------------------------------------------------
-- @param c The client to move, or the focused one if nil.
-- @param snap The pixel to snap clients.
-- !!! Multi monitor moving (temporary?) removed !!!
function common.mouse.move(c)
	local c = c or client.focus

	if not c or c.fullscreen or awful.util.table.hasitem(common.mouse.ignored, c.type) then
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
					local lay = layout.get(c.screen)
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

-- End
-----------------------------------------------------------------------------------------------------------------------
return common
