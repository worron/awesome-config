-----------------------------------------------------------------------------------------------------------------------
--                                                 RedFlat sysmon widget                                             --
-----------------------------------------------------------------------------------------------------------------------
-- Monitoring widget
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local wibox = require("wibox")
local beautiful = require("beautiful")
local util = require("awful.util")

local monitor = require("redflat.gauge.monitor")
local tooltip = require("redflat.float.tooltip")
local system = require("redflat.system")
local redutil = require("redflat.util")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local sysmon = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		timeout = 5,
		width   = nil,
		widget = monitor.new
	}
	return redutil.table.merge(style, redutil.check(beautiful, "widget.sysmon") or {})
end

-- Create a new cpu monitor widget
-----------------------------------------------------------------------------------------------------------------------
function sysmon.new(args, style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	local args = args or {}
	local style = redutil.table.merge(default_style(), style or {})

	-- Create monitor widget
	--------------------------------------------------------------------------------
	local widg = style.widget(style.monitor)

	-- Set tooltip
	--------------------------------------------------------------------------------
	local tp = tooltip({ widg }, style.tooltip)

	-- Set update timer
	--------------------------------------------------------------------------------
	local t = timer({ timeout = style.timeout })
	t:connect_signal("timeout",
		function()
			local state = args.func(args.arg)
			widg:set_value(state.value)
			widg:set_alert(state.alert)
			tp:set_text(state.text)
		end
	)
	t:start()
	t:emit_signal("timeout")

	--------------------------------------------------------------------------------
	return widg
end

-- Config metatable to call module as function
-----------------------------------------------------------------------------------------------------------------------
function sysmon.mt:__call(...)
	return sysmon.new(...)
end

return setmetatable(sysmon, sysmon.mt)
