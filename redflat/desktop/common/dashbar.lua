-----------------------------------------------------------------------------------------------------------------------
--                                              RedFlat dashbar widget                                               --
-----------------------------------------------------------------------------------------------------------------------
-- Dashed progress bar indicator
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local math = math
local wibox = require("wibox")
local color = require("gears.color")
local beautiful = require("beautiful")

local redutil = require("redflat.util")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local dashbar = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		maxm        = 1,
		width       = nil,
		height      = nil,
		zero_height = 4,
		bar         = { gap = 5, width = 5 },
		autoscale   = true,
		color       = { main = "#b1222b", gray = "#404040" }
	}

	return redutil.table.merge(style, redutil.check(beautiful, "desktop.common.dashbar") or {})
end

-- Cairo drawing functions
-----------------------------------------------------------------------------------------------------------------------

local function draw_dashbar(cr, width, height, gap, first_point, last_point, fill_color)
	cr:set_source(color(fill_color))
	for i = first_point, last_point do
		cr:rectangle((i - 1) * (width + gap), 0, width, height)
	end
	cr:fill()
end

-- Create a new dashbar widget
-- @param style.bar Table containing dash parameters
-- @param style.color.main Main color
-- @param style.width Widget width (optional)
-- @param style.height Widget height (optional)
-- @param style.autoscale Scaling received values, true by default
-- @param style.maxm Scaling value if autoscale = false
-----------------------------------------------------------------------------------------------------------------------
function dashbar.new(style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	local style = redutil.table.merge(default_style(), style or {})
	local maxm = style.maxm

	-- updating values
	local data = {
		value = 0
	}

	-- Create custom widget
	--------------------------------------------------------------------------------
	local widg = wibox.widget.base.make_widget()

	function widg:set_value(x)
		if style.autoscale then
			if x > maxm then maxm = x end
		end

		local cx = x / maxm
		if cx > 1 then cx = 1 end
		data.value = cx
		self:emit_signal("widget::updated")
	end

	widg.fit = function(widg, width, height)
		return style.width or width, style.height or height
	end

	-- Draw function
	------------------------------------------------------------
	widg.draw = function(widg, wibox, cr, width, height)

		-- progressbar
		local barnum = math.floor((width + style.bar.gap) / (style.bar.width + style.bar.gap))
		local real_gap = style.bar.gap + (width - (barnum - 1) * (style.bar.width + style.bar.gap)
		                 - style.bar.width) / (barnum - 1)
		local point = math.ceil(barnum * data.value)

		draw_dashbar(cr, style.bar.width, height, real_gap, 1, point, style.color.main)
		draw_dashbar(cr, style.bar.width, height, real_gap, point + 1, barnum, style.color.gray)
	end
	--------------------------------------------------------------------------------

	return widg
end

-- Config metatable to call dashbar module as function
-----------------------------------------------------------------------------------------------------------------------
function dashbar.mt:__call(...)
	return dashbar.new(...)
end

return setmetatable(dashbar, dashbar.mt)
