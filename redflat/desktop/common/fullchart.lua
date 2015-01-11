-----------------------------------------------------------------------------------------------------------------------
--                                             RedFlat fullchart widget                                              --
-----------------------------------------------------------------------------------------------------------------------
-- Complex indicator with history chart, progress bar and label
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local color = require("gears.color")

local dcommon = require("redflat.desktop.common")
local redutil = require("redflat.util")


-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local fullchart = { mt = {} }

-- Create a new fullchart widget
-- @param label_style Style variables for redflat textbox widget
-- @param dashbar_style Style variables for redflat dashbar widget
-- @param chart_style Style variables for redflat chart widget
-- @param barvalue_height Height for barvalue widget
-- @param maxm Maximum value for redflat dashbar and chart (optional)
-----------------------------------------------------------------------------------------------------------------------
function fullchart.new(label_style, dashbar_style, chart_style, barvalue_height, maxm)

	local widg = {}
	local chart_style = redutil.table.merge(chart_style, { maxm = maxm })
	local dashbar_style = redutil.table.merge(dashbar_style, { maxm = maxm })

	-- construct layout with indicators
	widg.layout = wibox.layout.fixed.vertical()
	local align_vertical = wibox.layout.align.vertical()
	widg.layout:add(align_vertical)

	widg.barvalue = dcommon.barvalue(dashbar_style, label_style)
	widg.chart = dcommon.chart(chart_style)
	local bv_const = wibox.layout.constraint(widg.barvalue.layout, "exact", nil, barvalue_height)

	align_vertical:set_top(bv_const)
	align_vertical:set_bottom(widg.chart)

	return widg
end

-- Config metatable to call fullchart module as function
-----------------------------------------------------------------------------------------------------------------------
function fullchart.mt:__call(...)
	return fullchart.new(...)
end

return setmetatable(fullchart, fullchart.mt)
