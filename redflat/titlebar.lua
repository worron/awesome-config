-----------------------------------------------------------------------------------------------------------------------
--                                                RedFlat titlebar                                                   --
-----------------------------------------------------------------------------------------------------------------------
-- A simplified version awful.titlebar
-- Only simple indicators avaliable, no buttons
-- Focus indication moved to seperate icon
-- Window size correction added
-----------------------------------------------------------------------------------------------------------------------
-- Some code was taken from
------ awful.titlebar v3.5.2
------ (c) 2012 Uli Schlachter
-----------------------------------------------------------------------------------------------------------------------


-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local error = error
local type = type
local pairs = pairs
local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local color = require("gears.color")
local drawable = require("wibox.drawable")

local redutil = require("redflat.util")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local titlebar = { mt = {}, widget = {} }

local all_titlebars = setmetatable({}, { __mode = 'k' })

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		size          = 16,
		position      = "top",
		icon          = { size = 20, gap = 10 },
		border_margin = { 0, 0, 0, 8 },
		color         = { main = "#b1222b", wibox = "#202020", gray = "#575757" }
	}

	return redutil.table.merge(style, beautiful.titlebar or {})
end

-- Support functions
-----------------------------------------------------------------------------------------------------------------------

-- Construct layout with titlebar indicator
------------------------------------------------------------
local function ticon(c, t_func, size, gap)
	return wibox.layout.margin(wibox.layout.constraint(t_func(c), "exact", size, nil), gap)
end

-- Get titlebar function
------------------------------------------------------------
local function get_titlebar_function(c, position)
	if     position == "left"   then return c.titlebar_left
	elseif position == "right"  then return c.titlebar_right
	elseif position == "top"    then return c.titlebar_top
	elseif position == "bottom" then return c.titlebar_bottom
	else
		error("Invalid titlebar position '" .. position .. "'")
	end
end

-- Function to keep window size the same after show/hide titlebar
------------------------------------------------------------
local function correct_size(c, position, size)
	if position == "top" or position == "bottom" then
		c:geometry({ height = c:geometry().height + size })
	else
		c:geometry({ width = c:geometry().width + size })
	end
end

-- Base for window state indicators
------------------------------------------------------------
local function titlebar_icon(style)
	local style = redutil.table.merge(default_style(), style or {})

	local data = {
		color = style.color.gray
	}

	local ret = wibox.widget.base.make_widget()

	ret.fit = function(ret, width, height) return width, height end

	ret.draw = function(ret, wibox, cr, width, height)
		cr:set_source(color(data.color))
		cr:rectangle(0, 0, width, height)
		cr:fill()
	end

	function ret:set_active(active)
		data.color = active and style.color.main or style.color.gray
		self:emit_signal("widget::updated")
	end

	return ret
end


-- Get a client's titlebar
-- Can be called only once for every position
-- @param c The client for which a titlebar is wanted.
-----------------------------------------------------------------------------------------------------------------------
function titlebar.new(c, style)

	all_titlebars[c] = all_titlebars[c] or {}
	local style = redutil.table.merge(default_style(), style or {})

	local prop = {
		bg_color = style.color.wibox,
		size = style.size
	}

	-- Make sure that there is never more than one titlebar for any given client
	local ret
	if not all_titlebars[c][style.position] then
		correct_size(c, style.position, - prop.size)
		local d = get_titlebar_function(c, style.position)(c, prop.size)
		ret = drawable(d, nil)
		ret:set_bg(prop.bg_color)
		all_titlebars[c][style.position] = {
			args = prop,
			drawable = ret
		}
	end

	return ret
end

-- Titlebar functions
-----------------------------------------------------------------------------------------------------------------------

-- Get a state of client's titlebar
------------------------------------------------------------
function titlebar.get_state(c, position)
	local position = position or "top"
	local args = all_titlebars[c] and all_titlebars[c][position] and all_titlebars[c][position].args
	local drawable, size = get_titlebar_function(c, position)(c)
	return args and size > 0
end

-- Show a client's titlebar
------------------------------------------------------------
function titlebar.show(c, position)
	local position = position or "top"
	local args = all_titlebars[c] and all_titlebars[c][position] and all_titlebars[c][position].args
	local drawable, size = get_titlebar_function(c, position)(c)

	if args and size == 0 then
		get_titlebar_function(c, position)(c, args.size)
		correct_size(c, position, - args.size)
	end
end

--- Hide a client's titlebar
------------------------------------------------------------
function titlebar.hide(c, position)
	local position = position or "top"
	local args = all_titlebars[c] and all_titlebars[c][position] and all_titlebars[c][position].args
	local drawable, size = get_titlebar_function(c, position)(c)

	if args and size > 0 then
		get_titlebar_function(c, position)(c, 0)
		correct_size(c, position, size)
	end

	return args ~= nil and size > 0
end

-- Hide title bar for all avaliable clients
------------------------------------------------------------
function titlebar.hide_all(list, position)
	local cls = list or client.get()
	local list_of_hidden = {}

	for k, c in pairs(cls) do
		if titlebar.hide(c, position) then table.insert(list_of_hidden, c) end
	end

	return list_of_hidden
end

-- Show title bar for all avaliable clients
------------------------------------------------------------
function titlebar.show_all(list, position)
	local cls = list or client.get()

	for k, c in pairs(cls) do
		-- work with user client list is a pain, so pcall used here
		pcall(titlebar.show, c, position)
	end
end

-- Toggle a client's titlebar, hiding it if it is visible, otherwise showing it
------------------------------------------------------------
function titlebar.toggle(c, position)
	local position = position or "top"
	local drawable, size = get_titlebar_function(c, position)(c)

	if size == 0 then
		titlebar.show(c, position)
	else
		titlebar.hide(c, position)
	end
end

-- Window state indicators
-----------------------------------------------------------------------------------------------------------------------

-- Focused
------------------------------------------------------------
function titlebar.widget.focused(c, style)
	local ret = titlebar_icon(style)
	ret:set_active(client.focus == c)
	c:connect_signal("focus", function() ret:set_active(true) end)
	c:connect_signal("unfocus", function() ret:set_active(false) end)
	return ret
end

-- Floating
------------------------------------------------------------
function titlebar.widget.floating(c, style)
	local ret = titlebar_icon(style)
	ret:set_active(awful.client.floating.get(c))
	c:connect_signal("property::floating", function() ret:set_active(awful.client.floating.get(c)) end)
	return ret
end

-- Ontop
------------------------------------------------------------
function titlebar.widget.ontop(c, style)
	local ret = titlebar_icon(style)
	ret:set_active(c.ontop)
	c:connect_signal("property::ontop", function() ret:set_active(c.ontop) end)
	return ret
end

-- Sticky
------------------------------------------------------------
function titlebar.widget.sticky(c, style)
	local ret = titlebar_icon(style)
	ret:set_active(c.sticky)
	c:connect_signal("property::sticky", function() ret:set_active(c.sticky) end)
	return ret
end

-- Below
------------------------------------------------------------
function titlebar.widget.below(c, style)
	local ret = titlebar_icon(style)
	ret:set_active(c.below)
	c:connect_signal("property::below", function() ret:set_active(c.below) end)
	return ret
end


-- Base example of lightweight titlebar widget
-----------------------------------------------------------------------------------------------------------------------
function titlebar.constructor(c, indicators, style)
	local style = redutil.table.merge(default_style(), style or {})

	-- Construct titlebar layout
	------------------------------------------------------------
	local layout = wibox.layout.align.horizontal()

	-- Add focus icon
	------------------------------------------------------------
	local focus_layout = wibox.layout.constraint(titlebar.widget.focused(c), "exact")
	layout:set_middle(focus_layout)

	-- Add window state icons
	------------------------------------------------------------
	local state_layout = wibox.layout.fixed.horizontal()
	for _, id in ipairs(indicators) do
		state_layout:add(ticon(c, titlebar.widget[id], style.icon.size, style.icon.gap))
	end
	layout:set_right(state_layout)

	-- Set margin
	------------------------------------------------------------
	local margin_layout = wibox.layout.margin(layout, unpack(style.border_margin))

	-- Rotate layout if needed
	------------------------------------------------------------
	if style.position == "left" then
		return wibox.layout.rotate(margin_layout, "east")
	elseif style.position == "right" then
		return wibox.layout.rotate(margin_layout, "west")
	else
		return margin_layout
	end
end


-- Config metatable to call titlebar module as function
-----------------------------------------------------------------------------------------------------------------------
function titlebar.mt:__call(...)
	return titlebar.new(...)
end

return setmetatable(titlebar, titlebar.mt)
