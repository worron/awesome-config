
--                                                   RedFlat tag widget                                              --
-----------------------------------------------------------------------------------------------------------------------
-- Custom widget to display tag info
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local math = math

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local color = require("gears.color")

local redutil = require("redflat.util")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local redtag = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		width    = 80,
		font     = { font = "Sans", size = 16, face = 0, slant = 0 },
		text_gap = 32,
		point    = { height = 4, gap = 8, dx = 6, width = 40 },
		show_min = false,
		color    = { main   = "#b1222b", gray = "#575757", icon = "#a0a0a0", urgent = "#32882d",
		             wibox = "#202020" }
	}

	return redutil.table.merge(style, redutil.check(beautiful, "gauge.bluetag") or {})
end

-- Support functions
-----------------------------------------------------------------------------------------------------------------------

-- Create a new tag widget
-- @param style Table containing colors and geometry parameters for all elemets
-----------------------------------------------------------------------------------------------------------------------
function redtag.new(style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	local style = redutil.table.merge(default_style(), style or {})

	-- updating values
	local data = {
		state = { text = "TEXT" },
		width = style.width or nil
	}

	-- Create custom widget
	--------------------------------------------------------------------------------
	local widg = wibox.widget.base.make_widget()

	-- User functions
	------------------------------------------------------------
	function widg:set_state(state)
		data.state = awful.util.table.clone(state)
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

		-- text
		cr:set_source(color(data.state.active and style.color.main or style.color.icon))
		redutil.cairo.set_font(cr, style.font)
		redutil.cairo.tcenter_horizontal(cr, { width/2, style.text_gap }, data.state.text)

		-- occupied mark
		local n = #data.state.list
		local x = (width - style.point.width) / 2

		if n > 0 then
			local l = (style.point.width - (n - 1) * style.point.dx) / n

			for i = 1, n do
				local cl = data.state.list[i].focus and style.color.main or
				           data.state.list[i].urgent and style.color.urgent or
				           data.state.list[i].minimized and style.show_min and style.color.gray or
				           style.color.icon
				cr:set_source(color(cl))
				cr:rectangle(x + (i - 1) * (style.point.dx + l), style.point.gap, l, style.point.height)
				cr:fill()
			end
		else
			cr:set_source(color(style.color.gray))
			cr:rectangle((width - style.point.width) / 2, style.point.gap, style.point.width, style.point.height)
			cr:fill()
		end
	end

	--------------------------------------------------------------------------------
	return widg
end

-- Config metatable to call redtag module as function
-----------------------------------------------------------------------------------------------------------------------
function redtag.mt:__call(...)
	return redtag.new(...)
end

return setmetatable(redtag, redtag.mt)
