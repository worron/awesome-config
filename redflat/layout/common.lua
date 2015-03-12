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

local function get_move_handler(lay)
	return lay.mouse_move_handler or common.mouse.move_handler[lay]
end

local function get_resize_handler(lay)
	return lay.mouse_resize_handler or common.mouse.resize_handler[lay]
end

-- Resize handlers
-- !!! Temporary code !!!
-- !!! remove after awesome github #56 'Layouts can define their own resizing handler' release !!!
-----------------------------------------------------------------------------------------------------------------------
function common.mouse.handler.resize.floating(c, corner, x, y)
	local g = c:geometry()

	-- Do not allow maximized clients to be resized by mouse
	local fixed_x = c.maximized_horizontal
	local fixed_y = c.maximized_vertical

	-- Warp mouse pointer
	mouse.coords({ x = x, y = y })

	mousegrabber.run(
		function (_mouse)
			 for k, v in ipairs(_mouse.buttons) do
				if v then
					local ng
					if corner == "bottom_right" then
						ng = { width = _mouse.x - g.x,
						       height = _mouse.y - g.y }
					elseif corner == "bottom_left" then
						ng = { x = _mouse.x,
						       width = (g.x + g.width) - _mouse.x,
						       height = _mouse.y - g.y }
					elseif corner == "top_left" then
						ng = { x = _mouse.x,
						       width = (g.x + g.width) - _mouse.x,
						       y = _mouse.y,
						       height = (g.y + g.height) - _mouse.y }
					else
						ng = { width = _mouse.x - g.x,
						       y = _mouse.y,
						       height = (g.y + g.height) - _mouse.y }
					end
					if ng.width <= 0 then ng.width = nil end
					if ng.height <= 0 then ng.height = nil end
					if fixed_x then ng.width = g.width ng.x = g.x end
					if fixed_y then ng.height = g.height ng.y = g.y end
					c:geometry(ng)
					-- Get real geometry that has been applied
					-- in case we honor size hints
					-- XXX: This should be rewritten when size
					-- hints are available from Lua.
					local rg = c:geometry()

					if corner == "bottom_right" then
					ng = {}
					elseif corner == "bottom_left" then
						ng = { x = (g.x + g.width) - rg.width }
					elseif corner == "top_left" then
						ng = { x = (g.x + g.width) - rg.width,
						       y = (g.y + g.height) - rg.height }
					else
						ng = { y = (g.y + g.height) - rg.height }
					end
					c:geometry({ x = ng.x, y = ng.y })
					return true
				end
			end
			return false
		end,
		corner .. "_corner"
	)
end

local function tile_resize_handler(c, corner, x, y, orientation)
	local orientation = orientation or "tile"
	local wa = screen[c.screen].workarea
	local mwfact = awful.tag.getmwfact()
	local cursor
	local g = c:geometry()
	local offset = 0
	local x,y
	if orientation == "tile" then
		cursor = "cross"
		if g.height+15 > wa.height then
			offset = g.height * .5
			cursor = "sb_h_double_arrow"
		elseif not (g.y+g.height+15 > wa.y+wa.height) then
			offset = g.height
		end
		mouse.coords({ x = wa.x + wa.width * mwfact, y = g.y + offset })
	elseif orientation == "left" then
		cursor = "cross"
		if g.height+15 >= wa.height then
			offset = g.height * .5
			cursor = "sb_h_double_arrow"
		elseif not (g.y+g.height+15 > wa.y+wa.height) then
			offset = g.height
		end
		mouse.coords({ x = wa.x + wa.width * (1 - mwfact), y = g.y + offset })
	elseif orientation == "bottom" then
		cursor = "cross"
		if g.width+15 >= wa.width then
			offset = g.width * .5
			cursor = "sb_v_double_arrow"
		elseif not (g.x+g.width+15 > wa.x+wa.width) then
			offset = g.width
		end
		mouse.coords({ y = wa.y + wa.height * mwfact, x = g.x + offset})
	else
		cursor = "cross"
		if g.width+15 >= wa.width then
			offset = g.width * .5
			cursor = "sb_v_double_arrow"
		elseif not (g.x+g.width+15 > wa.x+wa.width) then
			offset = g.width
		end
		mouse.coords({ y = wa.y + wa.height * (1 - mwfact), x= g.x + offset })
	end

	mousegrabber.run(
		function (_mouse)
			for k, v in ipairs(_mouse.buttons) do
				if v then
					local fact_x = (_mouse.x - wa.x) / wa.width
					local fact_y = (_mouse.y - wa.y) / wa.height
					local mwfact

					local g = c:geometry()

					-- we have to make sure we're not on the last visible client
					-- where we have to use different settings.
					local wfact
					local wfact_x, wfact_y
					if (g.y+g.height+15) > (wa.y+wa.height) then
						wfact_y = (g.y + g.height - _mouse.y) / wa.height
					else
						wfact_y = (_mouse.y - g.y) / wa.height
					end

					if (g.x+g.width+15) > (wa.x+wa.width) then
						wfact_x = (g.x + g.width - _mouse.x) / wa.width
					else
						wfact_x = (_mouse.x - g.x) / wa.width
					end

					if orientation == "tile" then
						mwfact = fact_x
						wfact = wfact_y
					elseif orientation == "left" then
						mwfact = 1 - fact_x
						wfact = wfact_y
					elseif orientation == "bottom" then
						mwfact = fact_y
						wfact = wfact_x
					else
						mwfact = 1 - fact_y
						wfact = wfact_x
					end

					awful.tag.setmwfact(math.min(math.max(mwfact, 0.01), 0.99), awful.tag.selected(c.screen))
					awful.client.setwfact(math.min(math.max(wfact,0.01), 0.99), c)
					return true
				end
			end
			return false
		end,
		cursor
	)
end

common.mouse.handler.resize.tile = {
	right  = function(c, corner, x, y) return tile_resize_handler(c, corner, x, y) end,
	left   = function(c, corner, x, y) return tile_resize_handler(c, corner, x, y, "left") end,
	top    = function(c, corner, x, y) return tile_resize_handler(c, corner, x, y, "top") end,
	bottom = function(c, corner, x, y) return tile_resize_handler(c, corner, x, y, "bottom") end
}

function common.mouse.handler.resize.magnifier(c, corner, x, y)
	mouse.coords({ x = x, y = y })

	local wa = screen[c.screen].workarea
	local center_x = wa.x + wa.width / 2
	local center_y = wa.y + wa.height / 2
	local maxdist_pow = (wa.width^2 + wa.height^2) / 4

	mousegrabber.run(
		function (_mouse)
			for k, v in ipairs(_mouse.buttons) do
				if v then
					local dx = center_x - _mouse.x
					local dy = center_y - _mouse.y
					local dist = dx^2 + dy^2

					-- New master width factor
					local mwfact = dist / maxdist_pow
					awful.tag.setmwfact(math.min(math.max(0.01, mwfact), 0.99), awful.tag.selected(c.screen))
					return true
				end
			end
			return false
		end,
		corner .. "_corner"
	)
end

-- Handlers table
-----------------------------------------------------------------------------------------------------------------------
common.mouse.move_handler = {}
common.mouse.move_handler[layout.suit.floating]    = common.mouse.handler.move.floating
common.mouse.move_handler[layout.suit.fair]        = common.mouse.handler.move.tile
common.mouse.move_handler[layout.suit.tile]        = common.mouse.handler.move.tile
common.mouse.move_handler[layout.suit.tile.left]   = common.mouse.handler.move.tile
common.mouse.move_handler[layout.suit.tile.top]    = common.mouse.handler.move.tile
common.mouse.move_handler[layout.suit.tile.bottom] = common.mouse.handler.move.tile
common.mouse.move_handler[layout.suit.spiral]      = common.mouse.handler.move.tile

common.mouse.resize_handler = {}
common.mouse.resize_handler[layout.suit.floating]    = common.mouse.handler.resize.floating
common.mouse.resize_handler[layout.suit.magnifier]   = common.mouse.handler.resize.magnifier
common.mouse.resize_handler[layout.suit.tile]        = common.mouse.handler.resize.tile.right
common.mouse.resize_handler[layout.suit.tile.right]  = common.mouse.handler.resize.tile.right
common.mouse.resize_handler[layout.suit.tile.left]   = common.mouse.handler.resize.tile.left
common.mouse.resize_handler[layout.suit.tile.top]    = common.mouse.handler.resize.tile.top
common.mouse.resize_handler[layout.suit.tile.bottom] = common.mouse.handler.resize.tile.bottom

-- End
-----------------------------------------------------------------------------------------------------------------------
return common
