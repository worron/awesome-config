-----------------------------------------------------------------------------------------------------------------------
--                                       RedFlat speed meter deskotp widget                                          --
-----------------------------------------------------------------------------------------------------------------------
-- Network or disk i/o speed indicators
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local math = math
local string = string

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local color = require("gears.color")

local fullchart = require("redflat.desktop.common.fullchart")
local system = require("redflat.system")
local redutil = require("redflat.util")
local svgbox = require("redflat.gauge.svgbox")


-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local speedmeter = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		images           = {},
		label            = { height = 20 },
		dashbar          = { bar = { width = 10, gap = 5 }, height = 4 },
		chart            = {},
		barvalue_height  = 32,
		fullchart_height = 78,
		digit_num        = 2,
		image_gap        = 20,
		unit             = { { "B", -1 }, { "KB", 1024 }, { "MB", 1024^2 }, { "GB", 1024^3 } },
		color            = { main = "#b1222b", wibox = "#161616", gray = "#404040" }
	}
	return redutil.table.merge(style, redutil.check(beautiful, "desktop.speedmeter") or {})
end

local default_args = {
	autoscale = true,
	label = "NETWORK",
	timeout = 5,
	interface = "eth0",
	meter_function = system.net_speed
}

local default_geometry = { width = 200, height = 100, x = 100, y = 100 }
local default_maxspeed = { up = 10 * 1024, down = 10 * 1024 }


-- Support functions
-----------------------------------------------------------------------------------------------------------------------
local function set_fullchart_info(objects, label, state, style)
	for i, o in ipairs(objects) do
		o.barvalue:set_value(state[i])
		o.barvalue:set_text(label .. "  " .. redutil.text.dformat(state[i], style.unit, style.digit_num, " "))
		o.chart:set_value(state[i])
	end
end

local function colorize_icon(objects, last_state, values, crit, style)
	for i, o in ipairs(objects) do
		local st = values[i] > crit[i]
		if st ~= last_state[i] then
			o:set_color(st and style.color.main or style.color.gray)
			last_state[i] = st
		end
	end
end

-- Construct speed info elements (fullchart and icon in one layout)
--------------------------------------------------------------------------------
local function speed_line(image, maxm, el_style, style)
	local fc = fullchart(el_style.label, el_style.dashbar, el_style.chart, style.barvalue_height, maxm)
	local align = wibox.layout.align.horizontal()
	local icon

	align:set_right(fc.layout)

	if image then
		icon = svgbox(image)
		icon:set_color(style.color.gray)
		align:set_left(wibox.layout.margin(icon, 0, style.image_gap))
	end

	local layout = wibox.layout.constraint(align, "exact", nil, style.fullchart_height)
	return fc, layout, icon
end


-- Create a new speed meter widget
-----------------------------------------------------------------------------------------------------------------------
function speedmeter.new(args, geometry, style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	local dwidget = {}
	local storage = {}
	local last = {}

	local args = redutil.table.merge(default_args, args or {})
	local geometry = redutil.table.merge(default_geometry, geometry or {})
	local style = redutil.table.merge(default_style(), style or {})
	local maxspeed = redutil.table.merge(default_maxspeed, args.maxspeed or {})

	local elements_style = {
		label   = redutil.table.merge(style.label, { draw = "by_edges", color = style.color.gray }),
		dashbar = redutil.table.merge(style.dashbar, { autoscale = args.autoscale, color = style.color }),
		chart   = redutil.table.merge(style.chart, { autoscale = args.autoscale, color = style.color.gray })
	}

	-- Create wibox
	--------------------------------------------------------------------------------
	dwidget.wibox = wibox({ type = "desktop", visible = true, bg = style.color.wibox })
	dwidget.wibox:geometry(geometry)

	-- Construct indicators
	--------------------------------------------------------------------------------
	local total_align = wibox.layout.align.vertical()
	dwidget.wibox:set_widget(total_align)

	local up_widget, up_layout, up_icon = speed_line(style.images[1], maxspeed.up, elements_style, style)
	local down_widget, down_layout, down_icon = speed_line(style.images[2], maxspeed.down, elements_style, style)

	total_align:set_top(up_layout)
	total_align:set_bottom(down_layout)

	-- Update info
	--------------------------------------------------------------------------------
	local function update()
		local state = args.meter_function(args.interface, storage)

		set_fullchart_info({ up_widget, down_widget }, args.label, state, style)

		if style.images and args.crit then
			colorize_icon({ up_icon, down_icon }, last, state, { args.crit.up, args.crit.down }, style)
		end
	end

	-- Set update timer
	--------------------------------------------------------------------------------
	local t = timer({ timeout = args.timeout })
	t:connect_signal("timeout", update)
	t:start()
	t:emit_signal("timeout")

	--------------------------------------------------------------------------------
	return dwidget
end

-- Config metatable to call module as function
-----------------------------------------------------------------------------------------------------------------------
function speedmeter.mt:__call(...)
	return speedmeter.new(...)
end

return setmetatable(speedmeter, speedmeter.mt)
