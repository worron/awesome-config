-----------------------------------------------------------------------------------------------------------------------
--                                             RedFlat corners widget                                                --
-----------------------------------------------------------------------------------------------------------------------
-- Vertical progress indicator with corners shape
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local math = math
local wibox = require("wibox")
local color = require("gears.color")
--local beautiful = require("beautiful")

local redutil = require("redflat.util")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local corners = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	return {
		corner    = { num = 10, line = 5, height = 10 },
		maxm      = 1,
		width     = nil,
		height    = nil,
		autoscale = true,
		color     = { main = "#b1222b", gray = "#404040" }
	}
end

-- Cairo drawing functions
-----------------------------------------------------------------------------------------------------------------------

local function draw_corner(cr, width, height, gap, first_point, last_point, fill_color, style)
	cr:set_source(color(fill_color))
	for i = first_point, last_point do
		cr:move_to(0, height - (i - 1) * (style.corner.line + gap))
		cr:rel_line_to(width / 2, - style.corner.height)
		cr:rel_line_to(width / 2, style.corner.height)
		cr:rel_line_to(- style.corner.line, 0)
		cr:rel_line_to(- width / 2 + style.corner.line, - style.corner.height + style.corner.line)
		cr:rel_line_to(- width / 2 + style.corner.line, style.corner.height - style.corner.line)
		cr:close_path()
	end
	cr:fill()
end

-- Create a new corners widget
-- @param style.corner Table containing corner number and sizes
-- @param style.color Main color
-- @param style.width Widget width (optional)
-- @param style.height Widget height (optional)
-- @param style.autoscale Scaling received values, true by default
-- @param style.maxm Scaling value if autoscale = false
-----------------------------------------------------------------------------------------------------------------------
function corners.new(style)

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
	local cornwidg = wibox.widget.base.make_widget()

	function cornwidg:set_value(x)
		if style.autoscale then
			if x > maxm then maxm = x end
		end
		local cx = x / maxm
		if cx > 1 then cx = 1 end
		data.value = cx
		self:emit_signal("widget::updated")
	end

	cornwidg.fit = function(cornwidg, width, height)
		return style.width  or width, style.height or height
	end

	-- Draw function
	------------------------------------------------------------
	cornwidg.draw = function(cornwidg, wibox, cr, width, height)
		local corner_gap = (height - (style.corner.num - 1) * style.corner.line
		                   - style.corner.height) / (style.corner.num - 1)
		local point = math.ceil(style.corner.num * data.value)

		draw_corner(cr, width, height, corner_gap, 1, point, style.color.main, style)
		draw_corner(cr, width, height, corner_gap, point + 1, style.corner.num, style.color.gray, style)
	end

	--------------------------------------------------------------------------------
	return cornwidg
end

-- Config metatable to call corners module as function
-----------------------------------------------------------------------------------------------------------------------
function corners.mt:__call(...)
	return corners.new(...)
end

return setmetatable(corners, corners.mt)
