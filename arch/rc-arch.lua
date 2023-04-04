-----------------------------------------------------------------------------------------------------------------------
--                                                Arch config                                                   --
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
require("arch.ercheck-config") -- load file with error handling

-- Setup theme and environment vars
-----------------------------------------------------------------------------------------------------------------------
local env = require("arch.env-config") -- load file with environment
env:init()

-- Layouts setup
-----------------------------------------------------------------------------------------------------------------------
local layouts = require("arch.layout-config") -- load file with tile layouts setup
layouts:init()

-- Main menu configuration
-----------------------------------------------------------------------------------------------------------------------
local mymenu = require("arch.menu-config") -- load file with menu configuration
mymenu:init({
    env = env
})

-- Panel widgets
-----------------------------------------------------------------------------------------------------------------------

-- Separator
--------------------------------------------------------------------------------
local separator = redflat.gauge.separator.vertical()

-- Taglist widget
--------------------------------------------------------------------------------
local taglist = {}

taglist.style = {
    widget = redflat.gauge.tag.ruby.new,
    show_tip = true
}

-- double line taglist
taglist.cols_num = 6
taglist.rows_num = 2

taglist.layout = wibox.widget {
    expand = true,
    forced_num_rows = taglist.rows_num,
    forced_num_cols = taglist.cols_num,
    layout = wibox.layout.grid
}

-- buttons
taglist.buttons = awful.util.table.join(awful.button({}, 1, function(t)
    t:view_only()
end), awful.button({env.mod}, 1, function(t)
    if client.focus then
        client.focus:move_to_tag(t)
    end
end), awful.button({}, 2, awful.tag.viewtoggle), awful.button({}, 3, function(t)
    redflat.widget.layoutbox:toggle_menu(t)
end), awful.button({env.mod}, 3, function(t)
    if client.focus then
        client.focus:toggle_tag(t)
    end
end), awful.button({}, 4, function(t)
    awful.tag.viewnext(t.screen)
end), awful.button({}, 5, function(t)
    awful.tag.viewprev(t.screen)
end))

-- some tag settings which indirectky depends on row and columns number of taglist
taglist.names = {"Prime", "Full", "Code", "Edit", "Misc", "Game", "Spare", "Back", "Test", "Qemu", "Data", "Free"}

local al = awful.layout.layouts
taglist.layouts = {al[5], al[6], al[6], al[4], al[3], al[3], al[5], al[6], al[6], al[4], al[3], al[1]}

-- Tasklist
--------------------------------------------------------------------------------
local tasklist = {}

tasklist.buttons = awful.util.table.join(awful.button({}, 1, redflat.widget.tasklist.action.select),
    awful.button({}, 2, redflat.widget.tasklist.action.close), awful.button({}, 3, redflat.widget.tasklist.action.menu),
    awful.button({}, 4, redflat.widget.tasklist.action.switch_next),
    awful.button({}, 5, redflat.widget.tasklist.action.switch_prev))

-- Textclock widget
--------------------------------------------------------------------------------
os.setlocale(os.getenv("LANG")) -- to localize the clock
local textclock = {}
textclock.widget = redflat.widget.textclock({
    timeformat = "%H:%M",
    dateformat = "%b  %d  %a"
})

-- Layoutbox configure
--------------------------------------------------------------------------------
local layoutbox = {}

layoutbox.buttons = awful.util.table.join(awful.button({}, 1, function()
    awful.layout.inc(1)
end), awful.button({}, 3, function()
    redflat.widget.layoutbox:toggle_menu(mouse.screen.selected_tag)
end), awful.button({}, 4, function()
    awful.layout.inc(1)
end), awful.button({}, 5, function()
    awful.layout.inc(-1)
end))

-- Tray widget
--------------------------------------------------------------------------------
local tray = {}
tray.widget = redflat.widget.minitray()

tray.buttons = awful.util.table.join(awful.button({}, 1, function()
    redflat.widget.minitray:toggle()
end))

-- PA volume control
--------------------------------------------------------------------------------
local volume = {}
volume.widget = redflat.widget.pulse(nil, {
    widget = redflat.gauge.audio.blue.new
})

-- activate player widget
redflat.float.player:init({
    name = env.player
})

volume.buttons = awful.util.table.join(awful.button({}, 4, function()
    volume.widget:change_volume()
end), awful.button({}, 5, function()
    volume.widget:change_volume({
        down = true
    })
end), awful.button({}, 2, function()
    volume.widget:mute()
end), awful.button({}, 3, function()
    redflat.float.player:show()
end), awful.button({}, 1, function()
    redflat.float.player:action("PlayPause")
end), awful.button({}, 8, function()
    redflat.float.player:action("Previous")
end), awful.button({}, 9, function()
    redflat.float.player:action("Next")
end))

-- Keyboard layout indicator
--------------------------------------------------------------------------------
local kbindicator = {}
redflat.widget.keyboard:init({"English", "Russian"})
kbindicator.widget = redflat.widget.keyboard()

kbindicator.buttons = awful.util.table.join(awful.button({}, 1, function()
    redflat.widget.keyboard:toggle_menu()
end), awful.button({}, 4, function()
    redflat.widget.keyboard:toggle()
end), awful.button({}, 5, function()
    redflat.widget.keyboard:toggle(true)
end))

-- Software update indcator
--------------------------------------------------------------------------------
redflat.widget.updates:init({
    command = env.updates
})

local updates = {}
updates.widget = redflat.widget.updates()

updates.buttons = awful.util.table.join(awful.button({}, 1, function()
    redflat.widget.updates:toggle()
end), awful.button({}, 2, function()
    redflat.widget.updates:update(true)
end), awful.button({}, 3, function()
    redflat.widget.updates:toggle()
end))

-- System resource monitoring widgets
--------------------------------------------------------------------------------
local sysmon = {
    widget = {},
    buttons = {},
    icon = {}
}

-- icons
sysmon.icon.battery = redflat.util.table.check(beautiful, "wicon.battery")
sysmon.icon.network = redflat.util.table.check(beautiful, "wicon.wireless")
sysmon.icon.cpuram = redflat.util.table.check(beautiful, "wicon.monitor")

-- battery
--[[ sysmon.widget.battery = redflat.widget.sysmon(
	{ func = redflat.system.pformatted.bat(25), arg = "BAT0" },
	{ timeout = 60, widget = redflat.gauge.icon.single, monitor = { is_vertical = true, icon = sysmon.icon.battery } }
) ]]
sysmon.widget.battery = redflat.widget.battery({
    func = redflat.system.pformatted.bat(25),
    arg = "BAT0"
}, {
    timeout = 60,
    widget = redflat.gauge.monitor.dash
})

-- network speed
sysmon.widget.network = redflat.widget.net({
    interface = "wlo1",
    alert = {
        up = 5 * 1024 ^ 2,
        down = 5 * 1024 ^ 2
    },
    speed = {
        up = 6 * 1024 ^ 2,
        down = 6 * 1024 ^ 2
    },
    autoscale = false
}, {
    timeout = 2,
    widget = redflat.gauge.monitor.double,
    monitor = {
        icon = sysmon.icon.network
    }
})

-- CPU usage
sysmon.widget.cpu = redflat.widget.sysmon({
    func = redflat.system.pformatted.cpu(80)
}, {
    timeout = 2,
    widget = redflat.gauge.monitor.dash
})

sysmon.buttons.cpu = awful.util.table.join(awful.button({}, 1, function()
    redflat.float.top:show("cpu")
end))

-- RAM usage
sysmon.widget.ram = redflat.widget.sysmon({
    func = redflat.system.pformatted.mem(70)
}, {
    timeout = 10,
    widget = redflat.gauge.monitor.dash
})

sysmon.buttons.ram = awful.util.table.join(awful.button({}, 1, function()
    redflat.float.top:show("mem")
end))

-- CPU and RAM usage
local cpu_storage = {
    cpu_total = {},
    cpu_active = {}
}

local cpuram_func = function()
    local cpu_usage = redflat.system.cpu_usage(cpu_storage).total
    local mem_usage = redflat.system.memory_info().usep

    return {
        text = "CPU: " .. cpu_usage .. "%  " .. "RAM: " .. mem_usage .. "%",
        value = {cpu_usage / 100, mem_usage / 100},
        alert = cpu_usage > 80 or mem_usage > 70
    }
end

sysmon.widget.cpuram = redflat.widget.sysmon({
    func = cpuram_func
}, {
    timeout = 2,
    widget = redflat.gauge.monitor.double,
    monitor = {
        icon = sysmon.icon.cpuram
    }
})

sysmon.buttons.cpuram = awful.util.table.join(awful.button({}, 1, function()
    redflat.float.top:show("cpu")
end))

-- Screen setup
-----------------------------------------------------------------------------------------------------------------------
awful.screen.connect_for_each_screen(function(s)
    -- wallpaper
    env.wallpaper(s)

    -- tags
    awful.tag(taglist.names, s, taglist.layouts)

    -- layoutbox widget
    layoutbox[s] = redflat.widget.layoutbox({
        screen = s
    })

    -- taglist widget
    -- taglist[s] = redflat.widget.taglist({ screen = s, buttons = taglist.buttons, hint = env.tagtip }, taglist.style)
    taglist[s] = redflat.widget.taglist({
        screen = s,
        buttons = taglist.buttons,
        hint = env.tagtip,
        layout = taglist.layout
    }, taglist.style)

    -- tasklist widget
    tasklist[s] = redflat.widget.tasklist({
        screen = s,
        buttons = tasklist.buttons
    })

    -- panel wibox
    s.panel = awful.wibar({
        position = "bottom",
        screen = s,
        height = beautiful.panel_height or 36
    })

    -- add widgets to the wibox
    s.panel:setup{
        layout = wibox.layout.align.horizontal,
        { -- left widgets
            layout = wibox.layout.fixed.horizontal,

            env.wrapper(layoutbox[s], "layoutbox", layoutbox.buttons),
            separator,
            env.wrapper(mymenu.widget, "mainmenu", mymenu.buttons),
            separator,
            env.wrapper(taglist[s], "taglist"),
            separator,
            s.mypromptbox
        },
        { -- middle widget
            layout = wibox.layout.align.horizontal,
            expand = "outside",

            nil,
            env.wrapper(tasklist[s], "tasklist")
        },
        { -- right widgets
            layout = wibox.layout.fixed.horizontal,

            separator,
            env.wrapper(kbindicator.widget, "keyboard", kbindicator.buttons),
            separator,
            env.wrapper(volume.widget, "volume", volume.buttons),
            separator,
            env.wrapper(sysmon.widget.cpu, "cpu", sysmon.buttons.cpu),
            separator,
            env.wrapper(sysmon.widget.ram, "ram", sysmon.buttons.ram),
            separator,
            env.wrapper(sysmon.widget.battery, "battery"),
            separator,
            env.wrapper(sysmon.widget.network, "network"),
            separator,
            env.wrapper(updates.widget, "updates"),
            separator,
            env.wrapper(textclock.widget, "textclock"),
            separator,
            env.wrapper(tray.widget, "tray", tray.buttons)
        }
    }
end)

-- Desktop widgets
-----------------------------------------------------------------------------------------------------------------------
if not lock.desktop then
	local desktop = require("arch.desktop-config") -- load file with desktop widgets configuration
	desktop:init({
		env = env,
		buttons = awful.util.table.join(awful.button({}, 3, function () mymenu.mainmenu:toggle() end))
	})
end

-- Key bindings
-----------------------------------------------------------------------------------------------------------------------
local appkeys = require("color.blue.appkeys-config") -- load file with application keys sheet

local hotkeys = require("arch.keys-config") -- load file with hotkeys configuration
hotkeys:init({
    env = env,
    menu = mymenu.mainmenu,
    appkeys = appkeys,
    tag_cols_num = taglist.cols_num,
    volume = volume.widget
})

-- Rules
-----------------------------------------------------------------------------------------------------------------------
local rules = require("arch.rules-config") -- load file with rules configuration
rules:init({
    hotkeys = hotkeys
})

-- Titlebar setup
-----------------------------------------------------------------------------------------------------------------------
local titlebar = require("colorless.titlebar-config") -- load file with titlebar configuration
titlebar:init()

-- Base signal set for awesome wm
-----------------------------------------------------------------------------------------------------------------------
local signals = require("colorless.signals-config") -- load file with signals configuration
signals:init({
    env = env
})

-- Autostart user applications
-----------------------------------------------------------------------------------------------------------------------
-- if redflat.startup.is_startup then
-- 	local autostart = require("color.blue.autostart-config") -- load file with autostart application list
-- 	autostart.run()
-- end

-- Autostart applications
awful.spawn.with_shell("~/.config/awesome/autostart.sh")
awful.spawn.with_shell("picom -b --config  $HOME/.config/awesome/picom.conf")
