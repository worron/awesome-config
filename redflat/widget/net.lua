-----------------------------------------------------------------------------------------------------------------------
--                                               RedFlat network widget                                              --
-----------------------------------------------------------------------------------------------------------------------
-- Network speed monitoring widget
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local wibox = require("wibox")
local beautiful = require("beautiful")
local color = require("gears.color")

local redutil = require("redflat.util")
local doublebar = require("redflat.gauge.doublebar")
local tooltip = require("redflat.float.tooltip")
local system = require("redflat.system")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local net = { mt = {} }

local default_args = {
	speed     = { up = 10*1024, down = 10*1024 },
	autoscale = true,
	interface = "eth0"
}

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		widget    = doublebar.new,
		timeout   = 5,
		digit_num = 2
	}
	return redutil.table.merge(style, beautiful.widget.net or {})
end

-- Create a new network widget
-- @param args.timeout Update interval
-- @param args.interface Network interface
-- @param args.autoscale Scale bars, true by default
-- @param args.speed.up Max upload speed in bytes
-- @param args.speed.down Max download speed in bytes
-- @param style Settings for doublebar widget
-----------------------------------------------------------------------------------------------------------------------
function net.new(args, style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	local storage = {}
	local args = redutil.table.merge(default_args, args or {})
	local unit = {{  "B", 1 }, { "KB", 1024 }, { "MB", 1024^2 }, { "GB", 1024^3 }}
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
			local state = system.net_speed(args.interface, storage)

			if args.autoscale then
				if state[1] > args.speed.up then args.speed.up = state[1] end
				if state[2] > args.speed.down then args.speed.down = state[2] end
			end

			if args.alert then
				widg:set_alert(state[1] > args.alert.up or state[2] > args.alert.down)
			end

			widg:set_value({ state[2]/args.speed.down, state[1]/args.speed.up })
			tp:set_text(
				"↓" .. redutil.text.dformat(state[2], unit, style.digit_num, " ")
				.. "  ↑" .. redutil.text.dformat(state[1], unit, style.digit_num, " ")
			)
		end
	)
	t:start()
	t:emit_signal("timeout")

	--------------------------------------------------------------------------------
	return widg
end

-- Config metatable to call net module as function
-----------------------------------------------------------------------------------------------------------------------
function net.mt:__call(...)
	return net.new(...)
end

return setmetatable(net, net.mt)
