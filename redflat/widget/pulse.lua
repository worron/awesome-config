-----------------------------------------------------------------------------------------------------------------------
--                                   RedFlat pulseaudio volume control widget                                        --
-----------------------------------------------------------------------------------------------------------------------
-- Indicate and change volume level using pacmd
-----------------------------------------------------------------------------------------------------------------------
-- Some code was taken from
------ Pulseaudio volume control
------ https://github.com/orofarne/pulseaudio-awesome/blob/master/pulseaudio.lua
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local io = io
local math = math
local table = table
local tonumber = tonumber
local tostring = tostring
local string = string
local setmetatable = setmetatable
local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")

local tooltip = require("redflat.float.tooltip")
local audio = require("redflat.gauge.redaudio")
local rednotify = require("redflat.float.notify")
local redutil = require("redflat.util")


-- Initialize tables and vars for module
-----------------------------------------------------------------------------------------------------------------------
local pulse = { widgets = {}, mt = {} }

pulse.startup_time = 4

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		notify_icon = nil,
		widget      = audio.new,
		audio       = {}
	}
	return redutil.table.merge(style, redutil.check(beautiful, "widget.pulse") or {})
end

local change_volume_default_args = {
	down        = false,
	step        = 655 * 5,
	show_notify = false
}

-- Change volume level
-----------------------------------------------------------------------------------------------------------------------
function pulse:change_volume(args)

	-- initialize vars
	local args = redutil.table.merge(change_volume_default_args, args or {})
	local diff = args.down and -args.step or args.step

	-- get current volume
	local v = awful.util.pread("pacmd dump |grep set-sink-volume")
	local volume = tonumber(string.sub(v, string.find(v, 'x') - 1))

	-- calculate new volume
	local new_volume = volume + diff

	if new_volume > 65536 then
		new_volume = 65536
	elseif new_volume < 0 then
		new_volume = 0
	end

	-- show notify if need
	if args.show_notify then
		local vol = new_volume / 65536
		rednotify:show({value = vol, text = string.format('%.0f', vol*100) .. "%", icon = pulse.notify_icon})
	end

	-- set new volume
	awful.util.spawn("pacmd set-sink-volume 0 "..new_volume)
	-- update volume indicators
	self:update_volume()
end

-- Set mute
-----------------------------------------------------------------------------------------------------------------------
function pulse:mute()
	local mute = awful.util.pread("pacmd dump |grep set-sink-mute")
	if string.find(mute, "no") then
		awful.util.spawn("pacmd set-sink-mute 0 yes")
	else
		awful.util.spawn("pacmd set-sink-mute 0 no")
	end
	self:update_volume()
end

-- Update volume level info
-----------------------------------------------------------------------------------------------------------------------
function pulse:update_volume()

	-- initialize vars
	local volmax = 65536
	local volume = 0
	local mute

	-- get current volume and mute state
	local v = awful.util.pread("pacmd dump |grep set-sink-volume")
	local m = awful.util.pread("pacmd dump |grep set-sink-mute")

	if v then
		local pv = string.find(v, 'x')
		if pv then volume = math.floor(tonumber(string.sub(v, pv - 1)) * 100 / volmax) end
	end

	if m ~= nil and string.find(m, "no") then
		mute = false
	else
		mute = true
	end

	-- update tooltip
	self.tooltip:set_text(volume.."%")

	-- update widgets value
	for _, w in ipairs(pulse.widgets) do
		w:set_value(volume/100)
		w:set_mute(mute)
	end
end

-- Create a new pulse widget
-- @param timeout Update interval
-----------------------------------------------------------------------------------------------------------------------
function pulse.new(args, style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	local style = redutil.table.merge(default_style(), style or {})
	pulse.notify_icon = style.notify_icon

	local counter = 0
	local args = args or {}
	local timeout = args.timeout or 30

	-- create widget
	--------------------------------------------------------------------------------
	widg = style.widget(style.audio)
	table.insert(pulse.widgets, widg)

	-- Set tooltip
	--------------------------------------------------------------------------------
	if not pulse.tooltip then
		pulse.tooltip = tooltip({ widg }, style.tooltip)
	else
		pulse.tooltip:add_to_object(widg)
	end

	--[[
	-- Set update timer
	--------------------------------------------------------------------------------
	local t = timer({ timeout = timeout })
	t:connect_signal("timeout", function() pulse:update_volume() end)
	t:start()
	--]]

	-- Set startup timer
	-- This is workaround if widget created bofore pulseaudio servise start
	--------------------------------------------------------------------------------
	pulse.startup_updater = timer({ timeout = 1 })
	pulse.startup_updater:connect_signal("timeout",
		function()
			counter = counter + 1
			pulse:update_volume()
			if counter > pulse.startup_time then pulse.startup_updater:stop() end
		end
	)
	pulse.startup_updater:start()

	--------------------------------------------------------------------------------
	pulse:update_volume()
	return widg
end

-- Config metatable to call pulse module as function
-----------------------------------------------------------------------------------------------------------------------
function pulse.mt:__call(...)
	return pulse.new(...)
end

return setmetatable(pulse, pulse.mt)
