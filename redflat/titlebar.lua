-----------------------------------------------------------------------------------------------------------------------
--                                                RedFlat titlebar                                                   --
-----------------------------------------------------------------------------------------------------------------------
-- model titlebar with two view: light and full
-- Tabs added
-- Only simple indicators avaliable, no buttons
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
local math = math

local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local color = require("gears.color")
local drawable = require("wibox.drawable")
local naughty = require("naughty")

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
		icon          = { size = 20, gap = 10, angle = 0 },
		font          = "Sans 12 bold",
		border_margin = { 0, 0, 0, 8 },
		color         = { main = "#b1222b", wibox = "#202020", gray = "#575757", text = "#aaaaaa" }
	}

	return redutil.table.merge(style, beautiful.titlebar or {})
end

-- Hack awful layout lib to be able lock window arrangement during sort operation
-----------------------------------------------------------------------------------------------------------------------
awful.layout.arrange_lock = false

awful.layout.arrange = function(s)
    if awful.layout.arrange_lock then return end
    awful.layout.arrange_lock = true
    local p = {}
    p.workarea = screen[s].workarea
    local padding = awful.screen.padding(screen[s])
    if padding then
        p.workarea.x = p.workarea.x + (padding.left or 0)
        p.workarea.y = p.workarea.y + (padding.top or 0)
        p.workarea.width = p.workarea.width - ((padding.left or 0 ) + (padding.right or 0))
        p.workarea.height = p.workarea.height - ((padding.top or 0) + (padding.bottom or 0))
    end
    p.geometry = screen[s].geometry
    p.clients = awful.client.tiled(s)
    p.screen = s
    awful.layout.get(s).arrange(p)
    screen[s]:emit_signal("arrange")
    awful.layout.arrange_lock = false
end

-- Support functions
-----------------------------------------------------------------------------------------------------------------------

-- Check if every client in list has titlebar
------------------------------------------------------------
local function check_group_list(cls, position)
	for _, c in ipairs(cls) do
		if not (all_titlebars[c] and all_titlebars[c][position]) then return false end
	end
	return true
end
-- Function to remove client from group
------------------------------------------------------------
local function get_size_by_model(model)
	return model.widget.widget == model.full.layout and model.full.size or model.light.size
end

-- Function to remove client from group
------------------------------------------------------------
local function construct_remover(c, position)
	return function(c)
		local model = all_titlebars[c] and all_titlebars[c][position] and all_titlebars[c][position].model
		if model and model.cls then
			local list = model.cls
			local id = awful.util.table.hasitem(list, c)

			titlebar.destroy_group(c, position)
			table.remove(list, id)
			if #list > 1 then titlebar.set_group(list, position) end
			client.focus = list[1]
		end
	end
end

-- Init textbox for title
------------------------------------------------------------
local function makebox(style)
	local titlebox = wibox.widget.textbox()
	titlebox:set_font(style.font)
	titlebox:set_align("center")

	return titlebox
end

-- Construct layout with titlebar indicator
------------------------------------------------------------
local function ticon(c, t_func, style)
	return wibox.layout.margin(
		wibox.layout.constraint(t_func(c, style), "exact", style.icon.size, nil),
		style.icon.gap
	)
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
	--local style = redutil.table.merge(default_style(), style or {})

	local data = {
		color = style.color.gray
	}

	local ret = wibox.widget.base.make_widget()

	ret.fit = function(ret, width, height) return width, height end

	ret.draw = function(ret, wibox, cr, width, height)
		cr:set_source(color(data.color))
		local d = math.tan(style.icon.angle) * height
		cr:move_to(0, height)
		cr:rel_line_to(d, - height)
		cr:rel_line_to(width - d, 0)
		cr:rel_line_to(-d, height)
		cr:close_path()

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
function titlebar.new(c, model, style)

	all_titlebars[c] = all_titlebars[c] or {}
	local style = redutil.table.merge(default_style(), style or {})

	-- Make sure that there is never more than one titlebar for any given client
	local ret
	if not all_titlebars[c][style.position] then
		local tfunction = get_titlebar_function(c, style.position)
		local d = tfunction(c, style.size)

		ret = drawable(d, nil)
		ret:set_bg(style.color.wibox)
		correct_size(c, style.position, - style.size)

		-- add info to model
		model.size = style.size
		model.position = style.position
		model.tfunction = tfunction

		-- save title bar info
		all_titlebars[c][style.position] = {
			model = model,
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
	local position = position or beautiful.titlebar and beautiful.titlebar.position or "top"
	local bar = all_titlebars[c] and all_titlebars[c][position]
	if not bar then return false end

	return bar.model.size > 0
end

-- Show a client's titlebar
------------------------------------------------------------
function titlebar.show(c, position)
	local position = position or beautiful.titlebar and beautiful.titlebar.position or "top"
	local bar = all_titlebars[c] and all_titlebars[c][position]
	if not bar then return false end

	local size = bar.model.size

	if size == 0 then
		bar.model.size = get_size_by_model(bar.model)
		bar.model.tfunction(c, bar.model.size)
		correct_size(c, position, - bar.model.size)
	end
end

--- Hide a client's titlebar
------------------------------------------------------------
function titlebar.hide(c, position)
	local position = position or beautiful.titlebar and beautiful.titlebar.position or "top"
	local bar = all_titlebars[c] and all_titlebars[c][position]
	if not bar then return false end

	local size = bar.model.size

	if size > 0 then
		bar.model.tfunction(c, 0)
		bar.model.size = 0
		correct_size(c, position, size)
	end

	return size > 0
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
	local position = position or beautiful.titlebar and beautiful.titlebar.position or "top"
	local bar = all_titlebars[c] and all_titlebars[c][position]
	if not bar then return false end

	if bar.model.size == 0 then
		titlebar.show(c, position)
	else
		titlebar.hide(c, position)
	end
end

-- Toggle titlebar view
------------------------------------------------------------
function titlebar.toggle_view(c, position)
	local position = position or beautiful.titlebar and beautiful.titlebar.position or "top"
	local bar = all_titlebars[c] and all_titlebars[c][position]
	if not bar then return false end

	if bar.model.size > 0 then
		local model_setup = bar.model.widget.widget == bar.model.light.layout and bar.model.full or bar.model.light

		bar.model.tfunction(c, model_setup.size)
		correct_size(c, position, bar.model.size - model_setup.size)
		bar.model.size = model_setup.size
		bar.model.widget:set_widget(model_setup.layout)
	end
end

-- Group windows
------------------------------------------------------------
function titlebar.set_group(cls, position)
	local position = position or beautiful.titlebar and beautiful.titlebar.position or "top"

	if not cls or #cls < 2 or not check_group_list(cls, position) then return end

	awful.layout.arrange_lock = true
    for i, c in ipairs(cls) do
		local model = all_titlebars[c][position].model
		model:set_group(cls)
		c.hidden = i ~= 1
	end

	awful.layout.arrange_lock = false
	cls[1]:emit_signal("property::geometry")
end

-- Toggle to next window in group
------------------------------------------------------------
function titlebar.toggle_group(c, position)
	local position = position or beautiful.titlebar and beautiful.titlebar.position or "top"
	local bar = all_titlebars[c] and all_titlebars[c][position]
	if not bar or not bar.model.cls then return false end

	local cid = awful.util.table.hasitem(bar.model.cls, c)
	local nid = cid % #bar.model.cls + 1

	awful.layout.arrange_lock = true
	bar.model.cls[nid].hidden = false
	bar.model.cls[nid]:swap(bar.model.cls[cid])

	awful.layout.arrange_lock = false
	bar.model.cls[cid].hidden = true
	client.focus = bar.model.cls[nid]; bar.model.cls[nid]:raise()
end

-- Destroy group
------------------------------------------------------------
function titlebar.destroy_group(c, position)
	local position = position or beautiful.titlebar and beautiful.titlebar.position or "top"
	local bar = all_titlebars[c] and all_titlebars[c][position]
	if not bar or not bar.model.cls then return false end

	for _, v in ipairs(bar.model.cls) do
		all_titlebars[v][position].model:reset()
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


-- Base example of titlebar widget
-----------------------------------------------------------------------------------------------------------------------

-- Light version
--------------------------------------------------------------------------------
function titlebar.constructor_light(c, indicators, style)
	local bar = { size = style.size }

	-- construct titlebar layout
	local layout = wibox.layout.align.horizontal()

	-- add focus icon
	local focus_layout = wibox.layout.constraint(titlebar.widget.focused(c, style), "exact")
	layout:set_middle(focus_layout)

	-- add window state icons
	local state_layout = wibox.layout.fixed.horizontal()
	for _, id in ipairs(indicators) do
		state_layout:add(ticon(c, titlebar.widget[id], style))
	end
	layout:set_right(state_layout)

	-- set margin
	local margin_layout = wibox.layout.margin(layout, unpack(style.border_margin))

	-- rotate layout if needed
	if style.position == "left" then
		bar.layout = wibox.layout.rotate(margin_layout, "east")
	elseif style.position == "right" then
		bar.layout = wibox.layout.rotate(margin_layout, "west")
	else
		bar.layout = margin_layout
	end

	return bar
end

-- Full version
--------------------------------------------------------------------------------
function titlebar.constructor_full(c, indicators, style)
	local bar = { size = style.size }

	-- Construct titlebar layout
	------------------------------------------------------------
	local layout = wibox.layout.align.horizontal()

	-- add focus icon
	local focus_layout = wibox.layout.constraint(titlebar.widget.focused(c, style), "exact", style.icon.size)
	layout:set_left(focus_layout)

	-- add title
	local middle_layout = wibox.layout.flex.horizontal()
	local titlebox = wibox.widget.textbox()
	titlebox:set_font(style.font)
	titlebox:set_align("center")

	local function update()
		local txt = awful.util.escape(c.name or "Unknown")
		titlebox:set_markup('<span color="' .. style.color.text .. '">' .. txt .. '</span>')
	end
	c:connect_signal("property::name", update)
	update()

	middle_layout:add(titlebox)
	layout:set_middle(middle_layout)

	-- add window state icons
	local state_layout = wibox.layout.fixed.horizontal()
	for _, id in ipairs(indicators) do
		state_layout:add(ticon(c, titlebar.widget[id], style))
	end
	layout:set_right(state_layout)

	-- set margin
	local margin_layout = wibox.layout.margin(layout, unpack(style.border_margin))

	-- rotate layout if needed
	if style.position == "left" then
		bar.layout = wibox.layout.rotate(margin_layout, "east")
	elseif style.position == "right" then
		bar.layout = wibox.layout.rotate(margin_layout, "west")
	else
		bar.layout = margin_layout
	end

	-- Tabbing functions
	------------------------------------------------------------

	-- show clients class in titlebar for tabbed group
	function bar:set_names(cls)
		middle_layout:reset()
		for _, v in ipairs(cls) do
			local tb = makebox(style)
			local colour = c == v and style.color.text or style.color.gray
			tb:set_markup('<span color="' .. colour .. '">' .. (v.class or "<unknown>") .. '</span>')
			middle_layout:add(tb)
		end
	end

	-- set original client name in titlebar
	function bar:reset()
		middle_layout:reset()
		middle_layout:add(titlebox)
	end

	------------------------------------------------------------
	return bar
end

-- Construct titlebar model
--------------------------------------------------------------------------------
function titlebar.model(c, indicators, lightstyle, fullstyle)
	local lightstyle = redutil.table.merge(default_style(), lightstyle or {})
	local fullstyle = redutil.table.merge(default_style(), fullstyle or {})

	-- Set two titlebar models and main widget
	------------------------------------------------------------
	local model = {}

	model.light = titlebar.constructor_light(c, indicators, lightstyle)
	model.full = titlebar.constructor_full(c, indicators, fullstyle)

	model.widget = wibox.widget.background(model.light.layout)

	-- Tabbing functions
	------------------------------------------------------------

	-- Set tab group for current client
	function model:set_group(cls)
		self.full:set_names(cls)
		self.cls = cls
		self.original = { size = self.size, layout = self.widget.widget }

		self.tfunction(c, self.full.size)
		correct_size(c, position, self.size - self.full.size)

		self.size = self.full.size
		self.widget:set_widget(self.full.layout)

		self.remover = construct_remover(c, self.position)
		c:connect_signal("unmanage", self.remover)
	end

	-- Remove client from tab group and restore titlebar
	function model:reset()
		self.full:reset()
		self.cls = nil
		c.hidden = false

		if self.remover then
			c:disconnect_signal("unmanage", self.remover)
			self.remover = nil
		end

		if self.original then
			local _, size = self.tfunction(c)

			self.tfunction(c, self.original.size)
			self.size = self.original.size
			self.widget:set_widget(self.original.layout)
			correct_size(c, self.position, size - self.original.size)
		end
	end

	------------------------------------------------------------
	return model
end

-- Config metatable to call titlebar module as function
-----------------------------------------------------------------------------------------------------------------------
function titlebar.mt:__call(...)
	return titlebar.new(...)
end

return setmetatable(titlebar, titlebar.mt)
