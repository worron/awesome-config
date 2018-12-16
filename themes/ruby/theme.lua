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
theme.panel_height = 40 -- panel height
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
	layoutbox   = { 12, 10, 7, 6 },
	textclock   = { 10, 10, 0, 0 },
	volume      = { 10, 10, 6, 6 },
	network     = { 6, 6, 7, 7 },
	keyboard    = { 10, 10, 4, 3 },
	taglist     = { 5, 5, 5, 5 },
	mail        = { 10, 10, 4, 3 },
	cpu         = { 10, 3, 7, 7 },
	ram         = { 2, 2, 7, 7 },
	battery     = { 3, 10, 7, 7 },
	tray        = { 10, 12, 7, 7 },
	--tasklist    = { 6, 0, 0, 0 }, -- centering tasklist widget
}

-- Dotcount
------------------------------------------------------------
theme.gauge.graph.dots.dot_gap_h = 5

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
