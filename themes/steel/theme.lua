-----------------------------------------------------------------------------------------------------------------------
--                                                  steel theme                                                      --
-----------------------------------------------------------------------------------------------------------------------
local awful = require("awful")

-- This theme was inherited from another with overwriting some values
-- Check parent theme to find full settings list and its description
local theme = require("themes/colored/theme")


-- Color scheme
-----------------------------------------------------------------------------------------------------------------------
theme.color.main   = "#025A73"
theme.color.urgent = "#BA1900"

-- Common
-----------------------------------------------------------------------------------------------------------------------
theme.path = awful.util.get_configuration_dir() .. "themes/steel"

-- Main config
--------------------------------------------------------------------------------
theme.panel_height = 38 -- panel height
theme.border_width = 0  -- window border width
theme.useless_gap  = 0  -- useless gap
theme.wallpaper    = theme.path .. "/wallpaper/primary.png"

-- Setup parent theme settings
--------------------------------------------------------------------------------
theme:update()


-- Desktop config
-----------------------------------------------------------------------------------------------------------------------

-- Desktop widgets placement
--------------------------------------------------------------------------------


-- Panel widgets
-----------------------------------------------------------------------------------------------------------------------

-- individual margins for panel widgets
--------------------------------------------------------------------------------
theme.widget.wrapper = {
	binclock    = { 10, 10, 7, 7 },
	volume      = { 6, 9, 7, 7 },
	tray        = { 8, 8, 7, 7 },
	cpu         = { 9, 3, 7, 7 },
	ram         = { 2, 2, 7, 7 },
	battery     = { 3, 9, 7, 7 },
	network     = { 4, 4, 7, 7 },
	updates     = { 10, 10, 7, 7 },
	taglist     = { 4, 4, 0, 0 },
	tasklist    = { 0, 9, 0, 0 }, -- centering tasklist widget
}

-- Various widgets style tuning
------------------------------------------------------------

-- Dotcount
theme.gauge.graph.dots.dot_gap_h = 5

-- System updates indicator
theme.widget.updates.icon = theme.icon.awesome

-- Audio
theme.gauge.audio.blue.dash.plain = true
theme.gauge.audio.blue.dash.bar.num = 8
theme.gauge.audio.blue.dash.bar.width = 3
theme.gauge.audio.blue.dmargin = { 7, 0, 5, 5 }
theme.gauge.audio.blue.width = 80
theme.gauge.audio.blue.icon = theme.path .. "/widget/audio.svg"

-- Dash
theme.gauge.monitor.dash.width = 11

-- Tags
theme.gauge.tag.green.width = 42
theme.gauge.tag.green.margin = { 0, 0, 7, 7 }

-- Tasklist
theme.gauge.task.ruby.width = 80
theme.gauge.task.ruby.underline  = { height = 12, thickness = 3, gap = 34, dh = 5 }

theme.widget.tasklist.char_digit = 5
theme.widget.tasklist.task = theme.gauge.task.ruby

-- End
-----------------------------------------------------------------------------------------------------------------------
return theme
