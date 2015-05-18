-----------------------------------------------------------------------------------------------------------------------
--                                             RedFlat monitor widget                                                --
-----------------------------------------------------------------------------------------------------------------------
-- Widget with label and progressbar
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local math = math
local wibox = require("wibox")
local beautiful = require("beautiful")
local color = require("gears.color")

local redutil = require("redflat.util")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local monitor = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		line     = { width = 4, v_gap = 30 },
		font     = { font = "Sans", size = 16, face = 0, slant = 0 },
		text_gap = 22,
		label    = "MON",
		width    = nil,
		color    = { main = "#b1222b", gray = "#575757", icon = "#a0a0a0" }
	}
	return redutil.table.merge(style, redutil.check(beautiful, "gauge.monitor") or {})
end

-- Create a new monitor widget
-- @param style Table containing colors and geometry parameters for all elemets
-----------------------------------------------------------------------------------------------------------------------
function monitor.new(style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	local style = redutil.table.merge(default_style(), style or {})

	-- updating values
	local data = {
		value = 0,
		label = style.label,
		width = style.width,
		color = style.color.icon
	}

	-- Create custom widget
	--------------------------------------------------------------------------------
	local widg = wibox.widget.base.make_widget()

	-- User functions
	------------------------------------------------------------
	function widg:set_value(x)
		data.value = x < 1 and x or 1
		self:emit_signal("widget::updated")
	end

	function widg:set_label(t)
		data.label = t
		self:emit_signal("widget::updated")
	end

	function widg:set_width(width)
		data.width = width
		self:emit_signal("widget::updated")
	end

	function widg:set_alert(alert)
		data.color = alert and style.color.main or style.color.icon
		self:emit_signal("widget::updated")
	end

	-- Fit
	------------------------------------------------------------
	widg.fit = function(widg, width, height)
		if data.width then
			return data.width, height
		else
			local size = math.min(width, height)
			return size, size
		end
	end

	-- Draw
	------------------------------------------------------------
	widg.draw = function(widg, wibox, cr, width, height)

		-- label
		cr:set_source(color(data.color))
		redutil.cairo.set_font(cr, style.font)
		redutil.cairo.tcenter_horizontal(cr, { width/2, style.text_gap }, data.label)

		-- progressbar
		local wd = { width, width * data.value }
		for i = 1, 2 do
			cr:set_source(color(i > 1 and style.color.main or style.color.gray))
			cr:rectangle(0, style.line.v_gap, wd[i], style.line.width)
			cr:fill()
		end
	end

	--------------------------------------------------------------------------------
	return widg
end

-- Config metatable to call monitor module as function
-----------------------------------------------------------------------------------------------------------------------
function monitor.mt:__call(...)
	return monitor.new(...)
end

return setmetatable(monitor, monitor.mt)
