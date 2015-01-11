-----------------------------------------------------------------------------------------------------------------------
--                                              RedFlat barvalue widget                                              --
-----------------------------------------------------------------------------------------------------------------------
-- Complex indicator with progress bar and label on top of it
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local math = math
local string = string
local wibox = require("wibox")
local color = require("gears.color")
--local beautiful = require("beautiful")

local redutil = require("redflat.util")
local dcommon = require("redflat.desktop.common")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local barvalue = { mt = {} }

-- Create a new barvalue widget
-- @param dashbar_style Style variables for redflat dashbar
-- @param label_style Style variables for redflat textbox
-----------------------------------------------------------------------------------------------------------------------
function barvalue.new(dashbar_style, label_style)

	local widg = {}

	-- construct layout with indicators
	widg.layout = wibox.layout.fixed.vertical()
	local align_vertical = wibox.layout.align.vertical()
	widg.layout:add(align_vertical)

	local progressbar = dcommon.dashbar(dashbar_style)
	local label = dcommon.textbox(nil, label_style)
	align_vertical:set_bottom(progressbar)
	align_vertical:set_top(label)

	-- setup functions
	function widg:set_text(text)
		label:set_text(text)
	end

	function widg:set_value(x)
		progressbar:set_value(x)
	end

	return widg
end

-- Config metatable to call barvalue module as function
-----------------------------------------------------------------------------------------------------------------------
function barvalue.mt:__call(...)
	return barvalue.new(...)
end

return setmetatable(barvalue, barvalue.mt)
