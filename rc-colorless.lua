-----------------------------------------------------------------------------------------------------------------------
--                                                Colorless config                                                   --
-----------------------------------------------------------------------------------------------------------------------

-- Load modules
-----------------------------------------------------------------------------------------------------------------------

-- Standard awesome library
------------------------------------------------------------
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")

require("awful.autofocus")

-- User modules
------------------------------------------------------------
local redflat = require("redflat")


-- Error handling
-----------------------------------------------------------------------------------------------------------------------
require("colorless.ercheck-config") -- load file with error handling


-- Setup theme and environment vars
-----------------------------------------------------------------------------------------------------------------------
local env = require("colorless.env-config") -- load file with environment
env:init()


-- Layouts setup
-----------------------------------------------------------------------------------------------------------------------
awful.layout.layouts = {
	awful.layout.suit.floating,
	awful.layout.suit.tile,
	awful.layout.suit.tile.left,
	awful.layout.suit.tile.bottom,
	awful.layout.suit.tile.top,
	awful.layout.suit.fair,
	awful.layout.suit.max,
	awful.layout.suit.max.fullscreen,
}


-- Main menu configuration
-----------------------------------------------------------------------------------------------------------------------
local mymenu = require("colorless.menu-config") -- load file with menu configuration
mymenu:init({ env = env })


-- Panel widgets
-----------------------------------------------------------------------------------------------------------------------

-- Separator
--------------------------------------------------------------------------------
local separator = redflat.gauge.separator.vertical()

-- Tasklist
--------------------------------------------------------------------------------
local tasklist = {}

tasklist.buttons = awful.util.table.join(
	awful.button({}, 1, redflat.widget.tasklist.action.select),
	awful.button({}, 2, redflat.widget.tasklist.action.close),
	awful.button({}, 3, redflat.widget.tasklist.action.menu),
	awful.button({}, 4, redflat.widget.tasklist.action.switch_next),
	awful.button({}, 5, redflat.widget.tasklist.action.switch_prev)
)

-- Taglist widget
--------------------------------------------------------------------------------
local taglist = {}
taglist.style = { separator = separator, widget = redflat.gauge.tag.blue.new, show_tip = true }
taglist.buttons = awful.util.table.join(
	awful.button({         }, 1, function(t) t:view_only() end),
	awful.button({ env.mod }, 1, function(t) if client.focus then client.focus:move_to_tag(t) end end),
	awful.button({         }, 2, awful.tag.viewtoggle),
	awful.button({         }, 3, function(t) redflat.widget.layoutbox:toggle_menu(t) end),
	awful.button({ env.mod }, 3, function(t) if client.focus then client.focus:toggle_tag(t) end end),
	awful.button({         }, 4, function(t) awful.tag.viewnext(t.screen) end),
	awful.button({         }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

-- Textclock widget
--------------------------------------------------------------------------------
local textclock = {}
textclock.widget = redflat.widget.textclock({ timeformat = "%H:%M", dateformat = "%b  %d  %a" })

-- Layoutbox configure
--------------------------------------------------------------------------------
local layoutbox = {}

layoutbox.buttons = awful.util.table.join(
	awful.button({ }, 1, function () awful.layout.inc( 1) end),
	awful.button({ }, 3, function () redflat.widget.layoutbox:toggle_menu(mouse.screen.selected_tag) end),
	awful.button({ }, 4, function () awful.layout.inc( 1) end),
	awful.button({ }, 5, function () awful.layout.inc(-1) end)
)

-- Tray widget
--------------------------------------------------------------------------------
local tray = {}
tray.widget = redflat.widget.minitray({ timeout = 10 })

tray.buttons = awful.util.table.join(
	awful.button({}, 1, function() redflat.widget.minitray:toggle() end)
)


-- Screen setup
-----------------------------------------------------------------------------------------------------------------------
awful.screen.connect_for_each_screen(
	function(s)
		-- wallpaper
		env.wallpaper(s)

		-- tags
		awful.tag({ "Tag1", "Tag2", "Tag3", "Tag4", "Tag5" }, s, awful.layout.layouts[1])

		-- Create a promptbox for each screen
		s.mypromptbox = awful.widget.prompt()

		-- layoutbox widget
		layoutbox[s] = redflat.widget.layoutbox({ screen = s })

		-- taglist widget
		taglist[s] = redflat.widget.taglist({ screen = s, buttons = taglist.buttons }, taglist.style)

		-- tasklist widget
		tasklist[s] = redflat.widget.tasklist({ screen = s, buttons = tasklist.buttons })

		-- panel wibox
		s.panel = awful.wibar({ position = "bottom", screen = s, height = beautiful.panel_height or 36 })

		-- add widgets to the wibox
		s.panel:setup {
			layout = wibox.layout.align.horizontal,
			{ -- left widgets
				layout = wibox.layout.fixed.horizontal,

				env.wrapper(mymenu.widget, "mainmenu", mymenu.buttons),
				separator,
				env.wrapper(taglist[s], "taglist"),
				separator,
				s.mypromptbox,
			},
			{ -- middle widget
				layout = wibox.layout.align.horizontal,
				expand = "outside",

				nil,
				env.wrapper(tasklist[s], "tasklist"),
			},
			{ -- right widgets
				layout = wibox.layout.fixed.horizontal,

				separator,
				env.wrapper(layoutbox[s], "layoutbox", layoutbox.buttons),
				separator,
				env.wrapper(textclock.widget, "textclock"),
				separator,
				env.wrapper(tray.widget, "tray", tray.buttons),
			},
		}
	end
)


-- Key bindings
-----------------------------------------------------------------------------------------------------------------------
local hotkeys = require("colorless.keys-config") -- load file with hotkeys configuration
hotkeys:init({ env = env, menu = mymenu.mainmenu })

-- set global keys
root.keys(hotkeys.keys.root)

-- set global(desktop) mouse buttons
root.buttons(hotkeys.mouse.root)


-- Rules
-----------------------------------------------------------------------------------------------------------------------
local rules = require("colorless.rules-config") -- load file with rules configuration
rules:init({ hotkeys = hotkeys})

awful.rules.rules = rules.rules


-- Titlebar setup
-----------------------------------------------------------------------------------------------------------------------
local titlebar = require("colorless.titlebar-config") -- load file with titlebar configuration
titlebar:init()

-- Signals setup
-----------------------------------------------------------------------------------------------------------------------
client.connect_signal(
	"manage",
	function(c)
		if awesome.startup
		   and not c.size_hints.user_position
		   and not c.size_hints.program_position
		then
			awful.placement.no_offscreen(c)
		end
	end
)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal(
	"mouse::enter",
	function(c)
		if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier and awful.client.focus.filter(c) then
			client.focus = c
		end
	end
)

client.connect_signal("focus",   function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

screen.connect_signal("property::geometry", env.wallpaper)
