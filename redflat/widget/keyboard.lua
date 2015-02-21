-----------------------------------------------------------------------------------------------------------------------
--                                     RedFlat keyboard layout indicator widget                                      --
-----------------------------------------------------------------------------------------------------------------------
-- Indicate and switch keybord layout using kbdd
-- (!) Doesn't support more than one instance
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local math = math
local table = table
local tonumber = tonumber
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local color = require("gears.color")

local tooltip = require("redflat.float.tooltip")
local redmenu = require("redflat.menu")
local redutil = require("redflat.util")
local svgbox = require("redflat.gauge.svgbox")


-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local keybd = { mt = {} }

local pre_command = "dbus-send --dest=ru.gentoo.KbddService /ru/gentoo/KbddService "

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		icon         = nil,
		micon        = {},
		layout_color = {}
	}
	return redutil.table.merge(style, redutil.check(beautiful, "widget.keyboard") or {})
end

-- Initialize layout menu
-----------------------------------------------------------------------------------------------------------------------
function keybd:init(layouts, style)

	-- construct list of layouts
	local menu_items = {}
	for i = 1, #layouts do
		local command = pre_command .. "ru.gentoo.kbdd.set_layout uint32:" .. tostring(i - 1)
		table.insert(menu_items, {layouts[i], command, nil, style.micon.blank})
	end

	-- initialize menu
	self.menu = redmenu({ hide_timeout = 1, theme = style.menu, items = menu_items })
	if self.menu.items[1].right_icon then
		self.menu.items[1].right_icon:set_image(beautiful.icon.check)
	end
end

-- Show layout menu
-----------------------------------------------------------------------------------------------------------------------
function keybd:toggle_menu(t)
	if self.menu.wibox.visible then
		self.menu:hide()
	else
		awful.placement.under_mouse(self.menu.wibox)
		awful.placement.no_offscreen(self.menu.wibox)
		self.menu:show({coords = {x = self.menu.wibox.x, y = self.menu.wibox.y}})
	end
end

-- Toggle layout
-----------------------------------------------------------------------------------------------------------------------
function keybd:toggle(reverse)
	if reverse then
		awful.util.spawn_with_shell(pre_command .. "ru.gentoo.kbdd.prev_layout")
	else
		awful.util.spawn_with_shell(pre_command .. "ru.gentoo.kbdd.next_layout")
	end
end

-- Create a new keyboard indicator widget
-- @param layouts Keyboard layout names to display in tooltip
-- @param style Table containing font parameters and letter position
-----------------------------------------------------------------------------------------------------------------------
function keybd.new(args, style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	local style = redutil.table.merge(default_style(), style or {})

	local args = args or {}
	local layouts_num = #args.layouts

	-- Initialize layout menu
	--------------------------------------------------------------------------------
	keybd:init(args.layouts, style)

	-- Create widget
	--------------------------------------------------------------------------------
	local widg = svgbox(style.icon)
	widg:set_color(style.layout_color[1])

	-- Set tooltip
	--------------------------------------------------------------------------------
	local tp = tooltip({ widg }, style.tooltip)
	tp:set_text(args.layouts[1])

	-- Set dbus signal
	--------------------------------------------------------------------------------
	dbus.request_name("session", "ru.gentoo.kbdd")
	dbus.add_match("session", "interface='ru.gentoo.kbdd',member='layoutChanged'")
	dbus.connect_signal("ru.gentoo.kbdd",
		function(...)
			-- set layout mark
			local data = {...}
			local layout = tonumber(data[2]) + 1
			widg:set_color(style.layout_color[layout] or "#000000")
			-- update tooltip
			tp:set_text(args.layouts[layout])
			-- update menu
			for i = 1, #args.layouts do
				local mark = layout == i and style.micon.check or style.micon.blank
				keybd.menu.items[i].right_icon:set_image(mark)
			end
		end)

	--------------------------------------------------------------------------------
	return widg
end

-- Config metatable to call keybd module as function
-----------------------------------------------------------------------------------------------------------------------
function keybd.mt:__call(...)
	return keybd.new(...)
end

return setmetatable(keybd, keybd.mt)
