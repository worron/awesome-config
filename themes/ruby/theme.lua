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
	layoutbox   = { 12, 10, 7, 7 },
	textclock   = { 10, 10, 0, 0 },
	volume      = { 10, 10, 7, 7 },
	network     = { 6, 6, 8, 8 },
	keyboard    = { 10, 10, 5, 5 },
	taglist     = { 4, 4, 0, 0 },
	mail        = { 10, 10, 5, 5 },
	cpu         = { 10, 2, 8, 8 },
	ram         = { 2, 2, 8, 8 },
	battery     = { 2, 10, 8, 8 },
	tray        = { 10, 12, 8, 8 },
	--tasklist    = { 6, 0, 0, 0 }, -- centering tasklist widget
}


-- Tag (base element of taglist)
------------------------------------------------------------
theme.gauge.tag.orange.width = 36

-- Tasklist
------------------------------------------------------------
theme.widget.tasklist.char_digit = 5
theme.widget.tasklist.task = theme.gauge.task.blue

-- End
-----------------------------------------------------------------------------------------------------------------------
return theme
