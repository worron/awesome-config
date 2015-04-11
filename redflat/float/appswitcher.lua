-----------------------------------------------------------------------------------------------------------------------
--                                             RedFlat appswitcher widget                                            --
-----------------------------------------------------------------------------------------------------------------------
-- Advanced application switcher
-----------------------------------------------------------------------------------------------------------------------
-- Some code was taken from
------ Familiar Alt Tab by Joren Heit
------ https://github.com/jorenheit/awesome_alttab
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local type = type
local math = math
local unpack = unpack
local table = table

local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local gears = require("gears")

local dfparser = require("redflat.service.dfparser")
local redutil = require("redflat.util")
local redtitlebar = require("redflat.titlebar")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local appswitcher = { clients_list = {}, index = 1, hotkeys = {} }

local cache = { titlebar = {}, border_cololr = nil }

-- key bindings
appswitcher.keys = {
	next  = { "a", "A" },
	prev  = { "q", "Q" },
	close = { "Super_L" },
}


-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		wibox_height    = 200,
		label_height    = 20,
		title_height    = 20,
		icon_size       = 48,
		preview_gap     = 20,
		preview_format  = 16/10,
		preview_margin  = { 20, 20, 20, 20 },
		border_margin   = { 6, 6, 6, 6 },
		border_width    = 2,
		icon_style      = {},
		update_timeout  = 1,
		min_icon_number = 4,
		title_font      = "Sans 12",
		hotkeys         = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" },
		font            = { font = "Sans", size = 16, face = 0, slant = 0 },
		color           = { border = "#575757", text = "#aaaaaa", main = "#b1222b", preview_bg = "#b1222b80",
		                    wibox  = "#202020", icon = "#a0a0a0", bg   = "#161616", gray = "#575757" }
	}

	return redutil.table.merge(style, redutil.check(beautiful, "float.appswitcher") or {})
end

-- Support functions
-----------------------------------------------------------------------------------------------------------------------

-- Find all clients to be shown
--------------------------------------------------------------------------------
local function clients_find(filter)
	local clients = {}
	for i, c in ipairs(client.get()) do
		if not (c.skip_taskbar or c.hidden or c.type == "splash" or c.type == "dock" or c.type == "desktop")
		and filter(c, mouse.screen) then
			table.insert(clients, c)
		end
	end
	return clients
end

-- Loop iterating through table
--------------------------------------------------------------------------------
local function iterate(tabl, i, diff)
	local nxt = i + diff

	if nxt > #tabl then nxt = 1
	elseif nxt < 1 then nxt = #tabl end

	return nxt
end

-- Select new focused window
--------------------------------------------------------------------------------
local function focus_and_raise(c)
	if c.minimized then c.minimized = false end

	if not c:isvisible() then
		awful.tag.viewmore(c:tags(), c.screen)
	end

	client.focus = c
	c:raise()
end

-- Initialize appswitcher widget
-----------------------------------------------------------------------------------------------------------------------
function appswitcher:init()

	-- Initialize style vars
	--------------------------------------------------------------------------------
	local style = default_style()
	local icon_db = dfparser.icon_list(style.icon_style)
	local iscf = 1 -- icon size correction factor

	-- Create floating wibox for appswitcher widget
	--------------------------------------------------------------------------------
	self.wibox = wibox({
		ontop        = true,
		bg           = style.color.wibox,
		border_width = style.border_width,
		border_color = style.color.border
	})

	-- Keygrabber
	--------------------------------------------------------------------------------
	local function focus_by_key(key)
		self:switch({ index = awful.util.table.hasitem(style.hotkeys, key) })
	end

	self.keygrabber = function(mod, key, event)
		if event == "press" then return false
		elseif awful.util.table.hasitem(self.keys.close, key) then self:hide()
		elseif awful.util.table.hasitem(self.keys.next,  key) then self:switch()
		elseif awful.util.table.hasitem(self.keys.prev,  key) then self:switch({ reverse = true })
		elseif awful.util.table.hasitem(style.hotkeys,   key) then focus_by_key(key)
		else
			return false
		end
	end

	-- Function to form title string for given client (name and tags)
	--------------------------------------------------------------------------------
	function self.title_generator(c)
		local client_tags = ""
		for _, t in ipairs(c:tags()) do
			client_tags = client_tags .. " " .. string.upper(t.name)
		end
		client_tags = '<span color="' .. style.color.gray .. '">' .. "  [" .. client_tags .. " ]" .. "</span>"
		return (awful.util.escape(c.name) or "Untitled") .. client_tags
	end

	-- Function to mark window (border color change)
	--------------------------------------------------------------------------------
	function self.winmark(c, mark)
		if mark then
			cache.border_color = c.border_color
			c.border_color = style.color.main
		else
			c.border_color = cache.border_color
		end
	end

	-- Function to correct wibox size for given namber of icons
	--------------------------------------------------------------------------------
	function self.size_correction(inum)
		local w, h
		local inum = math.max(inum, style.min_icon_number)
		local expen_h = (inum - 1) * style.preview_gap + style.preview_margin[1] + style.preview_margin[2]
		                + style.border_margin[1] + style.border_margin[2]
		local expen_v = style.label_height + style.preview_margin[3] + style.preview_margin[4] + style.title_height
		                + style.border_margin[3] + style.border_margin[4]

		-- calculate width
		local widget_height = style.wibox_height - expen_v + style.label_height
		local max_width = screen[mouse.screen].geometry.width - 2 * self.wibox.border_width
		local wanted_width = inum * ((widget_height - style.label_height) * style.preview_format) + expen_h

		-- check if need size correction
		if wanted_width <= max_width then
			-- correct width
			w = wanted_width
			h = style.wibox_height
			iscf = 1
		else
			-- correct height
			wanted_widget_width = (max_width - expen_h) / inum
			corrected_height = wanted_widget_width / style.preview_format + expen_v

			w = max_width
			h = corrected_height
			iscf = (corrected_height - expen_v) / (style.wibox_height - expen_v)
		end

		-- set wibox size
		self.wibox:geometry({ width = w, height = h })
	end

	-- Create custom widget to draw previews
	--------------------------------------------------------------------------------
	local widg = wibox.widget.base.make_widget()

	-- Fit
	------------------------------------------------------------
	widg.fit = function(widg, width, height) return width, height end

	-- Draw
	------------------------------------------------------------
	widg.draw = function(widg, wibox, cr, width, height)

		-- calculate preview pattern size
		local psize = {
			width = (height - style.label_height) * style.preview_format,
			height = (height - style.label_height)
		}

		-- Shift pack of preview icons to center of widget if needed
		if #self.clients_list < style.min_icon_number then
			local tr = (style.min_icon_number - #self.clients_list) * (style.preview_gap + psize.width) / 2
			cr:translate(tr, 0)
		end

		-- draw all previews
		for i = 1, #self.clients_list do

			-- support vars
			local sc, tr, surface
			local c = self.clients_list[i]

			-- create surface and calculate scale and translate factors
			if c:isvisible() then
				surface = gears.surface(c.content)
				local cg = c:geometry()

				if cg.width/cg.height > style.preview_format then
					sc = psize.width / cg.width
					tr = {0, (psize.height - sc * cg.height) / 2}
				else
					sc = psize.height / cg.height
					tr = {(psize.width - sc * cg.width) / 2, 0}
				end
			else
				surface = gears.surface(icon_db[string.lower(c.class)] or c.icon)

				sc = style.icon_size / surface.width * iscf
				tr = {(psize.width - style.icon_size * iscf) / 2, (psize.height - style.icon_size * iscf) / 2}
			end

			-- translate cairo for every icon
			if i > 1 then cr:translate(style.preview_gap + psize.width, 0) end

			-- draw background for preview
			cr:set_source(gears.color(i == self.index and style.color.main or style.color.preview_bg))
			cr:rectangle(0, 0, psize.width, psize.height)
			cr:fill()

			-- draw current preview or application icon
			cr:save()
			cr:translate(unpack(tr))
			cr:scale(sc, sc)

			cr:set_source_surface(surface, 0, 0)
			cr:paint()
			cr:restore()

			-- draw label
			local txt = style.hotkeys[i] or "?"
			cr:set_source(gears.color(i == self.index and style.color.main or style.color.text))
			redutil.cairo.set_font(cr, style.font)
			redutil.cairo.tcenter_horizontal(cr, { psize.width/2, psize.height + style.label_height }, txt)
		end
	end

	-- Set widget and create title for wibox
	--------------------------------------------------------------------------------
	self.widget = widg

	self.titlebox = wibox.widget.textbox("TEXT")
	self.titlebox:set_align("center")
	self.titlebox:set_font(style.title_font)

	local title_layout = wibox.layout.constraint(self.titlebox, "exact", nil, style.title_height)
	local vertical_layout = wibox.layout.fixed.vertical()
	local widget_bg = wibox.widget.background(
		wibox.layout.margin(self.widget, unpack(style.preview_margin)),
		style.color.bg
	)
	vertical_layout:add(title_layout)
	vertical_layout:add(widget_bg)

	self.wibox:set_widget(wibox.layout.margin(vertical_layout, unpack(style.border_margin)))

	-- Set preview icons update timer
	--------------------------------------------------------------------------------
	self.update_timer = timer({ timeout = style.update_timeout })
	self.update_timer:connect_signal("timeout", function() self.widget:emit_signal("widget::updated") end)

	-- Restart switcher if any client was closed
	--------------------------------------------------------------------------------
	client.connect_signal("unmanage",
		function(c)
			if self.wibox.visible and awful.util.table.hasitem(self.clients_list, c) then
				self:hide(true)
				self:show(cache.args)
			end
		end
	)
end

-- Show appswitcher widget
-----------------------------------------------------------------------------------------------------------------------
function appswitcher:show(args)

	local args = args or {}
	local filter = args.filter

	if not self.wibox then self:init() end
	if self.wibox.visible then
		self:switch(args)
		return
	end

	local clients = clients_find(filter)
	if #clients == 0 then return end

	self.clients_list = clients
	cache.titlebar = redtitlebar.hide_all(clients)
	cache.args = args
	self.size_correction(#clients)
	redutil.placement.centered(self.wibox, nil, screen[mouse.screen].workarea)
	self.wibox.visible = true
	self.update_timer:start()
	awful.keygrabber.run(self.keygrabber)

	self.index = awful.util.table.hasitem(self.clients_list, client.focus) or 1
	self.winmark(self.clients_list[self.index], true)
	self:switch(args)
	self.widget:emit_signal("widget::updated")
end

-- Hide appswitcher widget
-----------------------------------------------------------------------------------------------------------------------
function appswitcher:hide(is_empty_call)

	if not self.wibox then self:init() end
	if not self.wibox.visible then return end
	self.wibox.visible = false
	self.update_timer:stop()
	redtitlebar.show_all(cache.titlebar)
	awful.keygrabber.stop(self.keygrabber)

	self.winmark(self.clients_list[self.index], false)
	if not is_empty_call then focus_and_raise(self.clients_list[self.index]) end
end

-- Toggle appswitcher widget
-----------------------------------------------------------------------------------------------------------------------
function appswitcher:switch(args)
	local args = args or {}
	self.winmark(self.clients_list[self.index], false)

	if args.index then
		if self.clients_list[args.index] then self.index = args.index end
	else
		local reverse = args.reverse or false
		local diff = reverse and -1 or 1
		self.index = iterate(self.clients_list, self.index, diff)
	end

	self.winmark(self.clients_list[self.index], true)
	self.titlebox:set_markup(self.title_generator(self.clients_list[self.index]))
	self.widget:emit_signal("widget::updated")
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return appswitcher
