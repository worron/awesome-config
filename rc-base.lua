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
local naughty = require("naughty")

require("awful.autofocus")

-- User modules
------------------------------------------------------------
timestamp = require("redflat.timestamp")
asyncshell = require("redflat.asyncshell")

local redflat = require("redflat")
--local lain = require("lain")

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
--beautiful.init("/usr/share/awesome/themes/default/theme.lua")

local terminal = "x-terminal-emulator"
local editor   = os.getenv("EDITOR") or "geany"
local editor_cmd = terminal .. " -e " .. editor
local fm = "nemo"
local set_slave = true

local modkey = "Mod4"

-- Layouts setup
-----------------------------------------------------------------------------------------------------------------------
local layouts = {
	awful.layout.suit.floating,
	redflat.layout.grid,
	redflat.layout.map,

	--lain.layout.uselesstile,
	--lain.layout.uselesstile.left,
	--lain.layout.uselesstile.bottom,
	--lain.layout.uselessfair,
	awful.layout.suit.max,
	awful.layout.suit.max.fullscreen,
}

-- Set floating layouts for sawp util
redflat.util.floating_layout = { redflat.layout.grid }

-- Tags
-----------------------------------------------------------------------------------------------------------------------
local tags = {
	names  = { "Main", "Full", "Edit", "Read", "Free" },
	layout = { layouts[1], layouts[1], layouts[1], layouts[1], layouts[1] },
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
local mainmenu

do
	-- Menu configuration
	--------------------------------------------------------------------------------
	local icon_style = { custom_only = false, scalable_only = false }

	-- icon finder
	local function micon(name)
		return redflat.service.dfparser.lookup_icon(name, icon_style)
	end

	-- menu separator
	local menu_sep = { widget = separator.horizontal({ margin = { 3, 3, 5, 5 } }) }

	-- menu theme
	local menu_theme = {
		icon_margin = { 7, 10, 7, 7 },
		auto_hotkey = true
	}

	-- run commands
	local ed_command = editor_cmd .. " " .. awesome.conffile

	-- Build menu
	--------------------------------------------------------------------------------

	-- Application submenu
	------------------------------------------------------------
	local appmenu = redflat.service.dfparser.menu({ icons = icon_style, wm_name = "awesome" })

	-- Awesome submenu
	------------------------------------------------------------
	local awesomemenu = {
		{ "Manual",          terminal .. " -e man awesome", micon("help") },
		{ "Edit config",     ed_command,                    micon("gnome-system-config")  },
		{ "Restart",         awesome.restart,               micon("gnome-session-reboot") },
		{ "Quit",            awesome.quit,                  micon("exit")                 },
	}

	-- Main menu
	------------------------------------------------------------
	mainmenu = redflat.menu({ hide_timeout = 1, theme = menu_theme,
		items = {
			{ "Awesome",       awesomemenu, beautiful.icon and beautiful.icon.awesome },
			{ "Applications",  appmenu,     micon("distributor-logo") },
			menu_sep,
			{ "Open terminal", terminal,    micon("gnome-terminal") }
		}
	})
end

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
	awful.button({           }, 3, function(t) redflat.widget.layoutbox:toggle_menu(t)         end),
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
local tray = redflat.widget.minitray({ timeout = 10 })

tray:buttons(awful.util.table.join(
	awful.button({}, 1, function() redflat.widget.minitray:toggle() end)
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
	panel[s] = awful.wibox({ type = "normal", position = "bottom", screen = s , height = beautiful.panel_heigh or 50 })

	-- Widgets that are aligned to the left
	local left_layout = wibox.layout.fixed.horizontal()
	local left_elements = {
		taglist[s].layout,   double_sep,
		upgrades.layout,     single_sep,
		layoutbox[s].layout, double_sep
	}
	for _, element in ipairs(left_elements) do
		left_layout:add(element)
	end

	-- Widgets that are aligned to the right
	local right_layout = wibox.layout.fixed.horizontal()
	local right_elements = {
		double_sep, tray,
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
		awful.button({}, 1,
			function()
				if client.focus then client.focus.maximized = not client.focus.maximized end
			end
		),
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
	local sw = redflat.float.appswitcher
	local current = redflat.widget.tasklist.filter.currenttags
	local allscreen = redflat.widget.tasklist.filter.allscreen
	local laybox = redflat.widget.layoutbox

	-- key functions
	local focus_switch_byd = function(dir)
		return function()
			awful.client.focus.bydirection(dir)
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

	--other
	local function toggle_placement()
		set_slave = not set_slave
		redflat.float.notify:show({
			text = (set_slave and "Slave" or "Master") .. " placement",
			icon = beautiful.icon.warning
		})
	end

	-- Custom widget keys
	--------------------------------------------------------------------------------
	redflat.float.appswitcher.keys.next  = { "a", "A", "Tab" }
	redflat.float.appswitcher.keys.prev  = { "q", "Q", }
	redflat.float.appswitcher.keys.close = { "Super_L" }

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
		{
			args = { { modkey,           }, "F2", function () redflat.service.keyboard.handler() end },
			comment = "Window control mode"
		},
		{ comment = "Window focus" },
		{
			args = { { modkey,           }, "Right", focus_switch_byd("right"), },
			comment = "Focus right client"
		},
		{
			args = { { modkey,           }, "Left", focus_switch_byd("left"), },
			comment = "Focus left client"
		},
		{
			args = { { modkey,           }, "Up", focus_switch_byd("up"), },
			comment = "Focus client above"
		},
		{
			args = { { modkey,           }, "Down", focus_switch_byd("down"), },
			comment = "Focus client below"
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
			args = { { modkey, "Shift"   }, "Left", awful.tag.viewprev },
			comment = "View previous tag"
		},
		{
			args = { { modkey, "Shift"   }, "Right", awful.tag.viewnext },
			comment = "View next tag"
		},
		{
			args = { { modkey,           }, "Escape", awful.tag.history.restore },
			comment = "View previously selected tag set"
		},
		{ comment = "Widgets" },
		{
			args = { { modkey,           }, "x", function() redflat.float.top:show() end },
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
			args = { { modkey            }, "p", function () redflat.float.prompt:run() end },
			comment = "Run prompt"
		},
		{
			args = { { modkey            }, "r", function() redflat.float.apprunner:show() end },
			comment = "Allication launcher"
		},
		{
			args = { { modkey,           }, "i", function() redflat.widget.minitray:toggle() end },
			comment = "Show minitray"
		},
		{
			args = { { modkey,           }, "F1", function() redflat.float.hotkeys:show() end },
			comment = "Show hotkeys helper"
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
		{ comment = "Window manipulation" },
		--{
		--	args = { { modkey,           }, "F3", toggle_placement },
		--	comment = "Toggle master/slave placement"
		--},
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
		{ comment = "Titlebar" },
		{
			args = { { modkey,           }, "k", function (c) redflat.titlebar.toggle_group(client.focus) end },
			comment = "Switch to next client in group"
		},
		{
			args = { { modkey,           }, "j", function (c) redflat.titlebar.toggle_group(client.focus, true) end },
			comment = "Switch to previous client in group"
		},
		{
			args = { { modkey,           }, "t", function (c) redflat.titlebar.toggle_view(client.focus) end },
			comment = "Toggle focused titlebar view"
		},
		{
			args = { { modkey, "Shift"   }, "t", function (c) redflat.titlebar.toggle_view_all() end },
			comment = "Toggle all titlebar view"
		},
		{
			args = { { modkey, "Control" }, "t", function (c) redflat.titlebar.toggle(client.focus) end },
			comment = "Toggle focused titlebar visible"
		},
		{
			args = { { modkey, "Control", "Shift" }, "t", function (c) redflat.titlebar.toggle_all() end },
			comment = "Toggle all titlebar visible"
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
			args = { { modkey, "Control" }, "j", function () awful.client.incwfact(0.05) end },
			comment = "Increase window height factor by 5%"
		},
		{
			args = { { modkey, "Control" }, "k", function () awful.client.incwfact(-0.05) end },
			comment = "Decrease window height factor by 5%"
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
	globalkeys = redflat.util.table.join_raw(raw_globalkeys, awful.key)

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
			args = { { modkey,           }, "m", function (c) c.maximized = not c.maximized end },
			comment = "Maximize client"
		}
	}

	-- format raw keys to key objects
	clientkeys = redflat.util.table.join_raw(raw_clientkeys, awful.key)

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
	redflat.float.hotkeys.raw_keys = awful.util.table.join(raw_globalkeys, raw_clientkeys, num_tips)

end

-- set global keys
root.keys(globalkeys)

-- Client buttons
-----------------------------------------------------------------------------------------------------------------------
clientbuttons = awful.util.table.join(
	awful.button({                   }, 1, function (c) client.focus = c; c:raise() end),
	awful.button({                   }, 2, redflat.service.mouse.move),
	awful.button({ modkey            }, 3, redflat.service.mouse.resize),
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
		redflat.titlebar.hide_all()
	end
)

-----------------------------------------------------------------------------------------------------------------------

-- Autostart user applications
-----------------------------------------------------------------------------------------------------------------------
local stamp = timestamp.get()

if not stamp or (os.time() - tonumber(stamp)) > 5 then
	--awful.util.spawn_with_shell("compton")
end
