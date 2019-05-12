-----------------------------------------------------------------------------------------------------------------------
--                                                 Orange theme                                                      --
-----------------------------------------------------------------------------------------------------------------------
local awful = require("awful")

-- This theme was inherited from another with overwriting some values
-- Check parent theme to find full settings list and its description
local theme = require("themes/colored/theme")


-- Color scheme
-----------------------------------------------------------------------------------------------------------------------
theme.color.main   = "#B22B00"
theme.color.urgent = "#064A71"


-- Common
-----------------------------------------------------------------------------------------------------------------------
theme.path = awful.util.get_configuration_dir() .. "themes/orange"

-- Main config
--------------------------------------------------------------------------------
theme.panel_height = 36 -- panel height
theme.wallpaper    = theme.path .. "/wallpaper/custom.png"

-- Setup parent theme settings
--------------------------------------------------------------------------------
theme:update()


-- Desktop config
-----------------------------------------------------------------------------------------------------------------------
theme.desktop.textset = {
	font  = "Belligerent Madness 22",
	spacing = 10,
	color = theme.desktop.color
}


-- Panel widgets
-----------------------------------------------------------------------------------------------------------------------

-- individual margins for panel widgets
------------------------------------------------------------
theme.widget.wrapper = {
	layoutbox   = { 12, 10, 6, 6 },
	textclock   = { 10, 10, 0, 0 },
	volume      = { 10, 10, 5, 5 },
	network     = { 4, 4, 5, 5 },
	keyboard    = { 10, 10, 4, 4 },
	taglist     = { 4, 4, 0, 0 },
	mail        = { 10, 10, 4, 4 },
	battery     = { 0, 5, 0, 0 },
	cpu         = { 5, 0, 0, 0 },
	tray        = { 10, 12, 7, 7 },
	tasklist    = { 6, 0, 0, 0 }, -- centering tasklist widget
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
