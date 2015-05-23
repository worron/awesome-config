-----------------------------------------------------------------------------------------------------------------------
--                                             RedFlat doublemonitor widget                                          --
-----------------------------------------------------------------------------------------------------------------------
-- Widget with two progressbar and icon
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local math = math
local wibox = require("wibox")
local beautiful = require("beautiful")
local color = require("gears.color")

local redutil = require("redflat.util")
local svgbox = require("redflat.gauge.svgbox")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local doublemonitor = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		line    = { width = 4, v_gap = 6, gap = 4, num = 5 },
		icon    = nil,
		dmargin = { 10, 0, 0, 0 },
		width   = 100,
		color   = { main = "#b1222b", gray = "#575757", icon = "#a0a0a0", urgent = "#32882d" }
	}
	return redutil.table.merge(style, redutil.check(beautiful, "gauge.doublemonitor") or {})
end

-- Create progressbar widget
-----------------------------------------------------------------------------------------------------------------------
function pbar(style)

	-- updating values
	local data = {
		value = { 0, 0 },
	}

	-- Create custom widget
	--------------------------------------------------------------------------------
	local widg = wibox.widget.base.make_widget()

	-- User functions
	------------------------------------------------------------
	function widg:set_value(value)
		data.value[1] = value[1] < 1 and value[1] or 1
		data.value[2] = value[2] < 1 and value[2] or 1
		self:emit_signal("widget::updated")
	end

	-- Fit
	------------------------------------------------------------
	widg.fit = function(widg, width, height)
		return width, height
	end

	-- Draw
	------------------------------------------------------------
	widg.draw = function(widg, wibox, cr, width, height)

		local wd = (width + style.line.gap) / style.line.num - style.line.gap
		local dy = (height - (2 * style.line.width + style.line.v_gap)) / 2
		local p = { math.ceil(style.line.num * data.value[1]), math.ceil(style.line.num * data.value[2]) }

		for i = 1, 2 do
			for k = 1, style.line.num do
				cr:set_source(color(k <= p[i] and style.color.main or style.color.gray))
				cr:rectangle(
					(k - 1) * (wd + style.line.gap), dy + (i - 1) * (style.line.width + style.line.v_gap),
					wd, style.line.width
				)
				cr:fill()
			end
		end
	end

	--------------------------------------------------------------------------------
	return widg
end

-- Cunstruct a new doublemonitor widget
-- @param style Table containing colors and geometry parameters for all elemets
-----------------------------------------------------------------------------------------------------------------------
function doublemonitor.new(style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	local style = redutil.table.merge(default_style(), style or {})
	
	-- Construct layout
	--------------------------------------------------------------------------------
	local fixed = wibox.layout.fixed.horizontal()
	local layout = wibox.layout.constraint(fixed, "exact", style.width)
	local widg = pbar(style)
	local icon = svgbox(style.icon)

	icon:set_color(style.color.icon)
	
	fixed:add(icon)
	fixed:add(wibox.layout.margin(widg, unpack(style.dmargin)))

	-- User functions
	--------------------------------------------------------------------------------
	function layout:set_value(value)
		widg:set_value(value)
	end

	function layout:set_alert(alert)
		icon:set_color(alert and style.color.urgent or style.color.icon)
	end

	--------------------------------------------------------------------------------
	return layout
end

-- Config metatable to call doublemonitor module as function
-----------------------------------------------------------------------------------------------------------------------
function doublemonitor.mt:__call(...)
	return doublemonitor.new(...)
end

return setmetatable(doublemonitor, doublemonitor.mt)
