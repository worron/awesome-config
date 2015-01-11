-----------------------------------------------------------------------------------------------------------------------
--                                            RedFlat taglist widget                                                 --
-----------------------------------------------------------------------------------------------------------------------
-- Custom widget used to display tag info
-- Separators added
-----------------------------------------------------------------------------------------------------------------------
-- Some code was taken from
------ awful.widget.taglist v3.5.2
------ (c) 2008-2009 Julien Danjou
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local pairs = pairs
local ipairs = ipairs
local table = table
local string = string
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

local redutil = require("redflat.util")
local redtag = require("redflat.gauge.tag")

-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local taglist = { filter = {}, mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		tag       = {},
		widget    = redtag.new,
		separator = nil
	}
	return redutil.table.merge(style, beautiful.widget.taglist or {})
end

-- Support functions
-----------------------------------------------------------------------------------------------------------------------

-- Check if any client in given list have urgent mark
--------------------------------------------------------------------------------
local function is_urgent(client_list)
	local urgent = false
	for _, c in pairs(client_list) do
		if c.urgent then
			urgent = true
			break
		end
	end
	return urgent
end

-- Get info about tag
--------------------------------------------------------------------------------
local function get_state(t)
	local state = {}
	local focused_client = client.focus
	local client_list = t:clients()

	-- check if tag active
	state.active = t.selected
	-- check if tag has focused window
	state.focus = focused_client and awful.util.table.hasitem(focused_client:tags(), t) ~= nil or false
	-- check if tag has any non focused windows
	state.occupied = #client_list > 0 and not (#client_list == 1 and state.focus)
	-- check if tag has urgent client
	state.urgent = state.occupied and is_urgent(client_list)
	-- read tag name
	state.text = string.upper(t.name)

	return state
end

-- Find all tag to be shown
--------------------------------------------------------------------------------
local function filtrate_tags(screen, filter)
	local tags = {}
	for _, t in ipairs(awful.tag.gettags(screen)) do
		if not awful.tag.getproperty(t, "hide") and filter(t) then
			table.insert(tags, t)
		end
	end
	return tags
end

-- Create a new taglist widget
-- @param screen The screen to draw taglist for
-- @param filter Filter function to define what tags will be listed
-- @param buttons A table with buttons binding to set
-- @param style
-----------------------------------------------------------------------------------------------------------------------
function taglist.new(screen, filter, buttons, style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	local style = redutil.table.merge(default_style(), style or {})

	local layout = wibox.layout.fixed.horizontal()
	local data = setmetatable({}, { __mode = 'k' })

	-- Update function
	--------------------------------------------------------------------------------
	local update = function (s)
		if s ~= screen then return end
		local tags = filtrate_tags(s, filter)

		-- Construct taglist
		------------------------------------------------------------
		layout:reset()
		for i, t in ipairs(tags) do
			local cache = data[t]
			local widg

			-- use existing widgets or create new one
			if cache then
				widg = cache
			else
				--widg = redtag(style.tag)
				widg = style.widget(style.tag)
				widg:buttons(redutil.create_buttons(buttons, t))
				data[t] = widg
			end

			-- set tag state info to widget
			local state = get_state(t)
			widg:set_state(state)

			-- add widget and separator to base layout
			layout:add(widg)
			if style.separator and i < #tags then
				layout:add(style.separator)
			end
	   end
		------------------------------------------------------------
	end

	local uc = function (c) return update(c.screen) end
	local ut = function (t) return update(awful.tag.getscreen(t)) end

	-- Signals setup
	--------------------------------------------------------------------------------
	local tag_signals = {
		"property::selected",  "property::icon", "property::hide",
		"property::activated", "property::name", "property::screen",
		"property::index"
	}
	local client_signals = {
		"focus",  "unfocus",  "property::urgent",
		"tagged", "untagged", "unmanage"
	}

	for _, sg in ipairs(tag_signals) do awful.tag.attached_connect_signal(screen, sg, ut) end
	for _, sg in ipairs(client_signals) do client.connect_signal(sg, uc) end

	client.connect_signal("property::screen", function(c) update(screen) end)

	--------------------------------------------------------------------------------
	update(screen) -- create taglist widget
	return layout  -- return taglist widget
end

-- Filtering functions
-- @param t The awful.tag
-- @param args unused list of extra arguments
-----------------------------------------------------------------------------------------------------------------------
function taglist.filter.noempty(t, args) -- to include all nonempty tags on the screen.
	return #t:clients() > 0 or t.selected
end

function taglist.filter.all(t, args) -- to include all tags on the screen.
	return true
end

-- Config metatable to call taglist module as function
-----------------------------------------------------------------------------------------------------------------------
function taglist.mt:__call(...)
	return taglist.new(...)
end

return setmetatable(taglist, taglist.mt)
