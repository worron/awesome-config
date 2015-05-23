-----------------------------------------------------------------------------------------------------------------------
--                                             RedFlat tasklist widget                                               --
-----------------------------------------------------------------------------------------------------------------------
-- Custom widget used to show apps, see redtask.lua for more info
-- No icons; labels can be customized in beautiful theme file
-- Same class clients grouped into one object
-- Pop-up tooltip with task names
-- Pop-up menu with window state info
-----------------------------------------------------------------------------------------------------------------------
-- Some code was taken from
------ awful.widget.tasklist v3.5.2
------ (c) 2008-2009 Julien Danjou
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local pairs = pairs
local ipairs = ipairs
local table = table
local string = string
local math = math
local beautiful = require("beautiful")
local tag = require("awful.tag")
local awful = require("awful")
local wibox = require("wibox")

local redtask = require("redflat.gauge.task")
local redutil = require("redflat.util")
local separator = require("redflat.gauge.separator")
local redmenu = require("redflat.menu")
local svgbox = require("redflat.gauge.svgbox")


-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local redtasklist = { filter = {}, winmenu = {}, tasktip = {}, action = {}, mt = {} }

local last = {
	client      = nil,
	group       = nil,
	client_list = nil,
	screen      = mouse.screen
}

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		appnames    = {},
		widget      = redtask.new,
		width       = 40,
		char_digit  = 3,
		need_group  = true,
		task_margin = { 5, 5, 0, 0 }
	}
	style.winmenu = {
		icon           = {},
		micon          = {},
		layout_icon    = {},
		titleline      = { font = "Sans 16 bold", height = 35},
		state_iconsize = { 20, 20 },
		sep_margin     = { 3, 3, 5, 5 },
		tagmenu        = { icon_margin = { 10, 10, 10, 10 } },
		color          = { main = "#b1222b", icon = "#a0a0a0", gray = "#404040" }
	}
	style.tasktip = {
		border_width = 2,
		margin       = { 10, 10, 5, 5 },
		timeout      = 0.5,
		color        = { border = "#575757", text = "#aaaaaa", main = "#b1222b", highlight = "#eeeeee",
		                 wibox = "#202020", gray = "#575757", urgent = "#32882d" }

	}
	style.winmenu.menu = {
		ricon_margin = { 10, 10, 10, 10 },
		layout_icon  = {},
		nohide       = true
	}

	return redutil.table.merge(style, redutil.check(beautiful, "widget.tasklist") or {})
end

-- Support functions
-----------------------------------------------------------------------------------------------------------------------

-- Get info about client group
--------------------------------------------------------------------------------
local function get_state(c_group, chars, names)

	local names = names or {}
	local state = { focus = false, urgent = false, minimized = true, list = {} }

	for _, c in pairs(c_group) do
		state.focus     = state.focus or client.focus == c
		state.urgent    = state.urgent or c.urgent
		state.minimized = state.minimized and c.minimized

		table.insert(state.list, { focus = client.focus == c, urgent = c.urgent, minimized = c.minimized })
	end

	local class = c_group[1].class or "Untitled"
	state.text = names[class] or string.upper(string.sub(class, 1, chars))
	state.num = #c_group

	return state
end

-- Function to build item list for submenu
--------------------------------------------------------------------------------
local function tagmenu_items(action, style)
	local items = {}
	for _, t in ipairs(awful.tag.gettags(last.screen)) do
		if not awful.tag.getproperty(t, "hide") then
			table.insert(
				items,
				{ t.name, function() action(t, last.client) end, style.micon.blank, style.micon.blank }
			)
		end
	end
	return items
end

-- Function to update tag submenu icons
--------------------------------------------------------------------------------
local function tagmenu_update(c, menu, submenu_index, style)
	for k, t in ipairs(awful.tag.gettags(last.screen)) do
		if not awful.tag.getproperty(t, "hide") then

			-- set layout icon for every tag
			local l = awful.layout.getname(awful.tag.getproperty(t, "layout"))

			for _, index in ipairs(submenu_index) do
				if menu.items[index].child.items[k].icon then
					menu.items[index].child.items[k].icon:set_image(style.layout_icon[l] or style.layout_icon.unknown)
				end
			end

			-- set "checked" icon if tag active for given client
			-- otherwise set empty icon
			if c then
				local client_tags = c:tags()
				local check_icon = awful.util.table.hasitem(client_tags, t) and style.micon.check
				                   or style.micon.blank

				for _, index in ipairs(submenu_index) do
					if menu.items[index].child.items[k].right_icon then
						menu.items[index].child.items[k].right_icon:set_image(check_icon)
					end
				end
			end
		end
	end
end

-- Function to construct menu line with state icons
--------------------------------------------------------------------------------
local function state_line_construct(state_icons, setup_layout, style)
	local stateboxes = {}

	for i, v in ipairs(state_icons) do
		-- create widget
		stateboxes[i] = svgbox(v.icon, false)
		stateboxes[i]:set_size({ width = style.state_iconsize[1], height = style.state_iconsize[2] })

		-- set widget in line
		local l = wibox.layout.align.horizontal()
		l:set_middle(stateboxes[i])
		setup_layout:add(l)

		-- set mouse action
		stateboxes[i]:buttons(awful.util.table.join(awful.button({}, 1, v.act)))
	end

	return stateboxes
end

-- Calculate menu position
-- !!! Bad code is here !!!
-- !!! TODO: make variant when panel place on top of screen !!!
--------------------------------------------------------------------------------
local function coords_calc(menu, tip_wibox, gap)
	local coords = {}

	if gap then
		coords.x = tip_wibox.x + (tip_wibox.width - menu.wibox.width) / 2
		coords.y = tip_wibox.y - menu.wibox.height - 2 * menu.wibox.border_width + tip_wibox.border_width + gap
	else
		coords = mouse.coords()
		coords.x = coords.x - menu.wibox.width / 2 - menu.wibox.border_width
	end

	return coords
end

-- Create tasklist object
--------------------------------------------------------------------------------
local function new_task(c_group, style)
	local task = {}
	task.widg  = style.widget(style.task)
	task.group = c_group
	task.l     = wibox.layout.margin(task.widg, unpack(style.task_margin))

	task.widg:connect_signal("mouse::enter", function() redtasklist.tasktip:show(task.group) end)
	task.widg:connect_signal("mouse::leave",
		function()
			redtasklist.tasktip.hidetimer:start()
			redtasklist.winmenu.menu.hidetimer:start()
		end
	)
	return task
end

-- Find all clients to be shown
--------------------------------------------------------------------------------
local function visible_clients(filter, screen)
	local clients = {}

	for i, c in ipairs(client.get()) do
		local hidden = c.skip_taskbar or c.hidden or c.type == "splash" or c.type == "dock" or c.type == "desktop"

		if not hidden and filter(c, screen) then
			table.insert(clients, c)
		end
	end

	return clients
end

-- Split tasks into groups by class
--------------------------------------------------------------------------------
local function group_task(clients, need_group)
	local client_groups = {}
	local classes = {}

	for _, c in ipairs(clients) do
		if need_group then
			local index = awful.util.table.hasitem(classes, c.class)
			if index then
				table.insert(client_groups[index], c)
			else
				table.insert(classes, c.class)
				table.insert(client_groups, { c })
			end
		else
			table.insert(client_groups, { c })
		end
	end

	return client_groups
end

-- Form ordered client list special for switch function
--------------------------------------------------------------------------------
local function sort_list(client_groups)
	local list = {}

	for _, g in ipairs(client_groups) do
		for _, c in ipairs(g) do
			if not c.minimized then table.insert(list, c) end
		end
	end

	return list
end

-- Create tasktip line
--------------------------------------------------------------------------------
local function tasktip_line(style)
	local line = {}

	-- text
	line.tb = wibox.widget.textbox()

	-- horizontal align wlayout
	local horizontal = wibox.layout.fixed.horizontal()
	horizontal:add(wibox.layout.margin(line.tb, unpack(style.margin)))

	-- background for client state mark
	line.field = wibox.widget.background(horizontal)

	-- tasktip line metods
	function line:set_text(text)
		line.tb:set_text(text)
		line.field:set_fg(style.color.text)
		line.field:set_bg(style.color.wibox)
	end

	function line:mark_focused()
		line.field:set_bg(style.color.main)
		line.field:set_fg(style.color.highlight)
	end

	function line:mark_urgent()
		line.field:set_bg(style.color.urgent)
		line.field:set_fg(style.color.highlight)
	end

	function line:mark_minimized()
		line.field:set_fg(style.color.gray)
	end

	return line
end

-- Switch task
--------------------------------------------------------------------------------
local function switch_focus(list, is_reverse)
	local diff = is_reverse and - 1 or 1

	if #list == 0 then return end

	local index = (awful.util.table.hasitem(list, client.focus) or 1) + diff

	if     index < 1 then index = #list
	elseif index > #list then index = 1
	end

	-- set focus to new task
	client.focus = list[index]
	list[index]:raise()
end

-- Build or update tasklist.
--------------------------------------------------------------------------------
local function tasklist_construct(client_groups, layout, data, buttons, style)

	layout:reset()
	layout:set_max_widget_size(style.width + style.task_margin[1] + style.task_margin[2])

	-- construct tasklist
	for i, c_group in ipairs(client_groups) do
		local task

		-- use existing widgets or create new
		if data[i] then
			task = data[i]
			task.group = c_group
		else
			task = new_task(c_group, style)
			data[i] = task
		end

		-- set info and buttons to widget
		local state = get_state(c_group, style.char_digit, style.appnames)
		task.widg:set_state(state)
		task.widg:buttons(redutil.create_buttons(buttons, { group = c_group }))

		-- construct
		layout:add(task.l)
   end
end

-- Construct or update tasktip
--------------------------------------------------------------------------------
local function construct_tasktip(c_group, layout, data, buttons, style)
	layout:reset()
	local tb_w, tb_h
	local tip_width = 1

	for i, c in ipairs(c_group) do
		local line

		-- use existing widgets or create new
		if data[i] then
			line = data[i]
		else
			line = tasktip_line(style)
			data[i] = line
		end

		line:set_text(awful.util.escape(c.name))
		tb_w, tb_h = line.tb:fit(-1, -1)

		-- set state highlight and buttons only for grouped tasks
		if #c_group > 1 then
			local state = get_state({ c })

			if state.focus     then line:mark_focused()   end
			if state.minimized then line:mark_minimized() end
			if state.urgent    then line:mark_urgent()    end

			local gap = (i - 1) * (tb_h + style.margin[3] + style.margin[4])
			line.field:buttons(redutil.create_buttons(buttons, { group = { c }, gap = gap }))
		else
			line.field:buttons({})
		end

		tip_width = math.max(tip_width, tb_w)
		layout:add(line.field)
	end

	-- return tasktip size
	return {
		width  = tip_width + style.margin[1] + style.margin[2],
		height = #c_group * (tb_h + style.margin[3] + style.margin[4])
	}
end


-- Initialize window menu widget
-----------------------------------------------------------------------------------------------------------------------
function redtasklist.winmenu:init(style)

	-- Window managment functions
	--------------------------------------------------------------------------------
	local close    = function() last.client:kill() end
	local minimize = function() last.client.minimized = not last.client.minimized end
	local maximize = function() last.client.maximized = not last.client.maximized end

	-- Create array of state icons
	-- associate every icon with action and state indicator
	--------------------------------------------------------------------------------

	local function icon_table_ganerator(property)
		return {
			icon = style.icon[property],
			act  = function() last.client[property] = not last.client[property] end,
			ind  = function(c) return c[property] end
		}
	end

	-- most of properties tables are similar, so they can be generated by general function
	-- but "floating" icon is a bit different, so its table written by hand
	local state_icons = {
		{
			icon = style.icon.floating,
			act  = function() awful.client.floating.toggle(last.client) end,
			ind  = awful.client.floating.get
		},
		icon_table_ganerator("sticky"),
		icon_table_ganerator("ontop"),
		icon_table_ganerator("below"),
		icon_table_ganerator("maximized_horizontal"),
		icon_table_ganerator("maximized_vertical"),
	}

	-- Construct menu
	--------------------------------------------------------------------------------

	-- Client class line (menu title) construction
	------------------------------------------------------------
	local classbox = wibox.widget.textbox()
	classbox:set_font(style.titleline.font)
	classbox:set_align ("center")

	local classline = wibox.layout.constraint(classbox, "exact", nil, style.titleline.height)

	-- Window state line construction
	------------------------------------------------------------

	-- layouts
	local stateline_horizontal = wibox.layout.flex.horizontal()
	local stateline_vertical = wibox.layout.align.vertical()
	stateline_vertical:set_middle(stateline_horizontal)
	local stateline = wibox.layout.constraint(stateline_vertical, "exact", nil, style.titleline.height)

	-- set all state icons in line
	local stateboxes = state_line_construct(state_icons, stateline_horizontal, style)

	-- update function for state icons
	local function stateboxes_update(c, state_icons, stateboxes)
		for i, v in ipairs(state_icons) do
			stateboxes[i]:set_color(v.ind(c) and style.color.main or style.color.gray)
		end
	end

	-- Separators config
	------------------------------------------------------------
	local menusep = { widget = separator.horizontal({ margin = style.sep_margin }) }

	-- Construct tag submenus ("move" and "add")
	------------------------------------------------------------
	local movemenu_items = tagmenu_items(awful.client.movetotag, style)
	local addmenu_items  = tagmenu_items(awful.client.toggletag, style)

	-- Create menu
	------------------------------------------------------------
	self.menu = redmenu({
		hide_timeout = 1,
		theme = style.menu,
		items = {
			{ widget = classline },
			menusep,
			{ "Move to tag", { items = movemenu_items, theme = style.tagmenu} },
			{ "Add to tag",  { items = addmenu_items,  theme = style.tagmenu} },
			{ "Maximize",    maximize, nil, style.icon.maximize },
			{ "Minimize",    minimize, nil, style.icon.minimize },
			{ "Close",       close,    nil, style.icon.close    },
			menusep,
			{ widget = stateline }
		}
	})

	-- Widget update functions
	--------------------------------------------------------------------------------
	function self:update(c)
		if self.menu.wibox.visible then
			classbox:set_text(c.class or "Unknown")
			stateboxes_update(c, state_icons, stateboxes)
			tagmenu_update(c, self.menu, { 1, 2 }, style)
		end
	end

	-- Signals setup
	-- Signals which affect window menu only
	-- and does not connected to tasklist
	--------------------------------------------------------------------------------
	local client_signals = {
		"property::ontop", "property::floating", "property::below",
		"property::maximized_horizontal", "property::maximized_vertical"
	}
	for _, sg in ipairs(client_signals) do
		client.connect_signal(sg, function() self:update(last.client) end)
	end
end

-- Show window menu widget
-----------------------------------------------------------------------------------------------------------------------
function redtasklist.winmenu:show(c_group, gap)

	-- do nothing if group of task received
	-- show state only for single task
	if #c_group > 1 then return end

	local c = c_group[1]

	-- toggle menu
	if self.menu.wibox.visible and c == last.client and mouse.screen == last.screen  then
		self.menu:hide()
	else
		last.client = c
		last.screen = mouse.screen
		self.menu:show({ coords = coords_calc(self.menu, redtasklist.tasktip.wibox, gap) })

		if self.menu.hidetimer.started then self.menu.hidetimer:stop() end
		self:update(c)
	end
end


-- Initialize a tasktip
-----------------------------------------------------------------------------------------------------------------------
function redtasklist.tasktip:init(buttons, style)

	local tippat = {}

	-- Create wibox
	--------------------------------------------------------------------------------
	self.wibox = wibox({
		type = "tooltip",
		bg   = style.color.wibox,
		border_width = style.border_width,
		border_color = style.color.border
	})

	self.wibox.ontop = true

	self.layout = wibox.layout.fixed.vertical()
	self.wibox:set_widget(self.layout)

	-- Update function
	--------------------------------------------------------------------------------
	function self:update(c_group)

		if not self.wibox.visible then return end

		local wg = construct_tasktip(c_group, self.layout, tippat, buttons, style)
		self.wibox:geometry(wg)
	end

	-- Set tasktip autohide timer
	--------------------------------------------------------------------------------
	self.hidetimer = timer({ timeout = style.timeout })
	self.hidetimer:connect_signal("timeout",
		function()
			self.wibox.visible = false
			self.hidetimer:stop()
		end
	)
	self.hidetimer:emit_signal("timeout")

	-- Signals setup
	--------------------------------------------------------------------------------
	self.wibox:connect_signal("mouse::enter",
		function()
			if self.hidetimer.started then self.hidetimer:stop() end
		end
	)

	self.wibox:connect_signal("mouse::leave",
		function()
			self.hidetimer:start()
			redtasklist.winmenu.menu.hidetimer:start()
		end
	)
end

-- Show tasktip
-----------------------------------------------------------------------------------------------------------------------
function redtasklist.tasktip:show(c_group)

	if self.hidetimer.started then self.hidetimer:stop() end

	if not self.wibox.visible or last.group ~= c_group then
		self.wibox.visible = true
		last.group = c_group
		self:update(c_group)
		awful.placement.under_mouse(self.wibox)
		awful.placement.no_offscreen(self.wibox)
	end
end

-- Create a new tasklist widget
-- @param screen The screen to draw tasklist for
-- @param filter Filter function to define what clients will be listed
-- @param style Settings for redtask widget
-----------------------------------------------------------------------------------------------------------------------
function redtasklist.new(screen, filter, buttons, style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	local style = redutil.table.merge(default_style(), style or {})

	redtasklist.winmenu:init(style.winmenu)
	redtasklist.tasktip:init(buttons, style.tasktip)

	local tasklist = wibox.layout.flex.horizontal()
	local data = {}

	-- Update tasklist
	--------------------------------------------------------------------------------

	-- Tasklist update function
	------------------------------------------------------------
	local function tasklist_update()
		local clients = visible_clients(filter, screen)
		local client_groups = group_task(clients, style.need_group)

		last.sorted_list = sort_list(client_groups)

		tasklist_construct(client_groups, tasklist, data, buttons, style)
	end

	-- Full update including pop-up widgets
	------------------------------------------------------------
	local function update()
		tasklist_update()
		redtasklist.tasktip:update(last.group)
		redtasklist.winmenu:update(last.client)
	end

	-- Signals setup
	--------------------------------------------------------------------------------
	local client_signals = {
		"property::urgent", "property::sticky", "property::minimized",
		"property::name", "  property::icon",   "property::skip_taskbar",
		"property::screen", "property::hidden",
		"tagged", "untagged", "list", "focus", "unfocus"
	}

	local tag_signals = { "property::selected", "property::activated" }

	for _, sg in ipairs(client_signals) do client.connect_signal(sg, update) end
	for _, sg in ipairs(tag_signals)    do tag.attached_connect_signal(screen, sg, update) end

	-- force hide pop-up widgets if any client was closed
	-- because last vars may be no actual anymore
	client.connect_signal("unmanage",
		function(c)
			tasklist_update()
			redtasklist.tasktip.wibox.visible = false
			redtasklist.winmenu.menu:hide()
			last.client = nil
			last.group  = nil
		end
	)

	-- Construct
	--------------------------------------------------------------------------------
	update()

	return tasklist
end

-- Mouse action functions
-----------------------------------------------------------------------------------------------------------------------

-- focus/minimize
function redtasklist.action.select(args)
	local args = args or {}
	local state = get_state(args.group)

	if state.focus then
		for _, c in ipairs(args.group) do c.minimized = true end
	else
		if state.minimized then
			for _, c in ipairs(args.group) do c.minimized = false end
		end

		client.focus = args.group[1]
		args.group[1]:raise()
	end
end

-- close all in group
function redtasklist.action.close(args)
	local args = args or {}
	for i, c in ipairs(args.group) do c:kill() end
end

-- show/close winmenu
function redtasklist.action.menu(args)
	local args = args or {}
	redtasklist.winmenu:show(args.group, args.gap)
end

-- switch to next task
function redtasklist.action.switch_next(args)
	switch_focus(last.sorted_list)
end

-- switch to previous task
function redtasklist.action.switch_prev(args)
	switch_focus(last.sorted_list, true)
end


-- Filtering functions
-- @param c The client
-- @param screen The screen we are drawing on
-----------------------------------------------------------------------------------------------------------------------

-- To include all clients
--------------------------------------------------------------------------------
function redtasklist.filter.allscreen(c, screen)
	return true
end

-- To include the clients from all tags on the screen
--------------------------------------------------------------------------------
function redtasklist.filter.alltags(c, screen)
	return c.screen == screen
end

-- To include only the clients from currently selected tags
--------------------------------------------------------------------------------
function redtasklist.filter.currenttags(c, screen)
	if c.screen ~= screen then return false end
	if c.sticky then return true end

	local tags = tag.gettags(screen)

	for k, t in ipairs(tags) do
		if t.selected then
			local ctags = c:tags()

			for _, v in ipairs(ctags) do
				if v == t then return true end
			end
		end
	end

	return false
end

-- To include only the minimized clients from currently selected tags
--------------------------------------------------------------------------------
function redtasklist.filter.minimizedcurrenttags(c, screen)
	if c.screen ~= screen then return false end
	if not c.minimized then return false end
	if c.sticky then return true end

	local tags = tag.gettags(screen)

	for k, t in ipairs(tags) do
		if t.selected then
			local ctags = c:tags()

			for _, v in ipairs(ctags) do
				if v == t then return true end
			end
		end
	end

	return false
end

-- To include only the currently focused client
--------------------------------------------------------------------------------
function redtasklist.filter.focused(c, screen)
	return c.screen == screen and client.focus == c
end

-- Config metatable to call redtasklist module as function
-----------------------------------------------------------------------------------------------------------------------
function redtasklist.mt:__call(...)
	return redtasklist.new(...)
end

return setmetatable(redtasklist, redtasklist.mt)
