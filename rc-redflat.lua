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
local theme_path = os.getenv("HOME") .. "/.config/awesome/themes/redflat"
beautiful.init(theme_path .. "/theme.lua")

local terminal = "urxvt"
local editor   = os.getenv("EDITOR") or "geany"
local editor_cmd = terminal .. " -e " .. editor
local fm = "nemo"
local modkey = "Mod4"

-- Layouts setup
-----------------------------------------------------------------------------------------------------------------------
local layouts = {
	awful.layout.suit.floating,
	redflat.layout.grid,
	lain.layout.uselesstile,
	lain.layout.uselesstile.left,
	lain.layout.uselesstile.bottom,
	lain.layout.uselessfair,
	redflat.layout.map,
	awful.layout.suit.max,
	awful.layout.suit.max.fullscreen,

	--awful.layout.suit.fair,
	--awful.layout.suit.tile,
	--awful.layout.suit.fair.horizontal,
	--awful.layout.suit.spiral,
	--awful.layout.suit.spiral.dwindle,
	--awful.layout.suit.magnifier
	--lain.layout.uselesstile.left,
	--lain.layout.uselessfair
}

-- Set handlers for user layouts
local red_move_handler = redflat.layout.common.mouse.move_handler
local red_resize_handler = redflat.layout.common.mouse.resize_handler
local red_key_handler = redflat.layout.common.keyboard.key_handler

red_move_handler[lain.layout.uselessfair]        = redflat.layout.common.mouse.handler.move.tile
red_move_handler[lain.layout.uselesstile]        = redflat.layout.common.mouse.handler.move.tile
red_move_handler[lain.layout.uselesstile.left]   = redflat.layout.common.mouse.handler.move.tile
red_move_handler[lain.layout.uselesstile.bottom] = redflat.layout.common.mouse.handler.move.tile

red_resize_handler[lain.layout.uselesstile]        = redflat.layout.common.mouse.handler.resize.tile.right
red_resize_handler[lain.layout.uselesstile.left]   = redflat.layout.common.mouse.handler.resize.tile.left
red_resize_handler[lain.layout.uselesstile.bottom] = redflat.layout.common.mouse.handler.resize.tile.bottom

red_key_handler[lain.layout.uselessfair]        = redflat.layout.common.keyboard.handler.fair
red_key_handler[lain.layout.uselesstile]        = redflat.layout.common.keyboard.handler.tile.right
red_key_handler[lain.layout.uselesstile.left]   = redflat.layout.common.keyboard.handler.tile.left
red_key_handler[lain.layout.uselesstile.bottom] = redflat.layout.common.keyboard.handler.tile.bottom

-- Set floating layouts for swap util
redflat.util.floating_layout = { redflat.layout.grid }

-- Set layouts prop
redflat.layout.map.autoaim = true

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
local mymenu = require("menu-config") -- load file with menu configuration

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
local netspeed  = { up   = 60 * 1024, down = 650 * 1024 }

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
do
	-- desktop aliases
	local wgeometry = redflat.util.desktop.wgeometry
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
		label     = "SOLID DRIVE"
	}

	ssdspeed.style = { unit = { { "B", -1 }, { "KB", 2 }, { "MB", 2048 } } }

	-- HDD speed
	--------------------------------------------------------------------------------
	local hddspeed = { geometry = wgeometry(grid, places.hddspeed, workarea) }

	hddspeed.args = {
		interface = "sdc",
		meter_function = system.disk_speed,
		timeout = 2,
		label = "HARD DRIVE"
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
	netspeed.widget = redflat.desktop.speedgraph(netspeed.args, netspeed.geometry, netspeed.style)
	ssdspeed.widget = redflat.desktop.speedgraph(ssdspeed.args, ssdspeed.geometry, ssdspeed.style)
	hddspeed.widget = redflat.desktop.speedgraph(hddspeed.args, hddspeed.geometry, hddspeed.style)

	cpumem.widget = redflat.desktop.multim(cpumem.args, cpumem.geometry, cpumem.style)
	transm.widget = redflat.desktop.multim(transm.args, transm.geometry, transm.style)

	disks.widget   = redflat.desktop.dashpack(disks.args, disks.geometry, disks.style)
	thermal.widget = redflat.desktop.dashpack(thermal.args, thermal.geometry, thermal.style)
end


-- Active screen edges
-----------------------------------------------------------------------------------------------------------------------
do
	-- edge aliases
	local workarea = screen[mouse.screen].workarea
	local ew = 1 -- edge width

	local switcher = redflat.float.appswitcher
	local currenttags = redflat.widget.tasklist.filter.currenttags
	local allscreen   = redflat.widget.tasklist.filter.allscreen

	-- edge geometry
	local egeometry = {
		top   = { width = workarea.width - 2 * ew, height = ew , x = ew, y = 0 },
		right = { width = ew, height = workarea.height - ew, x = workarea.width - ew, y = ew },
		left  = { width = ew, height = workarea.height, x = 0, y = 0 }
	}

	-- Top
	--------------------------------------------------------------------------------
	local top = redflat.util.desktop.edge("horizontal")
	top.wibox:geometry(egeometry["top"])

	top.layout:buttons(awful.util.table.join(
		awful.button({}, 1, function() client.focus.maximized = not client.focus.maximized end),
		awful.button({}, 4, function() awful.tag.incmwfact( 0.05) end),
		awful.button({}, 5, function() awful.tag.incmwfact(-0.05) end)
	))

	-- Right
	--------------------------------------------------------------------------------
	local right = redflat.util.desktop.edge("vertical")
	right.wibox:geometry(egeometry["right"])

	right.layout:buttons(awful.util.table.join(
		awful.button({}, 5, function() awful.tag.viewnext(mouse.screen) end),
		awful.button({}, 4, function() awful.tag.viewprev(mouse.screen) end)
	))

	-- Left
	--------------------------------------------------------------------------------
	local left = redflat.util.desktop.edge("vertical", { ew, workarea.height - ew })
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

	left.wibox:connect_signal("mouse::leave", function() redflat.float.appswitcher:hide() end)
end


-- Key bindings
-----------------------------------------------------------------------------------------------------------------------
local hotkeys = require("keys-config") -- load file with hotkets configuration

hotkeys:init({ terminal = terminal, menu = mainmenu, mod = modkey })

-- set global keys
root.keys(hotkeys.global)

-- set global(desktop) mouse buttons
root.buttons(hotkeys.mouse.global)


-- Rules
-----------------------------------------------------------------------------------------------------------------------
awful.rules.rules = {
	{
		rule = {},
		properties = {
			border_width     = beautiful.border_width,
			border_color     = beautiful.border_normal,
			focus            = awful.client.focus.filter,
			keys             = hotkeys.client,
			buttons          = hotkeys.mouse.client,
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
		rule       = { class = "Key-mon" },
		properties = { sticky = true }
	},
	{
		rule = { class = "Exaile" },
		callback = function(c)
			for _, exist in ipairs(awful.client.visible(c.screen)) do
				if c ~= exist and c.class == exist.class then
					awful.client.floating.set(c, true)
					return
				end
			end
			awful.client.movetotag(tags[1][2], c)
			c.minimized = true
		end
	}
}


-- Windows titlebar config
-----------------------------------------------------------------------------------------------------------------------
local titlebar = {
	enabled    = true,
	exceptions = { "Plugin-container", "Steam", "Key-mon", "Gvim" }
}

do
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
			redflat.titlebar.hide(c)
		else
			redflat.titlebar.show(c)
		end
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

		-- Create titlebar
		------------------------------------------------------------
		local full_style =  { size = 28, icon = { gap = 0, size = 25, angle = 0.50 } }
		local model = redflat.titlebar.model(c, { "floating", "sticky", "ontop" }, nil, full_style)
		redflat.titlebar(c, model):set_widget(model.widget)

		-- Mouse actions setup
		------------------------------------------------------------
		model.widget:buttons(awful.util.table.join(
			awful.button({}, 1, titlebar_action(c, redflat.service.mouse.move)),
			awful.button({}, 3, titlebar_action(c, redflat.service.mouse.resize))
		))

		-- Hide titlebar when window maximized
		------------------------------------------------------------
		if c.maximized_vertical then redflat.titlebar.hide(c) end
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
	awful.util.spawn_with_shell("setxkbmap -layout 'us,ru' -variant ',winkeys,winkeys' -option grp:alt_shift_toggle")
	awful.util.spawn_with_shell("xkbcomp $DISPLAY - | egrep -v 'group . = AltGr;' | xkbcomp - $DISPLAY")
	awful.util.spawn_with_shell("sleep 1 && bash /home/vorron/Documents/scripts/swapctrl.sh")
	awful.util.spawn_with_shell("kbdd")

	-- apps
	awful.util.spawn_with_shell("parcellite")
	awful.util.spawn_with_shell("exaile")
	awful.util.spawn_with_shell("sleep 0.5 && transmission-gtk -m")
end
--]]
