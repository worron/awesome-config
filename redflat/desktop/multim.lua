-----------------------------------------------------------------------------------------------------------------------
--                                     RedFlat multi monitoring deskotp widget                                       --
-----------------------------------------------------------------------------------------------------------------------
-- Multi monitoring widget
-- Pack of corner indicators and two lines with dashbar, label and text
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local math = math
local string = string
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

local dcommon = require("redflat.desktop.common")
local system = require("redflat.system")
local redutil = require("redflat.util")
local svgbox = require("redflat.gauge.svgbox")
local asyncshell = require("redflat.asyncshell")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local multim = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		barpack      = {},
		corner       = { width = 40 },
		state_height = 60,
		digit_num    = 3,
		prog_height  = 100,
		image_gap    = 20,
		unit         = { { "MB", - 1 }, { "GB", 1024 } },
		color        = { main = "#b1222b", wibox = "#161616", gray = "#404040" }
	}
	return redutil.table.merge(style, redutil.check(beautiful, "desktop.multim") or {})
end

local default_geometry = { width = 200, height = 100, x = 100, y = 100 }
local default_args = {
	corners = { num = 1, maxm = 1},
	lines   = { maxm = 1 },
	meter   = { func = system.dformatted.cpumem },
	timeout = 60,
}

-- Support functions
-----------------------------------------------------------------------------------------------------------------------
local function set_info(value, args, corners, lines, icon, last_state, style)
	local corners_alert = value.alert

	-- set dashbar values and color
	for i, line in ipairs(args.lines) do
		lines:set_values(value.lines[i][1] / line.maxm, i)
		lines:set_text(redutil.text.dformat(value.lines[i][2], line.unit or style.unit, style.digit_num), i)

		if line.crit then
			lines:set_text_color(value.lines[i][1] > line.crit and style.color.main or style.color.gray, i)
		end
	end

	-- set corners value
	for i = 1, args.corners.num do
		local v = value.corners[i] or 0
		corners:set_values(v / args.corners.maxm, i)
		if args.corners.crit then corners_alert = corners_alert or v > args.corners.crit end
	end

	-- colorize icon if needed
	if style.image and corners_alert ~= last_state then
		icon:set_color(corners_alert and style.color.main or style.color.gray)
		last_state = corners_alert
	end
end


-- Create a new widget
-----------------------------------------------------------------------------------------------------------------------
function multim.new(args, geometry, style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	local dwidget = {}
	local icon
	local last_state = nil

	local args = redutil.table.merge(default_args, args or {})
	local geometry = redutil.table.merge(default_geometry, geometry or {})
	local style = redutil.table.merge(default_style(), style or {})

	local barpack_style = redutil.table.merge(style.barpack, { dashbar = { color = style.color } })
	local corner_style = redutil.table.merge(style.corner, { color = style.color })

	-- Create wibox
	--------------------------------------------------------------------------------
	dwidget.wibox = wibox({ type = "desktop", visible = true, bg = style.color.wibox })
	dwidget.wibox:geometry(geometry)

	-- Construct layouts
	--------------------------------------------------------------------------------
	local total_align = wibox.layout.align.vertical()

	local lines = dcommon.barpack(#args.lines, barpack_style)
	local corners = dcommon.cornerpack(args.corners.num, corner_style)

	local corners_align = wibox.layout.align.horizontal()
	corners_align:set_right(corners.layout)

	if style.image then
		icon = svgbox(style.image)
		icon:set_color(style.color.gray)
		corners_align:set_left(wibox.layout.margin(icon, 0, style.image_gap))
	end

	local lines_layout = wibox.layout.constraint(lines.layout, "exact", nil, style.state_height)
	local corners_layout = wibox.layout.constraint(corners_align, "exact", nil, style.prog_height)

	total_align:set_top(corners_layout)
	total_align:set_bottom(lines_layout)
	dwidget.wibox:set_widget(total_align)

	-- Update info function
	--------------------------------------------------------------------------------
	local function get_and_set(source)
		local state = args.meter.func(source)
		set_info(state, args, corners, lines, icon, last_state, style)
	end

	local function update_plain()
		get_and_set(args.meter.args)
	end

	local function update_asyncshell()
		asyncshell.request(args.asyncshell, get_and_set, args.timeout)
	end

	local update = args.asyncshell and update_asyncshell or update_plain

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
function multim.mt:__call(...)
	return multim.new(...)
end

return setmetatable(multim, multim.mt)
