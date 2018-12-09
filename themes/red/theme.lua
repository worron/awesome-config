-----------------------------------------------------------------------------------------------------------------------
--                                                   Red theme                                                       --
-----------------------------------------------------------------------------------------------------------------------
local awful = require("awful")

-- This theme was inherited from another with overwriting some values
-- Check parent theme to find full settings list and its description
local theme = require("themes/colored/theme")


-- Color scheme
-----------------------------------------------------------------------------------------------------------------------
theme.color.main   = "#A90017"
theme.color.urgent = "#00725B"


-- Common
-----------------------------------------------------------------------------------------------------------------------
theme.path = awful.util.get_configuration_dir() .. "themes/red"

-- Main config
--------------------------------------------------------------------------------
theme.panel_height = 36 -- panel height
theme.wallpaper    = theme.path .. "/wallpaper/custom.png"

-- Setup parent theme settings
--------------------------------------------------------------------------------
theme:update()


-- Desktop config
-----------------------------------------------------------------------------------------------------------------------

-- Desktop widgets
--------------------------------------------------------------------------------
--theme.desktop.speedmeter.images = { theme.path .. "/desktop/up.svg", theme.path .. "/desktop/down.svg" }
--
---- Desktop widgets placement
----------------------------------------------------------------------------------
--theme.desktop.grid = {
--	width  = { 520, 520, 520 },
--	height = { 180, 160, 160, 138, 18 },
--	edge   = { width = { 60, 60 }, height = { 40, 40 } }
--}
--
--theme.desktop.places = {
--	netspeed = { 1, 1 },
--	ssdspeed = { 2, 1 },
--	hddspeed = { 3, 1 },
--	cpumem   = { 1, 2 },
--	transm   = { 1, 3 },
--	disks    = { 1, 4 },
--	thermal  = { 1, 5 }
--}


-- Panel widgets
-----------------------------------------------------------------------------------------------------------------------

-- individual margins for palnel widgets
--------------------------------------------------------------------------------
theme.widget.wrapper = {
	layoutbox   = { 12, 10, 6, 6 },
	textclock   = { 10, 10, 0, 0 },
	volume      = { 10, 10, 5, 5 },
	network     = { 10, 10, 5, 5 },
	cpuram      = { 10, 10, 5, 5 },
	keyboard    = { 10, 10, 4, 4 },
	mail        = { 10, 10, 4, 4 },
	battery     = { 8, 10, 7, 7 },
	tray        = { 8, 8, 7, 7 },
	--tasklist    = { 4, 0, 0, 0 }, -- centering tasklist widget
}

-- Tasklist
--------------------------------------------------------------------------------
--theme.widget.tasklist.char_digit = 5
--theme.widget.tasklist.task = theme.gauge.task.blue
--

-- Pulseaudio volume control
------------------------------------------------------------
theme.widget.pulse.audio = { icon = { volume = theme.wicon.audio, mute = theme.wicon.mute } }


-- End
-----------------------------------------------------------------------------------------------------------------------
return theme
