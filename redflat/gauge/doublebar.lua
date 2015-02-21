-----------------------------------------------------------------------------------------------------------------------
--                                            RedFlat doublebar widget                                               --
-----------------------------------------------------------------------------------------------------------------------
-- Gauge wigget with two vertical progressbar
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local wibox = require("wibox")
local beautiful = require("beautiful")
local color = require("gears.color")

local redutil = require("redflat.util")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local doublebar = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		line  = { width = 4, gap = 5 },
		v_gap = 8,
		color = { main = "#b1222b", gray = "#575757" }
	}
	return redutil.table.merge(style, redutil.check(beautiful, "gauge.doublebar") or {})
end

-- Create a new doublebar widget
-- @param style Table containing colors and geometry parameters for all elemets
-----------------------------------------------------------------------------------------------------------------------
function doublebar.new(style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	local style = redutil.table.merge(default_style(), style or {})

	-- updating values
	local data = {
		value = {0, 0}
	}

	-- Create custom widget
	--------------------------------------------------------------------------------
	local widg = wibox.widget.base.make_widget()

	-- User functions
	------------------------------------------------------------
	function widg:set_value(value)
		data.value = { value[1] < 1 and value[1] or 1, value[2] < 1 and value[2] or 1 }
		self:emit_signal("widget::updated")
		return self
	end

	-- Fit
	------------------------------------------------------------
	widg.fit = function(widg, width, height)
		local width = 2 * style.line.width + style.line.gap
		return width, height
	end

	-- Draw
	------------------------------------------------------------
	widg.draw = function(widg, wibox, cr, width, height)
		local bar_height = height - 2*style.v_gap

		cr:set_source(color(style.color.gray))
		cr:rectangle(0, style.v_gap, style.line.width, bar_height)
		cr:rectangle(width - style.line.width, style.v_gap, style.line.width, bar_height)
		cr:fill()

		cr:set_source(color(style.color.main))
		cr:rectangle(0, height - style.v_gap, style.line.width, - bar_height * data.value[1])
		cr:rectangle(width - style.line.width, height - style.v_gap, style.line.width, - bar_height * data.value[2])
		cr:fill()
	end

	--------------------------------------------------------------------------------
	return widg
end

-- Config metatable to call doublebar module as function
-----------------------------------------------------------------------------------------------------------------------
function doublebar.mt:__call(...)
	return doublebar.new(...)
end

return setmetatable(doublebar, doublebar.mt)
