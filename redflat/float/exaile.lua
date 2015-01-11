-----------------------------------------------------------------------------------------------------------------------
--                                               RedFlat exaile widget                                               --
-----------------------------------------------------------------------------------------------------------------------
-- Exaile music player widget
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local unpack = unpack

local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local color = require("gears.color")

local redutil = require("redflat.util")
local progressbar = require("redflat.gauge.progressbar")
local dashcontrol = require("redflat.gauge.dashcontrol")
local svgbox = require("redflat.gauge.svgbox")
local asyncshell = require("redflat.asyncshell")

-- Initialize and vars for module
-----------------------------------------------------------------------------------------------------------------------
local exaile = {}

local command = "qdbus org.exaile.Exaile /org/exaile/Exaile org.exaile.Exaile."
local actions = { "PlayPause", "Next", "Prev" }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		geometry       = { width = 520, height = 150, x = 580, y = 864},
		border_gap     = { 20, 20, 20, 20 },
		elements_gap   = { 20, 0, 0, 0 },
		volume_gap     = { 0, 0, 0, 3 },
		control_gap    = { 0, 0, 18, 8 },
		buttons_margin = { 0, 0, 3, 3 },
		pause_gap      = { 12, 12 },
		timeout        = 2,
		line_height    = 26,
		bar_width      = 8, -- progress bar height
		volume_width   = 50,
		titlefont      = "Sans 12",
		timefont       = "Sans 12",
		artistfont     = "Sans 12",
		border_width   = 2,
		icon           = {},
		color          = { border = "#575757", text = "#aaaaaa", main = "#b1222b",
		                   wibox = "#202020", gray = "#575757" }
	}
	return redutil.table.merge(style, beautiful.float.exaile or {})
end

-- Support functions
-----------------------------------------------------------------------------------------------------------------------

-- Check if exaile running
--------------------------------------------------------------------------------
local function is_exaile_running()
	return awful.util.pread("ps -e | grep exaile") ~= ""
end

-- Get line from output
--------------------------------------------------------------------------------
local function get_line(s)
	local line = string.match(s, "[^\n]+")
	return line or "Unknown"
end

-- Initialize exaile widget
-----------------------------------------------------------------------------------------------------------------------
function exaile:init()

	-- Initialize vars
	--------------------------------------------------------------------------------
	local style = default_style()
	local tr_command = command .. "GetTrackAttr"
	local show_album = false

	-- Construct layouts
	--------------------------------------------------------------------------------

	-- progressbar and icon
	local bar = progressbar(style.progressbar)
	local image = svgbox(style.icon.cover)
	image:set_color(style.color.icon)

	-- Text lines
	------------------------------------------------------------
	local titlebox = wibox.widget.textbox("Title")
	local artistbox = wibox.widget.textbox("Artist")
	titlebox:set_font(style.titlefont)
	artistbox:set_font(style.artistfont)

	local text_area = wibox.layout.fixed.vertical()
	text_area:add(wibox.layout.constraint(titlebox, "exact", nil, style.line_height))
	text_area:add(wibox.layout.constraint(artistbox, "exact", nil, style.line_height))

	-- Control line
	------------------------------------------------------------

	-- playback buttons
	local player_buttons = wibox.layout.fixed.horizontal()
	local prev_button = svgbox(style.icon.prev_tr, false)
	prev_button:set_color(style.color.icon)
	player_buttons:add(prev_button)

	self.play_button = svgbox(style.icon.pause, false)
	self.play_button:set_color(style.color.icon)
	player_buttons:add(wibox.layout.margin(self.play_button, unpack(style.pause_gap)))

	local next_button = svgbox(style.icon.next_tr, false)
	next_button:set_color(style.color.icon)
	player_buttons:add(next_button)

	-- time indicator
	local timebox = wibox.widget.textbox("0:00")
	timebox:set_font(style.timefont)

	-- volume
	self.volume = dashcontrol(style.dashcontrol)
	local volumespace = wibox.layout.margin(self.volume, unpack(style.volume_gap))
	local volume_area = wibox.layout.constraint(volumespace, "exact", style.volume_width, nil)

	-- full line
	local control_align = wibox.layout.align.horizontal()
	control_align:set_middle(wibox.layout.margin(player_buttons, unpack(style.buttons_margin)))
	control_align:set_right(timebox)
	control_align:set_left(volume_area)

	-- Bring it all together
	------------------------------------------------------------
	local align_vertical = wibox.layout.align.vertical()
	align_vertical:set_top(text_area)
	align_vertical:set_middle(wibox.layout.margin(control_align, unpack(style.control_gap)))
	align_vertical:set_bottom(wibox.layout.constraint(bar, "exact", nil, style.bar_width))
	local area = wibox.layout.fixed.horizontal()
	area:add(image)
	area:add(wibox.layout.margin(align_vertical, unpack(style.elements_gap)))

	-- Buttons
	------------------------------------------------------------

	-- playback controll
	self.play_button:buttons(awful.util.table.join(awful.button({ }, 1, function() self:action("PlayPause") end)))
	next_button:buttons(awful.util.table.join(awful.button({ }, 1, function() self:action("Next") end)))
	prev_button:buttons(awful.util.table.join(awful.button({ }, 1, function() self:action("Prev") end)))

	-- volume
	self.volume:buttons(awful.util.table.join(
		awful.button({ }, 4, function() self:change_volume() end),
		awful.button({ }, 5, function() self:change_volume(true) end)
	))

	-- switch between artist and album info on mouse click
	artistbox:buttons(awful.util.table.join(
		awful.button({ }, 1,
			function()
				show_album = not show_album
				self:update()
				self.updatetimer:stop()
				self.updatetimer:start()
			end
		)
	))

	-- Create floating wibox for exaile widget
	--------------------------------------------------------------------------------
	self.wibox = wibox({
		ontop        = true,
		bg           = style.color.wibox,
		border_width = style.border_width,
		border_color = style.color.border
	})

	self.wibox:set_widget(wibox.layout.margin(area, unpack(style.border_gap)))
	self.wibox:geometry(style.geometry)
	awful.placement.no_offscreen(self.wibox)

	-- Update info function
	--------------------------------------------------------------------------------

	-- Function to set info for artist/album line
	------------------------------------------------------------
	local function show_artist_or_album_info(show_album)
		if show_album then
			asyncshell.request(tr_command .. " album",
				function(o)
					artistbox:set_markup('<span color="' .. style.color.gray .. '">From </span>' .. get_line(o))
				end
			)
		else
			asyncshell.request(tr_command .. " artist",
				function(o)
					artistbox:set_markup('<span color="' .. style.color.gray .. '">By </span>' .. get_line(o))
				end
			)
		end
	end

	-- Check if music is playing now and update track info
	------------------------------------------------------------
	local function check_if_playing(output)
		if get_line(output) == "playing" then
			asyncshell.request(tr_command .. " title", function(o) titlebox:set_text(get_line(o)) end)
			asyncshell.request(command .. "CurrentPosition", function(o) timebox:set_text(get_line(o)) end)
			asyncshell.request(command .. "GetVolume", function(o) self.volume:set_value(get_line(o) /100) end)
			asyncshell.request(command .. "CurrentProgress", function(o) bar:set_value(get_line(o) /100) end)

			show_artist_or_album_info(show_album)
			self.play_button:set_image(style.icon.pause)
		else
			self.play_button:set_image(style.icon.play)
		end
	end

	-- Main update function
	------------------------------------------------------------
	function self:update()
		if is_exaile_running() then
			asyncshell.request(command .. "GetState", check_if_playing)
			image:set_color(style.color.gray)
		else
			image:set_color(style.color.main)
		end
	end

	-- Set update timer
	--------------------------------------------------------------------------------
	self.updatetimer = timer({ timeout = style.timeout })
	self.updatetimer:connect_signal("timeout", function() self:update() end)
end

-- Player playback control
-----------------------------------------------------------------------------------------------------------------------
function exaile:action(args)
	if not awful.util.table.hasitem(actions, args) then return end
	if not exaile.wibox then exaile:init() end

	if is_exaile_running() then
		awful.util.spawn_with_shell(command .. args)
		self:update()
		if self.wibox.visible then
			self.updatetimer:stop()
			self.updatetimer:start()
		end
	end
end

-- Player volume control
-----------------------------------------------------------------------------------------------------------------------
function exaile:change_volume(down)
	if is_exaile_running() ~= "" then
		local down = down or false
		local step = down and "-5" or "5"

		awful.util.spawn_with_shell(command .. "ChangeVolume " .. step)
		self.volume:set_value(get_line(awful.util.pread(command .. "GetVolume")) / 100)
	end
end

-- Hide exaile widget
-----------------------------------------------------------------------------------------------------------------------
function exaile:hide()
	self.wibox.visible = false
	self.updatetimer:stop()
end

-- Show exaile widget
-----------------------------------------------------------------------------------------------------------------------
function exaile:show()
	if not self.wibox then self:init() end

	if not self.wibox.visible then
		self:update()
		self.wibox.visible = true
		self.updatetimer:start()
	else
		self:hide()
	end
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return exaile
