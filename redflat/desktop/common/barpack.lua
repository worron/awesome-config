-----------------------------------------------------------------------------------------------------------------------
--                                               RedFlat barpack widget                                              --
-----------------------------------------------------------------------------------------------------------------------
-- Group of indicators with progressbar, label and text in every line
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local math = math
local string = string
local wibox = require("wibox")
local color = require("gears.color")
local beautiful = require("beautiful")

local redutil = require("redflat.util")
local dcommon = require("redflat.desktop.common")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local barpack = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		label_style = {},
		text_style  = {},
		dashbar     = {},
		line_height = 20,
		text_gap    = 20,
		label_gap   = 20,
		color       = {}
	}
	return redutil.table.merge(style, redutil.check(beautiful, "desktop.common.barpack") or {})
end


-- Create a new barpack widget
-- @param style.names Table containing labels placed at the start of line
-- @param style.text Table containing labels at the end of line
-- @param style.line_height Height for all elements in line
-- @param style.style.color.main Style variables for redflat dashbar
-- @param style.label_style Style variables for redflat textbox
-- @param style.text_style Style variables for redflat textbox
-----------------------------------------------------------------------------------------------------------------------
function barpack.new(num, style)

	local pack = {}
	local style = redutil.table.merge(default_style(), style or {})
	local dashbar_style = redutil.table.merge(style.dashbar, { color = style.color })
	local label_style = redutil.table.merge(style.label_style, { color = style.color.gray })
	local text_style = redutil.table.merge(style.text_style, { color = style.color.gray })

	-- Construct group of lines
	--------------------------------------------------------------------------------
	pack.layout = wibox.layout.fixed.vertical()
	local flex_vertical = wibox.layout.flex.vertical()
	local lines = {}

	for i = 1, num do
		lines[i] = {}

		local line_align = wibox.layout.align.horizontal()
		local line_const = wibox.layout.constraint(line_align, "exact", nil, style.line_height)
		lines[i].bar = dcommon.dashbar(dashbar_style)
		line_align:set_middle(lines[i].bar)

		lines[i].label = dcommon.textbox("", label_style)
		lines[i].label:set_width(0)
		lines[i].label_margin = wibox.layout.margin(lines[i].label)
		line_align:set_left(lines[i].label_margin)

		lines[i].text = dcommon.textbox("", text_style)
		lines[i].text:set_width(0)
		lines[i].text_margin = wibox.layout.margin(lines[i].text)
		line_align:set_right(lines[i].text_margin)

		if i == 1 then
			pack.layout:add(line_const)
		else
			local line_space = wibox.layout.align.vertical()
			line_space:set_bottom(line_const)
			flex_vertical:add(line_space)
		end
	end
	pack.layout:add(flex_vertical)

	-- Setup functions
	--------------------------------------------------------------------------------

	function pack:set_values(value, index)
		lines[index].bar:set_value(value)
	end

	function pack:set_text(value, index)
		lines[index].text:set_text(value)
		lines[index].text:set_width(value and text_style.width or 0)
		lines[index].text_margin:set_left(value and style.text_gap or 0)
	end

	function pack:set_text_color(value, index)
		lines[index].text:set_color(value)
	end

	function pack:set_label_color(value, index)
		lines[index].label:set_color(value)
	end

	function pack:set_label(value, index)
		lines[index].label:set_text(value)
		lines[index].label:set_width(value and label_style.width or 0)
		lines[index].label_margin:set_right(value and style.label_gap or 0)
	end

	--------------------------------------------------------------------------------
	return pack
end

-- Config metatable to call barpack module as function
-----------------------------------------------------------------------------------------------------------------------
function barpack.mt:__call(...)
	return barpack.new(...)
end

return setmetatable(barpack, barpack.mt)
