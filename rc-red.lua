-----------------------------------------------------------------------------------------------------------------------
--                                                    Red config                                                     --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------

-- Standard awesome library
------------------------------------------------------------
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
local wibox = require("wibox")
local beautiful = require("beautiful")
--local naughty = require("naughty")
naughty = require("naughty")

require("awful.autofocus")

-- User modules
------------------------------------------------------------
timestamp = require("redflat.timestamp")
-- asyncshell = require("redflat.asyncshell")

local lain = require("lain")
local redflat = require("redflat")

local system = redflat.system
local separator = redflat.gauge.separator

-- Error handling
-----------------------------------------------------------------------------------------------------------------------
if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title  = "Oops, there were errors during startup!",
		text   = awesome.startup_errors
	})
end

do
	local in_error = false
	awesome.connect_signal("debug::error",
		function (err)
			if in_error then return end

			in_error = true
			naughty.notify({
				preset  = naughty.config.presets.critical,
				title   = "Oops, an error happened!",
				text    = err
			})
			in_error = false
		end
	)
end

-- Environment
-----------------------------------------------------------------------------------------------------------------------
local theme_path = os.getenv("HOME") .. "/.config/awesome/themes/red"
beautiful.init(theme_path .. "/theme.lua")

local terminal = "urxvt"
local editor   = os.getenv("EDITOR") or "geany"
local editor_cmd = terminal .. " -e " .. editor
local fm = "nemo"
local modkey = "Mod4"

-- Layouts setup
-----------------------------------------------------------------------------------------------------------------------
local layouts = require("red.layout-config") -- load file with layouts configuration

-- Tags
-----------------------------------------------------------------------------------------------------------------------
local tags = {
	names  = { "Main", "Full", "Edit", "Read", "Free" },
	layout = { layouts[7], layouts[8], layouts[8], layouts[7], layouts[2] },
}

for s = 1, screen.count() do tags[s] = awful.tag(tags.names, s, tags.layout) end

-- Naughty config
-----------------------------------------------------------------------------------------------------------------------
naughty.config.padding = beautiful.useless_gap_width or 0

if beautiful.naughty_preset then
	naughty.config.presets.normal = beautiful.naughty_preset.normal
	naughty.config.presets.critical = beautiful.naughty_preset.critical
	naughty.config.presets.low = redflat.util.table.merge(naughty.config.presets.normal, { timeout = 3 })
end

-- Main menu configuration
-----------------------------------------------------------------------------------------------------------------------
local mymenu = require("red.menu-config") -- load file with menu configuration

local menu_icon_style = { custom_only = true, scalable_only = true }
local menu_sep = { widget = separator.horizontal({ margin = { 3, 3, 5, 5 } }) }
local menu_theme = { icon_margin = { 7, 10, 7, 7 }, auto_hotkey = true }

mainmenu = mymenu.build({ separator = menu_sep, fm = fm, theme = menu_theme, icon_style = menu_icon_style })

-- Panel widgets
-----------------------------------------------------------------------------------------------------------------------

-- check theme
local pmargin

if beautiful.widget and beautiful.widget.margin then
	pmargin = beautiful.widget.margin
else
	pmargin = { double_sep = {} }
end

-- Separators
--------------------------------------------------------------------------------
local single_sep = separator.vertical({ margin = pmargin.single_sep })

local double_sep = wibox.layout.fixed.horizontal()
double_sep:add(separator.vertical({ margin = pmargin.double_sep[1] }))
double_sep:add(separator.vertical({ margin = pmargin.double_sep[2] }))

-- Taglist configure
--------------------------------------------------------------------------------
local taglist = {}
taglist.style  = { separator = single_sep }
taglist.margin = pmargin.taglist

taglist.buttons = awful.util.table.join(
	awful.button({ modkey    }, 1, awful.client.movetotag),
	awful.button({           }, 1, awful.tag.viewonly    ),
	awful.button({           }, 2, awful.tag.viewtoggle  ),
	awful.button({ modkey    }, 3, awful.client.toggletag),
	awful.button({           }, 3, function(t) redflat.widget.layoutbox:toggle_menu(t)    end),
	awful.button({           }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
	awful.button({           }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
)

-- Software update indcator
-- this widget used as icon for main menu
--------------------------------------------------------------------------------
local upgrades = {}
upgrades.widget = redflat.widget.upgrades()
upgrades.layout = wibox.layout.margin(upgrades.widget, unpack(pmargin.upgrades or {}))

upgrades.widget:buttons(awful.util.table.join(
	awful.button({}, 1, function () mainmenu:toggle()           end),
	awful.button({}, 2, function () redflat.widget.upgrades:update() end)
))

-- Keyboard widget
--------------------------------------------------------------------------------
local kbindicator = {}
kbindicator.widget = redflat.widget.keyboard({ layouts = { "English", "Russian" } })
kbindicator.layout = wibox.layout.margin(kbindicator.widget, unpack(pmargin.kbindicator or {}))

kbindicator.widget:buttons(awful.util.table.join(
	awful.button({}, 1, function () redflat.widget.keyboard:toggle_menu() end),
	awful.button({}, 3, function () awful.util.spawn_with_shell("sleep 0.1 && xdotool key 133+64+65") end),
	awful.button({}, 4, function () redflat.widget.keyboard:toggle()      end),
	awful.button({}, 5, function () redflat.widget.keyboard:toggle(true)  end)
))

-- PA volume control
-- also this widget used for exaile control
--------------------------------------------------------------------------------
local volume = {}
volume.widget = redflat.widget.pulse()
volume.layout = wibox.layout.margin(volume.widget, unpack(pmargin.volume or {}))

volume.widget:buttons(awful.util.table.join(
	awful.button({}, 4, function() redflat.widget.pulse:change_volume()                end),
	awful.button({}, 5, function() redflat.widget.pulse:change_volume({ down = true }) end),
	awful.button({}, 3, function() redflat.float.exaile:show()                         end),
	awful.button({}, 2, function() redflat.widget.pulse:mute()                         end),
	awful.button({}, 1, function() redflat.float.exaile:action("PlayPause") end),
	awful.button({}, 8, function() redflat.float.exaile:action("Prev")      end),
	awful.button({}, 9, function() redflat.float.exaile:action("Next")      end)
))

-- Mail
--------------------------------------------------------------------------------
local mail_scripts      = { "mail1.py", "mail2.py" }
local mail_scripts_path = "/home/vorron/Documents/scripts/"

local mail = {}
mail.widget = redflat.widget.mail({ path = mail_scripts_path, scripts = mail_scripts })
mail.layout = wibox.layout.margin(mail.widget, unpack(pmargin.mail or {}))

-- buttons
mail.widget:buttons(awful.util.table.join(
	awful.button({ }, 1, function () awful.util.spawn_with_shell("claws-mail") end),
	awful.button({ }, 2, function () redflat.widget.mail:update()                   end)
))

-- Layoutbox configure
--------------------------------------------------------------------------------
local layoutbox = {}
layoutbox.margin = pmargin.layoutbox

layoutbox.buttons = awful.util.table.join(
	awful.button({ }, 1, function () awful.layout.inc(layouts, 1)  end),
	awful.button({ }, 3, function () redflat.widget.layoutbox:toggle_menu(awful.tag.selected(mouse.screen)) end),
	awful.button({ }, 4, function () awful.layout.inc(layouts, 1)  end),
	awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)
)

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

-- Tray widget
--------------------------------------------------------------------------------
local tray = {}
tray.widget = redflat.widget.minitray({ timeout = 10 })
tray.layout = wibox.layout.margin(tray.widget, unpack(pmargin.tray or {}))

tray.widget:buttons(awful.util.table.join(
	awful.button({}, 1, function() redflat.widget.minitray:toggle() end)
))

-- System resource monitoring widgets
--------------------------------------------------------------------------------
local netspeed  = { up   = 5 * 1024^2, down = 5 * 1024^2 }

local monitor = {
	cpu = redflat.widget.sysmon({ func = system.pformatted.cpu(80) }, { timeout = 2,  monitor = { label = "CPU" } }),
	mem = redflat.widget.sysmon({ func = system.pformatted.mem(80) }, { timeout = 10, monitor = { label = "RAM" } }),
	bat = redflat.widget.sysmon(
		{ func = system.pformatted.bat(15), arg = "BAT1" },
		{ timeout = 60, monitor = { label = "BAT" } }
	),
	net = redflat.widget.net({ interface = "wlan0", speed  = netspeed, autoscale = false }, { timeout = 2 })
}

monitor.cpu:buttons(awful.util.table.join(
	awful.button({ }, 1, function() redflat.float.top:show("cpu") end)
))

monitor.mem:buttons(awful.util.table.join(
	awful.button({ }, 1, function() redflat.float.top:show("mem") end)
))

-- Textclock widget
--------------------------------------------------------------------------------
local textclock = {}
textclock.widget = redflat.widget.textclock({ timeformat = "%H:%M", dateformat = "%b  %d  %a" })
textclock.layout = wibox.layout.margin(textclock.widget, unpack(pmargin.textclock or {}))

-- Panel wibox
-----------------------------------------------------------------------------------------------------------------------
local panel = {}
for s = 1, screen.count() do

	-- Create widget which will contains an icon indicating which layout we're using.
	layoutbox[s] = {}
	layoutbox[s].widget = redflat.widget.layoutbox({ screen = s, layouts = layouts })
	layoutbox[s].layout = wibox.layout.margin(layoutbox[s].widget, unpack(layoutbox.margin or {}))
	layoutbox[s].widget:buttons(layoutbox.buttons)

	-- Create a taglist widget
	taglist[s] = {}
	taglist[s].widget = redflat.widget.taglist(s, redflat.widget.taglist.filter.all, taglist.buttons, taglist.style)
	taglist[s].layout = wibox.layout.margin(taglist[s].widget, unpack(taglist.margin or {}))

	-- Create a tasklist widget
	tasklist[s] = redflat.widget.tasklist(s, redflat.widget.tasklist.filter.currenttags, tasklist.buttons)

	-- Create the wibox
	panel[s] = awful.wibox({ type = "normal", position = "bottom", screen = s , height = beautiful.panel_height or 50})

	-- Widgets that are aligned to the left
	local left_layout = wibox.layout.fixed.horizontal()
	local left_elements = {
		taglist[s].layout,   double_sep,
		upgrades.layout,     single_sep,
		kbindicator.layout,  single_sep,
		volume.layout,       single_sep,
		mail.layout,         single_sep,
		layoutbox[s].layout, double_sep
	}
	for _, element in ipairs(left_elements) do
		left_layout:add(element)
	end

	-- Widgets that are aligned to the right
	local right_layout = wibox.layout.fixed.horizontal()
	local right_elements = {
		double_sep, tray.layout,
		single_sep, monitor.bat,
		single_sep, monitor.mem,
		single_sep, monitor.cpu,
		single_sep, monitor.net,
		single_sep, textclock.layout
	}
	for _, element in ipairs(right_elements) do
		right_layout:add(element)
	end

	-- Center widgets are aligned to the left
	local middle_align = wibox.layout.align.horizontal()
	middle_align:set_left(tasklist[s])

	-- Now bring it all together (with the tasklist in the middle)
	local layout = wibox.layout.align.horizontal()
	layout:set_left(left_layout)
	layout:set_middle(middle_align)
	layout:set_right(right_layout)

	panel[s]:set_widget(layout)
end

-- Wallpaper setup
-----------------------------------------------------------------------------------------------------------------------
if beautiful.wallpaper and awful.util.file_readable(beautiful.wallpaper) then
	for s = 1, screen.count() do
		gears.wallpaper.maximized(beautiful.wallpaper, s, true)
	end
else
	gears.wallpaper.set("#161616")
end

-- Desktop widgets
-----------------------------------------------------------------------------------------------------------------------
local desktop = require("red.desktop-config") -- load file with desktop widgets configuration

desktop:init({ tpath = theme_path })

-- Active screen edges
-----------------------------------------------------------------------------------------------------------------------
local edges = require("red.edges-config") -- load file with edges configuration

edges:init({ width = 1})

-- Key bindings
-----------------------------------------------------------------------------------------------------------------------
local hotkeys = require("red.keys-config") -- load file with hotkeys configuration

hotkeys:init({ terminal = terminal, menu = mainmenu, mod = modkey, layouts = layouts })

-- set global keys
root.keys(hotkeys.global)

-- set global(desktop) mouse buttons
root.buttons(hotkeys.mouse.global)

-- Rules
-----------------------------------------------------------------------------------------------------------------------
local rules = require("red.rules-config") -- load file with rules configuration
local custom_rules = rules:build({ tags = tags })

local base_rule = {
	rule = {},
	properties = {
		border_width     = beautiful.border_width,
		border_color     = beautiful.border_normal,
		focus            = awful.client.focus.filter,
		keys             = hotkeys.client,
		buttons          = hotkeys.mouse.client,
		size_hints_honor = false
	}
}

table.insert(custom_rules, 1, base_rule)
awful.rules.rules = custom_rules

-- Windows titlebar config
-----------------------------------------------------------------------------------------------------------------------
local titlebar = require("red.titlebar-config") -- load file with titlebar configuration

local t_exceptions = { "Plugin-container", "Steam", "Key-mon", "Gvim" }

titlebar:init({ enable = true, exceptions = t_exceptions })

-- Signals setup
-----------------------------------------------------------------------------------------------------------------------

-- Sloppy focus config
--------------------------------------------------------------------------------
local sloppy_focus_enabled = false

local function catch_focus(c)
	if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier and awful.client.focus.filter(c) then
		client.focus = c
	end
end

-- For every new client
--------------------------------------------------------------------------------
client.connect_signal("manage",
	function (c, startup)

		-- Enable sloppy focus if need
		------------------------------------------------------------
		if sloppy_focus_enabled then
			c:connect_signal("mouse::enter", function(c) catch_focus(c) end)
		end

		-- Put windows in a smart way,
		-- only if they does not set an initial position
		------------------------------------------------------------
		if not startup then
			if hotkeys.settings.slave then awful.client.setslave(c) end
			if not c.size_hints.user_position and not c.size_hints.program_position then
				awful.placement.no_overlap(c, { awful.layout.suit.floating, redflat.layout.grid })
				awful.placement.no_offscreen(c)
			end
		end

		-- Create titlebar if need
		------------------------------------------------------------
		if titlebar.allowed(c) then
			titlebar.create(c)
		end
	end
)

-- Focus
--------------------------------------------------------------------------------
client.connect_signal("focus",   function(c) c.border_color = beautiful.border_focus  end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- On awesome exit or restart
--------------------------------------------------------------------------------
awesome.connect_signal("exit",
	function()
		redflat.titlebar.hide_all()
		--for _, c in ipairs(client:get(mouse.screen)) do c.hidden = false end
	end
)

-----------------------------------------------------------------------------------------------------------------------

---[[
-- Autostart user applications
-----------------------------------------------------------------------------------------------------------------------
local stamp = timestamp.get()

if not stamp or (os.time() - tonumber(stamp)) > 5 then
	-- utils
	awful.util.spawn_with_shell("compton")
	awful.util.spawn_with_shell("pulseaudio")
	awful.util.spawn_with_shell("/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1")
	awful.util.spawn_with_shell("nm-applet")
	awful.util.spawn_with_shell("bash /home/vorron/Documents/scripts/tmpfs_firefox.sh")
	awful.util.spawn_with_shell("xrdb -merge /home/vorron/.Xdefaults")

	-- keyboard layouts
	--awful.util.spawn_with_shell("setxkbmap -layout 'us,ru' -variant ',winkeys,winkeys' -option grp:caps_toggle")
	awful.util.spawn_with_shell("setxkbmap -layout 'us,ru' -variant ',winkeys,winkeys' -option grp:rctrl_toggle")
	awful.util.spawn_with_shell("xkbcomp $DISPLAY - | egrep -v 'group . = AltGr;' | xkbcomp - $DISPLAY")
	awful.util.spawn_with_shell("sleep 1 && bash /home/vorron/Documents/scripts/swapctrl.sh")
	awful.util.spawn_with_shell("kbdd")

	-- apps
	awful.util.spawn_with_shell("parcellite")
	awful.util.spawn_with_shell("exaile")
	awful.util.spawn_with_shell("sleep 0.5 && transmission-gtk -m")
end
--]]
