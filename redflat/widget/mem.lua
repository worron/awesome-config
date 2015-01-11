-----------------------------------------------------------------------------------------------------------------------
--                                                RedFlat memory widget                                              --
-----------------------------------------------------------------------------------------------------------------------
-- Memory usage monitoring widget
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local wibox = require("wibox")
local beautiful = require("beautiful")
local color = require("gears.color")

local monitor = require("redflat.gauge.monitor")
local tooltip = require("redflat.float.tooltip")
local system = require("redflat.system")
local redutil = require("redflat.util")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local mem = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {}
	return redutil.table.merge(style, beautiful.widget.mem or {})
end

-- Create a new memory monitor widget
-- @param args.timeout Update interval
-- @param args.width Widget width
-- @param style Settings for monitor widget
-----------------------------------------------------------------------------------------------------------------------
function mem.new(args, style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	local args = args or {}
	local crit = args.crit or 0.8
	local timeout = args.timeout or 5

	local style = redutil.table.merge(default_style(), style or {})

	-- Create monitor widget
	--------------------------------------------------------------------------------
	local widg = monitor(style.monitor)
	widg:set_label("RAM")
	if args.width then widg:set_width(args.width) end

	-- Set tooltip
	--------------------------------------------------------------------------------
	local tp = tooltip({ widg }, style.tooltip)

	-- Set update timer
	--------------------------------------------------------------------------------
	local t = timer({ timeout = timeout })
	t:connect_signal("timeout",
		function()
			local usage = system.memory_info().usep
			widg:set_value(usage/100)
			widg:set_alert(usage/100 > crit)
			tp:set_text(usage.."%")
		end
	)
	t:start()
	t:emit_signal("timeout")

	--------------------------------------------------------------------------------
	return widg
end

-- Config metatable to call mem module as function
-----------------------------------------------------------------------------------------------------------------------
function mem.mt:__call(...)
	return mem.new(...)
end

return setmetatable(mem, mem.mt)
