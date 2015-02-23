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
local exaile = { box = {} }

local last = { status = "Stopped" }

local command = "dbus-send --type=method_call --session --print-reply=literaly "
                .. "--dest=org.exaile.Exaile /org/exaile/Exaile org.exaile.Exaile."
local actions = { "PlayPause", "Next", "Prev" }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		geometry       = { width = 520, height = 150 },
		screen_gap     = 0,
		screen_pos     = {},
		border_gap     = { 20, 20, 20, 20 },
		elements_gap   = { 20, 0, 0, 0 },
		volume_gap     = { 0, 0, 0, 3 },
		control_gap    = { 0, 0, 18, 8 },
		buttons_margin = { 0, 0, 3, 3 },
		pause_gap      = { 12, 12 },
		timeout        = 5,
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
	return redutil.table.merge(style, redutil.check(beautiful, "float.exaile") or {})
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
	local line = string.match(s, "%s+(.+)")
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

	self.info = { artist = "Unknown", album = "Unknown" }
	self.style = style

	-- Construct layouts
	--------------------------------------------------------------------------------

	-- progressbar and icon
	self.bar = progressbar(style.progressbar)
	self.box.image = svgbox(style.icon.cover)
	self.box.image:set_color(style.color.gray)

	-- Text lines
	------------------------------------------------------------
	self.box.title = wibox.widget.textbox("Title")
	self.box.artist = wibox.widget.textbox("Artist")
	self.box.title:set_font(style.titlefont)
	self.box.artist:set_font(style.artistfont)

	local text_area = wibox.layout.fixed.vertical()
	text_area:add(wibox.layout.constraint(self.box.title, "exact", nil, style.line_height))
	text_area:add(wibox.layout.constraint(self.box.artist, "exact", nil, style.line_height))

	-- Control line
	------------------------------------------------------------

	-- playback buttons
	local player_buttons = wibox.layout.fixed.horizontal()
	local prev_button = svgbox(style.icon.prev_tr, false)
	prev_button:set_color(style.color.icon)
	player_buttons:add(prev_button)

	self.play_button = svgbox(style.icon.play, false)
	self.play_button:set_color(style.color.icon)
	player_buttons:add(wibox.layout.margin(self.play_button, unpack(style.pause_gap)))

	local next_button = svgbox(style.icon.next_tr, false)
	next_button:set_color(style.color.icon)
	player_buttons:add(next_button)

	-- time indicator
	self.box.time = wibox.widget.textbox("0:00")
	self.box.time:set_font(style.timefont)

	-- volume
	self.volume = dashcontrol(style.dashcontrol)
	local volumespace = wibox.layout.margin(self.volume, unpack(style.volume_gap))
	local volume_area = wibox.layout.constraint(volumespace, "exact", style.volume_width, nil)

	-- full line
	local control_align = wibox.layout.align.horizontal()
	control_align:set_middle(wibox.layout.margin(player_buttons, unpack(style.buttons_margin)))
	control_align:set_right(self.box.time)
	control_align:set_left(volume_area)

	-- Bring it all together
	------------------------------------------------------------
	local align_vertical = wibox.layout.align.vertical()
	align_vertical:set_top(text_area)
	align_vertical:set_middle(wibox.layout.margin(control_align, unpack(style.control_gap)))
	align_vertical:set_bottom(wibox.layout.constraint(self.bar, "exact", nil, style.bar_width))
	local area = wibox.layout.fixed.horizontal()
	area:add(self.box.image)
	area:add(wibox.layout.margin(align_vertical, unpack(style.elements_gap)))

	-- Buttons
	------------------------------------------------------------

	-- playback controll
	self.play_button:buttons(awful.util.table.join(awful.button({}, 1, function() self:action("PlayPause") end)))
	next_button:buttons(awful.util.table.join(awful.button({}, 1, function() self:action("Next") end)))
	prev_button:buttons(awful.util.table.join(awful.button({}, 1, function() self:action("Prev") end)))

	-- volume
	self.volume:buttons(awful.util.table.join(
		awful.button({}, 4, function() self:change_volume() end),
		awful.button({}, 5, function() self:change_volume(true) end)
	))

	-- switch between artist and album info on mouse click
	self.box.artist:buttons(awful.util.table.join(
		awful.button({}, 1,
			function()
				show_album = not show_album
				self.update_artist()
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

	-- Update info functions
	--------------------------------------------------------------------------------

	-- Function to set play button state
	------------------------------------------------------------
	self.set_play_button = function(state)
		self.play_button:set_image(style.icon[state])
	end

	-- Function to set info for artist/album line
	------------------------------------------------------------
	self.update_artist = function()
		if show_album then
			self.box.artist:set_markup('<span color="' .. style.color.gray .. '">From </span>' .. self.info.album)
		else
			self.box.artist:set_markup('<span color="' .. style.color.gray .. '">By </span>' .. self.info.artist)
		end
	end

	-- Set defs
	------------------------------------------------------------
	self.clear_info = function(is_att)
		self.box.image:set_image(style.icon.cover)
		self.box.image:set_color(is_att and style.color.main or style.color.gray)

		self.box.time:set_text("0:00")
		self.bar:set_value(0)
		--self.box.title:set_text("Stopped")
		--self.info = { artist = "", album = "" }
		--self.update_artist()
	end

	-- Main update function
	------------------------------------------------------------
	function self:update()
		if is_exaile_running() then
			if last.status ~= "Stopped" then
				asyncshell.request(command .. "CurrentPosition", function(o) self.box.time:set_text(get_line(o)) end)
				asyncshell.request(command .. "CurrentProgress", function(o) self.bar:set_value(o / 100) end)
			end
		else
			self.clear_info(true)
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
	end
end

-- Player volume control
-----------------------------------------------------------------------------------------------------------------------
function exaile:change_volume(is_down)
	if is_exaile_running() then
		local down = is_down or false
		local step = down and "-5" or "5"

		awful.util.spawn_with_shell(command .. "ChangeVolume int32:" .. step)
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
		if self.style.screen_pos[mouse.screen] then self.wibox:geometry(self.style.screen_pos[mouse.screen]) end
		redutil.placement.no_offscreen(self.wibox, self.style.screen_gap, screen[mouse.screen].workarea)
		self.wibox.visible = true
		if last.status == "Playing" then self.updatetimer:start() end
	else
		self:hide()
	end
end

-- Dbus signal setup
-- update some info which avaliable from dbus signal
-----------------------------------------------------------------------------------------------------------------------
dbus.request_name("session", "org.freedesktop.DBus.Properties")
dbus.add_match(
	"session",
	"path=/org/mpris/MediaPlayer2, interface='org.freedesktop.DBus.Properties', member='PropertiesChanged'"
)
dbus.connect_signal("org.freedesktop.DBus.Properties",
	function (_, _, data)
		if not exaile.wibox then exaile:init() end

		--if data.PlaybackStatus and data.PlaybackStatus ~= last.status then
		if data.PlaybackStatus then
			-- check player status and set suitable play/pause button image
			local state = data.PlaybackStatus == "Playing" and "pause" or "play"
			exaile.set_play_button(state)
			last.status = data.PlaybackStatus

			-- stop/start update timer
			if data.PlaybackStatus == "Playing" then
				if exaile.wibox.visible then exaile.updatetimer:start() end
			else
				exaile.updatetimer:stop()
				exaile:update()
			end

			-- clear track info if stoppped
			if data.PlaybackStatus == "Stopped" then
				exaile.clear_info()
			end
		end

		if data.Metadata then
			-- set song title
			exaile.box.title:set_text(data.Metadata["xesam:title"] or "Unknown")

			-- set album or artist info
			exaile.info.artist = data.Metadata["xesam:artist"] and data.Metadata["xesam:artist"][1] or "Unknown"
			exaile.info.album  = data.Metadata["xesam:album"] or "Unknown"
			exaile.update_artist()


			-- set cover art
			--if data.Metadata["mpris:artUrl"] and data.Metadata["mpris:artUrl"] ~= last.art then
			if data.Metadata["mpris:artUrl"] then
				local image = string.match(data.Metadata["mpris:artUrl"], "file://(.+)")
				exaile.box.image:set_color(nil)
				exaile.box.image:set_image(image)
			end
		end

		-- update player volume info
		-- !!! Workaround bacause awesome dbus doesn't recognize data.Volume double type !!!
		if not data.PlaybackStatus and not data.Metadata or not last.volume_checked then
			asyncshell.request(command .. "GetVolume", function(o) exaile.volume:set_value(o /100) end)
			last.volume_checked = true
		end
	end
)

-- End
-----------------------------------------------------------------------------------------------------------------------
return exaile
