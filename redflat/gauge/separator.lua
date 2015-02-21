-----------------------------------------------------------------------------------------------------------------------
--                                              RedFlat separatoe widget                                             --
-----------------------------------------------------------------------------------------------------------------------
-- Simple graphical separator to decorate panel
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local unpack = unpack
local wibox = require("wibox")
local beautiful = require("beautiful")
local color = require("gears.color")

local redutil = require("redflat.util")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local separator = {}

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		margin = { 0, 0, 0, 0 },
		color  = { shadow1 = "#141414", shadow2 = "#313131" }
	}
	return redutil.table.merge(style, redutil.check(beautiful, "gauge.separator") or {})
end

-- Create a new separator widget
-- Total size two pixels bigger than sum of margins for general direction
-----------------------------------------------------------------------------------------------------------------------
local function separator_base(horizontal, style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	local style = redutil.table.merge(default_style(), style or {})

	-- Create custom widget
	--------------------------------------------------------------------------------
	local widg = wibox.widget.base.make_widget()

	-- Fit
	------------------------------------------------------------
	widg.fit = function(widg, width, height)
		if horizontal then
			return width, 2
		else
			return 2, height
		end
	end

	-- Draw
	------------------------------------------------------------
	widg.draw = function(widg, wibox, cr, width, height)
		cr:set_source(color(style.color.shadow1))
		if horizontal then cr:rectangle(0, 0, width, 1)
		else cr:rectangle(0, 0, 1, height) end
		cr:fill()

		cr:set_source(color(style.color.shadow2))
		if horizontal then cr:rectangle(0, 1, width, 1)
		else cr:rectangle(1, 0, 1, height) end
		cr:fill()
	end

	--------------------------------------------------------------------------------
	return wibox.layout.margin(widg, unpack(style.margin))
end

-- Horizontal and vertial variants
-----------------------------------------------------------------------------------------------------------------------
function separator.vertical(style)
	return separator_base(false, style)
end

function separator.horizontal(style)
	return separator_base(true, style)
end

-----------------------------------------------------------------------------------------------------------------------
return separator
