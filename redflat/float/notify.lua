-----------------------------------------------------------------------------------------------------------------------
--                                                RedFlat notify widget                                              --
-----------------------------------------------------------------------------------------------------------------------
-- Floating widget with icon, text, and progress bar
-- special for volume and brightness indication
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local unpack = unpack
local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local color = require("gears.color")

local redutil = require("redflat.util")
local svgbox = require("redflat.gauge.svgbox")
local progressbar = require("redflat.gauge.progressbar")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local notify = {}

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		geometry        = { width = 480, height = 100, x =1424, y = 16 },
		screen_gap      = 0,
		border_margin   = { 20, 20, 20, 20 },
		elements_margin = { 20, 0, 2, 10 },
		bar_width       = 8,
		font            = "Sans 14",
		border_width    = 2,
		icon            = nil,
		color           = { border = "#575757", icon = "#aaaaaa", wibox = "#202020" }
	}
	return redutil.table.merge(style, beautiful.float.notify or {})
end

-- Initialize notify widget
-----------------------------------------------------------------------------------------------------------------------
function notify:init()

	local style = default_style()
	local hide_timeout = beautiful.notify_timeout or 5
	local icon = style.icon

	-- Construct layouts
	--------------------------------------------------------------------------------
	local area = wibox.layout.fixed.horizontal()

	local bar = progressbar(style.progressbar)
	local image = svgbox()
	local text = wibox.widget.textbox("100%")
	text:set_align("center")
	text:set_font(style.font)

	local align_vertical = wibox.layout.align.vertical()
	align_vertical:set_top(text)
	align_vertical:set_bottom(wibox.layout.constraint(bar, "exact", nil, style.bar_width))

	area:add(image)
	area:add(wibox.layout.margin(align_vertical, unpack(style.elements_margin)))

	-- Create floating wibox for notify widget
	--------------------------------------------------------------------------------
	self.wibox = wibox({
		ontop        = true,
		bg           = style.color.wibox,
		border_width = style.border_width,
		border_color = style.color.border
	})

	self.wibox:set_widget(wibox.layout.margin(area, unpack(style.border_margin)))
	self.wibox:geometry(style.geometry)
	redutil.placement.no_offscreen(self.wibox, style.screen_gap)

	-- Set info function
	--------------------------------------------------------------------------------
	function self:set(args)
		local args = args or {}

		if args.value then bar:set_value(args.value) end
		if args.text then text:set_text(args.text) end

		if args.icon then
			image:set_image(args.icon)
			image:set_color(style.color.icon)
		end
	end

	-- Set autohide timer
	--------------------------------------------------------------------------------
	self.hidetimer = timer({ timeout = hide_timeout })
	self.hidetimer:connect_signal("timeout", function() self:hide() end)

	-- Signals setup
	--------------------------------------------------------------------------------
	self.wibox:connect_signal("mouse::enter", function() self:hide() end)
end

-- Hide notify widget
-----------------------------------------------------------------------------------------------------------------------
function notify:hide()
	self.wibox.visible = false
	self.hidetimer:stop()
end

-- Show notify widget
-----------------------------------------------------------------------------------------------------------------------
function notify:show(args)
	if not self.wibox then self:init() end
	self:set(args)
	if not self.wibox.visible then self.wibox.visible = true end
	self.hidetimer:stop()
	self.hidetimer:start()
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return notify
