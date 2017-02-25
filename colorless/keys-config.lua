-----------------------------------------------------------------------------------------------------------------------
--                                          Hotkeys and mouse buttons config                                         --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local table = table
local awful = require("awful")
local redflat = require("redflat")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local hotkeys = { mouse = {}, raw = {}, keys = {}, fake = {} }

-- key aliases
local apprunner = redflat.float.apprunner
local appswitcher = redflat.float.appswitcher
local current = redflat.widget.tasklist.filter.currenttags
local allscr = redflat.widget.tasklist.filter.allscreen
local laybox = redflat.widget.layoutbox
local redtip = redflat.float.hotkeys

-- Key support functions
-----------------------------------------------------------------------------------------------------------------------
local function focus_to_previous()
	awful.client.focus.history.previous()
	if client.focus then client.focus:raise() end
end

local function restore_client()
	local c = awful.client.restore()
	if c then client.focus = c; c:raise() end
end

local function tag_numkey(i, mod, action)
	return awful.key(
		mod, "#" .. i + 9,
		function ()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then action(tag) end
		end
	)
end

local function client_numkey(i, mod, action)
	return awful.key(
		mod, "#" .. i + 9,
		function ()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then action(tag) end
			end
		end
	)
end


-- Build hotkeys depended on config parameters
-----------------------------------------------------------------------------------------------------------------------
function hotkeys:init(args)

	-- Init vars
	------------------------------------------------------------
	local args = args or {}
	local env = args.env
	local mainmenu = args.menu

	self.mouse.root = (awful.util.table.join(
		awful.button({ }, 3, function () mainmenu:toggle() end),
		awful.button({ }, 4, awful.tag.viewnext),
		awful.button({ }, 5, awful.tag.viewprev)
	))

	-- Keys for widgets, layouts and other secondary stuff
	--------------------------------------------------------------------------------

	-- Apprunner widget
	------------------------------------------------------------
	local apprunner_keys = {
		{
			{ env.mod }, "k", function() apprunner:down() end,
			{ description = "Select next item", group = "Navigation" }
		},
		{
			{ env.mod }, "i", function() apprunner:up() end,
			{ description = "Select previous item", group = "Navigation" }
		},
	}

	apprunner:set_keys(awful.util.table.join(apprunner.keys, apprunner_keys))

	-- Menu widget
	------------------------------------------------------------
	local menu_keys = {
		{
			{ env.mod }, "k", redflat.menu.action.down,
			{ description = "Select next item", group = "Navigation" }
		},
		{
			{ env.mod }, "i", redflat.menu.action.up,
			{ description = "Select previous item", group = "Navigation" }
		},
		{
			{ env.mod }, "j", redflat.menu.action.back,
			{ description = "Go back", group = "Navigation" }
		},
		{
			{ env.mod }, "l", redflat.menu.action.enter,
			{ description = "Open submenu", group = "Navigation" }
		},
	}

	redflat.menu:set_keys(awful.util.table.join(redflat.menu.keys, menu_keys))

	-- Appswitcher
	------------------------------------------------------------
	appswitcher_keys = {
		{
			{ env.mod }, "a", function() appswitcher:switch() end,
			{ description = "Select next app", group = "Navigation" }
		},
		{
			{ env.mod }, "q", function() appswitcher:switch({ reverse = true }) end,
			{ description = "Select previous app", group = "Navigation" }
		},
		{
			{ env.mod }, "Super_L", function() appswitcher:hide() end,
			{ description = "Exit", group = "Action" }
		},
		{
			{}, "Escape", function() appswitcher:hide() end,
			{ description = "Exit", group = "Action" }
		},
		{
			{ env.mod }, "F1", function() redtip:show()  end,
			{ description = "Show hotkeys helper", group = "Help" }
		},
	}

	appswitcher:set_keys(appswitcher_keys)


	-- Global keys
	--------------------------------------------------------------------------------
	self.raw.root = {
		{
			{ env.mod }, "F1", function() redtip:show() end,
			{ description = "Show hotkeys helper", group = "Main" }
		},
		{
			{ env.mod }, "Left", awful.tag.viewprev,
			{ description = "View previous tag", group = "Tags" }
		},
		{
			{ env.mod }, "Right", awful.tag.viewnext,
			{ description = "View next tag", group = "Tags" }
		},
		{
			{ env.mod }, "Escape", awful.tag.history.restore,
			{ description = "Go previos tag", group = "Tags" }
		},
		{
			{ env.mod }, "w", function() mainmenu:show() end,
			{ description = "Show main menu", group = "Main" }
		},
		{
			{ env.mod }, "a", nil, function() appswitcher:show({ filter = current }) end,
			{ description = "Switch to next with current tag", group = "Launcher" }
		},
		{
			{ env.mod }, "q", nil, function() appswitcher:show({ filter = current, reverse = true }) end,
			{ description = "Switch to previous with current tag", group = "Launcher" }
		},
		{
			{ env.mod, "Shift" }, "a", nil, function() appswitcher:show({ filter = allscr }) end,
			{ description = "Switch to next through all tags", group = "Launcher" }
		},
		{
			{ env.mod, "Shift" }, "q", nil, function() appswitcher:show({ filter = allscr, reverse = true }) end,
			{ description = "Switch to previous through all tags", group = "Launcher" }
		},
		{
			{ env.mod }, "u", awful.client.urgent.jumpto,
			{ description = "Jump to urgent client", group = "Clients" }
		},
		{
			{ env.mod }, "Tab", focus_to_previous,
			{ description = "Go previos client", group = "Clients" }
		},
		{
			{ env.mod }, "Return", function() awful.spawn(env.terminal) end,
			{ description = "Open a terminal", group = "Launcher" }
		},
		{
			{ env.mod, "Control" }, "r", awesome.restart,
			{ description = "Reload awesome", group = "Main" }
		},
		{
			{ env.mod, "Control" }, "q", awesome.quit,
			{ description = "Quit awesome", group = "Main" }
		},
		{
			{ env.mod }, "y", function() laybox:toggle_menu(mouse.screen.selected_tag) end,
			{ description = "Show layout menu", group = "Layouts" }
		},
		{
			{ env.mod }, "space", function() awful.layout.inc(1) end,
			{ description = "Select next layout", group = "Layouts" }
		},
		{
			{ env.mod, "Shift" }, "space", function() awful.layout.inc(-1) end,
			{ description = "Select previous layout", group = "Layouts" }
		},
		{
			{ env.mod, "Control" }, "n", restore_client,
			{ description = "Restore minimized client", group = "Clients" }
		},
		{
			{ env.mod }, "r", function() apprunner:show() end,
			{ description = "Application launcher", group = "Launcher" }
		},
		{
			{ env.mod }, "p", function() redflat.float.prompt:run() end,
			{ description = "Show the prompt box", group = "Launcher" }
		},
	}

	-- Client keys
	--------------------------------------------------------------------------------
	self.raw.client = {
		{
			{ env.mod }, "f", function(c) c.fullscreen = not c.fullscreen; c:raise() end,
			{ description = "Toggle fullscreen", group = "Clients" }
		},
		{
			{ env.mod }, "F4", function(c) c:kill() end,
			{ description = "Close", group = "Clients" }
		},
		{
			{ env.mod, "Control" }, "space", awful.client.floating.toggle,
			{ description = "Toggle floating", group = "Clients" }
		},
		{
			{ env.mod }, "o", function(c) c.ontop = not c.ontop end,
			{ description = "Toggle keep on top", group = "Clients" }
		},
		{
			{ env.mod }, "n", function(c) c.minimized = true end,
			{ description = "Minimize", group = "Clients" }
		},
		{
			{ env.mod }, "m", function(c) c.maximized = not c.maximized; c:raise() end,
			{ description = "Maximize", group = "Clients" }
		}
	}

	self.keys.root = redflat.util.key.build(self.raw.root)
	self.keys.client = redflat.util.key.build(self.raw.client)

	-- Numkeys
	--------------------------------------------------------------------------------

	-- add real keys without description here
	for i = 1, 9 do
		self.keys.root = awful.util.table.join(
			self.keys.root,
			tag_numkey(i,    { env.mod },                     function(t) t:view_only()               end),
			tag_numkey(i,    { env.mod, "Control" },          function(t) awful.tag.viewtoggle(t)     end),
			client_numkey(i, { env.mod, "Shift" },            function(t) client.focus:move_to_tag(t) end),
			client_numkey(i, { env.mod, "Control", "Shift" }, function(t) client.focus:toggle_tag(t)  end)
		)
	end

	-- make fake keys with description special for key helper widget
	local numkeys = { "1", "2", "3", "4", "5", "6", "7", "8", "9" }

	self.fake.numkeys = {
		{
			{ env.mod }, "1 .. 9", nil,
			{ description = "Switch to tag", group = "Numkeys", keyset = numkeys }
		},
		{
			{ env.mod, "Control" }, "1 .. 9", nil,
			{ description = "Toggle tag", group = "Numkeys", keyset = numkeys }
		},
		{
			{ env.mod, "Shift" }, "1 .. 9", nil,
			{ description = "Move focused client to tag", group = "Numkeys", keyset = numkeys }
		},
		{
			{ env.mod, "Control", "Shift" }, "1 .. 9", nil,
			{ description = "Toggle focused client on tag", group = "Numkeys", keyset = numkeys }
		},
	}

	-- Hotkeys helper setup
	--------------------------------------------------------------------------------
	redflat.float.hotkeys:set_pack("Main", awful.util.table.join(self.raw.root, self.raw.client, self.fake.numkeys), 2)

	-- Mouse buttons
	--------------------------------------------------------------------------------
	self.mouse.client = awful.util.table.join(
		awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
		awful.button({ env.mod }, 1, awful.mouse.client.move),
		awful.button({ env.mod }, 3, awful.mouse.client.resize)
	)

end

-- End
-----------------------------------------------------------------------------------------------------------------------
return hotkeys
