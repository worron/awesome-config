-----------------------------------------------------------------------------------------------------------------------
--                                         RedFlat dashpack desktop widget                                           --
-----------------------------------------------------------------------------------------------------------------------
-- Multi monitoring widget
-- Several lines with dashbar, label and text
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local math = math
local string = string

local wibox = require("wibox")
local beautiful = require("beautiful")

local redutil = require("redflat.util")
local barpack = require("redflat.desktop.common.barpack")
local system = require("redflat.system")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local dashpack = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		show_text = false,
		barpack   = {},
		digit_num = 3,
		unit      = { { "B", -1 }, { "KB", 1024 }, { "MB", 1024^2 }, { "GB", 1024^3 } },
		color     = { main = "#b1222b", wibox = "#161616", gray = "#404040" }
	}
	return redutil.table.merge(style, redutil.check(beautiful, "desktop.dashpack") or {})
end

local default_geometry = { width = 200, height = 100, x = 100, y = 100 }
local default_args = { names = {}, textadd = "", timeout = 60, sensors = {} }

-- Create a new widget
-----------------------------------------------------------------------------------------------------------------------
function dashpack.new(args, geometry, style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	local dwidget = {}
	local args = redutil.table.merge(default_args, args or {})
	local geometry = redutil.table.merge(default_geometry, geometry or {})
	local style = redutil.table.merge(default_style(), style or {})

	-- Create wibox
	--------------------------------------------------------------------------------
	dwidget.wibox = wibox({ type = "desktop", visible = true, bg = style.color.wibox })
	dwidget.wibox:geometry(geometry)

	-- initialize bar lines
	local pack = barpack(#args.sensors, style.barpack)
	dwidget.wibox:set_widget(pack.layout)

	for i, name in ipairs(args.names) do
		pack:set_label(string.upper(name), i)
	end

	-- Update info function
	--------------------------------------------------------------------------------
	local function update()
		for i, sens in ipairs(args.sensors) do
			local state = sens.meter_function(sens.args)
			local text_color = sens.crit and state[1] > sens.crit and style.color.main or style.color.gray

			pack:set_values(state[1] / sens.maxm, i)
			pack:set_label_color(text_color, i)

			if style.show_text then
				pack:set_text(redutil.text.dformat(state[2] or state[1], style.unit, style.digit_num), i)
				pack:set_text_color(text_color, i)
			end
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
function dashpack.mt:__call(...)
	return dashpack.new(...)
end

return setmetatable(dashpack, dashpack.mt)
