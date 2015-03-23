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
local awful = require("awful")
local navigator = require("redflat.service.navigator")

local ipairs = ipairs
local math = math

local hasitem = awful.util.table.hasitem
local layout = awful.layout


-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local common = { mouse = {}, keyboard = {} }

common.mouse.handler = { move = {}, resize = {} }
common.keyboard.handler = {}
common.mouse.snap = 10
common.wfactstep = 0.05

local last = {}

-- default keys
common.keys = {
	move_up    = { "Up" },
	move_down  = { "Down" },
	move_left  = { "Left" },
	move_right = { "Right" },
	resize_up    = { "k", "K", },
	resize_down  = { "j", "J", },
	resize_left  = { "h", "H", },
	resize_right = { "l", "L", },
	exit = { "Escape", "Super_L" },
}

-- Shared movement handlers
-----------------------------------------------------------------------------------------------------------------------
function common.mouse.handler.move.floating(c)
	local orig = c:geometry()
	local m_c = mouse.coords()
    local fixed_x = c.maximized_horizontal
    local fixed_y = c.maximized_vertical
	local dist = {
		x = m_c.x - orig.x,
		y = m_c.y - orig.y
	}

	mousegrabber.run(
		function (_mouse)
			for k, v in ipairs(_mouse.buttons) do
				if v then
					local x = _mouse.x - dist.x
					local y = _mouse.y - dist.y
					c:geometry(awful.mouse.client.snap(c, common.mouse.snap, x, y, fixed_x, fixed_y))
					return true
				end
			end
			return false
		end,
		"fleur"
	)
end

function common.mouse.handler.move.tile(c)
	mousegrabber.run(
		function (_mouse)
			for k, v in ipairs(_mouse.buttons) do
				if v then
					local c_u_m = awful.mouse.client_under_pointer()
					if c_u_m and not awful.client.floating.get(c_u_m) then
						if c_u_m ~= c then c:swap(c_u_m) end
					end
					return true
				end
			end
			return false
		end,
		"fleur"
	)
end

-- Shared resizing handlers
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

-- Shared keyboard handlers
-----------------------------------------------------------------------------------------------------------------------
local function swap_by_geometry(mod, key, event)
	if     hasitem(common.keys.move_up, key)    then awful.client.swap.bydirection("up")
	elseif hasitem(common.keys.move_down, key)  then awful.client.swap.bydirection("down")
	elseif hasitem(common.keys.move_left, key)  then awful.client.swap.bydirection("left")
	elseif hasitem(common.keys.move_right, key) then awful.client.swap.bydirection("right")
	else
		return false
	end
	return true
end

-- Keygrabbers for awful layouts
-- TODO: improve resize direction finding for tile layout
--------------------------------------------------------------------------------
local function fair_keygrabber(mod, key, event)
	if event == "press" then return false
	elseif hasitem(common.keys.exit, key) then
		if last.on_close then last.on_close() end
		awful.keygrabber.stop(last.keygrabber)
	elseif navigator.raw_keygrabber(mod, key, event) then return true
	elseif swap_by_geometry(mod, key, event) then return true
	else return false
	end
end

local function tile_keygrabber_constructor(dir)
	local dy = (dir == "bottom" and -1 or 1) * common.wfactstep
	local dx = (dir == "left"   and -1 or 1) * common.wfactstep

	local vertical_action   = (dir == "left" or dir == "right") and awful.client.incwfact or awful.tag.incmwfact
	local horizontal_action = (dir == "left" or dir == "right") and awful.tag.incmwfact or awful.client.incwfact

	return function(mod, key, event)
		if event == "press" then return false
		elseif hasitem(common.keys.exit, key) then
			if last.on_close then last.on_close() end
			awful.keygrabber.stop(last.keygrabber)
		elseif navigator.raw_keygrabber(mod, key, event) then return true
		elseif swap_by_geometry(mod, key, event) then return true
		elseif hasitem(common.keys.resize_up, key)    then vertical_action(dy)
		elseif hasitem(common.keys.resize_down, key)  then vertical_action(- dy)
		elseif hasitem(common.keys.resize_right, key) then horizontal_action(dx)
		elseif hasitem(common.keys.resize_left, key)  then horizontal_action(- dx)
		else return false
		end
	end
end

local tile_keygrabber = {}
tile_keygrabber["right"]  = tile_keygrabber_constructor("right")
tile_keygrabber["left"]   = tile_keygrabber_constructor("left")
tile_keygrabber["top"]    = tile_keygrabber_constructor("top")
tile_keygrabber["bottom"] = tile_keygrabber_constructor("bottom")


-- Keyboard handlers for awful layouts
--------------------------------------------------------------------------------
common.keyboard.handler.fair = function(c, on_close)
	last.on_close = on_close
	last.keygrabber = fair_keygrabber

	awful.keygrabber.run(last.keygrabber)
end

local function handler_tile_constructor(dir)
	return function(c, on_close)
		last.c = c or client.focus
		last.on_close = on_close
		last.keygrabber = tile_keygrabber[dir]

		awful.keygrabber.run(last.keygrabber)
	end
end

common.keyboard.handler.tile = {}
common.keyboard.handler.tile.right  = handler_tile_constructor("right")
common.keyboard.handler.tile.left   = handler_tile_constructor("left")
common.keyboard.handler.tile.top    = handler_tile_constructor("top")
common.keyboard.handler.tile.bottom = handler_tile_constructor("bottom")

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

common.keyboard.key_handler = {}
common.keyboard.key_handler[layout.suit.fair]        = common.keyboard.handler.fair
common.keyboard.key_handler[layout.suit.tile]        = common.keyboard.handler.tile.right
common.keyboard.key_handler[layout.suit.tile.right]  = common.keyboard.handler.tile.right
common.keyboard.key_handler[layout.suit.tile.left]   = common.keyboard.handler.tile.left
common.keyboard.key_handler[layout.suit.tile.top]    = common.keyboard.handler.tile.top
common.keyboard.key_handler[layout.suit.tile.bottom] = common.keyboard.handler.tile.bottom

-- End
-----------------------------------------------------------------------------------------------------------------------
return common
