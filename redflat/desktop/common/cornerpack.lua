-----------------------------------------------------------------------------------------------------------------------
--                                            RedFlat cornerpack widget                                              --
-----------------------------------------------------------------------------------------------------------------------
-- Group of corner indicators placed in horizontal layout
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local math = math
local string = string

local wibox = require("wibox")
local color = require("gears.color")
--local beautiful = require("beautiful")

local corners = require("redflat.desktop.common.corners")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local cornerpack = { mt = {} }

-- Create a new cornerpack widget
-- @param num Number of indicators
-- @param style Style variables for redflat corners widget
-----------------------------------------------------------------------------------------------------------------------
function cornerpack.new(num, style)

	local pack = {}
	local style = style or {}

	-- construct group of corner indicators
	pack.layout = wibox.layout.fixed.horizontal()
	local flex_horizontal = wibox.layout.flex.horizontal()
	local crn = {}

	for i = 1, num do
		crn[i] = corners(style)
		if i == 1 then pack.layout:add(crn[i])
		else
			local corner_space = wibox.layout.align.horizontal()
			corner_space:set_right(crn[i])
			flex_horizontal:add(corner_space)
		end
	end
	pack.layout:add(flex_horizontal)

	-- setup functions
	function pack:set_values(values, n)
		if n then
			if crn[n] then crn[n]:set_value(values) end
		else
			for i, v in ipairs(values) do
				if crn[i] then crn[i]:set_value(v) end
			end
		end
	end

	return pack
end

-- Config metatable to call cornerpack module as function
-----------------------------------------------------------------------------------------------------------------------
function cornerpack.mt:__call(...)
	return cornerpack.new(...)
end

return setmetatable(cornerpack, cornerpack.mt)
