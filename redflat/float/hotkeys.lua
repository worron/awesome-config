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
		font          = "Sans 12",
		keysfont      = "Sans bold 12",
		titlefont     = "Sans bold 14",
		color         = { border = "#575757", text = "#aaaaaa", main = "#b1222b", wibox = "#202020",
		                  gray = "#575757" }
	}

	return redutil.table.merge(style, beautiful.float.hotkeys or {})
end

-- Support functions
-----------------------------------------------------------------------------------------------------------------------

-- Parse raw key table
--------------------------------------------------------------------------------
local function parse_raw_keys(raw_keys)
	local keys = {}
	for _, v in ipairs(raw_keys) do
		if v.comment then
			local args = v.args or {}
			table.insert(keys, { mod = args[1], key = args[2], comment = v.comment })
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
local function construct_column(keys, style)
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
		else
			line.layout = wibox.layout.flex.horizontal()
			line.titletbox = wibox.widget.textbox()
			line.titletbox:set_markup('<span color="' .. style.color.gray .. '">' .. v.comment .. '</span>')
			line.titletbox:set_font(style.titlefont)
			--line.titletbox:set_align("center")

			line.layout:add(line.titletbox)
		end

		column.line[i] = line
		column.layout:add(line.layout)
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

	-- Construct widget layouts
	-- !!! Bad code here. Need more clear conctruction !!!
	--------------------------------------------------------------------------------

	local sep = separator.vertical({ margin = style.sep_margin })
	local fake_sep = wibox.layout.constraint(nil, "exact", style.sep_margin[1] + style.sep_margin[1] + 2)

	local area = wibox.layout.fixed.horizontal()
	local flex_area = wibox.layout.flex.horizontal()
	area:add(fake_sep)

	for i, keys in ipairs(key_group) do
		local column = construct_column(keys, style)
		local column_with_sep = wibox.layout.align.horizontal()

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
	redutil.placement.centered(self.wibox, nil, screen[mouse.screen].workarea)

	-- Keygrabber
	--------------------------------------------------------------------------------
	self.keygrabber = function(mod, key, event)
		if awful.util.table.hasitem(self.keys.close, key) then self:hide()
		else return false
		end
	end

end

-- Show hotkeys widget
-----------------------------------------------------------------------------------------------------------------------
function hotkeys:show()
	if not self.wibox then self:init() end
	if not self.wibox.visible then
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
