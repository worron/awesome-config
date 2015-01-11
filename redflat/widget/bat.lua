-----------------------------------------------------------------------------------------------------------------------
--                                                RedFlat battery widget                                             --
-----------------------------------------------------------------------------------------------------------------------
-- Battery level monitoring widget
-----------------------------------------------------------------------------------------------------------------------
-- Some code was taken from
------ vicious batwidget
------ (c) 2010, Adrian C. <anrxc@sysphere.org
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local wibox = require("wibox")
local beautiful = require("beautiful")
local color = require("gears.color")

local redutil = require("redflat.util")
local monitor = require("redflat.gauge.monitor")
local tooltip = require("redflat.float.tooltip")
local system = require("redflat.system")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local bat = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {}
	return redutil.table.merge(style, beautiful.widget.bat or {})
end

-- Create a new battery widget
-- @param args.timeout Update interval
-- @param args.width Widget width
-- @param args.batt Battery name
-- @param style Settings for monitor widget
-----------------------------------------------------------------------------------------------------------------------
function bat.new(args, style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	local args = args or {}
	local crit = args.crit or 0.15
	local timeout = args.timeout or 120
	local batt = args.batt or "BAT0"

	local style = redutil.table.merge(default_style(), style or {})

	-- Create monitor widget
	--------------------------------------------------------------------------------
	local widg = monitor(style.monitor)
	widg:set_label("BAT")
	if args.width then widg:set_width(args.width) end

	-- Set tooltip
	--------------------------------------------------------------------------------
	local tp = tooltip({ widg }, style.tooltip)

	-- Set update timer
	--------------------------------------------------------------------------------
	local t = timer({ timeout = timeout })
	t:connect_signal("timeout",
		function()
			local state = system.battery(batt)
			widg:set_value(state[2]/100)
			widg:set_alert(state[2]/100 < crit)
			tp:set_text(state[1].."  "..state[2].."%  "..state[3])
		end
	)
	t:start()
	t:emit_signal("timeout")

	--------------------------------------------------------------------------------
	return widg
end

-- Config metatable to call bat module as function
-----------------------------------------------------------------------------------------------------------------------
function bat.mt:__call(...)
	return bat.new(...)
end

return setmetatable(bat, bat.mt)
