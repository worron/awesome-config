-----------------------------------------------------------------------------------------------------------------------
--                                                  Ruby theme                                                       --
-----------------------------------------------------------------------------------------------------------------------
local awful = require("awful")

-- This theme was inherited from another with overwriting some values
-- Check parent theme to find full settings list and its description
local theme = require("themes/colored/theme")


-- Color scheme
-----------------------------------------------------------------------------------------------------------------------
theme.color.main   = "#b20d1d"
theme.color.urgent = "#087465"


-- Common
-----------------------------------------------------------------------------------------------------------------------
theme.path = awful.util.get_configuration_dir() .. "themes/ruby"

-- Main config
--------------------------------------------------------------------------------
theme.panel_height = 36 -- panel height
theme.wallpaper    = theme.path .. "/wallpaper/custom.png"

-- Setup parent theme settings
--------------------------------------------------------------------------------
theme:update()


-- Desktop config
-----------------------------------------------------------------------------------------------------------------------

-- Panel widgets
-----------------------------------------------------------------------------------------------------------------------

-- individual margins for palnel widgets
------------------------------------------------------------
theme.widget.wrapper = {
	layoutbox   = { 12, 10, 6, 5 },
	textclock   = { 10, 10, 0, 0 },
	volume      = { 10, 10, 5, 4 },
	keyboard    = { 10, 10, 3, 3 },
	mail        = { 10, 10, 3, 3 },
	tray        = { 8, 8, 7, 7 },
	cpu         = { 9, 3, 6, 6 },
	ram         = { 2, 2, 6, 6 },
	battery     = { 3, 9, 6, 6 },
	network     = { 4, 4, 6, 5 },
	taglist     = { 5, 5, 5, 4 },
	--tasklist    = { 6, 0, 0, 0 }, -- centering tasklist widget
}

-- Dotcount
------------------------------------------------------------
--theme.gauge.graph.dots.dot_gap_h = 5

-- Dash
------------------------------------------------------------
theme.gauge.monitor.dash.width = 11


-- Tag (base element of taglist)
------------------------------------------------------------

-- Tasklist
------------------------------------------------------------
theme.widget.tasklist.char_digit = 5
theme.widget.tasklist.task = theme.gauge.task.blue

-- End
-----------------------------------------------------------------------------------------------------------------------
return theme
