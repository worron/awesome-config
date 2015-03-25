-----------------------------------------------------------------------------------------------------------------------
--                                                RedFlat task widget                                                --
-----------------------------------------------------------------------------------------------------------------------
-- Widget includes label and decorative line
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
local redtask = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		width    = 40,
		line     = { width = 4, v_gap = 30 },
		font     = { font = "Sans", size = 16, face = 0, slant = 0 },
		text_gap = 22,
		counter  = { size = 12, gap = 2 },
		color    = { main = "#b1222b", gray = "#575757", icon = "#a0a0a0",
		            urgent = "#32882d", wibox = "#202020" }
	}
	return redutil.table.merge(style, redutil.check(beautiful, "gauge.task") or {})
end

-- Create a new redtask widget
-- @param style Table containing colors and geometry parameters for all elemets
-----------------------------------------------------------------------------------------------------------------------
function redtask.new(style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	local style = redutil.table.merge(default_style(), style or {})

	-- updating values
	local data = {
		state = { text = "TXT" }
	}

	-- Create custom widget
	--------------------------------------------------------------------------------
	local widg = wibox.widget.base.make_widget()

	-- User functions
	------------------------------------------------------------
	function widg:set_state(state)
		data.state = redutil.table.merge(data.state, state)
		self:emit_signal("widget::updated")
	end

	function widg:set_width(width)
		data.width = width
		self:emit_signal("widget::updated")
	end

	-- Fit
	------------------------------------------------------------
	widg.fit = function(widg, width, height)
		if data.width then
			return math.min(width, data.width), height
		else
			return width, height
		end
	end

	-- Draw
	------------------------------------------------------------
	widg.draw = function(widg, wibox, cr, width, height)

		-- label
		cr:set_source(color(data.state.minimized and style.color.gray or style.color.icon))
		redutil.cairo.set_font(cr, style.font)
		redutil.cairo.tcenter_horizontal(cr, { width / 2, style.text_gap }, data.state.text)

		-- line
		local line_color = data.state.focus and style.color.main
		                   or data.state.urgent and style.color.urgent
		                   or style.color.gray
		cr:set_source(color(line_color))
		cr:rectangle(0, style.line.v_gap, width, style.line.width)
		cr:fill()

		-- counter
		if data.state.num > 1 then
			cr:set_font_size(style.counter.size)
			local ext = cr:text_extents(tostring(data.state.num))
			cr:set_source(color(style.color.wibox))
			cr:rectangle(
				(width - ext.width) / 2 - style.counter.gap, style.line.v_gap,
				ext.width + 2 * style.counter.gap, style.counter.size
			)
			cr:fill()

			cr:set_source(color(style.color.icon))
			local coord = { width / 2, style.line.v_gap + style.counter.size / 2 }
			redutil.cairo.tcenter_horizontal(cr, coord, tostring(data.state.num))
		end
	end

	--------------------------------------------------------------------------------
	return widg
end

-- Config metatable to call redtask module as function
-----------------------------------------------------------------------------------------------------------------------
function redtask.mt:__call(...)
	return redtask.new(...)
end

return setmetatable(redtask, redtask.mt)
