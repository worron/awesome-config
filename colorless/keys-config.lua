-----------------------------------------------------------------------------------------------------------------------
--                                          Hotkeys and mouse buttons config                                         --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local table = table

local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup").widget
-- local redflat = require("redflat")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local hotkeys = { mouse = {}, keys = {} }


-- Set key for widgets, layouts and other secondary stuff
-----------------------------------------------------------------------------------------------------------------------


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

	-- {{{ Key bindings
	self.keys.root = awful.util.table.join(
		awful.key({ env.mod,           }, "s",      hotkeys_popup.show_help,
				  {description="show help", group="awesome"}),
		awful.key({ env.mod,           }, "Left",   awful.tag.viewprev,
				  {description = "view previous", group = "tag"}),
		awful.key({ env.mod,           }, "Right",  awful.tag.viewnext,
				  {description = "view next", group = "tag"}),
		awful.key({ env.mod,           }, "Escape", awful.tag.history.restore,
				  {description = "go back", group = "tag"}),

		awful.key({ env.mod,           }, "j",
			function ()
				awful.client.focus.byidx( 1)
			end,
			{description = "focus next by index", group = "client"}
		),
		awful.key({ env.mod,           }, "k",
			function ()
				awful.client.focus.byidx(-1)
			end,
			{description = "focus previous by index", group = "client"}
		),
		awful.key({ env.mod,           }, "w", function () mymainmenu:show() end,
				  {description = "show main menu", group = "awesome"}),

		-- Layout manipulation
		awful.key({ env.mod, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
				  {description = "swap with next client by index", group = "client"}),
		awful.key({ env.mod, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
				  {description = "swap with previous client by index", group = "client"}),
		awful.key({ env.mod, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
				  {description = "focus the next screen", group = "screen"}),
		awful.key({ env.mod, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
				  {description = "focus the previous screen", group = "screen"}),
		awful.key({ env.mod,           }, "u", awful.client.urgent.jumpto,
				  {description = "jump to urgent client", group = "client"}),
		awful.key({ env.mod,           }, "Tab",
			function ()
				awful.client.focus.history.previous()
				if client.focus then
					client.focus:raise()
				end
			end,
			{description = "go back", group = "client"}),

		-- Standard program
		awful.key({ env.mod,           }, "Return", function () awful.spawn(env.terminal) end,
				  {description = "open a terminal", group = "launcher"}),
		awful.key({ env.mod, "Control" }, "r", awesome.restart,
				  {description = "reload awesome", group = "awesome"}),
		awful.key({ env.mod, "Shift"   }, "q", awesome.quit,
				  {description = "quit awesome", group = "awesome"}),

		awful.key({ env.mod,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
				  {description = "increase master width factor", group = "layout"}),
		awful.key({ env.mod,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
				  {description = "decrease master width factor", group = "layout"}),
		awful.key({ env.mod, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
				  {description = "increase the number of master clients", group = "layout"}),
		awful.key({ env.mod, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
				  {description = "decrease the number of master clients", group = "layout"}),
		awful.key({ env.mod, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
				  {description = "increase the number of columns", group = "layout"}),
		awful.key({ env.mod, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
				  {description = "decrease the number of columns", group = "layout"}),
		awful.key({ env.mod,           }, "space", function () awful.layout.inc( 1)                end,
				  {description = "select next", group = "layout"}),
		awful.key({ env.mod, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
				  {description = "select previous", group = "layout"}),

		awful.key({ env.mod, "Control" }, "n",
				  function ()
					  local c = awful.client.restore()
					  -- Focus restored client
					  if c then
						  client.focus = c
						  c:raise()
					  end
				  end,
				  {description = "restore minimized", group = "client"}),

		-- Prompt
		awful.key({ env.mod },            "r",     function () awful.screen.focused().mypromptbox:run() end,
				  {description = "run prompt", group = "launcher"}),

		awful.key({ env.mod }, "x",
				  function ()
					  awful.prompt.run {
						prompt       = "Run Lua code: ",
						textbox      = awful.screen.focused().mypromptbox.widget,
						exe_callback = awful.util.eval,
						history_path = awful.util.get_cache_dir() .. "/history_eval"
					  }
				  end,
				  {description = "lua execute prompt", group = "awesome"}),
		-- Menubar
		awful.key({ env.mod }, "p", function() menubar.show() end,
				  {description = "show the menubar", group = "launcher"})
	)

	self.keys.client = awful.util.table.join(
		awful.key({ env.mod,           }, "f",
			function (c)
				c.fullscreen = not c.fullscreen
				c:raise()
			end,
			{description = "toggle fullscreen", group = "client"}),
		awful.key({ env.mod, "Shift"   }, "c",      function (c) c:kill()                         end,
				  {description = "close", group = "client"}),
		awful.key({ env.mod, "Control" }, "space",  awful.client.floating.toggle                     ,
				  {description = "toggle floating", group = "client"}),
		awful.key({ env.mod, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
				  {description = "move to master", group = "client"}),
		awful.key({ env.mod,           }, "o",      function (c) c:move_to_screen()               end,
				  {description = "move to screen", group = "client"}),
		awful.key({ env.mod,           }, "t",      function (c) c.ontop = not c.ontop            end,
				  {description = "toggle keep on top", group = "client"}),
		awful.key({ env.mod,           }, "n",
			function (c)
				-- The client currently has the input focus, so it cannot be
				-- minimized, since minimized clients can't have the focus.
				c.minimized = true
			end ,
			{description = "minimize", group = "client"}),
		awful.key({ env.mod,           }, "m",
			function (c)
				c.maximized = not c.maximized
				c:raise()
			end ,
			{description = "maximize", group = "client"})
	)

	-- Bind all key numbers to tags.
	-- Be careful: we use keycodes to make it works on any keyboard layout.
	-- This should map on the top row of your keyboard, usually 1 to 9.
	for i = 1, 9 do
		self.keys.root = awful.util.table.join(self.keys.root,
			-- View tag only.
			awful.key({ env.mod }, "#" .. i + 9,
					  function ()
							local screen = awful.screen.focused()
							local tag = screen.tags[i]
							if tag then
							   tag:view_only()
							end
					  end,
					  {description = "view tag #"..i, group = "tag"}),
			-- Toggle tag display.
			awful.key({ env.mod, "Control" }, "#" .. i + 9,
					  function ()
						  local screen = awful.screen.focused()
						  local tag = screen.tags[i]
						  if tag then
							 awful.tag.viewtoggle(tag)
						  end
					  end,
					  {description = "toggle tag #" .. i, group = "tag"}),
			-- Move client to tag.
			awful.key({ env.mod, "Shift" }, "#" .. i + 9,
					  function ()
						  if client.focus then
							  local tag = client.focus.screen.tags[i]
							  if tag then
								  client.focus:move_to_tag(tag)
							  end
						 end
					  end,
					  {description = "move focused client to tag #"..i, group = "tag"}),
			-- Toggle tag on focused client.
			awful.key({ env.mod, "Control", "Shift" }, "#" .. i + 9,
					  function ()
						  if client.focus then
							  local tag = client.focus.screen.tags[i]
							  if tag then
								  client.focus:toggle_tag(tag)
							  end
						  end
					  end,
					  {description = "toggle focused client on tag #" .. i, group = "tag"})
		)
	end

	self.mouse.client = awful.util.table.join(
		awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
		awful.button({ env.mod }, 1, awful.mouse.client.move),
		awful.button({ env.mod }, 3, awful.mouse.client.resize)
	)

end

-- End
-----------------------------------------------------------------------------------------------------------------------
return hotkeys
