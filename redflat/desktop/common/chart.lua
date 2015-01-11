-----------------------------------------------------------------------------------------------------------------------
--                                                RedFlat chart widget                                               --
-----------------------------------------------------------------------------------------------------------------------
-- History graph for desktop widgets
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local table = table
local ipairs = ipairs
local math = math
local wibox = require("wibox")
local color = require("gears.color")
--local beautiful = require("beautiful")

local redutil = require("redflat.util")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local chart = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	return {
		maxm        = 1,
		color       = "#404040",
		width       = nil,
		height      = nil,
		zero_height = 4,
		bar         = { gap = 5, width = 5 },
		autoscale   = true
	}
end

-- Create a new chart widget
-- @param style Table containing chart geometry and style
-- See block of local vars below for more details
-----------------------------------------------------------------------------------------------------------------------
function chart.new(style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	local style = redutil.table.merge(default_style(), style or {})
	local count = 0
	local barnum
	local current_maxm = style.maxm

	-- updating values
	local data = {
		values = {}
	}

	-- Create custom widget
	--------------------------------------------------------------------------------
	local chartwidg = wibox.widget.base.make_widget()

	-- User functions
	------------------------------------------------------------
	function chartwidg:set_value(x)
		if barnum then
			count = count % barnum + 1
			data.values[count] = x
			self:emit_signal("widget::updated")
		end
	end

	-- Fit function
	------------------------------------------------------------
	chartwidg.fit = function(chartwidg, width, height)
		return style.width or width, style.height or height
	end

	-- Draw function
	------------------------------------------------------------
	chartwidg.draw = function(chartwidg, wibox, cr, width, height)

		--scale
		if style.autoscale then
			current_maxm = style.maxm

			for _, v in ipairs(data.values) do
				if v > current_maxm then current_maxm = v end
			end
		end

		-- chart
		barnum = math.floor((width + style.bar.gap) / (style.bar.width + style.bar.gap))
		while #data.values < barnum do
			table.insert(data.values, 0)
		end
		local real_gap = style.bar.gap + (width - (barnum - 1) * (style.bar.width + style.bar.gap)
		                 - style.bar.width) / (barnum - 1)

		cr:set_source(color(style.color))
		for i = 0, barnum - 1 do
			local n = (count + i) % barnum + 1
			local k = data.values[n] / current_maxm
			if k > 1 then k = 1 end
			local bar_height = - k * (height - style.zero_height)
			cr:rectangle(i * (style.bar.width + real_gap), height, style.bar.width, - style.zero_height)
			cr:rectangle(i * (style.bar.width + real_gap), height - style.zero_height, style.bar.width, bar_height)
		end

		cr:fill()
	end

	--------------------------------------------------------------------------------
	return chartwidg
end

-- Config metatable to call chart module as function
-----------------------------------------------------------------------------------------------------------------------
function chart.mt:__call(...)
	return chart.new(...)
end

return setmetatable(chart, chart.mt)
