-----------------------------------------------------------------------------------------------------------------------
--                                                     Red config                                                    --
-----------------------------------------------------------------------------------------------------------------------

-- Load modules
-----------------------------------------------------------------------------------------------------------------------

-- Standard awesome library
------------------------------------------------------------
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

require("awful.autofocus")

-- User modules
------------------------------------------------------------
local redflat = require("redflat")

-- global module
timestamp = require("redflat.timestamp")

-- Error handling
-----------------------------------------------------------------------------------------------------------------------
require("blue.ercheck-config") -- load file with error handling


-- Setup theme and environment vars
-----------------------------------------------------------------------------------------------------------------------
local env = require("red.env-config") -- load file with environment
env:init({ theme = "red" })


-- Layouts setup
-----------------------------------------------------------------------------------------------------------------------
local layouts = require("red.layout-config") -- load file with tile layouts setup
layouts:init()


-- Main menu configuration
-----------------------------------------------------------------------------------------------------------------------
local mymenu = require("red.menu-config") -- load file with menu configuration
mymenu:init({ env = env })


-- Panel widgets
-----------------------------------------------------------------------------------------------------------------------

-- Separator
--------------------------------------------------------------------------------
local separator = redflat.gauge.separator.vertical()

-- Tasklist
--------------------------------------------------------------------------------
local tasklist = {}
tasklist.style = { widget = redflat.gauge.task.red.new }

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
taglist.style = { separator = separator, widget = redflat.gauge.tag.red.new, show_tip = true }
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

-- Software update indcator
--------------------------------------------------------------------------------
local upgrades = {}
upgrades.widget = redflat.widget.upgrades({ command = env.upgrades })

upgrades.buttons = awful.util.table.join(
	awful.button({ }, 1, function () mymenu.mainmenu:toggle() end),
	awful.button({ }, 2, function () redflat.widget.upgrades:update(true) end)
)

-- Layoutbox configure
--------------------------------------------------------------------------------
local layoutbox = {}

layoutbox.buttons = awful.util.table.join(
	awful.button({ }, 1, function () redflat.widget.layoutbox:toggle_menu(mouse.screen.selected_tag) end),
	awful.button({ }, 4, function () awful.layout.inc( 1) end),
	awful.button({ }, 5, function () awful.layout.inc(-1) end)
)

-- Tray widget
--------------------------------------------------------------------------------
local tray = {}
tray.widget = redflat.widget.minitray()

tray.buttons = awful.util.table.join(
	awful.button({}, 1, function() redflat.widget.minitray:toggle() end)
)

-- PA volume control
--------------------------------------------------------------------------------
local volume = {}
volume.widget = redflat.widget.pulse(nil, { widget = redflat.gauge.audio.red.new })

-- activate player widget
redflat.float.player:init({ name = env.player })

volume.buttons = awful.util.table.join(
	awful.button({}, 4, function() redflat.widget.pulse:change_volume()                end),
	awful.button({}, 5, function() redflat.widget.pulse:change_volume({ down = true }) end),
	awful.button({}, 2, function() redflat.widget.pulse:mute()                         end),
	awful.button({}, 3, function() redflat.float.player:show()                         end),
	awful.button({}, 1, function() redflat.float.player:action("PlayPause")            end),
	awful.button({}, 8, function() redflat.float.player:action("Previous")             end),
	awful.button({}, 9, function() redflat.float.player:action("Next")                 end)
)

-- Keyboard layout indicator
--------------------------------------------------------------------------------
local kbindicator = {}
kbindicator.widget = redflat.widget.keyboard({ layouts = { "English", "Russian" } })

kbindicator.buttons = awful.util.table.join(
	awful.button({}, 1, function () redflat.widget.keyboard:toggle_menu() end),
	awful.button({}, 4, function () redflat.widget.keyboard:toggle()      end),
	awful.button({}, 5, function () redflat.widget.keyboard:toggle(true)  end)
)

-- Mail widget
--------------------------------------------------------------------------------
-- safe load private mail settings
local my_mails = {}
pcall(function() my_mails = require("red.mail-config") end)

-- widget setup
local mail = {}
mail.widget = redflat.widget.mail({ maillist = my_mails })

-- buttons
mail.buttons = awful.util.table.join(
	awful.button({ }, 1, function () awful.spawn.with_shell(env.mail) end),
	awful.button({ }, 2, function () redflat.widget.mail:update() end)
)

-- System resource monitoring widgets
--------------------------------------------------------------------------------
local sysmon = { widget = {}, buttons = {} }

-- battery
sysmon.widget.battery = redflat.widget.sysmon(
	{ func = redflat.system.pformatted.bat(25), arg = "BAT1" },
	{ timeout = 60, monitor = { label = "BAT" } }
)

-- network speed
sysmon.widget.network = redflat.widget.net(
	{ interface = "wlp3s0", speed = { up = 5 * 1024^2, down = 5 * 1024^2 }, autoscale = false },
	{ timeout = 2 }
)

-- CPU usage
sysmon.widget.cpu = redflat.widget.sysmon(
	{ func = redflat.system.pformatted.cpu(80) },
	{ timeout = 2, monitor = { label = "CPU" } }
)

sysmon.buttons.cpu = awful.util.table.join(
	awful.button({ }, 1, function() redflat.float.top:show("cpu") end)
)

-- RAM usage
sysmon.widget.ram = redflat.widget.sysmon(
	{ func = redflat.system.pformatted.mem(80) },
	{ timeout = 10, monitor = { label = "RAM" } }
)

sysmon.buttons.ram = awful.util.table.join(
	awful.button({ }, 1, function() redflat.float.top:show("mem") end)
)


-- Screen setup
-----------------------------------------------------------------------------------------------------------------------

-- aliases for setup
local al = awful.layout.layouts

-- setup
awful.screen.connect_for_each_screen(
	function(s)
		-- wallpaper
		env.wallpaper(s)

		-- tags
		awful.tag({ "Main", "Full", "Edit", "Read", "Free" }, s, { al[5], al[6], al[6], al[4], al[3] })

		-- layoutbox widget
		layoutbox[s] = redflat.widget.layoutbox({ screen = s })

		-- taglist widget
		taglist[s] = redflat.widget.taglist({ screen = s, buttons = taglist.buttons, hint = env.tagtip }, taglist.style)

		-- tasklist widget
		tasklist[s] = redflat.widget.tasklist({ screen = s, buttons = tasklist.buttons }, tasklist.style)

		-- panel wibox
		s.panel = awful.wibar({ position = "bottom", screen = s, height = beautiful.panel_height or 36 })

		-- add widgets to the wibox
		s.panel:setup {
			layout = wibox.layout.align.horizontal,
			{ -- left widgets
				layout = wibox.layout.fixed.horizontal,

				env.wrapper(taglist[s], "taglist"),
				separator,
				env.wrapper(upgrades.widget, "upgrades", upgrades.buttons),
				separator,
				env.wrapper(kbindicator.widget, "keyboard", kbindicator.buttons),
				separator,
				env.wrapper(volume.widget, "volume", volume.buttons),
				separator,
				env.wrapper(mail.widget, "mail", mail.buttons),
				separator,
				env.wrapper(layoutbox[s], "layoutbox", layoutbox.buttons),
				separator,
			},
			{ -- middle widget
				layout = wibox.layout.fixed.horizontal,

				env.wrapper(tasklist[s], "tasklist"),
			},
			{ -- right widgets
				layout = wibox.layout.fixed.horizontal,

				separator,
				env.wrapper(sysmon.widget.network, "network"),
				separator,
				env.wrapper(sysmon.widget.cpu, "cpu", sysmon.buttons.cpu),
				separator,
				env.wrapper(sysmon.widget.ram, "ram", sysmon.buttons.ram),
				separator,
				env.wrapper(sysmon.widget.battery, "battery"),
				separator,
				env.wrapper(tray.widget, "tray", tray.buttons),
				separator,
				env.wrapper(textclock.widget, "textclock"),
			},
		}
	end
)

-- Desktop widgets
-----------------------------------------------------------------------------------------------------------------------
local desktop = require("red.desktop-config") -- load file with desktop widgets configuration
desktop:init({ env = env })


-- Active screen edges
-----------------------------------------------------------------------------------------------------------------------
local edges = require("red.edges-config") -- load file with edges configuration
edges:init()


-- Key bindings
-----------------------------------------------------------------------------------------------------------------------
local hotkeys = require("red.keys-config") -- load file with hotkeys configuration
hotkeys:init({ env = env, menu = mymenu.mainmenu })


-- Rules
-----------------------------------------------------------------------------------------------------------------------
local rules = require("red.rules-config") -- load file with rules configuration
rules:init({ hotkeys = hotkeys})


-- Titlebar setup
-----------------------------------------------------------------------------------------------------------------------
local titlebar = require("red.titlebar-config") -- load file with titlebar configuration
titlebar:init()


-- Base signal set for awesome wm
-----------------------------------------------------------------------------------------------------------------------
local signals = require("red.signals-config") -- load file with signals configuration
signals:init({ env = env })


-- Autostart user applications
-----------------------------------------------------------------------------------------------------------------------
local autostart = require("red.autostart-config") -- load file with autostart application list

if timestamp.is_startup() then
	autostart.run()
end
