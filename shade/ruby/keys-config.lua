-----------------------------------------------------------------------------------------------------------------------
--                                          Hotkeys and mouse buttons config                                         --
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
local table = table
local unpack = unpack or table.unpack
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
local laycom = redflat.layout.common
local grid = redflat.layout.grid
local map = redflat.layout.map
local qlaunch = redflat.float.qlaunch
local numkeys_line = { "1", "2", "3", "4", "5", "6", "7", "8", "9" }
local tagkeys_line = { "q", "w", "e", "r", "t", "y", "u", "i", "o" }

-- Key support functions
-----------------------------------------------------------------------------------------------------------------------

-- change window focus by history
--loc function focus_to_previous()
--	awful.client.focus.history.previous()
--	if client.focus then client.focus:raise() end
--end

-- change window focus by direction
local focus_switch_byd = function(dir)
	return function()
		awful.client.focus.bydirection(dir)
		if client.focus then client.focus:raise() end
	end
end

-- minimize and restore windows
local function minimize_all()
	for _, c in ipairs(client.get()) do
		if current(c, mouse.screen) then c.minimized = true end
	end
end

local function minimize_all_except_focused()
	for _, c in ipairs(client.get()) do
		if current(c, mouse.screen) and c ~= client.focus then c.minimized = true end
	end
end

local function restore_all()
	for _, c in ipairs(client.get()) do
		if current(c, mouse.screen) and c.minimized then c.minimized = false end
	end
end

local function restore_client()
	local c = awful.client.restore()
	if c then client.focus = c; c:raise() end
end

-- close window
local function kill_all()
	for _, c in ipairs(client.get()) do
		if current(c, mouse.screen) and not c.sticky then c:kill() end
	end
end

-- window properties
local function client_property(p)
	if client.focus then client.focus[p] = not client.focus[p] end
end

-- new clients placement
local function toggle_placement(env)
	env.set_slave = not env.set_slave
	redflat.float.notify:show({ text = (env.set_slave and "Slave" or "Master") .. " placement" })
end

-- select next row tag on second key press
local function tag_double_select(i, colnum)
	local screen = awful.screen.focused()
	local tag = screen.tags[i]
	if tag.selected then
		tag = (i <= colnum) and screen.tags[i + colnum] or screen.tags[i - colnum]
		if tag then tag:view_only() end
	else
		tag:view_only()
	end
end

-- tag management by index
local function tag_toogle_by_index(i)
	awful.tag.viewtoggle(awful.screen.focused().tags[i])
end

local function current_clients()
	return awful.screen.focused().selected_tag:clients()
end

local function client_move_by_index(i, group)
	for _, c in ipairs(group) do
		c:move_to_tag(awful.screen.focused().tags[i])
	end
end

local function client_move_and_go_by_index(i, group)
	local tag = awful.screen.focused().tags[i]
	for _, c in ipairs(group) do c:move_to_tag(tag) end
	tag:view_only()
end

local function client_toggle_by_index(i, group)
	for _, c in ipairs(group) do
		c:toggle_tag(awful.screen.focused().tags[i])
	end
end

-- switch tag line
local function tag_line_switch(colnum)
	local screen = awful.screen.focused()
	local i = screen.selected_tag.index
	local tag = (i <= colnum) and screen.tags[i + colnum] or screen.tags[i - colnum]
	tag:view_only()
end

local function tag_line_jump(colnum, is_down)
	local screen = awful.screen.focused()
	local i = screen.selected_tag.index
	local tag = is_down and screen.tags[i + colnum] or screen.tags[i - colnum]
	if tag then tag:view_only() end
end

-- swap clients between tag lines
local function clients_swap_by_line(colnum)
	local screen = awful.screen.focused()
	local i = screen.selected_tag.index

	local current_tag = screen.selected_tag
	local next_tag = (i <= colnum) and screen.tags[i + colnum] or screen.tags[i - colnum]

	local cc = current_tag:clients()
	local nc = next_tag:clients()
	for _, c in ipairs(cc) do c:move_to_tag(next_tag) end
	for _, c in ipairs(nc) do c:move_to_tag(current_tag) end
end

-- numeric keys function builders
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

-- brightness functions
local brightness = function(args)
	redflat.float.brightness:change_with_xbacklight(args) -- use xbacklight utility
end

-- right bottom corner position
local rb_corner = function()
	return { x = screen[mouse.screen].workarea.x + screen[mouse.screen].workarea.width,
	         y = screen[mouse.screen].workarea.y + screen[mouse.screen].workarea.height }
end

-- Build hotkeys depended on config parameters
-----------------------------------------------------------------------------------------------------------------------
function hotkeys:init(args)

	-- Init vars
	args = args or {}
	local env = args.env
	local mainmenu = args.menu
	local volume = args.volume
	local microphone = args.microphone
	local appkeys = args.appkeys or {}

	local tcn = args.tag_cols_num or 0

	local numkeys = { unpack(numkeys_line, 1, tcn) }
	local tagkeys = { unpack(tagkeys_line, 1, tcn) }

	self.mouse.root = (awful.util.table.join(
		awful.button({ }, 3, function () mainmenu:toggle() end),
		awful.button({ }, 4, awful.tag.viewnext),
		awful.button({ }, 5, awful.tag.viewprev)
	))

	-- volume functions
	local volume_raise = function() volume:change_volume({ show_notify = true }) end
	local volume_lower = function() volume:change_volume({ show_notify = true, down = true }) end
	local volume_mute  = function() volume:mute() end

	-- Init widgets
	redflat.float.qlaunch:init()

	-- Application hotkeys helper
	--------------------------------------------------------------------------------
	local apphelper = function(keys)
		if not client.focus then return end

		local app = client.focus.class:lower()
		for name, sheet in pairs(keys) do
			if name == app then
				redtip:set_pack(
						client.focus.class, sheet.pack, sheet.style.column, sheet.style.geometry,
						function() redtip:remove_pack() end
				)
				redtip:show()
				return
			end
		end

		redflat.float.notify:show({ text = "No tips for " .. client.focus.class })
	end

	-- Keys for widgets
	--------------------------------------------------------------------------------

	-- Apprunner widget
	------------------------------------------------------------
	local apprunner_keys_move = {
		{
			{ env.mod }, "k", function() apprunner:down() end,
			{ description = "Select next item", group = "Navigation" }
		},
		{
			{ env.mod }, "i", function() apprunner:up() end,
			{ description = "Select previous item", group = "Navigation" }
		},
	}

	 apprunner:set_keys(awful.util.table.join(apprunner.keys.move, apprunner_keys_move), "move")
	--apprunner:set_keys(apprunner_keys_move, "move")

	-- Menu widget
	------------------------------------------------------------
	local menu_keys_move = {
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

	redflat.menu:set_keys(awful.util.table.join(redflat.menu.keys.move, menu_keys_move), "move")
	--redflat.menu:set_keys(menu_keys_move, "move")

	-- Updates widget
	------------------------------------------------------------
	local updates_keys_action = {
		{
			{ env.mod }, ",", function() redflat.widget.updates:hide() end,
			{ description = "Close updates widget", group = "Action" }
		},
	}

	-- close widget by the same key as showing
	redflat.widget.updates:set_keys(
		awful.util.table.join(redflat.widget.updates.keys.action, updates_keys_action), "action"
	)

	-- Top process list
	------------------------------------------------------------
	local top_keys_action = {
		{
			{ env.mod }, "/", function() redflat.float.top:hide() end,
			{ description = "Close top list widget", group = "Action" }
		},
	}

	-- close widget by the same key as showing
	redflat.float.top:set_keys(
		awful.util.table.join(redflat.float.top.keys.action, top_keys_action), "action"
	)

	-- Appswitcher widget
	------------------------------------------------------------
	local appswitcher_keys = {
		{
			{ env.mod }, "a", function() appswitcher:switch() end,
			{ description = "Select next app", group = "Navigation" }
		},
		{
			{ env.mod, "Shift" }, "a", function() appswitcher:switch() end,
			{} -- hidden key
		},
		{
			{}, "Super_L", function() appswitcher:hide() end,
			{ description = "Activate and exit", group = "Action" }
		},
		{
			{ env.mod }, "Super_L", function() appswitcher:hide() end,
			{} -- hidden key
		},
		{
			{ env.mod, "Shift" }, "Super_L", function() appswitcher:hide() end,
			{} -- hidden key
		},
		{
			{}, "Return", function() appswitcher:hide() end,
			{ description = "Activate and exit", group = "Action" }
		},
		{
			{}, "Escape", function() appswitcher:hide(true) end,
			{ description = "Exit", group = "Action" }
		},
		{
			{ env.mod }, "Escape", function() appswitcher:hide(true) end,
			{} -- hidden key
		},
		{
			{ env.mod }, "F1", function() redtip:show()  end,
			{ description = "Show hotkeys helper", group = "Action" }
		},
	}

	appswitcher:set_keys(appswitcher_keys)

	-- Emacs like key sequences
	--------------------------------------------------------------------------------

	-- initial key
	local keyseq = { { env.mod }, "c", {}, {} }

	-- group
	keyseq[3] = {
		{ {}, "a", {}, {} }, -- wm management
		{ {}, "k", {}, {} }, -- application kill
		{ {}, "r", {}, {} }, -- client restore
		{ {}, "n", {}, {} }, -- client minimization
		{ {}, "f", {}, {} }, -- client moving
		{ {}, "s", {}, {} }, -- client switching
		{ {}, "d", {}, {} }, -- client move and tag switch
		{ {}, "u", {}, {} }, -- update info
		{ {}, "p", {}, {} }, -- client properties

		{ { "Shift" }, "f", {}, {} }, -- clients moving group
		{ { "Shift" }, "s", {}, {} }, -- clients switching group
		{ { "Shift" }, "d", {}, {} }, -- clients move and tag switch group
	}

	-- wm management sequence actions
	keyseq[3][1][3] = {
		{
			{}, "p", function () toggle_placement(env) end,
			{ description = "Switch master/slave window placement", group = "Awesome management", keyset = { "p" } }
		},
		{
			{}, "r", function () awesome.restart() end,
			{ description = "Reload awesome", group = "Awesome management", keyset = { "r" } }
		},
	}

	-- application kill sequence actions
	keyseq[3][2][3] = {
		{
			{}, "f", function() if client.focus then client.focus:kill() end end,
			{ description = "Kill focused client", group = "Kill application", keyset = { "f" } }
		},
		{
			{}, "a", kill_all,
			{ description = "Kill all clients with current tag", group = "Kill application", keyset = { "a" } }
		},
	}

	-- application restore sequence actions
	keyseq[3][3][3] = {
		{
			{}, "f", restore_client,
			{ description = "Restore minimized client", group = "Clients management", keyset = { "f" } }
		},
		{
			{}, "a", restore_all,
			{ description = "Restore all clients with current tag", group = "Clients management", keyset = { "a" } }
		},
	}

	-- application minimize sequence actions
	keyseq[3][4][3] = {
		{
			{}, "f", function() if client.focus then client.focus.minimized = true end end,
			{ description = "Minimized focused client", group = "Clients management", keyset = { "f" } }
		},
		{
			{}, "a", minimize_all,
			{ description = "Minimized all clients with current tag", group = "Clients management", keyset = { "a" } }
		},
		{
			{}, "e", minimize_all_except_focused,
			{ description = "Minimized all clients except focused", group = "Clients management", keyset = { "e" } }
		},
	}

	-- add client tag sequence actions (without description)
	local kk = awful.util.table.join(numkeys, tagkeys)
	for i, k in ipairs(kk) do
		table.insert(keyseq[3][5][3], { {}, k, function() client_move_by_index(i, { client.focus })        end, {} })
		table.insert(keyseq[3][6][3], { {}, k, function() client_toggle_by_index(i, { client.focus })      end, {} })
		table.insert(keyseq[3][7][3], { {}, k, function() client_move_and_go_by_index(i, { client.focus }) end, {} })
	end

	-- make fake keys with description special for key helper widget
	local grp = "Client tagging"
	local line1_symb = string.format("%s..%s", numkeys[1], numkeys[#numkeys])
	local line2_symb = string.format("%s..%s", tagkeys[1], tagkeys[#tagkeys])

	table.insert(keyseq[3][5][3], {
		{}, line1_symb, nil, { description = "Move client to tag on 1st line", group = grp, keyset = numkeys }
	})
	table.insert(keyseq[3][6][3], {
		{}, line1_symb, nil, { description = "Toggle client on tag on 1st line", group = grp, keyset = numkeys }
	})
	table.insert(keyseq[3][7][3], {
		{}, line1_symb, nil, { description = "Move client and show tag on 1st line", group = grp, keyset = numkeys }
	})
	table.insert(keyseq[3][5][3], {
		{}, line2_symb, nil, { description = "Move client to tag on 2nd line", group = grp, keyset = tagkeys }
	})
	table.insert(keyseq[3][6][3], {
		{}, line2_symb, nil, { description = "Toggle client on tag on 2nd line", group = grp, keyset = tagkeys }
	})
	table.insert(keyseq[3][7][3], {
		{}, line2_symb, nil, { description = "Move client and show tag on 2nd line", group = grp, keyset = tagkeys }
	})

	-- widget info update commands
	keyseq[3][8][3] = {
		{
			{}, "u", function() redflat.widget.updates:update(true) end,
			{ description = "Check available updates", group = "Update info", keyset = { "u" } }
		},
		{
			{}, "m", function() redflat.widget.mail:update(true) end,
			{ description = "Check new mail", group = "Update info", keyset = { "m" } }
		},
	}

	-- client properties switch
	keyseq[3][9][3] = {
		{
			{}, "s", function() client_property("sticky") end,
			{ description = "Toggle sticky", group = "Client properties", keyset = { "s" } }
		},
		{
			{}, "o", function() client_property("ontop") end,
			{ description = "Toggle keep on top", group = "Client properties", keyset = { "o" } }
		},
		{
			{}, "f", function() client_property("floating") end,
			{ description = "Toggle floating", group = "Client properties", keyset = { "f" } }
		},
		{
			{}, "b", function() client_property("below") end,
			{ description = "Toggle below", group = "Client properties", keyset = { "b" } }
		},
	}

	-- add groups of clients tag sequence actions (hidden keys)
	for i, k in ipairs(kk) do
		table.insert(keyseq[3][10][3], { {}, k, function() client_move_by_index(i, current_clients())        end, {} })
		table.insert(keyseq[3][11][3], { {}, k, function() client_toggle_by_index(i, current_clients())      end, {} })
		table.insert(keyseq[3][12][3], { {}, k, function() client_move_and_go_by_index(i, current_clients()) end, {} })
	end

	-- Layouts
	--------------------------------------------------------------------------------

	-- shared layout keys
	local layout_tile = {
		{
			{ env.mod }, "l", function () awful.tag.incmwfact( 0.05) end,
			{ description = "Increase master width factor", group = "Layout" }
		},
		{
			{ env.mod }, "j", function () awful.tag.incmwfact(-0.05) end,
			{ description = "Decrease master width factor", group = "Layout" }
		},
		{
			{ env.mod }, "i", function () awful.client.incwfact( 0.05) end,
			{ description = "Increase window factor of a client", group = "Layout" }
		},
		{
			{ env.mod }, "k", function () awful.client.incwfact(-0.05) end,
			{ description = "Decrease window factor of a client", group = "Layout" }
		},
		{
			{ env.mod, }, "+", function () awful.tag.incnmaster( 1, nil, true) end,
			{ description = "Increase the number of master clients", group = "Layout" }
		},
		{
			{ env.mod }, "-", function () awful.tag.incnmaster(-1, nil, true) end,
			{ description = "Decrease the number of master clients", group = "Layout" }
		},
		{
			{ env.mod, "Control" }, "+", function () awful.tag.incncol( 1, nil, true) end,
			{ description = "Increase the number of columns", group = "Layout" }
		},
		{
			{ env.mod, "Control" }, "-", function () awful.tag.incncol(-1, nil, true) end,
			{ description = "Decrease the number of columns", group = "Layout" }
		},
	}

	laycom:set_keys(layout_tile, "tile")

	-- grid layout keys
	local layout_grid_move = {
		{
			{ env.mod }, "KP_Up", function() grid.move_to("up") end,
			{ description = "Move window up", group = "Movement" }
		},
		{
			{ env.mod }, "KP_Down", function() grid.move_to("down") end,
			{ description = "Move window down", group = "Movement" }
		},
		{
			{ env.mod }, "KP_Left", function() grid.move_to("left") end,
			{ description = "Move window left", group = "Movement" }
		},
		{
			{ env.mod }, "KP_right", function() grid.move_to("right") end,
			{ description = "Move window right", group = "Movement" }
		},
		{
			{ env.mod, "Control" }, "KP_Up", function() grid.move_to("up", true) end,
			{ description = "Move window up by bound", group = "Movement" }
		},
		{
			{ env.mod, "Control" }, "KP_Down", function() grid.move_to("down", true) end,
			{ description = "Move window down by bound", group = "Movement" }
		},
		{
			{ env.mod, "Control" }, "KP_Left", function() grid.move_to("left", true) end,
			{ description = "Move window left by bound", group = "Movement" }
		},
		{
			{ env.mod, "Control" }, "KP_Right", function() grid.move_to("right", true) end,
			{ description = "Move window right by bound", group = "Movement" }
		},
	}

	local layout_grid_resize = {
		{
			{ env.mod }, "i", function() grid.resize_to("up") end,
			{ description = "Inrease window size to the up", group = "Resize" }
		},
		{
			{ env.mod }, "k", function() grid.resize_to("down") end,
			{ description = "Inrease window size to the down", group = "Resize" }
		},
		{
			{ env.mod }, "j", function() grid.resize_to("left") end,
			{ description = "Inrease window size to the left", group = "Resize" }
		},
		{
			{ env.mod }, "l", function() grid.resize_to("right") end,
			{ description = "Inrease window size to the right", group = "Resize" }
		},
		{
			{ env.mod, "Shift" }, "i", function() grid.resize_to("up", nil, true) end,
			{ description = "Decrease window size from the up", group = "Resize" }
		},
		{
			{ env.mod, "Shift" }, "k", function() grid.resize_to("down", nil, true) end,
			{ description = "Decrease window size from the down", group = "Resize" }
		},
		{
			{ env.mod, "Shift" }, "j", function() grid.resize_to("left", nil, true) end,
			{ description = "Decrease window size from the left", group = "Resize" }
		},
		{
			{ env.mod, "Shift" }, "l", function() grid.resize_to("right", nil, true) end,
			{ description = "Decrease window size from the right", group = "Resize" }
		},
		{
			{ env.mod, "Control" }, "i", function() grid.resize_to("up", true) end,
			{ description = "Increase window size to the up by bound", group = "Resize" }
		},
		{
			{ env.mod, "Control" }, "k", function() grid.resize_to("down", true) end,
			{ description = "Increase window size to the down by bound", group = "Resize" }
		},
		{
			{ env.mod, "Control" }, "j", function() grid.resize_to("left", true) end,
			{ description = "Increase window size to the left by bound", group = "Resize" }
		},
		{
			{ env.mod, "Control" }, "l", function() grid.resize_to("right", true) end,
			{ description = "Increase window size to the right by bound", group = "Resize" }
		},
		{
			{ env.mod, "Control", "Shift" }, "i", function() grid.resize_to("up", true, true) end,
			{ description = "Decrease window size from the up by bound ", group = "Resize" }
		},
		{
			{ env.mod, "Control", "Shift" }, "k", function() grid.resize_to("down", true, true) end,
			{ description = "Decrease window size from the down by bound ", group = "Resize" }
		},
		{
			{ env.mod, "Control", "Shift" }, "j", function() grid.resize_to("left", true, true) end,
			{ description = "Decrease window size from the left by bound ", group = "Resize" }
		},
		{
			{ env.mod, "Control", "Shift" }, "l", function() grid.resize_to("right", true, true) end,
			{ description = "Decrease window size from the right by bound ", group = "Resize" }
		},
	}

	redflat.layout.grid:set_keys(layout_grid_move, "move")
	redflat.layout.grid:set_keys(layout_grid_resize, "resize")

	-- user map layout keys
	local layout_map_layout = {
		{
			{ env.mod }, "s", function() map.swap_group() end,
			{ description = "Change placement direction for group", group = "Layout" }
		},
		{
			{ env.mod }, "v", function() map.new_group(true) end,
			{ description = "Create new vertical group", group = "Layout" }
		},
		{
			{ env.mod }, "h", function() map.new_group(false) end,
			{ description = "Create new horizontal group", group = "Layout" }
		},
		{
			{ env.mod, "Control" }, "v", function() map.insert_group(true) end,
			{ description = "Insert new vertical group before active", group = "Layout" }
		},
		{
			{ env.mod, "Control" }, "h", function() map.insert_group(false) end,
			{ description = "Insert new horizontal group before active", group = "Layout" }
		},
		{
			{ env.mod }, "d", function() map.delete_group() end,
			{ description = "Destroy group", group = "Layout" }
		},
		{
			{ env.mod, "Control" }, "d", function() map.clean_groups() end,
			{ description = "Destroy all empty groups", group = "Layout" }
		},
		{
			{ env.mod }, "f", function() map.set_active() end,
			{ description = "Set active group", group = "Layout" }
		},
		{
			{ env.mod }, "g", function() map.move_to_active() end,
			{ description = "Move focused client to active group", group = "Layout" }
		},
		{
			{ env.mod, "Control" }, "f", function() map.hilight_active() end,
			{ description = "Hilight active group", group = "Layout" }
		},
		{
			{ env.mod }, "a", function() map.switch_active(1) end,
			{ description = "Activate next group", group = "Layout" }
		},
		{
			{ env.mod }, "q", function() map.switch_active(-1) end,
			{ description = "Activate previous group", group = "Layout" }
		},
		{
			{ env.mod }, "]", function() map.move_group(1) end,
			{ description = "Move active group to the top", group = "Layout" }
		},
		{
			{ env.mod }, "[", function() map.move_group(-1) end,
			{ description = "Move active group to the bottom", group = "Layout" }
		},
		{
			{ env.mod }, "r", function() map.reset_tree() end,
			{ description = "Reset layout structure", group = "Layout" }
		},
	}

	local layout_map_resize = {
		{
			{ env.mod }, "j", function() map.incfactor(nil, 0.1, false) end,
			{ description = "Increase window horizontal size factor", group = "Resize" }
		},
		{
			{ env.mod }, "l", function() map.incfactor(nil, -0.1, false) end,
			{ description = "Decrease window horizontal size factor", group = "Resize" }
		},
		{
			{ env.mod }, "i", function() map.incfactor(nil, 0.1, true) end,
			{ description = "Increase window vertical size factor", group = "Resize" }
		},
		{
			{ env.mod }, "k", function() map.incfactor(nil, -0.1, true) end,
			{ description = "Decrease window vertical size factor", group = "Resize" }
		},
		{
			{ env.mod, "Control" }, "j", function() map.incfactor(nil, 0.1, false, true) end,
			{ description = "Increase group horizontal size factor", group = "Resize" }
		},
		{
			{ env.mod, "Control" }, "l", function() map.incfactor(nil, -0.1, false, true) end,
			{ description = "Decrease group horizontal size factor", group = "Resize" }
		},
		{
			{ env.mod, "Control" }, "i", function() map.incfactor(nil, 0.1, true, true) end,
			{ description = "Increase group vertical size factor", group = "Resize" }
		},
		{
			{ env.mod, "Control" }, "k", function() map.incfactor(nil, -0.1, true, true) end,
			{ description = "Decrease group vertical size factor", group = "Resize" }
		},
	}

	redflat.layout.map:set_keys(layout_map_layout, "layout")
	redflat.layout.map:set_keys(layout_map_resize, "resize")


	-- Global keys
	--------------------------------------------------------------------------------
	self.raw.root = {
		{
			{ env.mod }, "F1", function() redtip:show() end,
			{ description = "[Hold] Awesome hotkeys helper", group = "Help" }
		},
		{
			{ env.mod, "Control" }, "F1", function() apphelper(appkeys) end,
			{ description = "[Hold] Hotkeys helper for application", group = "Help" }
		},

		{
			{ env.mod }, "F2", function () redflat.service.navigator:run() end,
			{ description = "[Hold] Tiling window control mode", group = "Window control" }
		},
		{
			{ env.mod }, "b", function() redflat.float.bartip:show() end,
			{ description = "[Hold] Titlebar control", group = "Window control" }
		},
		{
			{ env.mod }, "h", function() redflat.float.control:show() end,
			{ description = "[Hold] Floating window control mode", group = "Window control" }
		},

		{
			{ env.mod }, "Return", function() awful.spawn(env.terminal) end,
			{ description = "Open a terminal", group = "Applications" }
		},
		{
			{ env.mod, "Mod1" }, "space", function() awful.spawn("gpaste-client ui") end,
			{ description = "Clipboard manager", group = "Applications" }
		},

		{
			{ env.mod }, "l", focus_switch_byd("right"),
			{ description = "Go to right client", group = "Client focus" }
		},
		{
			{ env.mod }, "j", focus_switch_byd("left"),
			{ description = "Go to left client", group = "Client focus" }
		},
		{
			{ env.mod }, "i", focus_switch_byd("up"),
			{ description = "Go to upper client", group = "Client focus" }
		},
		{
			{ env.mod }, "k", focus_switch_byd("down"),
			{ description = "Go to lower client", group = "Client focus" }
		},
		{
			{ env.mod }, "u", awful.client.urgent.jumpto,
			{ description = "Go to urgent client", group = "Client focus" }
		},
		--{
		--	{ env.mod }, "z", focus_to_previous,
		--	{ description = "Go to previos client", group = "Client focus" }
		--},

		{
			{ env.mod }, "/", function() redflat.float.top:show("cpu") end,
			{ description = "Top process list", group = "Widgets" }
		},
		{
			{ env.mod }, ",", function() redflat.widget.updates:show() end,
			{ description = "System updates info", group = "Widgets" }
		},
		{
			{ env.mod }, "`", function() redflat.widget.minitray:toggle() end,
			{ description = "Minitray", group = "Widgets" }
		},
		{
			{ env.mod }, "c", function() redflat.float.keychain:activate(keyseq, "User") end,
			{ description = "User key sequence", group = "Widgets" }
		},

		{
			{ env.mod }, "a", nil, function() appswitcher:show({ filter = current }) end,
			{ description = "Switch to next with current tag", group = "Application switcher" }
		},
		{
			{ env.mod, "Shift" }, "a", nil, function() appswitcher:show({ filter = allscr }) end,
			{ description = "Switch to next through all tags", group = "Application switcher" }
		},

		{
			{ env.mod }, "Tab", awful.tag.history.restore,
			{ description = "Swith to previos tag by history", group = "Tag navigation" }
		},
		{
			{ env.mod }, "Right", awful.tag.viewnext,
			{ description = "View next tag", group = "Tag navigation" }
		},
		{
			{ env.mod }, "Left", awful.tag.viewprev,
			{ description = "View previous tag", group = "Tag navigation" }
		},
		{
			{ env.mod }, "Up", function() tag_line_jump(tcn) end,
			{ description = "Switch to upper line", group = "Tag navigation" }
		},
		{
			{ env.mod }, "Down", function() tag_line_jump(tcn, true) end,
			{ description = "Switch to lower line", group = "Tag navigation" }
		},
		{
			{ env.mod }, "space", function() tag_line_switch(tcn) end,
			{ description = "Switch tag line", group = "Tag navigation" }
		},
		{
			{ env.mod, "Control" }, "space", function() clients_swap_by_line(tcn) end,
			{ description = "Swap clients between lines", group = "Tag navigation" }
		},

		{
			{ env.mod }, "s", function() mainmenu:show() end,
			{ description = "Main menu", group = "Launchers" }
		},
		{
			{ env.mod }, "d", function() apprunner:show() end,
			{ description = "Application launcher", group = "Launchers" }
		},
		{
			{ env.mod }, "p", function() redflat.float.prompt:run() end,
			{ description = "Prompt box", group = "Launchers" }
		},
		{
			{ env.mod }, "g", function() qlaunch:show() end,
			{ description = "Application quick launcher", group = "Launchers" }
		},

		{
			{}, "XF86AudioRaiseVolume", volume_raise,
			{ description = "Increase volume", group = "Volume control" }
		},
		{
			{}, "XF86AudioLowerVolume", volume_lower,
			{ description = "Reduce volume", group = "Volume control" }
		},
		{
			{}, "XF86AudioMute", volume_mute,
			{ description = "Mute audio", group = "Volume control" }
		},
		{
			{ "Control" }, "XF86AudioMute", function () microphone:mute() end,
			{ description = "Mute microphone", group = "Volume control" }
		},

		{
			{}, "XF86MonBrightnessUp", function() brightness({ step = 2 }) end,
			{ description = "Increase brightness", group = "Brightness control" }
		},
		{
			{}, "XF86MonBrightnessDown", function() brightness({ step = 2, down = true }) end,
			{ description = "Reduce brightness", group = "Brightness control" }
		},

		{
			{ env.mod }, ".", function() redflat.float.player:show(rb_corner()) end,
			{ description = "Show/hide widget", group = "Audio player" }
		},
		{
			{}, "XF86AudioPlay", function() redflat.float.player:action("PlayPause") end,
			{ description = "Play/Pause track", group = "Audio player" }
		},
		{
			{}, "XF86AudioNext", function() redflat.float.player:action("Next") end,
			{ description = "Next track", group = "Audio player" }
		},
		{
			{}, "XF86AudioPrev", function() redflat.float.player:action("Previous") end,
			{ description = "Previous track", group = "Audio player" }
		},

		{
			{ env.mod }, "v", function() laybox:toggle_menu(mouse.screen.selected_tag) end,
			{ description = "Show layout menu", group = "Layouts" }
		},
		{
			{ env.mod}, "]", function() awful.layout.inc(1) end,
			{ description = "Select next layout", group = "Layouts" }
		},
		{
			{ env.mod }, "[", function() awful.layout.inc(-1) end,
			{ description = "Select previous layout", group = "Layouts" }
		},

		--{
		--	{ env.mod, "Control" }, "s", function() for s in screen do env.wallpaper(s) end end,
		--	{} -- hidden key
		--}
	}

	-- Client keys
	--------------------------------------------------------------------------------
	self.raw.client = {
		{
			{ env.mod }, "f", function(c) c.fullscreen = not c.fullscreen; c:raise() end,
			{ description = "Toggle fullscreen", group = "Client keys" }
		},
		{
			{ env.mod }, "F4", function(c) c:kill() end,
			{ description = "Close", group = "Client keys" }
		},
		{
			{ env.mod }, "n", function(c) c.minimized = true end,
			{ description = "Minimize", group = "Client keys" }
		},
		{
			{ env.mod }, "m", function(c) c.maximized = not c.maximized; c:raise() end,
			{ description = "Maximize", group = "Client keys" }
		}
	}

	self.keys.root = redflat.util.key.build(self.raw.root)
	self.keys.client = redflat.util.key.build(self.raw.client)

	-- Numkeys
	--------------------------------------------------------------------------------

	-- add real keys without description here
	for i = 1, tcn do
		self.keys.root = awful.util.table.join(
			self.keys.root,
			tag_numkey(i, { env.mod },            function(_) tag_double_select(i, tcn) end),
			tag_numkey(i, { env.mod, "Control" }, function(t) awful.tag.viewtoggle(t)   end)
		)
	end

	for i, k in ipairs(tagkeys) do
		self.keys.root = awful.util.table.join(
			self.keys.root,
			awful.key({ env.mod },            k, function() tag_double_select(i + tcn, tcn) end),
			awful.key({ env.mod, "Control" }, k, function() tag_toogle_by_index(i + tcn)    end)
		)
	end

	-- make fake keys with description special for key helper widget
	self.fake.tagkeys = {
		{
			{ env.mod }, line1_symb, nil,
			{ description = "Switch to tag on 1st line", group = "Tag Control", keyset = numkeys }
		},
		{
			{ env.mod, "Control" }, line1_symb, nil,
			{ description = "Toggle tag on 1st line", group = "Tag Control", keyset = numkeys }
		},
			{
			{ env.mod }, line2_symb, nil,
			{ description = "Switch to tag on 2nd line", group = "Tag Control", keyset = tagkeys }
		},
		{
			{ env.mod, "Control" }, line2_symb, nil,
			{ description = "Toggle tag on 2nd line", group = "Tag Control", keyset = tagkeys }
		},
	}

	-- Hotkeys helper setup
	--------------------------------------------------------------------------------
	redflat.float.hotkeys:set_pack("Main", awful.util.table.join(self.raw.root, self.raw.client, self.fake.tagkeys), 2)

	-- Mouse buttons
	--------------------------------------------------------------------------------
	local function game_safe_kill(c)
		local current_tag = awful.screen.focused().selected_tag
		if current_tag and current_tag.name and current_tag.name:lower() ~= "game" then
			c:kill()
		end
	end

	self.mouse.client = awful.util.table.join(
		awful.button({}, 1, function (c) client.focus = c; c:raise() end),
		awful.button({}, 2, awful.mouse.client.move),
		awful.button({ env.mod }, 3, awful.mouse.client.resize),
		awful.button({}, 8, game_safe_kill)
	)

	-- Set root hotkeys
	--------------------------------------------------------------------------------
	root.keys(self.keys.root)
	root.buttons(self.mouse.root)
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return hotkeys
