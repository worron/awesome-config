-----------------------------------------------------------------------------------------------------------------------
--                                                   Ruby config                                                     --
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

-- debug locker
local lock = lock or {}

redflat.startup.locked = lock.autostart
redflat.startup:activate()


-- Error handling
-----------------------------------------------------------------------------------------------------------------------
require("colorless.ercheck-config") -- load file with error handling


-- Setup theme and environment vars
-----------------------------------------------------------------------------------------------------------------------
local env = require("color.blue.env-config") -- load file with environment
env:init({ theme = "ruby", desktop_autohide = true, set_center = true })


-- Layouts setup
-----------------------------------------------------------------------------------------------------------------------
local layouts = require("color.blue.layout-config") -- load file with tile layouts setup
layouts:init()


-- Main menu configuration
-----------------------------------------------------------------------------------------------------------------------
local mymenu = require("color.blue.menu-config") -- load file with menu configuration
mymenu:init({ env = env })


-- Panel widgets
-----------------------------------------------------------------------------------------------------------------------

-- Separator
--------------------------------------------------------------------------------
local separator = redflat.gauge.separator.vertical()

-- Tasklist
--------------------------------------------------------------------------------
local tasklist = {}

-- load list of app name aliases from files and set it as part of tasklist theme
tasklist.style = { appnames = require("color.blue.alias-config"),  widget = redflat.gauge.task.ruby.new }

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

taglist.style = { widget = redflat.gauge.tag.ruby.new, show_tip = true }

-- double line taglist
taglist.cols_num = 6
taglist.rows_num = 2

taglist.layout = wibox.widget {
	expand          = true,
	forced_num_rows = taglist.rows_num,
	forced_num_cols = taglist.cols_num,
    layout          = wibox.layout.grid,
}

-- buttons
taglist.buttons = awful.util.table.join(
	awful.button({         }, 1, function(t) t:view_only() end),
	awful.button({ env.mod }, 1, function(t) if client.focus then client.focus:move_to_tag(t) end end),
	awful.button({         }, 2, awful.tag.viewtoggle),
	awful.button({         }, 3, function(t) redflat.widget.layoutbox:toggle_menu(t) end),
	awful.button({ env.mod }, 3, function(t) if client.focus then client.focus:toggle_tag(t) end end),
	awful.button({         }, 4, function(t) awful.tag.viewnext(t.screen) end),
	awful.button({         }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

-- some tag settings which indirectky depends on row and columns number of taglist
taglist.names = {
	"Prime", "Full", "Code", "Edit", "Misc", "Game",
	"Spare", "Back", "Test", "Qemu", "Data", "Free"
}

local al = awful.layout.layouts
taglist.layouts = {
	al[5], al[6], al[6], al[4], al[3], al[3],
	al[5], al[6], al[6], al[4], al[3], al[1]
}

-- Textclock widget
--------------------------------------------------------------------------------
local textclock = {}
textclock.widget = redflat.widget.textclock({ timeformat = "%H:%M", dateformat = "%b  %d  %a" })

-- Layoutbox configure
--------------------------------------------------------------------------------
local layoutbox = {}

layoutbox.buttons = awful.util.table.join(
	awful.button({ }, 3, function () mymenu.mainmenu:toggle() end),
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
volume.widget = redflat.widget.pulse(nil, { widget = redflat.gauge.audio.blue.new })

-- activate player widget
redflat.float.player:init({ name = env.player })

volume.buttons = awful.util.table.join(
	awful.button({}, 4, function() volume.widget:change_volume()                end),
	awful.button({}, 5, function() volume.widget:change_volume({ down = true }) end),
	awful.button({}, 2, function() volume.widget:mute()                         end),
	awful.button({}, 3, function() redflat.float.player:show()                  end),
	awful.button({}, 1, function() redflat.float.player:action("PlayPause")     end),
	awful.button({}, 8, function() redflat.float.player:action("Previous")      end),
	awful.button({}, 9, function() redflat.float.player:action("Next")          end)
)

-- PA microphone
--------------------------------------------------------------------------------
local microphone = {}

-- tricky custom style
local microphone_style = {
	widget = redflat.gauge.audio.blue.new,
	audio = beautiful.individual and beautiful.individual.microphone_audio or {},
}
--microphone_style.audio.gauge = redflat.gauge.monitor.dash
microphone_style.audio.gauge = false

-- init widget
microphone.widget = redflat.widget.pulse({ type = "source" }, microphone_style)

microphone.buttons = awful.util.table.join(
	awful.button({}, 2, function() microphone.widget:mute() end),
	awful.button({}, 4, function() microphone.widget:change_volume() end),
	awful.button({}, 5, function() microphone.widget:change_volume({ down = true }) end)
)

-- Keyboard layout indicator
--------------------------------------------------------------------------------
local kbindicator = {}
redflat.widget.keyboard:init({ "English", "Russian" })
kbindicator.widget = redflat.widget.keyboard()

kbindicator.buttons = awful.util.table.join(
	awful.button({}, 1, function () redflat.widget.keyboard:toggle_menu() end),
	awful.button({}, 4, function () redflat.widget.keyboard:toggle()      end),
	awful.button({}, 5, function () redflat.widget.keyboard:toggle(true)  end)
)

-- Mail widget
--------------------------------------------------------------------------------
-- mail settings template
local my_mails = require("color.blue.mail-example")

-- safe load private mail settings
pcall(function() my_mails = require("private.mail-config") end)

-- widget setup
local mail = {}
redflat.widget.mail:init({ maillist = my_mails, update_timeout = 15 * 60 })
mail.widget = redflat.widget.mail()

-- buttons
mail.buttons = awful.util.table.join(
	awful.button({ }, 1, function () awful.spawn.with_shell(env.mail) end),
	awful.button({ }, 2, function () redflat.widget.mail:update(true) end)
)

-- Software update indcator
--------------------------------------------------------------------------------
redflat.widget.updates:init({ command = env.updates })

local updates = {}
updates.widget = redflat.widget.updates()

updates.buttons = awful.util.table.join(
	awful.button({ }, 1, function () redflat.widget.updates:toggle() end),
	awful.button({ }, 2, function () redflat.widget.updates:update(true) end),
	awful.button({ }, 3, function () redflat.widget.updates:toggle() end)
)

-- System resource monitoring widgets
--------------------------------------------------------------------------------
local sysmon = { widget = {}, buttons = {} }

-- battery
sysmon.widget.battery = redflat.widget.battery(
	{ func = redflat.system.pformatted.bat(25), arg = "BAT0" },
	{ timeout = 60, widget = redflat.gauge.monitor.dash }
)

-- network speed
sysmon.widget.network = redflat.widget.net(
	{
		interface = "wlp60s0",
		speed = { up = 6 * 1024^2, down = 6 * 1024^2 },
		autoscale = false
	},
	{ timeout = 2, widget = redflat.gauge.icon.double, monitor = { step = 0.1 } }
)

-- CPU usage
sysmon.widget.cpu = redflat.widget.sysmon(
	{ func = redflat.system.pformatted.cpu(80) },
	{ timeout = 2, widget = redflat.gauge.monitor.dash }
)

sysmon.buttons.cpu = awful.util.table.join(
	awful.button({ }, 1, function() redflat.float.top:show("cpu") end)
)

-- RAM usage
sysmon.widget.ram = redflat.widget.sysmon(
	{ func = redflat.system.pformatted.mem(70) },
	{ timeout = 10, widget = redflat.gauge.monitor.dash }
)

sysmon.buttons.ram = awful.util.table.join(
	awful.button({ }, 1, function() redflat.float.top:show("mem") end)
)


-- Screen setup
-----------------------------------------------------------------------------------------------------------------------

-- setup
awful.screen.connect_for_each_screen(
	function(s)
		-- wallpaper
		env.wallpaper(s)

		-- tags
		awful.tag(taglist.names, s, taglist.layouts)

		-- layoutbox widget
		layoutbox[s] = redflat.widget.layoutbox({ screen = s })

		-- taglist widget
		taglist[s] = redflat.widget.taglist(
			{ screen = s, buttons = taglist.buttons, hint = env.tagtip, layout = taglist.layout }, taglist.style
		)

		-- tasklist widget
		tasklist[s] = redflat.widget.tasklist({ screen = s, buttons = tasklist.buttons }, tasklist.style)

		-- panel wibox
		s.panel = awful.wibar({ position = "bottom", screen = s, height = beautiful.panel_height or 36 })

		-- add widgets to the wibox
		s.panel:setup {
			layout = wibox.layout.align.horizontal,
			{ -- left widgets
				layout = wibox.layout.fixed.horizontal,

				env.wrapper(layoutbox[s], "layoutbox", layoutbox.buttons),
				separator,
				env.wrapper(taglist[s], "taglist"),
				separator,
				env.wrapper(kbindicator.widget, "keyboard", kbindicator.buttons),
				separator,
				env.wrapper(mail.widget, "mail", mail.buttons),
				separator,
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
				env.wrapper(updates.widget, "updates", updates.buttons),
				separator,
				env.wrapper(sysmon.widget.network, "network"),
				separator,
				env.wrapper(microphone.widget, "microphone", microphone.buttons),
				separator,
				env.wrapper(volume.widget, "volume", volume.buttons),
				separator,
				env.wrapper(sysmon.widget.cpu, "cpu", sysmon.buttons.cpu),
				env.wrapper(sysmon.widget.ram, "ram", sysmon.buttons.ram),
				env.wrapper(sysmon.widget.battery, "battery"),
				separator,
				env.wrapper(textclock.widget, "textclock"),
				separator,
				env.wrapper(tray.widget, "tray", tray.buttons),
			},
		}
	end
)


-- Desktop widgets
-----------------------------------------------------------------------------------------------------------------------
if not lock.desktop then
	local desktop = require("shade.ruby.desktop-config") -- load file with desktop widgets configuration
	desktop:init({
		env = env,
		buttons = awful.util.table.join(awful.button({}, 3, function () mymenu.mainmenu:toggle() end))
	})
end


-- Active screen edges
-----------------------------------------------------------------------------------------------------------------------
local edges = require("shade.ruby.edges-config") -- load file with edges configuration
edges:init({ tag_cols_num = taglist.cols_num })


-- Key bindings
-----------------------------------------------------------------------------------------------------------------------
local appkeys = require("color.blue.appkeys-config") -- load file with application keys sheet

local hotkeys = require("shade.ruby.keys-config") -- load file with hotkeys configuration
hotkeys:init({
	env = env, menu = mymenu.mainmenu, appkeys = appkeys, tag_cols_num = taglist.cols_num,
	microphone = microphone.widget, volume = volume.widget
 })


-- Rules
-----------------------------------------------------------------------------------------------------------------------
local rules = require("color.blue.rules-config") -- load file with rules configuration
rules:init({ env = env, hotkeys = hotkeys })


-- Titlebar setup
-----------------------------------------------------------------------------------------------------------------------
local titlebar = require("shade.ruby.titlebar-config") -- load file with titlebar configuration
titlebar:init()


-- Base signal set for awesome wm
-----------------------------------------------------------------------------------------------------------------------
local signals = require("colorless.signals-config") -- load file with signals configuration
signals:init({ env = env })


-- Autostart user applications
-----------------------------------------------------------------------------------------------------------------------
if redflat.startup.is_startup then
	local autostart = require("color.blue.autostart-config") -- load file with autostart application list
	autostart.run()
end
