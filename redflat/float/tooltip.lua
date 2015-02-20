-----------------------------------------------------------------------------------------------------------------------
--                                                  RedFlat tooltip                                                  --
-----------------------------------------------------------------------------------------------------------------------
-- Slightly modded awful tooltip
-- style.margin were added
-- Proper placement on every text update
-----------------------------------------------------------------------------------------------------------------------
-- Some code was taken from
------ awful.tooltip v3.5.2
------ (c) 2009 Sébastien Gross
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local ipairs = ipairs
local unpack = unpack
local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")

local redutil = require("redflat.util")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local tooltip = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		margin       = { 5, 5, 3, 3 },
		timeout      = 1,
		border_width = 2,
		color        = { border = "#404040", text = "#aaaaaa", wibox = "#202020" }
	}
	return redutil.table.merge(style, redutil.check(beautiful, "float.tooltip") or {})
end

-- Create a new tooltip
-- @param objects Table containing objects to which tooltip will be attached
-- @param style.margin Table with horizontal and vertical text margin
-----------------------------------------------------------------------------------------------------------------------
function tooltip.new(objects, style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	local style = redutil.table.merge(default_style(), style or {})

	-- Construct tooltip window with wibox and textbox
	--------------------------------------------------------------------------------
	local ttp = { wibox = wibox({ type = "tooltip" }) }
	local tb = wibox.widget.textbox()
	ttp.widget = tb
	ttp.wibox:set_widget(wibox.layout.margin(tb, unpack(style.margin)))

	-- configure wibox properties
	ttp.wibox.visible = false
	ttp.wibox.ontop = true
	ttp.wibox.border_width = style.border_width
	ttp.wibox.border_color = style.color.border
	ttp.wibox:set_bg(style.color.wibox)
	ttp.wibox:set_fg(style.color.text)

	-- Tooltip size configurator
	--------------------------------------------------------------------------------
	 function ttp:set_geometry()
		local geom = self.wibox:geometry()
		local n_w, n_h = self.widget:fit(-1, -1)
		if geom.width ~= n_w or geom.height ~= n_h then
			self.wibox:geometry({
				width = n_w + style.margin[1] + style.margin[2],
				height = n_h + style.margin[3] + style.margin[4]
			})
		end
	end

	-- Set timer to make delay before tooltip show
	--------------------------------------------------------------------------------
	local show_timer = timer({ timeout = style.timeout })
	show_timer:connect_signal("timeout",
		function()
			ttp:set_geometry()
			awful.placement.under_mouse(ttp.wibox)
			awful.placement.no_offscreen(ttp.wibox)
			ttp.wibox.visible = true
			show_timer:stop()
		end)

	-- Tooltip metods
	--------------------------------------------------------------------------------
	function ttp.show()
		if not show_timer.started then show_timer:start() end
	end

	function ttp.hide()
		show_timer:stop()
		if ttp.wibox.visible then ttp.wibox.visible = false end
	end

	function ttp:set_text(text)
		self.widget:set_text(text)
		if self.wibox.visible then
			self:set_geometry()
			self.wibox.x = mouse.coords().x - self.wibox.width/2
			awful.placement.no_offscreen(self.wibox)
	   end
	end

	function ttp:add_to_object(object)
		object:connect_signal("mouse::enter", self.show)
		object:connect_signal("mouse::leave", self.hide)
	end

	function ttp:remove_from_object(object)
		object:disconnect_signal("mouse::enter", self.show)
		object:disconnect_signal("mouse::leave", self.hide)
	end

	-- Add tooltip to objects
	--------------------------------------------------------------------------------
	if objects then
		for _, object in ipairs(objects) do
			ttp:add_to_object(object)
		end
	end

	--------------------------------------------------------------------------------
	return ttp
end

-- Config metatable to call tooltip module as function
-----------------------------------------------------------------------------------------------------------------------
function tooltip.mt:__call(...)
	return tooltip.new(...)
end

return setmetatable(tooltip, tooltip.mt)
