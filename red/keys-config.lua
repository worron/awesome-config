-----------------------------------------------------------------------------------------------------------------------
--                                          Hotkeys and mouse buttons config                                         --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local beautiful = require("beautiful")
local awful = require("awful")
local redflat = require("redflat")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local hotkeys = { settings = { slave = true}, mouse = {} }

-- key aliases
local sw = redflat.float.appswitcher
local current = redflat.widget.tasklist.filter.currenttags
local allscr = redflat.widget.tasklist.filter.allscreen
local laybox = redflat.widget.layoutbox
local tagsel = awful.tag.selected
local exaile = redflat.float.exaile
local redbar = redflat.titlebar

-- key functions
local br = function(args)
	redflat.float.brightness:change_with_gsd(args)
end

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
		if current(c, mouse.screen) and not c.sticky then c:kill() end
	end
end

local function minimize_all_else(c)
	thisScreen = client.focus.screen
	for _, cc in ipairs(client.get(c.screen)) do
		if current(cc, thisScreen) and cc.window ~= c.window then
			cc.minimized = true
		end
	end
end

local function has_minimized_one_else(c)
	for _, cc in ipairs(client.get(c.screen)) do
		if current(cc, client.focus.screen) and cc.minimized == true then
			return true
		end
	end
end

local function restore_all_else(c)
	for _, cc in ipairs(client.get(c.screen)) do
		if current(cc, client.focus.screen) and cc.minimized then cc.minimized = false end
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
local volume_raise = function() redflat.widget.pulse:change_volume({ show_notify = true })              end
local volume_lower = function() redflat.widget.pulse:change_volume({ show_notify = true, down = true }) end
local volume_mute  = function() redflat.widget.pulse:mute() end

--other
local function toggle_placement()
	hotkeys.settings.slave = not hotkeys.settings.slave
	redflat.float.notify:show({
		text = (hotkeys.settings.slave and "Slave" or "Master") .. " placement",
		icon = beautiful.icon and beautiful.icon.warning
	})
end

-- Set key for widgets, layouts and other secondary stuff
-----------------------------------------------------------------------------------------------------------------------

-- custom widget keys
redflat.float.appswitcher.keys.next  = { "a", "A", "Tab" }
redflat.float.appswitcher.keys.prev  = { "q", "Q", }
redflat.float.appswitcher.keys.close = { "Super_L", "Return", "Escape" }

-- layout keys
local resize_keys = {
	resize_up    = { "i", "I", },
	resize_down  = { "k", "K", },
	resize_left  = { "j", "J", },
	resize_right = { "l", "L", },
}

redflat.layout.common.keys = redflat.util.table.merge(redflat.layout.common.keys, resize_keys)
redflat.layout.grid.keys = redflat.util.table.merge(redflat.layout.grid.keys, resize_keys)
redflat.layout.map.keys = redflat.util.table.merge(redflat.layout.map.keys, resize_keys)
redflat.layout.map.keys = redflat.util.table.merge(redflat.layout.map.keys, { last = { "p", "P" } })

-- quick launcher settings
local launcher_keys = {}
for i = 1, 9 do launcher_keys["#" .. tostring(i + 9)] = { app = "", run = "" } end
local launcher_style = { service_hotkeys = { close = { "Escape" }, switch = { "Return" }} }

-- Build hotkeys depended on config parameters
-----------------------------------------------------------------------------------------------------------------------
function hotkeys:init(args)

	-- init vars
	local args = args or {}
	self.menu = args.menu or redflat.menu({ items = { {"Empty menu"} } })
	self.terminal = args.terminal or "x-terminal-emulator"
	self.mod = args.mod or "Mod4"
	self.qmod = args.qmod or "Mod1"
	self.need_helper = args.need_helper or true
	self.layouts = args.layouts

	-- quick launcher settings
	local launcher_settings = {
		keys = launcher_keys,
		switchmod = { self.mod, self.qmod            },
		setupmod  = { self.mod, self.qmod, "Control" },
		runmod    = { self.mod, self.qmod, "Shift"   }
	}

	redflat.float.qlaunch:init(launcher_settings, launcher_style)

	-- Global keys
	--------------------------------------------------------------------------------
	self.raw_global = {
		{ comment = "Global keys" },
		{
			args = { { self.mod,           }, "Return", function () awful.util.spawn(self.terminal) end },
			comment = "Spawn terminal emulator"
		},
		{
			args = { { self.mod, "Control" }, "r", awesome.restart },
			comment = "Restart awesome"
		},
		{
			args = { { self.mod,           }, "F2", function () redflat.service.keyboard.handler() end },
			comment = "Window control mode"
		},
		{ comment = "Window focus" },
		{
			args = { { self.mod,           }, "l", focus_switch_byd("right"), },
			comment = "Focus right client"
		},
		{
			args = { { self.mod,           }, "j", focus_switch_byd("left"), },
			comment = "Focus left client"
		},
		{
			args = { { self.mod,           }, "i", focus_switch_byd("up"), },
			comment = "Focus client above"
		},
		{
			args = { { self.mod,           }, "k", focus_switch_byd("down"), },
			comment = "Focus client below"
		},
		{
			args = { { self.mod,           }, "u", awful.client.urgent.jumpto, },
			comment = "Focus first urgent client"
		},
		{
			args = { { self.mod,           }, "Tab", focus_previous, },
			comment = "Return to previously focused client"
		},
		{ comment = "Tag navigation" },
		{
			args = { { self.mod,         }, "Left", awful.tag.viewprev },
			comment = "View previous tag"
		},
		{
			args = { { self.mod,         }, "Right", awful.tag.viewnext },
			comment = "View next tag"
		},
		{
			args = { { self.mod,           }, "Escape", awful.tag.history.restore },
			comment = "View previously selected tag set"
		},
		{ comment = "Widgets" },
		{
			args = { { self.mod,           }, "x", function() redflat.float.top:show() end },
			comment = "Show top widget"
		},
		{
			args = { { self.mod,           }, "w", function() hotkeys.menu:toggle() end },
			comment = "Open main menu"
		},
		{
			args = { { self.mod, self.qmod }, "w", function() redflat.float.qlaunch:show() end },
			comment = "Show quick launch widget"
		},
		{
			args = { { self.mod,           }, "y", function () laybox:toggle_menu(tagsel(mouse.screen)) end },
			comment = "Open layout menu"
		},
		{
			args = { { self.mod            }, "p", function () redflat.float.prompt:run() end },
			comment = "Run prompt"
		},
		{
			args = { { self.mod            }, "r", function() redflat.float.apprunner:show() end },
			comment = "Allication launcher"
		},
		{
			args = { { self.mod, "Control" }, "i", function() redflat.widget.minitray:toggle() end },
			comment = "Show minitray"
		},
		{
			args = { { self.mod            }, "e", function() exaile:show() end },
			comment = "Show exaile widget"
		},
		{
			args = { { self.mod,           }, "F1", function() redflat.float.hotkeys:show() end },
			comment = "Show hotkeys helper"
		},
		{
			args = { { self.mod, "Control" }, "u", function () redflat.widget.upgrades:update(true) end },
			comment = "Check available upgrades"
		},
		{
			args = { { self.mod, "Control" }, "m", function () redflat.widget.mail:update() end },
			comment = "Check new mail"
		},
		{ comment = "Application switcher" },
		{
			args = { { self.mod            }, "a", nil, function() sw:show({ filter = current }) end },
			comment = "Switch to next with current tag"
		},
		{
			args = { { self.mod            }, "q", nil, function() sw:show({ filter = current, reverse = true }) end },
			comment = "Switch to previous with current tag"
		},
		{
			args = { { self.mod, "Shift"   }, "a", nil, function() sw:show({ filter = allscr }) end },
			comment = "Switch to next through all tags"
		},
		{
			args = { { self.mod, "Shift"   }, "q", nil, function() sw:show({ filter = allscr, reverse = true }) end },
			comment = "Switch to previous through all tags"
		},
		{ comment = "Exaile music player" },
		{
			args = { {                     }, "XF86AudioPlay", function() exaile:action("PlayPause") end },
			comment = "Play/Pause"
		},
		{
			args = { {                     }, "XF86AudioNext", function() exaile:action("Next") end },
			comment = "Next track"
		},
		{
			args = { {                     }, "XF86AudioPrev", function() exaile:action("Prev") end },
			comment = "Previous track"
		},
		{ comment = "Brightness control" },
		{
			args = { {                     }, "XF86MonBrightnessUp", function() br({ step = 1 }) end },
			comment = "Increase brightness"
		},
		{
			args = { {                     }, "XF86MonBrightnessDown", function() br({ step = 1, down = true }) end },
			comment = "Reduce brightness"
		},
		{ comment = "Volume control" },
		{
			args = { {                     }, "XF86AudioRaiseVolume", volume_raise },
			comment = "Increase volume"
		},
		{
			args = { {                    }, "XF86AudioLowerVolume", volume_lower },
			comment = "Reduce volume"
		},
		{
			args = { { self.mod,            }, "v", volume_mute },
			comment = "Toggle mute"
		},
		{ comment = "Window manipulation" },
		{
			args = { { self.mod,           }, "F3", toggle_placement },
			comment = "Toggle master/slave placement"
		},
		{
			args = { { self.mod, "Control" }, "Return", swap_with_master },
			comment = "Swap focused client with master"
		},
		{
			args = { { self.mod, "Control" }, "n", awful.client.restore },
			comment = "Restore first minmized client"
		},
		{
			args = { { self.mod, "Shift" }, "n", minimize_all },
			comment = "Minmize all with current tag"
		},
		{
			args = { { self.mod, "Control", "Shift" }, "n", restore_all },
			comment = "Restore all with current tag"
		},
		{
			args = { { self.mod, "Shift"   }, "F4", kill_all },
			comment = "Kill all with current tag"
		},
		{ comment = "Layouts" },
		{
			args = { { self.mod,           }, "Up", function () awful.layout.inc(self.layouts, 1) end },
			comment = "Switch to next layout"
		},
		{
			args = { { self.mod,           }, "Down", function () awful.layout.inc(self.layouts, - 1) end },
			comment = "Switch to previous layout"
		},
		{ comment = "Titlebar" },
		{
			args = { { self.mod,           }, "comma", function (c) redbar.toggle_group(client.focus) end },
			comment = "Switch to next client in group"
		},
		{
			args = { { self.mod,           }, "period", function (c) redbar.toggle_group(client.focus, true) end },
			comment = "Switch to previous client in group"
		},
		{
			args = { { self.mod,           }, "t", function (c) redbar.toggle_view(client.focus) end },
			comment = "Toggle focused titlebar view"
		},
		{
			args = { { self.mod, "Shift"   }, "t", function (c) redbar.toggle_view_all() end },
			comment = "Toggle all titlebar view"
		},
		{
			args = { { self.mod, "Control" }, "t", function (c) redbar.toggle(client.focus) end },
			comment = "Toggle focused titlebar visible"
		},
		{
			args = { { self.mod, "Control", "Shift" }, "t", function (c) redbar.toggle_all() end },
			comment = "Toggle all titlebar visible"
		},
		{ comment = "Tile control" },
		{
			args = { { self.mod, "Shift"   }, "j", function () awful.tag.incnmaster(1) end },
			comment = "Increase number of master windows by 1"
		},
		{
			args = { { self.mod, "Shift"   }, "l", function () awful.tag.incnmaster(-1) end },
			comment = "Decrease number of master windows by 1"
		},
		{
			args = { { self.mod, "Control" }, "j", function () awful.tag.incncol(1) end },
			comment = "Increase number of non-master columns by 1"
		},
		{
			args = { { self.mod, "Control" }, "l", function () awful.tag.incncol(-1) end },
			comment = "Decrease number of non-master columns by 1"
		}
	}

	-- Client keys
	--------------------------------------------------------------------------------
	self.raw_client = {
		{ comment = "Client keys" }, -- fake element special for hotkeys helper
		{
			args = { { self.mod,           }, "f", function (c) c.fullscreen = not c.fullscreen end },
			comment = "Set client fullscreen"
		},
		{
			args = { { self.mod,           }, "s", function (c) c.sticky = not c.sticky end },
			comment = "Toogle client sticky status"
		},
		{
			args = { { self.mod,           }, "F4", function (c) c:kill() end },
			comment = "Kill focused client"
		},
		{
			args = { { self.mod, "Control" }, "f", awful.client.floating.toggle },
			comment = "Toggle client floating status"
		},
		{
			args = { { self.mod,           }, "o", function (c) c.ontop = not c.ontop end },
			comment = "Toggle client ontop status"
		},
		{
			args = { { self.mod,           }, "n", function (c) c.minimized = true end },
			comment = "Minimize client"
		},
		{
			args = { { self.mod,           }, "m", function (c) c.maximized = not c.maximized end },
			comment = "Maximize client"
		}
	}

	-- Bind all key numbers to tags
	--------------------------------------------------------------------------------
	local num_tips = { { comment = "Numeric keys" } } -- this is special for hotkey helper

	local num_bindings = {
		{
			mod     = { self.mod },
			args    = { awful.tag.viewonly, true },
			comment = "Switch to tag"
		},
		{
			mod     = { self.mod, "Control" },
			args    = { awful.tag.viewtoggle, true },
			comment = "Toggle tag view"
		},
		{
			mod     = { self.mod, "Shift" },
			args    = { awful.client.movetotag },
			comment = "Tag client with tag"
		},
		{
			mod     = { self.mod, "Control", "Shift" },
			args    = { awful.client.toggletag },
			comment = "Toggle tag on client"
		}
	}

	-- bind
	self.num = {}

	for k, v in ipairs(num_bindings) do
		-- add fake key to tip table
		num_tips[k + 1] = { args = { v.mod, "1 .. 9" }, comment = v.comment, codes = {} }
		for i = 1, 9 do
			table.insert(num_tips[k + 1].codes, i + 9)
			-- add numerical key objects to global
			self.num = awful.util.table.join(
				self.num, awful.key(v.mod, "#" .. i + 9, naction(i, unpack(v.args)))
			)
		end
	end

	-- Mouse bindings
	--------------------------------------------------------------------------------

	-- global
	self.mouse.global = awful.util.table.join(
		awful.button({}, 3, function () self.menu:toggle() end)
		--awful.button({}, 4, awful.tag.viewnext),
		--awful.button({}, 5, awful.tag.viewprev)
	)

	-- client
	self.mouse.client = awful.util.table.join(
		awful.button({                     }, 1, function (c) client.focus = c; c:raise() end),
		awful.button({                     }, 2, redflat.service.mouse.move),
		awful.button({ self.mod            }, 3, redflat.service.mouse.resize),
		awful.button({                     }, 8, function(c) c:kill() end),
		awful.button({ self.mod            }, 4, function (c) minimize_all_else(c) end),
		awful.button({ self.mod            }, 5,
			function (c)
					if has_minimized_one_else(c) then restore_all_else(c) end
			end
		)
	)

	-- Hotkeys helper setup
	--------------------------------------------------------------------------------
	if self.need_helper then
		redflat.float.hotkeys.raw_keys = awful.util.table.join(self.raw_global, self.raw_client, num_tips)
	end

	self.client = redflat.util.table.join_raw(hotkeys.raw_client, awful.key)
	self.global = redflat.util.table.join_raw(hotkeys.raw_global, awful.key)
	self.global = awful.util.table.join(self.global, hotkeys.num)
	self.global = awful.util.table.join(self.global, redflat.float.qlaunch.hotkeys)
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return hotkeys
