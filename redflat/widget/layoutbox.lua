-----------------------------------------------------------------------------------------------------------------------
--                                            RedFlat layoutbox widget                                               --
-----------------------------------------------------------------------------------------------------------------------
-- Paintbox widget used to display layout
-- Layouts menu added
-----------------------------------------------------------------------------------------------------------------------
-- Some code was taken from
------ awful.widget.layoutbox v3.5.2
------ (c) 2009 Julien Danjou
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local ipairs = ipairs
local table = table
local awful = require("awful")
local wibox = require("wibox")
local layout = require("awful.layout")
local beautiful = require("beautiful")

local redmenu = require("redflat.menu")
local tooltip = require("redflat.float.tooltip")
local redutil = require("redflat.util")
local svgbox = require("redflat.gauge.svgbox")


-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local layoutbox = { mt = {} }

local last_tag = nil

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		icon       = {},
		micon      = {},
		name_alias = {},
		color      = { icon = "#a0a0a0" }
	}
	return redutil.table.merge(style, redutil.check(beautiful, "widget.layoutbox") or {})
end

-- Initialize layoutbox
-----------------------------------------------------------------------------------------------------------------------
function layoutbox:init(layouts, style)

	-- Set tooltip
	------------------------------------------------------------
	layoutbox.tp = tooltip({}, style.tooltip)

	-- Construct layout list
	------------------------------------------------------------
	local items = {}
	for _, l in ipairs(layouts) do
		local layout_name = layout.getname(l)
		local icon = style.icon[layout_name] or style.icon.unknown
		local text = style.name_alias[layout_name] or layout_name
		table.insert(items, { text, function() layout.set (l, last_tag) end, icon, style.micon.blank })
	end

	-- Update tooltip function
	------------------------------------------------------------
	function self:update_tooltip(layout_name)
		layoutbox.tp:set_text(style.name_alias[layout_name] or layout_name)
	end

	-- Update menu function
	------------------------------------------------------------
	function self:update_menu(t)
		cl = awful.tag.getproperty(t, "layout")
		for i, l in ipairs(layouts) do
			local mark = cl == l and style.micon.check or style.micon.blank
			if self.menu.items[i].right_icon then
				self.menu.items[i].right_icon:set_image(mark)
			end
		end
	end

	-- Initialize menu
	------------------------------------------------------------
	self.menu = redmenu({ hide_timeout = 1, theme = style.menu, items = items })
end

-- Widget update function
-----------------------------------------------------------------------------------------------------------------------
local function update(w, screen, style)
	local layout = layout.getname(layout.get(screen))
	w:set_image(style.icon[layout] or style.icon.unknown)
	layoutbox:update_tooltip(layout)

	if layoutbox.menu.wibox.visible then
		layoutbox:update_menu(last_tag)
	end
end

-- Show layout menu
-----------------------------------------------------------------------------------------------------------------------
function layoutbox:toggle_menu(t)
	if self.menu.wibox.visible and t == last_tag then
		self.menu:hide()
	else
		if self.menu.wibox.visible then self.menu.wibox.visible = false end
		awful.placement.under_mouse(self.menu.wibox)
		awful.placement.no_offscreen(self.menu.wibox)

		last_tag = t
		self.menu:show({coords = {x = self.menu.wibox.x, y = self.menu.wibox.y}})
		self:update_menu(last_tag)
	end
end

-- Create a layoutbox widge
-- @param screen The screen number that the layout will be represented for
-- @param layouts List of layouts
-----------------------------------------------------------------------------------------------------------------------
function layoutbox.new(args)

	-- Initialize vars
	--------------------------------------------------------------------------------
	local screen = args.screen or 1
	local style = redutil.table.merge(default_style(), style or {})
	local w = svgbox()
	w:set_color(style.color.icon)

	if not layoutbox.menu then layoutbox:init(args.layouts, style) end

	-- Set tooltip
	--------------------------------------------------------------------------------
	layoutbox.tp:add_to_object(w)

	-- Set signals
	--------------------------------------------------------------------------------
	local function update_on_tag_selection(t)
		return update(w, awful.tag.getscreen(t), style)
	end

	awful.tag.attached_connect_signal(screen, "property::selected", update_on_tag_selection)
	awful.tag.attached_connect_signal(screen, "property::layout", update_on_tag_selection)
	--w:connect_signal("mouse::leave", function() layoutbox.menu.hidetimer:start() end)

	--------------------------------------------------------------------------------
	update(w, screen, style)
	return w
end

-- Config metatable to call layoutbox module as function
-----------------------------------------------------------------------------------------------------------------------
function layoutbox.mt:__call(...)
	return layoutbox.new(...)
end

return setmetatable(layoutbox, layoutbox.mt)
