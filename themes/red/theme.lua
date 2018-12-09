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
theme.panel_height = 50 -- panel height
theme.useless_gap  = 6  -- useless gap
theme.wallpaper    = theme.path .. "/wallpaper/custom.png"

-- Fonts
------------------------------------------------------------
theme.cairo_fonts.tag = { font = "Play", size = 20, face = 1 } -- taglist widget

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
	textclock   = { 4, 20, 0, 0 },
	layoutbox   = { 4, 4, 9, 9 },
	volume      = { 4, 4, 5, 5 },
	upgrades    = { 4, 4, 9, 9 },
	keyboard    = { 4, 4, 5, 5 },
	mail        = { 4, 4, 5, 5 },
	battery     = { 3, 3, 0, 0 },
	ram         = { 3, 3, 0, 0 },
	cpu         = { 3, 3, 0, 0 },
	tray        = { 1, 1, 8, 8 },
	network     = { 1, 1, 8, 8 },
	taglist     = { 12, 0, 0, 0 },
	tasklist    = { 4, 4, 0, 0 },
}

-- Separator
------------------------------------------------------------
theme.gauge.separator.marginv = { 12, 12, 5, 5 }
theme.gauge.separator.marginh = { 8, 8, 3, 3 }

-- Dotcount
------------------------------------------------------------
theme.gauge.graph.dots.column_num   = { 2, 3 }
theme.gauge.graph.dots.row_num      = 4
theme.gauge.graph.dots.dot_size     = 5
theme.gauge.graph.dots.dot_gap_h    = 5

-- Tag
------------------------------------------------------------
theme.gauge.tag.red.width        = 100
theme.gauge.tag.red.text_shift   = 28
theme.gauge.tag.red.counter      = { size = 13, margin = 3, coord = { 50, 38 } }
theme.gauge.tag.red.show_counter = false

theme.gauge.tag.red.geometry = {
	active   = {         y = 36,             height = 4  },
	focus    = { x = 4,  y = 14, width = 13, height = 13 },
	occupied = { x = 85, y = 8,  width = 9,  height = 15 }
}

-- Task
------------------------------------------------------------
theme.gauge.task.red.width      = 50
theme.gauge.task.red.text_shift = theme.gauge.tag.red.text_shift
theme.gauge.task.red.line       = { height = 4, y = 36 }
theme.gauge.task.red.counter    = { size = 13, margin = 3 }

-- Monitor
--------------------------------------------------------------
theme.gauge.monitor.plain.text_shift = theme.gauge.tag.red.text_shift
theme.gauge.monitor.plain.line       = theme.gauge.task.red.line

-- Tasklist
--------------------------------------------------------------------------------
theme.widget.tasklist.char_digit = 3
theme.widget.tasklist.task = theme.gauge.task.red

-- Pulseaudio volume control
------------------------------------------------------------
theme.widget.pulse.audio = { icon = { volume = theme.wicon.audio, mute = theme.wicon.mute } }

-- System updates indicator
------------------------------------------------------------
theme.widget.upgrades.icon = theme.icon.awesome

-- Minitray
------------------------------------------------------------
theme.widget.minitray.geometry = { height = 50 }

-- End
-----------------------------------------------------------------------------------------------------------------------
return theme
