-----------------------------------------------------------------------------------------------------------------------
--                                        RedFlat volume indicator widget                                            --
-----------------------------------------------------------------------------------------------------------------------
-- Indicator with audio icon
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
local audio = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		icon  = {},
		color = { main = "#b1222b", icon = "#a0a0a0", mute = "#404040" }
	}
	return redutil.table.merge(style, redutil.check(beautiful, "gauge.redaudio") or {})
end

-- Support functions
-----------------------------------------------------------------------------------------------------------------------
local function pattern_string(height, value, c1, c2)
	return string.format("linear:0,%s:0,0:0,%s:%s,%s:%s,%s:1,%s", height, c1, value, c1, value, c2, c2)
end

-- Create a new audio widget
-- @param style Table containing colors and geometry parameters for all elemets
-----------------------------------------------------------------------------------------------------------------------
function audio.new(style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	local style = redutil.table.merge(default_style(), style or {})

	-- Icon widgets
	------------------------------------------------------------
	local icon = {}
	icon.ready = svgbox(style.icon.ready)
	icon.ready:set_color(style.color.icon)
	icon.mute = svgbox(style.icon.mute)
	icon.mute:set_color(style.color.mute)

	-- Create widget
	--------------------------------------------------------------------------------
	local widg = wibox.widget.background(icon.ready)

	-- User functions
	------------------------------------------------------------
	function widg:set_value(x)
		if x > 1 then x = 1 end

		if self.widget._image then
			local h = self.widget._image.height
			icon.ready:set_color(pattern_string(h, x, style.color.main, style.color.icon))
		end
	end

	function widg:set_mute(mute)
		widg:set_widget(mute and icon.mute or icon.ready)
	end

	--------------------------------------------------------------------------------
	return widg
end

-- Config metatable to call audio module as function
-----------------------------------------------------------------------------------------------------------------------
function audio.mt:__call(...)
	return audio.new(...)
end

return setmetatable(audio, audio.mt)
