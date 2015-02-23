-----------------------------------------------------------------------------------------------------------------------
--                                          RedFlat hotkeys helper widget                                            --
-----------------------------------------------------------------------------------------------------------------------
-- Widget with list of hotkeys
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local type = type
local math = math

local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")

local redutil = require("redflat.util")
local separator = require("redflat.gauge.separator")


-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local hotkeys = { raw_keys = {} }

-- key bindings
hotkeys.keys = {
	close = { "Super_L" },
}

local fake_key = { mod = {}, key = "", comment = "" }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		geometry      = { width = 800, height = 600 },
		border_margin = { 10, 10, 10, 10 },
		sep_margin    = { 20, 20, 10, 10 },
		border_width  = 2,
		keyf_width    = 200,
		colnum        = 1,
		ltimeout      = 0.05,
		font          = "Sans 12",
		keysfont      = "Sans bold 12",
		titlefont     = "Sans bold 14",
		color         = { border = "#575757", text = "#aaaaaa", main = "#b1222b", wibox = "#202020",
		                  gray = "#575757" }
	}

	return redutil.table.merge(style, redutil.check(beautiful, "float.hotkeys") or {})
end

-- Support functions
-----------------------------------------------------------------------------------------------------------------------

-- Get system keycode table
--------------------------------------------------------------------------------
local function keycode_table()
	local output = awful.util.pread("xmodmap -pk")
	local codes = {}

	for line in string.gmatch(output, "[^\n]+") do
		local index = tonumber(string.match(line, "%d+"))

		if index then
			codes[index] = {}
			for key in string.gmatch(line , "%x+%s%(([%a%d_]+)%)") do
				table.insert(codes[index], key)
			end
		end
	end

	return codes
end

-- Find keycode for symbol
--------------------------------------------------------------------------------
local function keycode(key, codetable)
	for code, symbols in pairs(codetable) do
		if awful.util.table.hasitem(symbols, key) then return code end
	end

	return nil
end

-- Highlight key tip
--------------------------------------------------------------------------------
local function highlight(list, codetable, key, last, style)
	local key = key == " " and "space" or key -- !!! fix this !!!

	if key == last.key then return end
	local code = keycode(key, codetable)

	for _, line in ipairs(list) do
		if line.codes and awful.util.table.hasitem(line.codes, code) then
			line.bg:set_fg(style.color.main)

			last.key = key
			table.insert(last.lines, line)
		end
	end
end

-- Parse raw key table
--------------------------------------------------------------------------------
local function parse_raw_keys(raw_keys)
	local keys = {}
	for _, v in ipairs(raw_keys) do
		if v.comment then
			local args = v.args or {}
			table.insert(keys, { mod = args[1], key = args[2], comment = v.comment, codes = v.codes })
		end
	end
	return keys
end

-- Generate full key label
--------------------------------------------------------------------------------
local function form_key_text(key)
	local text = key.key

	if #key.mod > 0 then
		local mod_text = ""

		for i, v in ipairs(key.mod) do
			mod_text = i > 1 and mod_text .. " + " .. v or v
		end

		text = mod_text .. " + " .. text
	end

	return text
end

-- Construct single column with key tips
--------------------------------------------------------------------------------
local function construct_column(keys, codetable, style)
	local column = { line = {} }
	column.layout = wibox.layout.flex.vertical()

	for i, v in ipairs(keys) do
		local line = {}

		if v.key and v.mod then
			line.layout = wibox.layout.fixed.horizontal()
			line.keybox = wibox.widget.textbox(form_key_text(v))
			line.commentbox = wibox.widget.textbox(v.comment)
			line.keybox:set_font(style.keysfont)
			line.commentbox:set_font(style.font)
			--line.keybox:set_align("center")

			line.layout:add(wibox.layout.constraint(line.keybox, "exact", style.keyf_width))
			line.layout:add(line.commentbox)

			line.bg = wibox.widget.background(line.layout)
			line.bg:set_fg(style.color.text)

			if v.codes then
				line.codes = v.codes
			else
				line.codes = { keycode(v.key, codetable) }
			end
		else
			line.layout = wibox.layout.flex.horizontal()
			line.titletbox = wibox.widget.textbox()
			line.titletbox:set_markup('<span color="' .. style.color.gray .. '">' .. v.comment .. '</span>')
			line.titletbox:set_font(style.titlefont)
			--line.titletbox:set_align("center")

			line.layout:add(line.titletbox)
		end

		column.line[i] = line
		column.layout:add(line.bg or line.layout)
	end

	return column
end

-- Split solid key list to group (used for column view)
--------------------------------------------------------------------------------
local function split_to_group(keys, n)
	local rows = math.ceil(#keys / n)
	local kgroup = {}

	for i = 1, n do
		kgroup[i] = {}
		for j = 1, rows do
			local index = (i - 1) * rows + j
			table.insert(kgroup[i], keys[index] or fake_key)
		end
	end

	return kgroup
end

-- Initialize widget
-----------------------------------------------------------------------------------------------------------------------
function hotkeys:init()

	-- Initialize vars
	--------------------------------------------------------------------------------
	local style = default_style()
	local keys = parse_raw_keys(self.raw_keys)
	local key_group = split_to_group(keys, style.colnum)
	local codetable = keycode_table()
	local fulllist = {}
	local last = { lines = {} }

	-- Construct widget layouts
	-- !!! Bad code here. Need more clear conctruction !!!
	--------------------------------------------------------------------------------

	local sep = separator.vertical({ margin = style.sep_margin })
	local fake_sep = wibox.layout.constraint(nil, "exact", style.sep_margin[1] + style.sep_margin[1] + 2)

	local area = wibox.layout.fixed.horizontal()
	local flex_area = wibox.layout.flex.horizontal()
	area:add(fake_sep)

	for i, keys in ipairs(key_group) do
		local column = construct_column(keys, codetable, style)
		local column_with_sep = wibox.layout.align.horizontal()

		for _, v in ipairs(column.line) do table.insert(fulllist, v) end

		column_with_sep:set_right(i == #key_group and fake_sep or sep)
		column_with_sep:set_middle(column.layout)

		flex_area:add(column_with_sep)
	end

	area:add(flex_area)
	local wibox_layout = wibox.layout.margin(area, unpack(style.border_margin))

	-- Create floating wibox for top widget
	--------------------------------------------------------------------------------
	self.wibox = wibox({
		ontop        = true,
		bg           = style.color.wibox,
		border_width = style.border_width,
		border_color = style.color.border
	})

	self.wibox:set_widget(wibox_layout)
	self.wibox:geometry(style.geometry)

	-- Highlight timer
	--------------------------------------------------------------------------------
	local ltimer = timer({ timeout = style.ltimeout })
	ltimer:connect_signal("timeout",
		function()
			ltimer:stop()
			for _, l in ipairs(last.lines) do l.bg:set_fg(style.color.text) end

			last.key = nil
			last.lines = {}
		end
	)

	-- Keygrabber
	--------------------------------------------------------------------------------
	self.keygrabber = function(mod, key, event)
		if event == "press" then
			highlight(fulllist, codetable, key, last, style)
		else
			ltimer:again()
		end

		if awful.util.table.hasitem(self.keys.close, key) then
			self:hide()
		else
			return false
		end
	end

end

-- Show hotkeys widget
-----------------------------------------------------------------------------------------------------------------------
function hotkeys:show()
	if not self.wibox then self:init() end
	if not self.wibox.visible then
		redutil.placement.centered(self.wibox, nil, screen[mouse.screen].workarea)
		self.wibox.visible = true
		awful.keygrabber.run(self.keygrabber)
	else
		self:hide()
	end
end

-- Hide hotkeys widget
-----------------------------------------------------------------------------------------------------------------------
function hotkeys:hide()
	self.wibox.visible = false
	awful.keygrabber.stop(self.keygrabber)
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return hotkeys
