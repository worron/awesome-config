-----------------------------------------------------------------------------------------------------------------------
--                                      RedFlat simple line desktop widget                                           --
-----------------------------------------------------------------------------------------------------------------------
-- Multi monitoring widget
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local math = math
local string = string

local wibox = require("wibox")
local beautiful = require("beautiful")

local redutil = require("redflat.util")
local svgbox = require("redflat.gauge.svgbox")
local textbox = require("redflat.desktop.common.textbox")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local sline = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		lbox      = { draw = "by_left", width = 50 },
		rbox      = { draw = "by_right", width = 50 },
		digit_num = 3,
		icon      = nil,
		iwidth    = 120,
		unit      = { { "B", -1 }, { "KB", 1024 }, { "MB", 1024^2 }, { "GB", 1024^3 } },
		color     = { main = "#b1222b", wibox = "#161616", gray = "#404040" }
	}
	return redutil.table.merge(style, redutil.check(beautiful, "desktop.sline") or {})
end

local default_geometry = { width = 200, height = 100, x = 100, y = 100 }
local default_args = { names = {}, textadd = "", timeout = 60, sensors = {} }

-- Create a new widget
-----------------------------------------------------------------------------------------------------------------------
function sline.new(args, geometry, style)

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

	-- initialize layouts
	dwidget.item = {}
	dwidget.icon = {}
	dwidget.layout = wibox.layout.align.horizontal()
	dwidget.wibox:set_widget(dwidget.layout)

	local mid = wibox.layout.flex.horizontal()

	-- construct line
	for i, name in ipairs(args.sensors) do
		local l = textbox(string.upper(args.names[i] or "mon"), style.lbox)
		local boxlayout = wibox.layout.align.horizontal()
		dwidget.item[i] = textbox("", style.rbox)

		if style.icon then
			dwidget.icon[i] = svgbox(style.icon)
			boxlayout:set_middle(dwidget.icon[i])
		end

		boxlayout:set_left(l)
		boxlayout:set_right(dwidget.item[i])

		if i == 1 then
			dwidget.layout:set_left(wibox.layout.constraint(boxlayout, "exact", style.iwidth))
		else
			local space = wibox.layout.align.horizontal()
			space:set_right(wibox.layout.constraint(boxlayout, "exact", style.iwidth))
			mid:add(space)
		end
	end

	dwidget.layout:set_middle(mid)

	-- Update info function
	--------------------------------------------------------------------------------
	local function update()
		for i, sens in ipairs(args.sensors) do
			local state = sens.meter_function(sens.args)
			local text_color = sens.crit and state[1] > sens.crit and style.color.main or style.color.gray
			local icon_color = state.off and style.color.gray or style.color.main
			local txt = redutil.text.dformat(state[2] or state[1], style.unit, style.digit_num)

			--dwidget.item[i]:set_text(string.gsub(txt, "  ", " "))
			dwidget.item[i]:set_text(txt)
			dwidget.item[i]:set_color(text_color)
			if dwidget.icon[i] then dwidget.icon[i]:set_color(icon_color) end
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
function sline.mt:__call(...)
	return sline.new(...)
end

return setmetatable(sline, sline.mt)
