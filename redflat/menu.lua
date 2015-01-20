-----------------------------------------------------------------------------------------------------------------------
--                                                  RedFlat menu                                                     --
-----------------------------------------------------------------------------------------------------------------------
-- awful.menu modification
-- Custom widget support added
-- Auto hide option added
-- Right icon support added to default item constructor
-- Icon margin added to default item constructor
-- Auto hotkeys for menu items added

-- Horizontal mode support removed
-- Add to index and delete item functions removed
-- menu:clients function removed
-----------------------------------------------------------------------------------------------------------------------
-- Some code was taken from
------ awful.menu v3.5.2
------ (c) 2008, 2011 Damien Leone, Julien Danjou, dodo
-----------------------------------------------------------------------------------------------------------------------


-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local setmetatable = setmetatable
local tonumber = tonumber
local string = string
local ipairs = ipairs
local pairs = pairs
local pcall = pcall
local print = print
local table = table
local type = type
local math = math

local redutil = require("redflat.util")
local svgbox = require("redflat.gauge.svgbox")


-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local menu = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_theme()
	local style = {
		border_width = 2,
		screen_gap   = 0,
		submenu_icon = nil,
		height       = 20,
		width        = 200,
		font         = "Sans 12",
		icon_margin  = { 0, 0, 0, 0 }, -- left icon margin
		ricon_margin = { 0, 0, 0, 0 }, -- right icon margin
		nohide       = false,
		auto_expand  = true,
		auto_hotkey  = false,
		svg_scale    = {false, false},
		color        = { border = "#575757", text = "#aaaaaa", highlight = "#eeeeee",
		                 main = "#b1222b", wibox = "#202020",
		                 submenu_icon = nil, right_icon = nil, left_icon = nil }
	}
	return redutil.table.merge(style, beautiful.menu or {})
end

-- Key bindings for menu navigation.
menu.menu_keys = {
	up    = { "Up" },
	down  = { "Down" },
	back  = { "Left" },
	exec  = { "Return" },
	enter = { "Right" },
	close = { "Escape" }
}

-- Support functions
-----------------------------------------------------------------------------------------------------------------------

-- Check if any menu item connected with given key
-- and run menu item command if found
--------------------------------------------------------------------------------
local function check_access_key(_menu, key)
	local num = awful.util.table.hasitem(_menu.keys, key)
	if num then
		_menu:item_enter(num)
		_menu:exec(num)
	end
end

-- Get the elder parent of submenu
--------------------------------------------------------------------------------
function menu:get_root()
	return self.parent and menu.get_root(self.parent) or self
end

-- Setup case insensitive underline markup to given character in string
--------------------------------------------------------------------------------
local function make_u(text, key)
	local pos = key and string.find(string.lower(text), key) or nil

	if pos then
		local rkey = string.sub(text, pos, pos)
		return string.gsub(text, rkey, "<u>" .. rkey .. "</u>", 1)
	end

	return text
end

-- Function to set menu or submenu in position
-----------------------------------------------------------------------------------------------------------------------
local function set_coords(_menu, screen_idx, m_coords)
	local s_geometry = redutil.placement.add_gap(screen[screen_idx].workarea, _menu.theme.screen_gap)

	local screen_w = s_geometry.x + s_geometry.width
	local screen_h = s_geometry.y + s_geometry.height

	local x = _menu.wibox.x
	local y = _menu.wibox.y
	local b = _menu.wibox.border_width
	local w = _menu.wibox.width + 2 * _menu.wibox.border_width
	local h = _menu.wibox.height + 2 * _menu.wibox.border_width

	if _menu.parent then
		local pw = _menu.parent.wibox.width + 2 * _menu.parent.theme.border_width
		local piy = _menu.parent.wibox.y + _menu.position + _menu.parent.theme.border_width

		y = piy - b
		x = _menu.parent.wibox.x + pw

		if y + h > screen_h then y = screen_h - h end
		if x + w > screen_w then x = _menu.parent.wibox.x - w end
	else
		if m_coords == nil then
			m_coords = mouse.coords()
			m_coords.x = m_coords.x - 1
			m_coords.y = m_coords.y - 1
		end

		y = m_coords.y < s_geometry.y and s_geometry.y or m_coords.y
		x = m_coords.x < s_geometry.x and s_geometry.x or m_coords.x

		if y + h > screen_h then y = screen_h - h end
		if x + w > screen_w then x = screen_w - w end
	end

	_menu.wibox.x = x
	_menu.wibox.y = y
end

-- Menu keygrabber
-- A new instance for every submenu should be used
-----------------------------------------------------------------------------------------------------------------------

local grabber

-- localize small alias functions for keygrabber in logical block
do
	-- support functions
	local function go_up(menu, sel)
		local sel_new = sel - 1 < 1 and #menu.items or sel - 1
		menu:item_enter(sel_new)
	end

	local function go_down(menu, sel)
		local sel_new = sel + 1 > #menu.items and 1 or sel + 1
		menu:item_enter(sel_new)
	end

	local function enter(menu, sel)
		if menu.items[sel].child then menu.items[sel].child:show() end
	end

	local function exec(menu, sel)
		menu:exec(sel, { exec = true })
	end

	-- keygrabber
	grabber = function(_menu, mod, key, event)
		if event ~= "press" then return end
		local sel = _menu.sel or 0

		if     awful.util.table.hasitem(menu.menu_keys.up,    key)             then go_up(_menu, sel)
		elseif awful.util.table.hasitem(menu.menu_keys.down,  key)             then go_down(_menu, sel)
		elseif awful.util.table.hasitem(menu.menu_keys.enter, key) and sel > 0 then enter(_menu, sel)
		elseif awful.util.table.hasitem(menu.menu_keys.exec,  key) and sel > 0 then exec(_menu, sel)
		elseif awful.util.table.hasitem(menu.menu_keys.back,  key)             then _menu:hide()
		elseif awful.util.table.hasitem(menu.menu_keys.close, key)             then menu.get_root(_menu):hide()
		else   check_access_key(_menu, key)
		end
	end
end

-- Execute menu item
-----------------------------------------------------------------------------------------------------------------------
function menu:exec(num)
	local item = self.items[num]

	if not item then return end

	local cmd = item.cmd

	if type(cmd) == "table" then
		item.child:show()
	elseif type(cmd) == "string" then
		if not item.theme.nohide then menu.get_root(self):hide() end
		awful.util.spawn(cmd)
	elseif type(cmd) == "function" then
		if not item.theme.nohide then menu.get_root(self):hide() end
		cmd()
	end
end

-- Menu item selection functions
-----------------------------------------------------------------------------------------------------------------------

-- Select item
--------------------------------------------------------------------------------
function menu:item_enter(num, opts)
	local opts = opts or {}
	local item = self.items[num]

	if num == nil or self.sel == num or not item then
		return
	elseif self.sel then
		self:item_leave(self.sel)
	end

	item._background:set_fg(item.theme.color.highlight)
	item._background:set_bg(item.theme.color.main)
	self.sel = num

	if self.theme.auto_expand and opts.hover and self.items[num].child then
		self.items[num].child:show()
	end
end

-- Unselect item
--------------------------------------------------------------------------------
function menu:item_leave(num)
	local item = self.items[num]

	if item then
		item._background:set_fg(item.theme.color.text)
		item._background:set_bg(item.theme.color.wibox)
		if item.child then item.child:hide() end
	end
end

-- Menu show/hide functions
-----------------------------------------------------------------------------------------------------------------------

-- Show a menu popup.
-- @param args.coords Menu position defaulting to mouse.coords()
--------------------------------------------------------------------------------
function menu:show(args)
	local args = args or {}
	local screen_index = mouse.screen

	set_coords(self, screen_index, args.coords)
	awful.keygrabber.run(self._keygrabber)
	self.wibox.visible = true
	self:item_enter(1)
end

-- Hide a menu popup.
--------------------------------------------------------------------------------
function menu:hide()
	if not self.wibox.visible then return end

	self:item_leave(self.sel)

	if self.items[self.sel].child then self.items[self.sel].child:hide() end

	self.sel = nil
	awful.keygrabber.stop(self._keygrabber)

	if self.hidetimer then self.hidetimer:stop() end

	self.wibox.visible = false
end

-- Toggle menu visibility
--------------------------------------------------------------------------------
function menu:toggle(args)
	if self.wibox.visible then
		self:hide()
	else
		self:show(args)
	end
end

-- Add a new menu entry.
-- args.new (Default: redflat.menu.entry) The menu entry constructor.
-- args.theme (Optional) The menu entry theme.
-- args.* params needed for the menu entry constructor.
-- @param args The item params
-----------------------------------------------------------------------------------------------------------------------
function menu:add(args)
	if not args then return end

	-- If widget instead of text label recieved
	-- just add it to layer, don't try to create menu item
	------------------------------------------------------------
	if type(args[1]) ~= "string" and args.widget then
		local element = {}
		element.width, element.height = args.widget:fit(-1, -1)
		self.add_size = self.add_size + element.height
		self.layout:add(args.widget)
		return
	end

	-- Set theme for currents item
	------------------------------------------------------------
	local theme = redutil.table.merge(self.theme, args.theme or {})
	args.theme = theme

	-- Generate menu item
	------------------------------------------------------------
	args.new = args.new or menu.entry
	local success, item = pcall(args.new, self, args)

	if not success then
		print("Error while creating menu entry: " .. item)
		return
	end

	if not item.widget then
		print("Error while checking menu entry: no property widget found.")
		return
	end

	item.parent = self
	item.theme = item.theme or theme
	--wibox.widget.base.check_widget(item.widget)
	item._background = wibox.widget.background()
	item._background:set_widget(item.widget)
	item._background:set_fg(item.theme.color.text)
	item._background:set_bg(item.theme.color.wibox)

	-- Add item widget to menu layout
	------------------------------------------------------------
	table.insert(self.items, item)
	self.layout:add(item._background)

	-- Create bindings
	------------------------------------------------------------
	local num = #self.items

	item._background:buttons(awful.util.table.join(
		awful.button({}, 3, function () self:hide() end),
		awful.button({}, 1, function ()
			self:item_enter(num)
			self:exec(num)
		end)
	))

	item.widget:connect_signal("mouse::enter", function() self:item_enter(num, { hover = true }) end)

	-- Create submenu if needed
	------------------------------------------------------------
	if type(args[2]) == "table" then
		if not self.items[#self.items].child then
			self.items[#self.items].child = menu.new(args[2], self)
			self.items[#self.items].child.position = self.add_size
		end
	end

	------------------------------------------------------------
	self.add_size = self.add_size + item.theme.height

	return item
end

-- Default menu item constructor
-- @param parent The parent menu
-- @param args the item params
-- @return table with all the properties the user wants to change
-----------------------------------------------------------------------------------------------------------------------
function menu.entry(parent, args)
	local args = args or {}
	args.text = args[1] or args.text or ""
	args.cmd  = args[2] or args.cmd
	args.icon = args[3] or args.icon
	args.right_icon = args[4] or args.right_icon

	-- Create the item label widget
	------------------------------------------------------------
	local label = wibox.widget.textbox()
	label:set_font(args.theme.font)

	-- Set hotkey if needed
	------------------------------------------------------------
	local key = nil
	local text = awful.util.escape(args.text)

	if args.key and not awful.util.table.hasitem(parent.keys, args.key) then
		key = args.key
	elseif parent.theme.auto_hotkey then
		for i = 1, #text do
			local c = string.sub(string.lower(text), i, i)

			if not awful.util.table.hasitem(parent.keys, c) and string.match(c, "%l") then
				key = c
				break
			end
		end
	end

	if key then parent.keys[#parent.keys + 1] = key end

	label:set_markup(make_u(text, key))

	-- Set left icon if needed
	------------------------------------------------------------
	local iconbox = nil
	local margin = wibox.layout.margin()
	margin:set_widget(label)

	if args.icon then
		iconbox = svgbox(args.icon, args.theme.svg_scale[1])
		if args.theme.color.left_icon then iconbox:set_color(args.theme.color.left_icon) end
	else
		margin:set_left(args.theme.icon_margin[1])
	end

	-- Set right icon if needed
	------------------------------------------------------------
	local right_iconbox = nil

	if type(args.cmd) == "table" then
		if args.theme.submenu_icon then
			right_iconbox = svgbox(args.theme.submenu_icon, args.theme.svg_scale[2])
			if args.theme.color.submenu_icon then right_iconbox:set_color(args.theme.color.submenu_icon) end
		else
			right_iconbox = wibox.widget.textbox("▶ ")
		end
	elseif args.right_icon then
		right_iconbox = svgbox(args.right_icon, args.theme.svg_scale[2])
		if args.theme.color.right_icon then right_iconbox:set_color(args.theme.color.right_icon) end
	end

	-- Construct item layouts
	------------------------------------------------------------
	local left = wibox.layout.fixed.horizontal()

	if iconbox ~= nil then
		left:add(wibox.layout.margin(iconbox, unpack(args.theme.icon_margin)))
	end

	left:add(margin)

	local layout = wibox.layout.align.horizontal()
	layout:set_left(left)

	if right_iconbox ~= nil then
		layout:set_right(wibox.layout.margin(right_iconbox, unpack(args.theme.ricon_margin)))
	end

	local layout_const = wibox.layout.constraint(layout, "exact", args.theme.width, args.theme.height)

	------------------------------------------------------------
	return {
		label  = label,
		icon   = iconbox,
		widget = layout_const,
		cmd    = args.cmd,
		right_icon = right_iconbox
	}
end

-- Create new menu
-----------------------------------------------------------------------------------------------------------------------
function menu.new(args, parent)

	local args = args or {}

	-- Initialize menu object
	------------------------------------------------------------
	local _menu = {
		item_enter   = menu.item_enter,
		item_leave   = menu.item_leave,
		get_root     = menu.get_root,
		delete       = menu.delete,
		toggle       = menu.toggle,
		hide         = menu.hide,
		show         = menu.show,
		exec         = menu.exec,
		add          = menu.add,
		items        = {},
		keys         = {},
		parent       = parent,
		layout       = wibox.layout.fixed.vertical(),
		hide_timeout = parent and parent.hide_timeout or args.hide_timeout,
		add_size     = 0,
		theme        = redutil.table.merge(parent and parent.theme or default_theme(), args.theme or {})
	}

	-- Create items
	------------------------------------------------------------
	for i, v in ipairs(args) do _menu:add(v) end

	if args.items then
		for i, v in ipairs(args.items) do _menu:add(v) end
	end

	_menu._keygrabber = function (...)
		grabber(_menu, ...)
	end

	-- create wibox
	------------------------------------------------------------
	_menu.wibox = wibox({
		type  = "popup_menu",
		ontop = true,
		fg    = _menu.theme.color.text,
		bg    = _menu.theme.color.wibox,
		border_color = _menu.theme.color.border,
		border_width = _menu.theme.border_width
	})

	_menu.wibox.visible = false
	_menu.wibox:set_widget(_menu.layout)

	-- set size
	_menu.wibox.width = _menu.theme.width
	_menu.wibox.height = _menu.add_size

	-- Set menu autohide timer
	------------------------------------------------------------
	if _menu.hide_timeout then
		local root = _menu:get_root()

		-- timer only for root menu
		-- all submenus will be hidden automatically
		if root == _menu then
			_menu.hidetimer = timer({ timeout = _menu.hide_timeout })
			_menu.hidetimer:connect_signal("timeout", function() _menu:hide() end)
		end

		-- enter/leave signals for all menu chain
		_menu.wibox:connect_signal("mouse::enter",
			function()
				if root.hidetimer.started then root.hidetimer:stop() end
			end)
		_menu.wibox:connect_signal("mouse::leave", function() root.hidetimer:start() end)
	end

	------------------------------------------------------------
	return _menu
end

-- Config metatable to call menu module as function
-----------------------------------------------------------------------------------------------------------------------
function menu.mt:__call(...)
	return menu.new(...)
end

return setmetatable(menu, menu.mt)
