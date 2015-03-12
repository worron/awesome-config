-----------------------------------------------------------------------------------------------------------------------
--                                            RedFlat keyboard actions util                                          --
-----------------------------------------------------------------------------------------------------------------------
-- Move and resize windows by keyboard
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

local redutil = require("redflat.util")
local common = require("redflat.layout.common")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local keyboard = { handler = {}, notify = {} }

keyboard.ignored = { "dock", "splash", "desktop"}

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		notify = {
			geometry     = { width = 200, height = 80 },
			border_width = 2,
			text         = "Window control mode",
			font         = "Sans 14 bold",
			color        = { border = "#575757", wibox = "#202020" }
		}
	}
	return redutil.table.merge(style, redutil.check(beautiful, "service.kyboard") or {})
end

-- Support functions
-----------------------------------------------------------------------------------------------------------------------
function get_handler(lay)
	return lay.key_handler or common.keyboard.key_handler[lay]
end

-- Initialize notify window
-----------------------------------------------------------------------------------------------------------------------
function keyboard.notify:init()
	local style = default_style().notify

	-- notification text
	local notebox = wibox.widget.textbox(style.text)
	notebox:set_align("center")
	notebox:set_font(style.font)

	-- create notifacion wibox
	self.wibox = wibox({
		ontop        = true,
		bg           = style.color.wibox,
		border_width = style.border_width,
		border_color = style.color.border
	})

	self.wibox:set_widget(notebox)
	self.wibox:geometry(style.geometry)
end

function keyboard.notify:show()
	if not self.wibox then self:init() end
	redutil.placement.centered(self.wibox, nil, screen[mouse.screen].workarea)
	self.wibox.visible = true
end

function keyboard.notify:hide()
	self.wibox.visible = false
end

-- Start key handler
-----------------------------------------------------------------------------------------------------------------------
function keyboard.handler(c)
	local c = c or client.focus

	if not c or c.fullscreen or awful.util.table.hasitem(keyboard.ignored, c.type) then
		return
	end

	local lay = awful.layout.get(c.screen)
	local handler = get_handler(lay)

	if handler then
		keyboard.notify:show()
		return handler(c, function() keyboard.notify:hide() end)
	end
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return keyboard
