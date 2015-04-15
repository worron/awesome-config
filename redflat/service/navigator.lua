-----------------------------------------------------------------------------------------------------------------------
--                                            RedFlat focus switch util                                              --
-----------------------------------------------------------------------------------------------------------------------
-- Visual swap and focus switch helper
-- Group window with redfalt titlebar
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local math = math

local awful = require("awful")
local wibox = require("wibox")
local color = require("gears.color")
local beautiful = require("beautiful")

local redutil = require("redflat.util")
local redbar = require("redflat.titlebar")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local navigator = {}

local data = { group = false, gruop_list = {} }

-- default keys
navigator.keys = {
	num = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "F1", "F3", "F4", "F5" },
	kill = { "c", "C" },
	group_make = { "g", "G" },
	group_destroy = { "d", "D" },
	mod  = { total = "Shift" },
	close = { "Escape", "Super_L" },
}

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		geometry     = { width = 200, height = 80 },
		border_width = 2,
		marksize     = { width = 200, height = 100, r = 20 },
		gradstep     = 100,
		linegap      = 35,
		titlefont    = { font = "Sans", size = 28, face = 1, slant = 0 },
		font         = { font = "Sans", size = 22, face = 1, slant = 0 },
		color        = { border = "#575757", wibox = "#00000000", bg1 = "#57575740", bg2 = "#57575720",
		                 fbg1 = "#b1222b40", fbg2 = "#b1222b20", mark = "#575757", text = "#202020" }
	}
	return redutil.table.merge(style, redutil.check(beautiful, "service.navigator") or {})
end

-- Support functions
-----------------------------------------------------------------------------------------------------------------------

-- Window painting
--------------------------------------------------------------------------------
function navigator.make_paint(c)

	-- Initialize vars
	------------------------------------------------------------
	local style = navigator.style
	local widg = wibox.widget.base.make_widget()

	local data = {
		client = c,
	}

	-- User functions
	------------------------------------------------------------
	function widg:set_client(c)
		data.client = c
		self:emit_signal("widget::updated")
	end

	-- Fit
	------------------------------------------------------------
	widg.fit = function(widg, width, height) return width, height end

	-- Draw
	------------------------------------------------------------
	widg.draw = function(widg, wibox, cr, width, height)

		if not data.client then return end

		-- background
		local num = math.ceil((width + height) / style.gradstep)
		local is_focused = data.client == client.focus
		local bg1 = is_focused and style.color.fbg1 or style.color.bg1
		local bg2 = is_focused and style.color.fbg2 or style.color.bg2

		for i = 1, num do
			local cc = i % 2 == 1 and bg1 or bg2
			local l = i * style.gradstep

			cr:set_source(color(cc))
			cr:move_to(0, (i - 1) * style.gradstep)
			cr:rel_line_to(0, style.gradstep)
			cr:rel_line_to(l, - l)
			cr:rel_line_to(- style.gradstep, 0)
			cr:close_path()
			cr:fill()
		end

		-- rounded rectangle on center
		local r = style.marksize.r
		local w, h = style.marksize.width - 2 * r, style.marksize.height - 2 * r

		cr:set_source(color(style.color.mark))
		cr:move_to((width - w) / 2 - r, (height - h) / 2)
		cr:rel_curve_to(0, -r, 0, -r, r, -r)
		cr:rel_line_to(w, 0)
		cr:rel_curve_to(r, 0, r, 0, r, r)
		cr:rel_line_to(0, h)
		cr:rel_curve_to(0, r, 0, r, -r, r)
		cr:rel_line_to(-w, 0)
		cr:rel_curve_to(-r, 0, -r, 0, -r, -r)
		cr:close_path()
		cr:fill()

		-- label
		local index = navigator.keys.num[awful.util.table.hasitem(navigator.cls, data.client)]
		local g = redutil.client.fullgeometry(data.client)

		cr:set_source(color(style.color.text))
		redutil.cairo.set_font(cr, style.titlefont)
		redutil.cairo.tcenter(cr, { width/2, height/2 - style.linegap / 2 }, index)
		redutil.cairo.set_font(cr, style.font)
		redutil.cairo.tcenter(cr, { width/2, height/2 + style.linegap / 2 }, g.width .. " x " .. g.height)
	end

	------------------------------------------------------------
	return widg
end

-- Construct wibox
--------------------------------------------------------------------------------
function navigator.make_decor(c)
	local object = {}
	local style = navigator.style

	-- Create wibox
	------------------------------------------------------------
	object.wibox = wibox({
		ontop        = true,
		bg           = style.color.wibox,
		border_width = style.border_width,
		border_color = style.color.border
	})

	object.client = c
	object.widget = navigator.make_paint(c)
	object.wibox:set_widget(object.widget)

	-- User functions
	------------------------------------------------------------
	object.update =  {
		focus = function() object.widget:emit_signal("widget::updated") end,
		close = function() navigator:restart() end,
		geometry = function() redutil.client.fullgeometry(object.wibox, redutil.client.fullgeometry(object.client)) end
	}

	function object:set_client(c)
		object.client = c
		object.widget:set_client(c)
		redutil.client.fullgeometry(object.wibox, redutil.client.fullgeometry(object.client))

		object.client:connect_signal("focus", object.update.focus)
		object.client:connect_signal("unfocus", object.update.focus)
		object.client:connect_signal("property::geometry", object.update.geometry)
		object.client:connect_signal("unmanage", object.update.close)
	end

	function object:clear(no_hide)
		object.client:disconnect_signal("focus", object.update.focus)
		object.client:disconnect_signal("unfocus", object.update.focus)
		object.client:disconnect_signal("property::geometry", object.update.geometry)
		object.client:disconnect_signal("unmanage", object.update.close)
		object.widget:set_client()
		if not no_hide then object.wibox.visible = false end
	end

	------------------------------------------------------------
	object:set_client(c)
	return object
end

-- keygrabber
-----------------------------------------------------------------------------------------------------------------------
navigator.raw_keygrabber = function(mod, key, event)
	local index = awful.util.table.hasitem(navigator.keys.num, key)

	if awful.util.table.hasitem(navigator.keys.group_make, key) then
		if navigator.group then
			redbar.set_group(navigator.group_list)
			navigator:restart()
		else
			navigator.group = true
			navigator.group_list = {}
		end
	elseif awful.util.table.hasitem(navigator.keys.group_destroy, key) then
		if awful.util.table.hasitem(mod, navigator.keys.mod.total) then
			redbar.destroy_group(client.focus)
		else
			redbar.ungroup(client.focus)
		end
		navigator:restart()
	elseif awful.util.table.hasitem(navigator.keys.kill, key) then
		client.focus:kill()
		navigator:restart()
	elseif index then
		local index = awful.util.table.hasitem(navigator.keys.num, key)

		if data[index] and awful.util.table.hasitem(navigator.cls, data[index].client) then
			if navigator.group then
				table.insert(navigator.group_list, data[index].client)
			elseif navigator.last then
				if navigator.last == index then
					client.focus = data[index].client
					client.focus:raise()
				else
					redutil.client.swap(data[navigator.last].client, data[index].client)
				end
				navigator.last = nil
			else
				navigator.last = index
			end
		end

		return true
	end

	return false
end

navigator.keygrabber = function(mod, key, event)
	if event == "press" then return false
	elseif awful.util.table.hasitem(navigator.keys.close, key) then navigator:close()
	elseif navigator.raw_keygrabber(mod, key, event) then return true
	else return false
	end
end

-- Main functions
-----------------------------------------------------------------------------------------------------------------------
function navigator:run(is_soft)
	if not self.style then self.style = default_style() end

	local s = mouse.screen
	self.cls = awful.client.tiled(s)

	if #self.cls == 0 then return end

	for i, c in ipairs(self.cls) do
		if not data[i] then
			data[i] = self.make_decor(c)
		else
			data[i]:set_client(c)
		end

		data[i].wibox.visible = true
	end

	if not is_soft then awful.keygrabber.run(self.keygrabber) end
end

function navigator:close(is_soft)
	for i, c in ipairs(self.cls) do
		data[i]:clear()
	end

	if not is_soft then awful.keygrabber.stop(navigator.keygrabber) end
	navigator.last = nil
	navigator.group = false
	navigator.group_list = {}
end

function navigator:restart()
	--clear navigator info
	navigator.last = nil
	navigator.group = false
	navigator.group_list = {}

	-- update decoration
	for i, c in ipairs(self.cls) do data[i]:clear(true) end
	local newcls = awful.client.tiled(mouse.screen)
	for i = 1, math.max(#self.cls, #newcls) do
		if newcls[i] then
			if not data[i] then
				data[i] = self.make_decor(newcls[i])
			else
				data[i]:set_client(newcls[i])
			end

			data[i].wibox.visible = true
		else
			data[i].wibox.visible = false
		end
	end

	self.cls = newcls
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return navigator
