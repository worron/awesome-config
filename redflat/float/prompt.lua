-----------------------------------------------------------------------------------------------------------------------
--                                              RedFlat promt widget                                                 --
-----------------------------------------------------------------------------------------------------------------------
-- Promt widget with his own wibox placed on center of screen
-----------------------------------------------------------------------------------------------------------------------
-- Some code was taken from
------ awful.widget.prompt v3.5.2
------ (c) 2009 Julien Danjou
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local type = type
local unpack = unpack

local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")

local redutil = require("redflat.util")
local decoration = require("redflat.float.decoration")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local floatprompt = {}

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		geometry     = { width = 620, height = 120 },
		margin       = { 20, 20, 40, 40 },
		border_width = 2,
		color        = { border = "#575757", wibox = "#202020" }
	}
	return redutil.table.merge(style, redutil.check(beautiful, "float.prompt") or {})
end

-- Initialize prompt widget
-- @param prompt Prompt to use
-----------------------------------------------------------------------------------------------------------------------
function floatprompt:init()

	local style = default_style()

	-- Create prompt widget
	--------------------------------------------------------------------------------
	self.widget = wibox.widget.textbox()
	self.info = false
	self.widget:set_ellipsize("start")
	--self.prompt = prompt or " Run: "
	self.prompt = " Run: "
	self.decorated_widget = decoration.textfield(self.widget, style.field)

	-- Create floating wibox for promt widget
	--------------------------------------------------------------------------------
	self.wibox = wibox({
		ontop        = true,
		bg           = style.color.wibox,
		border_width = style.border_width,
		border_color = style.color.border
	})

	self.wibox:set_widget(wibox.layout.margin(self.decorated_widget, unpack(style.margin)))
	self.wibox:geometry(style.geometry)
end

-- Run method for prompt widget
-- Wibox appears on call and hides after command entered
-----------------------------------------------------------------------------------------------------------------------
function floatprompt:run()
	if not self.wibox then self:init() end
	redutil.placement.centered(self.wibox, nil, screen[mouse.screen].workarea)
	self.wibox.visible = true
	self.info = false
	return awful.prompt.run(
		{ prompt = self.prompt },
		self.widget,
		function (...)
			local result = awful.util.spawn(...)
			if type(result) == "string" then
				self.widget:set_text(result)
				self.info = true
			end
		end,
		awful.completion.shell,
		awful.util.getdir("cache") .. "/history",
		30,
		function ()
			if not self.info then self.wibox.visible = false end
		end
	)
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return floatprompt
