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
local setmetatable = setmetatable
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local util = { text = {}, cairo = {}, table = {}, desktop = {}, placement = {}, client = {} }

util.floating_layout = {}

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

-- Check if deep key exists
-----------------------------------------------------------------------------------------------------------------------
function util.check(t, s)
    local v = t

    for key in string.gmatch(s, "([^%.]+)(%.?)") do
        if v[key] then
            v = v[key]
        else
            return nil
        end
    end

    return v
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

-- Set font
------------------------------------------------------------
function util.cairo.set_font(cr, font)
	cr:set_font_size(font.size)
	cr:select_font_face(font.font, font.slant, font.face)
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

-- Apply handler on every raw table element and join result
------------------------------------------------------------
function util.table.join_raw(t, handler)
	local temp = {}

	for _, v in ipairs(t) do
		if v.args then table.insert(temp, handler(unpack(v.args))) end
	end

	return awful.util.table.join(unpack(temp))
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

-- Placement utilits
-----------------------------------------------------------------------------------------------------------------------
local direction = { x = "width", y = "height" }

function util.placement.add_gap(geometry, gap)
	return {
		x = geometry.x + gap,
		y = geometry.y + gap,
		width = geometry.width - 2 * gap,
		height = geometry.height - 2 * gap
	}
end

function util.placement.no_offscreen(object, gap, area)
	local geometry = object:geometry()
	local border = object.border_width

	local screen_idx = object.screen or awful.screen.getbycoord(geometry.x, geometry.y)
	local area = area or screen[screen_idx].workarea
	if gap then area = util.placement.add_gap(area, gap) end

	for coord, dim in pairs(direction) do
		if geometry[coord] + geometry[dim] + 2 * border > area[coord] + area[dim] then
			geometry[coord] = area[coord] + area[dim] - geometry[dim] - 2*border
		elseif geometry[coord] < area[coord] then
			geometry[coord] = area[coord]
		end
	end

	object:geometry(geometry)
end

local function centered_base(is_h, is_v)
	return function(object, gap, area)
		local geometry = object:geometry()
		local new_geometry = {}

		local screen_idx = object.screen or awful.screen.getbycoord(geometry.x, geometry.y)
		local area = area or screen[screen_idx].geometry
		if gap then area = util.placement.add_gap(area, gap) end

		if is_h then new_geometry.x = area.x + (area.width - geometry.width) / 2 - object.border_width end
		if is_v then new_geometry.y = area.y + (area.height - geometry.height) / 2 - object.border_width end

		return object:geometry(new_geometry)
	end
end

util.placement.centered = setmetatable({}, {
	__call = function(_, ...) return centered_base(true, true)(...) end
})
util.placement.centered.horizontal = centered_base(true, false)
util.placement.centered.vertical = centered_base(false, true)

-- Client utilits
-----------------------------------------------------------------------------------------------------------------------
local function size_correction(c, geometry, is_restore)
	local sign = is_restore and - 1 or 1
	local bg = sign * 2 * c.border_width

    if geometry.width  then geometry.width  = geometry.width  - bg end
    if geometry.height then geometry.height = geometry.height - bg end
end

-- Client geometry correction by border width
--------------------------------------------------------------------------------
function util.client.fullgeometry(c, g)
	local ng

	if g then
		if g.width  and g.width  <= 1 then return end
		if g.height and g.height <= 1 then return end

		size_correction(c, g, false)
		ng = c:geometry(g)
	else
		ng = c:geometry()
	end

	size_correction(c, ng, true)

	return ng
end

-- Smart swap include floating layout
--------------------------------------------------------------------------------
function util.client.swap(c1, c2)
	local lay = awful.layout.get(c1.screen)
	if awful.util.table.hasitem(util.floating_layout, lay) then
		local g1, g2 = util.client.fullgeometry(c1), util.client.fullgeometry(c2)

		util.client.fullgeometry(c1, g2)
		util.client.fullgeometry(c2, g1)
	end

	c1:swap(c2)
end


-----------------------------------------------------------------------------------------------------------------------
return util
