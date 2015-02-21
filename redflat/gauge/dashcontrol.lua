-----------------------------------------------------------------------------------------------------------------------
--                                            RedFlat dashcontrol widget                                             --
-----------------------------------------------------------------------------------------------------------------------
-- Horizontal progresspar with stairs form
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
local dashcontrol = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		bar   = { width = 4, num = 10 },
		color = { main = "#b1222b", gray = "#404040" }
	}
	return redutil.table.merge(style, redutil.check(beautiful, "gauge.dashcontrol") or {})
end

-- Create a new dashcontrol widget
-- @param style Table containing colors and geometry parameters for all elemets
-----------------------------------------------------------------------------------------------------------------------
function dashcontrol.new(style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	local style = redutil.table.merge(default_style(), style or {})

	-- updating values
	local data = {
		value = 0
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

	-- Fit
	------------------------------------------------------------
	widg.fit = function(ret, width, height) return width, height end

	-- Draw
	------------------------------------------------------------
	widg.draw = function(widg, wibox, cr, width, height)
		local wstep = (width - style.bar.width) / (style.bar.num - 1)
		local hstep = height / style.bar.num
		local point = math.ceil(data.value * style.bar.num)

		for i = 1, style.bar.num do
			cr:set_source(color(i > point and style.color.gray or style.color.main))
			cr:rectangle((i - 1) * wstep, height, style.bar.width, - i * hstep)
			cr:fill()
		end
	end

	--------------------------------------------------------------------------------
	return widg
end

-- Config metatable to call dashcontrol module as function
-----------------------------------------------------------------------------------------------------------------------
function dashcontrol.mt:__call(...)
	return dashcontrol.new(...)
end

return setmetatable(dashcontrol, dashcontrol.mt)
