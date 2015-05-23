-----------------------------------------------------------------------------------------------------------------------
--                                           RedFlat indicator widget                                                --
-----------------------------------------------------------------------------------------------------------------------
-- Image indicator
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local math = math
local string = string
local wibox = require("wibox")
local beautiful = require("beautiful")
local color = require("gears.color")

local redutil = require("redflat.util")
local svgbox = require("redflat.gauge.svgbox")


-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local gicon = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		icon        = nil,
		is_vertical = false,
		color       = { main = "#b1222b", icon = "#a0a0a0", urgent = "#32882d" }
	}
	return redutil.table.merge(style, redutil.check(beautiful, "gauge.gicon") or {})
end

-- Support functions
-----------------------------------------------------------------------------------------------------------------------
local function pattern_string_v(height, value, c1, c2)
	return string.format("linear:0,%s:0,0:0,%s:%s,%s:%s,%s:1,%s", height, c1, value, c1, value, c2, c2)
end

local function pattern_string_h(width, value, c1, c2)
	return string.format("linear:0,0:%s,0:0,%s:%s,%s:%s,%s:1,%s", width, c1, value, c1, value, c2, c2)
end

-- Create a new gicon widget
-- @param style Table containing colors and geometry parameters for all elemets
-----------------------------------------------------------------------------------------------------------------------
function gicon.new(style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	local style = redutil.table.merge(default_style(), style or {})
	local pattern = style.is_vertical and pattern_string_v or pattern_string_h

	local data = {
		color = style.color.main
	}

	-- Create widget
	--------------------------------------------------------------------------------
	local widg = svgbox(style.icon)

	-- User functions
	------------------------------------------------------------
	function widg:set_value(x)
		if x > 1 then x = 1 end

		if self._image then
			local d = style.is_vertical and self._image.height or self._image.width
			widg:set_color(pattern(d, x, data.color, style.color.icon))
		end
	end

	function widg:set_alert(alert)
		data.color = alert and style.color.urgent or style.color.main
	end

	--------------------------------------------------------------------------------
	return widg
end

-- Config metatable to call gicon module as function
-----------------------------------------------------------------------------------------------------------------------
function gicon.mt:__call(...)
	return gicon.new(...)
end

return setmetatable(gicon, gicon.mt)
