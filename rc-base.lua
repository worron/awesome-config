-----------------------------------------------------------------------------------------------------------------------
--                                                  RedFlat config                                                   --
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
asyncshell = require("redflat.asyncshell")

local redwidget = require("redflat.widget")
local floatwidget = require("redflat.float")
local redutil = require("redflat.util")
local separator = require("redflat.gauge.separator")
local redmenu = require("redflat.menu")
local redtitlebar = require("redflat.titlebar")
local reddesktop = require("redflat.desktop")
local system = require("redflat.system")

--local lain = require("lain")

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
local theme_path = os.getenv("HOME") .. "/.config/awesome/themes/redflat"
beautiful.init(theme_path .. "/theme.lua")

local terminal = "x-terminal-emulator"
local editor   = os.getenv("EDITOR") or "geany"
local editor_cmd = terminal .. " -e " .. editor
local fm = "nemo"

local modkey = "Mod4"

-- Layouts setup
-----------------------------------------------------------------------------------------------------------------------
local layouts = {
	awful.layout.suit.floating,
	--lain.layout.uselesstile,
	--lain.layout.uselesstile.left,
	--lain.layout.uselesstile.bottom,
	--lain.layout.uselessfair,
	awful.layout.suit.max,
	awful.layout.suit.max.fullscreen,

	--awful.layout.suit.fair,
	--awful.layout.suit.fair.horizontal,
	--awful.layout.suit.spiral,
	--awful.layout.suit.spiral.dwindle,
	--awful.layout.suit.magnifier
	--lain.layout.uselesstile.left,
	--lain.layout.uselessfair
}

-- Tags
-----------------------------------------------------------------------------------------------------------------------
local tags = {
	names  = { "Main", "Full", "Edit", "Read", "Free" },
	layout = { layouts[1], layouts[1], layouts[1], layouts[1], layouts[1] },
}

for s = 1, screen.count() do tags[s] = awful.tag(tags.names, s, tags.layout) end

-- Naughty config
-----------------------------------------------------------------------------------------------------------------------
naughty.config.padding = beautiful.useless_gap_width

naughty.config.presets.normal   = beautiful.naughty_preset.normal
naughty.config.presets.critical = beautiful.naughty_preset.critical

naughty.config.presets.low = redutil.table.merge(naughty.config.presets.normal, { timeout = 3 })

-- Main menu configuration
-----------------------------------------------------------------------------------------------------------------------
local mainmenu

do
	-- Menu configuration
	--------------------------------------------------------------------------------
	local icon_style = { custom_only = true, scalable_only = true }

	-- icon finder
	local function micon(name)
		return floatwidget.dfparser.lookup_icon(name, icon_style)
	end

	-- menu separator
	local menu_sep = { widget = separator.horizontal({ margin = { 3, 3, 5, 5 } }) }

	-- menu theme
	local menu_theme = {
		icon_margin = { 7, 10, 7, 7 },
		auto_hotkey = true
	}

	-- run commands
	local terminal_command = "gnome-terminal --hide-menubar"
	local suspend_command  = [[dbus-send --print-reply --system --dest='org.freedesktop.UPower'
	                          /org/freedesktop/UPower org.freedesktop.UPower.Suspend]]

	-- Build menu
	--------------------------------------------------------------------------------

	-- Application submenu
	------------------------------------------------------------
	local appmenu = floatwidget.dfparser.menu({ icons = icon_style, wm_name = "awesome" })

	-- Awesome submenu
	------------------------------------------------------------
	local awesomemenu = {
		{ "Edit config",     "geany " .. awesome.conffile,  micon("gnome-system-config")  },
		{ "Restart",         awesome.restart,               micon("gnome-session-reboot") },
		{ "Quit",            awesome.quit,                  micon("exit")                 },
		menu_sep,
		{ "Awesome config",  "nemo .config/awesome",        micon("folder-bookmarks") },
		{ "Awesome lib",     "nemo /usr/share/awesome/lib", micon("folder-bookmarks") }
	}

	-- Exit submenu
	------------------------------------------------------------
	local exitmenu = {
		{ "Reboot",          "user-shutdown -r now",      micon("gnome-session-reboot")  },
		{ "Switch user",     "dm-tool switch-to-greeter", micon("gnome-session-switch")  },
		{ "Suspend",         suspend_command ,            micon("gnome-session-suspend") }
	}

	-- Places submenu
	------------------------------------------------------------
	local placesmenu = {
		{ "Documents",   fm .. " Documents", micon("folder-documents") },
		{ "Downloads",   fm .. " Downloads", micon("folder-download")  },
		{ "Music",       fm .. " Music",     micon("folder-music")     },
		{ "Pictures",    fm .. " Pictures",  micon("folder-pictures")  },
		{ "Videos",      fm .. " Videos",    micon("folder-videos")    },
		menu_sep,
		{ "AMV",         fm .. " /mnt/media/video/AMV", micon("folder-bookmarks") }
	}

	-- Main menu
	------------------------------------------------------------
	mainmenu = redmenu({ hide_timeout = 1, theme = menu_theme,
		items = {
			{ "Awesome",         awesomemenu,            beautiful.path .. "/awesome.svg" },
			{ "Applications",    appmenu,                micon("distributor-logo")        },
			{ "Places",          placesmenu,             micon("folder_home"), key = "c"  },
			menu_sep,
			{ "Firefox",         "firefox",              micon("firefox")                 },
			--{ "Terminal",        terminal_command,       micon("gnome-terminal")          },
			{ "Nemo",            "nemo",                 micon("folder")                  },
			{ "Ranger",          "uxterm -e ranger",     micon("folder")                  },
			{ "Geany",           "geany",                micon("geany")                   },
			{ "Exaile",          "exaile",               micon("exaile")                  },
			menu_sep,
			{ "Exit",            exitmenu,               micon("exit")                    },
			{ "Shutdown",        "user-shutdown -h now", micon("system-shutdown")         }
		}
	})
end

-- Panel widgets
-----------------------------------------------------------------------------------------------------------------------

-- Separators
--------------------------------------------------------------------------------
local single_sep = separator.vertical({ margin = beautiful.widget.margin.single_sep })

local double_sep = wibox.layout.fixed.horizontal()
double_sep:add(separator.vertical({ margin = beautiful.widget.margin.double_sep[1] }))
double_sep:add(separator.vertical({ margin = beautiful.widget.margin.double_sep[2] }))

-- Taglist configure
--------------------------------------------------------------------------------
local taglist = {}
taglist.style  = { separator = single_sep }
taglist.margin = beautiful.widget.margin.taglist

taglist.buttons = awful.util.table.join(
	awful.button({ modkey    }, 1, awful.client.movetotag),
	awful.button({           }, 1, awful.tag.viewonly    ),
	awful.button({           }, 2, awful.tag.viewtoggle  ),
	awful.button({ modkey    }, 3, awful.client.toggletag),
	awful.button({           }, 3, function(t) redwidget.layoutbox:toggle_menu(t)         end),
	awful.button({           }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
	awful.button({           }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
)

-- Software update indcator
-- this widget used as icon for main menu
--------------------------------------------------------------------------------
local upgrades = {}
upgrades.widget = redwidget.upgrades()
upgrades.layout = wibox.layout.margin(upgrades.widget, unpack(beautiful.widget.margin.upgrades))

upgrades.widget:buttons(awful.util.table.join(
	awful.button({}, 1, function () mainmenu:toggle()           end),
	awful.button({}, 2, function () redwidget.upgrades:update() end)
))

--[[
-- Keyboard widget
--------------------------------------------------------------------------------
local kbindicator = {}
kbindicator.widget = redwidget.keyboard({ layouts = { "English", "Russian" } })
kbindicator.layout = wibox.layout.margin(kbindicator.widget, unpack(beautiful.widget.margin.kbindicator))

kbindicator.widget:buttons(awful.util.table.join(
	awful.button({}, 1, function () redwidget.keyboard:toggle_menu() end),
	awful.button({}, 3, function () awful.util.spawn_with_shell("sleep 0.1 && xdotool key 133+64+65") end),
	awful.button({}, 4, function () redwidget.keyboard:toggle()      end),
	awful.button({}, 5, function () redwidget.keyboard:toggle(true)  end)
))

-- PA volume control
-- also this widget used for exaile control
--------------------------------------------------------------------------------
local volume = {}
volume.widget = redwidget.pulse()
volume.layout = wibox.layout.margin(volume.widget, unpack(beautiful.widget.margin.volume))

volume.widget:buttons(awful.util.table.join(
	awful.button({}, 4, function() redwidget.pulse:change_volume()                end),
	awful.button({}, 5, function() redwidget.pulse:change_volume({ down = true }) end),
	awful.button({}, 3, function() floatwidget.exaile:show()                      end),
	awful.button({}, 2, function() redwidget.pulse:mute()                         end),
	awful.button({}, 1, function() floatwidget.exaile:action("PlayPause") end),
	awful.button({}, 8, function() floatwidget.exaile:action("Prev")      end),
	awful.button({}, 9, function() floatwidget.exaile:action("Next")      end)
))

-- Mail
--------------------------------------------------------------------------------
local mail_scripts      = { "mail1.py", "mail2.py" }
local mail_scripts_path = "/home/vorron/Documents/scripts/"

local mail = {}
mail.widget = redwidget.mail({ path = mail_scripts_path, scripts = mail_scripts })
mail.layout = wibox.layout.margin(mail.widget, unpack(beautiful.widget.margin.mail))

-- buttons
mail.widget:buttons(awful.util.table.join(
	awful.button({ }, 1, function () awful.util.spawn_with_shell("claws-mail") end),
	awful.button({ }, 2, function () redwidget.mail:update()                   end)
))
--]]

-- Layoutbox configure
--------------------------------------------------------------------------------
local layoutbox = {}
layoutbox.margin = beautiful.widget.margin.layoutbox

layoutbox.buttons = awful.util.table.join(
	awful.button({ }, 1, function () awful.layout.inc(layouts, 1)  end),
	awful.button({ }, 3, function () redwidget.layoutbox:toggle_menu(awful.tag.selected(mouse.screen)) end),
	awful.button({ }, 4, function () awful.layout.inc(layouts, 1)  end),
	awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)
)

-- Tasklist
--------------------------------------------------------------------------------
local tasklist = {}

tasklist.buttons = awful.util.table.join(
	awful.button({}, 1, redwidget.tasklist.action.select),
	awful.button({}, 2, redwidget.tasklist.action.close),
	awful.button({}, 3, redwidget.tasklist.action.menu),
	awful.button({}, 4, redwidget.tasklist.action.switch_next),
	awful.button({}, 5, redwidget.tasklist.action.switch_prev)
)

-- Tray widget
--------------------------------------------------------------------------------
local tray = redwidget.minitray({ timeout = 10 })

tray:buttons(awful.util.table.join(
	awful.button({}, 1, function() redwidget.minitray:toggle() end)
))

-- System resource monitoring widgets
--------------------------------------------------------------------------------
--local netspeed  = { up   = 60 * 1024, down = 650 * 1024 }

local monitor = {
	cpu = redwidget.sysmon({ label = "CPU", func = system.pformatted.cpu(80) }, { timeout = 2 }),
	mem = redwidget.sysmon({ label = "RAM", func = system.pformatted.mem(80) }, { timeout = 10 }),
	--bat = redwidget.sysmon({ label = "BAT", func = system.pformatted.bat(15), arg = "BAT1" }, { timeout = 60 }),
	--net = redwidget.net({ timeout = 2, interface = "wlan0", speed  = netspeed, autoscale = false })
}

monitor.cpu:buttons(awful.util.table.join(
	awful.button({ }, 1, function() floatwidget.top:show("cpu") end)
))

monitor.mem:buttons(awful.util.table.join(
	awful.button({ }, 1, function() floatwidget.top:show("mem") end)
))

-- Textclock widget
--------------------------------------------------------------------------------
local textclock = {}
textclock.widget = redwidget.textclock({ timeformat = "%H:%M", dateformat = "%b  %d  %a" })
textclock.layout = wibox.layout.margin(textclock.widget, unpack(beautiful.widget.margin.textclock))

-- Panel wibox
-----------------------------------------------------------------------------------------------------------------------
local panel = {}
for s = 1, screen.count() do

	-- Create widget which will contains an icon indicating which layout we're using.
	layoutbox[s] = {}
	layoutbox[s].widget = redwidget.layoutbox({ screen = s, layouts = layouts })
	layoutbox[s].layout = wibox.layout.margin(layoutbox[s].widget, unpack(layoutbox.margin))
	layoutbox[s].widget:buttons(layoutbox.buttons)

	-- Create a taglist widget
	taglist[s] = {}
	taglist[s].widget = redwidget.taglist(s, redwidget.taglist.filter.all, taglist.buttons, taglist.style)
	taglist[s].layout = wibox.layout.margin(taglist[s].widget, unpack(taglist.margin))

	-- Create a tasklist widget
	tasklist[s] = redwidget.tasklist(s, redwidget.tasklist.filter.currenttags, tasklist.buttons)

	-- Create the wibox
	panel[s] = awful.wibox({ type = "normal", position = "bottom", screen = s , height = 50})

	-- Widgets that are aligned to the left
	local left_layout = wibox.layout.fixed.horizontal()
	local left_elements = {
		taglist[s].layout,   double_sep,
		upgrades.layout,     single_sep,
		--kbindicator.layout,  single_sep,
		--volume.layout,       single_sep,
		--mail.layout,         single_sep,
		layoutbox[s].layout, double_sep
	}
	for _, element in ipairs(left_elements) do
		left_layout:add(element)
	end

	-- Widgets that are aligned to the right
	local right_layout = wibox.layout.fixed.horizontal()
	local right_elements = {
		double_sep, tray,
		--single_sep, monitor.bat,
		single_sep, monitor.mem,
		single_sep, monitor.cpu,
		--single_sep, monitor.net,
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
--[[
if beautiful.wallpaper then
	for s = 1, screen.count() do
		gears.wallpaper.maximized(beautiful.wallpaper, s, true)
	end
end
--]]

gears.wallpaper.set(beautiful.color.bg)

--[[
-- Desktop widgets
-----------------------------------------------------------------------------------------------------------------------
do
	-- desktop aliases
	local wgeometry = redutil.desktop.wgeometry
	local workarea = screen[mouse.screen].workarea

	-- placement
	local grid = beautiful.desktop.grid
	local places = beautiful.desktop.places

	-- Network speed
	--------------------------------------------------------------------------------
	local netspeed = { geometry = wgeometry(grid, places.netspeed, workarea) }

	netspeed.args = {
		interface    = "wlan0",
		maxspeed     = { up = 65*1024, down = 650*1024 },
		crit         = { up = 60*1024, down = 600*1024 },
		timeout      = 2,
		autoscale    = false
	}

	netspeed.style  = {}

	-- SSD speed
	--------------------------------------------------------------------------------
	local ssdspeed = { geometry = wgeometry(grid, places.ssdspeed, workarea) }

	ssdspeed.args = {
		interface = "sdb",
		meter_function = system.disk_speed,
		timeout   = 2,
		label     = "SOLID DISK"
	}

	ssdspeed.style = { unit = { { "B", -1 }, { "KB", 2 }, { "MB", 2048 } } }

	-- HDD speed
	--------------------------------------------------------------------------------
	local hddspeed = { geometry = wgeometry(grid, places.hddspeed, workarea) }

	hddspeed.args = {
		interface = "sdc",
		meter_function = system.disk_speed,
		timeout = 2,
		label = "HARD DISK"
	}

	hddspeed.style = awful.util.table.clone(ssdspeed.style)

	-- CPU and memory usage
	--------------------------------------------------------------------------------
	local cpu_storage = { cpu_total = {}, cpu_active = {} }
	local cpumem = { geometry = wgeometry(grid, places.cpumem, workarea) }

	cpumem.args = {
		corners = { num = 8, maxm = 100, crit = 90 },
		lines   = { { maxm = 100, crit = 80 }, { maxm = 100, crit = 80 } },
		meter   = { args = cpu_storage },
		timeout = 2
	}

	cpumem.style = {}

	-- Transmission info
	--------------------------------------------------------------------------------
	local transm = { geometry = wgeometry(grid, places.transm, workarea) }

	transm.args = {
		corners    = { num = 8, maxm = 100 },
		lines      = { { maxm = 55, unit = { { "SEED", - 1 } } }, { maxm = 600, unit = { { "DNLD", - 1 } } } },
		meter      = { func = system.transmission_parse },
		timeout    = 5,
		asyncshell = "transmission-remote -l"
	}

	transm.style = {
		digit_num = 1,
		image     = theme_path .. "/desktop/ed1.svg"
	}

	-- Disks
	--------------------------------------------------------------------------------
	local disks = { geometry = wgeometry(grid, places.disks, workarea) }

	disks.args = {
		sensors  = {
			{ meter_function = system.fs_info, maxm = 100, crit = 80, args = "/" },
			{ meter_function = system.fs_info, maxm = 100, crit = 80, args = "/home" },
			{ meter_function = system.fs_info, maxm = 100, crit = 80, args = "/opt" },
			{ meter_function = system.fs_info, maxm = 100, crit = 80, args = "/mnt/media" }
		},
		names   = {"root", "home", "misc", "data"},
		timeout = 300
	}

	disks.style = {
		unit      = { { "KB", 1 }, { "MB", 1024^1 }, { "GB", 1024^2 } },
		show_text = false
	}

	-- Temperature indicator
	--------------------------------------------------------------------------------
	local thermal = { geometry = wgeometry(grid, places.thermal, workarea) }

	thermal.args = {
		sensors = {
			{ meter_function = system.thermal.sensors, args = "'Physical id 0'", maxm = 100, crit = 75 },
			{ meter_function = system.thermal.hddtemp, args = {disk = "/dev/sdc"}, maxm = 60, crit = 45 },
			{ meter_function = system.thermal.nvoptimus, maxm = 105, crit = 80 }
		},
		names   = {"cpu", "hdd", "gpu"},
		timeout = 5
	}

	thermal.style = {
		unit      = { { "°C", -1 } },
		show_text = true
	}

	-- Initialize all desktop widgets
	--------------------------------------------------------------------------------
	netspeed.widget = reddesktop.speedgraph(netspeed.args, netspeed.geometry, netspeed.style)
	ssdspeed.widget = reddesktop.speedgraph(ssdspeed.args, ssdspeed.geometry, ssdspeed.style)
	hddspeed.widget = reddesktop.speedgraph(hddspeed.args, hddspeed.geometry, hddspeed.style)

	cpumem.widget = reddesktop.multim(cpumem.args, cpumem.geometry, cpumem.style)
	transm.widget = reddesktop.multim(transm.args, transm.geometry, transm.style)

	disks.widget   = reddesktop.dashpack(disks.args, disks.geometry, disks.style)
	thermal.widget = reddesktop.dashpack(thermal.args, thermal.geometry, thermal.style)
end
--]]

-- Active screen edges
-----------------------------------------------------------------------------------------------------------------------
do
	-- edge aliases
	local workarea = screen[mouse.screen].workarea
	local ew = 1 -- edge width

	local switcher = floatwidget.appswitcher
	local currenttags = redwidget.tasklist.filter.currenttags
	local allscreen   = redwidget.tasklist.filter.allscreen

	-- edge geometry
	local egeometry = {
		top   = { width = workarea.width - 2 * ew, height = ew , x = ew, y = 0 },
		right = { width = ew, height = workarea.height - ew, x = workarea.width - ew, y = ew },
		left  = { width = ew, height = workarea.height, x = 0, y = 0 }
	}

	-- Top
	--------------------------------------------------------------------------------
	local top = redutil.desktop.edge("horizontal")
	top.wibox:geometry(egeometry["top"])

	top.layout:buttons(awful.util.table.join(
		awful.button({}, 1, function() client.focus.maximized = not client.focus.maximized end),
		awful.button({}, 4, function() awful.tag.incmwfact( 0.05) end),
		awful.button({}, 5, function() awful.tag.incmwfact(-0.05) end)
	))

	-- Right
	--------------------------------------------------------------------------------
	local right = redutil.desktop.edge("vertical")
	right.wibox:geometry(egeometry["right"])

	right.layout:buttons(awful.util.table.join(
		awful.button({}, 5, function() awful.tag.viewnext(mouse.screen) end),
		awful.button({}, 4, function() awful.tag.viewprev(mouse.screen) end)
	))

	-- Left
	--------------------------------------------------------------------------------
	local left = redutil.desktop.edge("vertical", { ew, workarea.height - ew })
	left.wibox:geometry(egeometry["left"])

	left.area[1]:buttons(awful.util.table.join(
		awful.button({}, 4, function() switcher:show({ filter = allscreen })                 end),
		awful.button({}, 5, function() switcher:show({ filter = allscreen, reverse = true }) end)
	))

	left.area[2]:buttons(awful.util.table.join(
		awful.button({}, 9, function() if client.focus then client.focus.minimized = true end  end),
		awful.button({}, 4, function() switcher:show({ filter = currenttags })                 end),
		awful.button({}, 5, function() switcher:show({ filter = currenttags, reverse = true }) end)
	))

	left.wibox:connect_signal("mouse::leave", function() floatwidget.appswitcher:hide() end)
end

-- Mouse bindings
-----------------------------------------------------------------------------------------------------------------------
root.buttons(awful.util.table.join(
	awful.button({}, 3, function () mainmenu:toggle() end)
	--awful.button({}, 4, awful.tag.viewnext),
	--awful.button({}, 5, awful.tag.viewprev)
))

-- Key bindings
-----------------------------------------------------------------------------------------------------------------------
local globalkeys, clientkeys

do
	-- key aliases
	local sw = floatwidget.appswitcher
	local current = redwidget.tasklist.filter.currenttags
	local allscreen = redwidget.tasklist.filter.allscreen
	local br = floatwidget.brightness
	local laybox = redwidget.layoutbox

	-- key functions
	local focus_switch = function(i)
		return function ()
			awful.client.focus.byidx(i)
			if client.focus then client.focus:raise() end
		end
	end

	local focus_previous = function()
		awful.client.focus.history.previous()
		if client.focus then client.focus:raise() end
	end

	local swap_with_master = function()
		if client.focus then client.focus:swap(awful.client.getmaster()) end
	end

	-- !!! Filters from tasklist used in 'all' functions !!!
	-- !!! It's need a custom filter to best performance !!!
	local function minimize_all()
		for _, c in ipairs(client.get()) do
			if current(c, mouse.screen) then c.minimized = true end
		end
	end

	local function restore_all()
		for _, c in ipairs(client.get()) do
			if current(c, mouse.screen) and c.minimized then c.minimized = false end
		end
	end

	local function kill_all()
		for _, c in ipairs(client.get()) do
			if current(c, mouse.screen) then c:kill() end
		end
	end

	-- numeric key function
	local function naction(i, handler, is_tag)
		return function ()
			if is_tag or client.focus then
				local tag = awful.tag.gettags(is_tag and mouse.screen or client.focus.screen)[i]
				if tag then handler(tag) end
			end
		end
	end

	-- volume functions
	local volume_raise = function() redwidget.pulse:change_volume({ show_notify = true })              end
	local volume_lower = function() redwidget.pulse:change_volume({ show_notify = true, down = true }) end
	local volume_mute  = function() redwidget.pulse:mute() end

	-- Custom widget keys
	--------------------------------------------------------------------------------
	floatwidget.appswitcher.keys.next  = { "a", "A", "Tab" }
	floatwidget.appswitcher.keys.prev  = { "q", "Q", }
	floatwidget.appswitcher.keys.close = { "Super_L" }

	-- Global keys
	--------------------------------------------------------------------------------
	local raw_globalkeys = {
		{ comment = "Global keys" },
		{
			args = { { modkey,           }, "Return", function () awful.util.spawn(terminal) end },
			comment = "Spawn terminal emulator"
		},
		{
			args = { { modkey, "Control" }, "r", awesome.restart },
			comment = "Restart awesome"
		},
		{ comment = "Window focus" },
		{
			args = { { modkey,           }, "j", focus_switch( 1), },
			comment = "Focus next client"
		},
		{
			args = { { modkey,           }, "k", focus_switch(-1), },
			comment = "Focus previous client"
		},
		{
			args = { { modkey,           }, "u", awful.client.urgent.jumpto, },
			comment = "Focus first urgent client"
		},
		{
			args = { { modkey,           }, "Tab", focus_previous, },
			comment = "Return to previously focused client"
		},
		{ comment = "Tag navigation" },
		{
			args = { { modkey,           }, "Left", awful.tag.viewprev },
			comment = "View previous tag"
		},
		{
			args = { { modkey,           }, "Right", awful.tag.viewnext },
			comment = "View next tag"
		},
		{
			args = { { modkey,           }, "Escape", awful.tag.history.restore },
			comment = "View previously selected tag set"
		},
		{ comment = "Widgets" },
		{
			args = { { modkey,           }, "x", function() floatwidget.top:show() end },
			comment = "Show top widget"
		},
		{
			args = { { modkey,           }, "w", function() mainmenu:toggle() end },
			comment = "Open main menu"
		},
		{
			args = { { modkey,           }, "y", function () laybox:toggle_menu(awful.tag.selected(mouse.screen)) end},
			comment = "Open layout menu"
		},
		{
			args = { { modkey            }, "p", function () floatwidget.prompt:run() end },
			comment = "Run prompt"
		},
		{
			args = { { modkey            }, "r", function() floatwidget.apprunner:show() end },
			comment = "Allication launcher"
		},
		{
			args = { { modkey,           }, "i", function() redwidget.minitray:toggle() end },
			comment = "Show minitray"
		},
		{
			args = { { modkey            }, "e", function() floatwidget.exaile:show() end },
			comment = "Show exaile widget"
		},
		{
			args = { { modkey,           }, "z", function() floatwidget.hotkeys:show() end },
			comment = "Show hotkeys helper"
		},
		{
			args = { { modkey, "Control" }, "u", function () redwidget.upgrades:update() end },
			comment = "Check available upgrades"
		},
		{
			args = { { modkey, "Control" }, "m", function () redwidget.mail:update() end },
			comment = "Check new mail"
		},
		{ comment = "Application switcher" },
		{
			args = { { modkey            }, "a", nil, function() sw:show({ filter = current }) end },
			comment = "Switch to next with current tag"
		},
		{
			args = { { modkey            }, "q", nil, function() sw:show({ filter = current, reverse = true }) end },
			comment = "Switch to previous with current tag"
		},
		{
			args = { { modkey, "Shift"   }, "a", nil, function() sw:show({ filter = allscreen }) end },
			comment = "Switch to next through all tags"
		},
		{
			args = { { modkey, "Shift"   }, "q", nil, function() sw:show({ filter = allscreen, reverse = true }) end },
			comment = "Switch to previous through all tags"
		},
		--[[
		{ comment = "Exaile music player" },
		{
			args = { {                   }, "XF86AudioPlay", function() floatwidget.exaile:action("PlayPause") end },
			comment = "Play/Pause"
		},
		{
			args = { {                   }, "XF86AudioNext", function() floatwidget.exaile:action("Next") end },
			comment = "Next track"
		},
		{
			args = { {                   }, "XF86AudioPrev", function() floatwidget.exaile:action("Prev") end },
			comment = "Previous track"
		},
		{ comment = "Brightness control" },
		{
			args = { {                   }, "XF86MonBrightnessUp", function() br:change({ step = 0 }) end },
			comment = "Increase brightness"
		},
		{
			args = { {                   }, "XF86MonBrightnessDown", function() br:change({ step = 0, down = 1 }) end},
			comment = "Reduce brightness"
		},
		--]]
		{ comment = "Volume control" },
		{
			args = { {                   }, "XF86AudioRaiseVolume", volume_raise },
			comment = "Increase volume"
		},
		{
			args = { {                   }, "XF86AudioLowerVolume", volume_lower },
			comment = "Reduce volume"
		},
		{
			args = { { modkey,            }, "v", volume_mute },
			comment = "Toggle mute"
		},
		{ comment = "Window manipulation" },
		{
			args = { { modkey, "Shift"   }, "j", function () awful.client.swap.byidx(1) end },
			comment = "Switch client with next client"
		},
		{
			args = { { modkey, "Shift"   }, "k", function () awful.client.swap.byidx(-1) end },
			comment = "Switch client with previous client"
		},
		{
			args = { { modkey, "Control" }, "Return", swap_with_master },
			comment = "Swap focused client with master"
		},
		{
			args = { { modkey, "Control" }, "n", awful.client.restore },
			comment = "Restore first minmized client"
		},
		{
			args = { { modkey, "Shift" }, "n", minimize_all },
			comment = "Minmize all with current tag"
		},
		{
			args = { { modkey, "Control", "Shift" }, "n", restore_all },
			comment = "Restore all with current tag"
		},
		{
			args = { { modkey, "Shift"   }, "F4", kill_all },
			comment = "Kill all with current tag"
		},
		{ comment = "Layouts" },
		{
			args = { { modkey,           }, "space", function () awful.layout.inc(layouts, 1) end },
			comment = "Switch to next layout"
		},
		{
			args = { { modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, - 1) end },
			comment = "Switch to previous layout"
		},
		{ comment = "Tile control" },
		{
			args = { { modkey,           }, "l", function () awful.tag.incmwfact(0.05) end },
			comment = "Increase master width factor by 5%"
		},
		{
			args = { { modkey,           }, "h", function () awful.tag.incmwfact(-0.05) end },
			comment = "Decrease master width factor by 5%"
		},
		{
			args = { { modkey, "Shift"   }, "h", function () awful.tag.incnmaster(1) end },
			comment = "Increase number of master windows by 1"
		},
		{
			args = { { modkey, "Shift"   }, "l", function () awful.tag.incnmaster(-1) end },
			comment = "Decrease number of master windows by 1"
		},
		{
			args = { { modkey, "Control" }, "h", function () awful.tag.incncol(1) end },
			comment = "Increase number of non-master columns by 1"
		},
		{
			args = { { modkey, "Control" }, "l", function () awful.tag.incncol(-1) end },
			comment = "Decrease number of non-master columns by 1"
		}
	}

	-- format raw keys to key objects
	globalkeys = redutil.table.join_raw(raw_globalkeys, awful.key)

	-- Client keys
	--------------------------------------------------------------------------------
	local raw_clientkeys = {
		{ comment = "Client keys" }, -- fake element special for hotkeys helper
		{
			args = { { modkey,           }, "f", function (c) c.fullscreen = not c.fullscreen end },
			comment = "Set client fullscreen"
		},
		{
			args = { { modkey,           }, "s", function (c) c.sticky = not c.sticky end },
			comment = "Toogle client sticky status"
		},
		{
			args = { { modkey,           }, "F4", function (c) c:kill() end },
			comment = "Kill focused client"
		},
		{
			args = { { modkey, "Control" }, "f", awful.client.floating.toggle },
			comment = "Toggle client floating status"
		},
		{
			args = { { modkey,           }, "t", function (c) c.ontop = not c.ontop end },
			comment = "Toggle client ontop status"
		},
		{
			args = { { modkey,           }, "n", function (c) c.minimized = true end },
			comment = "Minimize client"
		},
		{
			args = { { modkey,           }, "m",      function (c) c.maximized = not c.maximized    end },
			comment = "Maximize client"
		}
	}

	-- format raw keys to key objects
	clientkeys = redutil.table.join_raw(raw_clientkeys, awful.key)

	-- Bind all key numbers to tags
	--------------------------------------------------------------------------------
	local num_tips = { { comment = "Numeric keys" } } -- this is special for hotkey helper

	local num_bindings = {
		{
			mod     = { modkey },
			args    = { awful.tag.viewonly, true },
			comment = "Switch to tag"
		},
		{
			mod     = { modkey, "Control" },
			args    = { awful.tag.viewtoggle, true },
			comment = "Toggle tag view"
		},
		{
			mod     = { modkey, "Shift" },
			args    = { awful.client.movetotag },
			comment = "Tag client with tag"
		},
		{
			mod     = { modkey, "Control", "Shift" },
			args    = { awful.client.toggletag },
			comment = "Toggle tag on client"
		}
	}

	-- bind
	for k, v in ipairs(num_bindings) do
		-- add fake key to tip table
		num_tips[k + 1] = { args = { v.mod, "1 .. 9" }, comment = v.comment, codes = {} }
		for i = 1, 9 do
			table.insert(num_tips[k + 1].codes, i + 9)
			-- add numerical key objects to global
			globalkeys = awful.util.table.join(globalkeys, awful.key(v.mod, "#" .. i + 9, naction(i, unpack(v.args))))
		end
	end

	-- Hotkeys helper setup
	--------------------------------------------------------------------------------
	floatwidget.hotkeys.raw_keys = awful.util.table.join(raw_globalkeys, raw_clientkeys, num_tips)

end

-- set global keys
root.keys(globalkeys)

-- Client buttons
-----------------------------------------------------------------------------------------------------------------------
clientbuttons = awful.util.table.join(
	awful.button({                   }, 1, function (c) client.focus = c; c:raise() end),
	awful.button({                   }, 2, awful.mouse.client.move),
	awful.button({ modkey            }, 3, awful.mouse.client.resize),
	awful.button({                   }, 8, function(c) c:kill() end)
)


-- Rules
-----------------------------------------------------------------------------------------------------------------------
awful.rules.rules = {
	{
		rule = {},
		properties = {
			border_width     = beautiful.border_width,
			border_color     = beautiful.border_normal,
			focus            = awful.client.focus.filter,
			keys             = clientkeys,
			buttons          = clientbuttons,
			size_hints_honor = false
		}
	},
	{
		rule       = { class = "Gimp" }, except = { role = "gimp-image-window" },
		properties = { floating = true }
	},
	{
		rule       = { class = "Firefox" }, except = { role = "browser" },
		properties = { floating = true }
	},
    {
		rule_any   = { class = { "pinentry", "Plugin-container" } },
		properties = { floating = true }
	},
    {
		rule = { class = "Exaile", type = "normal" },
		callback = function(c)
			awful.client.movetotag(tags[1][2], c)
			c.minimized = true
		end
	}
}


-- Windows titlebar config
-----------------------------------------------------------------------------------------------------------------------
local titlebar = {
	enabled    = true,
	exceptions = { "Plugin-container", "Steam" }
}

do
	-- Geometry
	--------------------------------------------------------------------------------
	local height = 8
	local border_margin = { 0, 0, 0, 4 }
	local icon_size = 30
	local icon_gap  = 10

	-- Support functions
	--------------------------------------------------------------------------------
	local function titlebar_action(c, action)
		return function()
			client.focus = c
			c:raise()
			action(c)
		end
	end

	local function on_maximize(c)
		if c.maximized_vertical then
			redtitlebar.hide(c)
		else
			redtitlebar.show(c)
		end
	end

	local function ticon(c, t_func, size, gap)
		return wibox.layout.margin(wibox.layout.constraint(t_func(c), "exact", size, nil), gap)
	end

	-- Function to check if titlebar needed for given window
	--------------------------------------------------------------------------------
	titlebar.allowed = function(c)
		return titlebar.enabled and (c.type == "normal")
		       and not awful.util.table.hasitem(titlebar.exceptions, c.class)
	end

	-- Function to construct titlebar
	--------------------------------------------------------------------------------
	titlebar.create = function(c)

		-- Construct titlebar layout
		------------------------------------------------------------
		local layout = wibox.layout.align.horizontal()

		-- Add focus icon
		------------------------------------------------------------
		local focus_layout = wibox.layout.constraint(redtitlebar.widget.focused(c), "exact", nil, nil)
		layout:set_middle(focus_layout)

		-- Add window state icons
		------------------------------------------------------------
		local state_layout = wibox.layout.fixed.horizontal()
		state_layout:add(ticon(c, redtitlebar.widget.floating, icon_size, icon_gap))
		state_layout:add(ticon(c, redtitlebar.widget.sticky,   icon_size, icon_gap))
		state_layout:add(ticon(c, redtitlebar.widget.ontop,    icon_size, icon_gap))
		layout:set_right(state_layout)

		-- Create titlebar
		------------------------------------------------------------
		redtitlebar(c, { size = height }):set_widget(wibox.layout.margin(layout, unpack(border_margin)))

		-- Mouse actions setup
		------------------------------------------------------------
		layout:buttons(awful.util.table.join(
			awful.button({}, 1, titlebar_action(c, awful.mouse.client.move)),
			awful.button({}, 3, titlebar_action(c, awful.mouse.client.resize))
		))

		-- Hide titlebar when window maximized
		------------------------------------------------------------
		if c.maximized_vertical then redtitlebar.hide(c) end
		c:connect_signal("property::maximized_vertical", on_maximize)
	end
end

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
			awful.client.setslave(c)
			if not c.size_hints.user_position and not c.size_hints.program_position then
				awful.placement.no_overlap(c)
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
		redtitlebar.hide_all()
	end
)

-----------------------------------------------------------------------------------------------------------------------

--[[
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

	-- keyboard layouts
	awful.util.spawn_with_shell("setxkbmap -layout 'us,ru' -variant ',winkeys,winkeys' -option grp:caps_toggle")
	awful.util.spawn_with_shell("xkbcomp $DISPLAY - | egrep -v 'group . = AltGr;' | xkbcomp - $DISPLAY")
	awful.util.spawn_with_shell("kbdd")

	-- apps
	awful.util.spawn_with_shell("parcellite")
	awful.util.spawn_with_shell("exaile")
	awful.util.spawn_with_shell("sleep 0.5 && transmission-gtk -m")
end
--]]
