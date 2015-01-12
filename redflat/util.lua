-----------------------------------------------------------------------------------------------------------------------
--                                                     RedFlat util                                                  --
-----------------------------------------------------------------------------------------------------------------------
-- Simple common user functions
-- and slightly modded default functions collected here
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local io = io
local ipairs = ipairs
local pairs = pairs
local math = math
local string = string
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local util = { text = {}, cairo = {}, table = {}, desktop = {} }


-- Read from file
-----------------------------------------------------------------------------------------------------------------------
function util.read_ffile(path)
	local file = io.open(path)

	if file then
		output = file:read("*a")
		file:close()
	else
		return nil
	end

	return output
end

-- Format text
-----------------------------------------------------------------------------------------------------------------------

-- Format string to number with minimum length
------------------------------------------------------------
function util.text.oformat(v, w)
	local p = math.ceil(math.log10(v))
	local prec = v <= 10 and w - 1 or p > w and 0 or w - p
	return string.format('%.' .. prec .. 'f', v)
end

-- Format output for destop widgets
------------------------------------------------------------
function util.text.dformat(value, unit, w, spacer)
	local res = value
	local add = ""
	local w = w or 3
	local spacer = spacer or "  "

	for _, v in pairs(unit) do
		if value > v[2] then
			res = math.abs(value/v[2])
			add = v[1]
		end
	end

	return util.text.oformat(res, w) .. spacer .. add
end

-- Advanced buttons setup
-- Copypasted from awful.widget.common
-- (c) 2008-2009 Julien Danjou
-----------------------------------------------------------------------------------------------------------------------
function util.create_buttons(buttons, object)
	if buttons then
		local btns = {}

		for kb, b in ipairs(buttons) do
			-- Create a proxy button object: it will receive the real
			-- press and release events, and will propagate them the the
			-- button object the user provided, but with the object as
			-- argument.
			local btn = button { modifiers = b.modifiers, button = b.button }
			btn:connect_signal("press", function () b:emit_signal("press", object) end)
			btn:connect_signal("release", function () b:emit_signal("release", object) end)
			btns[#btns + 1] = btn
		end

		return btns
	end
end

-- Modules loader
-----------------------------------------------------------------------------------------------------------------------
function util.wrequire(table, key)
	local module = rawget(table, key)
	return module or require(table._NAME .. '.' .. key)
end

-- Cairo drawing functions
-----------------------------------------------------------------------------------------------------------------------

-- Draw text aligned by center
------------------------------------------------------------
function util.cairo.tcenter(cr, coord, text)
	local ext = cr:text_extents(text)
	cr:move_to(coord[1] - (ext.width/2 + ext.x_bearing), coord[2] - (ext.height/2 + ext.y_bearing))
	cr:show_text(text)
end

-- Draw text aligned by center horizontal only
------------------------------------------------------------
function util.cairo.tcenter_horizontal(cr, coord, text)
	local ext = cr:text_extents(text)
	cr:move_to(coord[1] - (ext.width/2 + ext.x_bearing), coord[2])
	cr:show_text(text)
end

-- Table operations
-----------------------------------------------------------------------------------------------------------------------

-- Merge two table to new one
------------------------------------------------------------
function util.table.merge(t1, t2)
	local ret = awful.util.table.clone(t1)

	for k, v in pairs(t2) do
		if type(v) == "table" and ret[k] and type(ret[k]) == "table" then
			ret[k] = util.table.merge(ret[k], v)
		else
			ret[k] = v
		end
	end

	return ret
end

-- Table elements sum
------------------------------------------------------------
function util.table.sum(t, n)
	local s = 0
	local n = n or #t

	for i = 1, n do s = s + t[i] end

	return s
end

-- Desktop utilits
-----------------------------------------------------------------------------------------------------------------------

local function wposition(grid, n, workarea, dir)
	local total = util.table.sum(grid[dir])
	local full_gap = util.table.sum(grid.edge[dir])
	local gap = #grid[dir] > 1 and (workarea[dir] - total - full_gap) / (#grid[dir] - 1) or 0

	local current = util.table.sum(grid[dir], n - 1)
	local pos = grid.edge[dir][1] + (n - 1) * gap + current

	return pos
end

-- Calculate size and position for desktop widget
------------------------------------------------------------
function util.desktop.wgeometry(grid, place, workarea)
	return {
		x = wposition(grid, place[1], workarea, "width"),
		y = wposition(grid, place[2], workarea, "height"),
		width  = grid.width[place[1]],
		height = grid.height[place[2]]
	}
end

-- Edge constructor
------------------------------------------------------------
function util.desktop.edge(direction, zone)
	local edge = { area = {} }

	edge.wibox = wibox({
		bg      = "#00000000",  -- transparent without compositing manager
		opacity = 0,            -- transparent with compositing manager
		ontop   = true,
		visible = true
	})

	edge.layout = wibox.layout.fixed[direction]()
	edge.wibox:set_widget(edge.layout)

	if zone then
		for i, z in ipairs(zone) do
			edge.area[i] = wibox.layout.margin(nil, 0, 0, z)
			edge.layout:add(edge.area[i])
		end
	end

	return edge
end

-----------------------------------------------------------------------------------------------------------------------
return util
